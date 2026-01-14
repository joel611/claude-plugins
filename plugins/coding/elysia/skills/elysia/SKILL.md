---
name: elysia
description: Expert knowledge for building type-safe web applications with ElysiaJS, including validation, lifecycle hooks, Eden end-to-end type safety, and integrations
---

# Elysia Skill

Expert knowledge for building high-performance, type-safe web applications with **ElysiaJS** - a fast, ergonomic Bun web framework with end-to-end type safety.

This skill synthesizes knowledge from official Elysia documentation covering core concepts, patterns, plugins, and integrations.

## When to Use This Skill

This skill should be triggered when you are:

**Building Web APIs:**
- Creating RESTful APIs with Elysia
- Setting up HTTP routes (GET, POST, PUT, DELETE, etc.)
- Implementing request/response handlers
- Working with route parameters, query strings, or request bodies

**Type Safety & Validation:**
- Adding schema validation with Elysia.t (TypeBox)
- Using Standard Schema validators (Zod, Valibot, ArkType, etc.)
- Validating request bodies, queries, params, headers, or cookies
- Generating OpenAPI documentation from schemas

**Lifecycle Hooks & Middleware:**
- Implementing authentication/authorization checks
- Adding logging, error handling, or request preprocessing
- Using lifecycle hooks (beforeHandle, afterResponse, onError, etc.)
- Creating reusable route options with Macros

**End-to-End Type Safety:**
- Setting up Eden Treaty for type-safe client-server communication
- Exporting server types for frontend consumption
- Creating type-safe API clients (similar to tRPC)
- Testing with end-to-end type safety

**Framework Integrations:**
- Integrating Elysia with Next.js, Nuxt, SvelteKit, Astro, or Expo
- Setting up Drizzle ORM with Elysia
- Using AI SDK with Elysia for streaming responses
- Deploying to Netlify Edge Functions or other platforms

