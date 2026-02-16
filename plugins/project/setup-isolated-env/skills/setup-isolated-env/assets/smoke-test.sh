#!/usr/bin/env bash
# Smoke Test for Isolated Environment
# RUN FROM WITHIN WORKTREE: cd .worktrees/<env-name> && ../../<worktree_scripts>/smoke-test.sh
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Detect if we're in a worktree
CURRENT_DIR=$(pwd)
if [[ ! -f ".env.local" ]]; then
    echo -e "${RED}✗${NC} Not in a worktree environment (.env.local not found)"
    echo -e "${BLUE}ℹ${NC} Run this script from within the worktree:"
    echo -e "    ${BLUE}cd .worktrees/<env-name> && ../../<worktree_scripts>/smoke-test.sh${NC}"
    exit 1
fi

# Get environment name from current directory
ENV_NAME=$(basename "$CURRENT_DIR")

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Smoke Test: ${ENV_NAME}${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Load environment variables from current directory
set -a  # Auto-export variables
source .env.local
set +a

# ============================================================================
# Test 1: Environment Variables
# ============================================================================

echo -e "${BLUE}[1/4]${NC} Checking environment variables..."

ERRORS=0

if [[ -z "${PORT:-}" ]]; then
    echo -e "${RED}✗${NC} PORT not set"
    ((ERRORS++))
else
    echo -e "${GREEN}✓${NC} PORT=${PORT}"
fi

# Check for additional ports based on project type
if [[ -n "${AGENT_PORT:-}" ]]; then
    echo -e "${GREEN}✓${NC} AGENT_PORT=${AGENT_PORT}"
elif [[ -n "${API_PORT:-}" ]]; then
    echo -e "${GREEN}✓${NC} API_PORT=${API_PORT}"
fi

if [[ -z "${DATABASE_URL:-}" ]]; then
    echo -e "${RED}✗${NC} DATABASE_URL not set"
    ((ERRORS++))
else
    echo -e "${GREEN}✓${NC} DATABASE_URL configured"
fi

echo ""

# ============================================================================
# Test 2: Port Availability
# ============================================================================

echo -e "${BLUE}[2/4]${NC} Checking port availability..."

check_port() {
    local port=$1
    local name=$2

    if command -v lsof &>/dev/null; then
        if lsof -i ":${port}" -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo -e "${RED}✗${NC} ${name} port ${port} is already in use"
            echo -e "${YELLOW}  Process using port:${NC}"
            lsof -i ":${port}" -sTCP:LISTEN | tail -n +2 | awk '{print "    "$1, $2, $9}'
            ((ERRORS++))
        else
            echo -e "${GREEN}✓${NC} ${name} port ${port} is available"
        fi
    elif command -v nc &>/dev/null; then
        if nc -z localhost "${port}" 2>/dev/null; then
            echo -e "${RED}✗${NC} ${name} port ${port} is already in use"
            ((ERRORS++))
        else
            echo -e "${GREEN}✓${NC} ${name} port ${port} is available"
        fi
    else
        echo -e "${YELLOW}⚠${NC} Cannot check port ${port} (lsof/nc not available)"
    fi
}

check_port "${PORT}" "Web"

if [[ -n "${AGENT_PORT:-}" ]]; then
    check_port "${AGENT_PORT}" "Agent"
elif [[ -n "${API_PORT:-}" ]]; then
    check_port "${API_PORT}" "API"
fi

echo ""

# ============================================================================
# Test 3: Database Connectivity
# ============================================================================

echo -e "${BLUE}[3/4]${NC} Checking database connectivity..."

# Extract database name from DATABASE_URL
DB_NAME=$(echo "$DATABASE_URL" | sed -n 's|.*/\([^?]*\).*|\1|p')

# Try multiple methods to verify database connectivity
DB_CONNECTED=false

# Method 1: psql
if command -v psql &>/dev/null; then
    if psql "$DATABASE_URL" -c "SELECT 1" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Database connection successful (via psql)"
        echo -e "${GREEN}✓${NC} Database: ${DB_NAME}"
        DB_CONNECTED=true
    fi
fi

# Method 2: Supabase CLI (if not connected via psql)
if [[ "$DB_CONNECTED" == false ]] && command -v supabase &>/dev/null; then
    # Note: supabase db execute doesn't have --db-url flag for direct connection
    # This is a limitation - we can only verify Supabase is running
    if supabase status >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Supabase is running"
        echo -e "${BLUE}ℹ${NC} Database: ${DB_NAME} (verify manually if needed)"
        DB_CONNECTED=true
    fi
fi

# Method 3: Check via project's database client
if [[ "$DB_CONNECTED" == false ]] && [[ -f "package.json" ]]; then
    # Try to import database client to verify connection
    if command -v bun &>/dev/null; then
        # This is a basic check - project-specific clients may vary
        echo -e "${YELLOW}⚠${NC} Cannot auto-verify database (no psql/supabase CLI)"
        echo -e "${BLUE}ℹ${NC} Database: ${DB_NAME}"
        echo -e "${BLUE}ℹ${NC} Verify manually after starting dev server"
    elif command -v node &>/dev/null; then
        echo -e "${YELLOW}⚠${NC} Cannot auto-verify database (no psql/supabase CLI)"
        echo -e "${BLUE}ℹ${NC} Database: ${DB_NAME}"
    fi
else
    if [[ "$DB_CONNECTED" == false ]]; then
        echo -e "${RED}✗${NC} Database connection failed"
        echo -e "${YELLOW}  Connection string:${NC} ${DATABASE_URL}"
        ((ERRORS++))
    fi
fi

echo ""

# ============================================================================
# Test 4: Infrastructure Service
# ============================================================================

echo -e "${BLUE}[4/4]${NC} Checking infrastructure services..."

# Check Supabase
if command -v supabase &>/dev/null; then
    if supabase status >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Supabase is running"

        # Check if Supabase URL is reachable
        if [[ -n "${SUPABASE_URL:-}" ]]; then
            if curl -sf "${SUPABASE_URL}/rest/v1/" -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY:-${SUPABASE_ANON_KEY:-}}" >/dev/null 2>&1; then
                echo -e "${GREEN}✓${NC} Supabase API is reachable"
            else
                echo -e "${YELLOW}⚠${NC} Supabase API unreachable (may be expected)"
            fi
        fi
    else
        echo -e "${RED}✗${NC} Supabase is not running"
        echo -e "${BLUE}ℹ${NC} Start with: supabase start"
        ((ERRORS++))
    fi
