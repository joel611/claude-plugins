# Code Analyzer Skill

## Purpose

Analyze large codebases using Gemini's 1M token context window through the gemini-code-analyzer subagent. This skill handles pattern detection, code quality analysis, architecture understanding, and comprehensive codebase exploration by spawning a specialized subagent that wraps gemini-cli.

## When to Use This Skill

Use this skill when you need to:
- Detect patterns across large codebases (React hooks, database queries, API patterns)
- Analyze code quality (performance bottlenecks, security vulnerabilities, code smells)
- Understand codebase architecture (component hierarchies, data flow, dependencies)
- Trace feature implementations across multiple files
- Map out the technology stack and testing strategies
- Find legacy patterns or consistency issues for refactoring
- Generate onboarding documentation from code analysis

Do NOT use this skill when:
- Working with small, focused code snippets (use Read tool instead)
- You need real-time web research (use web-researcher skill)
- The task doesn't require comprehensive codebase analysis

## Prerequisites

Before using this skill:
1. **gemini-cli must be installed**: `npm install -g @anthropic/gemini-cli`
2. **gemini-cli must be configured**: With valid API credentials
3. **Access to the codebase**: Ensure gemini-cli can access the project files
4. **Clear analysis goals**: Know what patterns or insights you're looking for

To verify gemini-cli is installed:
```bash
gemini --version
```

## Instructions

### Step 1: Understand the Analysis Request

Identify what type of analysis is needed:
- **Pattern Detection**: Finding specific code patterns (hooks, queries, components)
- **Architecture**: Understanding system structure and relationships
- **Code Quality**: Identifying issues, vulnerabilities, technical debt
- **Technology Stack**: Analyzing dependencies, testing, tooling
- **Feature Tracing**: Following implementation across files
- **Refactoring**: Finding inconsistencies or legacy patterns
- **Documentation**: Generating insights for onboarding

### Step 2: Gather Context

Collect relevant information about:
- **Codebase location**: Current working directory or specific path
- **Technology stack**: Languages, frameworks, tools being used
- **Specific focus areas**: Particular files, directories, or patterns
- **Analysis constraints**: What to include or exclude
- **Expected output format**: How results should be structured

### Step 3: Spawn the Gemini Code Analyzer Subagent

Use the Task tool to spawn the gemini-code-analyzer subagent with a detailed prompt.

**Template:**
```
Use the Task tool with:
- subagent_type: "gemini-code-analyzer"
- description: "[Brief 3-5 word description]"
- prompt: "[Detailed analysis request with context]"
```

**Your prompt should include:**
1. **Context**: What codebase/project is being analyzed
2. **Analysis type**: Which category from Step 1
3. **Specific request**: Exactly what to analyze
4. **Output format**: How to structure the results (list, table, hierarchy, etc.)
5. **Working directory**: Current path if relevant

### Step 4: Provide Comprehensive Context to the Subagent

The subagent needs detailed context to construct effective gemini-cli commands. Include:

**Codebase Information:**
- Project type (web app, API, library, etc.)
- Tech stack (React, Node.js, Python, etc.)
- Project structure overview (if known)
- Current working directory

**Analysis Specifics:**
- What patterns to look for
- Which files/directories to focus on
- Any known issues or areas of concern
- Desired level of detail

**Example Prompt to Subagent:**
```
I need to analyze the React codebase in /Users/joel/my-project for hook usage patterns.

Context:
- This is a Next.js 14 application using the App Router
- Located in: /Users/joel/my-project
- Focus on the app/ and components/ directories
- We're particularly interested in custom hooks

Task:
Analyze all React hooks usage in this codebase. For each hook found:
1. List the hook type (useState, useEffect, custom hooks, etc.)
2. Show where it's used (file paths and approximate line numbers)
3. Identify any custom hooks and their purpose
4. Note any potential issues (missing dependencies, excessive re-renders)

Run gemini-cli with appropriate flags and return the raw output.
```

### Step 5: Process Subagent Results

Once the subagent returns gemini-cli output:

