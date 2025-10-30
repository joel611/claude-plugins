import { test, expect } from '@playwright/test';

/**
 * Test Suite: [Feature Name]
 *
 * Description: [Brief description of what this test suite covers]
 */

test.describe('[Feature Name]', () => {
  /**
   * Setup: Runs before each test in this describe block
   */
  test.beforeEach(async ({ page }) => {
    // Navigate to the starting page
    await page.goto('/');

    // Wait for page to be ready
    await page.waitForLoadState('domcontentloaded');
  });

  /**
   * Test: [Specific behavior being tested]
   *
   * Scenario: [User story or use case]
   * Expected: [What should happen]
   */
  test('should [expected behavior]', async ({ page }) => {
    // ============================================
    // ARRANGE: Setup test preconditions
    // ============================================
    // Navigate to specific page (if needed)
    // await page.goto('/specific-page');

    // Verify page is loaded
    // await expect(page.locator('[data-testid="page-container"]')).toBeVisible();

    // ============================================
    // ACT: Perform the action being tested
    // ============================================
    // Interact with elements using data-testid
    // await page.locator('[data-testid="input-field"]').fill('test value');
    // await page.locator('[data-testid="submit-button"]').click();

    // ============================================
    // ASSERT: Verify the expected outcome
    // ============================================
    // Check that the expected result is visible
    // await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
    // await expect(page.locator('[data-testid="result"]')).toContainText('Expected text');
  });

  /**
   * Test: [Another specific behavior]
   */
  test('should [another expected behavior]', async ({ page }) => {
    // Arrange

    // Act

    // Assert
  });
});

/**
 * Best Practices Checklist:
 * ✅ Use only data-testid locators
 * ✅ Follow AAA pattern (Arrange-Act-Assert)
 * ✅ Use descriptive test names starting with "should"
 * ✅ Add comments for complex logic
 * ✅ Use explicit waits (waitForSelector, waitForLoadState)
 * ✅ No hardcoded waits (waitForTimeout)
 * ✅ One scenario per test
 * ✅ Tests are independent and isolated
 * ✅ Use TypeScript types
 * ✅ Add meaningful assertions
 */
