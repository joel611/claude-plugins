# Plugin Builder Skill

## Purpose

This skill guides you through creating well-structured Claude Code plugins with all necessary components, following best practices for discoverability, maintainability, and user experience.

## When to Use

Use this skill when:
- Creating a new Claude Code plugin from scratch
- Adding components (skills, commands, agents, hooks) to existing plugins
- Generating properly structured SKILL.md files
- Setting up marketplace plugin registration
- Validating plugin metadata and structure

## Prerequisites

- Access to a Claude Code marketplace repository
- Understanding of the plugin's intended functionality
- Basic knowledge of JSON and Markdown formats
- Location of the marketplace root directory

## Plugin Architecture Overview

A Claude Code plugin follows this structure:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json       # Required: Plugin metadata
├── skills/               # Optional: Agent Skills
│   └── skill-name/
│       ├── SKILL.md      # Skill instructions
│       ├── scripts/      # Optional: Executable code
│       └── resources/    # Optional: Templates, data
├── commands/             # Optional: Custom slash commands
│   └── command-name.md
├── agents/               # Optional: Custom agent definitions
├── hooks/                # Optional: Event handlers
│   └── hooks.json
└── .mcp.json            # Optional: MCP server configuration
```

## Instructions

### Step 1: Plan the Plugin

Before creating files, clarify:
1. **Plugin name** (use kebab-case: `my-plugin-name`)
2. **Purpose** (what problem does it solve?)
3. **Components needed** (skills, commands, agents, hooks?)
4. **Target users** (who will use this plugin?)

### Step 2: Create Plugin Directory Structure

1. Navigate to the marketplace `plugins/` directory
2. Create the plugin directory: `plugins/category/plugin-name/`
3. Create required subdirectories:
   ```bash
   mkdir -p plugins/category/plugin-name/.claude-plugin
   mkdir -p plugins/category/plugin-name/skills
   mkdir -p plugins/category/plugin-name/commands  # if needed
   ```

### Step 3: Generate plugin.json

Create `.claude-plugin/plugin.json` with this structure:

```json
{
  "name": "plugin-name",
  "description": "Clear, concise description of plugin functionality (1-2 sentences)",
  "version": "1.0.0",
  "author": {
    "name": "Author Name",
    "email": "author@example.com"
  },
  "category":"testing"
}
```

**Required fields:**
- `name`: Plugin identifier (kebab-case, no spaces)
- `description`: User-facing description (be specific about what it does)
- `version`: Semantic version (major.minor.patch)
- `author.name`: Author's name

**Optional field**
- `category`: Plugin category (e.g., "testing", "productivity", "tools")

**Version Guidelines:**
- Start with `1.0.0` for initial release
- Increment patch (1.0.1) for bug fixes
- Increment minor (1.1.0) for new features (backward compatible)
- Increment major (2.0.0) for breaking changes

### Step 4: Create Skills (if applicable)

For each skill in the plugin:

1. **Create skill directory:**
   ```bash
   mkdir -p plugins/category/plugin-name/skills/skill-name
   ```

2. **Create SKILL.md** using progressive disclosure format:

```markdown
# Skill Name

## Purpose
[1-2 sentences: What this skill does and its main value]

## When to Use
[Bullet list of specific scenarios where this skill applies]
- Creating X
- Automating Y
- Solving Z problem

