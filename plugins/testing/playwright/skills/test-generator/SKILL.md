---
name: playwright-test-generator
description: Generate production-ready Playwright E2E tests from natural language specifications or requirements. Creates TypeScript test files following best practices including data-testid locators, proper async/await usage, test isolation, and the AAA (Arrange-Act-Assert) pattern.
---

## When to Use This Skill

Use this skill when you need to:

- Create new E2E tests from user stories or requirements
- Generate test files for new features or pages
- Convert manual test cases into automated tests
- Scaffold a complete test suite for a new application
- Create tests with proper fixtures and configuration

Do NOT use this skill when:

- You need to debug existing tests (use test-debugger skill)
- You want to refactor or maintain existing tests (use test-maintainer skill)
- You need to create Page Object Models (use page-object-builder skill)

## Prerequisites

Before using this skill:

1. Playwright should be installed in the project (`npm install -D @playwright/test`)
2. Basic understanding of the application under test (URLs, main flows)
3. Knowledge of what functionality needs to be tested
4. Access to the application's UI or design documentation

## Instructions

### Step 1: Gather Test Requirements

Ask the user for:

- **Feature/functionality** to test
- **User flow** or scenario description
- **Expected outcomes** (what should happen)
- **Test data** requirements (if any)
- **Page URL(s)** involved in the test
- **Data-testid values** (or offer to suggest them based on element purpose)

### Step 2: Analyze and Plan

Review the requirements and:

- Break down the user flow into discrete steps
- Identify all page elements that need interaction
- Determine what assertions are needed
- Plan the test structure (setup, actions, verifications)
- Identify any fixtures or utilities needed

### Step 3: Generate Test File

Create a TypeScript test file with:

**File Structure:**

```typescript
import { test, expect } from "@playwright/test";

test.describe("Feature Name", () => {
  test("should <specific behavior>", async ({ page }) => {
    // Arrange: Setup
    // Act: Perform actions
    // Assert: Verify results
  });
});
```

**Required Elements:**

- Descriptive test names (what behavior is tested)
- Proper async/await usage
- data-testid locators ONLY
- Explicit waits (waitForSelector, waitForLoadState)
- Clear assertions with expect()
- Comments for AAA sections
- TypeScript types

**Locator Strategy (MANDATORY):**

```typescript
// ✅ CORRECT: Always use data-testid
await page.locator('[data-testid="submit-button"]').click();
await expect(page.locator('[data-testid="success-message"]')).toBeVisible();

// ❌ WRONG: Never use CSS selectors, XPath, or text selectors
await page.locator(".submit-btn").click(); // NO
await page.locator('//button[@type="submit"]').click(); // NO
await page.getByRole("button", { name: "Submit" }).click(); // NO
```

### Step 4: Add Configuration (if needed)

If this is the first test, generate `playwright.config.ts`:

- Base URL configuration
- Timeout settings (30s default)
- Retry logic (2 retries for flaky tests)
- Screenshot on failure
- Trace on first retry
- Parallel execution settings

### Step 5: Include Fixtures (if needed)

For complex setups, create custom fixtures:

```typescript
import { test as base } from "@playwright/test";

type MyFixtures = {
  authenticatedPage: Page;
};

export const test = base.extend<MyFixtures>({
  authenticatedPage: async ({ page }, use) => {
    // Setup: login
    await page.goto("/login");
    await page.locator('[data-testid="username"]').fill("testuser");
    await page.locator('[data-testid="password"]').fill("password");
    await page.locator('[data-testid="login-button"]').click();
    await page.waitForURL("/dashboard");

    await use(page);

    // Teardown (if needed)
  },
});
```

### Step 6: Validate Generated Test

Ensure the test includes:

- [ ] Descriptive test name
- [ ] Proper test.describe grouping
- [ ] Only data-testid locators
- [ ] No hardcoded waits (no page.waitForTimeout())
- [ ] Explicit waits for elements
- [ ] Clear AAA structure
- [ ] TypeScript types
- [ ] Meaningful assertions
- [ ] Comments for complex logic

### Step 7: Provide Usage Instructions

Tell the user:

- Where the test file was created
- How to run the test: `npx playwright test <filename>`
- How to run in debug mode: `npx playwright test --debug <filename>`
- How to view traces: `npx playwright show-trace trace.zip`
- What data-testid values need to be added to the UI (if suggesting new ones)

## Examples

### Example 1: Simple Login Test

**Input:**
"Create a test for the login flow. User enters username and password, clicks login button, and should see the dashboard."

**Output:**

