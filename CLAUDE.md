# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Claude Code marketplace repository - a collection of plugins that extend Claude Code with custom functionality for development tasks. Users can install plugins from this marketplace using `/plugin install plugin-name@marketplace-name`.

**Current Plugins:**
- **plugin-builder** (`plugins/claude/plugin-builder`): A comprehensive skill for creating well-structured Claude Code plugins. Includes templates and best practices for plugin development.

## Architecture

**Marketplace Structure:**
```
claude-marketplace/
├── .claude-plugin/
│   └── marketplace.json           # Marketplace metadata and plugin registry
├── plugins/
│   └── category/                  # Category grouping (e.g., claude, data, testing)
│       └── plugin-name/
│           ├── .claude-plugin/
│           │   └── plugin.json    # Plugin metadata (required)
│           ├── skills/            # Agent Skills (optional)
│           │   └── skill-name/
│           │       ├── SKILL.md   # Skill instructions
│           │       ├── resources/ # Templates, data files
│           │       └── scripts/   # Executable code
│           ├── commands/          # Custom slash commands (optional)
│           │   └── command-name.md
│           ├── agents/            # Custom agent definitions (optional)
│           ├── hooks/             # Event handlers (optional)
│           │   └── hooks.json
│           └── .mcp.json         # MCP server config (optional)
```

**Key Concepts:**
- **Marketplace**: The root repository containing multiple plugins. Defined by `.claude-plugin/marketplace.json`.
- **Plugin**: A subdirectory with its own `.claude-plugin/plugin.json` and optional components (commands, agents, skills, hooks, MCP servers).
- **Components**: Plugins can include:
  - Commands: Markdown files in `commands/` defining custom slash commands
  - Agents: Custom agent definitions in `agents/`
  - Skills: Model-invoked capabilities in `skills/` with `SKILL.md` files
  - Hooks: Event handlers via `hooks.json`
  - MCP Servers: External tool integration via `.mcp.json`

## Working with Plugins

**Creating a New Plugin:**
1. Create a new directory in the repository root with the plugin name
2. Add `.claude-plugin/plugin.json` with metadata (name, description, version, author)
3. Add plugin components in appropriate subdirectories (commands/, agents/, etc.)
4. Update `.claude-plugin/marketplace.json` to register the new plugin

**Plugin Manifest Structure (plugin.json):**
```json
{
  "name": "plugin-name",
  "description": "Plugin functionality description",
  "version": "1.0.0",
  "author": {
    "name": "Author Name"
  }
}
```

**Marketplace Manifest (.claude-plugin/marketplace.json):**
Defines the marketplace containing plugins with their sources and descriptions. Should list all available plugins in this marketplace.

## Development Workflow

1. Test plugins locally before committing
2. Use semantic versioning for plugin versions
3. Ensure all plugins have complete metadata in their plugin.json
4. Document each plugin's functionality clearly
5. Keep the marketplace.json updated with all available plugins
