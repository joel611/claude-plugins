---
name: gemini-web-researcher
description: Uses Gemini CLI to perform web research for technical documentation, solutions, library comparisons, and best practices. Activate when the user needs to find latest documentation, research solutions to technical problems, compare libraries or frameworks, look up API/SDK documentation, or find current information.
version: 3.0.0
---

# Gemini Web Researcher Skill

## Trigger

Activate when the user needs current technical information from the web.

## How to Use

1. Collect from the user's message:
   - Their exact research question (copy verbatim)
   - Tech stack and versions (if mentioned)
   - Constraints (version requirements, compatibility, scale — if mentioned)

2. Spawn the `gemini-web-researcher` agent via Task tool with this message:

   ```
   Question: [user's exact research question]
   Tech stack: [stack/versions, or "not specified"]
   Constraints: [constraints, or "none"]
   ```

3. Present the agent's returned summary to the user, then say:
   "Full research saved to `[file path from agent]`. Ask me about specific findings."
