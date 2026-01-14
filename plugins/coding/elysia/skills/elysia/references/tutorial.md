# Elysia - Tutorial

**Pages:** 14

---

## Lifecycle

**URL:** https://elysiajs.com/tutorial/getting-started/life-cycle.md

**Contents:**
- Hook
- Local Hook
- Interceptor Hook
- Assignment

---
url: 'https://elysiajs.com/tutorial/getting-started/life-cycle.md'
---

Lifecycle **hook** is function that executed on a specific event during the request-response cycle.

They allow you to run custom logic at the certain point

* request - when a request is received
* beforeHandle - before executing a handler
* afterResponse - after a response is sent, etc.
* error - when an error occurs

This can be useful for tasks like logging, authentication, etc.

To register a lifecycle hook, you can pass it to 3rd argument of a route method:

When `beforeHandle` returns a value, it will skip the handler and return the value instead.

This is useful for things like authentication, where you want to return a `401 Unauthorized` response if the user is not authenticated.

See Life Cycle, Before Handle for a more detailed explanation.

A function that intercepts the **lifecycle event**. because a function **"hooks"** into the lifecycle event

Hook can be categorized into 2 types:

1. Local Hook - execute on a specific route
2. Interceptor Hook - execute on every route **after the hook is registered**

A local hook is executed on a specific route.

To use a local hook, you can inline hook into a route handler:

Register hook into every **handler that came after the hook is called** for the current instance only.

To add an interceptor hook, you can use `.on` followed by a lifecycle event:

Unlike Local Hook, Interceptor Hook will add the hook to every route that came after the hook is registered.

Let's put 2 types of hooks into practice.

We can use `beforeHandle` to intercept the request before it reaches the handler, and return a response with `status` method.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.get('/1', () => 'Hello Elysia!')
	.get('/auth', () => {
		console.log('This is executed after "beforeHandle"')

		return 'Oh you are lucky!'
	}, {
		beforeHandle({ request, status }) {
			console.log('This is executed before handler')

			if(Math.random() <= 0.5)
				return status(418)
		}
	})
	.get('/2', () => 'Hello Elysia!')
```

Example 2 (typescript):
```typescript
// Similar to previous code snippet
import { Elysia } from 'elysia'

new Elysia()
	.get('/1', () => 'Hello Elysia!')
	.get('/auth', () => {
		console.log('Run after "beforeHandle"')

		return 'Oh you are lucky!'
	}, {
		// This is a Local Hook
		beforeHandle({ request, status }) {
			console.log('Run before handler')

			if(Math.random() <= 0.5)
				return status(418)
		}
	})
	.get('/2', () => 'Hello Elysia!')
```

Example 3 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.get('/1', () => 'Hello Elysia!')
	.onBeforeHandle(({ request, status }) => {
		console.log('This is executed before handler')

		if(Math.random() <= 0.5)
			return status(418)
	})
	// "beforeHandle" is applied
	.get('/auth', () => {
		console.log('This is executed after "beforeHandle"')

		return 'Oh you are lucky!'
	})
	// "beforeHandle" is also applied
	.get('/2', () => 'Hello Elysia!')
```

Example 4 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.onBeforeHandle(({ query: { name }, status }) => {
		if(!name) return status(401)
	})
	.get('/auth', ({ query: { name = 'anon' } }) => {
		return `Hello ${name}!`
	})
	.get('/profile', ({ query: { name = 'anon' } }) => {
		return `Hello ${name}!`
	})
	.listen(3000)
```

---

## Mount

**URL:** https://elysiajs.com/tutorial/features/mount.md

**Contents:**
- Assignment

---
url: 'https://elysiajs.com/tutorial/features/mount.md'
---

Elysia provides a Elysia.mount to interlop between backend frameworks that is built on Web Standard like Hono, H3, etc.

This allows us to gradually migrate our application to Elysia, or use multiple frameworks in a single application.

Let's use the preview to **GET '/hono'** to see if our Hono route is working.

Try to modify the code and see how it changes!

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia, t } from 'elysia'
import { Hono } from 'hono'

const hono = new Hono()
	.get('/', (c) => c.text('Hello from Hono')

new Elysia()
	.get('/', 'Hello from Elysia')
	.mount('/hono', hono.fetch)
	.listen(3000)
```

