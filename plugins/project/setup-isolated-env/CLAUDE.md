# setup-isolated-env Plugin

## Skills

### Flow Overview

```
Project needs isolation?
        │
        ▼
setup-isolated-env:generate-env-scripts   ← ONE-TIME per project
  Scan infrastructure → create scripts
  (setup-env.sh, cleanup-env.sh, smoke-test.sh)
        │
        │  (clear context after)
        │
        ▼
  Feature work begins
        │
        ▼
setup-isolated-env:activate-worktree-env  ← PER WORKTREE
  Run setup-env.sh → cd into worktree
  → run smoke-test.sh → start dev
```

### Trigger Points

| Skill | Trigger When |
|-------|-------------|
| `generate-env-scripts` | User asks to set up isolated environments, adds new external service (DB, cache, queue), or reports port/data conflicts between features |
| `activate-worktree-env` | A git worktree has just been created and needs its environment provisioned and verified |

### generate-env-scripts

**One-time setup** — scans project infrastructure and creates isolation scripts.

Trigger phrases:
- "set up isolated environments"
- "set up worktrees for parallel development"
- "we're adding Redis / Postgres / a new service"
- "I'm getting port conflicts between features"

Does NOT trigger for:
- Creating individual worktrees (that's `activate-worktree-env`)
- Ongoing feature development

### activate-worktree-env

**Per-worktree activation** — runs the project's setup-env.sh and verifies the environment.

Trigger phrases / situations:
- "I just created a worktree for [feature]"
- "set up the environment for this worktree"
- After `git worktree add` completes
- When starting work in a new worktree that has no `.env.local`

Prerequisite: `generate-env-scripts` must have been run first (setup-env.sh must exist).