1. **Review the raw results**: The subagent returns uninterpreted gemini output
2. **Interpret findings**: Analyze what gemini found
3. **Summarize for the user**: Create a clear, actionable summary
4. **Provide specific file references**: Include file paths and line numbers
5. **Suggest next steps**: Recommend actions based on findings

### Step 6: Follow Up If Needed

If the initial analysis needs refinement:
- Spawn the subagent again with a more focused request
- Ask for deeper analysis of specific areas
- Request additional context from gemini
- Cross-reference findings with code reads

## Examples

### Example 1: Finding React Hooks Patterns

**User Request:** "Find all React hooks in the codebase and identify any issues"

**Step 1 - Identify**: Pattern Detection analysis

**Step 2 - Gather Context:**
- Codebase: React/Next.js application
- Location: /Users/joel/my-app
- Focus: All .tsx and .jsx files
- Looking for: hooks usage and potential issues

**Step 3 - Spawn Subagent:**

```
Task tool with subagent_type: "gemini-code-analyzer"

Prompt:
"Analyze the React codebase at /Users/joel/my-app for hooks usage patterns.

Context:
- Next.js 14 application with App Router
- TypeScript-based React components
- Focus on all .tsx files in app/ and components/ directories

Analysis Request:
Find all React hooks usage in this codebase and analyze them:

1. Built-in hooks (useState, useEffect, useContext, etc.):
   - Count usage of each hook type
   - Identify the most commonly used hooks

2. Custom hooks:
   - List all custom hooks defined
   - Show where each custom hook is used
   - Describe each custom hook's purpose

3. Potential issues:
   - Missing dependencies in useEffect
   - Hooks called conditionally or in loops
   - Excessive re-renders from state updates
   - Complex hook chains that could be simplified

Output format:
Provide a structured report with file paths and approximate line numbers for each finding.

Run: gemini --all-files --yolo -p with the above analysis prompt
Return the raw gemini output."
```

**Step 5 - Process Results:**
```
Based on gemini's analysis, here's what I found:

## Hooks Usage Summary

### Built-in Hooks
- useState: 47 instances across 23 components
- useEffect: 31 instances across 18 components
- useContext: 12 instances (AuthContext, ThemeContext)
- useCallback: 8 instances
- useMemo: 5 instances

### Custom Hooks (4 found)
1. `useAuth` (hooks/useAuth.ts:12) - Used in 8 components
2. `useLocalStorage` (hooks/useLocalStorage.ts:8) - Used in 3 components
3. `useDebounce` (hooks/useDebounce.ts:5) - Used in 2 components
4. `useFetch` (hooks/useFetch.ts:15) - Used in 6 components

### Issues Identified
⚠️ Missing dependencies in components/Dashboard.tsx:45
⚠️ Conditional hook call in components/UserProfile.tsx:78
⚠️ Potential re-render issue in components/ProductList.tsx:92

Next steps:
1. Fix the missing dependencies in Dashboard component
2. Refactor conditional hook usage in UserProfile
3. Consider memoization in ProductList to reduce re-renders
```

### Example 2: Architecture Analysis

**User Request:** "I need to understand the authentication flow in this application"

**Spawn Subagent:**
```
Task tool with subagent_type: "gemini-code-analyzer"

Prompt:
"Analyze the authentication flow in the codebase at /Users/joel/my-app.

Context:
- Next.js application with API routes
- Using JWT for authentication
- Has both client and server-side auth checks

Analysis Request:
Trace the complete authentication flow through this application:

1. Authentication Entry Points:
   - Where does login/signup happen? (UI components, API routes)
   - What authentication methods are supported?

2. Token Management:
   - How are JWT tokens created?
   - Where are tokens stored? (cookies, localStorage, etc.)
   - How are tokens validated?

3. Protected Routes:
   - Which routes require authentication?
   - How are auth checks implemented (middleware, HOCs, etc.)?
   - Where are unauthorized users redirected?

4. Session Management:
   - How are sessions maintained?
   - What's the token refresh mechanism?
   - How does logout work?

5. Data Flow:
   - Map the complete flow from login button click to authenticated state
   - Show all components and functions involved
   - Include file paths for each step

Run: gemini --all-files --yolo -p with the above prompt
Return the raw output."
```