---

## Status

**URL:** https://elysiajs.com/tutorial/getting-started/status-and-headers.md

**Contents:**
- Redirect
- Headers
- Assignment

---
url: 'https://elysiajs.com/tutorial/getting-started/status-and-headers.md'
---

Status code is an indicator of how the server handles the request.

You must have heard of the infamous **404 Not Found** when you visit a non-existing page.

That's a **status code**.

By default, Elysia will return **200 OK** for a successful request.

Elysia also returns many other status codes depending on the situation like:

* 400 Bad Request
* 422 Unprocessable Entity
* 500 Internal Server Error

You can also return a status code by returning your response using a `status` function.

Similarly, you can also redirect the request to another URL by returning a `redirect` function.

Unlike status code and redirect, which you can return directly, you might need to set headers multiple times in your application.

That's why instead of returning a `headers` function, Elysia provides a `set.headers` object to set headers.

Because `headers` represents **request headers**, Elysia distinguishes between request headers and response headers by prefixing **set.headers** for response.

Let's exercise what we have learned.

1. To set status code to `418 I'm a teapot`, we can use `status` function.
2. To redirect `/docs` to `https://elysiajs.com`, we can use `redirect` function.
3. To set a custom header `x-powered-by` to `Elysia`, we can use `set.headers` object.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.get('/', ({ status }) => status(418, "I'm a teapot'"))
	.listen(3000)
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.get('/', ({ redirect }) => redirect('https://elysiajs.com'))
	.listen(3000)
```

Example 3 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.get('/', ({ set }) => {
		set.headers['x-powered-by'] = 'Elysia'

		return 'Hello World'
	})
	.listen(3000)
```

Example 4 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.get('/', ({ status, set }) => {
		set.headers['x-powered-by'] = 'Elysia'

		return status(418, 'Hello Elysia!')
	})
	.get('/docs', ({ redirect }) => redirect('https://elysiajs.com'))
	.listen(3000)
```

---

## Unit Test

**URL:** https://elysiajs.com/tutorial/features/unit-test.md

**Contents:**
  - Test
- Assignment

---
url: 'https://elysiajs.com/tutorial/features/unit-test.md'
---

Elysia provides a **Elysia.fetch** function to easily test your application.

**Elysia.fetch** takes a Web Standard Request, and returns a Response similar to the browser's fetch API.

This will run a request like an **actual request** (not simulated).

This allows us to easily test our application without running a server.

Let's tab the  icon in the preview to see how's the request is logged.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'

const app = new Elysia()
	.get('/', 'Hello World')

app.fetch(new Request('http://localhost/'))
	.then((res) => res.text())
	.then(console.log)
```

---

## End-to-End Type Safety

**URL:** https://elysiajs.com/tutorial/features/end-to-end-type-safety.md

**Contents:**
- Assignment

---
url: 'https://elysiajs.com/tutorial/features/end-to-end-type-safety.md'
---

Elysia provides an end-to-end type safety between backend and frontend **without code generation** similar to tRPC, using Eden.

This works by inferring the types from the Elysia instance, and use type hints to provide type safety for the client.

Let's tab the  icon in the preview to see how's the request is logged.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'
import { treaty } from '@elysiajs/eden'

// Backend
export const app = new Elysia()
	.get('/', 'Hello Elysia!')
	.listen(3000)

// Frontend
const client = treaty<typeof app>('localhost:3000')

const { data, error } = await client.get()

