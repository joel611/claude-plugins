# Gemini Research Plugin

A multi-agent plugin for Claude Code that leverages Google's Gemini CLI to perform comprehensive code analysis and web research using Gemini's 1 million token context window.

## Overview

This plugin provides two specialized subagents that wrap gemini-cli for different research tasks:

1. **Code Analyzer** - Analyzes large codebases for patterns, architecture, quality issues, and more
2. **Web Researcher** - Performs web research for documentation, solutions, and technology comparisons

Each subagent is designed as a CLI wrapper that executes gemini-cli commands and returns raw output for Claude to interpret, keeping your main conversation focused while offloading heavy analysis to Gemini.

## Prerequisites

**Required:**
- `gemini-cli` must be installed and configured
  ```bash
  npm install -g @anthropic/gemini-cli
  ```
- Valid Gemini API credentials configured in gemini-cli

**Verify Installation:**
```bash
gemini --version
```

## Components

### Agents (CLI Wrappers)

#### `gemini-code-analyzer`
Located in: `agents/code-analyzer.md`

A specialized agent that wraps gemini-cli for code analysis. It:
- Receives analysis requests with codebase context
- Constructs appropriate `gemini --all-files --yolo -p` commands
- Returns raw gemini output without interpretation
- Handles 7 analysis categories:
  - Pattern Detection
  - Architecture Analysis
  - Code Quality
  - Technology Stack
  - Feature Analysis
  - Migration & Refactoring
  - Documentation

#### `gemini-web-researcher`
Located in: `agents/web-researcher.md`

A specialized agent that wraps gemini-cli for web research. It:
- Receives research requests with project context
- Constructs appropriate gemini CLI commands for research
- Returns raw gemini research output
- Handles 8 research categories:
  - Documentation Lookup
  - Solution Research
  - Technology Comparison
  - API and SDK Research
  - Framework and Tool Updates
  - Architecture and Design Patterns
  - Security Research
  - Performance Optimization

### Skills (User-Facing)

#### `code-analyzer` Skill
Located in: `skills/code-analyzer/SKILL.md`

The user-facing skill that:
- Identifies when code analysis is needed
- Gathers codebase context
- Spawns the gemini-code-analyzer subagent with detailed prompts
- Processes and interprets the raw gemini output
- Provides actionable summaries to the user

**Use cases:**
- "Find all React hooks in the codebase"
- "Analyze the authentication flow"
- "Check for security vulnerabilities"
- "Identify performance bottlenecks"
- "Map the component hierarchy"

#### `web-researcher` Skill
Located in: `skills/web-researcher/SKILL.md`

The user-facing skill that:
- Identifies when web research is needed
- Gathers research context
- Spawns the gemini-web-researcher subagent with detailed prompts
- Processes and interprets research findings
- Provides summaries with links and recommendations

**Use cases:**
- "Find the latest Next.js App Router documentation"
- "How do I implement Stripe subscriptions?"
- "Compare Prisma vs Drizzle ORM"
- "Research solutions for hydration errors"
- "Best practices for React state management in 2024"

## How It Works

### Architecture

```
User Request
    ↓
Claude Code (with gemini-research plugin)
    ↓
Skill determines context and spawns subagent
    ↓
Subagent (gemini-code-analyzer or gemini-web-researcher)
    ↓
Constructs gemini-cli command with detailed prompt
    ↓
Executes: gemini --all-files --yolo -p "analysis prompt"
    ↓
Returns raw gemini output
    ↓
Skill interprets and summarizes results
    ↓
User receives actionable insights
```

### Key Design Principles

1. **Subagents are CLI wrappers only** - They don't analyze or interpret, just manage gemini-cli
2. **Skills provide context** - They gather necessary context and spawn subagents via Task tool
3. **Leverage Gemini's 1M tokens** - Perfect for analyzing large codebases
4. **Keep main conversation focused** - Offload heavy analysis to Gemini
5. **Raw output interpretation** - Claude interprets gemini results for the user

## Installation

Install the plugin from this marketplace:

```bash
/plugin install gemini-research@joel-plugins
```

## Usage Examples