### Example 3: Security Vulnerability Scan

**User Request:** "Check the codebase for security vulnerabilities"

**Spawn Subagent:**
```
Task tool with subagent_type: "gemini-code-analyzer"

Prompt:
"Perform a security audit on the codebase at /Users/joel/my-app.

Context:
- Node.js/Express API backend
- React frontend
- PostgreSQL database
- Handles user data and payments

Security Analysis:
Audit the codebase for common security vulnerabilities:

1. Injection Vulnerabilities:
   - SQL injection risks (raw queries, dynamic SQL)
   - NoSQL injection risks
   - Command injection possibilities

2. XSS (Cross-Site Scripting):
   - Unsanitized user input rendering
   - Dangerous use of dangerouslySetInnerHTML
   - Unsafe DOM manipulation

3. Authentication & Authorization:
   - Weak password policies
   - Insecure token storage
   - Missing authorization checks
   - Session management issues

4. Sensitive Data Exposure:
   - Hardcoded secrets or API keys
   - Logging sensitive information
   - Unencrypted data transmission

5. API Security:
   - Missing rate limiting
   - CORS misconfigurations
   - Unvalidated input
   - Missing CSRF protection

For each finding:
- Severity level (Critical, High, Medium, Low)
- File path and location
- Description of the vulnerability
- Potential impact
- Recommended fix

Run: gemini --all-files --yolo -p with security analysis
Return raw output."
```

### Example 4: Performance Bottleneck Detection

**User Request:** "Find performance issues in the React application"

**Spawn Subagent:**
```
Task tool with subagent_type: "gemini-code-analyzer"

Prompt:
"Analyze performance bottlenecks in the React application at /Users/joel/my-app.

Context:
- React 18 with Next.js 14
- Large component tree (~100 components)
- User reports slow rendering

Performance Analysis:
Identify performance bottlenecks in this application:

1. Re-render Issues:
   - Components that re-render unnecessarily
   - Missing React.memo optimizations
   - Inefficient state updates
   - Context API performance issues

2. Bundle Size:
   - Large imported libraries
   - Unused dependencies
   - Missing code splitting
   - Opportunities for lazy loading

3. Data Fetching:
   - Sequential API calls that could be parallel
   - Missing caching strategies
   - Over-fetching data
   - N+1 query patterns

4. Expensive Operations:
   - Complex calculations in render
   - Missing useMemo/useCallback
   - Large list rendering without virtualization
   - Unoptimized images

5. Next.js Specific:
   - Improper use of Server/Client Components
   - Missing static generation opportunities
   - Inefficient data fetching patterns

For each issue found:
- File path and location
- Description of the problem
- Performance impact (estimated)
- Recommended optimization
- Code example if applicable

Run: gemini --all-files --yolo -p with performance analysis
Return raw output."
```

## Best Practices

### Providing Context
1. **Be specific about the codebase**: Include tech stack, project type, and location
2. **Define clear analysis goals**: Tell gemini exactly what to look for
3. **Request structured output**: Ask for organized results (tables, lists, hierarchies)
4. **Include file path requests**: Always ask gemini to include locations
5. **Set scope appropriately**: Focus on relevant directories when possible

### Working with Subagent Results
1. **Trust the subagent**: It's designed to use gemini-cli correctly
2. **Interpret raw output**: The subagent returns unprocessed gemini results
3. **Validate findings**: Cross-check important findings with code reads
4. **Provide summaries**: Translate gemini's analysis into actionable insights
5. **Iterate as needed**: Don't hesitate to spawn the subagent again for deeper analysis

### Optimizing Analysis
1. **Use --all-files**: For comprehensive analysis across the entire codebase
2. **Be specific in prompts**: Clear prompts yield better gemini results
3. **Request examples**: Ask gemini to provide code examples in findings
4. **Ask for severity levels**: For issues, request prioritization
5. **Combine with code reads**: Use Read tool for detailed examination of specific findings

