---
name: gemini-web-researcher
description: Uses Gemini CLI to perform web research for technical documentation, solutions, library comparisons, and best practices. Activate when the user needs to find latest documentation, research solutions to technical problems, compare libraries or frameworks, look up API/SDK documentation, or find current information.
version: 2.0.0
---

# Gemini Web Researcher Skill

## Purpose

Offload web research to Gemini CLI. Build a single structured prompt that guides Gemini through the full research process — Gemini handles gathering, evaluating, synthesizing, and presenting information. Claude's only job is to construct the right prompt and pass it to the agent.

## Prerequisites

- `gemini-cli` installed: `npm install -g @google/gemini-cli`
- Valid Gemini API credentials configured
- Verify: `gemini --version`

## How to Use This Skill

1. Identify what the user needs researched and gather context (tech stack, version, constraints)
2. Build a structured prompt using the template below
3. Spawn the `gemini-web-researcher` agent via Task tool with that prompt
4. Present Gemini's response to the user as-is

## Prompt Template

```
You are a technical researcher. Work through this step by step:

**Step 1 — Understand the question:**
What specifically is being asked? What context and constraints apply? What would a useful answer look like?

**Step 2 — Research:**
Search for current, authoritative information. Prioritize: official documentation, recent release notes, authoritative technical blogs. Look for information dated [current year] or the most recent available.

**Step 3 — Evaluate:**
For each source: assess its currency, authority, and relevance. Note any conflicting recommendations between sources.

**Step 4 — Synthesize:**
Combine findings into a coherent answer. Resolve conflicts by preferring the most recent authoritative source.

**Step 5 — Present:**
[Insert output format from list below]

**Question:** [Restate the user's exact research question]
**Tech stack:** [Languages, frameworks, versions the user is working with]
**Constraints:** [Version requirements, compatibility needs, team size, scale — whatever the user mentioned]
```

## Step 5 Output Format by Research Type

Replace the Step 5 presentation instruction with the appropriate format:

**Documentation Lookup:**
```
Present: direct answer, link to official documentation, key concepts explained, and a minimal working example if applicable.
```

**Solution Research** (fixing errors, implementing features):
```
Present: the root cause, step-by-step solution, code example, links to relevant documentation, and common pitfalls to avoid.
```

**Technology Comparison:**
```
Present: a comparison table covering [criteria the user cares about], pros and cons of each option, and a clear recommendation with reasoning based on the user's context.
```

**API / SDK Research:**
```
Present: key capabilities, authentication setup, the most common usage patterns with code examples, links to official reference docs, and known limitations or gotchas.
```

**Updates / Migration:**
```
Present: what changed (new features, breaking changes), the official migration path, common issues encountered during migration, and links to the changelog and migration guide.
```

**Best Practices / Patterns:**
```
Present: the recommended approach, why it's preferred over alternatives, a concrete implementation example, and links to authoritative sources.
```

**Security Research:**
```
Present: the threat model, recommended mitigations with code examples, common mistakes to avoid, and links to official security guidance.
```

## Example

**User:** "Should I use Prisma or Drizzle ORM for a new Next.js project with PostgreSQL?"

**Prompt to pass to agent:**
```
You are a technical researcher. Work through this step by step:

**Step 1 — Understand the question:**
Compare Prisma vs Drizzle ORM for a Next.js project using PostgreSQL. The user needs a concrete recommendation.

**Step 2 — Research:**
Find current information on both ORMs: features, performance, developer experience, ecosystem maturity, community adoption, and Next.js compatibility. Focus on information from 2024 or most recent available.

**Step 3 — Evaluate:**
Assess each source for currency and authority. Note where community sentiment differs from official positioning.

**Step 4 — Synthesize:**
Identify the clearest differentiators. Determine which is better suited for a new project with a team that may have varying SQL experience.

**Step 5 — Present:**
A comparison table covering: type safety, query API, migrations, bundle size, serverless performance, learning curve, and ecosystem. Then a clear recommendation with reasoning. Include links to official docs for both.

**Question:** Prisma vs Drizzle ORM for Next.js with PostgreSQL
**Tech stack:** Next.js 14, PostgreSQL, TypeScript
**Constraints:** New project, team of 3, varying SQL experience
```
