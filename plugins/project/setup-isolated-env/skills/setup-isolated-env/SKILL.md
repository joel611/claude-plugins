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

### Step 3.5: Framework-Specific Port Configuration

**CRITICAL**: Before writing setup scripts, ensure application code reads ports from environment variables.

**Run framework detection**:
```bash
"${CLAUDE_PLUGIN_ROOT}/skills/setup-isolated-env/scripts/detect-framework.sh"
```

**Common framework patterns**:

#### Vite Projects
```typescript
// vite.config.ts
import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    port: Number(process.env.PORT) || 5001,
  },
});

// package.json - REMOVE hardcoded port
"dev": "vite dev --host"  // NOT: "vite dev --port 5001"
```

#### Next.js Projects
```bash
# Next.js reads PORT automatically
# package.json - ensure no hardcoded port
"dev": "next dev"  # NOT: "next dev -p 3000"
```

#### Express/Elysia/Bun
```typescript
// src/index.ts
const PORT = Number(process.env.PORT) || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

**Verification**: Check checklist.sh output for "Port configuration issues" and resolve them BEFORE proceeding.

### Step 3.6: Database Creation Strategy

**CRITICAL**: Determine how databases will be created based on project rules.

**Detect SQL execution policy** (check CLAUDE.md for rules like "MUST use MCP", "no CLI SQL"):

**Strategy A: Direct psql/CLI (default)**
- Use `psql` or Docker Compose exec for database creation
- Works for most projects
- Example: `PGPASSWORD=postgres psql -h 127.0.0.1 -p 54322 -U postgres -d postgres -c "CREATE DATABASE ${DB_NAME}"`

**Strategy B: Supabase MCP (for restricted projects)**
- If project prohibits CLI SQL execution
- Database creation must be done via Claude Code:
  ```markdown
  After setup script completes, create database manually:
  1. Open Claude Code session
  2. Execute via MCP: CREATE DATABASE ${DB_NAME}
  ```
- OR add exception to CLAUDE.md: `MUST NOT run sql through cli (exception: CREATE DATABASE for worktree setup)`

**Strategy C: Schema-based isolation (alternative)**
- Use single database with schemas: `CREATE SCHEMA ${ENV_NAME}`
- Update DATABASE_URL: `?schema=${ENV_NAME}`
- Simpler, no admin privileges needed
- Trade-off: Less isolation than separate databases

**Recommendation**: For Supabase projects with SQL restrictions:
1. Add CREATE DATABASE exception to CLAUDE.md (admin operation, one-time setup)
2. Document manual creation step in setup script if exception not acceptable
3. Consider schema-based isolation as fallback

### Step 4: Guide Creation of smoke-test.sh

**CRITICAL**: Smoke test runs FROM WITHIN the worktree, not from project root.

**Purpose**: Verify environment connectivity after setup

**Usage**:
```bash
# Run from within worktree
cd .worktrees/<env-name>
../../<worktree_scripts>/smoke-test.sh
```

**Key changes from traditional approach**:
- No environment name argument needed (detects from current directory)
- Loads .env.local from current directory
- More intuitive workflow (already in worktree when developing)

**Template** (see `assets/smoke-test.sh` for complete version):

**Purpose**: Verify environment connectivity after setup

```bash
#!/usr/bin/env bash
# Smoke Test - Run from within worktree
set -euo pipefail

# Detect if we're in a worktree
if [[ ! -f ".env.local" ]]; then
    echo "✗ Not in worktree (.env.local not found)"
    echo "Usage: cd .worktrees/<env-name> && ../../<worktree_scripts>/smoke-test.sh"
    exit 1
fi

# Auto-detect environment name
ENV_NAME=$(basename "$PWD")
echo "Smoke Test: ${ENV_NAME}"

# Load environment from current directory
source .env.local

# Test 1: Environment variables
echo "[1/4] Checking environment variables..."
[[ -n "${PORT}" ]] && echo "✓ PORT=${PORT}" || echo "✗ PORT not set"
[[ -n "${DATABASE_URL}" ]] && echo "✓ DATABASE_URL configured" || echo "✗ DATABASE_URL not set"

# Test 2: Port availability
echo "[2/4] Checking port availability..."
lsof -i ":${PORT}" &>/dev/null || echo "✓ Port ${PORT} available"

