---
name: gemini-second-opinion 
description: Gets a second opinion from Gemini on code, architecture decisions, or implementation approaches. Activate when the user wants an external perspective on their code, asks "what do you think of this approach", wants to validate an architectural decision, needs critique of a design, or explicitly asks for a second opinion or code review.
version: 2.0.0
model: haiku
---

# Gemini Second Opinion Skill

## Purpose

Offload code review and decision critique to Gemini CLI. Build a single structured prompt that guides Gemini through a full review — Gemini handles understanding, critiquing, and recommending. Claude's only job is to construct the right prompt and pass it to the agent.

## Prerequisites

- `gemini-cli` installed: `npm install -g @google/gemini-cli`
- Valid Gemini API credentials configured
- Verify: `gemini --version`

## How to Use This Skill

1. Gather the subject for review (code snippet, architecture description, or decision) and any context the user provides
2. Build a structured prompt using the template below
3. Spawn the `gemini-advisor` agent via Task tool with that prompt
4. Present Gemini's response to the user as-is

## Prompt Template

```
You are performing a technical review. Work through this step by step:

**Step 1 — Understand the subject:**
What is this code/approach/decision trying to accomplish? What problem does it solve? What are the stated goals and constraints?

**Step 2 — Evaluate strengths:**
What does this do well? Where is it correct, efficient, secure, or elegantly designed?

**Step 3 — Identify weaknesses:**
What are the risks, bugs, security vulnerabilities, performance problems, scalability limits, or maintainability concerns? Be specific — cite exact issues, not general observations.

**Step 4 — Consider alternatives:**
Are there better approaches for this use case? What are the trade-offs of each alternative vs the current approach?

**Step 5 — Give a verdict:**
One of: ✅ Approve as-is / ⚠️ Approve with changes / ❌ Reconsider approach. Explain why. List the top 3 most important changes if any are needed.

**Subject for review:**
[Paste the code, describe the architecture, or state the decision here]

**Context:**
- Goal: [what this is trying to achieve]
- Tech stack: [relevant languages, frameworks, libraries]
- Constraints: [performance requirements, scale, team size, etc.]
- Alternatives already considered: [what else was evaluated, if any]
```

## Variants

### For a code snippet:

Add after the subject: "Focus particularly on: correctness, edge cases, security, and readability."

### For an architecture decision:

Add after the subject: "Focus particularly on: scalability, operational complexity, team capability fit, and long-term maintainability."

### For comparing two implementations:

Replace Steps 2-4 with:
```
**Step 2 — Evaluate Option A:**
Strengths and weaknesses.

**Step 3 — Evaluate Option B:**
Strengths and weaknesses.

**Step 4 — Compare directly:**
Which is better for this use case and why? What are the key differentiators?
```

## Example

**User:** "Is this a good way to handle JWT authentication in Express?"

**Prompt to pass to agent:**
```
You are performing a technical review. Work through this step by step:

**Step 1 — Understand the subject:**
This is Express.js middleware for JWT authentication. The goal is to protect API routes by verifying JWT tokens on each request.

**Step 2 — Evaluate strengths:**
What does this middleware do correctly? Is the token verification logic sound?

**Step 3 — Identify weaknesses:**
Check for: token storage risks, missing expiry validation, algorithm confusion attacks, missing error handling cases, information leakage in error responses, and performance concerns.

**Step 4 — Consider alternatives:**
Are there better patterns or libraries (passport-jwt, express-jwt) for this use case?

**Step 5 — Give a verdict:**
Approve as-is / Approve with changes / Reconsider. List the top issues to fix.

**Subject for review:**
[user's middleware code]

**Context:**
- Goal: Protect Express API routes with JWT auth
- Tech stack: Node.js, Express, jsonwebtoken
- Constraints: Production API handling user data
```
