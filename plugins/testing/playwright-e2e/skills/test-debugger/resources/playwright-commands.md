# Useful Playwright Debugging Commands

## Running Tests

```bash
# Run all tests
npx playwright test

# Run specific test file
npx playwright test login.spec.ts

# Run tests matching pattern
npx playwright test --grep "login"

# Run tests in specific browser
npx playwright test --project=chromium
npx playwright test --project=firefox
npx playwright test --project=webkit

# Run tests in headed mode (see browser)
npx playwright test --headed

# Run specific test by line number
npx playwright test login.spec.ts:42

# Run tests in parallel
npx playwright test --workers=4

# Run tests sequentially
npx playwright test --workers=1
```

## Debugging

```bash
# Debug mode (opens inspector)
npx playwright test --debug

# Debug specific test
npx playwright test login.spec.ts --debug

# UI Mode (interactive)
npx playwright test --ui

# Step through tests
npx playwright test --debug --headed

# Playwright Inspector
PWDEBUG=1 npx playwright test
```

## Code Generation

```bash
# Generate test code by recording actions
npx playwright codegen

# Generate code for specific URL
npx playwright codegen https://example.com

# Generate with specific device
npx playwright codegen --device="iPhone 12"

# Generate with authentication
npx playwright codegen --save-storage=auth.json
```

## Trace Viewing

```bash
# Show trace file
npx playwright show-trace trace.zip

# Open trace from test results
npx playwright show-trace test-results/login-test/trace.zip

# View trace with network data
npx playwright show-trace trace.zip --network
```

## Report Viewing

```bash
# Open HTML report
npx playwright show-report

# Open specific report
npx playwright show-report ./playwright-report
```

## Installation & Setup

```bash
# Install Playwright
npm init playwright@latest

# Install Playwright Test
npm install -D @playwright/test

# Install browsers
npx playwright install

# Install specific browser
npx playwright install chromium
npx playwright install firefox
npx playwright install webkit

# Install with dependencies (Linux)
npx playwright install --with-deps

# Update Playwright
npm install -D @playwright/test@latest
npx playwright install
```

## Configuration

```bash
# Run with custom config
npx playwright test --config=custom.config.ts

# List all projects
npx playwright test --list

# Show configuration
npx playwright show-config
```

## Useful Test Options

```bash
# Run tests with retries
npx playwright test --retries=3

# Set timeout
npx playwright test --timeout=60000

# Run tests with maximum failures
npx playwright test --max-failures=5

# Run only failed tests
npx playwright test --last-failed

# Update snapshots
npx playwright test --update-snapshots

# Ignore snapshots
npx playwright test --ignore-snapshots
```

## Environment Variables

```bash
# Enable debug logs
DEBUG=pw:api npx playwright test

# Enable verbose logging
DEBUG=* npx playwright test

# Set browser
BROWSER=firefox npx playwright test

# Set headed mode
HEADED=1 npx playwright test

# Disable parallel execution
PWTEST_PARALLEL=0 npx playwright test
```

## In-Test Debugging Commands

### Console Logging

```typescript
// Log to console
console.log('Debug message:', value);

// Log page URL
console.log('Current URL:', page.url());

// Log element count
const count = await page.locator('[data-testid="item"]').count();
console.log('Element count:', count);

// Log element text
const text = await page.locator('[data-testid="element"]').textContent();
console.log('Element text:', text);

// Log all text contents
const allText = await page.locator('[data-testid="item"]').allTextContents();
console.log('All texts:', allText);
```

### Page Pause

```typescript
// Pause test execution (opens inspector)
await page.pause();

// Pause on specific condition
if (someCondition) {
  await page.pause();
}
```

### Screenshots

```typescript
// Take screenshot
await page.screenshot({ path: 'screenshot.png' });

// Full page screenshot
await page.screenshot({ path: 'screenshot.png', fullPage: true });

// Element screenshot
await page.locator('[data-testid="element"]').screenshot({ path: 'element.png' });

// Screenshot with timestamp
const timestamp = Date.now();
await page.screenshot({ path: `debug-${timestamp}.png` });
```

### Video Recording

```typescript
// In playwright.config.ts
use: {
  video: 'on', // or 'retain-on-failure'
}

// In test
const path = await page.video()?.path();
console.log('Video saved at:', path);
```

### Trace Recording

```typescript
// Start tracing
await context.tracing.start({ screenshots: true, snapshots: true });

// Stop tracing and save
await context.tracing.stop({ path: 'trace.zip' });

// Or in playwright.config.ts
use: {
  trace: 'on-first-retry', // or 'on' for all tests
}
```

### Evaluate JavaScript

