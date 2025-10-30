# Test Refactoring Patterns

## Pattern 1: Extract Method

**When:** Duplicate code appears in multiple tests

**Before:**
```typescript
test('test 1', async ({ page }) => {
  await page.locator('[data-testid="email"]').fill('user@example.com');
  await page.locator('[data-testid="password"]').fill('password');
  await page.locator('[data-testid="login"]').click();
  await page.waitForURL('/dashboard');
  // test continues...
});

test('test 2', async ({ page }) => {
  await page.locator('[data-testid="email"]').fill('user@example.com');
  await page.locator('[data-testid="password"]').fill('password');
  await page.locator('[data-testid="login"]').click();
  await page.waitForURL('/dashboard');
  // different test logic...
});
```

**After:**
```typescript
// utils/auth.ts
export async function login(page: Page, email = 'user@example.com', password = 'password') {
  await page.locator('[data-testid="email"]').fill(email);
  await page.locator('[data-testid="password"]').fill(password);
  await page.locator('[data-testid="login"]').click();
  await page.waitForURL('/dashboard');
}

// In tests
test('test 1', async ({ page }) => {
  await login(page);
  // test continues...
});

test('test 2', async ({ page }) => {
  await login(page);
  // different test logic...
});
```

## Pattern 2: Extract to Fixture

**When:** Setup code needed for multiple tests

**Before:**
```typescript
test('test 1', async ({ page }) => {
  await page.goto('/login');
  await page.locator('[data-testid="email"]').fill('test@example.com');
  await page.locator('[data-testid="password"]').fill('password');
  await page.locator('[data-testid="login"]').click();
  await page.waitForURL('/dashboard');
  // test logic...
});
```

**After:**
```typescript
// fixtures/auth.ts
export const test = base.extend<{ authenticatedPage: Page }>({
  authenticatedPage: async ({ page }, use) => {
    await page.goto('/login');
    await page.locator('[data-testid="email"]').fill('test@example.com');
    await page.locator('[data-testid="password"]').fill('password');
    await page.locator('[data-testid="login"]').click();
    await page.waitForURL('/dashboard');
    await use(page);
  },
});

// In tests
test('test 1', async ({ authenticatedPage: page }) => {
  // Already logged in
  // test logic...
});
```

## Pattern 3: Extract to Page Object

**When:** Many tests interact with the same page

**Before:**
```typescript
test('test 1', async ({ page }) => {
  await page.goto('/profile');
  await page.locator('[data-testid="name"]').fill('John');
  await page.locator('[data-testid="save"]').click();
  await expect(page.locator('[data-testid="success"]')).toBeVisible();
});

test('test 2', async ({ page }) => {
  await page.goto('/profile');
  await page.locator('[data-testid="email"]').fill('john@example.com');
  await page.locator('[data-testid="save"]').click();
  await expect(page.locator('[data-testid="success"]')).toBeVisible();
});
```

**After:**
```typescript
// page-objects/ProfilePage.ts
export class ProfilePage {
  constructor(readonly page: Page) {}

  async goto() {
    await this.page.goto('/profile');
  }

  async updateName(name: string) {
    await this.page.locator('[data-testid="name"]').fill(name);
  }

  async updateEmail(email: string) {
    await this.page.locator('[data-testid="email"]').fill(email);
  }

  async save() {
    await this.page.locator('[data-testid="save"]').click();
  }

  getSuccessMessage() {
    return this.page.locator('[data-testid="success"]');
  }
}

// In tests
test('test 1', async ({ page }) => {
  const profilePage = new ProfilePage(page);
  await profilePage.goto();
  await profilePage.updateName('John');
  await profilePage.save();
  await expect(profilePage.getSuccessMessage()).toBeVisible();
});
```

## Pattern 4: Parameterized Tests

**When:** Same test logic with different inputs

**Before:**
```typescript
test('validates email 1', async ({ page }) => {
  await page.locator('[data-testid="email"]').fill('invalid');
  await page.locator('[data-testid="submit"]').click();
  await expect(page.locator('[data-testid="error"]')).toBeVisible();
});

test('validates email 2', async ({ page }) => {
  await page.locator('[data-testid="email"]').fill('@example.com');
  await page.locator('[data-testid="submit"]').click();
  await expect(page.locator('[data-testid="error"]')).toBeVisible();
});
```

**After:**
```typescript
const invalidEmails = [
  'invalid',
  '@example.com',
  'user@',
  '',
  'user @example.com',
];

for (const email of invalidEmails) {
  test(`validates email: ${email}`, async ({ page }) => {
    await page.locator('[data-testid="email"]').fill(email);
    await page.locator('[data-testid="submit"]').click();
    await expect(page.locator('[data-testid="error"]')).toBeVisible();
  });
}
```

## Pattern 5: Builder Pattern for Complex Setup

**When:** Tests need complex object creation

**Before:**
```typescript
test('create user', async ({ page }) => {
  await page.locator('[data-testid="name"]').fill('John');
  await page.locator('[data-testid="email"]').fill('john@example.com');
  await page.locator('[data-testid="age"]').fill('30');
  await page.locator('[data-testid="country"]').selectOption('USA');
  await page.locator('[data-testid="bio"]').fill('Software engineer');
  // ... many more fields
});
```

