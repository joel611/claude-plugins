# Claude Code Marketplace

A collection of plugins that extend Claude Code with custom functionality for development tasks.

## What is this?

This marketplace contains plugins that add new capabilities to Claude Code, including:
- Custom skills for specialized tasks
- Slash commands for quick actions
- Agent definitions for automated workflows
- Hooks for event-driven automation
- MCP server integrations

## Installation

### Install the Marketplace

To use plugins from this marketplace, you first need to install the marketplace itself:

```bash
/plugin install-marketplace https://github.com/joel611/claude-marketplace
```

Or if you have the marketplace cloned locally:

```bash
/plugin install-marketplace /path/to/claude-marketplace
```

### Install Individual Plugins

Once the marketplace is installed, you can install specific plugins:

```bash
/plugin install plugin-name@joel-plugins
```

Replace `plugin-name` with the name of the plugin you want to install (see available plugins below).

## Available Plugins

### plugin-builder

Helps create well-structured Claude Code plugins with skills, commands, and proper metadata following best practices.

**Install:**
```bash
/plugin install plugin-builder@joel-plugins
```

**Use:**
```bash
/plugin-builder
```

### playwright-e2e

Comprehensive Playwright E2E testing plugin with test generation, Page Object Models, debugging, and maintenance. Features data-testid locators, TypeScript-first approach, and Playwright MCP integration for browser automation.

**Install:**
```bash
/plugin install playwright-e2e@joel-plugins
```

**Use:**
```bash
/playwright-e2e
```

## Plugin Management

### List Installed Plugins
```bash
/plugin list
```

### Uninstall a Plugin
```bash
/plugin uninstall plugin-name
```

### Update a Plugin
```bash
/plugin update plugin-name
```

## Development

Want to contribute a plugin? Use the `plugin-builder` skill to create a well-structured plugin following best practices:

1. Install the plugin-builder: `/plugin install plugin-builder@joel-plugins`
2. Run the builder: `/plugin-builder`
3. Follow the prompts to create your plugin
4. Submit a pull request to add your plugin to the marketplace

### Plugin Structure

Each plugin should follow this structure:
```
plugin-name/
├── .claude-plugin/
│   └── plugin.json       # Plugin metadata (required)
├── skills/               # Agent Skills (optional)
├── commands/             # Slash commands (optional)
├── agents/               # Custom agents (optional)
├── hooks/                # Event handlers (optional)
└── .mcp.json            # MCP server config (optional)
```

## Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/joel611/claude-marketplace).

## License

See individual plugin directories for license information.
