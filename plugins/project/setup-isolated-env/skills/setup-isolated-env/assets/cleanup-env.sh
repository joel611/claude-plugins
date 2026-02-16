#!/usr/bin/env bash
# Cleanup Isolated Environment
# Removes git worktree and drops isolated database
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if environment name is provided
if [[ $# -eq 0 ]]; then
    echo -e "${RED}✗${NC} Usage: <worktree_scripts>/cleanup-env.sh <env-name>"
    echo -e "${BLUE}ℹ${NC} Example: .worktrees_scripts/cleanup-env.sh feature-auth"
    exit 1
fi

ENV_NAME="$1"
ENV_NAME_SANITIZED=$(echo "$ENV_NAME" | tr '/-.' '_')
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKTREE_PATH="${PROJECT_ROOT}/.worktrees/${ENV_NAME}"
DB_NAME="${ENV_NAME_SANITIZED}_db"

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Cleanup Environment: ${ENV_NAME}${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Check if worktree exists
if [[ ! -d "$WORKTREE_PATH" ]]; then
    echo -e "${YELLOW}⚠${NC} Worktree not found: ${WORKTREE_PATH}"
    echo -e "${BLUE}ℹ${NC} It may have already been removed"
else
    echo -e "${BLUE}ℹ${NC} Worktree path: ${WORKTREE_PATH}"
fi

# Confirmation prompt
echo -e "${YELLOW}⚠ WARNING:${NC} This will delete:"
echo -e "  - Git worktree: ${WORKTREE_PATH}"
echo -e "  - Database: ${DB_NAME}"
echo ""
echo -e "This action ${RED}cannot be undone${NC}."
echo ""
read -p "Are you sure? (type 'yes' to confirm): " confirmation

if [[ "$confirmation" != "yes" ]]; then
    echo -e "${BLUE}ℹ${NC} Cleanup cancelled"
    exit 0
fi

echo ""

# ============================================================================
# Step 1: Remove Git Worktree
# ============================================================================

echo -e "${BLUE}[1/2]${NC} Removing git worktree..."

if [[ -d "$WORKTREE_PATH" ]]; then
    # Check if there are uncommitted changes
    if [[ -n "$(cd "$WORKTREE_PATH" && git status --porcelain)" ]]; then
        echo -e "${YELLOW}⚠${NC} Worktree has uncommitted changes:"
        (cd "$WORKTREE_PATH" && git status --short)
        echo ""
        read -p "Delete anyway? (type 'yes' to confirm): " force_confirm

        if [[ "$force_confirm" != "yes" ]]; then
            echo -e "${BLUE}ℹ${NC} Cleanup cancelled"
            exit 0
        fi

        # Force remove worktree
        git worktree remove --force "$WORKTREE_PATH"
        echo -e "${GREEN}✓${NC} Worktree removed (forced)"
    else
        git worktree remove "$WORKTREE_PATH"
        echo -e "${GREEN}✓${NC} Worktree removed"
    fi
else
    echo -e "${YELLOW}⚠${NC} Worktree not found (may have been removed manually)"
fi

echo ""

# ============================================================================
# Step 2: Drop Database
# ============================================================================

echo -e "${BLUE}[2/2]${NC} Dropping database..."

# Database cleanup - adapt based on infrastructure
drop_database() {
    # Try Supabase first
    if command -v supabase &>/dev/null && supabase status &>/dev/null 2>&1; then
        # Get database port from Supabase status
        local supabase_status
        supabase_status=$(supabase status)
        local db_port
        db_port=$(echo "$supabase_status" | grep "DB URL" | awk -F: '{print $(NF-1)}' | awk -F/ '{print $1}')

        if [[ -z "$db_port" ]]; then
            db_port="54322"  # Default Supabase local port
        fi

        # Drop database using psql
        if command -v psql &>/dev/null; then
            if PGPASSWORD=postgres psql -h 127.0.0.1 -p "$db_port" -U postgres -d postgres \
                -c "DROP DATABASE IF EXISTS ${DB_NAME};" 2>&1; then
                echo -e "${GREEN}✓${NC} Database ${DB_NAME} dropped"
                return 0
            fi
        fi

        # Note: Cannot use Supabase MCP from bash script
        echo -e "${YELLOW}⚠${NC} Cannot drop database via psql"
        echo -e "${BLUE}ℹ${NC} Manual cleanup required:"
        echo -e "    ${BLUE}Open Claude Code and execute: DROP DATABASE IF EXISTS ${DB_NAME}${NC}"
        return 1

    # Try Docker Compose
    elif command -v docker &>/dev/null && [[ -f "docker-compose.yml" ]]; then
        if docker compose exec -T postgres psql -U postgres -c "DROP DATABASE IF EXISTS ${DB_NAME};" 2>&1; then
            echo -e "${GREEN}✓${NC} Database ${DB_NAME} dropped"
            return 0
        else
            echo -e "${YELLOW}⚠${NC} Failed to drop database via Docker Compose"
            return 1
        fi

    else
        echo -e "${YELLOW}⚠${NC} No database service detected"
        echo -e "${BLUE}ℹ${NC} Database ${DB_NAME} may need manual cleanup"
        return 1
    fi
}

drop_database || true  # Don't fail cleanup if database drop fails

echo ""

# ============================================================================
# Summary
# ============================================================================

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Cleanup complete${NC}"
echo ""
echo -e "${BLUE}Removed:${NC}"
echo -e "  - Worktree: ${ENV_NAME}"
echo -e "  - Database: ${DB_NAME} (if cleanup succeeded)"
echo ""