**Plugin Development:**
- Creating custom Elysia plugins
- Using official plugins (@elysiajs/*)
- Implementing OpenTelemetry for observability
- Working with HTML, CORS, JWT, GraphQL, or other plugins

## Key Concepts

### Method Chaining
Elysia uses method chaining extensively. Each method returns a new instance with updated types:

```typescript
new Elysia()
  .state('version', 1)
  .get('/', ({ store }) => store.version)
  .listen(3000)
```

**Important:** Always use method chaining - it's required for proper type inference, especially with Eden.

### Schema Validation
Elysia provides `t` (TypeBox) for runtime and compile-time type safety. Schemas automatically generate TypeScript types and OpenAPI documentation:

```typescript
import { Elysia, t } from 'elysia'

new Elysia()
  .post('/user', ({ body }) => body, {
    body: t.Object({
      name: t.String(),
      age: t.Number()
    })
  })
```

### Lifecycle Hooks
Hooks execute at specific points in the request-response cycle:

- **request** - when request is received
- **beforeHandle** - before executing handler (e.g., auth checks)
- **afterHandle** - after handler, before response
- **afterResponse** - after response is sent
- **onError** - when errors occur

Hooks can be **local** (specific route) or **interceptor** (all routes after registration).

### Eden Treaty
Eden provides end-to-end type safety between server and client, similar to tRPC but using Elysia's type system:

```typescript
// server.ts
const app = new Elysia()
  .get('/user/:id', ({ params: { id } }) => ({ id, name: 'John' }))
export type App = typeof app

// client.ts
import { treaty } from '@elysiajs/eden'
const api = treaty<App>('localhost:3000')
const { data } = await api.user({ id: '1' }).get()
// data is fully typed!
```

## Quick Reference

### 1. Basic Server Setup

```typescript
import { Elysia } from 'elysia'

new Elysia()
  .get('/', () => 'Hello Elysia')
  .listen(3000)

console.log('🦊 Elysia is running at http://localhost:3000')
```

### 2. Route with Validation

```typescript
import { Elysia, t } from 'elysia'

new Elysia()
  .post('/user', ({ body }) => body, {
    body: t.Object({
      name: t.String(),
      email: t.String({ format: 'email' })
    })
  })
  .listen(3000)
```

### 3. Path Parameters & Query Strings

```typescript
import { Elysia, t } from 'elysia'

new Elysia()
  .get('/id/:id', ({ params: { id }, query }) => {
    return { id, query }
  }, {
    params: t.Object({
      id: t.Number() // Automatically coerced from string
    }),
    query: t.Object({
      name: t.String()
    })
  })
  .listen(3000)
```

### 4. Authentication with beforeHandle Hook

```typescript
import { Elysia } from 'elysia'

new Elysia()
  .onBeforeHandle(({ query: { name }, status }) => {
    if (!name) return status(401)
  })
  .get('/protected', ({ query: { name } }) => {
    return `Welcome ${name}!`
  })
  .listen(3000)
```

### 5. Local Hook for Specific Route

```typescript
import { Elysia } from 'elysia'

new Elysia()
  .get('/public', () => 'Public route')
  .get('/auth', () => 'Authenticated!', {
    beforeHandle({ request, status }) {
      if (Math.random() <= 0.5) return status(418)
    }
  })
  .listen(3000)
```

### 6. Guard for Multiple Routes

```typescript
import { Elysia, t } from 'elysia'

new Elysia()
  .get('/none', () => 'No validation')
  .guard({
    query: t.Object({
      name: t.String()
    })
  })
  .get('/query', ({ query: { name } }) => name)
  .get('/query2', ({ query: { name } }) => `Hello ${name}`)
  .listen(3000)
```

### 7. State Management

```typescript
import { Elysia } from 'elysia'

new Elysia()
  .state('count', 0)
  .get('/', ({ store }) => {
    store.count++
    return store.count
  })
  .listen(3000)
```

### 8. Custom Status & Redirect

```typescript
import { Elysia } from 'elysia'

new Elysia()
  .get('/teapot', ({ status }) => status(418, "I'm a teapot"))
  .get('/home', ({ redirect }) => redirect('https://elysiajs.com'))
  .listen(3000)
```

### 9. Reusable Macro

```typescript
import { Elysia, t } from 'elysia'

new Elysia()
  .macro('auth', {
    cookie: t.Object({
      session: t.String()
    }),
    beforeHandle({ cookie: { session }, status }) {
      if (!session.value) return status(401)
    }
  })
  .post('/user', ({ body }) => body, {
    auth: true // Applies auth macro
  })
  .listen(3000)
```

### 10. Eden Setup (End-to-End Type Safety)

**Server:**
```typescript
// server.ts
import { Elysia, t } from 'elysia'

const app = new Elysia()
  .get('/', () => 'Hi Elysia')
  .get('/id/:id', ({ params: { id } }) => id)
  .post('/mirror', ({ body }) => body, {
    body: t.Object({
      id: t.Number(),
      name: t.String()
    })
  })
  .listen(3000)

export type App = typeof app
```

**Client:**
```bash
bun add @elysiajs/eden
bun add -d elysia
```

```typescript
// client.ts
import { treaty } from '@elysiajs/eden'
import type { App } from './server'

const api = treaty<App>('localhost:3000')

const { data, error } = await api.mirror.post({
  id: 1,
  name: 'Elysia'
})

if (error) console.error(error.value)
else console.log(data) // Fully typed!
```

### 11. Error Handling

```typescript
import { Elysia, t } from 'elysia'

new Elysia()
  .get('/:id', ({ params: { id } }) => id, {
    params: t.Object({
      id: t.Number({
        error: 'id must be a number'
      })
    })
  })
  .onError(({ code, error, status }) => {
    if (code === 'VALIDATION')
      return status(400, error.message)

    return status(500, 'Internal Server Error')
  })
  .listen(3000)
```

### 12. Standard Schema (Zod Example)

```typescript
import { Elysia } from 'elysia'
import { z } from 'zod'

new Elysia()
  .post('/user', ({ body }) => body, {
    body: z.object({
      name: z.string(),
      age: z.number()
    })
  })
  .listen(3000)
```

### 13. Drizzle ORM Integration

```bash
bun add drizzle-orm drizzle-typebox
```

```typescript
import { Elysia } from 'elysia'
import { drizzle } from 'drizzle-orm/bun-sqlite'
import { createInsertSchema } from 'drizzle-typebox'
import { users } from './schema'

const db = drizzle(/* ... */)
const insertUserSchema = createInsertSchema(users)

new Elysia()
  .post('/user', async ({ body }) => {
    const user = await db.insert(users).values(body)
    return user
  }, {
    body: insertUserSchema
  })
  .listen(3000)
```

### 14. File Upload

```typescript
import { Elysia, t } from 'elysia'

new Elysia()
  .post('/upload', async ({ body: { file } }) => {
    return `Uploaded: ${file.name}`
  }, {
    body: t.Object({
      file: t.File()
    })
  })
  .listen(3000)
```

### 15. Plugin Creation

```typescript
import { Elysia } from 'elysia'

const myPlugin = new Elysia({ name: 'my-plugin' })
  .state('pluginVersion', '1.0.0')
  .get('/plugin', ({ store }) => store.pluginVersion)

new Elysia()
  .use(myPlugin)
  .listen(3000)
