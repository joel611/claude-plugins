#!/bin/bash
set -euo pipefail

INPUT=$(cat)
NAME=$(echo "$INPUT" | jq -r '.name')
CWD=$(echo "$INPUT" | jq -r '.cwd')

# Resolve bare repo and its parent (sibling root) — make absolute if relative
GIT_COMMON_DIR=$(git -C "$CWD" rev-parse --git-common-dir)
[[ "$GIT_COMMON_DIR" = /* ]] || GIT_COMMON_DIR="$CWD/$GIT_COMMON_DIR"
GIT_COMMON_DIR=$(cd "$GIT_COMMON_DIR" && pwd)
REPO_ROOT=$(dirname "$GIT_COMMON_DIR")

# Only proceed if repo uses .bare or .git structure
if [ ! -d "$REPO_ROOT/.bare" ] && [ ! -d "$REPO_ROOT/.git" ]; then
  echo "worktree-create: no .bare or .git at $REPO_ROOT, skipping sibling layout" >&2
  exit 1
fi

FLAT_NAME="${NAME//\//--}"
DIR="$REPO_ROOT/$FLAT_NAME"
BRANCH="worktree-$NAME"

# Fetch latest
git -C "$GIT_COMMON_DIR" fetch origin --quiet 2>/dev/null || true

# Create worktree as sibling of main, branching from origin/main
git -C "$GIT_COMMON_DIR" worktree add "$DIR" -b "$BRANCH" origin/main 1>&2

# Custom WorktreeCreate hooks replace Claude Code's built-in .worktreeinclude
# copying, so replicate it here: copy gitignored files matching .worktreeinclude
# patterns (gitignore syntax) from the source worktree into the new one.
if [ -f "$CWD/.worktreeinclude" ]; then
  while IFS= read -r ENTRY; do
    [ -e "$CWD/$ENTRY" ] || continue
    mkdir -p "$DIR/$(dirname "$ENTRY")"
    cp -R "$CWD/$ENTRY" "$DIR/$ENTRY"
    echo "worktree-create: copied $ENTRY from .worktreeinclude" >&2
  done < <(git -C "$CWD" ls-files --others -i --exclude-from=.worktreeinclude -- . ':!node_modules' ':!**/node_modules/**')
fi

echo "$DIR"
