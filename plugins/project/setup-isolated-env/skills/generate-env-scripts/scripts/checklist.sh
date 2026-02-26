#!/usr/bin/env bash
set -euo pipefail

# Infrastructure Checklist for Worktree Setup
# Detects available services and validates prerequisites

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ $1${NC}"; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
error() { echo -e "${RED}✗ $1${NC}"; }

echo ""
echo "=== Worktree Setup Infrastructure Checklist ==="
echo ""

# Track findings
DOCKER_COMPOSE_FOUND=false
SUPABASE_FOUND=false
ENV_TEMPLATE_FOUND=false
SERVICES_DETECTED=()

# 1. Check for Docker Compose
info "Checking for Docker Compose..."
if [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]; then
    success "Docker Compose file found"
    DOCKER_COMPOSE_FOUND=true

    # Extract services from docker-compose.yml
    if [[ -f "docker-compose.yml" ]]; then
        COMPOSE_FILE="docker-compose.yml"
    else
        COMPOSE_FILE="docker-compose.yaml"
    fi

    # Detect Postgres
    if grep -q "postgres" "$COMPOSE_FILE"; then
        SERVICES_DETECTED+=("postgres")
        success "  - PostgreSQL detected"
    fi

    # Detect Redis
    if grep -q "redis" "$COMPOSE_FILE"; then
        SERVICES_DETECTED+=("redis")
        success "  - Redis detected"
    fi

    # Check if Docker is running
    if docker compose ps &>/dev/null; then
        success "  - Docker Compose is running"
    else
        warn "  - Docker Compose not running (run: docker compose up -d)"
    fi
else
    warn "Docker Compose file not found"
fi

# 2. Check for Supabase
info "Checking for Supabase..."
if [[ -f "supabase/config.toml" ]] || command -v supabase &>/dev/null; then
    success "Supabase configuration found"
    SUPABASE_FOUND=true
    SERVICES_DETECTED+=("supabase-postgres")

    # Check if Supabase is running
    if supabase status &>/dev/null 2>&1; then
        success "  - Supabase is running"
    else
        warn "  - Supabase not running (run: supabase start)"
    fi
else
    warn "Supabase not found"
fi

# 3. Check for environment template files
info "Checking for environment templates..."
if [[ -f ".env.example" ]]; then
    success ".env.example found"
    ENV_TEMPLATE_FOUND=true
    ENV_TEMPLATE=".env.example"
elif [[ -f ".env.local.example" ]]; then
    success ".env.local.example found"
    ENV_TEMPLATE_FOUND=true
    ENV_TEMPLATE=".env.local.example"
elif [[ -f "env.example" ]]; then
    success "env.example found"
    ENV_TEMPLATE_FOUND=true
    ENV_TEMPLATE="env.example"
else
    error "No environment template found (.env.example, .env.local.example, or env.example)"
fi

# 4. Parse environment template for service hints
if [[ "$ENV_TEMPLATE_FOUND" == true ]]; then
    info "Analyzing environment template..."

    # Check for database URL
    if grep -q "DATABASE_URL" "$ENV_TEMPLATE"; then
        success "  - Database URL configuration found"

        # Try to identify database type
        if grep "DATABASE_URL" "$ENV_TEMPLATE" | grep -q "postgresql"; then
            if [[ ! " ${SERVICES_DETECTED[*]} " =~ " postgres " ]] && [[ ! " ${SERVICES_DETECTED[*]} " =~ " supabase-postgres " ]]; then
                SERVICES_DETECTED+=("postgres")
                info "  - PostgreSQL detected from DATABASE_URL"
            fi
        fi
    fi

    # Check for Redis configuration
    if grep -q "REDIS" "$ENV_TEMPLATE"; then
        success "  - Redis configuration found"
        if [[ ! " ${SERVICES_DETECTED[*]} " =~ " redis " ]]; then
            SERVICES_DETECTED+=("redis")
        fi
    fi

    # Check for port configurations
    if grep -q "^PORT=" "$ENV_TEMPLATE" || grep -q "^VITE_PORT=" "$ENV_TEMPLATE"; then
        success "  - Port configuration found"
    else
        info "  - No PORT variable in template (will need to add)"
    fi

    # Check for API port
    if grep -q "API_PORT" "$ENV_TEMPLATE"; then
        success "  - API port configuration found"
    else
        info "  - No API_PORT variable in template (may need to add)"
    fi