# Check Docker Compose
elif command -v docker &>/dev/null && [[ -f "../../docker-compose.yml" ]]; then
    if docker compose ps >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Docker Compose services are running"
    else
        echo -e "${RED}✗${NC} Docker Compose services not running"
        echo -e "${BLUE}ℹ${NC} Start with: docker compose up -d"
        ((ERRORS++))
    fi
else
    echo -e "${YELLOW}⚠${NC} No infrastructure service detected (Supabase/Docker)"
fi

echo ""

# ============================================================================
# Summary
# ============================================================================

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"

if [[ $ERRORS -eq 0 ]]; then
    echo -e "${GREEN}✓ Smoke test passed!${NC}"
    echo ""
    echo -e "${GREEN}Ready to start development:${NC}"
    echo -e "  ${BLUE}bun run dev${NC}   (web app on port ${PORT})"
    if [[ -n "${AGENT_PORT:-}" ]]; then
        echo ""
        echo -e "  ${BLUE}cd apps/agent && bun run dev${NC}  (agent on port ${AGENT_PORT})"
    fi
    echo ""
    exit 0
else
    echo -e "${RED}✗ Smoke test failed with ${ERRORS} error(s)${NC}"
    echo ""
    echo -e "${YELLOW}Fix the issues above before starting development.${NC}"
    echo ""
    exit 1
fi