console.log(data) // Hello World
```

---

## OpenAPI

**URL:** https://elysiajs.com/tutorial/features/openapi.md

**Contents:**
- Detail
- Reference Model
- Type Gen
  - Browser Environment
- Assignment

---
url: 'https://elysiajs.com/tutorial/features/openapi.md'
---

Elysia is built around OpenAPI, and support OpenAPI documentation out of the box.

We can use OpenAPI plugin to show an API documentation.

Once added, we can access our API documentation at **/openapi**.

We can provide document API by with a `detail` field which follows OpenAPI 3.0 specification (with auto-completion):

We can also define reusable schema with Reference Model:

When we defined a reference model, it will be shown in the **Components** section of the OpenAPI documentation.

OpenAPI Type Gen can document your API **without manual annotation** infers directly from TypeScript type. No Zod, TypeBox, manual interface declaraiont, etc.

**This features is unique to Elysia**, and is not available in other JavaScript frameworks.

For example, if you use Drizzle ORM or Prisma, Elysia can infer the schema directly from the query directly.

![Drizzle](/blog/openapi-type-gen/drizzle-typegen.webp)

> Returning Drizzle query from Elysia route handler will be automatically inferred into OpenAPI schema.

To use OpenAPI Type Gen, simply add apply `fromTypes` plugin before `openapi` plugin.

Unfortunately, this feature require a **fs** module to read your source code, and is not available this web playground. As Elysia is running directly in your browser (not a separated server).

You can try this feature locally with Type Gen Example repository:

Let's use the preview to **GET '/openapi'**, and see how our API documentation looks like.

This API documentation is reflected from your code.

Try to modify the code and see how the documentation changes!

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia, t } from 'elysia'
import { openapi } from '@elysiajs/openapi' // [!code ++]

new Elysia()
	.use(openapi()) // [!code ++]
	.post(
		'/',
		({ body }) => body,
		{
			body: t.Object({
				age: t.Number()
			})
		}
	)
	.listen(3000)
```

Example 2 (typescript):
```typescript
import { Elysia, t } from 'elysia'
import { openapi } from '@elysiajs/openapi'

new Elysia()
	.use(openapi())
	.post(
		'/',
		({ body }) => body,
		{
			body: t.Object({
				age: t.Number()
			}),
			detail: { // [!code ++]
				summary: 'Create a user', // [!code ++]
				description: 'Create a user with age', // [!code ++]
				tags: ['User'], // [!code ++]
			} // [!code ++]
		}
	)
	.listen(3000)
```

Example 3 (typescript):
```typescript
import { Elysia, t } from 'elysia'
import { openapi } from '@elysiajs/openapi'

new Elysia()
	.use(openapi())
	.model({
		age: t.Object({ // [!code ++]
			age: t.Number() // [!code ++]
		}) // [!code ++]
	})
	.post(
		'/',
		({ body }) => body,
		{
			age: t.Object({ // [!code --]
				age: t.Number() // [!code --]
			}), // [!code --]
			body: 'age',  // [!code ++]
			detail: {
				summary: 'Create a user',
				description: 'Create a user with age',
				tags: ['User'],
			}
		}
	)
	.listen(3000)
```

Example 4 (typescript):
```typescript
import { Elysia } from 'elysia'

import { openapi, fromTypes } from '@elysiajs/openapi' // [!code ++]

new Elysia()
	.use(openapi({
		references: fromTypes() // [!code ++]
	}))
	.get('/', { hello: 'world' })
	.listen(3000)
```

---

## Plugin

**URL:** https://elysiajs.com/tutorial/getting-started/plugin.md

**Contents:**
  - Plugin Config
- Assignment

---
url: 'https://elysiajs.com/tutorial/getting-started/plugin.md'
---

Every Elysia instance can be plug-and-play with other instances by `use` method.

Once applied, all routes from `user` instance will be available in `app` instance.

You can also create a plugin that takes argument, and returns an Elysia instance to make a more dynamic plugin.

It's also recommended that you should also read about [Key Concept: Dependency](/key-concept#dependency) to understand how Elysia handles dependencies between plugins.

Let's apply the `user` instance to the `app` instance.

Similar to the above example, we can use the `use` method to plug the `user` instance into the `app` instance.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'

const user = new Elysia()
	.get('/profile', 'User Profile')
	.get('/settings', 'User Settings')

new Elysia()
	.use(user) // [!code ++]
	.get('/', 'Home')
	.listen(3000)
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'

const user = ({ log = false }) => new Elysia() // [!code ++]
	.onBeforeHandle(({ request }) => {
		if (log) console.log(request)
	})
	.get('/profile', 'User Profile')
	.get('/settings', 'User Settings')

new Elysia()
	.use(user({ log: true })) // [!code ++]
	.get('/', 'Home')
	.listen(3000)
```

Example 3 (typescript):
```typescript
import { Elysia } from 'elysia'

const user = new Elysia()
	.get('/profile', 'User Profile')
	.get('/settings', 'User Settings')

const app = new Elysia()
	.use(user) // [!code ++]
	.get('/', 'Home')
	.listen(3000)