fi

# 5. Check framework-specific port configurations
info "Checking framework-specific port configurations..."

FRAMEWORK_DETECTED=""
PORT_CONFIG_ISSUES=()

# Detect Vite
if [[ -f "vite.config.ts" ]] || [[ -f "vite.config.js" ]]; then
    FRAMEWORK_DETECTED="vite"
    success "Framework detected: Vite"

    # Check if port is configured to read from env
    if ! grep -E "port.*process\.env\.(PORT|VITE_PORT)" vite.config.* &>/dev/null; then
        warn "  - Vite config doesn't read port from environment"
        PORT_CONFIG_ISSUES+=("vite.config: Add 'server: { port: Number(process.env.PORT) || 5001 }'")
    else
        success "  - Vite port configured to read from environment"
    fi

    # Check package.json for hardcoded port in dev script
    if [[ -f "package.json" ]] && grep -q "\"dev\".*--port [0-9]" package.json; then
        warn "  - package.json dev script has hardcoded port"
        PORT_CONFIG_ISSUES+=("package.json: Remove '--port XXXX' from dev script")
    fi
fi

# Detect Next.js
if [[ -f "next.config.js" ]] || [[ -f "next.config.ts" ]] || [[ -f "next.config.mjs" ]]; then
    FRAMEWORK_DETECTED="nextjs"
    success "Framework detected: Next.js"

    # Next.js reads PORT automatically, just check package.json
    if [[ -f "package.json" ]] && grep -q "\"dev\".*next dev -p [0-9]" package.json; then
        warn "  - package.json dev script has hardcoded port"
        PORT_CONFIG_ISSUES+=("package.json: Remove '-p XXXX' from next dev command")
    else
        success "  - Next.js will read PORT environment variable automatically"
    fi
fi

