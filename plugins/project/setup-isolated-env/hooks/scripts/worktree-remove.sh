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
