# Debug Test Command

## Description

Debug a failing Playwright test by analyzing error messages, screenshots, and traces. Provides actionable solutions for common test failures including timeouts, selector issues, and race conditions.

## Usage

```
/debug-test [test-name-or-error]
```

## Parameters

- `test-name-or-error` - Test name, file path, or error message (optional)

## Examples

```
/debug-test login.spec.ts
```

```
/debug-test TimeoutError: waiting for selector
```

```
/debug-test Test "user dashboard loads" is flaky
```

## Instructions for Claude

When this command is invoked:

1. **Invoke the test-debugger skill** to handle debugging

2. **Gather failure information**:
   - Error message and stack trace
   - Test file location
   - Expected vs actual behavior
   - Screenshots/traces if available
   - Failure frequency (always or intermittent)

3. **Analyze the error**:
   - Identify error type (timeout, selector, assertion, etc.)
   - Determine root cause
   - Check for common issues (missing waits, wrong testid, race conditions)

4. **Optionally use Playwright MCP**:
   - Navigate to the page if needed
   - Inspect element state
   - Test locator strategies
   - Verify data-testid values

5. **Provide solution**:
   - Explain what's wrong
   - Show the fix with code examples
   - Explain how to prevent in future
   - Provide verification steps

6. **Apply the fix if requested**:
   - Update the test code
   - Add missing waits
   - Fix locators
   - Improve test stability

## Error Handling

- If insufficient information, ask for error details
- If test file not found, ask for correct path
- If error is unclear, use MCP to investigate
- If multiple issues, prioritize and fix one at a time

## Notes

- Most test failures are timing-related
- Always verify data-testid values are correct
- Use explicit waits, not hardcoded timeouts
- Check test isolation if flaky
- Run tests multiple times to verify fix