```typescript
import { test, expect } from "@playwright/test";

test.describe("Authentication", () => {
  test("should successfully login with valid credentials", async ({ page }) => {
    // Arrange: Navigate to login page
    await page.goto("/login");
    await expect(page.locator('[data-testid="login-form"]')).toBeVisible();

    // Act: Enter credentials and submit
    await page
      .locator('[data-testid="username-input"]')
      .fill("testuser@example.com");
    await page.locator('[data-testid="password-input"]').fill("SecurePass123");
    await page.locator('[data-testid="login-button"]').click();

    // Assert: Verify successful login
    await page.waitForURL("/dashboard");
    await expect(
      page.locator('[data-testid="dashboard-header"]'),
    ).toBeVisible();
    await expect(page.locator('[data-testid="user-welcome"]')).toContainText(
      "Welcome",
    );
  });
});
```

**Required data-testid values:**

- `login-form` - The login form container
- `username-input` - Username/email input field
- `password-input` - Password input field
- `login-button` - Submit button
- `dashboard-header` - Dashboard page header
- `user-welcome` - Welcome message element

### Example 2: E-commerce Product Purchase

**Input:**
"Test the product purchase flow: search for 'laptop', select first result, add to cart, checkout, and verify order confirmation."

**Output:**

```typescript
import { test, expect } from "@playwright/test";

test.describe("E-commerce Purchase Flow", () => {
  test("should complete product purchase from search to confirmation", async ({
    page,
  }) => {
    // Arrange: Navigate to homepage
    await page.goto("/");
    await expect(page.locator('[data-testid="search-bar"]')).toBeVisible();

    // Act: Search for product
    await page.locator('[data-testid="search-input"]').fill("laptop");
    await page.locator('[data-testid="search-button"]').click();
    await page.waitForLoadState("networkidle");

    // Act: Select first product
    await expect(
      page.locator('[data-testid="product-card"]').first(),
    ).toBeVisible();
    await page.locator('[data-testid="product-card"]').first().click();

    // Act: Add to cart
    await expect(
      page.locator('[data-testid="add-to-cart-button"]'),
    ).toBeEnabled();
    await page.locator('[data-testid="add-to-cart-button"]').click();
    await expect(page.locator('[data-testid="cart-count"]')).toContainText("1");

    // Act: Proceed to checkout
    await page.locator('[data-testid="cart-icon"]').click();
    await page.locator('[data-testid="checkout-button"]').click();

    // Act: Fill checkout form
    await page.locator('[data-testid="shipping-name"]').fill("John Doe");
    await page.locator('[data-testid="shipping-address"]').fill("123 Main St");
    await page.locator('[data-testid="shipping-city"]').fill("New York");
    await page.locator('[data-testid="shipping-zip"]').fill("10001");
    await page.locator('[data-testid="payment-card"]').fill("4242424242424242");
    await page.locator('[data-testid="payment-expiry"]').fill("12/25");
    await page.locator('[data-testid="payment-cvc"]').fill("123");
    await page.locator('[data-testid="place-order-button"]').click();

    // Assert: Verify order confirmation
    await page.waitForURL(/\/order\/confirmation/);
    await expect(
      page.locator('[data-testid="order-success-message"]'),
    ).toBeVisible();
    await expect(page.locator('[data-testid="order-number"]')).toContainText(
      /ORD-\d+/,
    );
  });
});
```

### Example 3: Form Validation Test

**Input:**
"Create a test for contact form validation. Test that empty fields show error messages."

**Output:**

```typescript
import { test, expect } from "@playwright/test";

test.describe("Contact Form Validation", () => {
  test("should display validation errors for empty required fields", async ({
    page,
  }) => {
    // Arrange: Navigate to contact page
    await page.goto("/contact");
    await expect(page.locator('[data-testid="contact-form"]')).toBeVisible();

    // Act: Submit form without filling any fields
    await page.locator('[data-testid="submit-button"]').click();

    // Assert: Verify error messages appear
    await expect(page.locator('[data-testid="name-error"]')).toBeVisible();
    await expect(page.locator('[data-testid="name-error"]')).toContainText(
      "Name is required",
    );

    await expect(page.locator('[data-testid="email-error"]')).toBeVisible();
    await expect(page.locator('[data-testid="email-error"]')).toContainText(
      "Email is required",
    );

    await expect(page.locator('[data-testid="message-error"]')).toBeVisible();
    await expect(page.locator('[data-testid="message-error"]')).toContainText(
      "Message is required",
    );

    // Act: Fill fields correctly
    await page.locator('[data-testid="name-input"]').fill("John Doe");
    await page.locator('[data-testid="email-input"]').fill("john@example.com");
    await page
      .locator('[data-testid="message-input"]')
      .fill("Hello, this is a test message.");

    // Assert: Verify errors disappear
    await expect(page.locator('[data-testid="name-error"]')).not.toBeVisible();
    await expect(page.locator('[data-testid="email-error"]')).not.toBeVisible();
    await expect(
      page.locator('[data-testid="message-error"]'),
    ).not.toBeVisible();

    // Act: Submit form
    await page.locator('[data-testid="submit-button"]').click();

    // Assert: Verify success
    await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
  });
});
```