```

---

## Encapsulation

**URL:** https://elysiajs.com/tutorial/getting-started/encapsulation.md

**Contents:**
  - Scope
- Guard
- Assignment

---
url: 'https://elysiajs.com/tutorial/getting-started/encapsulation.md'
---

Elysia hooks are **encapsulated** to its own instance only.

If you create a new instance, it will not share hook with other instances.

> Try changing the path in the URL bar to **/rename** and see the result

**Elysia isolate lifecycle** unless explicitly stated.

This is similar to **export** in JavaScript, where you need to export the function to make it available outside the module.

To **"export"** the lifecycle to other instances, you must add specify the scope.

There are 3 scopes available:

1. **local** (default) - apply to only current instance and descendant only
2. **scoped** - apply to parent, current instance and descendants
3. **global** - apply to all instance that apply the plugin (all parents, current, and descendants)

In our case, we want to apply the sign-in check to the `app` which is a direct parent, so we can use either **scoped** or **global**.

Casting lifecycle to **"scoped"** will export lifecycle to **parent instance**.
While **"global"** will export lifecycle to **all instances** that has a plugin.

Learn more about this in scope.

Similar to lifecycle, **schema** is also encapsulated to its own instance.

We can specify guard scope similar to lifecycle.

It's very important to note that every hook will affect all routes **after** its declaration.

See Scope for more information.

Let's define a scope for `nameCheck`, and `ageCheck` to make our app works.

We can modify scope as follows:

1. modify `nameCheck` scope to **scope**
2. modify `ageCheck` scope to **global**

**Examples:**

Example 1 (ts):
```ts
import { Elysia } from 'elysia'

const profile = new Elysia()
	.onBeforeHandle(
		({ query: { name }, status }) => {
			if(!name)
				return status(401)
		}
	)
	.get('/profile', () => 'Hi!')

new Elysia()
	.use(profile)
	.patch('/rename', () => 'Ok! XD')
	.listen(3000)
```

Example 2 (ts):
```ts
import { Elysia } from 'elysia'

const profile = new Elysia()
	.onBeforeHandle(
		{ as: 'scoped' }, // [!code ++]
		({ cookie }) => {
			throwIfNotSignIn(cookie)
		}
	)
	.get('/profile', () => 'Hi there!')

const app = new Elysia()
	.use(profile)
	// This has sign in check
	.patch('/rename', ({ body }) => updateProfile(body))
```

Example 3 (typescript):
```typescript
import { Elysia } from 'elysia'

const user = new Elysia()
	.guard({
		as: 'scoped', // [!code ++]
		query: t.Object({
			age: t.Number(),
			name: t.Optional(t.String())
		}),
		beforeHandle({ query: { age }, status }) {
			if(age < 18) return status(403)
		}
	})
	.get('/profile', () => 'Hi!')
	.get('/settings', () => 'Settings')
```

Example 4 (typescript):
```typescript
import { Elysia, t } from 'elysia'

const nameCheck = new Elysia()
	.onBeforeHandle(
		{ as: 'scoped' }, // [!code ++]
		({ query: { name }, status }) => {
			if(!name) return status(401)
		}
	)

const ageCheck = new Elysia()
	.guard({
		as: 'global', // [!code ++]
		query: t.Object({
			age: t.Number(),
			name: t.Optional(t.String())
		}),
		beforeHandle({ query: { age }, status }) {
			if(age < 18) return status(403)
		}
	})

const name = new Elysia()
	.use(nameCheck)
	.patch('/rename', () => 'Ok! XD')

const profile = new Elysia()
	.use(ageCheck)
	.use(name)
	.get('/profile', () => 'Hi!')

new Elysia()
	.use(profile)
	.listen(3000)
