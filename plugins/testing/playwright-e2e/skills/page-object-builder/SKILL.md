# Page Object Builder Skill

## Purpose

Create maintainable and reusable Page Object Models (POMs) for Playwright tests. Generates TypeScript classes that encapsulate page-specific locators and actions, following the Page Object Model design pattern with data-testid locators exclusively.

## When to Use This Skill

Use this skill when you need to:
- Create a Page Object Model for a specific page or component
- Refactor tests to use the POM pattern
- Build reusable page classes for complex applications
- Encapsulate page-specific logic and locators
- Improve test maintainability and reduce duplication

Do NOT use this skill when:
- Writing simple one-off tests (use test-generator skill)
- Debugging existing tests (use test-debugger skill)
- Refactoring existing POMs (use test-maintainer skill)

## Prerequisites

Before using this skill:
1. Understanding of the page structure and elements
2. Knowledge of user interactions on the page
3. List of data-testid values for page elements (or ability to suggest them)
4. Playwright installed in the project
5. Basic understanding of TypeScript classes

## Instructions

### Step 1: Identify Page Information

Gather from the user:
- **Page name** or component name
- **Page URL** or route
- **Key elements** on the page (buttons, inputs, text, etc.)
- **Common actions** users perform on the page
- **data-testid values** for all elements (or help define them)

### Step 2: Plan Page Object Structure

Determine:
- **Class name** (e.g., `LoginPage`, `DashboardPage`, `CheckoutPage`)
- **Properties**: Locators for all page elements
- **Methods**: Actions users can perform (login, addToCart, etc.)
- **Getters**: Read-only properties for assertions
- **Navigation**: How to reach this page

### Step 3: Create Page Object Class

Generate a TypeScript class with:

**Structure:**
```typescript
import { Page, Locator } from '@playwright/test';

export class PageName {
  readonly page: Page;

  // Locators
  readonly elementName: Locator;

  constructor(page: Page) {
    this.page = page;
    this.elementName = page.locator('[data-testid="element-name"]');
  }

  // Navigation
  async goto() {
    await this.page.goto('/page-url');
  }

  // Actions
  async performAction() {
    await this.elementName.click();
  }

  // Getters for assertions
  getElement() {
    return this.elementName;
  }
}
```

**Key Requirements:**
1. All locators use data-testid (MANDATORY)
2. Locators are readonly properties
3. Constructor accepts Page object
4. Include goto() method for navigation
5. Action methods are async and return Promise<void>
6. Getter methods for elements that need assertions
7. Use TypeScript types
8. Add JSDoc comments for complex methods

### Step 4: Define Locators

For each element:
```typescript
readonly elementName: Locator;

constructor(page: Page) {
  this.page = page;
  this.elementName = page.locator('[data-testid="element-name"]');
}
```

**Naming Convention:**
- Use camelCase for properties
- Descriptive names (e.g., `submitButton`, `emailInput`, `errorMessage`)
- Suffix with element type when helpful (Button, Input, Message, Link)

### Step 5: Implement Action Methods

For each user action:
```typescript
/**
 * Descriptive action name
 * @param param - Parameter description if needed
 */
async actionName(param?: string): Promise<void> {
  // Wait for element if needed
  await this.element.waitFor({ state: 'visible' });

  // Perform action
  await this.element.click();
  // or
  await this.element.fill(param);
}
```

**Common Actions:**
- Form filling: `async fillForm(data: FormData)`
- Button clicks: `async clickButton()`
- Navigation: `async navigateTo(section: string)`
- Complex workflows: `async completeCheckout(details: CheckoutDetails)`

### Step 6: Add Getter Methods

For elements that tests will assert against:
```typescript
getElementName(): Locator {
  return this.elementName;
}

async getTextContent(): Promise<string> {
  return await this.element.textContent() || '';
}

async isElementVisible(): Promise<boolean> {
  return await this.element.isVisible();
}
```

### Step 7: Validate Page Object

Ensure the Page Object includes:
- [ ] All locators use data-testid
- [ ] Locators are readonly
- [ ] All methods are async
- [ ] Constructor accepts Page
- [ ] goto() method for navigation
- [ ] JSDoc comments for public methods
- [ ] TypeScript types for parameters
- [ ] Meaningful method names
- [ ] No test assertions in POM (only actions and getters)

### Step 8: Provide Usage Example

Show how to use the Page Object in tests:
```typescript
import { test, expect } from '@playwright/test';
import { PageName } from './page-objects/PageName';

test('test description', async ({ page }) => {
  const pageName = new PageName(page);

  await pageName.goto();
  await pageName.performAction();
  await expect(pageName.getElement()).toBeVisible();
});
```

## Examples

### Example 1: Login Page Object

**Input:**
"Create a Page Object for the login page with username, password fields, login button, and error message."

