---
name: playwright-test-debugger
description: Debug failing Playwright E2E tests by analyzing error messages, stack traces, screenshots, and Playwright traces. Provides actionable solutions for common test failures including timeouts, selector issues, race conditions, and unexpected behaviors. Optionally uses Playwright MCP for live debugging.
---

## When to Use This Skill

Use this skill when you need to:

- Fix failing or flaky Playwright tests
- Understand why a test is timing out
- Debug element selector issues
- Analyze test traces and screenshots
- Resolve race conditions
- Investigate unexpected test behavior
- Use Playwright MCP to inspect live browser state

Do NOT use this skill when:

- Creating new tests (use test-generator skill)
- Building Page Objects (use page-object-builder skill)
- Refactoring test code (use test-maintainer skill)

## Prerequisites

Before using this skill:

1. Failing test file or error message
2. Test execution output or logs
3. Optional: Screenshots from test failure
4. Optional: Playwright trace file
5. Optional: Playwright MCP access for live debugging

## Instructions

### Step 1: Gather Failure Information

Ask the user for:

- **Error message** and stack trace
- **Test file** location and test name
- **Expected vs actual** behavior
- **Screenshots** (if available)
- **Trace file** path (if available)
- **Frequency**: Does it fail always or intermittently (flaky)?
- **Environment**: Local, CI, specific browser?

### Step 2: Analyze the Error

Identify the error type:

**Timeout Errors:**

- `Timeout 30000ms exceeded`
- `waiting for selector`
- `waiting for navigation`

**Selector Errors:**

- `Element not found`
- `strict mode violation`
- `No node found`

**Assertion Errors:**

- `Expected ... but received ...`
- `toBe`, `toContain`, `toBeVisible` failures

**Navigation Errors:**

- `Target closed`
- `Navigation failed`
- `ERR_CONNECTION_REFUSED`

**Race Conditions:**

- Intermittent failures
- Works locally but fails in CI
- Different results on different runs

### Step 3: Use Playwright MCP (Optional)

If Playwright MCP is available and needed:

- Use MCP tools to inspect browser state
- Navigate to the problematic page
- Check element visibility and attributes
- Verify data-testid values exist
- Test locator strategies
- Capture screenshots

### Step 4: Identify Root Cause

Common root causes:

**1. Missing or Wrong data-testid:**

- Element has different testid than expected
- testid doesn't exist in HTML
- Multiple elements with same testid

**2. Timing Issues:**

- Element not yet loaded when accessed
- No explicit wait before interaction
- Network requests still pending
- Animations or transitions in progress

**3. Element State:**

- Element exists but not visible
- Element disabled or not clickable
- Element covered by another element
- Element in different frame/iframe

**4. Test Isolation:**

- Tests depend on each other
- Shared state between tests
- Cleanup not performed
- Browser context pollution

**5. Environment Differences:**

- Different viewport sizes
- Different network speeds
- CI vs local differences
- Browser-specific issues

### Step 5: Provide Solution

For each root cause, provide:

1. **Explanation**: What's wrong
2. **Fix**: Code changes needed
3. **Prevention**: How to avoid in future
4. **Verification**: How to confirm it's fixed

### Step 6: Apply the Fix

**For Selector Issues:**

```typescript
// ❌ Before
await page.locator('[data-testid="wrong-id"]').click();

// ✅ After
await page.locator('[data-testid="correct-id"]').click();
```

**For Timeout Issues:**

```typescript
// ❌ Before
await page.locator('[data-testid="submit"]').click();

// ✅ After
await page.locator('[data-testid="submit"]').waitFor({ state: "visible" });
await page.locator('[data-testid="submit"]').click();
```

**For Race Conditions:**

```typescript
// ❌ Before
await page.locator('[data-testid="submit"]').click();
await expect(page.locator('[data-testid="result"]')).toBeVisible();

// ✅ After
await page.locator('[data-testid="submit"]').click();
await page.waitForLoadState("networkidle");
await expect(page.locator('[data-testid="result"]')).toBeVisible();
```

### Step 7: Verify the Fix

Guide the user to:

1. Run the test locally multiple times (3-5 times)
2. Check if error is resolved
3. Verify test passes consistently
4. Run related tests to ensure no regression
5. Consider running in CI if flakiness was CI-specific

## Examples

### Example 1: Timeout Error

**Input:**

```
Test failed with error:
TimeoutError: Timeout 30000ms exceeded.
=========================== logs ===========================
waiting for locator('[data-testid="submit-button"]')
```

**Analysis:**

- Timeout error waiting for element
- Element may not be loading
- Selector may be incorrect

**Solution:**

