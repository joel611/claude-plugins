# Common Playwright Errors and Quick Fixes

## Timeout Errors

### Error: "Timeout 30000ms exceeded waiting for selector"

**Cause:** Element not found within timeout period

**Quick Fixes:**
```typescript
// 1. Add explicit wait
await page.waitForSelector('[data-testid="element"]', { state: 'visible' });

// 2. Verify data-testid is correct
const count = await page.locator('[data-testid="element"]').count();
console.log('Found', count, 'elements');

// 3. Wait for page to load first
await page.waitForLoadState('domcontentloaded');

// 4. Increase timeout if legitimately slow
await page.locator('[data-testid="element"]').waitFor({
  state: 'visible',
  timeout: 60000
});
```

### Error: "Timeout 30000ms exceeded waiting for navigation"

**Cause:** Page navigation taking too long or not happening

**Quick Fixes:**
```typescript
// 1. Wait for specific URL
await page.waitForURL('/expected-path', { timeout: 45000 });

// 2. Wait for load state
await page.waitForLoadState('networkidle');

// 3. Check if navigation actually occurs
console.log('Current URL:', page.url());
```

## Selector Errors

### Error: "strict mode violation: locator resolved to X elements"

**Cause:** Multiple elements match the selector

**Quick Fixes:**
```typescript
// 1. Use .first() or .last()
await page.locator('[data-testid="item"]').first().click();

// 2. Use .nth() for specific element
await page.locator('[data-testid="item"]').nth(2).click();

// 3. Make selector more specific (avoid if possible)
await page.locator('[data-testid="item"][aria-selected="true"]').click();

// 4. Filter locators
await page.locator('[data-testid="item"]').filter({ hasText: 'Active' }).click();
```

### Error: "Element not found"

**Cause:** Element doesn't exist or wrong selector

**Quick Fixes:**
```typescript
// 1. Verify element exists
const exists = await page.locator('[data-testid="element"]').count() > 0;
console.log('Element exists:', exists);

// 2. Check for typos in data-testid
// Verify in HTML: <button data-testid="correct-id">

// 3. Wait for element to be added to DOM
await page.locator('[data-testid="element"]').waitFor({ state: 'attached' });

// 4. Check if in iframe
const frame = page.frameLocator('[data-testid="app-frame"]');
await frame.locator('[data-testid="element"]').click();
```

## Assertion Errors

### Error: "expect(received).toBeVisible() - Expected visible but received hidden"

**Cause:** Element exists but is not visible

**Quick Fixes:**
```typescript
// 1. Wait for element to become visible
await page.locator('[data-testid="element"]').waitFor({ state: 'visible' });
await expect(page.locator('[data-testid="element"]')).toBeVisible();

// 2. Check visibility with timeout
await expect(page.locator('[data-testid="element"]')).toBeVisible({
  timeout: 10000
});

// 3. Debug visibility
const isVisible = await page.locator('[data-testid="element"]').isVisible();
console.log('Is visible:', isVisible);
```

### Error: "expect(received).toContainText() - Expected substring not found"

**Cause:** Element doesn't contain expected text or not loaded yet

**Quick Fixes:**
```typescript
// 1. Wait for text to appear
await expect(page.locator('[data-testid="element"]')).toContainText('Expected', {
  timeout: 10000
});

// 2. Wait for network before checking
await page.waitForLoadState('networkidle');
await expect(page.locator('[data-testid="element"]')).toContainText('Expected');

// 3. Check actual text content
const text = await page.locator('[data-testid="element"]').textContent();
console.log('Actual text:', text);
```

## Click Errors

### Error: "locator.click: Target closed"

**Cause:** Element or page disappeared before click completed

**Quick Fixes:**
```typescript
// 1. Wait for element to be stable
await page.locator('[data-testid="element"]').waitFor({ state: 'visible' });
await page.waitForTimeout(100); // Allow animations to settle
await page.locator('[data-testid="element"]').click();

// 2. Use force click if element is covered
await page.locator('[data-testid="element"]').click({ force: true });

// 3. Check if element is being removed
const count = await page.locator('[data-testid="element"]').count();
console.log('Element count before click:', count);
```

### Error: "Element is not clickable"

**Cause:** Element is disabled, covered, or not in viewport

**Quick Fixes:**
```typescript
// 1. Check if element is enabled
await expect(page.locator('[data-testid="button"]')).toBeEnabled();
await page.locator('[data-testid="button"]').click();

// 2. Scroll into view
await page.locator('[data-testid="element"]').scrollIntoViewIfNeeded();
await page.locator('[data-testid="element"]').click();

// 3. Wait for element to be clickable
await page.locator('[data-testid="element"]').waitFor({ state: 'visible' });
await expect(page.locator('[data-testid="element"]')).toBeEnabled();
await page.locator('[data-testid="element"]').click();
```

## Network Errors

