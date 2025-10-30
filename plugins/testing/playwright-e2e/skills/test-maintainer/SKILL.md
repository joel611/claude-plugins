# Test Maintainer Skill

## Purpose

Maintain, refactor, and improve existing Playwright E2E tests. Handles tasks like updating locators across test suites, extracting reusable utilities, improving test stability, removing code duplication, and enforcing best practices throughout the test codebase.

## When to Use This Skill

Use this skill when you need to:
- Update data-testid locators across multiple tests
- Refactor duplicate code into utilities or Page Objects
- Improve flaky or unstable tests
- Extract common test patterns into reusable fixtures
- Update tests after UI changes
- Migrate tests to use Page Object Model
- Consolidate similar tests
- Improve test readability and maintainability

Do NOT use this skill when:
- Creating new tests from scratch (use test-generator skill)
- Building new Page Objects (use page-object-builder skill)
- Debugging test failures (use test-debugger skill)

## Prerequisites

Before using this skill:
1. Access to existing test files
2. Understanding of what changes are needed
3. Knowledge of the current test structure
4. Optional: Test execution results to identify flaky tests

## Instructions

### Step 1: Assess Current State

Gather information about:
- **Test files** requiring maintenance
- **Type of maintenance** needed (refactor, update locators, fix flakiness)
- **Scope** of changes (single file, multiple files, entire suite)
- **Current issues** (duplication, poor practices, flakiness)
- **Desired end state** (what should the tests look like after)

### Step 2: Identify Maintenance Type

Determine the maintenance task:

**Locator Updates:**
- Changing data-testid values
- Updating selectors after UI changes
- Migrating from CSS/XPath to data-testid

**Code Refactoring:**
- Extracting duplicate code to utilities
- Creating Page Objects from inline selectors
- Consolidating similar tests
- Improving test structure

**Stability Improvements:**
- Adding explicit waits
- Fixing race conditions
- Removing hardcoded waits
- Improving assertions

**Best Practices:**
- Enforcing data-testid usage
- Implementing AAA pattern
- Adding proper TypeScript types
- Improving test isolation

### Step 3: Plan the Changes

Before making changes:
1. **Identify all affected files**
2. **Backup or commit current state** (git commit)
3. **Create checklist** of changes to make
4. **Plan refactoring strategy** (bottom-up or top-down)
5. **Consider impact** on other tests

### Step 4: Apply Maintenance

Execute the maintenance based on type:

#### Locator Updates

```typescript
// Task: Update data-testid from "btn-submit" to "submit-button"

// Before (multiple files)
await page.locator('[data-testid="btn-submit"]').click();

// After (updated in all files)
await page.locator('[data-testid="submit-button"]').click();

// Use search and replace across files
// Find: '[data-testid="btn-submit"]'
// Replace: '[data-testid="submit-button"]'
```

#### Extract Utilities

```typescript
// Before: Duplicate login code in multiple tests
test('test 1', async ({ page }) => {
  await page.goto('/login');
  await page.locator('[data-testid="email"]').fill('user@example.com');
  await page.locator('[data-testid="password"]').fill('password');
  await page.locator('[data-testid="login-button"]').click();
  await page.waitForURL('/dashboard');
  // ... test continues
});

// After: Extract to utility function
// In utils/auth.ts
export async function login(page: Page, email: string, password: string) {
  await page.goto('/login');
  await page.locator('[data-testid="email"]').fill(email);
  await page.locator('[data-testid="password"]').fill(password);
  await page.locator('[data-testid="login-button"]').click();
  await page.waitForURL('/dashboard');
}

// In tests
test('test 1', async ({ page }) => {
  await login(page, 'user@example.com', 'password');
  // ... test continues
});
```

#### Migrate to Page Objects

```typescript
// Before: Inline selectors throughout tests
test('update profile', async ({ page }) => {
  await page.goto('/profile');
  await page.locator('[data-testid="name-input"]').fill('John Doe');
  await page.locator('[data-testid="email-input"]').fill('john@example.com');
  await page.locator('[data-testid="save-button"]').click();
  await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
});

// After: Using Page Object
// Create ProfilePage.ts (see page-object-builder skill)

test('update profile', async ({ page }) => {
  const profilePage = new ProfilePage(page);
  await profilePage.goto();
  await profilePage.updateProfile({
    name: 'John Doe',
    email: 'john@example.com'
  });
  await expect(profilePage.getSuccessMessage()).toBeVisible();
});
```

#### Fix Flaky Tests

```typescript
// Before: Flaky due to race condition
await page.locator('[data-testid="submit"]').click();
await expect(page.locator('[data-testid="result"]')).toContainText('Success');

// After: Add proper waits
await page.locator('[data-testid="submit"]').click();
await page.waitForLoadState('networkidle');
await expect(page.locator('[data-testid="result"]')).toContainText('Success', {
  timeout: 10000
});
```

### Step 5: Ensure Consistency