```

---

## Handler and Context

**URL:** https://elysiajs.com/tutorial/getting-started/handler-and-context.md

**Contents:**
- Context
- Preview
- Assignment

---
url: 'https://elysiajs.com/tutorial/getting-started/handler-and-context.md'
---

**Handler** - a resource or a route function to send data back to client.

A handler can also be a literal value, see Handler

Using an inline value can be useful for static resource like **file**.

Contains information about each request. It is passed as the only argument of a handler.

**Context** stores information about the request like:

* body - data sent by client to server like form data, JSON payload.
* query - query string as an object. (Query is extracted from a value after pathname starting from '?' question mark sign)
* params - Path parameters parsed as object
* headers - HTTP Header, additional information about the request like "Content-Type".

You can preview the result by looking under the **editor** section.

There should be a tiny navigator on the **top left** of the preview window.

You can use it to switch between path and method to see the response.

You can also click  to edit body, and headers.

Let's try extracting context parameters:

1. We can extract `body`, `query`, and `headers` from the first value of a callback function.
2. We can then return them like `{ body, query, headers }`.

**Examples:**

Example 1 (ts):
```ts
import { Elysia } from 'elysia'

new Elysia()
    // `() => 'hello world'` is a handler
    .get('/', () => 'hello world')
    .listen(3000)
```

Example 2 (ts):
```ts
import { Elysia } from 'elysia'

new Elysia()
    // `'hello world'` is a handler
    .get('/', 'hello world')
    .listen(3000)
```

Example 3 (unknown):
```unknown
**Context** stores information about the request like:

* body - data sent by client to server like form data, JSON payload.
* query - query string as an object. (Query is extracted from a value after pathname starting from '?' question mark sign)
* params - Path parameters parsed as object
* headers - HTTP Header, additional information about the request like "Content-Type".

See Context.

## Preview

You can preview the result by looking under the **editor** section.

There should be a tiny navigator on the **top left** of the preview window.

You can use it to switch between path and method to see the response.

You can also click  to edit body, and headers.

## Assignment

Let's try extracting context parameters:

\<template #answer>

1. We can extract `body`, `query`, and `headers` from the first value of a callback function.
2. We can then return them like `{ body, query, headers }`.
```

---

## Guard

**URL:** https://elysiajs.com/tutorial/getting-started/guard.md

**Contents:**
- Assignment

---
url: 'https://elysiajs.com/tutorial/getting-started/guard.md'
---

When you need to apply multiple hook to your application, instead of repeating hook multiple time, you can use `guard` to bulk add hooks to your application.

Not only that, you can also apply **schema** to multiple routes using `guard`.

This will apply hooks and schema to every routes **after .guard** is called in the same instance.

See Guard for more information.

Let's put 2 types of hooks into practice.

We can use `beforeHandle` to intercept the request before it reaches the handler, and return a response with `status` method.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia, t } from 'elysia'

new Elysia()
	.onBeforeHandle(({ query: { name }, status }) => { // [!code --]
		if(!name) return status(401) // [!code --]
	}) // [!code --]
	.onBeforeHandle(({ query: { name } }) => { // [!code --]
		console.log(name) // [!code --]
	}) // [!code --]
	.onAfterResponse(({ responseValue }) => { // [!code --]
		console.log(responseValue) // [!code --]
	}) // [!code --]
	.guard({ // [!code ++]
		beforeHandle: [ // [!code ++]
			({ query: { name }, status }) => { // [!code ++]
				if(!name) return status(401) // [!code ++]
			}, // [!code ++]
			({ query: { name } }) => { // [!code ++]
				console.log(name) // [!code ++]
			} // [!code ++]
		], // [!code ++]
		afterResponse({ responseValue }) { // [!code ++]
			console.log(responseValue) // [!code ++]
		} // [!code ++]
	}) // [!code ++]
	.get(
		'/auth',
		({ query: { name = 'anon' } }) => `Hello ${name}!`,
		{
			query: t.Object({
				name: t.String()
			})
		}
	)
	.get(
		'/profile',
		({ query: { name = 'anon' } }) => `Hello ${name}!`,
		{
			query: t.Object({
				name: t.String()
			})
		}
	)
	.listen(3000)
```

Example 2 (typescript):
```typescript
import { Elysia, t } from 'elysia'

new Elysia()
	.guard({
		beforeHandle: [
			({ query: { name }, status }) => {
				if(!name) return status(401)
			},
			({ query: { name } }) => {
				console.log(name)
			}
		],
		afterResponse({ responseValue }) {
			console.log(responseValue)
		},
		query: t.Object({ // [!code ++]
			name: t.String() // [!code ++]
		}) // [!code ++]
	})
	.get(
		'/auth',
		({ query: { name = 'anon' } }) => `Hello ${name}!`,
		{ // [!code --]
			query: t.Object({ // [!code --]
				name: t.String() // [!code --]
			}) // [!code --]
		} // [!code --]
	)
	.get(
		'/profile',
		({ query: { name = 'anon' } }) => `Hello ${name}!`,
		{ // [!code --]
			query: t.Object({ // [!code --]
				name: t.String() // [!code --]
			}) // [!code --]
		} // [!code --]
	)
	.listen(3000)
```

