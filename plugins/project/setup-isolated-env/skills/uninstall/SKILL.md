---
name: uninstall
description: This skill should be used when the user wants to "uninstall setup-isolated-env", "remove isolated environment setup", "tear down worktree isolation", "undo the environment setup", "remove worktree scripts", or wants to fully revert a project back to before generate-env-scripts was run. Reverses the full setup-isolated-env setup flow by cleaning up active worktrees, dropping their databases, removing generated scripts, and restoring project documentation.
---

# Uninstall: Remove Isolated Environment Setup

## Overview

Reverses everything `setup-isolated-env:generate-env-scripts` created. Cleans up all active worktrees (dropping their databases), removes generated scripts, and restores CLAUDE.md and WORKTREE.md to their pre-setup state.

**Announce at start:** "i'm using setup-isolated-env:uninstall to reverse the isolation setup for this project"

**Run from project root.** All steps assume the current directory is the project root (not inside a worktree).

**Order matters**: Clean up running environments before removing the scripts that clean them.

## Quick Reference

| Step | What it does |
|------|-------------|
| 1. Detect active worktrees | Find all git worktrees, excluding main |
| 2. Clean up each worktree | Drop database, remove worktree |
| 3. Remove generated scripts | Delete setup-env.sh, cleanup-env.sh, smoke-test.sh |
| 4. Remove scripts directory | Only if it was created by this plugin |
| 5. Remove WORKTREE.md | Delete if it exists |
| 6. Update CLAUDE.md | Remove the "Isolated Development Environments" section |

## Implementation

### Step 1: Detect Active Worktrees

List all worktrees except the main one:

```bash
# From project root — skip the first line (main worktree)
git worktree list --porcelain | grep "^worktree" | tail -n +2 | awk '{print $2}'
```

If the list is empty, skip to Step 3.

If worktrees exist, present them to the user and confirm before proceeding:

> Found these active worktrees: .worktrees/feat-auth, .worktrees/feat-payments
> Uninstall will drop their databases and remove them. Continue? [y/N]

### Step 2: Clean Up Each Worktree

For each active worktree detected in Step 1:

#### 2a: Check for uncommitted changes

```bash
cd .worktrees/<env-name>
git status --porcelain
```

If uncommitted changes exist, warn the user and ask whether to proceed:

> ⚠ .worktrees/feat-auth has uncommitted changes. Remove anyway? [y/N]

#### 2b: Run cleanup-env.sh if it exists

Prefer the project's own cleanup script — it knows the exact database and infrastructure:

```bash
# From inside the worktree
cd .worktrees/<env-name>
<worktree_scripts>/cleanup-env.sh
```

Where `<worktree_scripts>` is the detected script location (`.worktrees_scripts/`, `scripts/`, etc.).

#### 2c: Fallback — manual cleanup if cleanup-env.sh is missing

If the cleanup script has already been removed or wasn't found, perform manual cleanup:

**Drop the database** (derive DB name from worktree directory name):

```bash
ENV_NAME=$(basename .worktrees/<env-name>)
DB_NAME=$(echo "$ENV_NAME" | tr '/-.' '_')_db

# Try Supabase
if command -v supabase &>/dev/null && supabase status &>/dev/null 2>&1; then
    DB_PORT=$(supabase status | grep "DB URL" | awk -F: '{print $(NF-1)}' | awk -F/ '{print $1}')
    DB_PORT=${DB_PORT:-54322}
    PGPASSWORD=postgres psql -h 127.0.0.1 -p "$DB_PORT" -U postgres -d postgres \
        -c "DROP DATABASE IF EXISTS ${DB_NAME};" || true

# Try Docker Compose
elif command -v docker &>/dev/null && [[ -f "docker-compose.yml" ]]; then
    docker compose exec -T postgres psql -U postgres \
        -c "DROP DATABASE IF EXISTS ${DB_NAME};" || true
fi
```

**Remove the worktree**:

```bash
# From project root
git worktree remove --force .worktrees/<env-name>
```

Repeat Steps 2a–2c for every active worktree.

### Step 3: Detect Script Location

Identify where the generated scripts live before removing them:

```bash
# Check common locations
ls .worktrees_scripts/setup-env.sh 2>/dev/null && echo ".worktrees_scripts"
ls scripts/setup-env.sh 2>/dev/null && echo "scripts"
```

If not found in either, ask the user to point to the script directory.

### Step 4: Remove Generated Scripts

Remove only the files this plugin created — do not delete the entire directory if it contains other files:

```bash
SCRIPT_DIR=<detected-location>

rm -f "${SCRIPT_DIR}/setup-env.sh"
rm -f "${SCRIPT_DIR}/cleanup-env.sh"
rm -f "${SCRIPT_DIR}/smoke-test.sh"
```

**Remove the scripts directory only if it's now empty** (i.e., it was created exclusively for these scripts):

```bash
# Only remove if empty
rmdir "${SCRIPT_DIR}" 2>/dev/null && echo "Removed empty ${SCRIPT_DIR}" || true
```

If the directory still has other files, leave it and note that it was not removed.

### Step 5: Remove WORKTREE.md

Find and remove WORKTREE.md if it exists:

```bash
# Check common locations
rm -f .claude/WORKTREE.md
rm -f WORKTREE.md
```

If WORKTREE.md was placed in a custom location, ask the user to confirm the path before deletion.

### Step 6: Remove CLAUDE.md Section

Remove the "Isolated Development Environments" section that `generate-env-scripts` added to CLAUDE.md.

Read the project's CLAUDE.md first to locate the section. The section looks like:

```markdown
## Isolated Development Environments

This project uses git worktrees for isolated parallel development.
...

## Reference file
| filename | description |
|---|---|
| WORKTREE.md | Detailed worktree setup and usage guide... |
```

Use the Edit tool to remove this section. Preserve everything else in CLAUDE.md.

If the section is not found, inform the user that CLAUDE.md was not modified.

### Step 7: Verify Cleanup

Confirm everything was removed:

```bash
# Verify no worktrees remain (except main)
git worktree list

# Verify scripts removed
ls .worktrees_scripts/ 2>/dev/null || echo "Directory removed"
ls scripts/setup-env.sh 2>/dev/null && echo "WARNING: setup-env.sh still present" || true

# Verify docs removed
ls .claude/WORKTREE.md 2>/dev/null && echo "WARNING: WORKTREE.md still present" || true
```

## Edge Cases

**Worktree contains active processes**: The dev server may still be running inside the worktree. Notify the user but proceed with removal — git worktree remove will fail if files are locked.

**Database already dropped**: If the database no longer exists, `DROP DATABASE IF EXISTS` is safe — it will not error.

**scripts/ directory has non-plugin files**: Do not remove the directory. Only remove setup-env.sh, cleanup-env.sh, and smoke-test.sh.

**CLAUDE.md section was manually modified**: Read the file and use best judgment to identify and remove the isolation section without disrupting other content.

**Multiple CLAUDE.md files**: Check both root `CLAUDE.md` and `.claude/CLAUDE.md` — generate-env-scripts may have updated either.

**Worktree outside .worktrees/**: The user may have placed worktrees elsewhere. `git worktree list` will show all locations regardless of path.

## Success Criteria

- [ ] All active worktrees listed and removed
- [ ] All worktree databases dropped (or manual cleanup steps provided)
- [ ] setup-env.sh, cleanup-env.sh, smoke-test.sh deleted
- [ ] Scripts directory removed if it was empty
- [ ] WORKTREE.md deleted
- [ ] CLAUDE.md "Isolated Development Environments" section removed
- [ ] `git worktree list` shows only the main worktree