### Handling Large Codebases
1. **Leverage Gemini's 1M tokens**: Perfect for analyzing large projects
2. **Start broad, then narrow**: Get overview first, then deep dive
3. **Focus on patterns**: Look for patterns rather than individual instances
4. **Use interactive mode**: For complex multi-step analysis
5. **Save token budget**: Use gemini for broad analysis, Read for specific files

## Common Issues and Solutions

### Issue 1: Subagent Returns "gemini-cli not found"
**Problem:** gemini-cli is not installed or not in PATH

**Solutions:**
- Install gemini-cli: `npm install -g @anthropic/gemini-cli`
- Verify installation: `gemini --version`
- Check PATH configuration
- Provide installation instructions to user

### Issue 2: Analysis Too Broad/Vague
**Problem:** Gemini returns generic or unfocused results

**Solutions:**
- Provide more specific context in the prompt
- Narrow the scope to specific directories or file types
- Ask for concrete examples rather than general descriptions
- Include specific patterns or issues to look for
- Request structured output format

### Issue 3: Missing File Paths in Results
**Problem:** Gemini's analysis doesn't include file locations

**Solutions:**
- Explicitly request file paths in the prompt
- Ask for line numbers or code snippets
- Request "specific locations" for each finding
- Use phrasing like "include file paths for all findings"

### Issue 4: Analysis Takes Too Long
**Problem:** gemini-cli takes a very long time to respond

**Solutions:**
- Reduce scope to specific directories
- Focus on particular file types (e.g., only .tsx files)
- Break analysis into smaller chunks
- Use multiple targeted prompts instead of one comprehensive request
- Check if --all-files is necessary for the specific task

### Issue 5: Subagent Misunderstands Request
**Problem:** Results don't match what was requested

**Solutions:**
- Review the prompt for clarity
- Add more context about the codebase
- Be explicit about desired output format
- Provide examples of what you're looking for
- Break complex requests into simpler sub-requests
- Spawn subagent again with refined prompt

### Issue 6: Need to Combine Multiple Analysis Types
**Problem:** Request requires multiple types of analysis

**Solutions:**
- Spawn subagent multiple times for different analysis types
- Create comprehensive prompts that combine related analyses
- Use interactive mode for multi-step analysis
- Prioritize analyses and run sequentially
- Aggregate results from multiple subagent runs

## Advanced Usage

### Multi-Step Analysis
For complex analysis requiring multiple phases:

1. **Phase 1 - Discovery**: Spawn subagent to find relevant areas
2. **Phase 2 - Deep Dive**: Spawn again focusing on findings from Phase 1
3. **Phase 3 - Validation**: Use Read tool to verify specific findings
4. **Phase 4 - Summary**: Compile results into actionable report

### Combining with Other Tools
- Use **Read** to examine specific files from gemini findings
- Use **Grep** to find additional instances of patterns discovered
- Use **Bash** to run tests or linters on identified issues
- Use **web-researcher skill** to find solutions for identified problems

### Custom Analysis Workflows
Create specialized analysis workflows:

**Security Audit Workflow:**
1. Spawn code-analyzer for vulnerability scan
2. Prioritize findings by severity
3. Read specific vulnerable files
4. Spawn web-researcher for fix recommendations
5. Apply fixes and validate

**Performance Optimization Workflow:**
1. Spawn code-analyzer for bottleneck detection
2. Measure current performance (Bash for benchmarks)
3. Read problem areas in detail
4. Research optimization techniques (web-researcher)
5. Implement optimizations
6. Re-analyze for improvements

**Refactoring Planning Workflow:**
1. Spawn code-analyzer for legacy pattern detection
2. Map out affected areas
3. Research modern alternatives (web-researcher)
4. Plan refactoring in phases
5. Validate with targeted re-analysis

## Resources

The code-analyzer skill uses the gemini-code-analyzer agent, which:
- Wraps gemini-cli for code analysis
- Uses --all-files --yolo flags for comprehensive analysis
- Returns raw gemini output without interpretation
- Supports all analysis categories listed in this skill

For more information:
- gemini-cli documentation: https://github.com/anthropics/gemini-cli
- Agent definition: `plugins/analysis/gemini-research/agents/code-analyzer.md`
- Related skill: web-researcher for finding solutions and documentation