**After:**
```typescript
// utils/UserBuilder.ts
export class UserBuilder {
  private data: Record<string, string> = {
    name: 'Default Name',
    email: 'default@example.com',
    age: '25',
    country: 'USA',
  };

  withName(name: string) {
    this.data.name = name;
    return this;
  }

  withEmail(email: string) {
    this.data.email = email;
    return this;
  }

  async fillForm(page: Page) {
    for (const [field, value] of Object.entries(this.data)) {
      await page.locator(`[data-testid="${field}"]`).fill(value);
    }
  }
}

// In test
test('create user', async ({ page }) => {
  await new UserBuilder()
    .withName('John')
    .withEmail('john@example.com')
    .fillForm(page);
});
```

## Pattern 6: Test Data Factory

**When:** Need consistent test data across tests

**Before:**
```typescript
test('test 1', async ({ page }) => {
  const user = {
    email: 'test@example.com',
    password: 'password123',
    name: 'Test User',
  };
  // use user...
});

test('test 2', async ({ page }) => {
  const user = {
    email: 'test2@example.com',
    password: 'password123',
    name: 'Test User 2',
  };
  // use user...
});
```

**After:**
```typescript
// utils/factories.ts
export const createUser = (overrides = {}) => ({
  email: 'test@example.com',
  password: 'password123',
  name: 'Test User',
  ...overrides,
});

// In tests
test('test 1', async ({ page }) => {
  const user = createUser();
  // use user...
});

test('test 2', async ({ page }) => {
  const user = createUser({ email: 'test2@example.com', name: 'Test User 2' });
  // use user...
});
```

## Pattern 7: Extract Wait Strategy

**When:** Consistent waiting needed across tests

**Before:**
```typescript
test('test 1', async ({ page }) => {
  await page.locator('[data-testid="submit"]').click();
  await page.waitForLoadState('networkidle');
  await expect(page.locator('[data-testid="result"]')).toBeVisible({ timeout: 10000 });
});

test('test 2', async ({ page }) => {
  await page.locator('[data-testid="save"]').click();
  await page.waitForLoadState('networkidle');
  await expect(page.locator('[data-testid="success"]')).toBeVisible({ timeout: 10000 });
});
```

**After:**
```typescript
// utils/wait-helpers.ts
export async function waitForActionComplete(page: Page, resultTestId: string) {
  await page.waitForLoadState('networkidle');
  await page.locator(`[data-testid="${resultTestId}"]`).waitFor({
    state: 'visible',
    timeout: 10000,
  });
}

// In tests
test('test 1', async ({ page }) => {
  await page.locator('[data-testid="submit"]').click();
  await waitForActionComplete(page, 'result');
});
```

## Pattern 8: Consolidate Assertions

**When:** Similar assertions repeated across tests

**Before:**
```typescript
test('test 1', async ({ page }) => {
  // ... actions
  await expect(page.locator('[data-testid="success"]')).toBeVisible();
  await expect(page.locator('[data-testid="success"]')).toContainText('Success');
  await expect(page.locator('[data-testid="error"]')).not.toBeVisible();
});
```

**After:**
```typescript
// utils/assertions.ts
export async function assertSuccess(page: Page) {
  await expect(page.locator('[data-testid="success"]')).toBeVisible();
  await expect(page.locator('[data-testid="success"]')).toContainText('Success');
  await expect(page.locator('[data-testid="error"]')).not.toBeVisible();
}

// In tests
test('test 1', async ({ page }) => {
  // ... actions
  await assertSuccess(page);
});
```

## Pattern 9: Extract Navigation Logic

**When:** Complex navigation patterns repeated

**Before:**
```typescript
test('test 1', async ({ page }) => {
  await page.goto('/');
  await page.locator('[data-testid="menu"]').click();
  await page.locator('[data-testid="settings"]').click();
  await page.locator('[data-testid="profile"]').click();
  // test logic...
});
```

**After:**
```typescript
// utils/navigation.ts
export async function navigateToProfile(page: Page) {
  await page.goto('/');
  await page.locator('[data-testid="menu"]').click();
  await page.locator('[data-testid="settings"]').click();
  await page.locator('[data-testid="profile"]').click();
  await page.waitForLoadState('domcontentloaded');
}

// In tests
test('test 1', async ({ page }) => {
  await navigateToProfile(page);
  // test logic...
});
```

## Pattern 10: Replace Magic Strings with Constants

**When:** Same strings/values used in multiple places

**Before:**
```typescript
test('test 1', async ({ page }) => {
  await page.locator('[data-testid="submit-button"]').click();
});

test('test 2', async ({ page }) => {
  await expect(page.locator('[data-testid="submit-button"]')).toBeEnabled();
});
```

**After:**
```typescript
// constants/testids.ts
export const TESTIDS = {
  SUBMIT_BUTTON: 'submit-button',
  CANCEL_BUTTON: 'cancel-button',
  // ... more testids
};

// In tests
test('test 1', async ({ page }) => {
  await page.locator(`[data-testid="${TESTIDS.SUBMIT_BUTTON}"]`).click();
});

// Or create a helper
function getByTestId(page: Page, testId: string) {
  return page.locator(`[data-testid="${testId}"]`);
}

test('test 1', async ({ page }) => {
  await getByTestId(page, TESTIDS.SUBMIT_BUTTON).click();
});
```