### Example 1: Code Analysis

**User:** "Find all database queries in my codebase and check for N+1 issues"

**What happens:**
1. `code-analyzer` skill activates
2. Skill gathers codebase context (location, tech stack)
3. Spawns `gemini-code-analyzer` subagent with detailed prompt
4. Subagent runs: `gemini --all-files --yolo -p "Find all database queries..."`
5. Returns raw gemini output showing all queries with locations
6. Skill interprets findings and highlights N+1 issues
7. User gets actionable report with specific file paths

### Example 2: Web Research

**User:** "What's the best way to implement authentication in Next.js 14?"

**What happens:**
1. `web-researcher` skill activates
2. Skill gathers context (Next.js 14, App Router, requirements)
3. Spawns `gemini-web-researcher` subagent with research prompt
4. Subagent runs: `gemini -p "Research authentication solutions for Next.js 14..."`
5. Returns raw gemini research with docs, comparisons, examples
6. Skill summarizes findings with recommendations and links
7. User gets current best practices with documentation links

### Example 3: Combined Workflow

**User:** "Audit my codebase for security issues and research how to fix them"

**What happens:**
1. `code-analyzer` skill spawns subagent to audit codebase
2. Identifies security vulnerabilities with locations
3. `web-researcher` skill spawns subagent to research fixes
4. Finds current security best practices and solutions
5. User gets both: security issues found + how to fix them

## Best Practices

### When Using code-analyzer

1. **Be specific about analysis goals** - "Find React hooks" is better than "analyze code"
2. **Provide context** - Mention tech stack, project type, areas of focus
3. **Use for large-scale analysis** - Best for patterns across many files
4. **Follow up with Read tool** - Use Read to examine specific findings in detail
5. **Combine analyses** - Run multiple focused analyses rather than one giant one

### When Using web-researcher

1. **Request current information** - Always ask for "latest" or "2024" information
2. **Be specific about use case** - Include your tech stack and requirements
3. **Ask for links** - Request official documentation URLs
4. **Request code examples** - Ask for practical implementation examples
5. **Specify comparison criteria** - When comparing, mention what matters to you

### Combining Both Skills

- Analyze codebase first, then research better approaches
- Research best practices, then audit codebase for compliance
- Find patterns in code, then research why they're problematic
- Research new features, then trace existing implementation

## Advanced Usage

### Multi-Step Analysis
```
1. code-analyzer: Get architecture overview
2. code-analyzer: Deep dive into specific areas
3. web-researcher: Research better patterns found
4. code-analyzer: Find all instances to refactor
```

### Research Workflows
```
1. web-researcher: Broad technology overview
2. web-researcher: Compare specific options
3. web-researcher: Deep dive into chosen approach
4. code-analyzer: Check current implementation
```

## Troubleshooting

### "gemini-cli not found"
- Install: `npm install -g @anthropic/gemini-cli`
- Verify: `gemini --version`
- Check PATH configuration

### Outdated Research Results
- Explicitly request "latest" or "2024" information
- Specify versions in your question
- Ask for "current best practices"

### Analysis Too Broad
- Narrow scope to specific directories
- Focus on particular patterns or file types
- Break into multiple targeted analyses

### Missing Context in Results
- Provide more details in the initial request
- Include tech stack, scale, constraints
- Request specific output format (tables, lists, etc.)

## Reference Documentation

- **gemini-cli**: https://github.com/anthropics/gemini-cli
- **Egghead Tutorial**: https://egghead.io/create-a-gemini-cli-powered-subagent-in-claude-code~adkge
- **Claude Code Plugins**: https://docs.claude.com/en/docs/claude-code/plugins
- **Agent Skills**: https://docs.claude.com/en/docs/claude-code/skills

## Contributing

Found an issue or have a suggestion? This plugin is part of the joel-plugins marketplace. Please contribute improvements or report issues.

## License

Part of the Claude Code marketplace plugin collection.

## Credits

Inspired by the Egghead.io tutorial on creating Gemini CLI-powered subagents in Claude Code, this plugin implements a comprehensive multi-agent system for code analysis and web research.
