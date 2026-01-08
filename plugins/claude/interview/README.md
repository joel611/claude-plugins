# Ask Me Command

## Description

Conduct an in-depth interactive interview to gather detailed requirements and specifications. Uses iterative questioning to explore technical implementation, UI/UX considerations, concerns, tradeoffs, and edge cases before generating a comprehensive specification document.

## Usage

```
/ask-me [topic or feature description]
```

## Parameters

- `topic or feature description` - The feature, system, or topic you want to be interviewed about (required)

## Examples

```
/ask-me build a login system using better-auth
```

```
/ask-me create a real-time chat feature
```

```
/ask-me implement a file upload system with image processing
```

## Instructions for Claude

When this command is invoked:

Read this: #$ARGUMENTS

Interview me in detail using the AskUserQuestion tool about literally anything: technical implementation, UI & UX, concerns, tradeoffs, etc. but make sure the questions are not obvious.

Be very in-depth and continue interviewing me continually until it's complete, then write the spec to the file.

### Interview Process

1. **Understand the Context**
   - Read and analyze the topic/feature provided in arguments
   - Identify key areas that need clarification

2. **Ask Non-Obvious Questions**
   - Focus on technical implementation details
   - Explore UI/UX implications and user flows
   - Investigate edge cases and error scenarios
   - Discuss security and performance considerations
   - Examine data models and architecture decisions
   - Consider scalability and future extensibility
   - Understand integration points and dependencies

3. **Iterative Deep Dive**
   - Use AskUserQuestion tool for each round of questions
   - Build upon previous answers to ask deeper questions
   - Continue until all critical aspects are covered
   - Don't stop at surface-level answers

4. **Generate Comprehensive Spec**
   - Once interview is complete, write a detailed specification
   - Include all gathered requirements and decisions
   - Document technical choices and rationale
   - Specify UI/UX flows and components
   - List edge cases and error handling
   - Save to a markdown file with appropriate naming

### Question Categories to Cover

- **Technical Architecture**: Framework choices, patterns, data flow, state management
- **Data Models**: Schemas, relationships, validation rules, constraints
- **User Experience**: Flows, interactions, feedback, accessibility
- **Security**: Authentication, authorization, data protection, input validation
- **Performance**: Optimization strategies, caching, lazy loading
- **Error Handling**: Validation, error states, user feedback, recovery
- **Integration**: APIs, third-party services, existing systems
- **Testing**: Strategy, coverage, test types
- **Deployment**: Environment considerations, configuration, monitoring

### Output Format

Save the final specification as `spec-[feature-name].md` with sections:

- Overview
- Requirements
- Technical Architecture
- Data Models
- User Flows
- UI/UX Specifications
- Security Considerations
- Error Handling
- Testing Strategy
- Future Considerations

## Notes

- Questions should be specific and thought-provoking, not generic
- Avoid obvious questions that could be assumed
- Build a complete mental model before writing the spec
- The goal is to uncover all critical decisions and considerations upfront

credit to thariq x post:
<https://x.com/trq212/status/2005315275026260309>
