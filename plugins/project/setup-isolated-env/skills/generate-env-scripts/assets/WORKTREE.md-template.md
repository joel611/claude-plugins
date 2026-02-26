# Isolated Development Environments - WORKTREE.md Template

This template should be placed at `.claude/WORKTREE.md` (recommended) or `WORKTREE.md` in project root.

**Purpose:** Detailed documentation for isolated development environments using git worktrees. Claude loads this via CLAUDE.md reference section before worktree operations.

---

# Isolated Development Environments

This project uses automation scripts for creating isolated development environments using git worktrees.

## Overview

Each isolated environment gets:
- **Separate git worktree** in `.worktrees/<env-name>/`
- **Unique ports** (web, agent service)
- **Isolated database** (separate Postgres database)
- **Independent `.env.local`** configuration

## Quick Start

```bash
# Create a new isolated environment
<worktree_scripts>/setup-env.sh

# Test environment connectivity
<worktree_scripts>/smoke-test.sh <env-name>

# Clean up when done
<worktree_scripts>/cleanup-env.sh <env-name>
```

## Port Allocation

Environments use incremental port offsets:

| Environment | Web Port | Agent Port |
|-------------|----------|------------|
| Main        | 3000     | 4111       |
| Feature 1   | 3010     | 4121       |
| Feature 2   | 3020     | 4131       |
| Feature 3   | 3030     | 4141       |

Port offset: **10** per environment

## Usage

### 1. Create Isolated Environment

```bash
<worktree_scripts>/setup-env.sh
```

**Interactive prompts:**
- Environment name (defaults to current git branch)
- Confirmation for existing environments

**What it does:**
1. Checks Supabase is running
2. Creates git worktree at `.worktrees/<env-name>/`
3. Allocates unique ports (auto-increments from existing envs)
4. Copies and configures `.env.local`
5. Creates isolated database
6. Runs migrations
7. Displays summary with next steps

**Output:**
```
=== Environment Ready ===

Environment: feature-auth
Location: .worktrees/feature-auth
Database: feature_auth
Web Port: 3010
Agent Port: 4121

Next steps:
  1. cd .worktrees/feature-auth
  2. bun run dev  # Start web app on port 3010
  3. cd apps/agent && bun run dev  # Start agent service on port 4121
```

### 2. Verify Environment

Run smoke test to verify connectivity:

```bash
<worktree_scripts>/smoke-test.sh feature-auth
```

**Checks:**
- Database connection
- Supabase connection
- Port availability (web and agent)

### 3. Work in Environment

```bash
cd .worktrees/feature-auth

# Install dependencies (if needed)
bun install

# Start web server
bun run dev  # Runs on port 3010

# Start agent service (separate terminal)
cd apps/agent && bun run dev  # Runs on port 4121
```

### 4. Clean Up Environment

When feature is complete or abandoned:

```bash
<worktree_scripts>/cleanup-env.sh feature-auth
```

**What it does:**
1. Removes git worktree
2. Drops database
3. Confirms before deletion

## Environment Variables

Each environment has its own `.env.local` with unique values:

```bash
# Server Ports (unique per environment)
PORT=3010
AGENT_PORT=4121

# Database (isolated database)
DATABASE_URL="postgresql://postgres:postgres@127.0.0.1:54322/feature_auth"

# Better Auth (uses unique port)
BETTER_AUTH_URL=http://localhost:3010

# API Base URL (uses unique port)
API_BASE_URL=http://host.docker.internal:3010

# Agent Webhook URL (uses unique agent port)
AGENT_WEBHOOK_URL=http://localhost:4121/webhook/agent-events

# Shared services (same across environments)
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_SERVICE_ROLE_KEY=<same>
OPENROUTER_API_KEY=<same>
```

## Workflow Examples

### Parallel Feature Development

