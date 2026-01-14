# Elysia - Patterns

**Pages:** 21

---

## Macro

**URL:** https://elysiajs.com/tutorial/patterns/macro.md

**Contents:**
- Assignment

---
url: 'https://elysiajs.com/tutorial/patterns/macro.md'
---

A reusable route options.

Imagine we have an authentication check like this:

If we have multiple routes that require authentication, we have to repeat the same options over and over again.

Instead, we can use a macro to reuse route options:

**auth** will then inline both **cookie**, and **beforeHandle** to the route.

Simply put, Macro **is a reusable route options**, similar to function but as a route options with **type soundness**.

Let's define a macro to check if a body is a fibonacci number:

1. To enforce type, we can define a `body` property in the macro.
2. To short-circuit the request, we can use `status` function to return early.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia, t } from 'elysia'

new Elysia()
	.post('/user', ({ body }) => body, {
		cookie: t.Object({
			session: t.String()
		}),
		beforeHandle({ cookie: { session } }) {
			if(!session.value) throw 'Unauthorized'
		}
	})
	.listen(3000)
```

Example 2 (typescript):
```typescript
import { Elysia, t } from 'elysia'

new Elysia()
	.macro('auth', {
		cookie: t.Object({
			session: t.String()
		}),
		// psuedo auth check
		beforeHandle({ cookie: { session }, status }) {
			if(!session.value) return status(401)
		}
	})
	.post('/user', ({ body }) => body, {
		auth: true // [!code ++]
	})
	.listen(3000)
```

Example 3 (typescript):
```typescript
function isFibonacci(n: number) {
	let a = 0, b = 1
	while(b < n) [a, b] = [b, a + b]
	return b === n || n === 0
}
```

Example 4 (typescript):
```typescript
import { Elysia, t } from 'elysia'

function isPerfectSquare(x: number) {
    const s = Math.floor(Math.sqrt(x))
    return s * s === x
}

function isFibonacci(n: number) {
    if (n < 0) return false

    return isPerfectSquare(5 * n * n + 4) || isPerfectSquare(5 * n * n - 4)
}

new Elysia()
    .macro('isFibonacci', {
		body: t.Number(),
        beforeHandle({ body, status }) {
            if(!isFibonacci(body)) return status(418)
        }
    })
	.post('/', ({ body }) => body, {
		isFibonacci: true
	})
    .listen(3000)
```

---

## Error Handling&#x20;

**URL:** https://elysiajs.com/patterns/error-handling.md

**Contents:**
- Custom Validation Message
  - Validation Detail&#x20;
- Validation Detail on production
- Custom Error
  - Custom Status Code
  - Custom Error Response
- To Throw or Return

---
url: 'https://elysiajs.com/patterns/error-handling.md'
---

This page provide a more advance guide for effectively handling errors with Elysia.

If you haven't read **"Life Cycle (onError)"** yet, we recommend you to read it first.

When defining a schema, you can provide a custom validation message for each field.

This message will be returned as-is when the validation fails.

If the validation fails on the `id` field, the response will be return as `id must be a number`.

Returning as value from `schema.error` will return the validation as-is, but sometimes you may also want to return the validation details, such as the field name and the expected type

You can do this by using the `validationDetail` option.

This will include all of the validation details in the response, such as the field name and the expected type.

But if you're planned to use `validationDetail` in every field, adding it manually can be annoying.

You can automatically add validation detail by handling it in `onError` hook.

This will apply every validation error with a custom message with custom validation message.

By default, Elysia will omitted all validation detail if `NODE_ENV` is `production`.

This is done to prevent leaking sensitive information about the validation schema, such as field names and expected types, which could be exploited by an attacker.

Elysia will only return that validation failed without any details.

The `message` property is optional and is omitted by default unless you provide a custom error message in the schema.

This can be overridden by setting `Elysia.allowUnsafeValidationDetails` to `true`, see [Elysia configuration](/patterns/configuration#allow-unsafe-validation-details) for more details.

Elysia supports custom error both in the type-level and implementation level.

By default, Elysia have a set of built-in error types like `VALIDATION`, `NOT_FOUND` which will narrow down the type automatically.

If Elysia doesn't know the error, the error code will be `UNKNOWN` with default status of `500`

But you can also add a custom error with type safety with `Elysia.error` which will help narrow down the error type for full type safety with auto-complete, and custom status code as follows:

You can also provide a custom status code for your custom error by adding `status` property in your custom error class.

Elysia will then use this status code when the error is thrown.

Otherwise you can also set the status code manually in the `onError` hook.

You can also provide a custom `toResponse` method in your custom error class to return a custom response when the error is thrown.

Most of an error handling in Elysia can be done by throwing an error and will be handle in `onError`.

But for `status` it can be a little bit confusing, since it can be used both as a return value or throw an error.

It could either be **return** or **throw** based on your specific needs.

* If an `status` is **throw**, it will be caught by `onError` middleware.
* If an `status` is **return**, it will be **NOT** caught by `onError` middleware.

See the following code:

**Examples:**

Example 1 (ts):
```ts
import { Elysia } from 'elysia'

new Elysia().get('/:id', ({ params: { id } }) => id, {
    params: t.Object({
        id: t.Number({
            error: 'id must be a number' // [!code ++]
        })
    })
})
```

Example 2 (ts):
```ts
import { Elysia, validationDetail } from 'elysia' // [!code ++]

new Elysia().get('/:id', ({ params: { id } }) => id, {
    params: t.Object({
        id: t.Number({
            error: validationDetail('id must be a number') // [!code ++]
        })
    })
})
```

Example 3 (ts):
```ts
new Elysia()
    .onError(({ error, code }) => {
        if (code === 'VALIDATION') return error.detail(error.message) // [!code ++]
    })
    .get('/:id', ({ params: { id } }) => id, {
        params: t.Object({
            id: t.Number({
                error: 'id must be a number'
            })
        })
    })
    .listen(3000)
```

Example 4 (json):
```json
{
    "type": "validation",
    "on": "body",
    "found": {},
    // Only shown for custom error
    "message": "x must be a number"
}
```

---

## Extends Context

**URL:** https://elysiajs.com/tutorial/patterns/extends-context.md

**Contents:**
- Decorate
- State
- Resolve / Derive
- Scope
- Assignment

---
url: 'https://elysiajs.com/tutorial/patterns/extends-context.md'
---

Elysia provides a context with small utilities to help you get started.

You can extends Elysia's context with:

1. Decorate
2. State
3. Resolve
4. Derive

**Singleton**, and **immutable** that shared across all requests.

Decorated value it will be available in the context as a read-only property, see Decorate.

A **mutable** reference that shared across all requests.

State will be available in **context.store** that is shared across every request, see State.

Decorate value is registered as a singleton.

While Resolve, and Derive allows you to abstract a context value **per request**.

Any **returned value will available in context** except status, which will be send to client directly, and abort the subsequent handlers.

Syntax for both resolve, derive is similar but they have different use cases.

Under the hood, both is a syntax sugar (with type safety) of a lifecycle:

* derive is based on transform
* resolve is based on before handle

Since derive is based on transform means that data isn't validated, and coerce/transform yet. It's better to use resolve if you need a validated data.

State, and Decorate are shared across all requests, and instances.

Resolve, and Derive are per request, and has a encapulation scope (as they're based on life-cycle event).

If you want to use a resolved/derived value from a plugin, you would have to declare a Scope.

Let's try to extends Elysia's context.

We can use resolve to extract age from query.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'

class Logger {
    log(value: string) {
        console.log(value)
    }
}

new Elysia()
    .decorate('logger', new Logger())
    .get('/', ({ logger }) => {
        logger.log('hi')

        return 'hi'
    })
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.state('count', 0)
	.get('/', ({ store }) => {
		store.count++

		return store.count
	})
```

Example 3 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.derive(({ headers: { authorization } }) => ({
		authorization
	}))
	.get('/', ({ authorization }) => authorization)
```

Example 4 (typescript):
```typescript
import { Elysia } from 'elysia'

const plugin = new Elysia()
	.derive(
		{ as: 'scoped' }, // [!code ++]
		({ headers: { authorization } }) => ({
			authorization
		})
	)

new Elysia()
	.use(plugin)
	.get('/', ({ authorization }) => authorization)
	.listen(3000)
```

---

## Elysia with Bun Fullstack Dev Server

**URL:** https://elysiajs.com/patterns/fullstack-dev-server.md

**Contents:**
- Custom prefix path
- Tailwind CSS
- Path Alias
- Build for Production

---
url: 'https://elysiajs.com/patterns/fullstack-dev-server.md'
---

Bun 1.3 introduce a [Fullstack Dev Server](https://bun.com/docs/bundler/fullstack) with HMR support.

This allows us to directly use React without any bundler like Vite or Webpack.

You can use [this example](https://github.com/saltyaom/elysia-fullstack-example) to quickly try it out.

Otherwise, install it manually:

1. Install Elysia Static plugin

:::tip
Notice that we need to add `await` before `staticPlugin()` to enable Fullstack Dev Server.

This is required to setup the necessary HMR hooks.
:::

2. Create **public/index.html** and **index.tsx**

3. Enable JSX in tsconfig.json

4. Navigate to `http://localhost:3000/public` and see the result.

This would allows us to develop frontend and backend in a single project without any bundler.

