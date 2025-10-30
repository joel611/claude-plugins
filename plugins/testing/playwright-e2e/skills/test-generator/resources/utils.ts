import { Page, Locator, expect } from '@playwright/test';

/**
 * Utility Functions for Playwright Tests
 *
 * Common helpers to reduce boilerplate and improve test readability.
 * All functions follow best practices: data-testid locators, explicit waits,
 * and proper error handling.
 */

/**
 * Fill a form with multiple fields at once
 *
 * @param page - Playwright page object
 * @param fields - Object mapping data-testid to values
 *
 * @example
 * await fillForm(page, {
 *   'username-input': 'testuser',
 *   'password-input': 'password123',
 *   'email-input': 'test@example.com'
 * });
 */
export async function fillForm(
  page: Page,
  fields: Record<string, string>
): Promise<void> {
  for (const [testId, value] of Object.entries(fields)) {
    const locator = page.locator(`[data-testid="${testId}"]`);
    await locator.waitFor({ state: 'visible' });
    await locator.fill(value);
  }
}

/**
 * Click and wait for navigation
 *
 * @param page - Playwright page object
 * @param testId - data-testid of the element to click
 * @param expectedUrl - Optional URL pattern to wait for
 *
 * @example
 * await clickAndNavigate(page, 'submit-button', '/dashboard');
 */
export async function clickAndNavigate(
  page: Page,
  testId: string,
  expectedUrl?: string | RegExp
): Promise<void> {
  const locator = page.locator(`[data-testid="${testId}"]`);
  await locator.waitFor({ state: 'visible' });

  await Promise.all([
    expectedUrl ? page.waitForURL(expectedUrl) : page.waitForLoadState('networkidle'),
    locator.click(),
  ]);
}

/**
 * Wait for element and verify visibility
 *
 * @param page - Playwright page object
 * @param testId - data-testid of the element
 * @param timeout - Optional timeout in milliseconds
 *
 * @example
 * await waitForElement(page, 'success-message');
 */
export async function waitForElement(
  page: Page,
  testId: string,
  timeout = 10000
): Promise<Locator> {
  const locator = page.locator(`[data-testid="${testId}"]`);
  await locator.waitFor({ state: 'visible', timeout });
  return locator;
}

/**
 * Select option from dropdown
 *
 * @param page - Playwright page object
 * @param testId - data-testid of the select element
 * @param value - Value to select
 *
 * @example
 * await selectOption(page, 'country-select', 'USA');
 */
export async function selectOption(
  page: Page,
  testId: string,
  value: string
): Promise<void> {
  const locator = page.locator(`[data-testid="${testId}"]`);
  await locator.waitFor({ state: 'visible' });
  await locator.selectOption(value);
}

/**
 * Check if element exists without throwing error
 *
 * @param page - Playwright page object
 * @param testId - data-testid of the element
 * @returns true if element exists, false otherwise
 *
 * @example
 * if (await elementExists(page, 'error-message')) {
 *   // Handle error state
 * }
 */
export async function elementExists(
  page: Page,
  testId: string
): Promise<boolean> {
  try {
    await page.locator(`[data-testid="${testId}"]`).waitFor({
      state: 'visible',
      timeout: 2000,
    });
    return true;
  } catch {
    return false;
  }
}

/**
 * Wait for element to disappear
 *
 * @param page - Playwright page object
 * @param testId - data-testid of the element
 * @param timeout - Optional timeout in milliseconds
 *
 * @example
 * await waitForElementToDisappear(page, 'loading-spinner');
 */
export async function waitForElementToDisappear(
  page: Page,
  testId: string,
  timeout = 10000
): Promise<void> {
  const locator = page.locator(`[data-testid="${testId}"]`);
  await locator.waitFor({ state: 'hidden', timeout });
}

/**
 * Get text content of an element
 *
 * @param page - Playwright page object
 * @param testId - data-testid of the element
 * @returns Text content of the element
 *
 * @example
 * const username = await getTextContent(page, 'username-display');
 */
export async function getTextContent(
  page: Page,
  testId: string
): Promise<string> {
  const locator = page.locator(`[data-testid="${testId}"]`);
  await locator.waitFor({ state: 'visible' });
  const text = await locator.textContent();
  return text?.trim() || '';
}

