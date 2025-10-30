# Playwright Testing Best Practices Checklist

## Test Structure

- [ ] Tests follow AAA pattern (Arrange-Act-Assert)
- [ ] One assertion per test (or closely related assertions)
- [ ] Tests are independent and can run in any order
- [ ] Clear, descriptive test names using "should" format
- [ ] Proper use of test.describe for grouping related tests

## Locators

- [ ] **ONLY** data-testid locators used (no CSS/XPath)
- [ ] data-testid values are semantic and descriptive
- [ ] No brittle selectors (class names, IDs, XPath)
- [ ] Locators are unique on the page
- [ ] Use .first() or .nth() for intentional multiple elements

## Waiting & Timing

- [ ] Explicit waits before interactions
- [ ] NO hardcoded waits (page.waitForTimeout())
- [ ] Use waitForLoadState() after navigation
- [ ] Wait for network requests when needed
- [ ] Proper timeouts for slow operations

## Code Organization

- [ ] No code duplication - extract to utilities/Page Objects
- [ ] Use Page Object Model for complex pages
- [ ] Common setup in fixtures
- [ ] Utilities for repeated actions
- [ ] Clear file and folder structure

## TypeScript

- [ ] All functions have proper types
- [ ] No `any` types (use specific types)
- [ ] Interfaces for complex data structures
- [ ] Async/await used correctly
- [ ] Proper error handling

## Test Isolation

- [ ] Tests don't depend on each other
- [ ] Clean state before each test
- [ ] Proper cleanup in afterEach/afterAll
- [ ] No shared mutable state
- [ ] Each test creates its own data

## Assertions

- [ ] Use appropriate matchers (toBeVisible, toContainText, etc.)
- [ ] Assertions have proper error messages
- [ ] Wait for conditions before asserting
- [ ] Check both positive and negative cases
- [ ] Use expect() consistently

## Configuration

- [ ] Proper timeout settings
- [ ] Retries enabled for flaky tests
- [ ] Screenshot on failure
- [ ] Trace on first retry
- [ ] Parallel execution configured

## Documentation

- [ ] Complex test logic has comments
- [ ] Page Objects are documented
- [ ] Utilities have JSDoc comments
- [ ] README explains test structure
- [ ] Known issues documented

## Maintenance

- [ ] Regular review of flaky tests
- [ ] Remove obsolete tests
- [ ] Update tests when UI changes
- [ ] Refactor duplicate code
- [ ] Keep dependencies updated
