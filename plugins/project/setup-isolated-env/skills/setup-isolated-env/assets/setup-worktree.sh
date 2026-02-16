#!/usr/bin/env bash
set -euo pipefail

# Setup Feature Worktree Helper Script
# Automates creation of isolated git worktree with dedicated ports and database

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."

    # Check for docker-compose.yml
    if [[ ! -f "docker-compose.yml" ]]; then
        error "docker-compose.yml not found. This project doesn't meet prerequisites."
    fi

    # Check for environment template
    if [[ ! -f ".env.example" ]] && [[ ! -f ".env.local.example" ]]; then
        error ".env.example or .env.local.example not found"
    fi

    # Check if Docker is running
    if ! docker compose ps &>/dev/null; then
        error "Docker Compose services not accessible. Run 'docker compose up -d' first."
    fi

    success "Prerequisites check passed"
}

# Get current branch
get_branch_name() {
    local current_branch
    current_branch=$(git branch --show-current)

    if [[ "$current_branch" == "main" ]] || [[ "$current_branch" == "master" ]]; then
        read -p "Enter feature branch name: " BRANCH_NAME
        if [[ -z "$BRANCH_NAME" ]]; then
            error "Branch name cannot be empty"
        fi
    else
        BRANCH_NAME="$current_branch"
    fi

    info "Using branch: $BRANCH_NAME"
}

# Calculate next available ports and Redis DB
allocate_ports() {
    info "Scanning for available ports and Redis DB..."

    # Find existing worktree ports
    local max_port=3000
    local max_redis_db=0

    if [[ -d ".worktrees" ]]; then
        while IFS= read -r port; do
            if [[ $port -gt $max_port ]]; then
                max_port=$port
            fi
        done < <(find .worktrees -name ".env.local" -exec grep -h "^PORT=" {} \; | cut -d= -f2 2>/dev/null)

        while IFS= read -r db; do
            if [[ $db -gt $max_redis_db ]]; then
                max_redis_db=$db
            fi
        done < <(find .worktrees -name ".env.local" -exec grep -h "^REDIS_DB=" {} \; | cut -d= -f2 2>/dev/null)
    fi

    # Increment by 10 from max port
    if [[ $max_port -eq 3000 ]]; then
        WEB_PORT=3010
        API_PORT=3011
    else
        WEB_PORT=$((max_port + 10))
        API_PORT=$((max_port + 11))
    fi

    # Increment Redis DB (0 is for main, 1-15 for worktrees)
    REDIS_DB=$((max_redis_db + 1))

    # Check if we've exceeded Redis DB limit (16 databases: 0-15)
    if [[ $REDIS_DB -gt 15 ]]; then
        error "Redis DB limit exceeded (max 15 worktrees). Clean up old worktrees first."
    fi

    info "Allocated ports: Web=$WEB_PORT, API=$API_PORT, Redis DB=$REDIS_DB"
}

# Create worktree
create_worktree() {
    info "Creating worktree at .worktrees/$BRANCH_NAME..."

    mkdir -p .worktrees

    if git worktree add ".worktrees/$BRANCH_NAME" -b "$BRANCH_NAME"; then
        success "Worktree created"
    else
        error "Failed to create worktree. Branch may already exist."
    fi
}