/**
 * Upload file to input
 *
 * @param page - Playwright page object
 * @param testId - data-testid of the file input
 * @param filePath - Path to the file to upload
 *
 * @example
 * await uploadFile(page, 'file-input', './test-data/sample.pdf');
 */
export async function uploadFile(
  page: Page,
  testId: string,
  filePath: string
): Promise<void> {
  const locator = page.locator(`[data-testid="${testId}"]`);
  await locator.waitFor({ state: 'attached' });
  await locator.setInputFiles(filePath);
}

/**
 * Check or uncheck a checkbox
 *
 * @param page - Playwright page object
 * @param testId - data-testid of the checkbox
 * @param checked - Whether to check or uncheck
 *
 * @example
 * await toggleCheckbox(page, 'terms-checkbox', true);
 */
export async function toggleCheckbox(
  page: Page,
  testId: string,
  checked: boolean
): Promise<void> {
  const locator = page.locator(`[data-testid="${testId}"]`);
  await locator.waitFor({ state: 'visible' });

  const isChecked = await locator.isChecked();
  if (isChecked !== checked) {
    await locator.click();
  }
}

/**
 * Retry an action with exponential backoff
 *
 * @param action - Async function to retry
 * @param maxRetries - Maximum number of retries
 * @param initialDelay - Initial delay in milliseconds
 *
 * @example
 * await retryWithBackoff(async () => {
 *   await page.locator('[data-testid="submit"]').click();
 * }, 3, 1000);
 */
export async function retryWithBackoff<T>(
  action: () => Promise<T>,
  maxRetries = 3,
  initialDelay = 1000
): Promise<T> {
  let lastError: Error | undefined;

  for (let i = 0; i < maxRetries; i++) {
    try {
      return await action();
    } catch (error) {
      lastError = error as Error;
      if (i < maxRetries - 1) {
        const delay = initialDelay * Math.pow(2, i);
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }
  }

  throw lastError;
}

/**
 * Wait for API response
 *
 * @param page - Playwright page object
 * @param urlPattern - URL pattern to wait for
 * @param action - Action that triggers the API call
 * @returns Response data
 *
 * @example
 * const response = await waitForApiResponse(
 *   page,
 *   '**/api/users',
 *   () => page.locator('[data-testid="load-users"]').click()
 * );
 */
export async function waitForApiResponse<T = any>(
  page: Page,
  urlPattern: string | RegExp,
  action: () => Promise<void>
): Promise<T> {
  const [response] = await Promise.all([
    page.waitForResponse(urlPattern),
    action(),
  ]);

  return await response.json();
}

/**
 * Take screenshot with timestamp
 *
 * @param page - Playwright page object
 * @param name - Base name for the screenshot
 *
 * @example
 * await takeTimestampedScreenshot(page, 'error-state');
 * // Saves as: error-state-2024-01-15T10-30-45.png
 */
export async function takeTimestampedScreenshot(
  page: Page,
  name: string
): Promise<void> {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  await page.screenshot({ path: `${name}-${timestamp}.png`, fullPage: true });
}

/**
 * Assert multiple elements are visible
 *
 * @param page - Playwright page object
 * @param testIds - Array of data-testid values
 *
 * @example
 * await assertElementsVisible(page, ['header', 'nav', 'footer']);
 */
export async function assertElementsVisible(
  page: Page,
  testIds: string[]
): Promise<void> {
  for (const testId of testIds) {
    const locator = page.locator(`[data-testid="${testId}"]`);
    await expect(locator).toBeVisible();
  }
}

/**
 * Get all text contents from multiple elements
 *
 * @param page - Playwright page object
 * @param testId - data-testid of elements (can match multiple)
 * @returns Array of text contents
 *
 * @example
 * const productNames = await getAllTextContents(page, 'product-name');
 */
export async function getAllTextContents(
  page: Page,
  testId: string
): Promise<string[]> {
  const locator = page.locator(`[data-testid="${testId}"]`);
  await locator.first().waitFor({ state: 'visible' });
  return await locator.allTextContents();
}
