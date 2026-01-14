import { Page, Locator } from '@playwright/test';

/**
 * Base Page Object
 *
 * Contains common functionality shared across all page objects.
 * Extend this class for your specific page objects to avoid duplication.
 *
 * Usage:
 * ```typescript
 * export class LoginPage extends BasePage {
 *   constructor(page: Page) {
 *     super(page);
 *   }
 *
 *   async login() {
 *     await this.fillInput('username', 'user@example.com');
 *   }
 * }
 * ```
 */
export class BasePage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  /**
   * Navigate to a URL
   */
  async goto(url: string): Promise<void> {
    await this.page.goto(url);
    await this.page.waitForLoadState('domcontentloaded');
  }

  /**
   * Get locator by data-testid
   */
  getByTestId(testId: string): Locator {
    return this.page.locator(`[data-testid="${testId}"]`);
  }

  /**
   * Click element by data-testid
   */
  async clickByTestId(testId: string): Promise<void> {
    const locator = this.getByTestId(testId);
    await locator.waitFor({ state: 'visible' });
    await locator.click();
  }

  /**
   * Fill input by data-testid
   */
  async fillInput(testId: string, value: string): Promise<void> {
    const locator = this.getByTestId(testId);
    await locator.waitFor({ state: 'visible' });
    await locator.fill(value);
  }

  /**
   * Get text content by data-testid
   */
  async getTextByTestId(testId: string): Promise<string> {
    const locator = this.getByTestId(testId);
    const text = await locator.textContent();
    return text?.trim() || '';
  }

  /**
   * Check if element is visible by data-testid
   */
  async isVisibleByTestId(testId: string): Promise<boolean> {
    try {
      await this.getByTestId(testId).waitFor({
        state: 'visible',
        timeout: 2000,
      });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Wait for element by data-testid
   */
  async waitForElement(testId: string, timeout = 10000): Promise<Locator> {
    const locator = this.getByTestId(testId);
    await locator.waitFor({ state: 'visible', timeout });
    return locator;
  }

  /**
   * Wait for element to disappear
   */
  async waitForElementToDisappear(
    testId: string,
    timeout = 10000
  ): Promise<void> {
    const locator = this.getByTestId(testId);
    await locator.waitFor({ state: 'hidden', timeout });
  }

  /**
   * Fill a form with multiple fields
   */
  async fillForm(fields: Record<string, string>): Promise<void> {
    for (const [testId, value] of Object.entries(fields)) {
      await this.fillInput(testId, value);
    }
  }

  /**
   * Click and wait for navigation
   */
  async clickAndNavigate(
    testId: string,
    expectedUrl?: string | RegExp
  ): Promise<void> {
    const locator = this.getByTestId(testId);
    await locator.waitFor({ state: 'visible' });

    await Promise.all([
      expectedUrl
        ? this.page.waitForURL(expectedUrl)
        : this.page.waitForLoadState('networkidle'),
      locator.click(),
    ]);
  }

  /**
   * Select option from dropdown
   */
  async selectOption(testId: string, value: string): Promise<void> {
    const locator = this.getByTestId(testId);
    await locator.waitFor({ state: 'visible' });
    await locator.selectOption(value);
  }

  /**
   * Check/uncheck checkbox
   */
  async toggleCheckbox(testId: string, checked: boolean): Promise<void> {
    const locator = this.getByTestId(testId);
    await locator.waitFor({ state: 'visible' });

    const isChecked = await locator.isChecked();
    if (isChecked !== checked) {
      await locator.click();
    }
  }

  /**
   * Upload file
   */
  async uploadFile(testId: string, filePath: string): Promise<void> {
    const locator = this.getByTestId(testId);
    await locator.waitFor({ state: 'attached' });
    await locator.setInputFiles(filePath);
  }

  /**
   * Get all text contents from multiple elements
   */
  async getAllTextsByTestId(testId: string): Promise<string[]> {
    const locator = this.getByTestId(testId);
    await locator.first().waitFor({ state: 'visible' });
    return await locator.allTextContents();
  }

  /**
   * Get element count by data-testid
   */
  async getCountByTestId(testId: string): Promise<number> {
    return await this.getByTestId(testId).count();
  }

  /**
   * Wait for API response
   */
  async waitForApiResponse<T = any>(
    urlPattern: string | RegExp,
    action: () => Promise<void>
  ): Promise<T> {
    const [response] = await Promise.all([
      this.page.waitForResponse(urlPattern),
      action(),
    ]);

    return await response.json();
  }

  /**
   * Get current URL
   */
  getCurrentUrl(): string {
    return this.page.url();
  }

  /**
   * Reload page
   */
  async reload(): Promise<void> {
    await this.page.reload();
    await this.page.waitForLoadState('domcontentloaded');
  }

  /**
   * Go back in browser history
   */
  async goBack(): Promise<void> {
    await this.page.goBack();
    await this.page.waitForLoadState('domcontentloaded');
  }

  /**
   * Go forward in browser history
   */
  async goForward(): Promise<void> {
    await this.page.goForward();
    await this.page.waitForLoadState('domcontentloaded');
  }

  /**
   * Take screenshot
   */
  async takeScreenshot(name: string): Promise<void> {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    await this.page.screenshot({
      path: `${name}-${timestamp}.png`,
      fullPage: true,
    });
  }
}

/**
 * Example usage:
 *
 * export class LoginPage extends BasePage {
 *   readonly usernameInput: Locator;
 *   readonly passwordInput: Locator;
 *   readonly loginButton: Locator;
 *
 *   constructor(page: Page) {
 *     super(page);
 *     this.usernameInput = this.getByTestId('username-input');
 *     this.passwordInput = this.getByTestId('password-input');
 *     this.loginButton = this.getByTestId('login-button');
 *   }
 *
 *   async goto(): Promise<void> {
 *     await super.goto('/login');
 *   }
 *
 *   async login(username: string, password: string): Promise<void> {
 *     await this.fillForm({
 *       'username-input': username,
 *       'password-input': password,
 *     });
 *     await this.clickAndNavigate('login-button', '/dashboard');
 *   }
 * }
 */