# Test 3: Database connectivity (multiple methods)
echo "[3/4] Checking database connectivity..."
if command -v psql &>/dev/null; then
    psql "$DATABASE_URL" -c "SELECT 1" &>/dev/null && echo "✓ Database OK"
elif command -v supabase &>/dev/null; then
    supabase status &>/dev/null && echo "✓ Supabase running"
fi

# Test 4: Infrastructure services
echo "[4/4] Checking infrastructure..."
supabase status &>/dev/null && echo "✓ Supabase running" || echo "⚠ Check services"

echo ""
echo "✓ Smoke test passed! Ready to start development."
```

**Implementation notes**:
- Script detects environment name from current directory
- No arguments needed (more intuitive)
- Loads .env.local from current working directory
- Provides fallback checks if psql not available
- See `assets/smoke-test.sh` for complete production-ready version

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

**Create separate cleanup-env.sh script** (see `assets/cleanup-env.sh` for complete version)

**CRITICAL BUG TO AVOID**: Do not use `local` keyword outside of functions:

```bash
# ❌ WRONG - causes error
local db_port
db_port=$(supabase status | grep "DB URL" | awk ...)

# ✅ CORRECT - only use local inside functions
drop_database() {
    local db_port  # Inside function scope
    db_port=$(supabase status | grep "DB URL" | awk ...)
}

# ✅ OR - don't use local at script level
db_port=$(supabase status | grep "DB URL" | awk ...)
```

**Database cleanup strategies**:

```bash
# Strategy A: psql (direct)
PGPASSWORD=postgres psql -h 127.0.0.1 -p "$db_port" -U postgres -d postgres \
    -c "DROP DATABASE IF EXISTS ${DB_NAME};"

# Strategy B: Docker Compose
docker compose exec -T postgres psql -U postgres \
    -c "DROP DATABASE IF EXISTS ${DB_NAME};"

# Strategy C: Manual (for MCP-only projects)
echo "Manual cleanup required:"
echo "  Open Claude Code and execute: DROP DATABASE IF EXISTS ${DB_NAME}"
```

**Key features**:
- Checks for uncommitted changes before removing worktree
- Confirms deletion (prevents accidents)
- Handles database cleanup based on infrastructure
- Falls back gracefully if database drop fails

### Step 8: Update Project Documentation

**Add quick reference to CLAUDE.md**:

```markdown
## Isolated Development Environments

This project uses git worktrees for isolated parallel development.

### Creating a New Environment

```bash
# 1. Create isolated environment
<worktree_scripts>/setup-env.sh

# 2. Navigate to worktree
cd .worktrees/<env-name>

# 3. REQUIRED: Run smoke test from within worktree
../../<worktree_scripts>/smoke-test.sh

# 4. Only start development after smoke test passes
bun run dev
```

### Smoke Test Verification

**CRITICAL**: Always run smoke test before starting development:

```bash
cd .worktrees/<env-name>
../../<worktree_scripts>/smoke-test.sh
```

The smoke test verifies:
- Database connectivity
- Port availability
- Environment variables configured correctly

**DO NOT start development** if smoke test fails.

### Cleanup When Done

```bash
<worktree_scripts>/cleanup-env.sh <env-name>
```