We have verified that Fullstack Dev Server works with HMR, [Tailwind](#tailwind), Tanstack Query, [Eden Treaty](/eden/overview), and path alias.

We can change the default `/public` prefix by passing the `prefix` option to `staticPlugin`.

This would serve the static files at `/` instead of `/public`.

See [static plugin](/plugins/static) for more configuration options.

We can also use Tailwind CSS with Bun Fullstack Dev Server.

1. Install dependencies

2. Create `bunfig.toml` with the following content:

3. Create a CSS file with Tailwind directives

4. Add Tailwind to your HTML or alternatively JavaScript/TypeScript file

We can also use path alias in Bun Fullstack Dev Server.

1. Add `paths` in `tsconfig.json`

2. Use the alias in your code

This would works out of the box without any additional configuration.

You can build fullstack server as if it's a normal Elysia server.

This would create a single executable file **server**.

When running the **server** executable, make sure to include the **public** folder in similar to the development environment.

See [Deploy to Production](/patterns/deploy) for more information.

**Examples:**

Example 1 (ts):
```ts
import { Elysia } from 'elysia'
import { staticPlugin } from '@elysiajs/static'

new Elysia()
	.use(await staticPlugin()) // [!code ++]
	.listen(3000)
```

Example 2 (unknown):
```unknown
:::

3. Enable JSX in tsconfig.json
```

Example 3 (unknown):
```unknown
4. Navigate to `http://localhost:3000/public` and see the result.

This would allows us to develop frontend and backend in a single project without any bundler.

We have verified that Fullstack Dev Server works with HMR, [Tailwind](#tailwind), Tanstack Query, [Eden Treaty](/eden/overview), and path alias.

## Custom prefix path

We can change the default `/public` prefix by passing the `prefix` option to `staticPlugin`.
```

Example 4 (unknown):
```unknown
This would serve the static files at `/` instead of `/public`.

See [static plugin](/plugins/static) for more configuration options.

## Tailwind CSS

We can also use Tailwind CSS with Bun Fullstack Dev Server.

1. Install dependencies
```

---

## TypeScript

**URL:** https://elysiajs.com/patterns/typescript.md

**Contents:**
- Inference
  - Schema to Type
- Type Performance
  - Eden

---
url: 'https://elysiajs.com/patterns/typescript.md'
---

Elysia has a first-class support for TypeScript out of the box.

Most of the time, you wouldn't need to add any TypeScript annotations manually.

Elysia infers the type of request and response based on the schema you provide.

Elysia can automatically infers type from schema like TypeBox and [your favorite validation library](/essential/validation#standard-schema) like:

* Zod
* Valibot
* ArkType
* Effect Schema
* Yup
* Joi

All of schema library supported by Elysia can be converted to TypeScript type.

\<Tab
id="quickstart"
:names="\['TypeBox', 'Zod', 'Valibot', 'ArkType']"
:tabs="\['typebox', 'zod', 'valibot', 'arktype']"
noTitle

Elysia is built with type inference performance in mind.

Before every release, we have a local benchmark to ensure that type inference is always snappy, fast, and doesn't blow up your IDE with "Type instantiation is excessively deep and possibly infinite" error.

Most of the time writing Elysia, you wouldn't encounter any type performance issue.

However, if you do, here are how to break down what's slowing down your type inference:

1. Navigate to the root of your project and runs

This should generate a `trace` folder in your project root.

2. Open [Perfetto UI](https://ui.perfetto.dev) and drag the `trace/trace.json` file

![Perfetto](/assets/perfetto.webp)

> It should show you a flame graph like this

Then you can find a chunk that takes a long time to be evaluated, click on it and it should show you how long the inference take, and which file, and line number it is coming from.

This should help you to identify the bottleneck of your type inference.

If you are having a slow type inference issue when using [Eden](/eden/overview), you can try using a sub app of Elysia to isolate the type inference.

And on your frontend, you can import the sub app instead of the whole app.

This should make your type inference faster it doesn't need to evaluate the whole app.

See [Eden Treaty](/eden/overview) to learn more about Eden.

**Examples:**

Example 1 (unknown):
```unknown
Elysia can automatically infers type from schema like TypeBox and [your favorite validation library](/essential/validation#standard-schema) like:

* Zod
* Valibot
* ArkType
* Effect Schema
* Yup
* Joi

### Schema to Type

All of schema library supported by Elysia can be converted to TypeScript type.

\<Tab
id="quickstart"
:names="\['TypeBox', 'Zod', 'Valibot', 'ArkType']"
:tabs="\['typebox', 'zod', 'valibot', 'arktype']"
noTitle

>
```

Example 2 (unknown):
```unknown
## Type Performance

Elysia is built with type inference performance in mind.

Before every release, we have a local benchmark to ensure that type inference is always snappy, fast, and doesn't blow up your IDE with "Type instantiation is excessively deep and possibly infinite" error.

Most of the time writing Elysia, you wouldn't encounter any type performance issue.

However, if you do, here are how to break down what's slowing down your type inference:

1. Navigate to the root of your project and runs
```

Example 3 (unknown):
```unknown
This should generate a `trace` folder in your project root.

2. Open [Perfetto UI](https://ui.perfetto.dev) and drag the `trace/trace.json` file

![Perfetto](/assets/perfetto.webp)

> It should show you a flame graph like this

Then you can find a chunk that takes a long time to be evaluated, click on it and it should show you how long the inference take, and which file, and line number it is coming from.

This should help you to identify the bottleneck of your type inference.

### Eden

If you are having a slow type inference issue when using [Eden](/eden/overview), you can try using a sub app of Elysia to isolate the type inference.
```

Example 4 (unknown):
```unknown
And on your frontend, you can import the sub app instead of the whole app.
```

---

## OpenAPI&#x20;

**URL:** https://elysiajs.com/patterns/openapi.md

**Contents:**
- OpenAPI from types
  - Production
  - Caveat: Explicit types
  - Caveat: Root path
  - Custom tsconfig.json
- Standard Schema with OpenAPI
  - Zod OpenAPI
  - Valibot OpenAPI
  - Effect OpenAPI
- Describing route

---
url: 'https://elysiajs.com/patterns/openapi.md'
---

Elysia has first-class support and follows OpenAPI schema by default.

Elysia can automatically generate an API documentation page by using an OpenAPI plugin.

To generate the Swagger page, install the plugin:

And register the plugin to the server:

Accessing `/openapi` would show you a Scalar UI with the generated endpoint documentation from the Elysia server.

For OpenAPI plugin configuration, see the [OpenAPI plugin page](/plugins/openapi).

> This is optional, but we highly recommend it for much better documentation experience.

By default, Elysia relies on runtime schema to generate OpenAPI documentation.

However, you can also generate OpenAPI documentation from types by using a generator from OpenAPI plugin as follows:

1. Specify your Elysia root file (if not specified, Elysia will use `src/index.ts`), and export an instance

2. Import a generator and provide a **file path from project root** to type generator

Elysia will attempt to generate OpenAPI documentation by reading the type of an exported instance to generate OpenAPI documentation.

This will co-exists with the runtime schema, and the runtime schema will take precedence over the type definition.

In production environment, it's likely that you might compile Elysia to a [single executable with Bun](/patterns/deploy.html) or [bundle into a single JavaScript file](https://elysiajs.com/patterns/deploy.html#compile-to-javascript).

It's recommended that you should pre-generate the declaration file (**.d.ts**) to provide type declaration to the generator.

OpenAPI Type Gen work best when using implicit types.

Sometime, explicit type may cause an issue to generator unable to resolve properly.

In this case, you can use `Prettify` to inline the type:

This should fix when type not showing up.

As it's unreliable to guess to root of the project, it's recommended to provide the path to the project root to allow generator to run correctly, especially when using monorepo.

If you have multiple `tsconfig.json` files, it's important that you must specify a correct `tsconfig.json` file to be used for type generation.

Elysia will try to use a native method from each schema to convert to OpenAPI schema.

However, if the schema doesn't provide a native method, you can provide a custom schema to OpenAPI by providing a `mapJsonSchema` as follows:

\<Tab
id="schema-openapi"
noTitle
:names="\['Zod', 'Valibot', 'Effect']"
:tabs="\['zod', 'valibot', 'effect']"

As Zod doesn't have a `toJSONSchema` method on the schema, we need to provide a custom mapper to convert Zod schema to OpenAPI schema.

Valibot use a separate package (`@valibot/to-json-schema`) to convert Valibot schema to JSON Schema.

As Effect doesn't have a `toJSONSchema` method on the schema, we need to provide a custom mapper to convert Effect schema to OpenAPI schema.

We can add route information by providing a schema type.

However, sometimes defining only a type does not make it clear what the route might do. You can use [detail](/plugins/openapi#detail) fields to explicitly describe the route.

The detail fields follows an OpenAPI V3 definition with auto-completion and type-safety by default.

Detail is then passed to OpenAPI to put the description to OpenAPI route.

We can add a response headers by wrapping a schema with `withHeader`:

Note that `withHeader` is an annotation only, and does not enforce or validate the actual response headers. You need to set the headers manually.

You can hide the route from the Swagger page by setting `detail.hide` to `true`

Elysia can separate the endpoints into groups by using the Swaggers tag system

Firstly define the available tags in the swagger config object

Then use the details property of the endpoint configuration section to assign that endpoint to the group

Which will produce a swagger page like the following

Elysia may accept tags to add an entire instance or group of routes to a specific tag.

By using [reference model](/essential/validation.html#reference-model), Elysia will handle the schema generation automatically.

By separating models into a dedicated section and linked by reference.

Alternatively, Elysia may accept guards to add an entire instance or group of routes to a specific guard.

You can change the OpenAPI endpoint by setting [path](#path) in the plugin config.

We can customize the OpenAPI information by setting [documentation.info](#documentationinfo) in the plugin config.

This can be useful for

* adding a title
* settings an API version
* adding a description explaining what our API is about
* explaining what tags are available, what each tag means

To secure your API endpoints, you can define security schemes in the Swagger configuration. The example below demonstrates how to use Bearer Authentication (JWT) to protect your endpoints:

This will ensures that all endpoints under the `/address` prefix require a valid JWT token for access.

**Examples:**

Example 1 (bash):
```bash
bun add @elysiajs/openapi
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'
import { openapi } from '@elysiajs/openapi' // [!code ++]

new Elysia()
	.use(openapi()) // [!code ++]
```

Example 3 (ts):
```ts
import { Elysia, t } from 'elysia'
import { openapi, fromTypes } from '@elysiajs/openapi' // [!code ++]

export const app = new Elysia() // [!code ++]
    .use(
        openapi({
            references: fromTypes() // [!code ++]
        })
    )
    .get('/', { test: 'hello' as const })
    .post('/json', ({ body, status }) => body, {
        body: t.Object({
            hello: t.String()
        })
    })
    .listen(3000)
```

Example 4 (ts):
```ts
import { Elysia, t } from 'elysia'
import { openapi, fromTypes } from '@elysiajs/openapi'

const app = new Elysia()
    .use(
        openapi({
            references: fromTypes(
            	process.env.NODE_ENV === 'production' // [!code ++]
             		? 'dist/index.d.ts' // [!code ++]
               		: 'src/index.ts' // [!code ++]
            )
        })
    )
```

---

## Unit Test&#x20;

**URL:** https://elysiajs.com/patterns/unit-test.md

**Contents:**
- Eden Treaty test

---
url: 'https://elysiajs.com/patterns/unit-test.md'
---

Being WinterCG compliant, we can use Request / Response classes to test an Elysia server.

Elysia provides the **Elysia.handle** method, which accepts a Web Standard [Request](https://developer.mozilla.org/en-US/docs/Web/API/Request) and returns [Response](https://developer.mozilla.org/en-US/docs/Web/API/Response), simulating an HTTP Request.

Bun includes a built-in [test runner](https://bun.sh/docs/cli/test) that offers a Jest-like API through the `bun:test` module, facilitating the creation of unit tests.

Create **test/index.test.ts** in the root of project directory with the following:

Then we can perform tests by running **bun test**

New requests to an Elysia server must be a fully valid URL, **NOT** a part of a URL.

The request must provide URL as the following:

| URL                   | Valid |
| --------------------- | ----- |
| http://localhost/user | ✅    |
| /user                 | ❌    |

We can also use other testing libraries like Jest to create Elysia unit tests.

We may use Eden Treaty to create an end-to-end type safety test for Elysia server as follows:

See [Eden Treaty Unit Test](/eden/treaty/unit-test) for setup and more information.

**Examples:**

Example 1 (typescript):
```typescript
// test/index.test.ts
import { describe, expect, it } from 'bun:test'
import { Elysia } from 'elysia'

describe('Elysia', () => {
    it('returns a response', async () => {
        const app = new Elysia().get('/', () => 'hi')

        const response = await app
            .handle(new Request('http://localhost/'))
            .then((res) => res.text())

        expect(response).toBe('hi')
    })
})
```

---

## Cookie

**URL:** https://elysiajs.com/tutorial/patterns/cookie.md

**Contents:**
- Value
- Attribute
- Remove
- Cookie Signature
- Assignment

---
url: 'https://elysiajs.com/tutorial/patterns/cookie.md'
---

You interact with cookie by using cookie from context.

Cookie is a reactive object. Once modified, it will be reflected in response.

Elysia will then try to coerce it into its respective value when a type annotation if provided.

We can use cookie schema to validate and parse cookie.

We can get/set cookie attribute by its respective property name.

Otherwise, use `.set()` to bulk set attribute.

See Cookie Attribute.

We can remove cookie by calling `.remove()` method.

Elysia can sign cookie to prevent tampering by:

1. Provide cookie secret to Elysia constructor.
2. Use `t.Cookie` to provide secret for each cookie.

If multiple secrets are provided, Elysia will use the first secret to sign cookie, and try to verify with the rest.

See Cookie Signature, Cookie Rotation.

Let's create a simple counter that tracks how many times you have visited the site.

1. We can update the cookie value by modifying `visit.value`.
2. We can set **HTTP only** attribute by setting `visit.httpOnly = true`.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.get('/', ({ cookie: { visit } }) => {
		const total = +visit.value ?? 0
		visit.value++

		return `You have visited ${visit.value} times`
	})
	.listen(3000)
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.get('/', ({ cookie: { visit } }) => {
		visit.value ??= 0
		visit.value.total++

		return `You have visited ${visit.value.total} times`
	}, {
		cookie: t.Object({
			visit: t.Optional(
				t.Object({
					total: t.Number()
				})
			)
		})
	})
	.listen(3000)
```

Example 3 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.get('/', ({ cookie: { visit } }) => {
		visit.value ??= 0
		visit.value++

		visit.httpOnly = true
		visit.path = '/'

		visit.set({
			sameSite: 'lax',
			secure: true,
			maxAge: 60 * 60 * 24 * 7
		})

		return `You have visited ${visit.value} times`
	})
	.listen(3000)
```

Example 4 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.get('/', ({ cookie: { visit } }) => {
		visit.remove()

		return `Cookie removed`
	})
	.listen(3000)
```

---

## Mount&#x20;

**URL:** https://elysiajs.com/patterns/mount.md

**Contents:**
- Mount

---
url: 'https://elysiajs.com/patterns/mount.md'
---

[WinterTC](https://wintertc.org/) is a standard for building HTTP Server behind Cloudflare, Deno, Vercel, and others.

It allows web servers to run interoperably across runtimes by using [Request](https://developer.mozilla.org/en-US/docs/Web/API/Request), and [Response](https://developer.mozilla.org/en-US/docs/Web/API/Response).

Elysia is WinterTC compliant. Optimized to run on Bun, but also support other runtimes if possible.

This allows any framework or code that is WinterCG compliant to be run together, allowing frameworks like Elysia, Hono, Remix, Itty Router to run together in a simple function.

To use **.mount**, [simply pass a `fetch` function](https://twitter.com/saltyAom/status/1684786233594290176):

Any framework that use `Request`, and `Response` can be interoperable with Elysia like

* Hono
* Nitro
* H3
* [Nextjs API Route](/integrations/nextjs)
* [Nuxt API Route](/integrations/nuxt)
* [SvelteKit API Route](/integrations/sveltekit)

And these can be use on multiple runtimes like:

* Bun
* Deno
* Vercel Edge Runtime
* Cloudflare Worker
* Netlify Edge Function

If the framework supports a **.mount** function, you can also mount Elysia inside another framework:

This makes the possibility of an interoperable framework and runtime a reality.

**Examples:**

Example 1 (ts):
```ts
import { Elysia } from 'elysia'
import { Hono } from 'hono'

const hono = new Hono()
	.get('/', (c) => c.text('Hello from Hono!'))

const app = new Elysia()
    .get('/', () => 'Hello from Elysia')
    .mount('/hono', hono.fetch)
```

Example 2 (ts):
```ts
import { Elysia } from 'elysia'
import { Hono } from 'hono'

const elysia = new Elysia()
    .get('/', () => 'Hello from Elysia inside Hono inside Elysia')

const hono = new Hono()
    .get('/', (c) => c.text('Hello from Hono!'))
    .mount('/elysia', elysia.fetch)

const main = new Elysia()
    .get('/', () => 'Hello from Elysia')
    .mount('/hono', hono.fetch)
    .listen(3000)
```

---

## Trace

**URL:** https://elysiajs.com/patterns/trace.md

**Contents:**
- Trace
- Children
- Trace Parameter
  - id - `number`
  - context - `Context`
  - set - `Context.set`
  - store - `Singleton.store`
  - time - `number`
  - on\[Event] - `TraceListener`
- Trace Listener

---
url: 'https://elysiajs.com/patterns/trace.md'
---

Performance is an important aspect for Elysia.

We don't want to be fast for benchmarking purposes, we want you to have a real fast server in real-world scenario.

There are many factors that can slow down our app - and it's hard to identify them, but **trace** can help solve that problem by injecting start and stop code to each life-cycle.

Trace allows us to inject code to before and after of each life-cycle event, block and interact with the execution of the function.

::: warning
trace doesn't work with dynamic mode `aot: false`, as it requires the function to be static and known at compile time otherwise it will have a large performance impact.
:::

Trace use a callback listener to ensure that callback function is finished before moving on to the next lifecycle event.

To use `trace`, you need to call `trace` method on the Elysia instance, and pass a callback function that will be executed for each life-cycle event.

You may listen to each lifecycle by adding `on` prefix followed by the lifecycle name, for example `onHandle` to listen to the `handle` event.

Please refer to [Life Cycle Events](/essential/life-cycle#events) for more information:

![Elysia Life Cycle](/assets/lifecycle-chart.svg)

Every event except `handle` has children, which is an array of events that are executed inside for each lifecycle event.

You can use `onEvent` to listen to each child event in order

In this example, total children will be `2` because there are 2 children in the `beforeHandle` event.

Then we listen to each child event by using `onEvent` and print the duration of each child event.

When each lifecycle is called

`trace` accept the following parameters:

Randomly generated unique id for each request

Elysia's [Context](/essential/handler.html#context), eg. `set`, `store`, `query`, `params`

Shortcut for `context.set`, to set a headers or status of the context

Shortcut for `context.store`, to access a data in the context

Timestamp of when request is called

An event listener for each life-cycle event.

You may listen to the following life-cycle:

* **onRequest** - get notified of every new request
* **onParse** - array of functions to parse the body
* **onTransform** - transform request and context before validation
* **onBeforeHandle** - custom requirement to check before the main handler, can skip the main handler if response returned.
* **onHandle** - function assigned to the path
* **onAfterHandle** - interact with the response before sending it back to the client
* **onMapResponse** - map returned value into a Web Standard Response
* **onError** - handle error thrown during processing request
* **onAfterResponse** - cleanup function after response is sent

A listener for each life-cycle event

Each lifecycle listener accept the following

The name of the function, if the function is anonymous, the name will be `anonymous`

The time when the function is started

The time when the function is ended, will be resolved when the function is ended

Error that was thrown in the lifecycle, will be resolved when the function is ended

A callback that will be executed when the lifecycle is ended

It's recommended to mutate context in this function as there's a lock mechanism to ensure the context is mutate successfully before moving on to the next lifecycle event

A parameter that passed to `onStop` callback

The time when the function is ended

Error that was thrown in the lifecycle

Elapsed time of the lifecycle or `end - begin`

**Examples:**

Example 1 (unknown):
```unknown
Please refer to [Life Cycle Events](/essential/life-cycle#events) for more information:

![Elysia Life Cycle](/assets/lifecycle-chart.svg)

## Children

Every event except `handle` has children, which is an array of events that are executed inside for each lifecycle event.

You can use `onEvent` to listen to each child event in order
```

Example 2 (unknown):
```unknown
In this example, total children will be `2` because there are 2 children in the `beforeHandle` event.

Then we listen to each child event by using `onEvent` and print the duration of each child event.

## Trace Parameter

When each lifecycle is called
```

Example 3 (unknown):
```unknown
`trace` accept the following parameters:

### id - `number`

Randomly generated unique id for each request

### context - `Context`

Elysia's [Context](/essential/handler.html#context), eg. `set`, `store`, `query`, `params`

### set - `Context.set`

Shortcut for `context.set`, to set a headers or status of the context

### store - `Singleton.store`

Shortcut for `context.store`, to access a data in the context

### time - `number`

Timestamp of when request is called

### on\[Event] - `TraceListener`

An event listener for each life-cycle event.

You may listen to the following life-cycle:

* **onRequest** - get notified of every new request
* **onParse** - array of functions to parse the body
* **onTransform** - transform request and context before validation
* **onBeforeHandle** - custom requirement to check before the main handler, can skip the main handler if response returned.
* **onHandle** - function assigned to the path
* **onAfterHandle** - interact with the response before sending it back to the client
* **onMapResponse** - map returned value into a Web Standard Response
* **onError** - handle error thrown during processing request
* **onAfterResponse** - cleanup function after response is sent

## Trace Listener

A listener for each life-cycle event
```

Example 4 (unknown):
```unknown
Each lifecycle listener accept the following

### name - `string`

The name of the function, if the function is anonymous, the name will be `anonymous`

### begin - `number`

The time when the function is started

### end - `Promise<number>`

The time when the function is ended, will be resolved when the function is ended

### error - `Promise<Error | null>`

Error that was thrown in the lifecycle, will be resolved when the function is ended

### onStop - `callback?: (detail: TraceEndDetail) => any`

A callback that will be executed when the lifecycle is ended
```

---

## Cookie&#x20;

**URL:** https://elysiajs.com/patterns/cookie.md

**Contents:**
- Reactivity
- Cookie Attribute
  - Assign Property
- set
- add
- remove
- Cookie Schema
- Nullable Cookie
- Cookie Signature
- Using Cookie Signature

---
url: 'https://elysiajs.com/patterns/cookie.md'
---

Elysia provides a mutable signal for interacting with Cookie.

There's no get/set, you can extract the cookie name and retrieve or update its value directly.

By default, Reactive Cookie can encode/decode object types automatically allowing us to treat cookies as objects without worrying about the encoding/decoding. **It just works**.

The Elysia cookie is reactive. This means that when you change the cookie value, the cookie will be updated automatically based on an approach like signals.

A single source of truth for handling cookies is provided by Elysia cookies, which have the ability to automatically set headers and sync cookie values.

Since cookies are Proxy-dependent objects by default, the extract value can never be **undefined**; instead, it will always be a value of `Cookie<unknown>`, which can be obtained by invoking the **.value** property.

We can treat the cookie jar as a regular object, iteration over it will only iterate over an already-existing cookie value.

To use Cookie attribute, you can either use one of the following:

1. Setting the property directly
2. Using `set` or `add` to update cookie property.

See [cookie attribute config](/patterns/cookie.html#config) for more information.

You can get/set the property of a cookie like any normal object, the reactivity model synchronizes the cookie value automatically.

**set** permits updating multiple cookie properties all at once through **reset all property** and overwrite the property with a new value.

Like **set**, **add** allow us to update multiple cookie properties at once, but instead, will only overwrite the property defined instead of resetting.

To remove a cookie, you can use either:

1. name.remove
2. delete cookie.name

You can strictly validate cookie type and providing type inference for cookie by using cookie schema with `t.Cookie`.

To handle nullable cookie value, you can use `t.Optional` on the cookie name you want to be nullable.

With an introduction of Cookie Schema, and `t.Cookie` type, we can create a unified type for handling sign/verify cookie signature automatically.

Cookie signature is a cryptographic hash appended to a cookie's value, generated using a secret key and the content of the cookie to enhance security by adding a signature to the cookie.

This make sure that the cookie value is not modified by malicious actor, helps in verifying the authenticity and integrity of the cookie data.

By provide a cookie secret, and `sign` property to indicate which cookie should have a signature verification.

Elysia then sign and unsign cookie value automatically.

You can use Elysia constructor to set global cookie `secret`, and `sign` value to apply to all route globally instead of inlining to every route you need.

Elysia handle Cookie's secret rotation automatically.

Cookie Rotation is a migration technique to sign a cookie with a newer secret, while also be able to verify the old signature of the cookie.

Below is a cookie config accepted by Elysia.

The secret key for signing/un-signing cookies.

If an array is passed, will use Key Rotation.

Key rotation is when an encryption key is retired and replaced by generating a new cryptographic key.

Below is a config that extends from [cookie](https://npmjs.com/package/cookie)

Specifies the value for the [Domain Set-Cookie attribute](https://tools.ietf.org/html/rfc6265#section-5.2.3).

By default, no domain is set, and most clients will consider the cookie to apply to only the current domain.

@default `encodeURIComponent`

Specifies a function that will be used to encode a cookie's value.

Since the value of a cookie has a limited character set (and must be a simple string), this function can be used to encode a value into a string suited for a cookie's value.

The default function is the global `encodeURIComponent`, which will encode a JavaScript string into UTF-8 byte sequences and then URL-encode any that fall outside of the cookie range.

Specifies the Date object to be the value for the [Expires Set-Cookie attribute](https://tools.ietf.org/html/rfc6265#section-5.2.1).

By default, no expiration is set, and most clients will consider this a "non-persistent cookie" and will delete it on a condition like exiting a web browser application.

::: tip
The [cookie storage model specification](https://tools.ietf.org/html/rfc6265#section-5.3) states that if both `expires` and `maxAge` are set, then `maxAge` takes precedence, but not all clients may obey this, so if both are set, they should point to the same date and time.
:::

Specifies the boolean value for the [HttpOnly Set-Cookie attribute](https://tools.ietf.org/html/rfc6265#section-5.2.6).

When truthy, the HttpOnly attribute is set, otherwise, it is not.

By default, the HttpOnly attribute is not set.

::: tip
be careful when setting this to true, as compliant clients will not allow client-side JavaScript to see the cookie in `document.cookie`.
:::

Specifies the number (in seconds) to be the value for the [Max-Age Set-Cookie attribute](https://tools.ietf.org/html/rfc6265#section-5.2.2).

The given number will be converted to an integer by rounding down. By default, no maximum age is set.

::: tip
The [cookie storage model specification](https://tools.ietf.org/html/rfc6265#section-5.3) states that if both `expires` and `maxAge` are set, then `maxAge` takes precedence, but not all clients may obey this, so if both are set, they should point to the same date and time.
:::

Specifies the value for the [Path Set-Cookie attribute](https://tools.ietf.org/html/rfc6265#section-5.2.4).

By default, the path handler is considered the default path.

Specifies the string to be the value for the [Priority Set-Cookie attribute](https://tools.ietf.org/html/draft-west-cookie-priority-00#section-4.1).
`low` will set the Priority attribute to Low.
`medium` will set the Priority attribute to Medium, the default priority when not set.
`high` will set the Priority attribute to High.

More information about the different priority levels can be found in [the specification](https://tools.ietf.org/html/draft-west-cookie-priority-00#section-4.1).

::: tip
This is an attribute that has not yet been fully standardized and may change in the future. This also means many clients may ignore this attribute until they understand it.
:::

Specifies the boolean or string to be the value for the [SameSite Set-Cookie attribute](https://tools.ietf.org/html/draft-ietf-httpbis-rfc6265bis-09#section-5.4.7).
`true` will set the SameSite attribute to Strict for strict same-site enforcement.
`false` will not set the SameSite attribute.
`'lax'` will set the SameSite attribute to Lax for lax same-site enforcement.
`'none'` will set the SameSite attribute to None for an explicit cross-site cookie.
`'strict'` will set the SameSite attribute to Strict for strict same-site enforcement.
More information about the different enforcement levels can be found in [the specification](https://tools.ietf.org/html/draft-ietf-httpbis-rfc6265bis-09#section-5.4.7).

::: tip
This is an attribute that has not yet been fully standardized and may change in the future. This also means many clients may ignore this attribute until they understand it.
:::

Specifies the boolean value for the [Secure Set-Cookie attribute](https://tools.ietf.org/html/rfc6265#section-5.2.5). When truthy, the Secure attribute is set, otherwise, it is not. By default, the Secure attribute is not set.

::: tip
Be careful when setting this to true, as compliant clients will not send the cookie back to the server in the future if the browser does not have an HTTPS connection.
:::

**Examples:**

Example 1 (ts):
```ts
import { Elysia } from 'elysia'

new Elysia()
    .get('/', ({ cookie: { name } }) => {
        // Get
        name.value

        // Set
        name.value = "New Value"
    })
```

Example 2 (ts):
```ts
import { Elysia } from 'elysia'

new Elysia()
    .get('/', ({ cookie: { name } }) => {
        // get
        name.domain

        // set
        name.domain = 'millennium.sh'
        name.httpOnly = true
    })
```

Example 3 (ts):
```ts
import { Elysia } from 'elysia'

new Elysia()
    .get('/', ({ cookie: { name } }) => {
        name.set({
            domain: 'millennium.sh',
            httpOnly: true
        })
    })
```

Example 4 (ts):
```ts
import { Elysia } from 'elysia'

new Elysia()
    .get('/', ({ cookie, cookie: { name } }) => {
        name.remove()

        delete cookie.name
    })
```

---

## Deploy to production

**URL:** https://elysiajs.com/patterns/deploy.md

**Contents:**
- Cluster mode
- Compile to binary
  - Target
  - Why not --minify
  - Permission
  - Unknown random Chinese error
- Compile to JavaScript
- Docker
  - OpenTelemetry
  - Monorepo

---
url: 'https://elysiajs.com/patterns/deploy.md'
---

This page is a guide on how to deploy Elysia to production.

Elysia is a single-threaded by default. To take advantage of multi-core CPU, we can run Elysia in cluster mode.

Let's create a **index.ts** file that import our main server from **server.ts** and fork multiple workers based on the number of CPU cores available.

This will make sure that Elysia is running on multiple CPU cores.

::: tip
Elysia on Bun use SO\_REUSEPORT by default, which allows multiple instances to listen on the same port. This only works on Linux.
:::

We recommend running a build command before deploying to production as it could potentially reduce memory usage and file size significantly.

We recommend compiling Elysia into a single binary using the command as follows:

This will generate a portable binary `server` which we can run to start our server.

Compiling server to binary usually significantly reduces memory usage by 2-3x compared to development environment.

This command is a bit long, so let's break it down:

1. **--compile** Compile TypeScript to binary
2. **--minify-whitespace** Remove unnecessary whitespace
3. **--minify-syntax** Minify JavaScript syntax to reduce file size
4. **--target bun** Optimize the binary for Bun runtime
5. **--outfile server** Output the binary as `server`
6. **src/index.ts** The entry file of our server (codebase)

To start our server, simply run the binary.

Once binary is compiled, you don't need `Bun` installed on the machine to run the server.

This is great as the deployment server doesn't need to install an extra runtime to run making binary portable.

You can also add a `--target` flag to optimize the binary for the target platform.

Here's a list of available targets:
| Target                  | Operating System | Architecture | Modern | Baseline | Libc  |
|--------------------------|------------------|--------------|--------|----------|-------|
| bun-linux-x64           | Linux            | x64          | ✅      | ✅        | glibc |
| bun-linux-arm64         | Linux            | arm64        | ✅      | N/A      | glibc |
| bun-windows-x64         | Windows          | x64          | ✅      | ✅        | -     |
| bun-windows-arm64       | Windows          | arm64        | ❌      | ❌        | -     |
| bun-darwin-x64          | macOS            | x64          | ✅      | ✅        | -     |
| bun-darwin-arm64        | macOS            | arm64        | ✅      | N/A      | -     |
| bun-linux-x64-musl      | Linux            | x64          | ✅      | ✅        | musl  |
| bun-linux-arm64-musl    | Linux            | arm64        | ✅      | N/A      | musl  |

Bun does have `--minify` flag that will minify the binary.

However if we are using [OpenTelemetry](/plugins/opentelemetry), it's going to reduce a function name to a single character.

This makes tracing harder than it should as OpenTelemetry relies on a function name.

However, if you're not using OpenTelemetry, you may opt in for `--minify` instead

Some Linux distros might not be able to run the binary, we suggest enabling executable permission to a binary if you're on Linux:

If you're trying to deploy a binary to your server but unable to run with random chinese character error.

It means that the machine you're running on **doesn't support AVX2**.

Unfortunately, Bun requires a machine that has `AVX2` hardware support.

There's no workaround as far as we know.

If you are unable to compile to binary or you are deploying on a Windows server.

You may bundle your server to a JavaScript file instead.

This will generate a single portable JavaScript file that you can deploy on your server.

On Docker, we recommended to always compile to binary to reduce base image overhead.

Here's an example image using Distroless image using binary.

If you are using [OpenTelemetry](/patterns/opentelemetry) to deploys production server.

As OpenTelemetry rely on monkey-patching `node_modules/<library>`. It's required that make instrumentations works properly, we need to specify that libraries to be instrument is an external module to exclude it from being bundled.

For example, if you are using `@opentelemetry/instrumentation-pg` to instrument `pg` library. We need to exclude `pg` from being bundled and make sure that it is importing `node_modules/pg`.

To make this works, we may specified `pg` as an external module with `--external pg`

This tells bun to not `pg` bundled into the final output file, and will be imported from the `node_modules` directory at runtime. So on a production server, you must also keeps the `node_modules` directory.

It's recommended to specify packages that should be available in a production server as `dependencies` in `package.json` and use `bun install --production` to install only production dependencies.

Then after running a build command, on a production server

If the node\_modules directory still includes development dependencies, you may remove the node\_modules directory and reinstall production dependencies again.

If you are using Elysia with Monorepo, you may need to include dependent `packages`.

If you are using Turborepo, you may place a Dockerfile inside an your apps directory like **apps/server/Dockerfile**. This may apply to other monorepo manager such as Lerna, etc.

Assume that our monorepo are using Turborepo with structure as follows:

* apps
  * server
    * **Dockerfile (place a Dockerfile here)**
* packages
  * config

Then we can build our Dockerfile on monorepo root (not app root):

With Dockerfile as follows:

[Railway](https://railway.app) is one of the popular deployment platform.

Railway assigns a **random port** to expose for each deployment, which can be accessed via the `PORT` environment variable.

We need to modify our Elysia server to accept the `PORT` environment variable to comply with Railway port.

Instead of a fixed port, we may use `process.env.PORT` and provide a fallback on development instead.

This should allows Elysia to intercept port provided by Railway.

::: tip
Elysia assign hostname to `0.0.0.0` automatically, which works with Railway
:::

**Examples:**

Example 1 (unknown):
```unknown
:::

This will make sure that Elysia is running on multiple CPU cores.

::: tip
Elysia on Bun use SO\_REUSEPORT by default, which allows multiple instances to listen on the same port. This only works on Linux.
:::

## Compile to binary

We recommend running a build command before deploying to production as it could potentially reduce memory usage and file size significantly.

We recommend compiling Elysia into a single binary using the command as follows:
```

Example 2 (unknown):
```unknown
This will generate a portable binary `server` which we can run to start our server.

Compiling server to binary usually significantly reduces memory usage by 2-3x compared to development environment.

This command is a bit long, so let's break it down:

1. **--compile** Compile TypeScript to binary
2. **--minify-whitespace** Remove unnecessary whitespace
3. **--minify-syntax** Minify JavaScript syntax to reduce file size
4. **--target bun** Optimize the binary for Bun runtime
5. **--outfile server** Output the binary as `server`
6. **src/index.ts** The entry file of our server (codebase)

To start our server, simply run the binary.
```

Example 3 (unknown):
```unknown
Once binary is compiled, you don't need `Bun` installed on the machine to run the server.

This is great as the deployment server doesn't need to install an extra runtime to run making binary portable.

### Target

You can also add a `--target` flag to optimize the binary for the target platform.
```

Example 4 (unknown):
```unknown
Here's a list of available targets:
| Target                  | Operating System | Architecture | Modern | Baseline | Libc  |
|--------------------------|------------------|--------------|--------|----------|-------|
| bun-linux-x64           | Linux            | x64          | ✅      | ✅        | glibc |
| bun-linux-arm64         | Linux            | arm64        | ✅      | N/A      | glibc |
| bun-windows-x64         | Windows          | x64          | ✅      | ✅        | -     |
| bun-windows-arm64       | Windows          | arm64        | ❌      | ❌        | -     |
| bun-darwin-x64          | macOS            | x64          | ✅      | ✅        | -     |
| bun-darwin-arm64        | macOS            | arm64        | ✅      | N/A      | -     |
| bun-linux-x64-musl      | Linux            | x64          | ✅      | ✅        | musl  |
| bun-linux-arm64-musl    | Linux            | arm64        | ✅      | N/A      | musl  |

### Why not --minify

Bun does have `--minify` flag that will minify the binary.

However if we are using [OpenTelemetry](/plugins/opentelemetry), it's going to reduce a function name to a single character.

This makes tracing harder than it should as OpenTelemetry relies on a function name.

However, if you're not using OpenTelemetry, you may opt in for `--minify` instead
```

---

## WebSocket

**URL:** https://elysiajs.com/patterns/websocket.md

**Contents:**
- WebSocket message validation:
- Configuration
  - perMessageDeflate
  - maxPayloadLength
  - idleTimeout
  - backpressureLimit
  - closeOnBackpressureLimit
- Methods
- ws
- WebSocketHandler

---
url: 'https://elysiajs.com/patterns/websocket.md'
---

WebSocket is a realtime protocol for communication between your client and server.

Unlike HTTP where our client repeatedly asks the website for information and waits for a reply each time, WebSocket sets up a direct line where our client and server can send messages back and forth directly, making the conversation quicker and smoother without having to start over with each message.

SocketIO is a popular library for WebSocket, but it is not the only one. Elysia uses [uWebSocket](https://github.com/uNetworking/uWebSockets) which Bun uses under the hood with the same API.

To use WebSocket, simply call `Elysia.ws()`:

Same as normal routes, WebSockets also accept a **schema** object to strictly type and validate requests.

WebSocket schema can validate the following:

* **message** - An incoming message.
* **query** - Query string or URL parameters.
* **params** - Path parameters.
* **header** - Request's headers.
* **cookie** - Request's cookie
* **response** - Value returned from handler

By default Elysia will parse incoming stringified JSON message as Object for validation.

You can set Elysia constructor to set the Web Socket value.

Elysia's WebSocket implementation extends Bun's WebSocket configuration, please refer to [Bun's WebSocket documentation](https://bun.sh/docs/api/websockets) for more information.

The following are a brief configuration from [Bun WebSocket](https://bun.sh/docs/api/websockets#create-a-websocket-server)

Enable compression for clients that support it.

By default, compression is disabled.

The maximum size of a message.

After a connection has not received a message for this many seconds, it will be closed.

@default `16777216` (16MB)

The maximum number of bytes that can be buffered for a single connection.

Close the connection if the backpressure limit is reached.

Below are the new methods that are available to the WebSocket route

Create a websocket handler

* **endpoint** - A path to exposed as websocket handler
* **options** - Customize WebSocket handler behavior

WebSocketHandler extends config from [config](#configuration).

Below is a config which is accepted by `ws`.

Callback function for new websocket connection.

Callback function for incoming websocket message.

`Message` type based on `schema.message`. Default is `string`.

Callback function for closing websocket connection.

Callback function for the server is ready to accept more data.

`Parse` middleware to parse the request before upgrading the HTTP connection to WebSocket.

`Before Handle` middleware which execute before upgrading the HTTP connection to WebSocket.

Ideal place for validation.

`Transform` middleware which execute before validation.

Like `transform`, but execute before validation of WebSocket message

Additional headers to add before upgrade connection to WebSocket.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
    .ws('/ws', {
        message(ws, message) {
            ws.send(message)
        }
    })
    .listen(3000)
```

Example 2 (typescript):
```typescript
import { Elysia, t } from 'elysia'

const app = new Elysia()
    .ws('/ws', {
        // validate incoming message
        body: t.Object({
            message: t.String()
        }),
        query: t.Object({
            id: t.String()
        }),
        message(ws, { message }) {
            // Get schema from `ws.data`
            const { id } = ws.data.query
            ws.send({
                id,
                message,
                time: Date.now()
            })
        }
    })
    .listen(3000)
```

Example 3 (ts):
```ts
import { Elysia } from 'elysia'

new Elysia({
    websocket: {
        idleTimeout: 30
    }
})
```

Example 4 (typescript):
```typescript
import { Elysia } from 'elysia'

const app = new Elysia()
    .ws('/ws', {
        message(ws, message) {
            ws.send(message)
        }
    })
    .listen(3000)
```

---

## TypeBox (Elysia.t)

**URL:** https://elysiajs.com/patterns/typebox.md

**Contents:**
- Primitive Type
  - Basic Type
  - Attribute
- Honorable Mentions
  - Union
  - Optional
  - Partial
- Elysia Type
  - UnionEnum
  - File

---
url: 'https://elysiajs.com/patterns/typebox.md'
---

Here's a common patterns for writing validation types using `Elysia.t`.

The TypeBox API is designed around and is similar to TypeScript types.

There are many familiar names and behaviors that intersect with TypeScript counterparts, such as **String**, **Number**, **Boolean**, and **Object**, as well as more advanced features like **Intersect**, **KeyOf**, and **Tuple** for versatility.

If you are familiar with TypeScript, creating a TypeBox schema behaves the same as writing a TypeScript type, except it provides actual type validation at runtime.

To create your first schema, import **Elysia.t** from Elysia and start with the most basic type:

This code tells Elysia to validate an incoming HTTP body, ensuring that the body is a string. If it is a string, it will be allowed to flow through the request pipeline and handler.

If the shape doesn't match, it will throw an error into the [Error Life Cycle](/essential/life-cycle.html#on-error).

![Elysia Life Cycle](/assets/lifecycle-chart.svg)

TypeBox provides basic primitive types with the same behavior as TypeScript types.

The following table lists the most common basic types:

Elysia extends all types from TypeBox, allowing you to reference most of the API from TypeBox for use in Elysia.

See [TypeBox's Type](https://github.com/sinclairzx81/typebox#json-types) for additional types supported by TypeBox.

TypeBox can accept arguments for more comprehensive behavior based on the JSON Schema 7 specification.

See [JSON Schema 7 specification](https://json-schema.org/draft/2020-12/json-schema-validation) for more explanation of each attribute.

The following are common patterns often found useful when creating a schema.

Allows a field in `t.Object` to have multiple types.

Allows a field in `t.Object` to be undefined or optional.

Allows all fields in `t.Object` to be optional.

`Elysia.t` is based on TypeBox with pre-configuration for server usage, providing additional types commonly found in server-side validation.

You can find all the source code for Elysia types in `elysia/type-system`.

The following are types provided by Elysia:

`UnionEnum` allows the value to be one of the specified values.

A singular file, often useful for **file upload** validation.

File extends the attributes of the base schema, with additional properties as follows:

Specifies the format of the file, such as image, video, or audio.

If an array is provided, it will attempt to validate if any of the formats are valid.

Minimum size of the file.

Accepts a number in bytes or a suffix of file units:

Maximum size of the file.

Accepts a number in bytes or a suffix of file units:

The following are the specifications of the file unit:
m: MegaByte (1048576 byte)
k: KiloByte (1024 byte)

Extends from [File](#file), but adds support for an array of files in a single field.

Files extends the attributes of the base schema, array, and File.

Object-like representation of a Cookie Jar extended from the Object type.

Cookie extends the attributes of [Object](https://json-schema.org/draft/2020-12/json-schema-validation#name-validation-keywords-for-obj) and [Cookie](https://github.com/jshttp/cookie#options-1) with additional properties as follows:

The secret key for signing cookies.

Accepts a string or an array of strings.

If an array is provided, [Key Rotation](https://crypto.stackexchange.com/questions/41796/whats-the-purpose-of-key-rotation) will be used. The newly signed value will use the first secret as the key.

Allows the value to be null but not undefined.

Allows the value to be null and undefined.

For additional information, you can find the full source code of the type system in [`elysia/type-system`](https://github.com/elysiajs/elysia/blob/main/src/type-system/index.ts).

A syntax sugar our `t.Object` with support for verifying return value of [form](/essential/handler.html#formdata) (FormData).

Accepts a buffer that can be parsed into a `Uint8Array`.

This is useful when you want to accept a buffer that can be parsed into a `Uint8Array`, such as in a binary file upload. It's designed to use for the validation of body with `arrayBuffer` parser to enforce the body type.

Accepts a buffer that can be parsed into a `ArrayBuffer`.

This is useful when you want to accept a buffer that can be parsed into a `Uint8Array`, such as in a binary file upload. It's designed to use for the validation of body with `arrayBuffer` parser to enforce the body type.

Accepts a string that can be parsed into an object.

This is useful when you want to accept a string that can be parsed into an object but the environment does not allow it explicitly, such as in a query string, header, or FormData body.

Accepts a string that can be parsed into a boolean.

Similar to [ObjectString](#objectstring), this is useful when you want to accept a string that can be parsed into a boolean but the environment does not allow it explicitly.

Numeric accepts a numeric string or number and then transforms the value into a number.

This is useful when an incoming value is a numeric string, for example, a path parameter or query string.

Numeric accepts the same attributes as [Numeric Instance](https://json-schema.org/draft/2020-12/json-schema-validation#name-validation-keywords-for-num).

Elysia use TypeBox by default.

However, to help making handling with HTTP easier. Elysia has some dedicated type and have some behavior difference from TypeBox.

To make a field optional, use `t.Optional`.

This will allows client to optionally provide a query parameter. This behavior also applied to `body`, `headers`.

This is different from TypeBox where optional is to mark a field of object as optional.

By default, Elysia will convert a `t.Number` to [t.Numeric](#numeric) when provided as route schema.

Because parsed HTTP headers, query, url parameter is always a string. This means that even if a value is number, it will be treated as string.

Elysia override this behavior by checking if a string value looks like a number then convert it even appropriate.

This is only applied when it is used as a route schema and not in a nested `t.Object`.

Similar to [Number to Numeric](#number-to-numeric)

Any `t.Boolean` will be converted to `t.BooleanString`.

**Examples:**

Example 1 (unknown):
```unknown
This code tells Elysia to validate an incoming HTTP body, ensuring that the body is a string. If it is a string, it will be allowed to flow through the request pipeline and handler.

If the shape doesn't match, it will throw an error into the [Error Life Cycle](/essential/life-cycle.html#on-error).

![Elysia Life Cycle](/assets/lifecycle-chart.svg)

### Basic Type

TypeBox provides basic primitive types with the same behavior as TypeScript types.

The following table lists the most common basic types:
```

Example 2 (unknown):
```unknown
Elysia extends all types from TypeBox, allowing you to reference most of the API from TypeBox for use in Elysia.

See [TypeBox's Type](https://github.com/sinclairzx81/typebox#json-types) for additional types supported by TypeBox.

### Attribute

TypeBox can accept arguments for more comprehensive behavior based on the JSON Schema 7 specification.
```

Example 3 (unknown):
```unknown
See [JSON Schema 7 specification](https://json-schema.org/draft/2020-12/json-schema-validation) for more explanation of each attribute.

## Honorable Mentions

The following are common patterns often found useful when creating a schema.

### Union

Allows a field in `t.Object` to have multiple types.
```

Example 4 (unknown):
```unknown
### Optional

Allows a field in `t.Object` to be undefined or optional.
```

---

## Validation Error

**URL:** https://elysiajs.com/tutorial/patterns/validation-error.md

**Contents:**
- Validation Detail
- Assignment

---
url: 'https://elysiajs.com/tutorial/patterns/validation-error.md'
---

If you use `Elysia.t` for validation, you can provide a custom error message based on the field that fails the validation.

Elysia will override the default error message with the custom one you provide, see Custom Validation Message.

By default Elysia also provide a Validation Detail to explain what's wrong with the validation as follows:

However, when you provide a custom error message, it will completely override Validation Detail

To bring back the validation detail, you can wrap your custom error message in a Validation Detail function.

Let's try to extends Elysia's context.

We can provide a custom error message by providing `error` property to the schema.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia, t } from 'elysia'

new Elysia()
	.post(
		'/',
		({ body }) => body,
		{
			body: t.Object({
				age: t.Number({
					error: 'Age must be a number' // [!code ++]
				})
			}, {
				error: 'Body must be an object' // [!code ++]
			})
		}
	)
	.listen(3000)
```

Example 2 (json):
```json
{
	"type": "validation",
	"on": "params",
	"value": { "id": "string" },
	"property": "/id",
	"message": "id must be a number", // [!code ++]
	"summary": "Property 'id' should be one of: 'numeric', 'number'",
	"found": { "id": "string" },
	"expected": { "id": 0 },
	"errors": [
		{
			"type": 62,
			"schema": {
				"anyOf": [
					{ "format": "numeric", "default": 0, "type": "string" },
					{ "type": "number" }
				]
			},
			"path": "/id",
			"value": "string",
			"message": "Expected union value",
			"errors": [{ "iterator": {} }, { "iterator": {} }],
			"summary": "Property 'id' should be one of: 'numeric', 'number'"
		}
	]
}
```

Example 3 (typescript):
```typescript
import { Elysia, t, validationDetail } from 'elysia' // [!code ++]

new Elysia()
	.post(
		'/',
		({ body }) => body,
		{
			body: t.Object({
				age: t.Number({
					error: validationDetail('Age must be a number') // [!code ++]
				})
			}, {
				error: validationDetail('Body must be an object') // [!code ++]
			})
		}
	)
	.listen(3000)
```

Example 4 (typescript):
```typescript
import { Elysia, t } from 'elysia'

new Elysia()
	.post(
		'/',
		({ body }) => body,
		{
			body: t.Object({
				age: t.Number({
                    error: 'thing' // [!code ++]
                })
			})
		}
	)
	.listen(3000)
```

---

## OpenTelemetry

**URL:** https://elysiajs.com/patterns/opentelemetry.md

**Contents:**
  - Export OpenTelemetry data
- OpenTelemetry SDK
- Record utility
  - Prepare your codebase for observability
- getCurrentSpan
- setAttributes
- Configuration
- Instrumentations Advanced Concept
  - Deploying to production Advanced Concept

---
url: 'https://elysiajs.com/patterns/opentelemetry.md'
---

To start using OpenTelemetry, install `@elysiajs/opentelemetry` and apply plugin to any instance.

![OpenTelemetry visualize via Axiom](/assets/axiom.webp)

Why use OpenTelemetry with Elysia?

* 1 line config
* Span name is the function name
* Grouping relevant lifecycle together
* Wrap a code to record a specific part
* Support Server-Sent Event, and response streaming
* Compatible with any OpenTelemetry compatible library

You may export telemetry data to Jaeger, Zipkin, New Relic, Axiom or any other OpenTelemetry compatible backend.

We can export OpenTelemetry data to any backend that supports OpenTelemetry protocol.

Here's an example of exporting telemetry to [Axiom](https://axiom.co)

Elysia OpenTelemetry is for applying OpenTelemetry to Elysia server only.

You may use OpenTelemetry SDK normally, and the span is run under Elysia's request span, it will be automatically appear in Elysia trace.

However, we also provide a `getTracer`, and `record` utility to collect span from any part of your application.

`record` is an equivalent to OpenTelemetry's `startActiveSpan` but it will handle auto-closing and capture exception automatically.

You may think of `record` as a label for your code that will be shown in trace.

Elysia OpenTelemetry will group lifecycle and read the **function name** of each hook as the name of the span.

It's a good time to **name your function**.

If your hook handler is an arrow function, you may refactor it to named function to understand the trace better, otherwise your trace span will be named as `anonymous`.

`getCurrentSpan` is a utility to get the current span of the current request when you are outside of the handler.

This works outside of the handler by retriving current span from `AsyncLocalStorage`

`setAttributes` is a utility to set attributes to the current span.

This is a syntax sugar for `getCurrentSpan().setAttributes`

See [opentelemetry plugin](/plugins/opentelemetry) for configuration option and definition.

Many instrumentation libraries required that the SDK **MUST** run before importing the module.

For example, to use `PgInstrumentation`, the `OpenTelemetry SDK` must run before importing the `pg` module.

To achieve this in Bun, we can

1. Separate an OpenTelemetry setup into a different file
2. create `bunfig.toml` to preload the OpenTelemetry setup file

Let's create a new file in `src/instrumentation.ts`

Then we can apply this `instrumentaiton` plugin into our main instance in `src/index.ts`

Then create a `bunfig.toml` with the following:

This will tell Bun to load and setup `instrumentation` before running the `src/index.ts` allowing OpenTelemetry to do its setup as needed.

If you are using `bun build` or other bundlers.

As OpenTelemetry rely on monkey-patching `node_modules/<library>`. It's required that make instrumentations works properly, we need to specify that libraries to be instrument is an external module to exclude it from being bundled.

For example, if you are using `@opentelemetry/instrumentation-pg` to instrument `pg` library. We need to exclude `pg` from being bundled and make sure that it is importing `node_modules/pg`.

To make this works, we may specified `pg` as an external module with `--external pg`

This tells bun to not `pg` bundled into the final output file, and will be imported from the **node\_modules** directory at runtime. So on a production server, you must also keeps the **node\_modules** directory.

It's recommended to specify packages that should be available in a production server as **dependencies** in **package.json** and use `bun install --production` to install only production dependencies.

Then after running a build command, on a production server

If the node\_modules directory still includes development dependencies, you may remove the node\_modules directory and reinstall production dependencies again.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'
import { opentelemetry } from '@elysiajs/opentelemetry'

new Elysia()
	.use(opentelemetry())
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'
import { opentelemetry } from '@elysiajs/opentelemetry'

import { BatchSpanProcessor } from '@opentelemetry/sdk-trace-node'
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-proto'

new Elysia().use(
	opentelemetry({
		spanProcessors: [
			new BatchSpanProcessor(
				new OTLPTraceExporter({
					url: 'https://api.axiom.co/v1/traces', // [!code ++]
					headers: {
						// [!code ++]
						Authorization: `Bearer ${Bun.env.AXIOM_TOKEN}`, // [!code ++]
						'X-Axiom-Dataset': Bun.env.AXIOM_DATASET // [!code ++]
					} // [!code ++]
				})
			)
		]
	})
)
```

Example 3 (typescript):
```typescript
import { Elysia } from 'elysia'
import { record } from '@elysiajs/opentelemetry'

export const plugin = new Elysia().get('', () => {
	return record('database.query', () => {
		return db.query('SELECT * FROM users')
	})
})
```

Example 4 (typescript):
```typescript
const bad = new Elysia()
	// ⚠️ span name will be anonymous
	.derive(async ({ cookie: { session } }) => {
		return {
			user: await getProfile(session)
		}
	})

const good = new Elysia()
	// ✅ span name will be getProfile
	.derive(async function getProfile({ cookie: { session } }) {
		return {
			user: await getProfile(session)
		}
	})
```

---

## Extends context&#x20;

**URL:** https://elysiajs.com/patterns/extends-context.md

**Contents:**
  - When to extend context
- State
  - When to use
  - Key takeaway
  - Reference and value Gotcha
- Decorate
  - When to use
  - Key takeaway
- Derive
        - ⚠️ Derive doesn't handle type integrity, you might want to use [resolve](#resolve) instead.

---
url: 'https://elysiajs.com/patterns/extends-context.md'
---

Elysia provides a minimal Context by default, allowing us to extend Context for our specific need using state, decorate, derive, and resolve.

Elysia allows us to extend Context for various use cases like:

* extracting user ID as variable
* inject a common pattern repository
* add a database connection

We may extend Elysia's context by using the following APIs to customize the Context:

* [state](#state) - a global mutable state
* [decorate](#decorate) - additional property assigned to **Context**
* [derive](#derive) / [resolve](#resolve) - create a new value from existing property

You should only extend context when:

* A property is a global mutable state, and shared across multiple routes using [state](#state)
* A property is associated with a request or response using [decorate](#decorate)
* A property is derived from an existing property using [derive](#derive) / [resolve](#resolve)

Otherwise, we recommend defining a value or function separately than extending the context.

::: tip
It's recommended to assign properties related to request and response, or frequently used functions to Context for separation of concerns.
:::

**State** is a global mutable object or state shared across the Elysia app.

Once **state** is called, value will be added to **store** property **once at call time**, and can be used in handler.

* When you need to share a primitive mutable value across multiple routes
* If you want to use a non-primitive or a `wrapper` value or class that mutate an internal state, use [decorate](#decorate) instead.

* **store** is a representation of a single-source-of-truth global mutable object for the entire Elysia app.
* **state** is a function to assign an initial value to **store**, which could be mutated later.
* Make sure to assign a value before using it in a handler.

::: tip
Beware that we cannot use a state value before assign.

Elysia registers state values into the store automatically without explicit type or additional TypeScript generic needed.
:::

To mutate the state, it's recommended to use **reference** to mutate rather than using an actual value.

When accessing the property from JavaScript, if we define a primitive value from an object property as a new value, the reference is lost, the value is treated as new separate value instead.

We can use **store.counter** to access and mutate the property.

However, if we define a counter as a new value

Once a primitive value is redefined as a new variable, the reference **"link"** will be missing, causing unexpected behavior.

This can apply to `store`, as it's a global mutable object instead.

**decorate** assigns an additional property to **Context** directly **at call time**.

* A constant or readonly value object to **Context**
* Non primitive value or class that may contain internal mutable state
* Additional functions, singleton, or immutable property to all handlers.

* Unlike **state**, decorated value **SHOULD NOT** be mutated although it's possible
* Make sure to assign a value before using it in a handler.

Retrieve values from existing properties in **Context** and assign new properties.

Derive assigns when request happens **at transform lifecycle** allowing us to "derive" (create new properties from existing properties).

Because **derive** is assigned once a new request starts, **derive** can access request properties like **headers**, **query**, **body** where **store**, and **decorate** can't.

* Create a new property from existing properties in **Context** without validation or type checking
* When you need to access request properties like **headers**, **query**, **body** without validation

* Unlike **state** and **decorate** instead of assign **at call time**, **derive** is assigned once a new request starts.
* **derive is called at transform, or before validation** happens, Elysia cannot safely confirm the type of request property resulting in as **unknown**. If you want to assign a new value from typed request properties, you may want to use [resolve](#resolve) instead.

Similar as [derive](#derive) but ensure type integrity.

Resolve allow us to assign a new property to context.

Resolve is called at **beforeHandle** lifecycle or **after validation**, allowing us to **resolve** request properties safely.

* Create a new property from existing properties in **Context** with type integrity (type checked)
* When you need to access request properties like **headers**, **query**, **body** with validation

* **resolve is called at beforeHandle, or after validation** happens. Elysia can safely confirm the type of request property resulting in as **typed**.

As resolve and derive is based on **transform** and **beforeHandle** lifecycle, we can return an error from resolve and derive. If error is returned from **derive**, Elysia will return early exit and return the error as response.

**state**, **decorate** offers a similar APIs pattern for assigning property to Context as the following:

* key-value
* object
* remap

Where **derive** can be only used with **remap** because it depends on existing value.

We can use **state**, and **decorate** to assign a value using a key-value pattern.

This pattern is great for readability for setting a single property.

Assigning multiple properties is better contained in an object for a single assignment.

The object offers a less repetitive API for setting multiple values.

Remap is a function reassignment.

Allowing us to create a new value from existing value like renaming or removing a property.

By providing a function, and returning an entirely new object to reassign the value.

It's a good idea to use state remap to create a new initial value from the existing value.

However, it's important to note that Elysia doesn't offer reactivity from this approach, as remap only assigns an initial value.

::: tip
Using remap, Elysia will treat a returned object as a new property, removing any property that is missing from the object.
:::

To provide a smoother experience, some plugins might have a lot of property value which can be overwhelming to remap one-by-one.

The **Affix** function which consists of **prefix** and **suffix**, allowing us to remap all property of an instance.

Allowing us to bulk remap a property of the plugin effortlessly, preventing the name collision of the plugin.

By default, **affix** will handle both runtime, type-level code automatically, remapping the property to camelCase as naming convention.

In some condition, we can also remap `all` property of the plugin:

**Examples:**

Example 1 (unknown):
```unknown
### When to use

* When you need to share a primitive mutable value across multiple routes
* If you want to use a non-primitive or a `wrapper` value or class that mutate an internal state, use [decorate](#decorate) instead.

### Key takeaway

* **store** is a representation of a single-source-of-truth global mutable object for the entire Elysia app.
* **state** is a function to assign an initial value to **store**, which could be mutated later.
* Make sure to assign a value before using it in a handler.
```

Example 2 (unknown):
```unknown
::: tip
Beware that we cannot use a state value before assign.

Elysia registers state values into the store automatically without explicit type or additional TypeScript generic needed.
:::

### Reference and value Gotcha

To mutate the state, it's recommended to use **reference** to mutate rather than using an actual value.

When accessing the property from JavaScript, if we define a primitive value from an object property as a new value, the reference is lost, the value is treated as new separate value instead.

For example:
```

Example 3 (unknown):
```unknown
We can use **store.counter** to access and mutate the property.

However, if we define a counter as a new value
```

Example 4 (unknown):
```unknown
Once a primitive value is redefined as a new variable, the reference **"link"** will be missing, causing unexpected behavior.

This can apply to `store`, as it's a global mutable object instead.
```

---

## Standalone Schema

**URL:** https://elysiajs.com/tutorial/patterns/standalone-schema.md

**Contents:**
- Schema Library Interoperability
- Assignment

---
url: 'https://elysiajs.com/tutorial/patterns/standalone-schema.md'
---

When we define a schema using Guard, the schema will be added to a route. But it will be **override** if the route provide a schema:

If we want a schema to **co-exist** with route schema, we can define it as **standalone schema**:

Schema between standalone schema can be from a different validation library.

For example you can define a standalone schema using **zod**, and a local schema using **Elysia.t**, and both will works interchangeably.

Let's make both `age` and `name` property required in the request body by using standalone schema.

We can define a standalone schema by adding `schema: 'standalone'` in the guard options.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia, t } from 'elysia'

new Elysia()
	.guard({
		body: t.Object({
			age: t.Number()
		})
	})
	.post(
		'/user',
		({ body }) => body,
		{
			// This will override the guard schema
			body: t.Object({
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
		schema: 'standalone', // [!code ++]
		body: t.Object({
			age: t.Number()
		})
	})
	.post(
		'/user',
		// body will have both age and name property
		({ body }) => body,
		{
			body: t.Object({
				name: t.String()
			})
		}
	)
	.listen(3000)
```

Example 3 (typescript):
```typescript
import { Elysia, t } from 'elysia'
import { z } from 'zod'

new Elysia()
	.guard({
		schema: 'standalone', // [!code ++]
		body: z.object({
			age: z.number()
		})
	})
	.post(
		'/user',
		({ body }) => body,
		{
			body: t.Object({
				name: t.String()
			})
		}
	)
	.listen(3000)
```

---

## Error Handling

**URL:** https://elysiajs.com/tutorial/patterns/error-handling.md

**Contents:**
- Custom Error
  - Error Status Code
  - Error Response
- Assignment

---
url: 'https://elysiajs.com/tutorial/patterns/error-handling.md'
---

onError is called when an **error is thrown**.

It accept **context** similar to handler but include an additional:

* error - a thrown error
* code - error code

You can return a status to override the default error status.

You can provide a custom error with error code as follows:

Elysia use error code to narrow down type of error.

It's recommended to register a custom error as Elysia can narrow down the type.

You can also provide a custom status code by adding a **status** property to class:

Elysia will use this status code if the error is thrown, see Custom Status Code.

You can also define a custom error response directly into the error by providing a `toResponse` method:

Elysia will use this response if the error is thrown, see Custom Error Response.

Let's try to extends Elysia's context.

1. You can narrow down error by "NOT\_FOUND" to override 404 response.
2. Provide your error to `.error()` method with status property of 418.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.onError(({ code, status }) => {
		if(code === "NOT_FOUND")
			return 'uhe~ are you lost?'

		return status(418, "My bad! But I\'m cute so you'll forgive me, right?")
	})
	.get('/', () => 'ok')
	.listen(3000)
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'

class NicheError extends Error {
	constructor(message: string) {
		super(message)
	}
}

new Elysia()
	.error({ // [!code ++]
		'NICHE': NicheError // [!code ++]
	}) // [!code ++]
	.onError(({ error, code, status }) => {
		if(code === 'NICHE') {
			// Typed as NicheError
			console.log(error)

			return status(418, "We have no idea how you got here")
		}
	})
	.get('/', () => {
        throw new NicheError('Custom error message')
	})
	.listen(3000)
```

Example 3 (typescript):
```typescript
import { Elysia } from 'elysia'

class NicheError extends Error {
	status = 418 // [!code ++]

	constructor(message: string) {
		super(message)
	}
}
```

Example 4 (typescript):
```typescript
import { Elysia } from 'elysia'

class NicheError extends Error {
	status = 418

	constructor(message: string) {
		super(message)
	}

	toResponse() { // [!code ++]
		return { message: this.message } // [!code ++]
	} // [!code ++]
}
```

---

## Macro&#x20;

**URL:** https://elysiajs.com/patterns/macro.md

**Contents:**
- Property shorthand
- Error handling
- Resolve
  - Macro extension with resolve
- Schema
  - Schema with lifecycle in the same macro
- Extension
- Deduplication

---
url: 'https://elysiajs.com/patterns/macro.md'
---

Macro is similar to a function that have a control over the lifecycle event, schema, context with full type safety.

Once defined, it will be available in hook and can be activated by adding the property.

Accessing the path should log **"Elysia"** as the results.

Starting from Elysia 1.2.10, each property in the macro object can be a function or an object.

If the property is an object, it will be translated to a function that accept a boolean parameter, and will be executed if the parameter is true.

You can return an error HTTP status by returning a `status`.

It's recommended that you should `return status` instead of `throw new Error()` to annotate correct HTTP status code.

If you throw an error instead, Elysia will convert it to `500 Internal Server Error` by default.

It's also recommend to use `return status` instead of `throw status` to ensure type inference for both [Eden](/eden/overview) and [OpenAPI Type Gen](/patterns/openapi#openapi-from-types).

You add a property to the context by returning an object with a [**resolve**](/essential/life-cycle.html#resolve) function.

In the example above, we add a new property **user** to the context by returning an object with a **resolve** function.

Here's an example that macro resolve could be useful:

* perform authentication and add user to the context
* run an additional database query and add data to the context
* add a new property to the context

Due to TypeScript limitation, macro that extends other macro cannot infer type into **resolve** function.

We provide a named single macro as a workaround to this limitation.

You can define a custom schema for your macro, to make sure that the route using the macro is passing the correct type.

Macro with schema will automatically validate and infer type to ensure type safety, and it can co-exist with existing schema as well.

You can also stack multiple schema from different macro, or even from Standard Validator and it will work together seamlessly.

Similar to [Macro extension with resolve](#macro-extension-with-resolve),

Macro schema also support type inference for **lifecycle within the same macro** **BUT** only with named single macro due to TypeScript limitation.

If you want to use lifecycle type inference within the same macro, you might want to use a named single macro instead of multiple stacked macro

> Not to confused with using macro schema to infer type into route's lifecycle event. That works just fine this limitation only apply to using lifecycle within the same macro.

Macro can extends other macro, allowing you to build upon existing one.

This allow you to build upon existing macro, and add more functionality to it.

Macro will automatically deduplicate the lifecycle event, ensuring that each lifecycle event is only executed once.

By default, Elysia will use the property value as the seed, but you can override it by providing a custom seed.

However, if you evert accidentally create a circular dependency, Elysia have a limit stack of 16 to prevent infinite loop in both runtime and type inference.

If the route already has OpenAPI detail, it will merge the detail together but prefers the route detail over macro detail.

**Examples:**

Example 1 (unknown):
```unknown
Accessing the path should log **"Elysia"** as the results.

## Property shorthand

Starting from Elysia 1.2.10, each property in the macro object can be a function or an object.

If the property is an object, it will be translated to a function that accept a boolean parameter, and will be executed if the parameter is true.
```

Example 2 (unknown):
```unknown
## Error handling

You can return an error HTTP status by returning a `status`.
```

Example 3 (unknown):
```unknown
It's recommended that you should `return status` instead of `throw new Error()` to annotate correct HTTP status code.

If you throw an error instead, Elysia will convert it to `500 Internal Server Error` by default.

It's also recommend to use `return status` instead of `throw status` to ensure type inference for both [Eden](/eden/overview) and [OpenAPI Type Gen](/patterns/openapi#openapi-from-types).

## Resolve

You add a property to the context by returning an object with a [**resolve**](/essential/life-cycle.html#resolve) function.
```

Example 4 (unknown):
```unknown
In the example above, we add a new property **user** to the context by returning an object with a **resolve** function.

Here's an example that macro resolve could be useful:

* perform authentication and add user to the context
* run an additional database query and add data to the context
* add a new property to the context

### Macro extension with resolve

Due to TypeScript limitation, macro that extends other macro cannot infer type into **resolve** function.

We provide a named single macro as a workaround to this limitation.
```

---

## Config

**URL:** https://elysiajs.com/patterns/configuration.md

**Contents:**
- adapter
        - Since 1.1.11
- allowUnsafeValidationDetails
        - Since 1.4.13
    - Options - @default `false`
- aot
        - Since 0.4.0
    - Options - @default `false`
- detail
- encodeSchema

---
url: 'https://elysiajs.com/patterns/configuration.md'
---

Elysia comes with a configurable behavior, allowing us to customize various aspects of its functionality.

We can define a configuration by using a constructor.

Runtime adapter for using Elysia in different environments.

Default to appropriate adapter based on the environment.

Whether Elysia should include unsafe validation details in the error response on production.

By default, Elysia will omitted all validation detail on production.

This is done to prevent leaking sensitive information about the validation schema, such as field names and expected types, which could be exploited by an attacker.

Ideally, this should only be enabled on a public APIs as it may leak sensitive information about the server implementation.

* `true` - Include unsafe validation details in the error response on production
* `false` - Exclude unsafe validation details in the error response on production

Ahead of Time compilation.

Elysia has a built-in JIT *"compiler"* that can [optimize performance](/blog/elysia-04.html#ahead-of-time-complie).

Disable Ahead of Time compilation

* `true` - Precompile every route before starting the server

* `false` - Disable JIT entirely. Faster startup time without cost of performance

Define an OpenAPI schema for all routes of an instance.

This schema will be used to generate OpenAPI documentation for all routes of an instance.

Handle custom `t.Transform` schema with custom `Encode` before returning the response to client.

This allows us to create custom encode function for your data before sending response to the client.

* `true` - Run `Encode` before sending the response to client
* `false` - Skip `Encode` entirely

Define a name of an instance which is used for debugging and [Plugin Deduplication](/essential/plugin.html#plugin-deduplication)

Use an optimized function for handling inline value for each respective runtime.

If enabled on Bun, Elysia will insert inline value into `Bun.serve.static` improving performance for static value.

Whether Elysia should coerce field into a specified schema.

When unknown properties that are not specified in schema are found on either input and output, how should Elysia handle the field?

Options - @default `true`

* `true`: Elysia will coerce fields into a specified schema using [exact mirror](/blog/elysia-13.html#exact-mirror)

* `typebox`: Elysia will coerce fields into a specified schema using [TypeBox's Value.Clean](https://github.com/sinclairzx81/typebox)

* `false`: Elysia will raise an error if a request or response contains fields that are not explicitly allowed in the schema of the respective handler.

Whether Elysia should [precompile all routes](/blog/elysia-10.html#improved-startup-time) ahead of time before starting the server.

Options - @default `false`

* `true`: Run JIT on all routes before starting the server

* `false`: Dynamically compile routes on demand

It's recommended to leave it as `false`.

Define a prefix for all routes of an instance

When prefix is defined, all routes will be prefixed with the given value.

A function or an array of function that calls and intercepts on every `t.String` while validation.

Allowing us to read and transform a string into a new value.

Define a value which will be used to generate checksum of an instance, used for [Plugin Deduplication](/essential/plugin.html#plugin-deduplication)

The value could be any type not limited to string, number, or object.

Whether should Elysia handle path strictly.

According to [RFC 3986](https://tools.ietf.org/html/rfc3986#section-3.3), a path should be strictly equal to the path defined in the route.

* `true` - Follows [RFC 3986](https://tools.ietf.org/html/rfc3986#section-3.3) for path matching strictly
* `false` - Tolerate suffix '/' or vice-versa.

Customize HTTP server behavior.

Bun serve configuration.

This configuration extends [Bun Serve API](https://bun.sh/docs/api/http) and [Bun TLS](https://bun.sh/docs/api/http#tls)

We can set the maximum body size by setting [`serve.maxRequestBodySize`](#serve-maxrequestbodysize) in the `serve` configuration.

By default the maximum request body size is 128MB (1024 \* 1024 \* 128).
Define body size limit.

We can enable TLS (known as successor of SSL) by passing in a value for key and cert; both are required to enable TLS.

We can increase the idle timeout by setting [`serve.idleTimeout`](#serve-idletimeout) in the `serve` configuration.

By default the idle timeout is 10 seconds (on Bun).

HTTP server configuration.

Elysia extends Bun configuration which supports TLS out of the box, powered by BoringSSL.

See [serve.tls](#serve-tls) for available configuration.

Set the hostname which the server listens on

Uniquely identify a server instance with an ID

This string will be used to hot reload the server without interrupting pending requests or websockets. If not provided, a value will be generated. To disable hot reloading, set this value to `null`.

@default `10` (10 seconds)

By default, Bun set idle timeout to 10 seconds, which means that if a request is not completed within 10 seconds, it will be aborted.

@default `1024 * 1024 * 128` (128MB)

Set the maximum size of a request body (in bytes)

@default `NODE_TLS_REJECT_UNAUTHORIZED` environment variable

If set to `false`, any certificate is accepted.

If the `SO_REUSEPORT` flag should be set

This allows multiple processes to bind to the same port, which is useful for load balancing

This configuration is override and turns on by default by Elysia

If set, the HTTP server will listen on a unix socket instead of a port.

(Cannot be used with hostname+port)

We can enable TLS (known as successor of SSL) by passing in a value for key and cert; both are required to enable TLS.

Elysia extends Bun configuration which supports TLS out of the box, powered by BoringSSL.

Optionally override the trusted CA certificates. Default is to trust the well-known CAs curated by Mozilla.

Mozilla's CAs are completely replaced when CAs are explicitly specified using this option.

Cert chains in PEM format. One cert chain should be provided per private key.

Each cert chain should consist of the PEM formatted certificate for a provided private key, followed by the PEM formatted intermediate certificates (if any), in order, and not
including the root CA (the root CA must be pre-known to the peer, see ca).

When providing multiple cert chains, they do not have to be in the same order as their private keys in key.

If the intermediate certificates are not provided, the peer will not be
able to validate the certificate, and the handshake will fail.

File path to a .pem file custom Diffie Helman parameters

Private keys in PEM format. PEM allows the option of private keys being encrypted. Encrypted keys will be decrypted with options.passphrase.

Multiple keys using different algorithms can be provided either as an array of unencrypted key strings or buffers, or an array of objects in the form .

The object form can only occur in an array.

**object.passphrase** is optional. Encrypted keys will be decrypted with

**object.passphrase** if provided, or **options.passphrase** if it is not.

This sets `OPENSSL_RELEASE_BUFFERS` to 1.

It reduces overall performance but saves some memory.

Shared passphrase for a single private key and/or a PFX.

If set to `true`, the server will request a client certificate.

Optionally affect the OpenSSL protocol behavior, which is not usually necessary.

This should be used carefully if at all!

Value is a numeric bitmask of the SSL\_OP\_\* options from OpenSSL Options

Explicitly set a server name

Define an tags for OpenAPI schema for all routes of an instance similar to [detail](#detail)

Use runtime/framework provided router if possible.

On Bun, Elysia will use [Bun.serve.routes](https://bun.sh/docs/api/http#routing) and fallback to Elysia's own router.

Override websocket configuration

Recommended to leave this as default as Elysia will generate suitable configuration for handling WebSocket automatically

This configuration extends [Bun's WebSocket API](https://bun.sh/docs/api/websockets)

**Examples:**

Example 1 (unknown):
```unknown
## adapter

###### Since 1.1.11

Runtime adapter for using Elysia in different environments.

Default to appropriate adapter based on the environment.
```

Example 2 (unknown):
```unknown
## allowUnsafeValidationDetails

###### Since 1.4.13

Whether Elysia should include unsafe validation details in the error response on production.
```

Example 3 (unknown):
```unknown
By default, Elysia will omitted all validation detail on production.

This is done to prevent leaking sensitive information about the validation schema, such as field names and expected types, which could be exploited by an attacker.

Ideally, this should only be enabled on a public APIs as it may leak sensitive information about the server implementation.

#### Options - @default `false`

* `true` - Include unsafe validation details in the error response on production
* `false` - Exclude unsafe validation details in the error response on production

## aot

###### Since 0.4.0

Ahead of Time compilation.

Elysia has a built-in JIT *"compiler"* that can [optimize performance](/blog/elysia-04.html#ahead-of-time-complie).
```

Example 4 (unknown):
```unknown
Disable Ahead of Time compilation

#### Options - @default `false`

* `true` - Precompile every route before starting the server

* `false` - Disable JIT entirely. Faster startup time without cost of performance

## detail

Define an OpenAPI schema for all routes of an instance.

This schema will be used to generate OpenAPI documentation for all routes of an instance.
```

---
