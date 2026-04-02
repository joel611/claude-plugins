---
name: gemini-code-analyzer
description: Uses Gemini CLI to analyze large codebases for patterns, architecture, code quality, security, and feature flows. Activate when the user asks to analyze a codebase, find patterns across files, audit code quality, trace feature implementations, identify security issues, detect performance bottlenecks, or needs large-scale analysis.
version: 2.0.0
---

# Gemini Code Analyzer Skill

## Purpose

Offload large-scale codebase analysis to Gemini CLI. Build a single structured prompt that guides Gemini through the full thinking process — Gemini handles exploration, analysis, synthesis, and presentation. Claude's only job is to construct the right prompt and pass it to the agent.

## Prerequisites

- `gemini-cli` installed: `npm install -g @google/gemini-cli`
- Valid Gemini API credentials configured
- Verify: `gemini --version`

## How to Use This Skill

1. Identify the analysis type and gather what context the user provides (codebase path, tech stack, focus area)
2. Build a structured prompt using the template below — include the analysis type and any known context
3. Spawn the `gemini-code-analyzer` agent via Task tool with that prompt
4. Present Gemini's response to the user as-is

## Prompt Template

Use this template to construct the gemini prompt. Fill in the bracketed sections:

```
You are analyzing a software codebase. Work through this step by step:

**Step 1 — Understand the project:**
Examine the project structure. What type of project is this? What is the tech stack, directory layout, and overall organization?

**Step 2 — Locate relevant code:**
Find the files, modules, and areas relevant to the analysis task. Focus on: [specific directories, file types, or patterns if the user mentioned them — otherwise scan broadly].

**Step 3 — Analyze in depth:**
For each relevant area, examine it closely. For the specific analysis type:
[Insert analysis-type-specific instructions from the list below]

**Step 4 — Record findings:**
For each finding, note: exact file path, approximate line number, description of what was found, and why it matters.

**Step 5 — Synthesize and present:**
Organize findings clearly. Group by [severity / category / file — pick what fits the analysis]. Lead with the most important findings. Conclude with recommended next steps.

**Task:** [Restate the user's exact request here]
**Working directory:** [Current directory or path if user specified]
**Focus:** [Any specific files, directories, or patterns the user mentioned]
**Output format:** [List / table / report — match what the user asked for]
```

## Step 3 Instructions by Analysis Type

Replace the Step 3 block in the template with the appropriate instructions:

**Pattern Detection** (hooks, queries, API patterns):
```
Identify all instances of [pattern] across the codebase. For each instance: where it appears, how it's used, any variations, and any problematic usage.
```

**Architecture Analysis** (component hierarchy, data flow, dependencies):
```
Map the structure: how components/modules relate, data flows between them, dependency relationships, and any architectural concerns (tight coupling, circular dependencies, violation of separation of concerns).
```

**Code Quality** (performance, security, smells, technical debt):
```
Identify issues categorized by severity (Critical / High / Medium / Low). For each: what the issue is, why it's a problem, the specific location, and the recommended fix.
```

**Security Audit**:
```
Check for: injection vulnerabilities (SQL, command, XSS), insecure authentication or authorization, exposed secrets or credentials, improper input validation, CSRF issues, insecure data storage or transmission. Rate each finding by severity.
```

**Feature Tracing** (how a feature is implemented end-to-end):
```
Trace [feature name] from entry point to data persistence: UI components → business logic → API calls → data layer. Show the complete call chain with file paths at each step.
```

**Technology Stack Analysis**:
```
Catalog all dependencies (direct and dev), identify unused or outdated packages, flag any with known security issues, and assess the testing and tooling setup.
```

**Refactoring / Legacy Detection**:
```
Find: deprecated API usage, inconsistent naming or patterns, duplicated logic, outdated syntax, and opportunities to use modern language features.
```

**Onboarding / Documentation**:
```
Explain the codebase to a new developer: overall architecture, key entry points, important patterns to know, suggested reading order, and any non-obvious conventions.
```

## Example

**User:** "Find all database queries and check for N+1 issues"

**Prompt to pass to agent:**
```
You are analyzing a software codebase. Work through this step by step:

**Step 1 — Understand the project:**
Examine the project structure. What type of project is this? What is the tech stack, directory layout, and overall organization?

**Step 2 — Locate relevant code:**
Find all files that contain database queries or ORM calls.

**Step 3 — Analyze in depth:**
For each query found: identify the query type (raw SQL, ORM, query builder), what table/collection it accesses, whether it runs inside a loop (N+1 risk), and whether results are cached or paginated.

**Step 4 — Record findings:**
For each N+1 issue or optimization opportunity: file path, approximate line number, what the query does, and why it's problematic.

**Step 5 — Synthesize and present:**
Group findings by severity. List all N+1 issues first, then other optimization opportunities. For each, include the recommended fix.

**Task:** Find all database queries and identify N+1 issues
**Working directory:** current directory
**Output format:** Grouped report with file paths and recommended fixes
```
