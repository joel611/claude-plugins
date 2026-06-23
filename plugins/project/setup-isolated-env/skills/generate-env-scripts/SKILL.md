---
name: generate-env-scripts
description: Setup skill for creating isolated development environments using git worktrees. Run once per project to generate setup-env.sh, smoke-test.sh, and cleanup-env.sh scripts. Re-run when adding new external services or changing infrastructure. Use when parallel feature work is needed, port conflicts occur between branches, or when adding databases, caches, or queues that need per-branch isolation. Invoke this skill when the user mentions setting up worktrees, parallel feature development, environment conflicts, or adding new external services to a project.
---

# Generate Environment Scripts

## Overview

Scans project infrastructure and guides creation of automation scripts (setup-env.sh, cleanup-env.sh, smoke-test.sh) for isolated development environments using git worktrees. **Core principle**: Establish isolation infrastructure once, then re-run only when infrastructure changes. This is NOT for ongoing implementation work.

After completing setup, **tell user to clear context** (`/clear` or restart session). This skill adds setup details that shouldn't persist into implementation conversations.

**Announce at start:** "i'm using generate-env-scripts skill to scan infrastructure and create isolation scripts"

**Don't use for**:
- Creating individual worktrees (use `setup-isolated-env:activate-worktree-env`)
- Ongoing feature development (that's what the generated scripts are for)
- Debugging existing isolation setup (read the project's scripts instead)

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
"${CLAUDE_SKILL_DIR}/scripts/checklist.sh"
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

**Goal**: Detect existing worktree conventions, then confirm or choose script location.

#### 2a: Scan Existing Worktrees

**Always scan first** before suggesting anything:

```bash
# List all existing worktrees (skip main worktree - first line)
git worktree list --porcelain | grep "^worktree" | tail -n +2 | awk '{print $2}'
```

**From results, detect**:
1. **Worktree directory** — where are they stored? (`.worktrees/`, `worktrees/`, `../feature-branches/`, etc.)
2. **Script location** — look for existing automation scripts:

```bash
# Check common script locations relative to project root
ls .worktrees_scripts/ 2>/dev/null
ls scripts/ 2>/dev/null
ls worktree_scripts/ 2>/dev/null
```

**If existing worktrees and scripts found** → present detected convention and ask to confirm:

> Detected: worktrees in `.worktrees/`, scripts in `.worktrees_scripts/`
> Use this convention? [Y/n]

**If existing worktrees but no scripts found** → note the worktree directory, then proceed to 2b for script location only.

**If no existing worktrees** → proceed to 2b.

#### 2b: Choose Location (when not detected)

**Suggest options and ask user to decide:**

| Option | Path | Recommended when |
|--------|------|-----------------|
| A (default) | `.worktrees_scripts/` | Project uses `.worktrees/` for worktrees |
| B | `scripts/` | Project already has a `scripts/` directory |
| C | Custom path | User has specific preference |

```bash
# Option A (default)
mkdir -p .worktrees_scripts

# Option B
mkdir -p scripts
```

**Replace `<worktree_scripts>` with chosen location throughout remaining steps.**

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
"${CLAUDE_SKILL_DIR}/scripts/detect-framework.sh"
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

Smoke test runs FROM WITHIN the worktree — no arguments needed, env name auto-detected from `$PWD`.

**Purpose**: Verify environment connectivity after setup

**Usage**:
```bash
# Run from inside the worktree
cd .worktrees/<env-name>
.worktrees_scripts/smoke-test.sh
```

**Key design decisions**:
- No environment name argument needed (detects from `basename $PWD`)
- Loads .env.local from current directory
- More intuitive workflow (already in worktree when developing)

**Template** (see `assets/smoke-test.sh` for complete version):

```bash
#!/usr/bin/env bash
# Smoke Test - Run from within worktree
set -euo pipefail

# Detect if we're in a worktree
if [[ ! -f ".env.local" ]]; then
    echo "✗ Not in worktree (.env.local not found)"
    echo "Usage: cd .worktrees/<env-name> && .worktrees_scripts/smoke-test.sh"
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
- Script detects environment name from `basename $PWD`
- No arguments needed
- Loads .env.local from current working directory (inside worktree)
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

**Usage**:
```bash
# Run from inside the worktree (env name auto-detected from $PWD)
cd .worktrees/<env-name>
.worktrees_scripts/cleanup-env.sh
```

**Key features**:
- Env name auto-detected from `basename $PWD`
- Checks for uncommitted changes before removing worktree
- Confirms deletion (prevents accidents)
- Handles database cleanup based on infrastructure
- Falls back gracefully if database drop fails

### Step 8: Update Project Documentation

**Add quick reference to CLAUDE.md**:

````markdown
## Isolated Development Environments

This project uses git worktrees for isolated parallel development.
Scripts live in `<worktree_scripts>/` (tracked in git, present in every worktree checkout).

### Creating a New Environment

```bash
# 1. Create worktree (from project root)
git worktree add .worktrees/<env-name> -b <branch-name>

# 2. Navigate into it
cd .worktrees/<env-name>

# 3. Run setup (from inside worktree)
<worktree_scripts>/setup-env.sh

# 4. Run smoke test (from inside worktree, no args needed)
<worktree_scripts>/smoke-test.sh

# 5. Only start development after smoke test passes
bun run dev  # or your project's dev command
```

### Smoke Test Verification

Always run smoke test before starting development. Run from **inside** the worktree:

```bash
cd .worktrees/<env-name>
<worktree_scripts>/smoke-test.sh
```

The smoke test verifies:
- Database connectivity
- Port availability
- Environment variables configured correctly

Do not start development if smoke test fails.

### Cleanup When Done

Run from **inside** the worktree (env name auto-detected):

```bash
cd .worktrees/<env-name>
<worktree_scripts>/cleanup-env.sh
```

## Reference file
| filename | description |
|---|---|
| WORKTREE.md | Detailed worktree setup and usage guide - load before creating isolated environments |
````

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

## When to Re-run

| Change | Action |
|--------|--------|
| Adding new external service | Re-run `"${CLAUDE_SKILL_DIR}/scripts/checklist.sh"`, update setup-env.sh to provision new service |
| Migrating infrastructure | Re-run full setup (e.g., Docker → Kubernetes) |
| Hardcoded URLs introduced | Re-run checklist.sh, refactor URLs, verify isolation |
| Port conflicts from growth | Adjust port allocation strategy in setup-env.sh |

1. Run `"${CLAUDE_SKILL_DIR}/scripts/checklist.sh"` (from project root) to detect changes
2. Update `setup-env.sh` to provision new resources
3. Update `smoke-test.sh` to verify new connections
4. Test with a new environment creation

## Reference: Example Implementation

See `assets/setup-env.sh` for complete Docker Compose + Postgres + Redis example. **Use as reference ONLY** - don't copy blindly. Adapt to your project's infrastructure.

## Troubleshooting

**Skipping worktree scan**: Always run `git worktree list --porcelain` first. Infer the convention from existing worktrees and confirm rather than asking from scratch.

**Hardcoded ports in app code or package.json**: Run `detect-framework.sh` for framework-specific guidance. Move port config to framework config files (vite.config.ts, etc.), not CLI args.
- Vite: port must be in `vite.config.ts`, not package.json CLI args
- Next.js: remove `-p` flag from dev script; reads PORT automatically
- Express/Elysia: update server code to read from `process.env.PORT`

**Hardcoded service URLs detected by checklist**: Refactor BEFORE creating isolation scripts. Each hardcoded URL is a future debugging session. Use environment variables or relative paths.

**Database creation fails (Supabase MCP projects)**: Setup script uses psql but project prohibits CLI SQL.
- Strategy A: Add CREATE DATABASE exception to CLAUDE.md (admin operation, one-time)
- Strategy B: Document manual database creation via Claude Code MCP
- Strategy C: Use schema-based isolation (`CREATE SCHEMA`) instead
- See Step 3.6 for detailed strategies

**Checklist fails - no infrastructure**: Add Docker Compose or Supabase CLI, or document manual database creation steps.

**Port conflicts after setup**: Check `lsof -i :{PORT}` for conflicting processes. Adjust port allocation offset in setup-env.sh.

**`local` keyword error in bash scripts** ("can only be used in a function"): Only use `local` inside function scope, or omit it at script level. See Step 7 for correct pattern.

**CORS errors after setup**: Include all environment ports in CORS configuration. Restart API server after changes.

**Cache conflicts**: Use Redis DB numbers (0-15) or cache key prefixes to isolate data across environments.

**Database name errors**: Replace special characters (`/`, `-`, `.`) with underscores for database names — branch names often contain these.

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
- [ ] `"${CLAUDE_SKILL_DIR}/scripts/checklist.sh"` runs from project root and detects all services
- [ ] Project scripts (setup-env.sh, cleanup-env.sh, smoke-test.sh) created in chosen location
- [ ] setup-env.sh runs from inside a worktree and creates isolated environment successfully
- [ ] smoke-test.sh runs from inside a worktree with no arguments and verifies all connections
- [ ] cleanup-env.sh runs from inside a worktree with no arguments and auto-detects env name
- [ ] Hardcoded URLs refactored to environment variables
- [ ] WORKTREE.md created with comprehensive workflow documentation
- [ ] CLAUDE.md reference section updated to include WORKTREE.md
- [ ] Project scripts committed to repository
- [ ] **Context cleared** (use `/clear`)

**Next step**: When creating a new worktree, use `setup-isolated-env:activate-worktree-env` to run setup-env.sh and verify the environment.