**Output:**
```typescript
import { Page, Locator } from '@playwright/test';

/**
 * Page Object Model for the Login Page
 *
 * Handles user authentication flow including:
 * - Filling login credentials
 * - Submitting the form
 * - Accessing error messages
 */
export class LoginPage {
  readonly page: Page;

  // Locators
  readonly usernameInput: Locator;
  readonly passwordInput: Locator;
  readonly loginButton: Locator;
  readonly errorMessage: Locator;
  readonly forgotPasswordLink: Locator;

  constructor(page: Page) {
    this.page = page;
    this.usernameInput = page.locator('[data-testid="username-input"]');
    this.passwordInput = page.locator('[data-testid="password-input"]');
    this.loginButton = page.locator('[data-testid="login-button"]');
    this.errorMessage = page.locator('[data-testid="error-message"]');
    this.forgotPasswordLink = page.locator('[data-testid="forgot-password-link"]');
  }

  /**
   * Navigate to the login page
   */
  async goto(): Promise<void> {
    await this.page.goto('/login');
    await this.page.waitForLoadState('domcontentloaded');
  }

  /**
   * Perform login with credentials
   * @param username - User's username or email
   * @param password - User's password
   */
  async login(username: string, password: string): Promise<void> {
    await this.usernameInput.waitFor({ state: 'visible' });
    await this.usernameInput.fill(username);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
  }

  /**
   * Fill only the username field
   */
  async fillUsername(username: string): Promise<void> {
    await this.usernameInput.fill(username);
  }

  /**
   * Fill only the password field
   */
  async fillPassword(password: string): Promise<void> {
    await this.passwordInput.fill(password);
  }

  /**
   * Click the login button
   */
  async clickLogin(): Promise<void> {
    await this.loginButton.click();
  }

  /**
   * Click forgot password link
   */
  async clickForgotPassword(): Promise<void> {
    await this.forgotPasswordLink.click();
  }

  /**
   * Get the error message element for assertions
   */
  getErrorMessage(): Locator {
    return this.errorMessage;
  }

  /**
   * Check if error message is visible
   */
  async hasError(): Promise<boolean> {
    try {
      await this.errorMessage.waitFor({ state: 'visible', timeout: 2000 });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Get the text content of the error message
   */
  async getErrorText(): Promise<string> {
    const text = await this.errorMessage.textContent();
    return text?.trim() || '';
  }
}
```

**Usage:**
```typescript
import { test, expect } from '@playwright/test';
import { LoginPage } from './page-objects/LoginPage';

test.describe('Login Flow', () => {
  test('should login successfully with valid credentials', async ({ page }) => {
    const loginPage = new LoginPage(page);

    await loginPage.goto();
    await loginPage.login('user@example.com', 'SecurePass123');

    // Assert navigation to dashboard
    await page.waitForURL('/dashboard');
  });

  test('should show error with invalid credentials', async ({ page }) => {
    const loginPage = new LoginPage(page);

    await loginPage.goto();
    await loginPage.login('invalid@example.com', 'wrongpass');

    // Assert error message
    await expect(loginPage.getErrorMessage()).toBeVisible();
    await expect(loginPage.getErrorMessage()).toContainText('Invalid credentials');
  });
});
```

### Example 2: Product Page Object

**Input:**
"Create a Page Object for a product details page with product name, price, description, quantity selector, add to cart button, and reviews section."

