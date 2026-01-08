# Web Researcher Skill

## Purpose

Perform comprehensive web research for technical documentation, solutions, and technology comparisons using Gemini's web access capabilities through the gemini-web-researcher subagent. This skill finds current documentation, researches best practices, compares technologies, and gathers technical information by spawning a specialized subagent that wraps gemini-cli.

## When to Use This Skill

Use this skill when you need to:
- Find latest documentation for libraries, frameworks, or APIs
- Research solutions to technical problems and troubleshooting
- Compare technologies, libraries, frameworks, or approaches
- Look up best practices and current recommendations
- Understand third-party APIs and SDKs
- Research security patterns and vulnerability mitigations
- Find performance optimization techniques
- Stay updated on framework/tool changes and migrations

Do NOT use this skill when:
- Information is already in the codebase (use Read tool or code-analyzer skill)
- You need to analyze code patterns (use code-analyzer skill)
- The question can be answered from your training data
- Real-time information isn't necessary

## Prerequisites

Before using this skill:
1. **gemini-cli must be installed**: `npm install -g @anthropic/gemini-cli`
2. **gemini-cli must be configured**: With valid API credentials and web access
3. **Clear research goals**: Know what information you're looking for
4. **Context about the problem**: Understand why this research is needed

To verify gemini-cli is installed:
```bash
gemini --version
```

## Instructions

### Step 1: Understand the Research Request

Identify what type of research is needed:
- **Documentation Lookup**: Finding official docs, API references, guides
- **Solution Research**: Finding fixes, workarounds, best practices
- **Technology Comparison**: Evaluating different options and trade-offs
- **API/SDK Research**: Understanding third-party integrations
- **Updates & Migrations**: Learning about new features and changes
- **Architecture Patterns**: Researching design patterns and approaches
- **Security Research**: Finding security best practices and mitigations
- **Performance**: Researching optimization techniques

### Step 2: Gather Context

Collect relevant information:
- **Current tech stack**: What technologies are being used
- **Specific problem**: What issue needs solving or information needed
- **Constraints**: Version requirements, compatibility needs, limitations
- **Use case**: How the information will be applied
- **Urgency**: Whether latest/cutting-edge info is needed

### Step 3: Spawn the Gemini Web Researcher Subagent

Use the Task tool to spawn the gemini-web-researcher subagent with a detailed research request.

**Template:**
```
Use the Task tool with:
- subagent_type: "gemini-web-researcher"
- description: "[Brief 3-5 word description]"
- prompt: "[Detailed research request with context]"
```

**Your prompt should include:**
1. **Context**: What project/problem this research is for
2. **Research type**: Which category from Step 1
3. **Specific question**: Exactly what to research
4. **Information needed**: What details are important
5. **Current year/relevance**: Request current/recent information
6. **Output format**: How to structure the results

### Step 4: Provide Comprehensive Context to the Subagent

The subagent needs detailed context to construct effective research prompts. Include:

**Project Context:**
- Technology stack being used
- Current implementation or approach
- Version numbers if relevant
- Scale or complexity of the project

**Research Specifics:**
- Exact question or problem to research
- Why this information is needed
- How it will be applied
- Any specific requirements or constraints

**Desired Output:**
- Links to official documentation
- Code examples if applicable
- Comparison tables for evaluations
- Step-by-step guides for implementations
- Current best practices and recommendations

**Example Prompt to Subagent:**
```
I need to research authentication solutions for a Next.js 14 application.

Context:
- Next.js 14 App Router application
- Need user authentication with email/password and OAuth
- Planning to use PostgreSQL for user data
- Must support session management and protected routes

Research Request:
Find current best practices and solutions for implementing authentication in Next.js 14 applications. Specifically research:

1. Authentication Libraries:
   - Compare NextAuth.js, Clerk, Supabase Auth, and Lucia
   - Pros and cons of each
   - Which works best with Next.js 14 App Router

2. Implementation Patterns:
   - How to protect routes in App Router
   - Session management approaches
   - Token storage best practices

3. OAuth Integration:
   - Setting up Google and GitHub OAuth
   - Recommended providers

4. Security Considerations:
   - CSRF protection
   - Secure token handling
   - Best practices for 2024

Please include:
- Links to official documentation
- Code examples where relevant
- Current recommendations (2024)
- Migration guides if applicable

Run gemini-cli with appropriate research prompt and return the raw output.
```

### Step 5: Process Subagent Results

Once the subagent returns gemini research results:

1. **Review the raw findings**: The subagent returns uninterpreted gemini output
2. **Extract key information**: Pull out relevant documentation, solutions, comparisons
3. **Summarize for the user**: Create a clear, actionable summary
4. **Provide links**: Include all documentation links found
5. **Make recommendations**: Suggest best approaches based on research
6. **Identify next steps**: What should be done with this information