```typescript
// Check if the data-testid is correct in the HTML
// Add explicit wait with better error message
await page.locator('[data-testid="submit-button"]').waitFor({
  state: "visible",
  timeout: 30000,
});

// If still failing, verify element exists in DOM
const exists = await page.locator('[data-testid="submit-button"]').count();
console.log(`Submit button count: ${exists}`); // Should be 1

// Check if page has loaded
await page.waitForLoadState("domcontentloaded");

// Final solution
await page.waitForLoadState("domcontentloaded");
await page
  .locator('[data-testid="submit-button"]')
  .waitFor({ state: "visible" });
await page.locator('[data-testid="submit-button"]').click();
```

**Prevention:**

- Always add explicit waits before interactions
- Verify data-testid values in HTML
- Use `waitForLoadState` after navigation

### Example 2: Element Not Found

**Input:**

```
Error: Element not found
locator.click: Target closed
  locator('[data-testid="user-menu"]')
```

**Analysis:**

- Element may not exist in current page state
- Possible strict mode violation (multiple elements)
- Element may be in a different frame

**Solution:**

```typescript
// Step 1: Verify element exists
const count = await page.locator('[data-testid="user-menu"]').count();
console.log(`Found ${count} elements`);

// If count = 0: Element doesn't exist, check data-testid in HTML
// If count > 1: Multiple elements, need to be more specific

// Step 2: If multiple elements, use .first() or filter
await page.locator('[data-testid="user-menu"]').first().click();

// Step 3: If in iframe, switch to frame first
const frame = page.frameLocator('[data-testid="app-frame"]');
await frame.locator('[data-testid="user-menu"]').click();

// Step 4: Add proper wait
await page.locator('[data-testid="user-menu"]').waitFor({ state: "attached" });
await page.locator('[data-testid="user-menu"]').click();
```

**Prevention:**

- Ensure data-testid values are unique on the page
- Check for elements in frames/iframes
- Add waits before interaction

### Example 3: Flaky Test (Passes Sometimes)

**Input:**

```
Test fails intermittently:
- Passes 70% of the time locally
- Fails 90% of the time in CI
Error: expect(received).toContainText(expected)
Expected substring: "Success"
Received string: ""
```

**Analysis:**

- Classic race condition
- Element loads but content not yet populated
- Likely caused by async data fetching
- CI is slower so more likely to fail

**Solution:**

```typescript
// ❌ Before: No wait for content
await page.locator('[data-testid="submit"]').click();
await expect(page.locator('[data-testid="message"]')).toContainText("Success");

// ✅ After: Wait for specific condition
await page.locator('[data-testid="submit"]').click();

// Option 1: Wait for network to settle
await page.waitForLoadState("networkidle");
await expect(page.locator('[data-testid="message"]')).toContainText("Success");

// Option 2: Wait for specific API call
await Promise.all([
  page.waitForResponse("**/api/submit"),
  page.locator('[data-testid="submit"]').click(),
]);
await expect(page.locator('[data-testid="message"]')).toContainText("Success");

// Option 3: Use Playwright's auto-waiting in assertion
await page.locator('[data-testid="submit"]').click();
await expect(page.locator('[data-testid="message"]')).toContainText("Success", {
  timeout: 10000, // Explicit timeout for slow operations
});
```

**Prevention:**

- Wait for network requests to complete
- Use explicit timeouts for slow operations
- Run tests multiple times to catch flakiness
- Enable retries in playwright.config.ts

### Example 4: Assertion Failure

**Input:**

```
Error: expect(received).toBeVisible()
  locator('[data-testid="success-message"]')
  Expected: visible
  Received: hidden
```

**Analysis:**

- Element exists but is hidden
- May need to wait for element to appear
- Check if element has conditional visibility
- Verify test logic is correct

**Solution:**

```typescript
// Step 1: Verify element exists
const exists = await page.locator('[data-testid="success-message"]').count();
console.log(`Element count: ${exists}`);

// Step 2: Check element state
const isVisible = await page
  .locator('[data-testid="success-message"]')
  .isVisible();
console.log(`Is visible: ${isVisible}`);

// Step 3: Wait for visibility with timeout
await page.locator('[data-testid="success-message"]').waitFor({
  state: "visible",
  timeout: 10000,
});

// Step 4: If still not visible, check CSS
const display = await page
  .locator('[data-testid="success-message"]')
  .evaluate((el) => window.getComputedStyle(el).display);
console.log(`Display property: ${display}`);

// Step 5: Final solution
await page.locator('[data-testid="submit"]').click();
await page.waitForLoadState("networkidle");
await expect(page.locator('[data-testid="success-message"]')).toBeVisible({
  timeout: 10000,
});
```

**Prevention:**

- Add explicit waits for elements that appear after actions
- Verify success conditions in the application logic
- Use appropriate timeout values

### Example 5: Using Playwright MCP for Debugging

**Input:**
"My test is failing but I can't figure out why. The error says element not found but I see it in the screenshot."

