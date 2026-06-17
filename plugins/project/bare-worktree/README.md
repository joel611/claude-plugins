# bare-worktree Plugin

Sibling-layout worktree create/remove for bare-repo projects (`repo/.bare` + `repo/<branch>` worktrees as siblings, e.g. the layout from `git clone --bare` + `git worktree add ../branch`).

## Installation

```bash
/plugin install bare-worktree@claude-marketplace
```

## How It Works

### WorktreeCreate

Triggered whenever Claude Code (or the `Agent` tool with `isolation: "worktree"`) needs a new worktree. The hook:

1. Resolves the repo's common git dir and finds the sibling root (the directory containing `.bare` or `.git`).
2. Refuses to run (exit 1) if that root doesn't use the `.bare`/`.git` sibling layout — this plugin is specifically for that layout, not Claude Code's default nested-worktree convention.
3. Fetches `origin`, then creates the new worktree as a sibling directory, branching from `origin/main` as `worktree-<name>`.
4. Replicates Claude Code's built-in `.worktreeinclude` copying (which this custom hook replaces): any gitignored files matching patterns in the source worktree's `.worktreeinclude` (gitignore syntax, e.g. `.env`) are copied into the new worktree.
5. Prints the new worktree path to stdout.

### WorktreeRemove

Removes the worktree at the given path (`git worktree remove --force`) when Claude Code tears it down.

## .worktreeinclude

Add a `.worktreeinclude` file (gitignore syntax) to the root of any worktree to have matching gitignored files copied into new worktrees created from it:

```
.env
```

## Project Structure

```
bare-worktree/
├── .claude-plugin/
│   └── plugin.json
├── hooks/
│   ├── hooks.json
│   └── scripts/
│       ├── worktree-create.sh
│       └── worktree-remove.sh
└── README.md
```

## Known Issue

`worktree-create.sh` has no logging beyond `stderr` echoes — if the `.worktreeinclude` copy step silently no-ops (e.g. wrong `cwd` passed in the hook input), there's currently no durable record to diagnose it after the fact. Consider redirecting the script's stderr to a log file if you hit a worktree missing expected copied files.

## Author

Joel Chan (chanhokyim@gmail.com)