### Step 6: Follow Up If Needed

If the initial research needs more detail:
- Spawn the subagent again with a more focused request
- Research specific aspects in more depth
- Compare specific options more thoroughly
- Find additional examples or use cases

## Examples

### Example 1: Documentation Lookup

**User Request:** "How do I use React Server Components in Next.js 14?"

**Step 1 - Identify**: Documentation Lookup

**Step 2 - Gather Context:**
- Tech: Next.js 14 with React
- Need: Understanding Server Components
- Use case: Building new features correctly

**Step 3 - Spawn Subagent:**

```
Task tool with subagent_type: "gemini-web-researcher"

Prompt:
"Research React Server Components in Next.js 14.

Context:
- Next.js 14 application using App Router
- Need to understand Server Components vs Client Components
- Want to use this for building new features

Research Request:
Find the latest Next.js 14 documentation on React Server Components. Include:

1. Core Concepts:
   - What are Server Components?
   - Server vs Client Components differences
   - When to use each type

2. Implementation:
   - How to create Server Components
   - How to mark Client Components ('use client')
   - Data fetching in Server Components
   - Passing props between Server and Client Components

3. Best Practices:
   - Component composition patterns
   - Common pitfalls to avoid
   - Performance considerations

4. Examples:
   - Code examples of Server Components
   - Common patterns (layouts, data fetching, etc.)
   - Real-world use cases

Please provide:
- Links to official Next.js documentation
- Code examples
- Best practices for 2024
- Any recent updates or changes

Run: gemini -p with this research request
Return the raw gemini output."
```

**Step 5 - Process Results:**
```
Based on gemini's research, here's what I found:

## React Server Components in Next.js 14

### Official Documentation
- Next.js Server Components: https://nextjs.org/docs/app/building-your-application/rendering/server-components
- React Server Components RFC: https://github.com/reactjs/rfcs/blob/main/text/0188-server-components.md

### Key Concepts

**Server Components (Default in App Router):**
- Run on the server only
- Can directly access backend resources (databases, file system)
- Don't send JavaScript to the client
- Cannot use hooks or browser APIs

**Client Components ('use client'):**
- Run on both server (for SSR) and client
- Can use hooks and browser APIs
- Required for interactivity
- Add JavaScript bundle to client

### When to Use Each

Use Server Components for:
✓ Data fetching from databases/APIs
✓ Accessing backend resources
✓ Keeping sensitive data on server
✓ Reducing client-side JavaScript

Use Client Components for:
✓ Interactive elements (onClick, onChange)
✓ Using React hooks (useState, useEffect)
✓ Browser APIs (localStorage, geolocation)
✓ Third-party libraries requiring browser

### Implementation Example

Server Component (default):
\`\`\`tsx
// app/products/page.tsx
async function ProductsPage() {
  // Direct database access - runs on server
  const products = await db.products.findMany();

  return (
    <div>
      {products.map(product => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  );
}
\`\`\`

Client Component:
\`\`\`tsx
// components/AddToCart.tsx
'use client';

import { useState } from 'react';

export function AddToCart({ productId }: { productId: string }) {
  const [loading, setLoading] = useState(false);

  const handleClick = async () => {
    setLoading(true);
    await addToCart(productId);
    setLoading(false);
  };

  return (
    <button onClick={handleClick} disabled={loading}>
      Add to Cart
    </button>
  );
}
\`\`\`

### Best Practices
1. **Default to Server**: Use Server Components by default, only use 'use client' when needed
2. **Push Client Components down**: Keep interactivity at leaf nodes
3. **Fetch data where needed**: Server Components can fetch their own data
4. **Compose carefully**: Server Components can import Client Components, but not vice versa
5. **Avoid prop drilling**: Fetch data close to where it's used

Next step: Start using Server Components for data fetching and reserve Client Components for interactive elements.
```

### Example 2: Solution Research

**User Request:** "How can I fix hydration errors in my Next.js app?"

**Spawn Subagent:**
```
Task tool with subagent_type: "gemini-web-researcher"

Prompt:
"Research solutions for Next.js hydration errors.

Context:
- Next.js 14 application
- Getting hydration mismatch errors in production
- Need to understand causes and solutions

Research Request:
Find comprehensive information about fixing hydration errors in Next.js:

1. Common Causes:
   - What causes hydration mismatches?
   - Typical scenarios (dates, IDs, localStorage, etc.)
   - Why they happen

2. Debugging:
   - How to identify the source of hydration errors
   - Tools and techniques for debugging
   - Reading error messages

3. Solutions:
   - Fixes for date/time hydration issues
   - Handling localStorage and browser-only code
   - Fixing random ID generation
   - Third-party script issues
   - Conditional rendering problems

4. Prevention:
   - Best practices to avoid hydration errors
   - Patterns to use
   - Testing strategies

5. Next.js Specific:
   - suppressHydrationWarning usage
   - useEffect patterns
   - Dynamic imports with { ssr: false }

Include:
- Official Next.js documentation links
- Stack Overflow solutions
- Code examples for each scenario
- Current best practices (2024)

Run: gemini -p with this research
Return raw output."
```