## Best Practices

### Test Structure

1. **One scenario per test**: Each test should verify one specific behavior
2. **Descriptive names**: Use "should [expected behavior]" format
3. **AAA pattern**: Always follow Arrange-Act-Assert structure
4. **Independent tests**: Tests should not depend on each other
5. **Clean state**: Each test should start with a clean state (use fixtures)

### Locators

1. **data-testid ONLY**: Never use CSS selectors, XPath, or text-based locators
2. **Semantic naming**: Use descriptive testid names (e.g., "submit-button" not "btn1")
3. **Stable locators**: data-testid values should not change with UI updates
4. **Unique identifiers**: Each testid should be unique on the page

### Async/Await

1. **Always await**: Every Playwright action should be awaited
2. **No hardcoded waits**: Use `waitForSelector`, `waitForLoadState`, not `waitForTimeout`
3. **Wait for elements**: Explicitly wait for elements before interaction
4. **Wait for navigation**: Use `waitForURL` after actions that navigate

### Assertions

1. **Explicit expectations**: Use `expect()` with specific matchers
2. **Wait for conditions**: Assertions automatically wait (default 5s)
3. **Multiple assertions**: It's OK to have multiple assertions per test
4. **Negative assertions**: Use `.not.toBeVisible()` for negative cases

### Error Handling

1. **Screenshot on failure**: Configure in playwright.config.ts
2. **Trace on retry**: Enable trace recording for debugging
3. **Meaningful errors**: Assertions should provide clear error messages
4. **Timeout configuration**: Set appropriate timeouts (30s default)

## Common Issues and Solutions

### Issue 1: Test Times Out

**Problem:** Test fails with "Timeout 30000ms exceeded" error

**Solutions:**

- Add explicit waits before interactions: `await page.waitForSelector('[data-testid="element"]')`
- Increase timeout for slow operations: `{ timeout: 60000 }`
- Wait for network to be idle: `await page.waitForLoadState('networkidle')`
- Check if element is actually present in the page
- Verify the data-testid value is correct

### Issue 2: Element Not Found

**Problem:** "Element not found" or "locator.click: Target closed" errors

**Solutions:**

- Verify the data-testid value matches the HTML attribute
- Add wait before interaction: `await expect(locator).toBeVisible()`
- Check if element is in a frame/iframe (requires frame handling)
- Ensure page has loaded: `await page.waitForLoadState('domcontentloaded')`
- Verify element isn't dynamically loaded (wait for it explicitly)

### Issue 3: Flaky Tests

**Problem:** Test passes sometimes but fails randomly

**Solutions:**

- Remove all `page.waitForTimeout()` calls (use explicit waits instead)
- Wait for specific conditions, not arbitrary time periods
- Use `waitForLoadState('networkidle')` for AJAX-heavy pages
- Enable retries in config (2 retries recommended)
- Check for race conditions (multiple elements with same testid)
- Ensure test isolation (clean state between tests)

### Issue 4: Wrong Locator Strategy

**Problem:** Generated test uses CSS selectors or XPath

**Solutions:**

- **ALWAYS** use `page.locator('[data-testid="element-name"]')` format
- Never use `page.locator('.class-name')` or `page.locator('#id')`
- Never use `page.getByRole()`, `page.getByText()`, or `page.getByLabel()`
- If data-testid doesn't exist, suggest adding it to the UI code
- Document all required data-testid values for developers

### Issue 5: Test Doesn't Match Requirements

**Problem:** Generated test doesn't fully cover the specified scenario

**Solutions:**

- Re-read the requirements carefully
- Break down complex flows into smaller steps
- Verify all user actions are included
- Ensure all expected outcomes have assertions
- Ask user for clarification if requirements are ambiguous
- Add comments explaining each step of the test

## Resources

The `resources/` directory contains templates for common patterns:

- `test-template.ts` - Basic test file structure
- `playwright.config.ts` - Recommended Playwright configuration
- `fixtures.ts` - Custom fixture examples (authentication, data setup)
- `utils.ts` - Helper functions for common operations