```

## Reference Files

This skill includes comprehensive documentation extracted from official Elysia sources. All examples and information come from **official documentation** (medium-high confidence).

### `references/essential.md` (6 pages)
Core Elysia concepts including:
- **Validation** - TypeBox schemas, Standard Schema support (Zod, Valibot, etc.)
- **Lifecycle** - Request-response cycle, hooks, and middleware
- **Body/Query/Params** - Request data validation
- **Guard** - Apply schemas to multiple routes

### `references/eden.md` (11 pages)
End-to-end type safety with Eden:
- **Installation** - Setup Eden Treaty on frontend
- **Type Inference** - Gotchas and troubleshooting
- **Testing** - Unit testing with Eden
- **Treaty API** - Tree-like syntax, dynamic paths, responses

### `references/tutorial.md` (14 pages)
Step-by-step guides including:
- **Getting Started** - Basic server setup
- **Lifecycle Hooks** - Local vs interceptor hooks
- **Mount** - Composing multiple Elysia instances
- **Features** - Advanced patterns and techniques

### `references/patterns.md` (21 pages)
Advanced patterns including:
- **Macro** - Reusable route options
- **Error Handling** - Custom errors, validation messages
- **Configuration** - Server configuration options
- **OpenTelemetry** - Observability integration

### `references/plugins.md` (13 pages)
Official plugins documentation:
- **OpenTelemetry** - Distributed tracing
- **HTML** - Server-side rendering
- **CORS** - Cross-origin resource sharing
- **JWT** - JSON Web Token authentication
- **GraphQL** - GraphQL integration

### `references/integrations.md` (17 pages)
Framework integrations:
- **Drizzle ORM** - Database integration with type safety
- **Next.js** - Integration with Next.js App Router
- **Nuxt** - Integration with Nuxt 3
- **SvelteKit** - Integration with SvelteKit
- **Expo** - React Native integration
- **Astro** - Integration with Astro
- **AI SDK** - Streaming AI responses

### `references/other.md`
Additional topics and utilities.

## Working with This Skill

### For Beginners

1. **Start with basics** - Read `references/tutorial.md` for getting started guides
2. **Learn validation** - Check `references/essential.md` for schema validation
3. **Try examples** - Use the Quick Reference examples above to build your first server
4. **Understand hooks** - Learn lifecycle hooks for middleware and authentication

### For Intermediate Users

1. **Master Guards** - Apply schemas to multiple routes efficiently
2. **Use Macros** - Create reusable route options for common patterns
3. **Add Eden** - Implement end-to-end type safety with Eden Treaty
4. **Error handling** - Implement robust error handling with custom errors

### For Advanced Users

1. **Create plugins** - Build reusable Elysia plugins for your organization
2. **Integrate frameworks** - Connect Elysia with Next.js, Nuxt, or other frameworks
3. **Add observability** - Implement OpenTelemetry for distributed tracing
4. **Optimize performance** - Use Elysia's ahead-of-time compilation features

### Navigation Tips

- **Need validation help?** → `references/essential.md`
- **Setting up Eden?** → `references/eden.md`
- **Framework integration?** → `references/integrations.md`
- **Creating plugins?** → `references/plugins.md`
- **Advanced patterns?** → `references/patterns.md`
- **Learning the basics?** → `references/tutorial.md`

## Important Notes

### TypeScript Requirements
- **Minimum TypeScript version:** 5.0+
- **Enable strict mode** in `tsconfig.json`
- Method chaining is required for proper type inference

### Eden Gotchas
- Server and client must have **matching Elysia versions**
- Use `method chaining` - required for type inference
- Pin `@sinclair/typebox` version if using Drizzle
- Path aliases in monorepos need careful configuration

### Validation Best Practices
- Use `t.File()` for file uploads (sets content-type automatically)
- Validation details are hidden in production by default
- Custom error messages can be set per field
- Standard Schema (Zod, Valibot, etc.) is fully supported

### Performance Tips
- Elysia runs on Bun for maximum performance
- Ahead-of-time compilation optimizes route handlers
- Use guards to apply validation to multiple routes efficiently
- State is instance-scoped, not request-scoped

## Source Information

**All content synthesized from official Elysia documentation:**
- Source Type: Official Documentation
- Confidence: Medium-High
- Documentation URL: https://elysiajs.com

No conflicts detected between sources. All examples and patterns come directly from official Elysia documentation and are considered authoritative.

## Additional Resources

### Installation
```bash
bun add elysia
```

### Common Plugins
```bash
# Eden (type-safe client)
bun add @elysiajs/eden

# HTML rendering
bun add @elysiajs/html

# CORS
bun add @elysiajs/cors

# JWT
bun add @elysiajs/jwt

# GraphQL
bun add @elysiajs/graphql-yoga

# OpenTelemetry
bun add @elysiajs/opentelemetry
```

### Community
- Official Website: https://elysiajs.com
- GitHub: https://github.com/elysiajs/elysia
- Discord: Join the Elysia community for support

## Updating

This skill was automatically generated from official Elysia documentation. To refresh:
1. Re-run the documentation scraper with the same configuration
2. The skill will be rebuilt with the latest information
3. All reference files will be updated with new examples and patterns