```bash
# Developer A: Authentication feature
<worktree_scripts>/setup-env.sh
# Enter name: feature-auth
cd .worktrees/feature-auth
bun run dev  # Web on 3010, Agent on 4121

# Developer B: Dashboard redesign
<worktree_scripts>/setup-env.sh
# Enter name: feature-dashboard
cd .worktrees/feature-dashboard
bun run dev  # Web on 3020, Agent on 4131

# Both features run simultaneously without conflicts
```

### Hotfix While Working on Feature

```bash
# Working on feature branch
cd .worktrees/feature-new-ui
bun run dev  # Running on 3010/4121

# Urgent hotfix needed
<worktree_scripts>/setup-env.sh
# Enter name: hotfix-crash
cd .worktrees/hotfix-crash
bun run dev  # Running on 3020/4131

# Fix bug, test, merge hotfix
# Return to feature work without losing state
<worktree_scripts>/cleanup-env.sh hotfix-crash
```

### Testing Database Migrations

```bash
# Create test environment
<worktree_scripts>/setup-env.sh
# Enter name: test-migration

cd .worktrees/test-migration

# Test migration
bun db:push --force

# Verify migration worked
<worktree_scripts>/smoke-test.sh test-migration

# Clean up test environment
cd ../..
<worktree_scripts>/cleanup-env.sh test-migration
```

## Troubleshooting

### Port Already in Use

**Problem:** Smoke test shows port in use

**Solution:**
1. Check running processes: `lsof -i :3010`
2. Stop conflicting process
3. Or allocate different port by creating new environment

### Database Creation Fails

**Problem:** `CREATE DATABASE` fails

**Solution:**
1. Check Supabase is running: `supabase status`
2. Verify database doesn't exist: `psql postgres://... -c "\\l"`
3. Drop existing database: `<worktree_scripts>/cleanup-env.sh <env-name>`

### Worktree Creation Fails

**Problem:** Branch already exists

**Solution:**
1. Delete existing branch: `git branch -D <branch-name>`
2. Or use different environment name
3. Or checkout existing branch to worktree

### Migration Fails

**Problem:** `bun db:push --force` fails

**Solution:**
1. Check DATABASE_URL in `.env.local`
2. Verify database exists: `psql $DATABASE_URL -c "SELECT 1"`
3. Check migration files for errors

## Best Practices

1. **Name environments after branches**
   - Easier to track which worktree is for which branch
   - Auto-detected from `git branch --show-current`

2. **Clean up when done**
   - Prevents port exhaustion (max ~15 environments with offset 10)
   - Keeps disk space manageable
   - Removes stale databases

3. **Use smoke test before starting work**
   - Verifies environment is ready
   - Catches port conflicts early
   - Confirms database connectivity

4. **Commit before creating worktree**
   - Ensures clean state for new branch
   - Prevents uncommitted changes in main worktree

5. **Don't edit main worktree**
   - Keep main worktree pristine
   - Use isolated environments for all work

## Limitations

- **Max environments:** ~15 with default offset (port 3000 + 150 = 3150)
- **Shared Supabase:** All environments use same Supabase instance (54321/54322)
- **No cache isolation:** No Redis/Memcached namespace separation (add if needed)
- **Manual dependency updates:** Run `bun install` in each worktree after dependency changes

## Scripts Reference

| Script | Purpose | Location |
|--------|---------|----------|
| `checklist.sh` | Detect infrastructure and validate prerequisites | `.claude/skills/setup-isolated-env/scripts/` (skill-provided) |
| `setup-env.sh` | Create new isolated environment | `<worktree_scripts>` (project-owned) |
| `smoke-test.sh` | Verify environment connectivity | `<worktree_scripts>` (project-owned) |
| `cleanup-env.sh` | Remove environment and cleanup resources | `<worktree_scripts>` (project-owned) |

## See Also

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Supabase Local Development](https://supabase.com/docs/guides/cli/local-development)
- [Turborepo Monorepo Guide](https://turbo.build/repo/docs)
