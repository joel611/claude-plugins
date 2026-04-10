---
name: gemini-second-opinion
description: Gets a second opinion from Gemini on code, architecture decisions, or implementation approaches. Activate when the user wants an external perspective on their code, asks "what do you think of this approach", wants to validate an architectural decision, needs critique of a design, or explicitly asks for a second opinion or code review.
version: 3.0.0
model: sonnet
---

# Gemini Second Opinion Skill

## Trigger

Activate when the user wants an independent critique of code, an architecture decision, or an implementation choice.

## How to Use

1. Collect from the user's message:
   - The subject for review (code snippet, architecture description, or decision — copy verbatim or ask user to paste it)
   - Goal (what it's trying to achieve)
   - Tech stack (relevant languages, frameworks, libraries)
   - Constraints (performance, scale, team size — if mentioned)
   - Alternatives already considered (if mentioned)

2. Spawn the `gemini-advisor` agent via Task tool with this message:

   ```
   Subject: [code, architecture description, or decision]
   Goal: [what it's trying to achieve]
   Tech stack: [stack]
   Constraints: [constraints, or "none specified"]
   Alternatives considered: [alternatives, or "none"]
   ```

3. Present the agent's returned summary (verdict + key points) to the user, then say:
   "Full review saved to `[file path from agent]`. Ask me about specific findings."