# Check application entry points for hardcoded ports
for file in src/index.{ts,js} src/server.{ts,js} apps/*/src/index.{ts,js} server.{ts,js}; do
    if [[ -f "$file" ]]; then
        if grep -E "const (PORT|port) = [0-9]{4}" "$file" &>/dev/null; then
            warn "  - Hardcoded port in $file"
            PORT_CONFIG_ISSUES+=("$file: Change to 'const PORT = Number(process.env.PORT) || XXXX'")
        fi
    fi
done

if [[ ${#PORT_CONFIG_ISSUES[@]} -gt 0 ]]; then
    echo ""
    warn "Port configuration issues found (${#PORT_CONFIG_ISSUES[@]}):"
    for issue in "${PORT_CONFIG_ISSUES[@]}"; do
        echo "    - $issue"
    done
    echo ""
fi

# 6. Scan for hardcoded URLs that break worktree isolation
info "Scanning codebase for hardcoded service URLs..."

HARDCODED_URLS_FOUND=false
HARDCODED_FILES=()

# Common patterns that indicate hardcoded URLs
# Exclude common false positives: node_modules, .git, dist, build, coverage
SEARCH_DIRS="src app pages components lib utils config"
if [[ ! -d "src" ]] && [[ ! -d "app" ]]; then
    # Fallback to searching all files if standard dirs don't exist
    SEARCH_DIRS="."
fi

# Search for hardcoded localhost URLs with ports
while IFS= read -r match; do
    if [[ -n "$match" ]]; then
        HARDCODED_URLS_FOUND=true
        HARDCODED_FILES+=("$match")
    fi
done < <(grep -r "localhost:[0-9]" $SEARCH_DIRS \
    --exclude-dir={node_modules,.git,dist,build,coverage,.next,.turbo,out,.claude,.agent} \
    --exclude="*.{json,lock,md,svg,png,jpg,jpeg,gif,ico,woff,woff2,ttf,eot}" \
    -l 2>/dev/null || true)

# Search for http://localhost without port (might be relying on default)
while IFS= read -r match; do
    if [[ -n "$match" ]] && [[ ! " ${HARDCODED_FILES[*]} " =~ " ${match} " ]]; then
        HARDCODED_URLS_FOUND=true
        HARDCODED_FILES+=("$match")
    fi
done < <(grep -r "http://localhost[\"']" $SEARCH_DIRS \
    --exclude-dir={node_modules,.git,dist,build,coverage,.next,.turbo,out,.claude,.agent} \
    --exclude="*.{json,lock,md,svg,png,jpg,jpeg,gif,ico,woff,woff2,ttf,eot}" \
    -l 2>/dev/null || true)

# Search for hardcoded port numbers in config (common: 3000, 3001, 5000, 8080)
while IFS= read -r match; do
    if [[ -n "$match" ]] && [[ ! " ${HARDCODED_FILES[*]} " =~ " ${match} " ]]; then
        HARDCODED_URLS_FOUND=true
        HARDCODED_FILES+=("$match")
    fi
done < <(grep -r ":[\"']300[0-9]\|:[\"']5000\|:[\"']8080" $SEARCH_DIRS \
    --exclude-dir={node_modules,.git,dist,build,coverage,.next,.turbo,out,.claude,.agent} \
    --exclude="*.{json,lock,md,svg,png,jpg,jpeg,gif,ico,woff,woff2,ttf,eot}" \
    -l 2>/dev/null || true)

if [[ "$HARDCODED_URLS_FOUND" == true ]]; then
    warn "Hardcoded service URLs found in ${#HARDCODED_FILES[@]} file(s)"
    echo ""
    echo "Files with potential hardcoded URLs (sample):"
    for file in "${HARDCODED_FILES[@]:0:5}"; do
        echo "  - $file"
    done
    if [[ ${#HARDCODED_FILES[@]} -gt 5 ]]; then
        echo "  ... and $((${#HARDCODED_FILES[@]} - 5)) more"
    fi
    echo ""
    warn "These hardcoded URLs will break worktree isolation!"
    echo "Recommended fixes:"
    echo "  1. Replace with environment variables (e.g., process.env.NEXT_PUBLIC_API_URL)"
    echo "  2. Use relative URLs where possible (/api/... instead of http://localhost:3000/api/...)"
    echo "  3. Use dynamic port detection (e.g., window.location.origin)"
    echo ""
else
    success "No hardcoded service URLs detected"
fi

# 7. Summary and Recommendations
echo ""
echo "=== Summary ==="
echo ""

if [[ "$DOCKER_COMPOSE_FOUND" == false ]] && [[ "$SUPABASE_FOUND" == false ]]; then
    error "No container orchestration found (Docker Compose or Supabase)"
    echo ""
    echo "Recommendation: This project needs Docker Compose or Supabase for worktree isolation."
    echo "Without it, you cannot create isolated databases for each worktree."
    exit 1
fi

if [[ "$ENV_TEMPLATE_FOUND" == false ]]; then
    error "No environment template found"
    echo ""
    echo "Recommendation: Create .env.example with your project's environment variables."
    exit 1
fi

success "Prerequisites met for worktree setup"
echo ""
echo "Detected services:"
for service in "${SERVICES_DETECTED[@]}"; do
    echo "  - $service"
done

echo ""
echo "=== Next Steps ==="
echo ""
echo "1. Create scripts/ folder in project root"
echo "2. Generate tailored setup-env.sh based on detected services:"
if [[ "$SUPABASE_FOUND" == true ]]; then
    echo "   - Use Supabase CLI for database operations"
    echo "   - Example: supabase db execute --file migrations/create_db.sql"
elif [[ "$DOCKER_COMPOSE_FOUND" == true ]]; then
    echo "   - Use Docker Compose for service access"
    echo "   - Example: docker compose exec postgres psql -U postgres -c \"CREATE DATABASE ...\""
fi

if [[ " ${SERVICES_DETECTED[*]} " =~ " redis " ]]; then
    echo "3. Implement Redis logical separation using DB numbers (0-15)"
fi

echo "4. Port allocation strategy: increment by 10 per worktree"
echo "   - Main: 3000 (web), 3001 (api)"
echo "   - Worktree 1: 3010, 3011"
echo "   - Worktree 2: 3020, 3021"
echo ""
