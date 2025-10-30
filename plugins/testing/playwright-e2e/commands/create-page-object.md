# Create Page Object Command

## Description

Create a Page Object Model (POM) for a specific page or component. Generates a TypeScript class with locators and methods following the Page Object pattern with data-testid locators.

## Usage

```
/create-page-object [page-name]
```

## Parameters

- `page-name` - Name of the page or component (required)

## Examples

```
/create-page-object LoginPage
```

```
/create-page-object ProductDetailsPage
```

```
/create-page-object CheckoutForm
```

## Instructions for Claude

When this command is invoked:

1. **Invoke the page-object-builder skill** to handle the Page Object creation

2. **Gather information**:
   - Page name and URL
   - Key elements on the page
   - Common user actions
   - data-testid values for elements

3. **Generate Page Object class**:
   - TypeScript class with proper types
   - Readonly locators using data-testid
   - Constructor accepting Page object
   - goto() method for navigation
   - Action methods (async)
   - Getter methods for assertions

4. **Provide usage example**:
   - Show how to use the Page Object in tests
   - Demonstrate common actions
   - Show assertion patterns

5. **List required data-testid values**:
   - Document all testid values needed in the UI
   - Provide semantic naming suggestions

## Error Handling

- If page name is missing, prompt for it
- If insufficient information, ask for page details
- Suggest data-testid names if not provided
- Warn if Page Object seems too large (consider splitting)

## Notes

- All locators must use data-testid
- Page Objects should not contain assertions
- Use getters for elements that need assertions
- Keep Page Objects focused on a single page/component
