# Generate Test Command

## Description

Generate a production-ready Playwright E2E test from a natural language description. Creates TypeScript test files following best practices including data-testid locators, AAA pattern, and proper async/await usage.

## Usage

```
/generate-test [description]
```

## Parameters

- `description` - Natural language description of the test scenario (required)

## Examples

```
/generate-test Login flow with valid credentials
```

```
/generate-test Add item to cart and complete checkout
```

```
/generate-test Form validation for empty email field
```

## Instructions for Claude

When this command is invoked:

1. **Invoke the test-generator skill** to handle the test generation
2. **Gather requirements** from the user:
   - Feature/functionality to test
   - User flow or scenario
   - Expected outcomes
   - Page URLs involved
   - data-testid values (or suggest them)

3. **Generate the test file** following these requirements:
   - TypeScript file with `.spec.ts` extension
   - Use only data-testid locators
   - Follow AAA pattern (Arrange-Act-Assert)
   - Include proper async/await
   - Add explicit waits (no hardcoded timeouts)
   - Include meaningful assertions
   - Add comments for clarity

4. **Create supporting files if needed**:
   - `playwright.config.ts` if first test
   - Custom fixtures if needed
   - Utility functions if reusable

5. **Provide usage instructions**:
   - How to run the test
   - What data-testid values need to be added to UI
   - How to debug if it fails

6. **Validate the generated test**:
   - Ensure only data-testid locators
   - Check for proper waits
   - Verify AAA structure
   - Confirm TypeScript types

## Error Handling

- If description is too vague, ask clarifying questions
- If missing required information (URLs, element names), prompt user
- If data-testid values aren't provided, suggest semantic names
- Warn if the test scenario seems too complex for a single test

## Notes

- Tests should be focused and test one specific behavior
- Always use data-testid for locators (MANDATORY)
- Include explicit waits, never use waitForTimeout()
- Follow Playwright and TypeScript best practices
- Ensure tests are maintainable and readable