## Reference file
| filename | description |
|---|---|
| WORKTREE.md | Detailed worktree setup and usage guide - load before creating isolated environments |
```

**Create WORKTREE.md** (place in `.claude/` or project root):

See `assets/WORKTREE.md-template.md` for complete customizable template. Update with:
- **Framework-specific port configuration** (Vite/Next.js/Express/etc.)
- **Database creation method** (psql, MCP, schema-based)
- **Smoke test workflow** (emphasize running from within worktree)
- Troubleshooting guide
- Best practices
- Limitations

**Critical sections to customize**:
1. Port configuration based on detected framework
2. Database creation strategy (especially for Supabase MCP projects)
3. Smoke test usage (runs from within worktree, no arguments)

**Why this approach:**
- CLAUDE.md: Quick reference, always loaded
- WORKTREE.md: Comprehensive docs, loaded on-demand via reference section
- Future Claude instances auto-load WORKTREE.md before worktree operations
- Makes smoke test verification a required step, not optional

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

See `assets/setup-env.sh` for complete Docker Compose + Postgres + Redis example. **Use as reference ONLY** - don't copy blindly. Adapt to your project's infrastructure.

## Common Mistakes

**Mistake**: Hardcoded ports in application code or package.json
**Fix**: Run `detect-framework.sh` for framework-specific guidance. Move port config to framework config files (vite.config.ts, etc.), not CLI args.

**Mistake**: Using psql in setup script for projects with SQL execution restrictions
**Fix**: Check CLAUDE.md for SQL policies. Add CREATE DATABASE exception, document manual step, or use schema-based isolation.

**Mistake**: Running smoke-test.sh from project root with environment argument
**Fix**: NEW APPROACH: Run from within worktree (`cd .worktrees/<env-name> && ../../<worktree_scripts>/smoke-test.sh`). No arguments needed.

**Mistake**: Using `local` keyword outside functions in bash scripts
**Fix**: Only use `local` inside function scope, or omit it at script level. Causes "can only be used in a function" error.

**Mistake**: Hardcoded service URLs in codebase
**Fix**: Run `checklist.sh` BEFORE creating scripts. Refactor URLs to use environment variables or relative paths.

**Mistake**: Copying example script without adapting to project infrastructure
**Fix**: Use example as reference. Create project-specific script based on checklist.sh detection.

**Mistake**: Not testing smoke test before creating multiple environments
**Fix**: Create one test environment, run smoke-test.sh from within worktree, verify connectivity, THEN scale to multiple environments.

**Mistake**: Forgetting to update CORS origins with new ports
**Fix**: Include all environment ports in CORS configuration. Restart API server after changes.

**Mistake**: Using same cache keys across environments
**Fix**: Use Redis DB numbers (0-15) or cache key prefixes to isolate data.

**Mistake**: Not sanitizing environment names for database identifiers
**Fix**: Replace special characters (`/`, `-`, `.`) with underscores for database names.

**Mistake**: Assuming all frameworks handle ports the same way
**Fix**: Vite needs config file changes, Next.js reads PORT automatically, Express/Elysia need code changes. Check framework-specific guidance.

## Troubleshooting

**Checklist fails - no infrastructure**:
- Add Docker Compose, or
- Install Supabase CLI, or
- Document manual database creation steps

**Hardcoded URLs detected**:
- Don't proceed with setup until URLs refactored
- Each hardcoded URL is a future debugging session

**Framework-specific port configuration issues**:
- **Vite**: Port must be in `vite.config.ts`, not package.json CLI args
- **Next.js**: Remove `-p` flag from dev script, uses PORT automatically
- **Express/Elysia**: Update server code to read from `process.env.PORT`
- Run `detect-framework.sh` for specific guidance

**Database creation fails (Supabase MCP projects)**:
- **Problem**: Setup script uses psql, but project prohibits CLI SQL
- **Solution A**: Add exception to CLAUDE.md for CREATE DATABASE (admin operation)
- **Solution B**: Document manual database creation via Claude Code MCP
- **Solution C**: Use schema-based isolation instead (`CREATE SCHEMA`)
- See Step 3.6 for detailed strategies

**Servers use wrong ports after setup**:
- Check application code reads from env vars (not hardcoded)
- Verify vite.config.ts has `port: Number(process.env.PORT)`
- Restart dev servers after .env.local changes
- Check checklist.sh "Port configuration issues" output

**Smoke test not finding worktree**:
- **Problem**: Running from wrong directory
- **Solution**: `cd .worktrees/<env-name>` first, then run `../../<worktree_scripts>/smoke-test.sh`
- Smoke test NO LONGER takes environment name as argument
- It detects environment from current directory

**Port conflicts after setup**:
- Check `lsof -i :{PORT}` for conflicting processes
- Adjust port allocation offset in setup-env.sh

**Cleanup script errors with "local can only be used in a function"**:
- **Problem**: `local` keyword used outside function scope
- **Solution**: Move variable declaration inside function or remove `local`
- See Step 7 for correct pattern

**Smoke test fails**:
- Check .env.local has correct values
- Verify services are running
- Test connectivity manually before debugging script
- Run from WITHIN worktree, not from project root

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
