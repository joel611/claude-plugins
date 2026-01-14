import { Page, Locator } from '@playwright/test';

/**
 * Component Object Model for [Component Name]
 *
 * Description: Reusable component that appears on multiple pages
 * Example: Navigation bar, modal dialog, toast notification, etc.
 *
 * Usage:
 * ```typescript
 * const component = new ComponentName(page);
 * await component.performAction();
 * ```
 */
export class ComponentName {
  readonly page: Page;

  // Component container
  readonly container: Locator;

  // Component elements
  readonly element1: Locator;
  readonly element2: Locator;

  /**
   * Constructor: Initialize component with page and optional container selector
   * @param page - Playwright Page object
   * @param containerTestId - Optional data-testid for component container
   */
  constructor(page: Page, containerTestId = 'component-container') {
    this.page = page;
    this.container = page.locator(`[data-testid="${containerTestId}"]`);

    // Scoped locators within the component
    this.element1 = this.container.locator('[data-testid="element-1"]');
    this.element2 = this.container.locator('[data-testid="element-2"]');
  }

  /**
   * Wait for component to be visible
   */
  async waitForComponent(): Promise<void> {
    await this.container.waitFor({ state: 'visible' });
  }

  /**
   * Check if component is visible
   */
  async isVisible(): Promise<boolean> {
    try {
      await this.container.waitFor({ state: 'visible', timeout: 2000 });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Component-specific action
   */
  async performAction(): Promise<void> {
    await this.waitForComponent();
    await this.element1.click();
  }

  // Getters
  getContainer(): Locator {
    return this.container;
  }
}

/**
 * Example: Modal Dialog Component
 */
export class ModalDialog {
  readonly page: Page;
  readonly modal: Locator;
  readonly title: Locator;
  readonly closeButton: Locator;
  readonly confirmButton: Locator;
  readonly cancelButton: Locator;

  constructor(page: Page) {
    this.page = page;
    this.modal = page.locator('[data-testid="modal-dialog"]');
    this.title = this.modal.locator('[data-testid="modal-title"]');
    this.closeButton = this.modal.locator('[data-testid="modal-close"]');
    this.confirmButton = this.modal.locator('[data-testid="modal-confirm"]');
    this.cancelButton = this.modal.locator('[data-testid="modal-cancel"]');
  }

  async waitForModal(): Promise<void> {
    await this.modal.waitFor({ state: 'visible' });
  }

  async close(): Promise<void> {
    await this.closeButton.click();
    await this.modal.waitFor({ state: 'hidden' });
  }

  async confirm(): Promise<void> {
    await this.confirmButton.click();
    await this.modal.waitFor({ state: 'hidden' });
  }

  async cancel(): Promise<void> {
    await this.cancelButton.click();
    await this.modal.waitFor({ state: 'hidden' });
  }

  async getTitle(): Promise<string> {
    const text = await this.title.textContent();
    return text?.trim() || '';
  }

  getModal(): Locator {
    return this.modal;
  }
}

/**
 * Example: Navigation Bar Component
 */
export class NavigationBar {
  readonly page: Page;
  readonly nav: Locator;
  readonly logo: Locator;
  readonly menuItems: Locator;
  readonly userMenu: Locator;
  readonly searchBar: Locator;

  constructor(page: Page) {
    this.page = page;
    this.nav = page.locator('[data-testid="navbar"]');
    this.logo = this.nav.locator('[data-testid="logo"]');
    this.menuItems = this.nav.locator('[data-testid="menu-item"]');
    this.userMenu = this.nav.locator('[data-testid="user-menu"]');
    this.searchBar = this.nav.locator('[data-testid="search-bar"]');
  }

  async clickLogo(): Promise<void> {
    await this.logo.click();
  }

  async clickMenuItem(name: string): Promise<void> {
    await this.menuItems.filter({ hasText: name }).click();
  }

  async openUserMenu(): Promise<void> {
    await this.userMenu.click();
  }

  async search(query: string): Promise<void> {
    await this.searchBar.fill(query);
    await this.page.keyboard.press('Enter');
  }

  getNav(): Locator {
    return this.nav;
  }
}