# Setup environment variables
setup_environment() {
    info "Setting up environment variables..."

    cd ".worktrees/$BRANCH_NAME"

    # Copy template
    if [[ -f "../../.env.example" ]]; then
        cp "../../.env.example" .env.local
    else
        cp "../../.env.local.example" .env.local
    fi

    # Sanitize branch name for database
    DB_NAME=$(echo "$BRANCH_NAME" | tr '/-.' '_')_db

    # Update or add PORT variables
    if grep -q "^PORT=" .env.local; then
        sed -i.bak "s/^PORT=.*/PORT=$WEB_PORT/" .env.local
    else
        echo -e "\n# Worktree-specific ports (auto-assigned)\nPORT=$WEB_PORT" >> .env.local
    fi

    if grep -q "^API_PORT=" .env.local; then
        sed -i.bak "s/^API_PORT=.*/API_PORT=$API_PORT/" .env.local
    else
        echo "API_PORT=$API_PORT" >> .env.local
    fi

    # Update DATABASE_URL
    if grep -q "^DATABASE_URL=" .env.local; then
        sed -i.bak "s|^DATABASE_URL=.*|DATABASE_URL=postgresql://postgres:postgres@localhost:5432/$DB_NAME|" .env.local
    else
        echo "DATABASE_URL=postgresql://postgres:postgres@localhost:5432/$DB_NAME" >> .env.local
    fi

    # Update REDIS_DB
    if grep -q "^REDIS_DB=" .env.local; then
        sed -i.bak "s/^REDIS_DB=.*/REDIS_DB=$REDIS_DB/" .env.local
    else
        echo "REDIS_DB=$REDIS_DB" >> .env.local
    fi

    # Update REDIS_URL (if project uses connection URL format)
    if grep -q "^REDIS_URL=" .env.local; then
        sed -i.bak "s|^REDIS_URL=.*|REDIS_URL=redis://localhost:6379/$REDIS_DB|" .env.local
    else
        echo "REDIS_URL=redis://localhost:6379/$REDIS_DB" >> .env.local
    fi

    # Update CORS_ORIGIN
    if grep -q "^CORS_ORIGIN=" .env.local; then
        sed -i.bak "s|^CORS_ORIGIN=.*|CORS_ORIGIN=http://localhost:$WEB_PORT,http://localhost:3000|" .env.local
    else
        echo "CORS_ORIGIN=http://localhost:$WEB_PORT,http://localhost:3000" >> .env.local
    fi

    # Cleanup backup files
    rm -f .env.local.bak

    cd - > /dev/null
    success "Environment configured"
}

# Create database
create_database() {
    info "Creating isolated database..."

    # Sanitize branch name for database
    DB_NAME=$(echo "$BRANCH_NAME" | tr '/-.' '_')_db

    # Extract postgres user from docker-compose.yml
    POSTGRES_USER=$(grep "POSTGRES_USER" docker-compose.yml | head -1 | cut -d: -f2 | tr -d ' "' || echo "postgres")

    if docker compose exec postgres psql -U "$POSTGRES_USER" -c "CREATE DATABASE $DB_NAME;" 2>/dev/null; then
        success "Database created: $DB_NAME"
    else
        error "Failed to create database. May already exist or permission denied."
    fi
}

# Run migrations
run_migrations() {
    info "Running database migrations..."

    cd ".worktrees/$BRANCH_NAME"

    if bun run db:push --force; then
        success "Migrations completed"
    else
        error "Migrations failed"
    fi

    cd - > /dev/null
}

# Print summary
print_summary() {
    DB_NAME=$(echo "$BRANCH_NAME" | tr '/-.' '_')_db

    echo ""
    echo -e "${GREEN}✅ Worktree Setup Complete${NC}"
    echo ""
    echo "📁 Location: .worktrees/$BRANCH_NAME"
    echo "🌐 Web URL: http://localhost:$WEB_PORT"
    echo "🔌 API URL: http://localhost:$API_PORT"
    echo "🗄️ Database: $DB_NAME"
    echo "🔴 Redis DB: $REDIS_DB"
    echo ""
    echo "Next steps:"
    echo "1. cd .worktrees/$BRANCH_NAME"
    echo "2. bun run dev (web server)"
    echo "3. cd apps/agent && bun run dev (agent service)"
    echo ""
    echo "To remove this worktree:"
    echo "git worktree remove .worktrees/$BRANCH_NAME"
    echo "docker compose exec postgres psql -U postgres -c \"DROP DATABASE $DB_NAME;\""
    echo "docker compose exec redis redis-cli -n $REDIS_DB FLUSHDB"
    echo ""
}

# Main execution
main() {
    echo ""
    echo "=== Feature Worktree Setup ==="
    echo ""

    check_prerequisites
    get_branch_name
    allocate_ports
    create_worktree
    setup_environment
    create_database
    run_migrations
    print_summary
}

main "$@"