After changes:
- [ ] All tests use data-testid locators
- [ ] Consistent naming conventions
- [ ] Follow AAA pattern
- [ ] Proper TypeScript types
- [ ] No code duplication
- [ ] Tests are isolated
- [ ] Proper waits (no hardcoded timeouts)

### Step 6: Verify Changes

Run tests to ensure:
1. **All tests pass** after refactoring
2. **No regressions** introduced
3. **Improved stability** (run multiple times)
4. **Better readability** and maintainability
5. **Reduced code duplication**

## Examples

### Example 1: Update Locators Across Test Suite

**Input:**
"The development team changed all button data-testids from format 'btn-action' to 'action-button'. Update all tests."

**Changes:**
```typescript
// Create mapping of old to new testids
const locatorUpdates = {
  'btn-submit': 'submit-button',
  'btn-cancel': 'cancel-button',
  'btn-delete': 'delete-button',
  'btn-edit': 'edit-button',
  'btn-save': 'save-button',
};

// Apply to all test files:
// Find all instances in: tests/**/*.spec.ts

// Example in login.spec.ts:
// Before
await page.locator('[data-testid="btn-submit"]').click();

// After
await page.locator('[data-testid="submit-button"]').click();

// Use global find and replace for each mapping
```

**Verification:**
```bash
# Search for old pattern to ensure all updated
grep -r "btn-" tests/

# Run all tests
npx playwright test

# Check for any failures
```

### Example 2: Extract Common Test Utilities

**Input:**
"Multiple tests have duplicate code for filling forms. Extract to reusable utilities."

**Solution:**
```typescript
// Identify duplicate pattern across tests:
// Pattern 1: Form filling
await page.locator('[data-testid="field1"]').fill(value1);
await page.locator('[data-testid="field2"]').fill(value2);
await page.locator('[data-testid="field3"]').fill(value3);

// Create utils/form-helpers.ts:
import { Page } from '@playwright/test';

export async function fillForm(
  page: Page,
  fields: Record<string, string>
): Promise<void> {
  for (const [testId, value] of Object.entries(fields)) {
    await page.locator(`[data-testid="${testId}"]`).fill(value);
  }
}

export async function submitForm(page: Page, submitButtonTestId: string): Promise<void> {
  await page.locator(`[data-testid="${submitButtonTestId}"]`).waitFor({ state: 'visible' });
  await page.locator(`[data-testid="${submitButtonTestId}"]`).click();
}

// Update all tests to use utilities:
import { fillForm, submitForm } from '../utils/form-helpers';

test('contact form submission', async ({ page }) => {
  await page.goto('/contact');

  await fillForm(page, {
    'name-input': 'John Doe',
    'email-input': 'john@example.com',
    'message-input': 'Hello!',
  });

  await submitForm(page, 'submit-button');
  await expect(page.locator('[data-testid="success"]')).toBeVisible();
});
```

### Example 3: Consolidate Similar Tests

**Input:**
"We have 5 tests that test form validation with different invalid inputs. Consolidate using test.each."

**Before:**
```typescript
test('should show error for empty email', async ({ page }) => {
  await page.goto('/register');
  await page.locator('[data-testid="email"]').fill('');
  await page.locator('[data-testid="submit"]').click();
  await expect(page.locator('[data-testid="email-error"]')).toBeVisible();
});

test('should show error for invalid email', async ({ page }) => {
  await page.goto('/register');
  await page.locator('[data-testid="email"]').fill('invalid');
  await page.locator('[data-testid="submit"]').click();
  await expect(page.locator('[data-testid="email-error"]')).toBeVisible();
});

// ... 3 more similar tests
```

**After:**
```typescript
const invalidEmails = [
  { email: '', description: 'empty email' },
  { email: 'invalid', description: 'invalid format' },
  { email: '@example.com', description: 'missing local part' },
  { email: 'user@', description: 'missing domain' },
  { email: 'user @example.com', description: 'space in email' },
];

test.describe('Email validation', () => {
  for (const { email, description } of invalidEmails) {
    test(`should show error for ${description}`, async ({ page }) => {
      await page.goto('/register');
      await page.locator('[data-testid="email"]').fill(email);
      await page.locator('[data-testid="submit"]').click();
      await expect(page.locator('[data-testid="email-error"]')).toBeVisible();
    });
  }
});
```

### Example 4: Improve Flaky Test

**Input:**
"Test 'user dashboard loads' fails intermittently with 'element not found' error."

**Analysis:**
```typescript
// Current test (flaky):
test('user dashboard loads', async ({ page }) => {
  await page.goto('/dashboard');
  await expect(page.locator('[data-testid="welcome-message"]')).toBeVisible();
  await expect(page.locator('[data-testid="stats-card"]')).toHaveCount(4);
});

// Issue: Not waiting for data to load
```

**Solution:**
```typescript
test('user dashboard loads', async ({ page }) => {
  await page.goto('/dashboard');

  // Wait for page to fully load
  await page.waitForLoadState('networkidle');

  // Wait for API call to complete
  await page.waitForResponse('**/api/dashboard');

  // Now check elements
  await expect(page.locator('[data-testid="welcome-message"]')).toBeVisible({
    timeout: 10000
  });

  // Wait for all stats cards to load
  await page.locator('[data-testid="stats-card"]').first().waitFor({ state: 'visible' });
  await expect(page.locator('[data-testid="stats-card"]')).toHaveCount(4);
});
```