### Example 3: Technology Comparison

**User Request:** "Should I use Prisma or Drizzle ORM for my new project?"

**Spawn Subagent:**
```
Task tool with subagent_type: "gemini-web-researcher"

Prompt:
"Compare Prisma and Drizzle ORM for a new TypeScript project.

Context:
- Building a new Next.js application
- PostgreSQL database
- TypeScript-first development
- Team of 3 developers with varying SQL experience

Research Request:
Provide a comprehensive comparison of Prisma vs Drizzle ORM:

1. Features:
   - Type safety capabilities
   - Schema definition approaches
   - Migration systems
   - Query builders
   - Relation handling

2. Performance:
   - Query performance benchmarks
   - Bundle size impact
   - Cold start times (serverless)
   - Caching mechanisms

3. Developer Experience:
   - Learning curve
   - Documentation quality
   - IDE support
   - Debugging experience
   - Community and ecosystem

4. Use Cases:
   - When to use Prisma
   - When to use Drizzle
   - Hybrid approaches

5. Trade-offs:
   - Pros and cons of each
   - Deal breakers or limitations
   - Migration difficulty if switching later

6. Current State (2024):
   - Maturity and stability
   - Active development
   - Community adoption trends
   - Recent updates

Please include:
- Links to official documentation
- Benchmark comparisons if available
- Real-world use case examples
- Expert recommendations
- Community sentiment

Create a comparison table and provide a recommendation based on the context.

Run: gemini -p with comparison research
Return raw output."
```

### Example 4: API Integration Research

**User Request:** "How do I integrate Stripe subscriptions into my app?"

**Spawn Subagent:**
```
Task tool with subagent_type: "gemini-web-researcher"

Prompt:
"Research Stripe subscription integration for a Next.js application.

Context:
- Next.js 14 with App Router
- Need to implement subscription billing
- SaaS application with multiple pricing tiers
- PostgreSQL database for user data

Research Request:
Find comprehensive information about implementing Stripe subscriptions:

1. Setup and Configuration:
   - Stripe account setup
   - API keys management
   - Webhook configuration
   - Test mode vs production

2. Subscription Creation:
   - Creating subscription products and prices
   - Implementing checkout flow
   - Payment method collection
   - Customer creation

3. Subscription Management:
   - Handling billing cycles
   - Managing pricing tiers
   - Upgrades and downgrades
   - Cancellations and pauses

4. Webhooks:
   - Essential webhooks for subscriptions
   - Webhook signature verification
   - Handling subscription events
   - Error handling and retries

5. Customer Portal:
   - Implementing customer billing portal
   - Self-service subscription management
   - Invoice access

6. Next.js Integration:
   - Recommended libraries (@stripe/stripe-js)
   - API route implementation
   - Server Actions for Stripe operations
   - Security best practices

7. Testing:
   - Test cards and scenarios
   - Testing webhooks locally
   - Stripe CLI usage

Include:
- Official Stripe documentation links
- Next.js integration examples
- Complete code snippets
- Best practices for production
- Common pitfalls to avoid

Run: gemini -p with Stripe research
Return raw output."
```

## Best Practices

### Crafting Research Requests
1. **Be specific about tech stack**: Include versions, frameworks, languages
2. **Request current information**: Always ask for latest/2024 information
3. **Ask for links**: Request official documentation URLs
4. **Include context**: Explain the use case and constraints
5. **Specify output format**: Ask for tables, lists, examples as needed

### Working with Subagent Results
1. **Trust the subagent**: It's designed to use gemini-cli for research correctly
2. **Interpret findings**: The subagent returns raw gemini research output
3. **Verify critical info**: Double-check important technical details
4. **Provide summaries**: Distill research into actionable information
5. **Include links**: Always pass through documentation URLs to the user

### Optimizing Research
1. **Focus the question**: Narrow scope for better results
2. **Request examples**: Ask for code examples and use cases
3. **Ask for comparisons**: When evaluating options, request comparison tables
4. **Seek current info**: Emphasize need for recent/updated information
5. **Follow up intelligently**: Use initial research to inform follow-up questions

### Combining with Other Skills
1. **Research then implement**: Use web-researcher to find approaches, then code
2. **Research then analyze**: Find best practices, then use code-analyzer to audit codebase
3. **Iterative research**: Research broadly, then deeply on specific findings
4. **Validate with docs**: Cross-reference research results with official docs