**Solution (Using MCP):**

```
1. Use Playwright MCP to navigate to the page:
   - Navigate to the page where test fails
   - Take screenshot to verify page state

2. Use MCP to check if element exists:
   - Use MCP to find elements by data-testid
   - Check how many elements match
   - Inspect element attributes

3. Use MCP to test the locator:
   - Try different locator strategies
   - Check element visibility
   - Verify element is in correct frame

4. Based on MCP findings, update the test:
   - If element has different testid: Update locator
   - If element in iframe: Add frame handling
   - If multiple matches: Make locator more specific
```

## Best Practices

### Debugging Process

1. **Read error carefully**: Error messages are usually accurate
2. **Check test in isolation**: Run the single failing test
3. **Use debugging tools**: Screenshots, traces, MCP
4. **Add console logs**: Temporary logs to understand state
5. **Verify assumptions**: Check that data-testid values are correct
6. **Test incrementally**: Fix one issue at a time

### Common Debugging Techniques

1. **Add explicit waits**: Most failures are timing-related
2. **Check element count**: Verify unique selectors
3. **Use page.pause()**: Interactive debugging mode
4. **Enable headed mode**: See what's happening visually
5. **Slow motion**: Add `slowMo` in config to slow down actions
6. **Check traces**: Use Playwright trace viewer

### Preventing Future Issues

1. **Always use data-testid**: Stable locators
2. **Add explicit waits**: Don't rely on auto-waiting alone
3. **Test isolation**: Each test should be independent
4. **Proper cleanup**: Reset state between tests
5. **Handle async**: Wait for network/animations
6. **Run multiple times**: Catch flaky tests early

## Common Issues and Solutions

### Issue 1: Test Passes Locally but Fails in CI

**Problem:** Test works on developer machine but fails in CI environment

**Solutions:**

- **Viewport difference**: CI may use different screen size

  ```typescript
  await page.setViewportSize({ width: 1920, height: 1080 });
  ```

- **Slower CI**: Increase timeouts for CI

  ```typescript
  timeout: process.env.CI ? 60000 : 30000;
  ```

- **Headless issues**: Test in headless mode locally

  ```bash
  npx playwright test --headed=false
  ```

- **Network speed**: Add retries in config for CI

### Issue 2: Cannot Find Element with Correct data-testid

**Problem:** Selector looks correct but element not found

**Solutions:**

- Check element is in main page, not iframe
- Verify element is not dynamically loaded later
- Check for typos in data-testid value
- Use Playwright MCP to inspect actual HTML
- Add wait for element to be added to DOM

  ```typescript
  await page.waitForSelector('[data-testid="element"]');
  ```

### Issue 3: Test Works First Time but Fails on Reruns

**Problem:** First run passes, subsequent runs fail

**Solutions:**

- **State leaking**: Tests aren't isolated
  - Use `test.beforeEach` to reset state
  - Use fixtures for clean context
- **Storage persistence**: Clear local storage/cookies

  ```typescript
  await page.context().clearCookies();
  await page.evaluate(() => localStorage.clear());
  ```

- **Database state**: Reset test database between runs

### Issue 4: Element Found but Click Doesn't Work

**Problem:** `element.click()` doesn't do anything or throws error

**Solutions:**

- **Element covered**: Another element is covering it

  ```typescript
  await page.locator('[data-testid="modal-close"]').click({ force: true });
  ```

- **Element disabled**: Check if element is enabled

  ```typescript
  await expect(page.locator('[data-testid="submit"]')).toBeEnabled();
  ```

- **Wrong element**: Multiple elements match, clicking wrong one

  ```typescript
  await page.locator('[data-testid="item"]').first().click();
  ```

- **Animation in progress**: Wait for animations to complete

  ```typescript
  await page.waitForTimeout(500); // Avoid this
  // Better: Wait for element to be stable
  await page.locator('[data-testid="element"]').waitFor({ state: "visible" });
  await page.waitForLoadState("networkidle");
  ```

### Issue 5: Assertion Timing Out

**Problem:** `expect()` assertion times out after 5 seconds

**Solutions:**

- **Increase timeout**: For slow operations

  ```typescript
  await expect(locator).toBeVisible({ timeout: 15000 });
  ```

- **Wait for condition**: Add wait before assertion

  ```typescript
  await page.waitForLoadState("networkidle");
  await expect(locator).toBeVisible();
  ```

- **Wrong expectation**: Verify what you're asserting is correct
  - Check expected text/value in application
  - Verify element actually appears on success

## Resources

The `resources/` directory contains helpful references:

- `debugging-checklist.md` - Step-by-step debugging guide
- `common-errors.md` - List of common errors and quick fixes
- `playwright-commands.md` - Useful Playwright debugging commands
