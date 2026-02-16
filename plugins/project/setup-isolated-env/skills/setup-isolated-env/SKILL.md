---
name: setup-isolated-env
description: Use when project needs isolated development environments for parallel feature work, or when adding new external services (databases, caches, message queues) that require environment isolation. ONE-TIME setup skill - clear context after use.
---

# Setup Isolated Environment

## Overview

**ONE-TIME SETUP SKILL** - Guides projects to create automation scripts for isolated development environments using git worktrees. **Core principle**: Help project establish isolation infrastructure once, then exit context. This is NOT for ongoing implementation work.

**CRITICAL**: After completing setup, **tell user to clear context** (`/clear` or restart session). This skill adds setup details that shouldn't persist into implementation conversations.

**Announce at start:** "i'm using setup-isolated-env skill to set up an isolation readiness"

## When to Use

**Use ONCE when**:
- New project needs parallel feature development capability
- Adding external services (database, cache, queue, storage) that need isolation
- Developers report environment conflicts (port collisions, data pollution)

**Re-run when**:
- Adding new external service (e.g., adding Redis to project that only had Postgres)
- Changing infrastructure (migrating from Docker to Kubernetes, adding Supabase)
- Isolation scripts break due to environment changes

**Don't use for**:
- Actually creating worktrees (use project's generated script)
- Ongoing feature development (that's what generated scripts are for)
- Debugging existing isolation setup (read project's scripts instead)

## Quick Reference

| Component | Purpose | Location |
|-----------|---------|----------|
| checklist.sh | Detect infrastructure and validate prerequisites | Skill `./scripts/` directory |
| setup-env.sh | Project-generated script for creating isolated environments | `<worktree_scripts>` (user-chosen location) |
| cleanup-env.sh | Remove isolated environment and cleanup resources | `<worktree_scripts>` (user-chosen location) |
| smoke-test.sh | Verify connectivity after setup | `<worktree_scripts>` (user-chosen location) |

## Implementation

### Step 1: Run Infrastructure Detection

**Always start with checklist** to understand project infrastructure:

```bash
# Run from PROJECT ROOT using absolute path
"${CLAUDE_PLUGIN_ROOT}/skills/setup-isolated-env/scripts/checklist.sh"
```

**CRITICAL**: Run checklist.sh **from your project root directory**, not from the skill directory. The script needs to scan project files (docker-compose.yml, .env.example, src/ directories).

**Note**: Script location will be chosen in Step 2. Examples below use `<worktree_scripts>` to represent the chosen location.

**Checklist detects**:
- Container orchestration (Docker Compose, Kubernetes, Supabase, etc.)
- Environment templates (`.env.example`, `.env.local.example`, etc.)
- External services (databases, caches, queues, storage)
- Hardcoded service URLs that break isolation

**If checklist fails**: Stop. Ask user to resolve prerequisites (missing env template, no containerization, etc.)

**If hardcoded URLs found**: Document them. Guide user to refactor BEFORE creating isolation scripts.

### Step 2: Determine Script Location

**Goal**: Choose where to store worktree automation scripts

**Ask user to confirm location:**
- Default: `.worktrees_scripts/` (recommended - keeps worktree infrastructure together)
- Alternative: `scripts/` (if project prefers root-level scripts)
- Custom: User-specified path

```bash
# Default location (recommended) - use this value for <worktree_scripts>
mkdir -p .worktrees_scripts

# Alternative: root scripts folder - use this value for <worktree_scripts>
mkdir -p scripts
```

**Replace `<worktree_scripts>` with chosen location throughout remaining steps.**

**Why .worktrees_scripts/ is recommended:**
- Groups worktree infrastructure in one location
- Separates worktree automation from general project scripts
- Clearer organization when .worktrees/ becomes the worktree hub

**When to use scripts/ instead:**
- Project already uses scripts/ for all automation
- Team prefers flat structure
- Worktrees are secondary feature, not primary workflow

### Step 3: Guide Creation of setup-env.sh

**DO NOT copy-paste** the example from `assets/`. Instead, **guide user to create** project-specific script based on detected infrastructure.

**Framework-agnostic template structure**:

```bash
#!/usr/bin/env bash
set -euo pipefail

# 1. Check prerequisites (adapt from checklist.sh)
check_prerequisites() {
    # Verify infrastructure is running
    # Check environment template exists
}

# 2. Get environment name (branch name or custom)
get_environment_name() {
    # Prompt user or detect from git branch
}

# 3. Allocate unique resources
allocate_resources() {
    # Scan existing environments for port ranges
    # Increment by fixed offset (10, 100, etc.)
    # Assign unique database/cache identifiers
}

# 4. Create isolated environment
create_environment() {
    # Create git worktree at .worktrees/{env-name}
    # Copy environment template to .env.local
}

# 5. Update environment configuration
update_configuration() {
    # Set unique ports (PORT, API_PORT, etc.)
    # Set unique database connection (DATABASE_URL)
    # Set unique cache namespace (REDIS_DB, CACHE_PREFIX, etc.)
    # Update CORS origins, webhook URLs
}

# 6. Provision isolated resources
provision_resources() {
    # Create database (project-specific command)
    # Initialize cache namespace
    # Create storage buckets
}

# 7. Run migrations
run_migrations() {
    # Execute database migrations (project-specific)
    # Seed initial data if needed
}

# 8. Display summary
display_summary() {
    # Show environment details
    # Provide cleanup commands
}
```

**Adapt based on detected infrastructure**:

| Infrastructure | Database Creation | Cache Isolation |
|---------------|------------------|-----------------|
| Docker Compose | `docker compose exec db createdb {name}` | Redis DB 0-15 |
| Supabase | `supabase db execute --sql "CREATE DATABASE {name}"` | Redis DB 0-15 |
| Kubernetes | `kubectl exec deployment/db -- createdb {name}` | Redis DB 0-15 |
| Managed DB (RDS, Cloud SQL) | Manual or API call | Cache key prefixes |

**Port allocation strategy** (framework agnostic):
- Main environment: Base ports (e.g., 3000, 3001)
- Environment 1: Base + offset (e.g., 3010, 3011)
- Environment 2: Base + offset * 2 (e.g., 3020, 3021)
- Choose offset: 10, 100, or 1000 depending on service count

### Step 4: Guide Creation of smoke-test.sh

**Purpose**: Verify environment connectivity after setup

```bash
#!/usr/bin/env bash
# Verify isolated environment is working

ENV_DIR="$1"

if [[ -z "$ENV_DIR" ]]; then
    echo "Usage: <worktree_scripts>/smoke-test.sh .worktrees/{env-name}"
    exit 1
fi

cd "$ENV_DIR"

# Load environment
source .env.local

echo "Testing environment: $ENV_DIR"
echo ""

# Test database connection
echo "Testing database..."
# Project-specific database ping command
# e.g., psql $DATABASE_URL -c "SELECT 1" >/dev/null && echo "✓ DB OK"

# Test cache connection
echo "Testing cache..."
# Project-specific cache ping command
# e.g., redis-cli -n $REDIS_DB PING >/dev/null && echo "✓ Cache OK"

# Test web server port available
echo "Testing web server port..."
# Check if port is available
# e.g., nc -z localhost $PORT || echo "✓ Port $PORT available"

# Test API server port available
echo "Testing API server port..."
# Check if port is available
# e.g., nc -z localhost $API_PORT || echo "✓ Port $API_PORT available"

echo ""
echo "Smoke test complete. Ready to start servers."
```

### Step 5: Environment Variable Updates

**Guide user to identify** which variables MUST be unique per environment:

**Always unique**:
- Server ports (`PORT`, `API_PORT`, `WEB_PORT`, etc.)
- Database connection strings (`DATABASE_URL`, `DB_NAME`, etc.)
- Cache identifiers (`REDIS_DB`, `CACHE_PREFIX`, etc.)

**Often unique**:
- CORS origins (include all environment ports)
- Webhook callback URLs (must point to correct port)
- Frontend API URLs (`NEXT_PUBLIC_API_URL`, `VITE_API_URL`, etc.)
- Service-to-service URLs

**Never change**:
- Third-party API keys (same across environments)
- Secret keys (shared infrastructure)

**Missing variables**: If PORT/API_PORT don't exist in template, guide user to add them.

### Step 6: Hardcoded URL Remediation

**If checklist found hardcoded URLs**, guide user to refactor BEFORE isolation setup:

**Fix strategies**:
1. **Environment variables** (preferred):
   ```javascript
   // Before: hardcoded
   const API_URL = "http://localhost:3000/api"

   // After: environment variable
   const API_URL = process.env.NEXT_PUBLIC_API_URL || "/api"
   ```

2. **Relative URLs** (browser contexts):
   ```javascript
   // Before: absolute URL
   fetch("http://localhost:3000/api/users")

   // After: relative URL
   fetch("/api/users")
   ```

3. **Dynamic detection** (runtime):
   ```javascript
   // Before: hardcoded port
   const WS_URL = "ws://localhost:3001"

   // After: dynamic port
   const WS_URL = `ws://${window.location.hostname}:${process.env.API_PORT}`
   ```

### Step 7: Cleanup Commands

**Guide user to add cleanup section** to setup script:

```bash
# Cleanup function (include in setup-env.sh)
cleanup_environment() {
    local ENV_NAME="$1"

    # Remove git worktree
    git worktree remove ".worktrees/${ENV_NAME}"

    # Drop database (project-specific)
    # e.g., docker compose exec db dropdb ${ENV_NAME}_db

    # Flush cache namespace (if using Redis)
    # e.g., redis-cli -n ${REDIS_DB} FLUSHDB

    # Remove storage buckets (if applicable)

    echo "Environment ${ENV_NAME} cleaned up"
}
```

### Step 8: Update Project Documentation

**Add WORKTREE.md reference to CLAUDE.md:**

```markdown
## Reference file
| filename | description |
|---|---|
| WORKTREE.md | Detailed worktree setup and usage guide - load before creating isolated environments |
```

**Create WORKTREE.md** (place in `.claude/` or project root):

See `assets/WORKTREE.md-template.md` for complete customizable template. This file contains:
- Detailed setup instructions
- Troubleshooting guide
- Workflow examples
- Best practices
- Limitations and edge cases
- Port allocation strategy
- Smoke test verification steps
- Cleanup procedures

**Why this approach:**
- WORKTREE.md: Comprehensive docs, loaded on-demand when needed
- Future Claude instances see WORKTREE.md in reference table → load it before worktree operations
- Keeps CLAUDE.md lean and focused
- All worktree details in one dedicated file

## When to Re-run This Skill

**Re-run when project infrastructure changes**:

| Change | Action |
|--------|--------|
| Adding new external service | Re-run `"${CLAUDE_PLUGIN_ROOT}/skills/setup-isolated-env/scripts/checklist.sh"`, update setup-env.sh to provision new service |
| Migrating infrastructure | Re-run full setup (e.g., Docker → Kubernetes) |
| Hardcoded URLs introduced | Re-run `"${CLAUDE_PLUGIN_ROOT}/skills/setup-isolated-env/scripts/checklist.sh"`, refactor URLs, verify isolation |
| Port conflicts from growth | Adjust port allocation strategy in setup-env.sh |

**How to update**:
1. Run `"${CLAUDE_PLUGIN_ROOT}/skills/setup-isolated-env/scripts/checklist.sh"` (from project root) to detect new services
2. Update `setup-env.sh` to provision new resources
3. Update `smoke-test.sh` to verify new connections
4. Test with new environment creation

## Reference: Example Implementation

See `assets/setup-worktree.sh` for complete Docker Compose + Postgres + Redis example. **Use as reference ONLY** - don't copy blindly. Adapt to your project's infrastructure.

## Common Mistakes

**Mistake**: Hardcoded service URLs in codebase
**Fix**: Run `"${CLAUDE_PLUGIN_ROOT}/skills/setup-isolated-env/scripts/checklist.sh"` BEFORE creating scripts. Refactor URLs to use environment variables or relative paths.

**Mistake**: Copying example script without adapting to project infrastructure
**Fix**: Use example as reference. Create project-specific script based on checklist.sh detection.

**Mistake**: Not testing smoke test before creating multiple environments
**Fix**: Create one test environment, run smoke-test.sh, verify connectivity, THEN scale to multiple environments.

**Mistake**: Forgetting to update CORS origins with new ports
**Fix**: Include all environment ports in CORS configuration. Restart API server after changes.

**Mistake**: Using same cache keys across environments
**Fix**: Use Redis DB numbers (0-15) or cache key prefixes to isolate data.

**Mistake**: Not sanitizing environment names for database identifiers
**Fix**: Replace special characters (`/`, `-`, `.`) with underscores for database names.

## Troubleshooting

**Checklist fails - no infrastructure**:
- Add Docker Compose, or
- Install Supabase CLI, or
- Document manual database creation steps

**Hardcoded URLs detected**:
- Don't proceed with setup until URLs refactored
- Each hardcoded URL is a future debugging session

**Port conflicts after setup**:
- Check `lsof -i :{PORT}` for conflicting processes
- Adjust port allocation offset in setup-env.sh

**Database creation fails**:
- Verify container/service is running
- Check user permissions
- Ensure database name doesn't already exist

**Smoke test fails**:
- Check .env.local has correct values
- Verify services are running
- Test connectivity manually before debugging script

## Edge Cases

- **Branch names with special chars**: Sanitize using `tr '/-.' '_'` for database names
- **Port exhaustion** (>15 environments): Increase offset or implement cleanup policy
- **Cache namespace limits**: Redis supports 16 DB numbers (0-15); use prefixes for >15 environments
- **No environment template**: Cannot proceed - guide user to create template first
- **Mixed infrastructure**: Detect primary (Docker vs Supabase) and generate appropriate commands

## After Completion

**CRITICAL - Clear Context**:

Once setup scripts are created and tested:

1. Commit scripts to repository
2. Document in project README how to use setup-env.sh
3. **Tell user: `/clear` or restart session**
4. **Reason**: This setup context shouldn't persist into feature development conversations

**Success criteria**:
- [ ] `"${CLAUDE_PLUGIN_ROOT}/skills/setup-isolated-env/scripts/checklist.sh"` runs from project root and detects all services
- [ ] Project scripts (setup-env.sh, cleanup-env.sh, smoke-test.sh) created in `scripts/` directory
- [ ] setup-env.sh creates isolated environment successfully
- [ ] smoke-test.sh verifies all connections
- [ ] Hardcoded URLs refactored to environment variables
- [ ] WORKTREE.md created with comprehensive workflow documentation
- [ ] CLAUDE.md reference section updated to include WORKTREE.md
- [ ] Project scripts committed to repository
- [ ] **Context cleared** (use `/clear`)

**Next session**: Use project's `setup-env.sh` for creating environments. This skill is not needed again unless infrastructure changes.
