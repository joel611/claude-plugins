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
