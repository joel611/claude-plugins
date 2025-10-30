# Fix Flaky Test Command

## Description

Analyze and fix flaky (intermittently failing) Playwright tests. Identifies race conditions, improves waiting strategies, and ensures test stability.

## Usage

```
/fix-flaky [test-name]
```

## Parameters

- `test-name` - Name or path of the flaky test (required)

## Examples

```
/fix-flaky dashboard.spec.ts
```

```
/fix-flaky "should load user profile"
```

```
/fix-flaky tests/checkout.spec.ts:42
```

## Instructions for Claude

When this command is invoked:

1. **Invoke the test-debugger and test-maintainer skills** for analysis

2. **Gather information**:
   - Test file and name
   - Failure pattern (how often it fails)
   - Error messages when it fails
   - Environment (local vs CI)
   - Which step usually fails

3. **Identify flakiness causes**:
   - Race conditions
   - Missing waits
   - Hardcoded timeouts
   - Network dependencies
   - Test isolation issues
   - Environment differences

4. **Common fixes**:
   - Add explicit waits before interactions
   - Replace waitForTimeout() with proper waits
   - Wait for network to settle
   - Wait for specific API responses
   - Increase timeouts for slow operations
   - Improve test isolation
   - Add retry configuration

5. **Apply improvements**:
   - Update test code
   - Add proper waits
   - Fix race conditions
   - Ensure test isolation
   - Configure retries if needed

6. **Verify stability**:
   - Run test multiple times (10+ times)
   - Test in different environments
   - Check in CI environment
   - Monitor for continued flakiness

## Error Handling

- If test not found, ask for correct path
- If can't reproduce failure, ask for more details
- If multiple issues, fix most impactful first
- Warn if test design is fundamentally flaky

## Notes

- Flakiness is usually caused by timing issues
- Never use waitForTimeout() - use explicit waits
- Wait for network/animations to complete
- Ensure tests are isolated and don't share state
- Run tests 10+ times to verify fix
- Consider enabling retries for legitimately slow operations
