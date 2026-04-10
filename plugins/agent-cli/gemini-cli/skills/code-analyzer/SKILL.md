---
name: gemini-code-analyzer
description: Uses Gemini CLI to analyze large codebases for patterns, architecture, code quality, security, and feature flows. Activate when the user asks to analyze a codebase, find patterns across files, audit code quality, trace feature implementations, identify security issues, detect performance bottlenecks, or needs large-scale analysis.
version: 3.0.0
---

# Gemini Code Analyzer Skill

## Trigger

Activate when the user needs large-scale codebase analysis that would be expensive in Claude's context.

## How to Use

1. Collect from the user's message:
   - Their exact request (copy verbatim)
   - Working directory path (if mentioned, else use current)
   - Specific focus areas, files, or patterns (if mentioned)
   - Desired output format (if mentioned)

2. Spawn the `gemini-code-analyzer` agent via Task tool with this message:

   ```
   Request: [user's exact request]
   Directory: [path or "current directory"]
   Focus: [specific areas, or "none specified"]
   Output format: [format, or "grouped report"]
   ```

3. Present the agent's returned summary to the user, then say:
   "Full analysis saved to `[file path from agent]`. Ask me about specific findings."