### Example 5: Migrate Test to Use Fixtures

**Input:**
"Tests require authentication but each test logs in manually. Create fixture for authenticated state."

**Solution:**
```typescript
// Create fixtures/auth.ts:
import { test as base, Page } from '@playwright/test';

type AuthFixtures = {
  authenticatedPage: Page;
};

export const test = base.extend<AuthFixtures>({
  authenticatedPage: async ({ page }, use) => {
    // Login once
    await page.goto('/login');
    await page.locator('[data-testid="email"]').fill('test@example.com');
    await page.locator('[data-testid="password"]').fill('password');
    await page.locator('[data-testid="login-button"]').click();
    await page.waitForURL('/dashboard');

    await use(page);

    // Cleanup if needed
  },
});

export { expect } from '@playwright/test';

// Update tests:
// Before
import { test, expect } from '@playwright/test';

test('view profile', async ({ page }) => {
  // Login code...
  await page.goto('/login');
  // ... more login code

  // Actual test
  await page.goto('/profile');
  // ...
});

// After
import { test, expect } from '../fixtures/auth';

test('view profile', async ({ authenticatedPage: page }) => {
  // Already logged in!
  await page.goto('/profile');
  // ... test continues
});
```

## Best Practices

### Refactoring Strategy
1. **Small incremental changes**: Refactor one thing at a time
2. **Run tests frequently**: After each change, verify tests still pass
3. **Use version control**: Commit after each successful refactoring
4. **Keep tests passing**: Never leave tests broken during refactoring
5. **Update related tests together**: Maintain consistency across suite

### Code Quality
1. **DRY principle**: Don't Repeat Yourself - extract common code
2. **Single Responsibility**: Each test tests one thing
3. **Clear naming**: Tests should describe what they verify
4. **Proper structure**: Follow AAA pattern consistently
5. **Type safety**: Use TypeScript types throughout

### Maintenance Patterns
1. **Centralize selectors**: Use Page Objects or constants
2. **Extract utilities**: Common actions go in helper functions
3. **Use fixtures**: Shared setup goes in fixtures
4. **Consistent waits**: Standardize waiting strategies
5. **Error handling**: Consistent approach to expected errors

## Common Issues and Solutions

### Issue 1: Large-Scale Locator Changes
**Problem:** Need to update hundreds of locators across many files

**Solutions:**
- Use IDE find and replace with regex
- Create a migration script
- Update and test incrementally (file by file)
- Use git to track changes and rollback if needed

```bash
# Example: Update all instances in all test files
find tests -name "*.spec.ts" -exec sed -i 's/btn-submit/submit-button/g' {} +

# Verify changes
git diff

# Run tests
npx playwright test
```

### Issue 2: Breaking Tests During Refactoring
**Problem:** Tests fail after refactoring

**Solutions:**
- Refactor smaller sections at a time
- Keep one version working while refactoring
- Use feature flags for gradual migration
- Maintain backward compatibility during transition

### Issue 3: Inconsistent Patterns Across Tests
**Problem:** Different tests use different approaches

**Solutions:**
- Document standard patterns in team guidelines
- Create templates for common test scenarios
- Use linting rules to enforce consistency
- Conduct code reviews to maintain standards
- Gradually migrate old tests to new patterns

### Issue 4: Difficult to Extract Common Code
**Problem:** Tests are similar but not identical

**Solutions:**
- Identify the varying parts and parameterize them
- Use fixtures with parameters
- Create flexible utility functions
- Consider builder pattern for complex setups

```typescript
// Flexible utility with options
async function performLogin(
  page: Page,
  options: {
    email?: string;
    password?: string;
    rememberMe?: boolean;
    expectSuccess?: boolean;
  } = {}
) {
  const {
    email = 'default@example.com',
    password = 'password',
    rememberMe = false,
    expectSuccess = true,
  } = options;

  await page.goto('/login');
  await page.locator('[data-testid="email"]').fill(email);
  await page.locator('[data-testid="password"]').fill(password);

  if (rememberMe) {
    await page.locator('[data-testid="remember-me"]').check();
  }

  await page.locator('[data-testid="login-button"]').click();

  if (expectSuccess) {
    await page.waitForURL('/dashboard');
  }
}
```

### Issue 5: Tests Become Over-Abstracted
**Problem:** Too many layers of abstraction make tests hard to understand

**Solutions:**
- Balance DRY with readability
- Keep tests readable - it's OK to have some duplication
- Don't abstract everything - abstract common patterns
- Inline simple operations rather than creating tiny utilities
- Document complex abstractions

## Resources

The `resources/` directory contains helpful references:
- `refactoring-patterns.md` - Common refactoring patterns for tests
- `migration-guide.md` - Guide for migrating tests to new patterns
- `best-practices.md` - Testing best practices checklist
