# Playwright Test Debugging Checklist

## Initial Assessment

- [ ] Read the error message carefully
- [ ] Note the failing test name and location
- [ ] Check if test fails consistently or intermittently
- [ ] Identify which browser(s) are failing
- [ ] Check if failure is local only or also in CI

## Error Type Identification

### Timeout Errors
- [ ] Check if element exists with correct data-testid
- [ ] Verify page has loaded completely
- [ ] Add explicit wait before interaction
- [ ] Check if network requests are pending
- [ ] Increase timeout if operation is legitimately slow

### Selector Errors
- [ ] Verify data-testid in HTML matches test code
- [ ] Check if multiple elements have the same testid
- [ ] Ensure element is not in an iframe
- [ ] Confirm element is added to DOM (not removed)
- [ ] Use Playwright Inspector to test selector

### Assertion Errors
- [ ] Verify expected value is correct
- [ ] Check if element exists and is visible
- [ ] Add wait before assertion
- [ ] Check if content is populated asynchronously
- [ ] Increase assertion timeout if needed

### Navigation Errors
- [ ] Check if URL is correct
- [ ] Verify server is running
- [ ] Check for network issues
- [ ] Ensure proper wait after navigation
- [ ] Look for redirects or authentication requirements

## Element Investigation

- [ ] Count elements matching selector (should be 1)
  ```typescript
  const count = await page.locator('[data-testid="element"]').count();
  console.log('Element count:', count);
  ```

- [ ] Check element visibility
  ```typescript
  const isVisible = await page.locator('[data-testid="element"]').isVisible();
  console.log('Is visible:', isVisible);
  ```

- [ ] Check element state
  ```typescript
  const isEnabled = await page.locator('[data-testid="element"]').isEnabled();
  console.log('Is enabled:', isEnabled);
  ```

- [ ] Get element attributes
  ```typescript
  const testId = await page.locator('[data-testid="element"]').getAttribute('data-testid');
  console.log('data-testid:', testId);
  ```

## Timing Investigation

- [ ] Add waits before interactions
  ```typescript
  await page.locator('[data-testid="element"]').waitFor({ state: 'visible' });
  ```

- [ ] Wait for page load
  ```typescript
  await page.waitForLoadState('domcontentloaded');
  await page.waitForLoadState('networkidle');
  ```

- [ ] Wait for specific API calls
  ```typescript
  await page.waitForResponse('**/api/endpoint');
  ```

- [ ] Check if animations/transitions are in progress
  ```typescript
  await page.waitForTimeout(500); // Only for testing, remove later
  ```

## Interactive Debugging

- [ ] Run test in headed mode
  ```bash
  npx playwright test --headed
  ```

- [ ] Use debug mode
  ```bash
  npx playwright test --debug
  ```

- [ ] Add `page.pause()` in test
  ```typescript
  await page.pause(); // Pauses execution for manual inspection
  ```

- [ ] Enable slow motion
  ```typescript
  // In playwright.config.ts
  use: {
    launchOptions: {
      slowMo: 1000, // Slow down by 1 second
    },
  }
  ```

- [ ] Take screenshots for inspection
  ```typescript
  await page.screenshot({ path: 'debug-screenshot.png', fullPage: true });
  ```

## Trace Analysis

- [ ] Enable trace recording
  ```typescript
  // In playwright.config.ts
  use: {
    trace: 'on-first-retry',
  }
  ```

- [ ] Open trace viewer
  ```bash
  npx playwright show-trace trace.zip
  ```

- [ ] Check trace for:
  - Network requests
  - Console logs
  - Screenshots at each step
  - DOM snapshots
  - Action timeline

## Test Isolation Check

- [ ] Run test in isolation (comment out other tests)
- [ ] Check if test passes when run alone
- [ ] Verify no shared state between tests
- [ ] Ensure proper cleanup in `afterEach`
- [ ] Check for global state mutations

## Environment Differences

### Local vs CI
- [ ] Run test in headless mode locally
  ```bash
  npx playwright test --headed=false
  ```

- [ ] Check viewport size matches CI
  ```typescript
  await page.setViewportSize({ width: 1920, height: 1080 });
  ```

- [ ] Compare timeouts (CI may need longer)
- [ ] Check if CI has different environment variables

### Browser Differences
- [ ] Test in all configured browsers
  ```bash
  npx playwright test --project=chromium
  npx playwright test --project=firefox
  npx playwright test --project=webkit
  ```

- [ ] Check for browser-specific issues
- [ ] Verify CSS compatibility
- [ ] Test JavaScript feature support

## Common Quick Fixes

### Fix #1: Add Explicit Wait
```typescript
// Before
await page.locator('[data-testid="element"]').click();

// After
await page.locator('[data-testid="element"]').waitFor({ state: 'visible' });
await page.locator('[data-testid="element"]').click();
```

### Fix #2: Wait for Network
```typescript
// Before
await page.locator('[data-testid="submit"]').click();
await expect(page.locator('[data-testid="result"]')).toBeVisible();

// After
await page.locator('[data-testid="submit"]').click();
await page.waitForLoadState('networkidle');
await expect(page.locator('[data-testid="result"]')).toBeVisible();
```

### Fix #3: Handle Multiple Elements
```typescript
// Before
await page.locator('[data-testid="item"]').click(); // Error if multiple

// After
await page.locator('[data-testid="item"]').first().click();
```

### Fix #4: Increase Timeout
```typescript
// Before
await expect(page.locator('[data-testid="slow-element"]')).toBeVisible();

// After
await expect(page.locator('[data-testid="slow-element"]')).toBeVisible({
  timeout: 15000
});
```

### Fix #5: Check Element State
```typescript
// Before
await page.locator('[data-testid="button"]').click();

// After
await expect(page.locator('[data-testid="button"]')).toBeEnabled();
await page.locator('[data-testid="button"]').click();
```

## Verification

- [ ] Run test 5+ times to verify consistency
- [ ] Test in all browsers
- [ ] Run full test suite to check for regressions
- [ ] Test in CI environment
- [ ] Document the fix for future reference

## Prevention

- [ ] Add explicit waits where needed
- [ ] Use only data-testid locators
- [ ] Ensure test isolation
- [ ] Add retry logic in config
- [ ] Review and refactor flaky tests regularly
- [ ] Keep tests simple and focused
- [ ] Maintain good test hygiene (cleanup, fixtures)