**Output:**
```typescript
import { Page, Locator } from '@playwright/test';

/**
 * Page Object Model for Product Details Page
 *
 * Handles product viewing and purchasing actions including:
 * - Viewing product details
 * - Selecting quantity
 * - Adding to cart
 * - Reading reviews
 */
export class ProductPage {
  readonly page: Page;

  // Product Information Locators
  readonly productName: Locator;
  readonly productPrice: Locator;
  readonly productDescription: Locator;
  readonly productImage: Locator;

  // Purchase Locators
  readonly quantityInput: Locator;
  readonly addToCartButton: Locator;
  readonly buyNowButton: Locator;

  // Reviews Locators
  readonly reviewsSection: Locator;
  readonly reviewItems: Locator;
  readonly averageRating: Locator;

  // Additional Actions
  readonly wishlistButton: Locator;
  readonly shareButton: Locator;

  constructor(page: Page) {
    this.page = page;

    // Product information
    this.productName = page.locator('[data-testid="product-name"]');
    this.productPrice = page.locator('[data-testid="product-price"]');
    this.productDescription = page.locator('[data-testid="product-description"]');
    this.productImage = page.locator('[data-testid="product-image"]');

    // Purchase
    this.quantityInput = page.locator('[data-testid="quantity-input"]');
    this.addToCartButton = page.locator('[data-testid="add-to-cart-button"]');
    this.buyNowButton = page.locator('[data-testid="buy-now-button"]');

    // Reviews
    this.reviewsSection = page.locator('[data-testid="reviews-section"]');
    this.reviewItems = page.locator('[data-testid="review-item"]');
    this.averageRating = page.locator('[data-testid="average-rating"]');

    // Actions
    this.wishlistButton = page.locator('[data-testid="wishlist-button"]');
    this.shareButton = page.locator('[data-testid="share-button"]');
  }

  /**
   * Navigate to a product page by ID
   */
  async goto(productId: string): Promise<void> {
    await this.page.goto(`/products/${productId}`);
    await this.page.waitForLoadState('domcontentloaded');
  }

  /**
   * Set the quantity for purchase
   */
  async setQuantity(quantity: number): Promise<void> {
    await this.quantityInput.waitFor({ state: 'visible' });
    await this.quantityInput.clear();
    await this.quantityInput.fill(quantity.toString());
  }

  /**
   * Add product to cart with specified quantity
   */
  async addToCart(quantity = 1): Promise<void> {
    if (quantity > 1) {
      await this.setQuantity(quantity);
    }
    await this.addToCartButton.waitFor({ state: 'enabled' });
    await this.addToCartButton.click();
  }

  /**
   * Click Buy Now button
   */
  async buyNow(): Promise<void> {
    await this.buyNowButton.click();
  }

  /**
   * Add product to wishlist
   */
  async addToWishlist(): Promise<void> {
    await this.wishlistButton.click();
  }

  /**
   * Click share button
   */
  async shareProduct(): Promise<void> {
    await this.shareButton.click();
  }

  /**
   * Get product name text
   */
  async getProductName(): Promise<string> {
    const text = await this.productName.textContent();
    return text?.trim() || '';
  }

  /**
   * Get product price text
   */
  async getProductPrice(): Promise<string> {
    const text = await this.productPrice.textContent();
    return text?.trim() || '';
  }

  /**
   * Get number of reviews
   */
  async getReviewCount(): Promise<number> {
    return await this.reviewItems.count();
  }

  /**
   * Get average rating text
   */
  async getAverageRating(): Promise<string> {
    const text = await this.averageRating.textContent();
    return text?.trim() || '';
  }

  // Getters for assertions
  getProductNameElement(): Locator {
    return this.productName;
  }

  getProductPriceElement(): Locator {
    return this.productPrice;
  }

  getAddToCartButton(): Locator {
    return this.addToCartButton;
  }

  getReviewsSection(): Locator {
    return this.reviewsSection;
  }
}
```

### Example 3: Dashboard Page with Multiple Sections

**Input:**
"Create a Page Object for a dashboard with header, sidebar navigation, main content area, and user profile dropdown."

**Output:**
```typescript
import { Page, Locator } from '@playwright/test';

/**
 * Page Object Model for Dashboard Page
 *
 * Handles dashboard navigation and interactions including:
 * - Sidebar navigation
 * - User profile actions
 * - Dashboard content
 */
export class DashboardPage {
  readonly page: Page;

  // Header Locators
  readonly header: Locator;
  readonly logo: Locator;
  readonly searchBar: Locator;
  readonly notificationIcon: Locator;
  readonly userProfileDropdown: Locator;

  // Sidebar Locators
  readonly sidebar: Locator;
  readonly homeLink: Locator;
  readonly projectsLink: Locator;
  readonly settingsLink: Locator;
  readonly logoutButton: Locator;

  // Main Content Locators
  readonly mainContent: Locator;
  readonly dashboardTitle: Locator;
  readonly statsCards: Locator;

  // Profile Dropdown Locators
  readonly profileMenu: Locator;
  readonly profileLink: Locator;
  readonly accountSettingsLink: Locator;

  constructor(page: Page) {
    this.page = page;

    // Header
    this.header = page.locator('[data-testid="dashboard-header"]');
    this.logo = page.locator('[data-testid="logo"]');
    this.searchBar = page.locator('[data-testid="search-bar"]');
    this.notificationIcon = page.locator('[data-testid="notification-icon"]');
    this.userProfileDropdown = page.locator('[data-testid="user-profile-dropdown"]');

    // Sidebar
    this.sidebar = page.locator('[data-testid="sidebar"]');
    this.homeLink = page.locator('[data-testid="nav-home"]');
    this.projectsLink = page.locator('[data-testid="nav-projects"]');
    this.settingsLink = page.locator('[data-testid="nav-settings"]');
    this.logoutButton = page.locator('[data-testid="logout-button"]');

    // Main Content
    this.mainContent = page.locator('[data-testid="main-content"]');
    this.dashboardTitle = page.locator('[data-testid="dashboard-title"]');
    this.statsCards = page.locator('[data-testid="stat-card"]');

    // Profile Dropdown
    this.profileMenu = page.locator('[data-testid="profile-menu"]');
    this.profileLink = page.locator('[data-testid="profile-link"]');
    this.accountSettingsLink = page.locator('[data-testid="account-settings-link"]');
  }

  async goto(): Promise<void> {
    await this.page.goto('/dashboard');
    await this.page.waitForLoadState('domcontentloaded');
  }

  /**
   * Navigate using sidebar
   */
  async navigateToHome(): Promise<void> {
    await this.homeLink.click();
  }

  async navigateToProjects(): Promise<void> {
    await this.projectsLink.click();
  }

  async navigateToSettings(): Promise<void> {
    await this.settingsLink.click();
  }

  /**
   * Search functionality
   */
  async search(query: string): Promise<void> {
    await this.searchBar.fill(query);
    await this.page.keyboard.press('Enter');
  }

  /**
   * Profile dropdown actions
   */
  async openProfileDropdown(): Promise<void> {
    await this.userProfileDropdown.click();
    await this.profileMenu.waitFor({ state: 'visible' });
  }

  async navigateToProfile(): Promise<void> {
    await this.openProfileDropdown();
    await this.profileLink.click();
  }

  async navigateToAccountSettings(): Promise<void> {
    await this.openProfileDropdown();
    await this.accountSettingsLink.click();
  }

  async logout(): Promise<void> {
    await this.logoutButton.click();
  }

  /**
   * Get stats count
   */
  async getStatsCount(): Promise<number> {
    return await this.statsCards.count();
  }

  // Getters for assertions
  getHeader(): Locator {
    return this.header;
  }

  getSidebar(): Locator {
    return this.sidebar;
  }

  getMainContent(): Locator {
    return this.mainContent;
  }

  getDashboardTitle(): Locator {
    return this.dashboardTitle;
  }
}
```

