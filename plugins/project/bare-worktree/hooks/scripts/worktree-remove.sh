#!/bin/bash
set -euo pipefail

INPUT=$(cat)
WORKTREE_PATH=$(echo "$INPUT" | jq -r '.worktree_path')

GIT_COMMON_DIR=$(git -C "$WORKTREE_PATH" rev-parse --git-common-dir)
git -C "$GIT_COMMON_DIR" worktree remove "$WORKTREE_PATH" --force 1>&2