Example 3 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.onBeforeHandle(({ query: { name }, status }) => {
		if(!name) return status(401)
	})
	.get('/auth', ({ query: { name = 'anon' } }) => {
		return `Hello ${name}!`
	})
	.get('/profile', ({ query: { name = 'anon' } }) => {
		return `Hello ${name}!`
	})
	.listen(3000)
```

---

## Validation

**URL:** https://elysiajs.com/tutorial/getting-started/validation.md

**Contents:**
  - Bring your own
- Validation Type
- Response Validation
- Assignment

---
url: 'https://elysiajs.com/tutorial/getting-started/validation.md'
---

Elysia offers data validation out of the box.

You can use `Elysia.t` to define a schema.

When you define a schema, Elysia will ensure the data is in a correct shape.

If the data doesn't match the schema, Elysia will return a **422 Unprocessable Entity** error.

Alternatively, Elysia support **Standard Schema**, allowing you to use a library of your choice like **zod**, **yup** or **valibot**.

See Standard Schema for all compatible schema.

You can validate the following property:

* `body`
* `query`
* `params`
* `headers`
* `cookie`
* `response`

Once schema is defined, Elysia will infers type for you so You don't have to define a separate schema in TypeScript.

See Schema Type for each type.

When you define a validation schema for `response`, Elysia will validate the response before sending it to the client, and type check the response for you.

You can also specify which status code to validate:

See Response Validation.

Let's exercise what we have learned.

We can define a schema by using `t.Object` provide to `body` property.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia, t } from 'elysia'

new Elysia()
	.post(
		'/user',
		({ body: { name } }) => `Hello ${name}!`,
		{
			body: t.Object({
				name: t.String(),
				age: t.Number()
			})
		}
	)
	.listen(3000)
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'
import { z } from 'zod'

new Elysia()
	.post(
		'/user',
		({ body: { name } }) => `Hello ${name}!`,
		{
			body: z.object({
				name: z.string(),
				age: z.number()
			})
		}
	)
	.listen(3000)
```

Example 3 (typescript):
```typescript
import { Elysia, t } from 'elysia'

new Elysia()
	.get(
		'/user',
		() => `Hello Elysia!`,
		{
			response: {
				200: t.Literal('Hello Elysia!'),
				418: t.Object({
					message: t.Literal("I'm a teapot")
				})
			}
		}
	)
	.listen(3000)
```

Example 4 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.get('/', ({ status, set }) => {
		set.headers['x-powered-by'] = 'Elysia'

		return status(418, 'Hello Elysia!')
	})
	.get('/docs', ({ redirect }) => redirect('https://elysiajs.com'))
	.listen(3000)