## Best Practices

### Page Object Design
1. **Single Responsibility**: Each POM represents one page or component
2. **No Assertions**: POMs should not contain test assertions (use getters instead)
3. **Encapsulation**: Hide implementation details, expose high-level actions
4. **Reusability**: Design methods to be reused across multiple tests
5. **Clear Naming**: Use descriptive names for classes, properties, and methods

### Locator Management
1. **data-testid Only**: All locators must use data-testid attribute
2. **Readonly**: Declare all locators as readonly
3. **Initialize in Constructor**: All locators defined in constructor
4. **Descriptive Names**: Use meaningful names that describe the element
5. **Group Related**: Group related locators together (e.g., all form fields)

### Method Design
1. **Async Methods**: All action methods should be async
2. **Return Types**: Action methods return Promise<void>, getters return data
3. **Parameters**: Use TypeScript types for all parameters
4. **Documentation**: Add JSDoc comments for complex methods
5. **Atomic Actions**: Methods should perform single, focused actions

### Organization
1. **File Location**: Store POMs in `page-objects/` or `pages/` directory
2. **One Class Per File**: Each POM in its own file
3. **Export Class**: Export the class as default or named export
4. **Index File**: Consider creating index.ts for easier imports
5. **Naming Convention**: Use PascalCase with "Page" suffix

## Common Issues and Solutions

### Issue 1: Too Many Locators
**Problem:** Page Object has 30+ locators making it hard to maintain

**Solutions:**
- Break down into smaller component-based POMs
- Group related elements into sub-objects
- Consider component composition pattern
- Focus on elements actually used in tests
- Create separate POMs for complex sections

### Issue 2: Tests Still Break When UI Changes
**Problem:** Tests fail despite using POMs

**Solutions:**
- Ensure ONLY data-testid locators are used (not CSS/XPath)
- Coordinate with developers to keep data-testid stable
- Use semantic testid names that reflect purpose, not implementation
- Document all required data-testid values for developers
- Update POM centrally when testid changes

### Issue 3: Duplicate Code Across POMs
**Problem:** Same logic repeated in multiple Page Objects

**Solutions:**
- Extract common actions to utility functions
- Create base Page class with shared methods
- Use composition over inheritance when possible
- Create reusable components for common UI elements
- Consider creating a ComponentPage for shared components

### Issue 4: Methods Too Complex
**Problem:** Action methods contain complex logic and are hard to test

**Solutions:**
- Break down into smaller, atomic methods
- Extract complex logic to private helper methods
- Keep public methods simple and focused
- Use composition of smaller actions
- Add clear comments for multi-step workflows

### Issue 5: Hard to Test Page Objects
**Problem:** Can't verify Page Object behavior without full tests

**Solutions:**
- Keep POMs simple (locators + actions only)
- Avoid business logic in POMs
- Use type-safe interfaces
- Create example usage in comments
- Focus on thin wrappers over Playwright API

## Resources

The `resources/` directory contains templates for common patterns:
- `page-template.ts` - Basic Page Object structure
- `component-template.ts` - Component-based Page Object
- `base-page.ts` - Base class with common functionality