### Error: "net::ERR_CONNECTION_REFUSED"

**Cause:** Server is not running or wrong URL

**Quick Fixes:**
```typescript
// 1. Verify server is running
// Check if dev server is started: npm run dev

// 2. Check baseURL in playwright.config.ts
use: {
  baseURL: 'http://localhost:3000', // Correct port?
}

// 3. Use full URL if baseURL not set
await page.goto('http://localhost:3000/path');
```

### Error: "Navigation failed because page was closed"

**Cause:** Page closed prematurely during navigation

**Quick Fixes:**
```typescript
// 1. Don't close page too early
// Remove premature page.close() calls

// 2. Wait for navigation to complete
await page.goto('/path');
await page.waitForLoadState('domcontentloaded');

// 3. Check for popup blockers or redirects
```

## Fill/Type Errors

### Error: "Cannot type into a non-editable element"

**Cause:** Trying to fill a non-input element

**Quick Fixes:**
```typescript
// 1. Verify element is an input/textarea
const tagName = await page.locator('[data-testid="element"]').evaluate(
  el => el.tagName
);
console.log('Tag name:', tagName); // Should be INPUT or TEXTAREA

// 2. Check if element is contenteditable
const isEditable = await page.locator('[data-testid="element"]').evaluate(
  el => el.contentEditable
);

// 3. Use correct element selector
// Ensure data-testid is on the input, not its container
```

### Error: "Element is disabled"

**Cause:** Trying to interact with disabled element

**Quick Fixes:**
```typescript
// 1. Wait for element to be enabled
await expect(page.locator('[data-testid="input"]')).toBeEnabled();
await page.locator('[data-testid="input"]').fill('value');

// 2. Check why element is disabled
const isDisabled = await page.locator('[data-testid="input"]').isDisabled();
console.log('Is disabled:', isDisabled);

// 3. Ensure prerequisites are met (e.g., terms accepted)
await page.locator('[data-testid="terms-checkbox"]').check();
await page.locator('[data-testid="submit"]').click();
```

## Frame/Iframe Errors

### Error: "Frame was detached"

**Cause:** Interacting with iframe that was removed

**Quick Fixes:**
```typescript
// 1. Re-acquire frame reference
const frame = page.frameLocator('[data-testid="app-frame"]');
await frame.locator('[data-testid="element"]').click();

// 2. Wait for frame to be ready
await page.frameLocator('[data-testid="app-frame"]').locator('body').waitFor();

// 3. Check if frame exists
const frameCount = await page.frames().length;
console.log('Frame count:', frameCount);
```

## Race Condition Errors

### Error: Test passes sometimes, fails other times

**Cause:** Race condition / flaky test

**Quick Fixes:**
```typescript
// 1. Wait for network to settle
await page.waitForLoadState('networkidle');

// 2. Wait for specific API calls
await page.waitForResponse('**/api/data');

// 3. Add explicit waits
await page.locator('[data-testid="element"]').waitFor({ state: 'visible' });

// 4. Increase timeouts
await expect(page.locator('[data-testid="result"]')).toBeVisible({
  timeout: 15000
});

// 5. Enable retries in playwright.config.ts
retries: 2,
```

## Context/State Errors

### Error: "localStorage is not defined"

**Cause:** Accessing localStorage before page is loaded

**Quick Fixes:**
```typescript
// 1. Navigate to page first
await page.goto('/');
await page.evaluate(() => localStorage.setItem('key', 'value'));

// 2. Use context.addInitScript for early setup
await context.addInitScript(() => {
  localStorage.setItem('key', 'value');
});
```

### Error: "Test passes in isolation but fails in suite"

**Cause:** Test pollution / shared state

**Quick Fixes:**
```typescript
// 1. Clear state in beforeEach
test.beforeEach(async ({ page }) => {
  await page.context().clearCookies();
  await page.evaluate(() => {
    localStorage.clear();
    sessionStorage.clear();
  });
});

// 2. Use test.describe.serial for dependent tests
test.describe.serial('Login flow', () => {
  // Tests run in order
});

// 3. Create fresh context for each test
test.use({ storageState: undefined });
```

## Configuration Errors

### Error: "Cannot find module '@playwright/test'"

**Cause:** Playwright not installed

**Quick Fixes:**
```bash
# Install Playwright
npm install -D @playwright/test

# Install browsers
npx playwright install
```

### Error: "No tests found"

**Cause:** Test files not matching pattern

**Quick Fixes:**
```typescript
// In playwright.config.ts
testDir: './tests',
testMatch: '**/*.spec.ts', // Or *.test.ts
```

## Debugging Commands

```bash
# Run with UI mode
npx playwright test --ui

# Run in headed mode
npx playwright test --headed

# Debug specific test
npx playwright test --debug test-file.spec.ts

# Show trace
npx playwright show-trace trace.zip

# Generate code
npx playwright codegen localhost:3000
```