## Prerequisites
[What's needed before using this skill]
- Required tools or libraries
- Necessary permissions or access
- Context or information needed

## Instructions

### Task 1: [First Major Step]
[Detailed step-by-step instructions]
1. Do this first
2. Then do this
3. Finally do this

### Task 2: [Second Major Step]
[More detailed instructions]

[Continue with all major tasks...]

## Examples

### Example 1: [Concrete Use Case]
[Show complete example with actual code/commands]

\`\`\`language
[actual code]
\`\`\`

### Example 2: [Another Use Case]
[Another complete example]

## Best Practices
- [Specific practice 1]
- [Specific practice 2]
- [Specific practice 3]

## Common Issues
- **Problem:** [Description]
  **Solution:** [How to fix]
- **Problem:** [Description]
  **Solution:** [How to fix]
```

3. **Add optional resources:**
   ```bash
   mkdir -p plugins/category/plugin-name/skills/skill-name/resources
   mkdir -p plugins/category/plugin-name/skills/skill-name/scripts
   ```

**Skill Best Practices:**
- **Focus:** Each skill should do ONE thing well
- **Discoverability:** Use clear, searchable names and descriptions
- **Progressive disclosure:** Start with overview, then details, then examples
- **Actionable:** Provide concrete steps, not generic advice
- **Examples:** Include real, working examples users can adapt
- **Error handling:** Document common issues and solutions

### Step 5: Create Commands (if applicable)

For custom slash commands:

1. **Create command file:**
   ```bash
   touch plugins/category/plugin-name/commands/command-name.md
   ```

2. **Write command markdown:**

```markdown
# Command Name

[Description of what this command does]

## Usage
/command-name [arguments]

## Examples
/command-name example-arg

## Parameters
- `arg1`: Description of first argument
- `arg2`: Description of second argument (optional)

## Instructions for Claude
[Detailed instructions for what Claude should do when this command is invoked]

1. Step 1
2. Step 2
3. Step 3
```

### Step 6: Update Marketplace Registry

1. **Open marketplace.json:**
   Located at `.claude-plugin/marketplace.json` in the repository root

2. **Add plugin entry:**
   ```json
   {
     "name": "marketplace-name",
     "plugins": [
       {
         "name": "plugin-name",
         "source": "./plugins/category/plugin-name",
         "description": "Plugin description"
       }
     ]
   }
   ```

   **Important:** For local plugins, the `source` field must start with `./` to specify a relative path from the marketplace root.

### Step 7: Validate Plugin

**Checklist:**
- [ ] plugin.json exists and has all required fields
- [ ] Plugin name uses kebab-case (no spaces, lowercase with hyphens)
- [ ] Description is clear and specific
- [ ] Version follows semantic versioning (major.minor.patch)
- [ ] All SKILL.md files follow progressive disclosure format
- [ ] Examples are included in all SKILL.md files
- [ ] Commands have clear usage instructions
- [ ] Plugin is registered in marketplace.json
- [ ] File paths are correct and accessible

### Step 8: Test Locally

1. **Install the plugin locally:**
   - User runs: `/plugin install plugin-name@marketplace-name`

2. **Test skill invocation:**
   - Verify skills are discoverable
   - Test with relevant prompts
   - Check that instructions are clear

3. **Test commands:**
   - Run each slash command
   - Verify behavior matches documentation

4. **Iterate:**
   - Fix any issues found
   - Update documentation as needed
   - Increment version number for changes

## Complete Examples

### Example 1: Creating a Data Validation Plugin

**Scenario:** Create a plugin that validates JSON schemas

**Step-by-step:**

1. **Create structure:**
   ```bash
   mkdir -p plugins/data/json-validator/.claude-plugin
   mkdir -p plugins/data/json-validator/skills/json-validator
   ```

2. **Create plugin.json:**
   ```json
   {
     "name": "json-validator",
     "description": "Validates JSON data against schemas with detailed error reporting",
     "version": "1.0.0",
     "author": {
       "name": "Data Team"
     }
   }
   ```

3. **Create SKILL.md:**
   ```markdown
   # JSON Validator Skill

   ## Purpose
   Validates JSON data against JSON Schema specifications and provides detailed error reports.

   ## When to Use
   - Validating API request/response payloads
   - Checking configuration files
   - Ensuring data structure compliance

   ## Prerequisites
   - JSON data to validate
   - JSON Schema definition
   - Understanding of JSON Schema syntax

   ## Instructions

   ### Validate JSON Data
   1. Receive or locate the JSON data to validate
   2. Receive or locate the JSON Schema
   3. Parse both JSON data and schema
   4. Validate data against schema
   5. Report validation results with specific errors
   6. Suggest fixes for validation errors

   ## Examples

   ### Example 1: Validate User Object
   Schema:
   \`\`\`json
   {
     "type": "object",
     "properties": {
       "name": {"type": "string"},
       "age": {"type": "number"}
     },
     "required": ["name"]
   }
   \`\`\`

   Valid data:
   \`\`\`json
   {"name": "Alice", "age": 30}
   \`\`\`

   Invalid data:
   \`\`\`json
   {"age": 30}
   \`\`\`
   Error: Missing required property 'name'

   ## Best Practices
   - Always show the full error path for nested objects
   - Suggest corrected JSON when possible
   - Validate schema itself before using it
   - Handle common schema mistakes gracefully

   ## Common Issues
   - **Problem:** Schema reference ($ref) not resolved
     **Solution:** Ensure all referenced schemas are accessible
   - **Problem:** Type coercion confusion
     **Solution:** Be explicit about type expectations
   ```

4. **Update marketplace.json:**
   ```json
   {
     "plugins": [
       {
         "name": "json-validator",
         "source": "./plugins/data/json-validator",
         "description": "Validates JSON data against schemas"
       }
     ]
   }
   ```

### Example 2: Adding a Skill to Existing Plugin

**Scenario:** Add a new skill to the json-validator plugin

1. **Create new skill directory:**
   ```bash
   mkdir -p plugins/data/json-validator/skills/schema-generator
   ```

2. **Create SKILL.md:**
   ```markdown
   # Schema Generator Skill

   ## Purpose
   Generates JSON Schema definitions from example JSON data.

   ## When to Use
   - Creating schemas from existing data
   - Documenting API data structures
   - Reverse engineering schemas

   [... rest of SKILL.md ...]
   ```

3. **Update plugin version:**
   Edit `plugin.json`:
   ```json
   {
     "version": "1.1.0"
   }
   ```
   (Minor version increment for new feature)

## Naming Conventions

**Plugins:**
- Use kebab-case: `my-plugin-name`
- Be descriptive but concise
- Avoid generic names like "helper" or "utility"
- Good: `json-validator`, `code-formatter`, `api-tester`
- Bad: `helper`, `utils`, `my_plugin`

**Skills:**
- Use clear, action-oriented names
- Match the skill's primary function
- Good: `json-validator`, `schema-generator`, `data-transformer`
- Bad: `skill1`, `helper`, `misc`

**Commands:**
- Start with verb when possible
- Be specific about action
- Good: `validate-json`, `generate-schema`, `format-code`
- Bad: `do-thing`, `run`, `help`

## Best Practices Summary

### Plugin Design
- **Single responsibility:** Each plugin should have a clear, focused purpose
- **Composability:** Plugins should work well together
- **Discoverability:** Names and descriptions should make purpose obvious
- **Documentation:** Include examples for all features
- **Versioning:** Follow semantic versioning strictly

### Skill Design
- **Progressive disclosure:** Overview → Instructions → Examples
- **Concrete examples:** Show real code, not pseudocode
- **Error handling:** Document common issues and solutions
- **Prerequisites:** List what's needed upfront
- **Modularity:** Keep skills focused on specific tasks

### Testing
- **Local testing:** Always test before committing
- **User perspective:** Test as if you've never seen it before
- **Documentation:** Verify all examples work
- **Edge cases:** Test with unusual inputs
- **Integration:** Test with other plugins

### Maintenance
- **Version bump:** Update version for any changes
- **Changelog:** Document what changed and why
- **Backward compatibility:** Don't break existing users
- **Deprecation:** Warn before removing features
- **Updates:** Keep dependencies and references current

## Common Issues and Solutions

### Issue 1: Skill Not Being Discovered
**Problem:** Claude doesn't load the skill when relevant

**Solutions:**
- Check SKILL.md filename is exactly `SKILL.md` (case-sensitive)
- Verify skill directory path: `plugins/category/plugin/skills/skill-name/SKILL.md`
- Ensure plugin is registered in marketplace.json
- Check that skill name and description are descriptive
- Verify plugin is installed: `/plugin list`

### Issue 2: Invalid Plugin Metadata
**Problem:** Plugin fails to install or load

**Solutions:**
- Validate JSON syntax in plugin.json (no trailing commas, proper quotes)
- Ensure all required fields present: name, description, version, author.name
- Check name uses kebab-case with no spaces
- Verify version follows semantic versioning (X.Y.Z)
- Ensure file is named exactly `plugin.json`

### Issue 3: Command Not Working
**Problem:** Slash command doesn't execute

**Solutions:**
- Verify command file is in `commands/` directory
- Check filename matches command name
- Ensure markdown formatting is correct
- Verify plugin is installed and loaded
- Check command syntax matches documentation

### Issue 4: Marketplace Registration Failed
**Problem:** Plugin not showing in marketplace

**Solutions:**
- Verify marketplace.json syntax is valid
- Check plugin source path is correct relative to marketplace root
- Ensure plugin name in marketplace.json matches plugin.json
- Verify marketplace.json is in `.claude-plugin/` at repo root

### Issue 5: Version Conflicts
**Problem:** Multiple versions causing issues

**Solutions:**
- Use semantic versioning consistently
- Document breaking changes clearly
- Test compatibility with existing plugins
- Update marketplace.json with correct version
- Consider version deprecation strategy

## Resources

The plugin-builder includes templates in `skills/plugin-builder/resources/`:
- `plugin-template.json`: Starter plugin.json
- `skill-template.md`: SKILL.md boilerplate
- `command-template.md`: Command file structure
- `marketplace-entry.json`: Marketplace registration example

## Support

For plugin system documentation, see:
- Claude Code Plugins: https://docs.claude.com/en/docs/claude-code/plugins
- Agent Skills: https://docs.claude.com/en/docs/claude-code/skills
- Skills Best Practices: https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills/best-practices
