# setup-isolated-env: WorktreeCreate/WorktreeRemove Hooks Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add WorktreeCreate and WorktreeRemove hook handlers to the setup-isolated-env plugin that inject system reminders into Claude's context when worktrees are created or removed.

**Architecture:** Two shell scripts output `additionalContext` JSON (matching the superpowers session-start hook format). Each script silently exits if setup scripts aren't found in the project, so the hooks are no-ops on projects that don't use this plugin's workflow.

**Tech Stack:** Bash, Claude Code hook system (WorktreeCreate/WorktreeRemove events), jq

---

### Task 1: Create hooks.json

**Files:**
- Create: `plugins/project/setup-isolated-env/hooks/hooks.json`

**Step 1: Create the file**

```json
{
  "hooks": {
    "WorktreeCreate": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/worktree-create.sh"
          }
        ]
      }
    ],
    "WorktreeRemove": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/worktree-remove.sh"
          }
        ]
      }
    ]
  }
}
```

**Step 2: Verify JSON is valid**

```bash
jq . plugins/project/setup-isolated-env/hooks/hooks.json
```

Expected: prints formatted JSON, no error.

---

### Task 2: Create worktree-create.sh

**Files:**
- Create: `plugins/project/setup-isolated-env/hooks/scripts/worktree-create.sh`

**Step 1: Write the script**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Read stdin (worktree event data - not used but consumed to avoid broken pipe)
INPUT=$(cat)

# Check if this project has setup scripts in known locations
SETUP_SCRIPT=""
for loc in ".worktrees_scripts/setup-env.sh" "scripts/setup-env.sh"; do
  if [ -f "$loc" ]; then
    SETUP_SCRIPT="$loc"
    break
  fi
done

# Exit silently if no setup scripts found (project doesn't use this plugin's workflow)
if [ -z "$SETUP_SCRIPT" ]; then
  echo "{}"
  exit 0
fi

# Escape a string for embedding in a JSON string value
escape_for_json() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

CONTEXT="<system-reminder>A git worktree was just created. This project has isolated environment scripts. Invoke the \`setup-isolated-env:activate-worktree-env\` skill now to provision the environment (ports, database, .env.local) for this worktree. Do not skip this step.</system-reminder>"
CONTEXT_ESCAPED=$(escape_for_json "$CONTEXT")

cat <<EOF
{
  "additional_context": "${CONTEXT_ESCAPED}",
  "hookSpecificOutput": {
    "hookEventName": "WorktreeCreate",
    "additionalContext": "${CONTEXT_ESCAPED}"
  }
}
EOF
```

**Step 2: Make executable**

```bash
chmod +x plugins/project/setup-isolated-env/hooks/scripts/worktree-create.sh
```

**Step 3: Smoke test — no setup scripts present**

```bash
echo '{}' | plugins/project/setup-isolated-env/hooks/scripts/worktree-create.sh
```

Expected: prints `{}` (silently exits, this repo has no setup-env.sh).

**Step 4: Smoke test — with a fake setup script**

```bash
mkdir -p .worktrees_scripts && touch .worktrees_scripts/setup-env.sh
echo '{}' | plugins/project/setup-isolated-env/hooks/scripts/worktree-create.sh
rm -rf .worktrees_scripts
```

Expected: prints JSON with `additionalContext` containing the system-reminder.

---

### Task 3: Create worktree-remove.sh

**Files:**
- Create: `plugins/project/setup-isolated-env/hooks/scripts/worktree-remove.sh`

**Step 1: Write the script**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Read stdin (worktree event data)
INPUT=$(cat)

# Check if this project has cleanup scripts in known locations
CLEANUP_SCRIPT=""
for loc in ".worktrees_scripts/cleanup-env.sh" "scripts/cleanup-env.sh"; do
  if [ -f "$loc" ]; then
    CLEANUP_SCRIPT="$loc"
    break
  fi
done

# Exit silently if no cleanup scripts found
if [ -z "$CLEANUP_SCRIPT" ]; then
  echo "{}"
  exit 0
fi

# Try to extract worktree path from stdin to derive env name
WORKTREE_PATH=$(echo "$INPUT" | jq -r '.worktree_path // .path // ""' 2>/dev/null || echo "")
ENV_NAME=""
if [ -n "$WORKTREE_PATH" ]; then
  ENV_NAME=$(basename "$WORKTREE_PATH")
fi

# Build the cleanup instruction
if [ -n "$ENV_NAME" ]; then
  INSTRUCTION="Run \`${CLEANUP_SCRIPT} ${ENV_NAME}\` from the project root to clean up the isolated environment (drops database, frees ports, removes .env.local)."
else
  INSTRUCTION="Run \`${CLEANUP_SCRIPT} <env-name>\` from the project root to clean up the isolated environment. The env name matches the worktree directory name."
fi

# Escape a string for embedding in a JSON string value
escape_for_json() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

CONTEXT="<system-reminder>A git worktree is being removed. This project has isolated environment cleanup scripts. ${INSTRUCTION}</system-reminder>"
CONTEXT_ESCAPED=$(escape_for_json "$CONTEXT")

cat <<EOF
{
  "additional_context": "${CONTEXT_ESCAPED}",
  "hookSpecificOutput": {
    "hookEventName": "WorktreeRemove",
    "additionalContext": "${CONTEXT_ESCAPED}"
  }
}
EOF
```

**Step 2: Make executable**

```bash
chmod +x plugins/project/setup-isolated-env/hooks/scripts/worktree-remove.sh
```

**Step 3: Smoke test — no cleanup scripts present**

```bash
echo '{}' | plugins/project/setup-isolated-env/hooks/scripts/worktree-remove.sh
```

Expected: prints `{}`.

**Step 4: Smoke test — with a fake cleanup script and worktree path**

```bash
mkdir -p .worktrees_scripts && touch .worktrees_scripts/cleanup-env.sh
echo '{"worktree_path": "/home/user/.worktrees/my-feature"}' | plugins/project/setup-isolated-env/hooks/scripts/worktree-remove.sh
rm -rf .worktrees_scripts
```

Expected: prints JSON with `additionalContext` containing the system-reminder and the command `.worktrees_scripts/cleanup-env.sh my-feature`.

---

### Task 4: Commit

**Step 1: Stage and commit**

```bash
git add plugins/project/setup-isolated-env/hooks/
git commit -m "feat(setup-isolated-env): add WorktreeCreate and WorktreeRemove hooks"
```

---

### Task 5: Bump plugin version

**Files:**
- Modify: `plugins/project/setup-isolated-env/.claude-plugin/plugin.json`

**Step 1: Update version from `0.2.2` to `0.3.0`** (minor bump — new feature)

```json
{
  "name": "setup-isolated-env",
  "version": "0.3.0",
  ...
}
```

**Step 2: Commit**

```bash
git add plugins/project/setup-isolated-env/.claude-plugin/plugin.json
git commit -m "chore(setup-isolated-env): bump version to 0.3.0"
```
