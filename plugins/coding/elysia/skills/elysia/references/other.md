# Elysia - Other

**Pages:** 10

---

## Key Concept&#x20;

**URL:** https://elysiajs.com/key-concept.md

**Contents:**
- Encapsulation&#x20;
- Method Chaining&#x20;
  - Without method chaining
- Dependency&#x20;
  - Deduplication&#x20;
  - Global vs Explicit Dependency
- Order of code&#x20;
- Type Inference
  - TypeScript

---
url: 'https://elysiajs.com/key-concept.md'
---

Elysia has a every important concepts that you need to understand to use.

This page covers most concepts that you should know before getting started.

Elysia lifecycle methods are **encapsulated** to its own instance only.

Which means if you create a new instance, it will not share the lifecycle methods with others.

In this example, the `isSignIn` check will only apply to `profile` but not `app`.

> Try changing the path in the URL bar to **/rename** and see the result

**Elysia isolate lifecycle by default** unless explicitly stated. This is similar to **export** in JavaScript, where you need to export the function to make it available outside the module.

To **"export"** the lifecycle to other instances, you must add specify the scope.

Casting lifecycle to **"global"** will export lifecycle to **every instance**.

Learn more about this in [scope](/essential/plugin.html#scope-level).

Elysia code should **ALWAYS** use method chaining.

This is **important to ensure type safety**.

In the code above, **state** returns a new **ElysiaInstance** type, adding a typed `build` property.

As Elysia type system is complex, every method in Elysia returns a new type reference.

Without using method chaining, Elysia doesn't save these new types, leading to no type inference.

We recommend to **always use method chaining** to provide an accurate type inference.

Elysia by design, is compose of multiple mini Elysia apps which can run **independently** like a microservice that communicate with each other.

Each Elysia instance is independent and **can run as a standalone server**.

When an instance need to use another instance's service, you **must explicitly declare the dependency**.

This is similar to **Dependency Injection** where each instance must declare its dependencies.

This approach force you to be explicit about dependencies allowing better tracking, modularity.

By default, each plugin will be re-executed **every time** applying to another instance.

To prevent this, Elysia can deduplicate lifecycle with **an unique identifier** using `name` and optional `seed` property.

Adding the `name` and optional `seed` to the instance will make it a unique identifier prevent it from being called multiple times.

Learn more about this in [plugin deduplication](/essential/plugin.html#plugin-deduplication).

There are some case that global dependency make more sense than an explicit one.

**Global** plugin example:

* **Plugin that doesn't add types** - eg. cors, compress, helmet
* Plugin that add global lifecycle that no instance should have control over - eg. tracing, logging

* OpenAPI/Open - Global document
* OpenTelemetry - Global tracer
* Logging - Global logger

In case like this, it make more sense to create it as global dependency instead of applying it to every instance.

However, if your dependency doesn't fit into these categories, it's recommended to use **explicit dependency** instead.

**Explicit dependency** example:

* **Plugin that add types** - eg. macro, state, model
* Plugin that add business logic that instance can interact with - eg. Auth, Database

* State management - eg. Store, Session
* Data modeling - eg. ORM, ODM
* Business logic - eg. Auth, Database
* Feature module - eg. Chat, Notification

The order of Elysia's life-cycle code is very important.

Because event will only apply to routes **after** it is registered.

If you put the onError before plugin, plugin will not inherit the onError event.

Console should log the following:

Notice that it doesn't log **2**, because the event is registered after the route so it is not applied to the route.

Learn more about this in [order of code](/essential/life-cycle.html#order-of-code).

Elysia has a complex type system that allows you to infer types from the instance.

You should **always use an inline function** to provide an accurate type inference.

If you need to apply a separate function, eg. MVC's controller pattern, it's recommended to destructure properties from inline function to prevent unnecessary type inference as follows:

See [Best practice: MVC Controller](/essential/best-practice.html#controller).

We can get a type definitions of every Elysia/TypeBox's type by accessing `static` property as follows:

This allows Elysia to infer and provide type automatically, reducing the need to declare duplicate schema

A single Elysia/TypeBox schema can be used for:

* Runtime validation
* Data coercion
* TypeScript type
* OpenAPI schema

This allows us to make a schema as a **single source of truth**.

**Examples:**

Example 1 (ts):
```ts
import { Elysia } from 'elysia'

const profile = new Elysia()
	.onBeforeHandle(({ cookie }) => {
		throwIfNotSignIn(cookie)
	})
	.get('/profile', () => 'Hi there!')

const app = new Elysia()
	.use(profile)
	// ⚠️ This will NOT have sign in check
	.patch('/rename', ({ body }) => updateProfile(body))
```

Example 2 (ts):
```ts
import { Elysia } from 'elysia'

const profile = new Elysia()
	.onBeforeHandle(
		{ as: 'global' }, // [!code ++]
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

Example 3 (unknown):
```unknown
In the code above, **state** returns a new **ElysiaInstance** type, adding a typed `build` property.

### Without method chaining

As Elysia type system is complex, every method in Elysia returns a new type reference.

Without using method chaining, Elysia doesn't save these new types, leading to no type inference.
```

Example 4 (unknown):
```unknown
We recommend to **always use method chaining** to provide an accurate type inference.

## Dependency&#x20;

Elysia by design, is compose of multiple mini Elysia apps which can run **independently** like a microservice that communicate with each other.

Each Elysia instance is independent and **can run as a standalone server**.

When an instance need to use another instance's service, you **must explicitly declare the dependency**.
```

---

## 

**URL:** https://elysiajs.com/playground/preview.md

---
url: 'https://elysiajs.com/playground/preview.md'
---

---

## At a glance

**URL:** https://elysiajs.com/at-glance.md

**Contents:**
- Performance
- TypeScript
- Type Integrity
- Standard Schema
- OpenAPI
- OpenAPI from types
- End-to-end Type Safety
- Type Soundness
- Platform Agnostic
- Our Community

---
url: 'https://elysiajs.com/at-glance.md'
---

Elysia is an ergonomic web framework for building backend servers with Bun.

Designed with simplicity and type-safety in mind, Elysia offers a familiar API with extensive support for TypeScript and is optimized for Bun.

Here's a simple hello world in Elysia.

Navigate to [localhost:3000](http://localhost:3000/) and you should see 'Hello Elysia' as the result.

::: tip
Hover over the code snippet to see the type definition.

In the mock browser, click on the path highlighted in blue to change paths and preview the response.

Elysia can run in the browser, and the results you see are actually executed using Elysia.
:::

Building on Bun and extensive optimization like static code analysis allows Elysia to generate optimized code on the fly.

Elysia can outperform most web frameworks available today\[1], and even match the performance of Golang and Rust frameworks\[2].

| Framework     | Runtime | Average     | Plain Text | Dynamic Parameters | JSON Body  |
| ------------- | ------- | ----------- | ---------- | ------------------ | ---------- |
| bun           | bun     | 262,660.433 | 326,375.76 | 237,083.18         | 224,522.36 |
| elysia        | bun     | 255,574.717 | 313,073.64 | 241,891.57         | 211,758.94 |
| hyper-express | node    | 234,395.837 | 311,775.43 | 249,675            | 141,737.08 |
| hono          | bun     | 203,937.883 | 239,229.82 | 201,663.43         | 170,920.4  |
| h3            | node    | 96,515.027  | 114,971.87 | 87,935.94          | 86,637.27  |
| oak           | deno    | 46,569.853  | 55,174.24  | 48,260.36          | 36,274.96  |
| fastify       | bun     | 65,897.043  | 92,856.71  | 81,604.66          | 23,229.76  |
| fastify       | node    | 60,322.413  | 71,150.57  | 62,060.26          | 47,756.41  |
| koa           | node    | 39,594.14   | 46,219.64  | 40,961.72          | 31,601.06  |
| express       | bun     | 29,715.537  | 39,455.46  | 34,700.85          | 14,990.3   |
| express       | node    | 15,913.153  | 17,736.92  | 17,128.7           | 12,873.84  |

Elysia is designed to help you write less TypeScript.

Elysia's Type System is fine-tuned to infer types from your code automatically, without needing to write explicit TypeScript, while providing type-safety at both runtime and compile time for the most ergonomic developer experience.

Take a look at this example:

The above code creates a path parameter **"id"**. The value that replaces `:id` will be passed to `params.id` both at runtime and in types, without manual type declaration.

Elysia's goal is to help you write less TypeScript and focus more on business logic. Let the framework handle the complex types.

TypeScript is not required to use Elysia, but it's recommended.

To take it a step further, Elysia provides **Elysia.t**, a schema builder to validate types and values at both runtime and compile time, creating a single source of truth for your data types.

Let's modify the previous code to accept only a number value instead of a string.

This code ensures that our path parameter **id** will always be a number at both runtime and compile time (type-level).

::: tip
Hover over "id" in the above code snippet to see a type definition.
:::

With Elysia's schema builder, we can ensure type safety like a strongly typed language with a single source of truth.

Elysia supports [Standard Schema](https://github.com/standard-schema/standard-schema), allowing you to use your favorite validation library:

* Zod
* Valibot
* ArkType
* Effect Schema
* Yup
* Joi
* [and more](https://github.com/standard-schema/standard-schema)

Elysia will infer the types from the schema automatically, allowing you to use your favorite validation library while still maintaining type safety.

Elysia adopts many standards by default, like OpenAPI, WinterTC compliance, and Standard Schema. Allowing you to integrate with most of the industry standard tools or at least easily integrate with tools you are familiar with.

For instance, because Elysia adopts OpenAPI by default, generating API documentation is as easy as adding a one-liner:

With the OpenAPI plugin, you can seamlessly generate an API documentation page without additional code or specific configuration and share it with your team effortlessly.

Elysia also supports OpenAPI schema generation with **1 line directly from types**.

This is a **unique feature** of Elysia, allowing you to have complete and accurate API documentation directly from your code without any manual annotation.

This is equivalent to **FastAPI**'s automatic OpenAPI generation from types but in TypeScript.

With Elysia, type safety is not limited to server-side.

With Elysia, you can synchronize your types with your frontend team automatically, similar to tRPC, using Elysia's client library, "Eden".

And on your client-side:

With Eden, you can use the existing Elysia types to query an Elysia server **without code generation** and synchronize types for both frontend and backend automatically.

Elysia is not only about helping you create a confident backend but for all that is beautiful in this world.

Most frameworks with end-to-end type safety usually assume only a happy part, leaving error handling and edge cases out of the type system.

However, Elysia can infers all of the possible outcomes of your API, from lifecycle events/macro from any part of your codebase.

This is one of the **unfair advantages** that Elysia has from years of investment in type system.

Elysia is optimized for Bun with native feature but **not limited to Bun**.

Being [WinterTC compliant](https://wintertc.org/) allows you to deploy Elysia servers on:

* Bun
* [Node.js](/integrations/node)
* [Deno](/integrations/deno)
* [Cloudflare Worker](/integrations/cloudflare-worker)
* [Vercel](/integrations/vercel)
* [Expo](/integrations/expo) via API routes
* [Nextjs](/integrations/nextjs) via API routes
* [Astro](/integrations/astro) via API routes

and several more! Checkout `integration` section on sidebar for more support runtime.

We want to create a friendly and welcoming community for everyone with cute and playful design including our anime mascot, Elysia chan.

We believe that technology can be cute and fun instead of being serious all the time, to brings joy to people's lives.

But even that, we take Elysia very seriously to make sure it's reliable and production ready high-performance framework that can be trusted for your next project.

Elysia is **used in production by many companies and projects worldwide**, including [X](https://x.com/shlomiatar/status/1822381556142362734), [Bank for Agriculture and Agricultural Co-operatives](https://github.com/elysiajs/elysia/discussions/1312#discussioncomment-13924470), [Cluely](https://github.com/elysiajs/elysia/discussions/1312#discussioncomment-14420139), [CS.Money](https://github.com/elysiajs/elysia/discussions/1312#discussioncomment-13913513), [Abacate Pay](https://github.com/elysiajs/elysia/discussions/1312#discussioncomment-13922081) and used by [over 10,000 (open source) projects on GitHub.](https://github.com/elysiajs/elysia/network/dependents) and has been actively developed and maintained since 2022 with many regular contributors from our community.

Elysia is a reliable choice and production ready for building your next backend server.

Here's on of our community resources to get you started:

1\. Measured in requests/second. The benchmark for parsing query, path parameter and set response header on Debian 11, Intel i7-13700K tested on Bun 0.7.2 on 6 Aug 2023. See the benchmark condition [here](https://github.com/SaltyAom/bun-http-framework-benchmark/tree/c7e26fe3f1bfee7ffbd721dbade10ad72a0a14ab#results).

2\. Based on [TechEmpower Benchmark round 22](https://www.techempower.com/benchmarks/#section=data-r22\&hw=ph\&test=composite).

**Examples:**

Example 1 (unknown):
```unknown
Navigate to [localhost:3000](http://localhost:3000/) and you should see 'Hello Elysia' as the result.

::: tip
Hover over the code snippet to see the type definition.

In the mock browser, click on the path highlighted in blue to change paths and preview the response.

Elysia can run in the browser, and the results you see are actually executed using Elysia.
:::

## Performance

Building on Bun and extensive optimization like static code analysis allows Elysia to generate optimized code on the fly.

Elysia can outperform most web frameworks available today\[1], and even match the performance of Golang and Rust frameworks\[2].

| Framework     | Runtime | Average     | Plain Text | Dynamic Parameters | JSON Body  |
| ------------- | ------- | ----------- | ---------- | ------------------ | ---------- |
| bun           | bun     | 262,660.433 | 326,375.76 | 237,083.18         | 224,522.36 |
| elysia        | bun     | 255,574.717 | 313,073.64 | 241,891.57         | 211,758.94 |
| hyper-express | node    | 234,395.837 | 311,775.43 | 249,675            | 141,737.08 |
| hono          | bun     | 203,937.883 | 239,229.82 | 201,663.43         | 170,920.4  |
| h3            | node    | 96,515.027  | 114,971.87 | 87,935.94          | 86,637.27  |
| oak           | deno    | 46,569.853  | 55,174.24  | 48,260.36          | 36,274.96  |
| fastify       | bun     | 65,897.043  | 92,856.71  | 81,604.66          | 23,229.76  |
| fastify       | node    | 60,322.413  | 71,150.57  | 62,060.26          | 47,756.41  |
| koa           | node    | 39,594.14   | 46,219.64  | 40,961.72          | 31,601.06  |
| express       | bun     | 29,715.537  | 39,455.46  | 34,700.85          | 14,990.3   |
| express       | node    | 15,913.153  | 17,736.92  | 17,128.7           | 12,873.84  |

## TypeScript

Elysia is designed to help you write less TypeScript.

Elysia's Type System is fine-tuned to infer types from your code automatically, without needing to write explicit TypeScript, while providing type-safety at both runtime and compile time for the most ergonomic developer experience.

Take a look at this example:
```

Example 2 (unknown):
```unknown
The above code creates a path parameter **"id"**. The value that replaces `:id` will be passed to `params.id` both at runtime and in types, without manual type declaration.

Elysia's goal is to help you write less TypeScript and focus more on business logic. Let the framework handle the complex types.

TypeScript is not required to use Elysia, but it's recommended.

## Type Integrity

To take it a step further, Elysia provides **Elysia.t**, a schema builder to validate types and values at both runtime and compile time, creating a single source of truth for your data types.

Let's modify the previous code to accept only a number value instead of a string.
```

Example 3 (unknown):
```unknown
This code ensures that our path parameter **id** will always be a number at both runtime and compile time (type-level).

::: tip
Hover over "id" in the above code snippet to see a type definition.
:::

With Elysia's schema builder, we can ensure type safety like a strongly typed language with a single source of truth.

## Standard Schema

Elysia supports [Standard Schema](https://github.com/standard-schema/standard-schema), allowing you to use your favorite validation library:

* Zod
* Valibot
* ArkType
* Effect Schema
* Yup
* Joi
* [and more](https://github.com/standard-schema/standard-schema)
```

Example 4 (unknown):
```unknown
Elysia will infer the types from the schema automatically, allowing you to use your favorite validation library while still maintaining type safety.

## OpenAPI

Elysia adopts many standards by default, like OpenAPI, WinterTC compliance, and Standard Schema. Allowing you to integrate with most of the industry standard tools or at least easily integrate with tools you are familiar with.

For instance, because Elysia adopts OpenAPI by default, generating API documentation is as easy as adding a one-liner:
```

---

## From Fastify to Elysia

**URL:** https://elysiajs.com/migrate/from-fastify.md

**Contents:**
- Performance
- Routing
- Handler
- Subrouter
- Validation
- File upload
- Lifecycle Event
  - Elysia Lifecycle
  - Fastify Lifecycle
- Sounds type safety

---
url: 'https://elysiajs.com/migrate/from-fastify.md'
---

This guide is for Fastify users who want to see a differences from Fastify including syntax, and how to migrate your application from Fastify to Elysia by example.

**Fastify** is a fast and low overhead web framework for Node.js, designed to be simple and easy to use. It is built on top of the HTTP module and provides a set of features that make it easy to build web applications.

**Elysia** is an ergonomic web framework for Bun, Node.js, and runtime that supports Web Standard API. Designed to be ergonomic and developer-friendly with a focus on **sound type safety** and performance.

Elysia has significant performance improvements over Fastify thanks to native Bun implementation, and static code analysis.

Fastify and Elysia has similar routing syntax, using `app.get()` and `app.post()` methods to define routes and similar path parameters syntax.

> Fastify use `request` and `reply` as request and response objects

> Elysia use a single `context` and returns the response directly

There is a slight different in style guide, Elysia recommends usage of method chaining and object destructuring.

Elysia also supports an inline value for the response if you don't need to use the context.

Both has a simliar property for accessing input parameters like `headers`, `query`, `params`, and `body`, and automatically parse the request body to JSON, URL-encoded data, and formdata.

> Fastify parse data and put it into `request` object

> Elysia parse data and put it into `context` object

Fastify use a function callback to define a subrouter while Elysia treats every instances as a component that can be plug and play together.

> Fastify use a function callback to declare a sub router

> Elysia treat every instances as a component

While Elysia set the prefix in the constructor, Fastify requires you to set the prefix in the options.

Elysia has a built-in support for request validation with sounds type safety out of the box using **TypeBox** while Fastify use JSON Schema for declaring schema, and **ajv** for validation.

However, doesn't infer type automatically, and you need to use a type provider like `@fastify/type-provider-json-schema-to-ts` to infer type.

> Fastify use JSON Schema for validation

> Elysia use TypeBox for validation, and coerce type automatically. While supporting various validation library like Zod, Valibot with the same syntax as well.

Alternatively, Fastify can also use **TypeBox** or **Zod** for validation using `@fastify/type-provider-typebox` to infer type automatically.

While Elysia **prefers TypeBox** for validation, Elysia also support for Standard Schema allowing you to use library like Zod, Valibot, ArkType, Effect Schema and so on out of the box.

Fastify use a `fastify-multipart` to handle file upload which use `Busboy` under the hood while Elysia use Web Standard API for handling formdata, mimetype valiation using declarative API.

However, Fastify doesn't offers a straight forward way for file validation, eg. file size and mimetype, and required some workarounds to validate the file.

> Fastift use `fastify-multipart` to handle file upload, and fake `type: object` to allow Buffer

> Elysia handle file, and mimetype validation using `t.File`

As **multer** doesn't validate mimetype, you need to validate the mimetype manually using **file-type** or similar library.

While Elysia, validate file upload, and use **file-type** to validate mimetype automatically.

Both Fastify and Elysia has some what similar lifecycle event using event-based approach.

Elysia's Life Cycle event can be illustrated as the following.
![Elysia Life Cycle Graph](/assets/lifecycle-chart.svg)

> Click on image to enlarge

Fastify Life Cycle event also use an event-based approach similar to Elysia.

Both also has somewhat similar syntax for intercepting the request and response lifecycle events, however Elysia doesn't require you to call `done` to continue the lifecycle event.

> Fastify use `addHook` to register a middleware, and requires you to call `done` to continue the lifecycle event

> Elysia detects the lifecycle event automatically, and doesn't require you to call `done` to continue the lifecycle event

Elysia is designed to be sounds type safety.

For example, you can customize context in a **type safe** manner using [derive](/essential/life-cycle.html#derive) and [resolve](/essential/life-cycle.html#resolve) while Fastify doesn't.

> Fastify use `decorateRequest` but doesn't offers sounds type safety

> Elysia use `decorate` to extend the context, and `resolve` to add custom properties to the context

While Fastify can, use `declare module` to extend the `FastifyRequest` interface, it is globally available and doesn't have sounds type safety, and doesn't garantee that the property is available in all request handlers.

> This is required for the above Fastify example to work, which doesn't offers sounds type safety

Fastify use a function to return Fastify plugin to define a named middleware, while Elysia use [macro](/patterns/macro) to define a custom hook.

> Fastify use a function callback to accept custom argument for middleware

> Elysia use macro to pass custom argument to custom middleware

While Fastify use a function callback, it needs to return a function to be placed in an event handler or an object represented as a hook which can be hard to handle when there are need for multiple custom functions as you need to reconcile them into a single object.

Both Fastify and Elysia offers a lifecycle event to handle error.

> Fastify use `setErrorHandler` for global error handler, and `errorHandler` for route-specific error handler

> Elysia offers a custom error code, a shorthand for status and `toResponse` for mapping error to a response.

While Both offers error handling using lifecycle event, Elysia also provide:

1. Custom error code
2. Shorthand for mapping HTTP status and `toResponse` for mapping error to a response

The error code is useful for logging and debugging, and is important when differentiating between different error types extending the same class.

Elysia provides all of this with type safety while Fastify doesn't.

Fastify encapsulate plugin side-effect, while Elysia give you a control over side-effect of a plugin via explicit scoping mechanism, and order-of-code.

> Fastify encapsulate side-effect of a plugin

> Elysia encapsulate side-effect of a plugin unless explicitly stated

Both has a encapsulate mechanism of a plugin to prevent side-effect.

However, Elysia can explicitly stated which plugin should have side-effect by declaring a scoped while Fastify always encapsulate it.

Elysia offers 3 type of scoping mechanism:

1. **local** - Apply to current instance only, no side-effect (default)
2. **scoped** - Scoped side-effect to the parent instance but not beyond
3. **global** - Affects every instances

As Fastify doesn't offers a scoping mechanism, we need to either:

1. Create a function for each hooks and append them manually
2. Use higher-order-function, and apply it to instance that need the effect

However, this can caused a duplicated side-effect if not handled carefully.

In this scenario, Elysia offers a plugin deduplication mechanism to prevent duplicated side-effect.

By using a unique `name`, Elysia will apply the plugin only once, and will not cause duplicated side-effect.

Fastify use `@fastify/cookie` to parse cookies, while Elysia has a built-in support for cookie and use a signal-based approach to handle cookies.

> Fastify use `unsignCookie` to verify the cookie signature, and `setCookie` to set the cookie

> Elysia use a signal-based approach to handle cookies, and signature verification is handle automatically

Both offers OpenAPI documentation using Swagger, however Elysia default to Scalar UI which is a more modern and user-friendly interface for OpenAPI documentation.

> Fastify use `@fastify/swagger` for OpenAPI documentation using Swagger

> Elysia use `@elysiajs/swagger` for OpenAPI documentation using Scalar by default, or optionally Swagger

Both offers model reference using `$ref` for OpenAPI documentation, however Fastify doesn't offers type-safety, and auto-completion for specifying model name while Elysia does.

Fastify has a built-in support for testing using `fastify.inject()` to **simulate** network request while Elysia use a Web Standard API to do an **actual** request.

> Fastify use `fastify.inject()` to simulate network request

> Elysia use Web Standard API to handle **actual** request

Alternatively, Elysia also offers a helper library called [Eden](/eden/overview) for End-to-end type safety, allowing us to test with auto-completion, and full type safety.

Elysia offers a built-in support for **end-to-end type safety** without code generation using [Eden](/eden/overview), while Fastify doesn't offers one.

If end-to-end type safety is important for you then Elysia is the right choice.

Elysia offers a more ergonomic and developer-friendly experience with a focus on performance, type safety, and simplicity while Fastify is one of the established framework for Node.js, but doesn't have **sounds type safety** and **end-to-end type safety** offered by next generation framework.

If you are looking for a framework that is easy to use, has a great developer experience, and is built on top of Web Standard API, Elysia is the right choice for you.

Alternatively, if you are coming from a different framework, you can check out:

**Examples:**

Example 1 (unknown):
```unknown
:::


> Fastify use `request` and `reply` as request and response objects

::: code-group
```

Example 2 (unknown):
```unknown
:::


> Elysia use a single `context` and returns the response directly

There is a slight different in style guide, Elysia recommends usage of method chaining and object destructuring.

Elysia also supports an inline value for the response if you don't need to use the context.

## Handler

Both has a simliar property for accessing input parameters like `headers`, `query`, `params`, and `body`, and automatically parse the request body to JSON, URL-encoded data, and formdata.

::: code-group
```

Example 3 (unknown):
```unknown
:::


> Fastify parse data and put it into `request` object

::: code-group
```

Example 4 (unknown):
```unknown
:::


> Elysia parse data and put it into `context` object

## Subrouter

Fastify use a function callback to define a subrouter while Elysia treats every instances as a component that can be plug and play together.

::: code-group
```

---

## From Express to Elysia

**URL:** https://elysiajs.com/migrate/from-express.md

**Contents:**
- Performance
- Routing
- Handler
- Subrouter
- Validation
- File upload
- Middleware
- Sounds type safety
- Middleware parameter
- Error handling

---
url: 'https://elysiajs.com/migrate/from-express.md'
---

This guide is for Express users who want to see the differences from Express including syntax, and how to migrate your application from Express to Elysia by example.

**Express** is a popular web framework for Node.js, and widely used for building web applications and APIs. It is known for its simplicity and flexibility.

**Elysia** is an ergonomic web framework for Bun, Node.js, and runtimes that support Web Standard API. Designed to be ergonomic and developer-friendly with a focus on **sound type safety** and performance.

Elysia has significant performance improvements over Express thanks to native Bun implementation, and static code analysis.

Express and Elysia have similar routing syntax, using `app.get()` and `app.post()` methods to define routes and similar path parameter syntax.

> Express use `req` and `res` as request and response objects

> Elysia use a single `context` and returns the response directly

There is a slight different in style guide, Elysia recommends usage of method chaining and object destructuring.

Elysia also supports an inline value for the response if you don't need to use the context.

Both has a simliar property for accessing input parameters like `headers`, `query`, `params`, and `body`.

> Express needs `express.json()` middleware to parse JSON body

> Elysia parse JSON, URL-encoded data, and formdata by default

Express use a dedicated `express.Router()` for declaring a sub router while Elysia treats every instances as a component that can be plug and play together.

> Express use `express.Router()` to create a sub router

> Elysia treat every instances as a component

Elysia has a built-in support for request validation using TypeBox sounds type safety, and support for Standard Schema out of the box allowing you to use your favorite library like Zod, Valibot, ArkType, Effect Schema and so on. While Express doesn't offers a built-in validation, and require a manual type declaration based on each validation library.

> Express require external validation library like `zod` or `joi` to validate request body

> Elysia use TypeBox for validation, and coerce type automatically. While supporting various validation library like Zod, Valibot with the same syntax as well.

Express use an external library `multer` to handle file upload, while Elysia has a built-in support for file and formdata, mimetype valiation using declarative API.

> Express needs `express.json()` middleware to parse JSON body

> Elysia handle file, and mimetype validation declaratively

As **multer** doesn't validate mimetype, you need to validate the mimetype manually using **file-type** or similar library.

Elysia validate file upload, and use **file-type** to validate mimetype automatically.

Express middleware use a single queue-based order while Elysia give you a more granular control using an **event-based** lifecycle.

Elysia's Life Cycle event can be illustrated as the following.
![Elysia Life Cycle Graph](/assets/lifecycle-chart.svg)

> Click on image to enlarge

While Express has a single flow for request pipeline in order, Elysia can intercept each event in a request pipeline.

> Express use a single queue-based order for middleware which execute in order

> Elysia use a specific event interceptor for each point in the request pipeline

While Express has a `next` function to call the next middleware, Elysia does not has one.

Elysia is designed to be sounds type safety.

For example, you can customize context in a **type safe** manner using [derive](/essential/life-cycle.html#derive) and [resolve](/essential/life-cycle.html#resolve) while Express doesn't.

> Express use a single queue-based order for middleware which execute in order

> Elysia use a specific event interceptor for each point in the request pipeline

While Express can, use `declare module` to extend the `Request` interface, it is globally available and doesn't have sounds type safety, and doesn't garantee that the property is available in all request handlers.

> This is required for the above Express example to work, which doesn't offers sounds type safety

Express use a function to return a plugin to define a reusable route-specific middleware, while Elysia use [macro](/patterns/macro) to define a custom hook.

> Express use a function callback to accept custom argument for middleware

> Elysia use macro to pass custom argument to custom middleware

Express use a single error handler for all routes, while Elysia provides a more granular control over error handling.

> Express use middleware to handle error, a single error handler for all routes

> Elysia provide more granular control over error handling, and scoping mechanism

While Express offers error handling using middleware, Elysia provide:

1. Both global and route specific error handler
2. Shorthand for mapping HTTP status and `toResponse` for mapping error to a response
3. Provide a custom error code for each error

The error code is useful for logging and debugging, and is important when differentiating between different error types extending the same class.

Elysia provides all of this with type safety while Express doesn't.

Express middleware is registered globally, while Elysia give you a control over side-effect of a plugin via explicit scoping mechanism, and order-of-code.

> Express doesn't handle side-effect of middleware, and requires a prefix to separate the side-effect

> Elysia encapsulate a side-effect into a plugin

By default, Elysia will encapsulate lifecycle events and context to the instance that is used, so that the side-effect of a plugin will not affect parent instance unless explicitly stated.

Elysia offers 3 type of scoping mechanism:

1. **local** - Apply to current instance only, no side-effect (default)
2. **scoped** - Scoped side-effect to the parent instance but not beyond
3. **global** - Affects every instances

While Express can scope the middleware side-effect by adding a prefix, it isn't a true encapsulation. The side-effect is still there but separated to any routes starts with said prefix, adding a mental overhead to the developer to memorize which prefix has side-effect.

Which you can do the following:

1. Move order of code from but only if there are a single instance with side-effects.
2. Add a prefix, but the side-effects are still there. If other instance has the same prefix, then it has the side-effects.

This can leads to a nightmarish scenario to debug as Express doesn't offers true encapsulation.

Express use an external library `cookie-parser` to parse cookies, while Elysia has a built-in support for cookie and use a signal-based approach to handle cookies.

> Express use `cookie-parser` to parse cookies

> Elysia use signal-based approach to handle cookies

Express require a separate configuration for OpenAPI, validation, and type safety while Elysia has a built-in support for OpenAPI using schema as a **single source of truth**.

> Express requires a separate configuration for OpenAPI, validation, and type safety

> Elysia use a schema as a single source of truth

Elysia will generate OpenAPI specification based on the schema you provided, and validate the request and response based on the schema, and infer type automatically.

Elysia also appends the schema registered in `model` to the OpenAPI spec, allowing you to reference the model in a dedicated section in Swagger or Scalar UI.

Express use a single `supertest` library to test the application, while Elysia is built on top of Web Standard API allowing it be used with any testing library.

> Express use `supertest` library to test the application

> Elysia use Web Standard API to handle request and response

Alternatively, Elysia also offers a helper library called [Eden](/eden/overview) for End-to-end type safety, allowing us to test with auto-completion, and full type safety.

Elysia offers a built-in support for **end-to-end type safety** without code generation using [Eden](/eden/overview), Express doesn't offers one.

If end-to-end type safety is important for you then Elysia is the right choice.

Elysia offers a more ergonomic and developer-friendly experience with a focus on performance, type safety, and simplicity while Express is a popular web framework for Node.js, but it has some limitations when it comes to performance and simplicity.

If you are looking for a framework that is easy to use, has a great developer experience, and is built on top of Web Standard API, Elysia is the right choice for you.

Alternatively, if you are coming from a different framework, you can check out:

**Examples:**

Example 1 (unknown):
```unknown
:::


> Express use `req` and `res` as request and response objects

::: code-group
```

Example 2 (unknown):
```unknown
:::


> Elysia use a single `context` and returns the response directly

There is a slight different in style guide, Elysia recommends usage of method chaining and object destructuring.

Elysia also supports an inline value for the response if you don't need to use the context.

## Handler

Both has a simliar property for accessing input parameters like `headers`, `query`, `params`, and `body`.

::: code-group
```

Example 3 (unknown):
```unknown
:::


> Express needs `express.json()` middleware to parse JSON body

::: code-group
```

Example 4 (unknown):
```unknown
:::


> Elysia parse JSON, URL-encoded data, and formdata by default

## Subrouter

Express use a dedicated `express.Router()` for declaring a sub router while Elysia treats every instances as a component that can be plug and play together.

::: code-group
```

---

## Welcome to ElysiaJS

**URL:** https://elysiajs.com/playground.md

---
url: 'https://elysiajs.com/playground.md'
---

It's great to have you here! This playground is designed to help you get started with ElysiaJS quickly and easily.

Unlike traditional backend framework, Elysia can also run in a browser! Allowing you to write, and try out Elysia directly in your browser! making it a perfect environment for learning and experimentation.

Elysia is an ergonomic web framework for humans.

---

## From tRPC to Elysia

**URL:** https://elysiajs.com/migrate/from-trpc.md

**Contents:**
- Overview
- Routing
- Handler
- Subrouter
- Validation
- File upload
- Middleware
- Sounds type safety
- Middleware parameter
- Error handling

---
url: 'https://elysiajs.com/migrate/from-trpc.md'
---

This guide is for tRPC users who want to see a differences from Elysia including syntax, and how to migrate your application from tRPC to Elysia by example.

**tRPC** is a typesafe RPC framework for building APIs using TypeScript. It provides a way to create end-to-end type-safe APIs with type-safe contract between frontend and backend.

**Elysia** is an ergonomic web framework. Designed to be ergonomic and developer-friendly with a focus on **sound type safety** and performance.

tRPC is primarily designed as RPC communication with proprietary abstraction over RESTful API, while Elysia is focused on RESTful API.

Main feature of tRPC is end-to-end type safety contract between frontend and backend which Elysia also offers via [Eden](/eden/overview).

Making Elysia a better fit for building a universal API with RESTful standard that developers already know instead of learning a new proprietary abstraction while having the end-to-end type safety that tRPC offers.

Elysia use a syntax similar to Express, and Hono like `app.get()` and `app.post()` methods to define routes and similar path parameters syntax.

While tRPC use a nested router approach to define routes.

> tRPC use nested router and procedure to define routes

> Elysia use HTTP method, and path parameters to define routes

While tRPC use proprietary abstraction over RESTful API with procedure and router, Elysia use a syntax similar to Express, and Hono like `app.get()` and `app.post()` methods to define routes and similar path parameters syntax.

tRPC handler is called `procedure` which can be either `query` or `mutation`, while Elysia use HTTP method like `get`, `post`, `put`, `delete` and so on.

tRPC is doesn't have a concept of HTTP property like query, headers, status code, and so on, only `input` and `output`.

> tRPC use single `input` for all properties

> Elysia use specific property for each HTTP property

Elysia use **static code analysis** to determine what to parse, and only parse the required properties.

This is useful for performance and type safety.

tRPC use nested router to define subrouter, while Elysia use `.use()` method to define a subrouter.

> tRPC use nested router to define subrouter

> Elysia use a `.use()` method to define a subrouter

While you can inline the subrouter in tRPC, Elysia use `.use()` method to define a subrouter.

Both support Standard Schema for validation. Allowing you to use various validation library like Zod, Yup, Valibot, and so on.

> tRPC use `input` to define validation schema

> Elysia use specific property to define validation schema

Both offers type inference from schema to context automatically.

tRPC doesn't support file upload out-of-the-box and require you to use `base64` string as input which is inefficient, and doesn't support mimetype validation.

While Elysia has built-in support for file upload using Web Standard API.

> Elysia handle file, and mimetype validation declaratively

As doesn't validate mimetype out-of-the-box, you need to use a third-party library like `file-type` to validate an actual type.

tRPC middleware use a single queue-based order with `next` similar to Express, while Elysia give you a more granular control using an **event-based** lifecycle.

Elysia's Life Cycle event can be illustrated as the following.
![Elysia Life Cycle Graph](/assets/lifecycle-chart.svg)

> Click on image to enlarge

While tRPC has a single flow for request pipeline in order, Elysia can intercept each event in a request pipeline.

> tRPC use a single middleware queue defined as a procedure

> Elysia use a specific event interceptor for each point in the request pipeline

While tRPC has a `next` function to call the next middleware in the queue, Elysia use specific event interceptor for each point in the request pipeline.

Elysia is designed to be sounds type safety.

For example, you can customize context in a **type safe** manner using [derive](/essential/life-cycle.html#derive) and [resolve](/essential/life-cycle.html#resolve) while tRPC offers one by using `context` by type case which is doesn't ensure 100% type safety, making it unsounds.

> tRPC use `context` to extend context but doesn't have sounds type safety

> Elysia use a specific event interceptor for each point in the request pipeline

Both support custom middleware, but Elysia use macro to pass custom argument to custom middleware while tRPC use higher-order-function which is not type safe.

> tRPC use higher-order-function to pass custom argument to custom middleware

> Elysia use macro to pass custom argument to custom middleware

tRPC use middleware-like to handle error, while Elysia provide custom error with type safety, and error interceptor for both global and route specific error handler.

> tRPC use middleware-like to handle error

> Elysia provide more granular control over error handling, and scoping mechanism

While tRPC offers error handling using middleware-like, Elysia provide:

1. Both global and route specific error handler
2. Shorthand for mapping HTTP status and `toResponse` for mapping error to a response
3. Provide a custom error code for each error

The error code is useful for logging and debugging, and is important when differentiating between different error types extending the same class.

Elysia provides all of this with type safety while tRPC doesn't.

tRPC encapsulate side-effect of a by procedure or router making it always isolated, while Elysia give you a control over side-effect of a plugin via explicit scoping mechanism, and order-of-code.

> tRPC encapsulate side-effect of a plugin into the procedure or router

> Elysia encapsulate side-effect of a plugin unless explicitly stated

Both has a encapsulate mechanism of a plugin to prevent side-effect.

However, Elysia can explicitly stated which plugin should have side-effect by declaring a scoped while Fastify always encapsulate it.

Elysia offers 3 type of scoping mechanism:

1. **local** - Apply to current instance only, no side-effect (default)
2. **scoped** - Scoped side-effect to the parent instance but not beyond
3. **global** - Affects every instances

tRPC doesn't offers OpenAPI first party, and relying on third-party library like `trpc-to-openapi` which is not a streamlined solution.

While Elysia has built-in support for OpenAPI using [@elysiajs/openapi](/plugins/openapi) from a single line of code.

> tRPC rely on third-party library to generate OpenAPI spec

> Elysia seamlessly integrate the specification into the schema

tRPC rely on third-party library to generate OpenAPI spec, and **MUST** require you to define a correct path name and HTTP method in the metadata which is force you to be **consistently aware** of how you place a router, and procedure.

While Elysia use schema you provide to generate the OpenAPI specification, and validate the request/response, and infer type automatically all from a **single source of truth**.

Elysia also appends the schema registered in `model` to the OpenAPI spec, allowing you to reference the model in a dedicated section in Swagger or Scalar UI while this is missing on tRPC inline the schema to the route.

Elysia use Web Standard API to handle request and response while tRPC require a lot of ceremony to run the request using `createCallerFactory`.

> tRPC require `createCallerFactory`, and a lot of ceremony to run the request

> Elysia use Web Standard API to handle request and response

Alternatively, Elysia also offers a helper library called [Eden](/eden/overview) for End-to-end type safety which is similar to `tRPC.createCallerFactory`, allowing us to test with auto-completion, and full type safety like tRPC without the ceremony.

Both offers end-to-end type safety for client-server communication.

> tRPC use `createTRPCProxyClient` to create a client with end-to-end type safety

> Elysia use `treaty` to run the request, and offers end-to-end type safety

While both offers end-to-end type safety, tRPC only handle **happy path** where the request is successful, and doesn't have a type soundness of error handling, making it unsound.

If type soundness is important for you, then Elysia is the right choice.

While tRPC is a great framework for building type-safe APIs, it has its limitations in terms of RESTful compliance, and type soundness.

Elysia is designed to be ergonomic and developer-friendly with a focus on developer experience, and **type soundness** complying with RESTful, OpenAPI, and WinterTC Standard making it a better fit for building a universal API.

Alternatively, if you are coming from a different framework, you can check out:

**Examples:**

Example 1 (unknown):
```unknown
:::


> tRPC use nested router and procedure to define routes

::: code-group
```

Example 2 (unknown):
```unknown
:::


> Elysia use HTTP method, and path parameters to define routes

While tRPC use proprietary abstraction over RESTful API with procedure and router, Elysia use a syntax similar to Express, and Hono like `app.get()` and `app.post()` methods to define routes and similar path parameters syntax.

## Handler

tRPC handler is called `procedure` which can be either `query` or `mutation`, while Elysia use HTTP method like `get`, `post`, `put`, `delete` and so on.

tRPC is doesn't have a concept of HTTP property like query, headers, status code, and so on, only `input` and `output`.

::: code-group
```

Example 3 (unknown):
```unknown
:::


> tRPC use single `input` for all properties

::: code-group
```

Example 4 (unknown):
```unknown
:::


> Elysia use specific property for each HTTP property

Elysia use **static code analysis** to determine what to parse, and only parse the required properties.

This is useful for performance and type safety.

## Subrouter

tRPC use nested router to define subrouter, while Elysia use `.use()` method to define a subrouter.

::: code-group
```

---

## Quick Start

**URL:** https://elysiajs.com/quick-start.md

**Contents:**
- Setup
  - Not on the list?

---
url: 'https://elysiajs.com/quick-start.md'
---

Elysia is a TypeScript backend framework with multiple runtime support but optimized for Bun.

However, you can use Elysia with other runtimes like Node.js.

\<Tab
id="quickstart"
:names="\['Bun', 'Node.js', 'Web Standard']"
:tabs="\['bun', 'node', 'web-standard']"

Elysia is optimized for Bun which is a JavaScript runtime that aims to be a drop-in replacement for Node.js.

You can install Bun with the command below:

\<Tab
id="quickstart"
:names="\['Auto Installation', 'Manual Installation']"
:tabs="\['auto', 'manual']"

We recommend starting a new Elysia server using `bun create elysia`, which sets up everything automatically.

Once done, you should see the folder name `app` in your directory.

Start a development server by:

Navigate to [localhost:3000](http://localhost:3000) should greet you with "Hello Elysia".

::: tip
Elysia ships you with `dev` command to automatically reload your server on file change.
:::

To manually create a new Elysia app, install Elysia as a package:

This will install Elysia and Bun type definitions.

Create a new file `src/index.ts` and add the following code:

Open your `package.json` file and add the following scripts:

These scripts refer to the different stages of developing an application:

* **dev** - Start Elysia in development mode with auto-reload on code change.
* **build** - Build the application for production usage.
* **start** - Start an Elysia production server.

If you are using TypeScript, make sure to create, and update `tsconfig.json` to include `compilerOptions.strict` to `true`:

Node.js is a JavaScript runtime for server-side applications, the most popular runtime for JavaScript which Elysia supports.

You can install Node.js with the command below:

We recommend using TypeScript for your Node.js project.

\<Tab
id="language"
:names="\['TypeScript', 'JavaScript']"
:tabs="\['ts', 'js']"

To create a new Elysia app with TypeScript, we recommend installing Elysia with `tsx`:

This will install Elysia, TypeScript, and `tsx`.

`tsx` is a CLI that transpiles TypeScript to JavaScript with hot-reload and several more feature you expected from a modern development environment.

Create a new file `src/index.ts` and add the following code:

Open your `package.json` file and add the following scripts:

These scripts refer to the different stages of developing an application:

* **dev** - Start Elysia in development mode with auto-reload on code change.
* **build** - Build the application for production usage.
* **start** - Start an Elysia production server.

Make sure to create `tsconfig.json`

Don't forget to update `tsconfig.json` to include `compilerOptions.strict` to `true`:

::: warning
If you use Elysia without TypeScript you may miss out on some features like auto-completion, advanced type checking and end-to-end type safety, which are the core features of Elysia.
:::

To create a new Elysia app with JavaScript, starts by installing Elysia:

This will install Elysia, TypeScript, and `tsx`.

`tsx` is a CLI that transpiles TypeScript to JavaScript with hot-reload and several more feature you expected from a modern development environment.

Create a new file `src/index.ts` and add the following code:

Open your `package.json` file and add the following scripts:

These scripts refer to the different stages of developing an application:

* **dev** - Start Elysia in development mode with auto-reload on code change.
* **start** - Start an Elysia production server.

Make sure to create `tsconfig.json`

Don't forget to update `tsconfig.json` to include `compilerOptions.strict` to `true`:

Elysia is a WinterCG compliance library, which means if a framework or runtime supports Web Standard Request/Response, it can run Elysia.

First, install Elysia with the command below:

Next, select a runtime that supports Web Standard Request/Response.

We have a few recommendations:

If you are using a custom runtime, you may access `app.fetch` to handle the request and response manually.

**Examples:**

Example 1 (unknown):
```unknown
:::

\<Tab
id="quickstart"
:names="\['Auto Installation', 'Manual Installation']"
:tabs="\['auto', 'manual']"

>

We recommend starting a new Elysia server using `bun create elysia`, which sets up everything automatically.
```

Example 2 (unknown):
```unknown
Once done, you should see the folder name `app` in your directory.
```

Example 3 (unknown):
```unknown
Start a development server by:
```

Example 4 (unknown):
```unknown
Navigate to [localhost:3000](http://localhost:3000) should greet you with "Hello Elysia".

::: tip
Elysia ships you with `dev` command to automatically reload your server on file change.
:::

To manually create a new Elysia app, install Elysia as a package:
```

---

## From Hono to Elysia

**URL:** https://elysiajs.com/migrate/from-hono.md

**Contents:**
- When to use
- Performance
- Routing
- Handler
- Subrouter
- Validation
- File upload
- Middleware
- Sounds type safety
- Middleware parameter

---
url: 'https://elysiajs.com/migrate/from-hono.md'
---

This guide is for Hono users who want to see a differences from Elysia including syntax, and how to migrate your application from Hono to Elysia by example.

**Hono** is a fast and lightweight web framework built on Web Standard. It has broad compatibility with multiple runtimes like Deno, Bun, Cloudflare Workers, and Node.js.

**Elysia** is an ergonomic web framework. Designed for developer experience with a focus on **sound type safety** and performance. Not limited to Bun, Elysia also supports multiple runtimes like Node.js, and Cloudflare Workers.

Here's a TLDR comparison between Hono and Elysia to help you decide:

* **Originally built for Cloudflare Workers**, more integrated with Cloudflare ecosystem
* Support multiple runtime with Web Standard, including **Node.js** and **Bun**
* Lightweight and minimalistic, suitable for edge environment
* Support OpenAPI but require additional effort to describe the specification
* Prefers simple, linear middleware-based approach
* Type safety is better than most frameworks, but not sound in some areas
* Somewhat similar to Express, Koa in terms of middleware, plugin style

* **Originally built for native Bun**, use most of Bun features to the fullest extent
* Support multiple runtime with Web Standard, including **Node.sjs** and **Cloudflare Worker**
* **Better performance**. Leans to long running server via JIT.
* **Better OpenAPI supports** with seamless experience, especially with [OpenAPI Type Gen](/patterns/openapi#openapi-from-types)
* Prefers event-based lifecycle approach for better control over request pipeline
* Sounds type safety across the board, including middleware, and error handling
* Somewhat similar to Fastify in terms of middleware, encapsulation, and plugin style

There is a huge **different between being compatible and specifically built for** something.

If you decide to use Elysia on Cloudflare Workers, you might miss some of the Cloudflare specific features that Hono provides out of the box. Similarly, if you use Hono on Bun, you might not get the best performance possible compared to using Elysia.

Elysia has significant performance improvements over Hono thanks to static code analysis.

Hono and Elysia has similar routing syntax, using `app.get()` and `app.post()` methods to define routes and similar path parameters syntax.

Both use a single `Context` parameters to handle request and response, and return a response directly.

> Hono use helper `c.text`, `c.json` to return a response

> Elysia use a single `context` and returns the response directly

While Hono use a `c.text`, and `c.json` to warp a response, Elysia map a value to a response automatically.

There is a slight different in style guide, Elysia recommends usage of method chaining and object destructuring.

Hono port allocation is depends on runtime, and adapter while Elysia use a single `listen` method to start the server.

Hono use a function to parse query, header, and body manually while Elysia automatically parse properties.

> Hono parse body automatically but it doesn't apply to query and headers

> Elysia use static code analysis to analyze what to parse

Elysia use **static code analysis** to determine what to parse, and only parse the required properties.

This is useful for performance and type safety.

Both can inherits another instance as a router, but Elysia treat every instances as a component which can be used as a subrouter.

> Hono **require** a prefix to separate the subrouter

> Elysia use optional prefix constructor to define one

While Hono requires a prefix to separate the subrouter, Elysia doesn't require a prefix to separate the subrouter.

While Hono supports for various validator via external package, Elysia has a built-in validation using **TypeBox**, and support for Standard Schema out of the box allowing you to use your favorite library like Zod, Valibot, ArkType, Effect Schema and so on without additional library. Elysia also offers seamless integration with OpenAPI, and type inference behind the scene.

> Hono use pipe based

> Elysia use TypeBox for validation, and coerce type automatically. While supporting various validation library like Zod, Valibot with the same syntax as well.

Both offers type inference from schema to context automatically.

Both Hono, and Elysia use Web Standard API to handle file upload, but Elysia has a built-in declarative support for file validation using **file-type** to validate mimetype.

> Hono needs a separate `file-type` library to validate mimetype

> Elysia handle file, and mimetype validation declaratively

As Web Standard API doesn't validate mimetype, it is a security risk to trust `content-type` provided by the client so external library is required for Hono, while Elysia use `file-type` to validate mimetype automatically.

Hono middleware use a single queue-based order similar to Express while Elysia give you a more granular control using an **event-based** lifecycle.

Elysia's Life Cycle event can be illustrated as the following.
![Elysia Life Cycle Graph](/assets/lifecycle-chart.svg)

> Click on image to enlarge

While Hono has a single flow for request pipeline in order, Elysia can intercept each event in a request pipeline.

> Hono use a single queue-based order for middleware which execute in order

> Elysia use a specific event interceptor for each point in the request pipeline

While Hono has a `next` function to call the next middleware, Elysia does not has one.

Elysia is designed to be sounds type safety.

For example, you can customize context in a **type safe** manner using [derive](/essential/life-cycle.html#derive) and [resolve](/essential/life-cycle.html#resolve) while Hono doesn't.

> Hono use a middleware to extend the context, but is not type safe

> Elysia use a specific event interceptor for each point in the request pipeline

While Hono can, use `declare module` to extend the `ContextVariableMap` interface, it is globally available and doesn't have sounds type safety, and doesn't garantee that the property is available in all request handlers.

> This is required for the above Hono example to work, which doesn't offers sounds type safety

Hono use a callback function to define a reusable route-specific middleware, while Elysia use [macro](/patterns/macro) to define a custom hook.

> Hono use callback to return `createMiddleware` to create a reusable middleware, but is not type safe

> Elysia use macro to pass custom argument to custom middleware

Hono provide a `onError` function which apply to all routes while Elysia provides a more granular control over error handling.

> Hono use `onError` funcition to handle error, a single error handler for all routes

> Elysia provide more granular control over error handling, and scoping mechanism

While Hono offers error handling using middleware-like, Elysia provide:

1. Both global and route specific error handler
2. Shorthand for mapping HTTP status and `toResponse` for mapping error to a response
3. Provide a custom error code for each error

The error code is useful for logging and debugging, and is important when differentiating between different error types extending the same class.

Elysia provides all of this with type safety while Hono doesn't.

Hono encapsulate plugin side-effect, while Elysia give you a control over side-effect of a plugin via explicit scoping mechanism, and order-of-code.

> Hono encapsulate side-effect of a plugin

> Elysia encapsulate side-effect of a plugin unless explicitly stated

Both has a encapsulate mechanism of a plugin to prevent side-effect.

However, Elysia can explicitly stated which plugin should have side-effect by declaring a scoped while Hono always encapsulate it.

Elysia offers 3 type of scoping mechanism:

1. **local** - Apply to current instance only, no side-effect (default)
2. **scoped** - Scoped side-effect to the parent instance but not beyond
3. **global** - Affects every instances

As Hono doesn't offers a scoping mechanism, we need to either:

1. Create a function for each hooks and append them manually
2. Use higher-order-function, and apply it to instance that need the effect

However, this can caused a duplicated side-effect if not handled carefully.

In this scenario, Elysia offers a plugin deduplication mechanism to prevent duplicated side-effect.

By using a unique `name`, Elysia will apply the plugin only once, and will not cause duplicated side-effect.

Hono has a built-in cookie utility functions under `hono/cookie`, while Elysia use a signal-based approach to handle cookies.

> Hono use utility functions to handle cookies

> Elysia use signal-based approach to handle cookies

Hono require additional effort to describe the specification, while Elysia seamless integrate the specification into the schema.

> Hono require additional effort to describe the specification

> Elysia seamlessly integrate the specification into the schema

Hono has separate function to describe route specification, validation, and require some effort to setup properly.

Elysia use schema you provide to generate the OpenAPI specification, and validate the request/response, and infer type automatically all from a **single source of truth**.

Elysia also appends the schema registered in `model` to the OpenAPI spec, allowing you to reference the model in a dedicated section in Swagger or Scalar UI while Hono inline the schema to the route.

Both is built on top of Web Standard API allowing it be used with any testing library.

> Hono has a built-in `request` method to run the request

> Elysia use Web Standard API to handle request and response

Alternatively, Elysia also offers a helper library called [Eden](/eden/overview) for End-to-end type safety, allowing us to test with auto-completion, and full type safety.

Both offers end-to-end type safety, however Hono doesn't seems to offers type-safe error handling based on status code.

> Hono use `hc` to run the request, and offers end-to-end type safety

> Elysia use `treaty` to run the request, and offers end-to-end type safety

While both offers end-to-end type safety, Elysia offers a more type-safe error handling based on status code while Hono doesn't.

Using the same purpose code for each framework to measure type inference speed, Elysia is 2.3x faster than Hono for type checking.

![Elysia eden type inference performance](/migrate/elysia-type-infer.webp)

> Elysia take 536ms to infer both Elysia, and Eden (click to enlarge)

![Hono HC type inference performance](/migrate/hono-type-infer.webp)

> Hono take 1.27s to infer both Hono, and HC with error (aborted) (click to enlarge)

The 1.27 seconds doesn't reflect the entire duration of the inference, but a duration from start to aborted by error **"Type instantiation is excessively deep and possibly infinite."** which happens when there are too large schema.

![Hono HC code showing excessively deep error](/migrate/hono-hc-infer.webp)

> Hono HC showing excessively deep error

This is caused by the large schema, and Hono doesn't support over a 100 routes with complex body, and response validation while Elysia doesn't have this issue.

![Elysia Eden code showing type inference without error](/migrate/elysia-eden-infer.webp)

> Elysia Eden code showing type inference without error

Elysia has a faster type inference performance, and doesn't have **"Type instantiation is excessively deep and possibly infinite."** *at least* up to 2,000 routes with complex body, and response validation.

If end-to-end type safety is important for you then Elysia is the right choice.

Both are the next generation web framework built on top of Web Standard API with slight differences.

Elysia is designed to be ergonomic and developer-friendly with a focus on **sounds type safety**, and has better performance than Hono.

While Hono offers a broad compatibility with multiple runtimes, especially with Cloudflare Workers, and a larger user base.

Alternatively, if you are coming from a different framework, you can check out:

**Examples:**

Example 1 (unknown):
```unknown
:::


> Hono use helper `c.text`, `c.json` to return a response

::: code-group
```

Example 2 (unknown):
```unknown
:::


> Elysia use a single `context` and returns the response directly

While Hono use a `c.text`, and `c.json` to warp a response, Elysia map a value to a response automatically.

There is a slight different in style guide, Elysia recommends usage of method chaining and object destructuring.

Hono port allocation is depends on runtime, and adapter while Elysia use a single `listen` method to start the server.

## Handler

Hono use a function to parse query, header, and body manually while Elysia automatically parse properties.

::: code-group
```

Example 3 (unknown):
```unknown
:::


> Hono parse body automatically but it doesn't apply to query and headers

::: code-group
```

Example 4 (unknown):
```unknown
:::


> Elysia use static code analysis to analyze what to parse

Elysia use **static code analysis** to determine what to parse, and only parse the required properties.

This is useful for performance and type safety.

## Subrouter

Both can inherits another instance as a router, but Elysia treat every instances as a component which can be used as a subrouter.

::: code-group
```

---

## Comparison with Other Frameworks

**URL:** https://elysiajs.com/migrate.md

---
url: 'https://elysiajs.com/migrate.md'
---
# Comparison with Other Frameworks

Elysia is designed to be intuitive and easy to use, especially for those familiar with other web frameworks.

If you have used other popular frameworks like Express, Fastify, or Hono, you will find Elysia right at home with just a few differences.

---
