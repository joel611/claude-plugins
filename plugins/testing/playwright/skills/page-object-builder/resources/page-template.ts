import { Page, Locator } from '@playwright/test';

/**
 * Page Object Model for [Page Name]
 *
 * Description: [Brief description of what this page represents]
 *
 * Key functionality:
 * - [Key function 1]
 * - [Key function 2]
 * - [Key function 3]
 */
export class PageName {
  readonly page: Page;

  // ============================================
  // LOCATORS
  // ============================================
  // Group related locators together with comments

  // Section 1: [e.g., Form Elements]
  readonly elementName: Locator;
  readonly anotherElement: Locator;

  // Section 2: [e.g., Navigation]
  readonly navElement: Locator;

  /**
   * Constructor: Initialize page object with locators
   * @param page - Playwright Page object
   */
  constructor(page: Page) {
    this.page = page;

    // Initialize all locators using data-testid
    this.elementName = page.locator('[data-testid="element-name"]');
    this.anotherElement = page.locator('[data-testid="another-element"]');
    this.navElement = page.locator('[data-testid="nav-element"]');
  }

  // ============================================
  // NAVIGATION
  // ============================================

  /**
   * Navigate to this page
   */
  async goto(): Promise<void> {
    await this.page.goto('/page-url');
    await this.page.waitForLoadState('domcontentloaded');
  }

  // ============================================
  // ACTIONS
  // ============================================

  /**
   * Perform a specific action
   * @param param - Description of parameter
   */
  async performAction(param: string): Promise<void> {
    await this.elementName.waitFor({ state: 'visible' });
    await this.elementName.click();
  }

  /**
   * Fill a form with data
   * @param data - Form data object
   */
  async fillForm(data: { field1: string; field2: string }): Promise<void> {
    await this.elementName.fill(data.field1);
    await this.anotherElement.fill(data.field2);
  }

  // ============================================
  // GETTERS (for assertions in tests)
  // ============================================

  /**
   * Get element for assertions
   */
  getElement(): Locator {
    return this.elementName;
  }

  /**
   * Get text content of an element
   */
  async getTextContent(): Promise<string> {
    const text = await this.elementName.textContent();
    return text?.trim() || '';
  }

  /**
   * Check if element is visible
   */
  async isElementVisible(): Promise<boolean> {
    try {
      await this.elementName.waitFor({ state: 'visible', timeout: 2000 });
      return true;
    } catch {
      return false;
    }
  }
}

/**
 * Required data-testid values:
 * - element-name: [Description of element]
 * - another-element: [Description of element]
 * - nav-element: [Description of element]
 */