## Common Issues and Solutions

### Issue 1: Subagent Returns "gemini-cli not found"
**Problem:** gemini-cli is not installed or not in PATH

**Solutions:**
- Install gemini-cli: `npm install -g @anthropic/gemini-cli`
- Verify installation: `gemini --version`
- Check PATH configuration
- Provide installation instructions to user

### Issue 2: Research Results Are Outdated
**Problem:** Gemini returns old information or deprecated approaches

**Solutions:**
- Explicitly request "latest" or "2024" information in prompt
- Ask for "current best practices"
- Request recent documentation
- Specify framework/library versions in the question
- Follow up with more specific date constraints

### Issue 3: Too Much General Information
**Problem:** Results are too broad or not actionable

**Solutions:**
- Make the research question more specific
- Include more context about the use case
- Request specific format (e.g., "step-by-step guide")
- Ask for code examples
- Narrow the scope to one aspect at a time

### Issue 4: Missing Code Examples
**Problem:** Research provides concepts but no practical examples

**Solutions:**
- Explicitly request "code examples" in the prompt
- Ask for "implementation examples"
- Request "working code snippets"
- Specify the language/framework for examples
- Ask for "real-world use cases with code"

### Issue 5: Comparison Doesn't Address Specific Needs
**Problem:** Technology comparison is generic, not tailored to use case

**Solutions:**
- Provide more detailed context about requirements
- Specify constraints (team size, experience, scale, budget)
- Ask for comparison on specific criteria
- Request "recommendation based on [specific context]"
- Include deal-breakers or must-have features

### Issue 6: Documentation Links Are Broken or Missing
**Problem:** No links provided or links don't work

**Solutions:**
- Explicitly request "official documentation links"
- Ask for "source URLs"
- Request "references to official docs"
- Follow up with specific request for links
- Search for official docs yourself as backup

## Advanced Usage

### Multi-Step Research
For complex research requiring multiple phases:

1. **Phase 1 - Broad Overview**: Research the general approach or technology
2. **Phase 2 - Specific Solutions**: Deep dive into chosen approach
3. **Phase 3 - Implementation Details**: Research specific integration steps
4. **Phase 4 - Best Practices**: Find optimization and production considerations

### Research Workflows

**New Technology Evaluation:**
1. Research what the technology is and its purpose
2. Compare with alternatives
3. Research integration steps
4. Find best practices and gotchas
5. Look for community sentiment and adoption

**Problem Solving Workflow:**
1. Research the problem/error message
2. Find common causes
3. Research solutions and workarounds
4. Find best practices to prevent recurrence
5. Look for related issues and edge cases

**API Integration Workflow:**
1. Research API documentation and capabilities
2. Find authentication and setup steps
3. Research common integration patterns
4. Find SDK/library recommendations
5. Research testing and debugging approaches

**Migration Planning Workflow:**
1. Research what's changed in new version
2. Find official migration guides
3. Research breaking changes and gotchas
4. Find community migration experiences
5. Research tools and helpers for migration

### Combining Research and Analysis

Use both skills together for comprehensive understanding:

**Audit and Improve Workflow:**
1. **code-analyzer**: Analyze current implementation
2. **web-researcher**: Research better approaches
3. **code-analyzer**: Find all places needing updates
4. **web-researcher**: Research specific migration steps
5. Implement improvements based on combined insights

**Learning Codebase Workflow:**
1. **code-analyzer**: Map out architecture and patterns
2. **web-researcher**: Research unfamiliar patterns found
3. **code-analyzer**: Find examples of pattern usage in codebase
4. **web-researcher**: Research best practices for those patterns
5. Document learnings for team

## Interactive Research Mode

For complex topics requiring iterative exploration, the subagent can use gemini's interactive mode:

**Example - Deep Technology Evaluation:**
```
Prompt to subagent:
"Use interactive mode (gemini -i) to research GraphQL vs REST for my use case.

Start by asking gemini about the high-level differences, then based on the response, ask follow-up questions about:
- Performance implications for my scale (1000 req/sec)
- Client complexity differences
- Caching strategies
- Real-time data handling

Conduct this as an interactive research session and return the complete conversation."
```

## Resources

The web-researcher skill uses the gemini-web-researcher agent, which:
- Wraps gemini-cli for web research
- Has access to current web information
- Returns raw gemini output without interpretation
- Supports all research categories listed in this skill

For more information:
- gemini-cli documentation: https://github.com/anthropics/gemini-cli
- Agent definition: `plugins/analysis/gemini-research/agents/web-researcher.md`
- Related skill: code-analyzer for analyzing codebases and patterns