```typescript
// Execute JavaScript in page context
const result = await page.evaluate(() => {
  return document.title;
});
console.log('Page title:', result);

// With parameters
const result = await page.evaluate((text) => {
  return document.body.textContent?.includes(text);
}, 'search term');

// Get element properties
const value = await page.locator('[data-testid="input"]').evaluate(
  (el: HTMLInputElement) => el.value
);
```

### Wait Commands

```typescript
// Wait for timeout (avoid in production)
await page.waitForTimeout(1000);

// Wait for selector
await page.waitForSelector('[data-testid="element"]');

// Wait for URL
await page.waitForURL('/dashboard');
await page.waitForURL(/\/user\/\d+/);

// Wait for load state
await page.waitForLoadState('load');
await page.waitForLoadState('domcontentloaded');
await page.waitForLoadState('networkidle');

// Wait for response
await page.waitForResponse('**/api/data');
await page.waitForResponse(response =>
  response.url().includes('/api/') && response.status() === 200
);

// Wait for request
await page.waitForRequest('**/api/users');

// Wait for function
await page.waitForFunction(() => document.querySelectorAll('.item').length > 5);

// Wait for event
await page.waitForEvent('response');
await page.waitForEvent('request');
```

### Network Debugging

```typescript
// Listen to all requests
page.on('request', request =>
  console.log('>>', request.method(), request.url())
);

// Listen to all responses
page.on('response', response =>
  console.log('<<', response.status(), response.url())
);

// Listen to console messages
page.on('console', msg => console.log('PAGE LOG:', msg.text()));

// Listen to page errors
page.on('pageerror', error => console.log('PAGE ERROR:', error));

// Intercept and log requests
await page.route('**/api/**', route => {
  console.log('API Request:', route.request().url());
  route.continue();
});
```

### State Inspection

```typescript
// Get all cookies
const cookies = await context.cookies();
console.log('Cookies:', cookies);

// Get localStorage
const localStorage = await page.evaluate(() => {
  return JSON.stringify(window.localStorage);
});
console.log('LocalStorage:', localStorage);

// Get sessionStorage
const sessionStorage = await page.evaluate(() => {
  return JSON.stringify(window.sessionStorage);
});
console.log('SessionStorage:', sessionStorage);

// Get viewport size
const viewport = page.viewportSize();
console.log('Viewport:', viewport);
```

### Element State Checks

```typescript
// Check visibility
const isVisible = await page.locator('[data-testid="element"]').isVisible();
console.log('Is visible:', isVisible);

// Check if enabled
const isEnabled = await page.locator('[data-testid="button"]').isEnabled();
console.log('Is enabled:', isEnabled);

// Check if checked
const isChecked = await page.locator('[data-testid="checkbox"]').isChecked();
console.log('Is checked:', isChecked);

// Get bounding box
const box = await page.locator('[data-testid="element"]').boundingBox();
console.log('Bounding box:', box);

// Get attribute
const value = await page.locator('[data-testid="input"]').getAttribute('value');
console.log('Value:', value);

// Get inner text
const text = await page.locator('[data-testid="element"]').innerText();
console.log('Inner text:', text);

// Get input value
const inputValue = await page.locator('[data-testid="input"]').inputValue();
console.log('Input value:', inputValue);
```

## Performance Testing

```bash
# Run with tracing
npx playwright test --trace=on

# Run with video
npx playwright test --video=on

# Slow down execution
npx playwright test --slow-mo=1000
```

## CI/CD Commands

```bash
# Run in CI mode
CI=1 npx playwright test

# Run with JUnit reporter
npx playwright test --reporter=junit

# Run with multiple reporters
npx playwright test --reporter=html,json,junit

# Run with sharding
npx playwright test --shard=1/3
npx playwright test --shard=2/3
npx playwright test --shard=3/3
```

## Test Filtering

```bash
# Run tests with specific tag
npx playwright test --grep @smoke

# Skip tests with tag
npx playwright test --grep-invert @skip

# Run tests in specific describe block
npx playwright test --grep "Login tests"

# Run only tests marked with test.only
# (Automatically done if test.only exists)
```

## Maintenance Commands

```bash
# Clean test output
rm -rf test-results/
rm -rf playwright-report/

# List installed browsers
npx playwright --version

# Check for browser updates
npx playwright install --dry-run

# Uninstall browsers
npx playwright uninstall

# Clear browser cache
npx playwright install --force
```

## Tips

1. **Use `--headed` for visual debugging**
   ```bash
   npx playwright test --headed --project=chromium
   ```

2. **Use `--debug` to step through test**
   ```bash
   npx playwright test login.spec.ts --debug
   ```

3. **Use `--ui` for interactive mode**
   ```bash
   npx playwright test --ui
   ```

4. **Use `show-trace` to analyze failures**
   ```bash
   npx playwright show-trace trace.zip
   ```

5. **Use `codegen` to learn selectors**
   ```bash
   npx playwright codegen http://localhost:3000
   ```
