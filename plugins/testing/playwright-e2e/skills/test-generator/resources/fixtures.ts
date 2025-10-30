import { test as base, Page } from '@playwright/test';

/**
 * Custom Fixtures for Playwright Tests
 *
 * Fixtures provide a way to set up test preconditions and share
 * common setup logic across tests. They ensure test isolation
 * and reduce boilerplate code.
 */

// Define custom fixture types
type MyFixtures = {
  authenticatedPage: Page;
  testUser: {
    email: string;
    password: string;
    name: string;
  };
};

/**
 * Extend the base test with custom fixtures
 */
export const test = base.extend<MyFixtures>({
  /**
   * Fixture: Authenticated Page
   *
   * Provides a page that is already logged in with a test user.
   * Use this when you need to test features that require authentication.
   *
   * Usage:
   *   test('should view profile', async ({ authenticatedPage }) => {
   *     await authenticatedPage.goto('/profile');
   *     // Test authenticated features
   *   });
   */
  authenticatedPage: async ({ page }, use) => {
    // Setup: Perform login
    await page.goto('/login');

    // Wait for login form to be visible
    await page.locator('[data-testid="login-form"]').waitFor();

    // Fill in credentials
    await page.locator('[data-testid="email-input"]').fill('test@example.com');
    await page.locator('[data-testid="password-input"]').fill('TestPassword123');

    // Submit login form
    await page.locator('[data-testid="login-button"]').click();

    // Wait for successful login (redirect to dashboard)
    await page.waitForURL('/dashboard');

    // Verify login success
    await page.locator('[data-testid="user-menu"]').waitFor();

    // Provide the authenticated page to the test
    await use(page);

    // Teardown: Logout (optional)
    // await page.locator('[data-testid="logout-button"]').click();
  },

  /**
   * Fixture: Test User
   *
   * Provides consistent test user data across tests.
   * Use this when you need user credentials or information.
   *
   * Usage:
   *   test('should register user', async ({ page, testUser }) => {
   *     await page.locator('[data-testid="email"]').fill(testUser.email);
   *   });
   */
  testUser: async ({}, use) => {
    const user = {
      email: 'test@example.com',
      password: 'TestPassword123',
      name: 'Test User',
    };

    await use(user);
  },
});

export { expect } from '@playwright/test';

/**
 * Additional Fixture Examples:
 *
 * 1. Database Setup Fixture:
 *    dbContext: async ({}, use) => {
 *      const db = await setupTestDatabase();
 *      await use(db);
 *      await db.cleanup();
 *    }
 *
 * 2. API Context Fixture:
 *    apiContext: async ({ playwright }, use) => {
 *      const context = await playwright.request.newContext({
 *        baseURL: 'https://api.example.com',
 *        extraHTTPHeaders: { 'Authorization': 'Bearer token' }
 *      });
 *      await use(context);
 *      await context.dispose();
 *    }
 *
 * 3. Test Data Fixture:
 *    testProduct: async ({}, use) => {
 *      const product = {
 *        name: 'Test Product',
 *        price: 99.99,
 *        sku: 'TEST-001'
 *      };
 *      await use(product);
 *    }
 *
 * 4. Viewport Fixture:
 *    mobileViewport: async ({ page }, use) => {
 *      await page.setViewportSize({ width: 375, height: 667 });
 *      await use(page);
 *    }
 *
 * 5. Mock Data Fixture:
 *    mockApiResponses: async ({ page }, use) => {
 *      await page.route('**/api/users', route => {
 *        route.fulfill({ json: [{ id: 1, name: 'Test User' }] });
 *      });
 *      await use(page);
 *    }
 */