```

---

## Congratulations!

**URL:** https://elysiajs.com/tutorial/whats-next.md

**Contents:**
- First up
  - llms.txt
  - If you are stuck
- From other Framework?
- Essential Chapter
- More Patterns
- Integration with Meta Framework
- Integration with your favorite tool

---
url: 'https://elysiajs.com/tutorial/whats-next.md'
---

You have completed the tutorial.

Now you're ready to build your own application with Elysia!

We highly recommended you to check out these 2 pages first before getting started with Elysia:

Alternatively, you can download llms.txt or llms-full.txt and feed it to your favorite LLMs like ChatGPT, Claude or Gemini to get a more interactive experience.

Feel free to ask our community on GitHub Discussions, Discord, and Twitter.

If you have used other popular frameworks like Express, Fastify, or Hono, you will find Elysia right at home with just a few differences.

Here are the foundation of Elysia, we highly recommended you to go through these pages before jumping to other topics:

If you feels like exploring more Elysia feature, check out:

We can also use Elysia with Meta Framework like Nextjs, Nuxt, Astro, etc.

We have some integration with popular tools:

We hope you will love Elysia as much as we do!

---

## Your First Route

**URL:** https://elysiajs.com/tutorial/getting-started/your-first-route.md

**Contents:**
- Routing
- Static Path
- Dynamic path
  - Optional path parameters
- Wildcards
- Assignment

---
url: 'https://elysiajs.com/tutorial/getting-started/your-first-route.md'
---

When we enter a website, it takes

1. **path** like `/`, `/about`, or `/contact`
2. **method** like `GET`, `POST`, or `DELETE`

To determine what a resource to show, simply called **"route"**.

In Elysia, we can define a route by:

1. Call method named after HTTP method
2. Path being the first argument
3. Handler being the second argument

Path in Elysia can be grouped into 3 types:

1. static paths - static string to locate the resource
2. dynamic paths - segment can be any value
3. wildcards - path until a specific point can be anything

Static path is a hardcoded string to locate the resource on the server.

Dynamic paths match some part and capture the value to extract extra information.

To define a dynamic path, we can use a colon `:` followed by a name.

Here, a dynamic path is created with `/id/:id`. Which tells Elysia to capture the value `:id` segment with value like **/id/1**, **/id/123**, **/id/anything**.

We can make a path parameter optional by adding a question mark `?` after the parameter name.

See Optional Path Parameters.

Dynamic paths allow capturing a single segment while wildcards allow capturing the rest of the path.

To define a wildcard, we can use an asterisk `*`.

Let's recap, and create 3 paths with different types:

1. Static path `/elysia` that responds with `"Hello Elysia!"`
2. Dynamic path `/friends/:name?` that responds with `"Hello {name}!"`
3. Wildcard path `/flame-chasers/*` that responds with the rest of the path.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.get('/', 'Hello World!')
	.listen(3000)
```

Example 2 (ts):
```ts
import { Elysia } from 'elysia'

new Elysia()
	.get('/hello', 'hello')
	.get('/hi', 'hi')
	.listen(3000)
```

Example 3 (unknown):
```unknown
Here, a dynamic path is created with `/id/:id`. Which tells Elysia to capture the value `:id` segment with value like **/id/1**, **/id/123**, **/id/anything**.

See Dynamic Path.

### Optional path parameters

We can make a path parameter optional by adding a question mark `?` after the parameter name.
```

Example 4 (unknown):
```unknown
See Optional Path Parameters.

## Wildcards

Dynamic paths allow capturing a single segment while wildcards allow capturing the rest of the path.

To define a wildcard, we can use an asterisk `*`.
```

---

## Welcome to Elysia

**URL:** https://elysiajs.com/tutorial.md

**Contents:**
- What is Elysia
- How to use this playground
- Assignment

---
url: 'https://elysiajs.com/tutorial.md'
---

It's great to have you here! This playground is will help you get started with Elysia interactively.

Unlike traditional backend framework, **Elysia can also run in a browser** as well! Although it doesn't support all features, it's a perfect environment for learning and experimentation.

You can check out the API docs by clicking  on the left sidebar.

Elysia is an ergonomic framework for humans.

Ok, seriously, Elysia is a backend TypeScript framework that focuses on developer experience and performance.

What makes Elysia different from other frameworks is that:

1. Spectacular performance comparable to Golang.
2. Extraordinary TypeScript support with **type soundness**.
3. Built around OpenAPI from the ground up.
4. Offers End-to-end Type Safety like tRPC.
5. Use Web Standard, allows you to run your code anywhere like Cloudflare Workers, Deno, Bun, Node.js and more.
6. It is, of course, **designed for humans** first.

Although Elysia has some important concept but once get the hang of it, many people find it very enjoyable, and intuative to work with.

Playground is divided into 3 sections:

1. Documentation and task on the left side (you're reading).
2. Code editor in the top right
3. Preview, output, and console in the bottom right

As for the first assignment, let's modify the code to make the server respond with `"Hello Elysia!"` instead of `"Hello World!"`.

Feels free to look around the code editor and preview section to get familiar with the environment.

You can change the response by changing the content inside the `.get` method from `'Hello World!'` to `'Hello Elysia!'`.

This would make Elysia response with `"Hello Elysia!"` when you access `/`.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.get('/', 'Hello World!') // [!code --]
	.get('/', 'Hello Elysia!') // [!code ++]
	.listen(3000)
```

---
