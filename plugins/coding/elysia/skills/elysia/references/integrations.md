# Elysia - Integrations

**Pages:** 17

---

## Drizzle

**URL:** https://elysiajs.com/integrations/drizzle.md

**Contents:**
  - Drizzle Typebox
  - Here's how it works:
- Installation
- Drizzle schema
- drizzle-typebox
- Type instantiation is possibly infinite
- Utility
  - Table Singleton
  - Refinement

---
url: 'https://elysiajs.com/integrations/drizzle.md'
---

Drizzle ORM is a headless TypeScript ORM with a focus on type safety and developer experience.

We may convert Drizzle schema to Elysia validation models using `drizzle-typebox`

[Elysia.t](/essential/validation.html#elysia-type) is a fork of TypeBox, allowing us to use any TypeBox type in Elysia directly.

We can convert Drizzle schema into TypeBox schema using ["drizzle-typebox"](https://npmjs.org/package/drizzle-typebox), and use it directly on Elysia's schema validation.

1. Define your database schema in Drizzle.
2. Convert Drizzle schema into Elysia validation models using `drizzle-typebox`.
3. Use the converted Elysia validation models to ensure type validation.
4. OpenAPI schema is generated from Elysia validation models.
5. Add [Eden Treaty](/eden/overview) to add type-safety to your frontend.

To install Drizzle, run the following command:

Then you need to pin `@sinclair/typebox` as there might be a mismatch version between `drizzle-typebox` and `Elysia`, this may cause conflict of Symbols between two versions.

We recommend pinning the version of `@sinclair/typebox` to the **minimum version** used by `elysia` by using:

We may use `overrides` field in `package.json` to pin the version of `@sinclair/typebox`:

Assuming we have a `user` table in our codebase as follows:

We may convert the `user` table into TypeBox models by using `drizzle-typebox`:

This allows us to reuse the database schema in Elysia validation models

If you got an error like **Type instantiation is possibly infinite** this is because of the circular reference between `drizzle-typebox` and `Elysia`.

If we nested a type from drizzle-typebox into Elysia schema, it will cause an infinite loop of type instantiation.

To prevent this, we need to **explicitly define a type between `drizzle-typebox` and `Elysia`** schema:

Always declare a variable for `drizzle-typebox` and reference it if you want to use Elysia type

As we are likely going to use `t.Pick` and `t.Omit` to exclude or include certain fields, it may be cumbersome to repeat the process:

We recommend using these utility functions **(copy as-is)** to simplify the process:

This utility function will convert Drizzle schema into a plain object, which can pick by property name as plain object:

We recommend using a singleton pattern to store the table schema, this will allow us to access the table schema from anywhere in the codebase:

This will allow us to access the table schema from anywhere in the codebase:

If type refinement is needed, you may use `createInsertSchema` and `createSelectSchema` to refine the schema directly.

In the code above, we refine a `user.email` schema to include a `format` property

The `spread` utility function will skip a refined schema, so you can use it as is.

For more information, please refer to the [Drizzle ORM](https://orm.drizzle.team) and [Drizzle TypeBox](https://orm.drizzle.team/docs/typebox) documentation.

**Examples:**

Example 1 (unknown):
```unknown
* ——————————————— *
                                                    |                 |
                                               | -> |  Documentation  |
* ————————— *             * ———————— * OpenAPI |    |                 |
|           |   drizzle-  |          | ——————— |    * ——————————————— *
|  Drizzle  | —————————-> |  Elysia  |
|           |  -typebox   |          | ——————— |    * ——————————————— *
* ————————— *             * ———————— *   Eden  |    |                 |
                                               | -> |  Frontend Code  |
												    |                 |
												    * ——————————————— *
```

Example 2 (bash):
```bash
bun add drizzle-orm drizzle-typebox
```

Example 3 (bash):
```bash
grep "@sinclair/typebox" node_modules/elysia/package.json
```

Example 4 (json):
```json
{
  "overrides": {
  	"@sinclair/typebox": "0.32.4"
  }
}
```

---

## Integration with Expo

**URL:** https://elysiajs.com/integrations/expo.md

**Contents:**
  - pnpm
- Prefix
- Eden
- Deployment

---
url: 'https://elysiajs.com/integrations/expo.md'
---

Starting from Expo SDK 50, and App Router v3, Expo allows us to create API route directly in an Expo app.

1. Create **app/\[...slugs]+api.ts**
2. Define an Elysia server
3. Export **Elysia.fetch** name of HTTP methods you want to use

You can treat the Elysia server as if normal Expo API route.

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.

If you place an Elysia server not in the root directory of the app router, you need to annotate the prefix to the Elysia server.

For example, if you place Elysia server in **app/api/\[...slugs]+api.ts**, you need to annotate prefix as **/api** to Elysia server.

This will ensure that Elysia routing will work properly in any location you place it in.

We can add [Eden](/eden/overview) for **end-to-end type safety** similar to tRPC.

1. Export `type` from the Elysia server

2. Create a Treaty client

3. Use the client in both server and client components

You can either directly use API route using Elysia and deploy as normal Elysia app normally if need or using [experimental Expo server runtime](https://docs.expo.dev/router/reference/api-routes/#deployment).

If you are using Expo server runtime, you may use `expo export` command to create optimized build for your expo app, this will include an Expo function which is using Elysia at **dist/server/\_expo/functions/\[...slugs]+api.js**

::: tip
Please note that Expo Functions are treated as Edge functions instead of normal server, so running the Edge function directly will not allocate any port.
:::

You may use the Expo function adapter provided by Expo to deploy your Edge Function.

Currently Expo support the following adapter:

* [Express](https://docs.expo.dev/router/reference/api-routes/#express)
* [Netlify](https://docs.expo.dev/router/reference/api-routes/#netlify)
* [Vercel](https://docs.expo.dev/router/reference/api-routes/#vercel)

**Examples:**

Example 1 (unknown):
```unknown
:::

You can treat the Elysia server as if normal Expo API route.

### pnpm

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.
```

Example 2 (unknown):
```unknown
## Prefix

If you place an Elysia server not in the root directory of the app router, you need to annotate the prefix to the Elysia server.

For example, if you place Elysia server in **app/api/\[...slugs]+api.ts**, you need to annotate prefix as **/api** to Elysia server.

::: code-group
```

Example 3 (unknown):
```unknown
:::

This will ensure that Elysia routing will work properly in any location you place it in.

## Eden

We can add [Eden](/eden/overview) for **end-to-end type safety** similar to tRPC.

1. Export `type` from the Elysia server

::: code-group
```

Example 4 (unknown):
```unknown
:::

2. Create a Treaty client

::: code-group
```

---

## Integration with AI SDK

**URL:** https://elysiajs.com/integrations/ai-sdk.md

**Contents:**
- Response Streaming
- Server Sent Event
- As Response
- Manual Streaming
- Fetch

---
url: 'https://elysiajs.com/integrations/ai-sdk.md'
---

Elysia provides a support for response streaming with ease, allowing you to integrate with [Vercel AI SDKs](https://vercel.com/docs/ai) seamlessly.

Elysia support continous streaming of a `ReadableStream` and `Response` allowing you to return stream directly from the AI SDKs.

Elysia will handle the stream automatically, allowing you to use it in various ways.

Elysia also supports Server Sent Event for streaming response by simply wrap a `ReadableStream` with `sse` function.

If you don't need a type-safety of the stream for further usage with [Eden](/eden/overview), you can return the stream directly as a response.

If you want to have more control over the streaming, you can use a generator function to yield the chunks manually.

If AI SDK doesn't support model you're using, you can still use the `fetch` function to make requests to the AI SDKs and stream the response directly.

Elysia will proxy fetch response with streaming support automatically.

For additional information, please refer to [AI SDK documentation](https://ai-sdk.dev/docs/introduction)

**Examples:**

Example 1 (ts):
```ts
import { Elysia } from 'elysia'
import { streamText } from 'ai'
import { openai } from '@ai-sdk/openai'

new Elysia().get('/', () => {
    const stream = streamText({
        model: openai('gpt-5'),
        system: 'You are Yae Miko from Genshin Impact',
        prompt: 'Hi! How are you doing?'
    })

    // Just return a ReadableStream
    return stream.textStream // [!code ++]

    // UI Message Stream is also supported
    return stream.toUIMessageStream() // [!code ++]
})
```

Example 2 (ts):
```ts
import { Elysia, sse } from 'elysia' // [!code ++]
import { streamText } from 'ai'
import { openai } from '@ai-sdk/openai'

new Elysia().get('/', () => {
    const stream = streamText({
        model: openai('gpt-5'),
        system: 'You are Yae Miko from Genshin Impact',
        prompt: 'Hi! How are you doing?'
    })

    // Each chunk will be sent as a Server Sent Event
    return sse(stream.textStream) // [!code ++]

    // UI Message Stream is also supported
    return sse(stream.toUIMessageStream()) // [!code ++]
})
```

Example 3 (ts):
```ts
import { Elysia } from 'elysia'
import { ai } from 'ai'
import { openai } from '@ai-sdk/openai'

new Elysia().get('/', () => {
    const stream = streamText({
        model: openai('gpt-5'),
        system: 'You are Yae Miko from Genshin Impact',
        prompt: 'Hi! How are you doing?'
    })

    return stream.toTextStreamResponse() // [!code ++]

    // UI Message Stream Response will use SSE
    return stream.toUIMessageStreamResponse() // [!code ++]
})
```

Example 4 (ts):
```ts
import { Elysia, sse } from 'elysia'
import { ai } from 'ai'
import { openai } from '@ai-sdk/openai'

new Elysia().get('/', async function* () {
    const stream = streamText({
        model: openai('gpt-5'),
        system: 'You are Yae Miko from Genshin Impact',
        prompt: 'Hi! How are you doing?'
    })

    for await (const data of stream.textStream) // [!code ++]
        yield sse({ // [!code ++]
            data, // [!code ++]
            event: 'message' // [!code ++]
        }) // [!code ++]

    yield sse({
        event: 'done'
    })
})
```

---

## Integration with Nuxt

**URL:** https://elysiajs.com/integrations/nuxt.md

**Contents:**
  - pnpm
- Prefix

---
url: 'https://elysiajs.com/integrations/nuxt.md'
---

We can use [nuxt-elysia](https://github.com/tkesgar/nuxt-elysia), a community plugin for Nuxt, to setup Elysia on Nuxt API route with Eden Treaty.

1. Install the plugin with the following command:

2. Add `nuxt-elysia` to your Nuxt config:

3. Create `api.ts` in the project root:

4. Use Eden Treaty in your Nuxt app:

This will automatically setup Elysia to run on Nuxt API route automatically.

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.

By default, Elysia will be mounted on **/\_api** but we can customize it with `nuxt-elysia` config.

This will mount Elysia on **/api** instead of **/\_api**.

For more configuration, please refer to [nuxt-elysia](https://github.com/tkesgar/nuxt-elysia)

**Examples:**

Example 1 (bash):
```bash
bun add elysia @elysiajs/eden
bun add -d nuxt-elysia
```

Example 2 (ts):
```ts
export default defineNuxtConfig({
    modules: [ // [!code ++]
        'nuxt-elysia' // [!code ++]
    ] // [!code ++]
})
```

Example 3 (unknown):
```unknown
4. Use Eden Treaty in your Nuxt app:
```

Example 4 (unknown):
```unknown
This will automatically setup Elysia to run on Nuxt API route automatically.

### pnpm

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.
```

---

## Integration with Astro

**URL:** https://elysiajs.com/integrations/astro.md

**Contents:**
  - pnpm
- Prefix

---
url: 'https://elysiajs.com/integrations/astro.md'
---

With [Astro Endpoint](https://docs.astro.build/en/core-concepts/endpoints/), we can run Elysia on Astro directly.

1. Set **output** to **server** in **astro.config.mjs**

2. Create **pages/\[...slugs].ts**
3. Create or import an existing Elysia server in **\[...slugs].ts**
4. Export the handler with the name of method you want to expose

Elysia will work normally as expected because of WinterCG compliance.

We recommend running [Astro on Bun](https://docs.astro.build/en/recipes/bun) as Elysia is designed to be run on Bun.

::: tip
You can run Elysia server without running Astro on Bun thanks to WinterCG support.
:::

With this approach, you can have co-location of both frontend and backend in a single repository and have End-to-end type-safety with Eden.

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.

If you place an Elysia server not in the root directory of the app router, you need to annotate the prefix to the Elysia server.

For example, if you place Elysia server in **pages/api/\[...slugs].ts**, you need to annotate prefix as **/api** to Elysia server.

This will ensure that Elysia routing will work properly in any location you place it.

Please refer to [Astro Endpoint](https://docs.astro.build/en/core-concepts/endpoints/) for more information.

**Examples:**

Example 1 (javascript):
```javascript
// astro.config.mjs
import { defineConfig } from 'astro/config'

// https://astro.build/config
export default defineConfig({
    output: 'server' // [!code ++]
})
```

Example 2 (typescript):
```typescript
// pages/[...slugs].ts
import { Elysia, t } from 'elysia'

const app = new Elysia()
    .get('/api', () => 'hi')
    .post('/api', ({ body }) => body, {
        body: t.Object({
            name: t.String()
        })
    })

const handle = ({ request }: { request: Request }) => app.handle(request) // [!code ++]

export const GET = handle // [!code ++]
export const POST = handle // [!code ++]
```

Example 3 (bash):
```bash
pnpm add @sinclair/typebox openapi-types
```

Example 4 (typescript):
```typescript
// pages/api/[...slugs].ts
import { Elysia, t } from 'elysia'

const app = new Elysia({ prefix: '/api' }) // [!code ++]
    .get('/', () => 'hi')
    .post('/', ({ body }) => body, {
        body: t.Object({
            name: t.String()
        })
    })

const handle = ({ request }: { request: Request }) => app.handle(request) // [!code ++]

export const GET = handle // [!code ++]
export const POST = handle // [!code ++]
```

---

## Integration with SvelteKit

**URL:** https://elysiajs.com/integrations/sveltekit.md

**Contents:**
  - pnpm
- Prefix

---
url: 'https://elysiajs.com/integrations/sveltekit.md'
---

With SvelteKit, you can run Elysia on server routes.

1. Create **src/routes/\[...slugs]/+server.ts**.
2. Define an Elysia server.
3. Export a **fallback** function that calls `app.handle`.

You can treat the Elysia server as a normal SvelteKit server route.

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.

If you place an Elysia server not in the root directory of the app router, you need to annotate the prefix to the Elysia server.

For example, if you place Elysia server in **src/routes/api/\[...slugs]/+server.ts**, you need to annotate prefix as **/api** to Elysia server.

This will ensure that Elysia routing will work properly in any location you place it.

Please refer to [SvelteKit Routing](https://kit.svelte.dev/docs/routing#server) for more information.

**Examples:**

Example 1 (typescript):
```typescript
// src/routes/[...slugs]/+server.ts
import { Elysia, t } from 'elysia';

const app = new Elysia()
    .get('/', 'hello SvelteKit')
    .post('/', ({ body }) => body, {
        body: t.Object({
            name: t.String()
        })
    })

interface WithRequest {
	request: Request
}

export const fallback = ({ request }: WithRequest) => app.handle(request) // [!code ++]
```

Example 2 (bash):
```bash
pnpm add @sinclair/typebox openapi-types
```

---

## Integration with Netlify Edge Function

**URL:** https://elysiajs.com/integrations/netlify.md

**Contents:**
  - Running locally
  - pnpm

---
url: 'https://elysiajs.com/integrations/netlify.md'
---

[Netlify Edge Function](https://docs.netlify.com/build/edge-functions/overview/) is run on [Deno](/integrations/deno) which is one of Elysia support runtime, as Elysia is built on top of Web Standard.

Netlify Edge Functions requires a special directory to run a function, the default is **\<directory>/netlify/edge-functions**.

To create a function at **/hello**, you would need to create file at `netlify/edge-functions/hello.ts`, then simply `export default` an Elysia instance.

To test your Elysia server on Netlify Edge Function locally, you can install [Netlify CLI](https://docs.netlify.com/build/edge-functions/get-started/#test-locally) to simluate function invokation.

To install Netlify CLI:

To run the development environment:

For an additional information, please refers to [Netlify Edge Function documentation](https://docs.netlify.com/build/edge-functions).

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.

**Examples:**

Example 1 (unknown):
```unknown
:::

### Running locally

To test your Elysia server on Netlify Edge Function locally, you can install [Netlify CLI](https://docs.netlify.com/build/edge-functions/get-started/#test-locally) to simluate function invokation.

To install Netlify CLI:
```

Example 2 (unknown):
```unknown
To run the development environment:
```

Example 3 (unknown):
```unknown
For an additional information, please refers to [Netlify Edge Function documentation](https://docs.netlify.com/build/edge-functions).

### pnpm

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.
```

---

## Better Auth

**URL:** https://elysiajs.com/integrations/better-auth.md

**Contents:**
- Handler
  - Custom endpoint
- OpenAPI
- CORS
- Macro

---
url: 'https://elysiajs.com/integrations/better-auth.md'
---

Better Auth is framework-agnostic authentication (and authorization) framework for TypeScript.

It provides a comprehensive set of features out of the box and includes a plugin ecosystem that simplifies adding advanced functionalities.

We recommend going through the [Better Auth basic setup](https://www.better-auth.com/docs/installation) before going through this page.

Our basic setup will look like this:

After setting up Better Auth instance, we can mount to Elysia via [mount](/patterns/mount.html).

We need to mount the handler to Elysia endpoint.

Then we can access Better Auth with `http://localhost:3000/api/auth`.

We recommend setting a prefix path when using [mount](/patterns/mount.html).

Then we can access Better Auth with `http://localhost:3000/auth/api/auth`.

But the URL looks redundant, we can customize the `/api/auth` prefix to something else in Better Auth instance.

Then we can access Better Auth with `http://localhost:3000/auth/api`.

Unfortunately, we can't set `basePath` of a Better Auth instance to be empty or `/`.

Better Auth support `openapi` with `better-auth/plugins`.

However if we are using [@elysiajs/openapi](/plugins/openapi), you might want to extract the documentation from Better Auth instance.

We may do that with the following code:

Then in our Elysia instance that use `@elysiajs/openapi`.

To configure cors, you can use the `cors` plugin from `@elysiajs/cors`.

You can use [macro](https://elysiajs.com/patterns/macro.html#macro) with [resolve](https://elysiajs.com/essential/handler.html#resolve) to provide session and user information before pass to view.

This will allow you to access the `user` and `session` object in all of your routes.

**Examples:**

Example 1 (unknown):
```unknown
## Handler

After setting up Better Auth instance, we can mount to Elysia via [mount](/patterns/mount.html).

We need to mount the handler to Elysia endpoint.
```

Example 2 (unknown):
```unknown
Then we can access Better Auth with `http://localhost:3000/api/auth`.

### Custom endpoint

We recommend setting a prefix path when using [mount](/patterns/mount.html).
```

Example 3 (unknown):
```unknown
Then we can access Better Auth with `http://localhost:3000/auth/api/auth`.

But the URL looks redundant, we can customize the `/api/auth` prefix to something else in Better Auth instance.
```

Example 4 (unknown):
```unknown
Then we can access Better Auth with `http://localhost:3000/auth/api`.

Unfortunately, we can't set `basePath` of a Better Auth instance to be empty or `/`.

## OpenAPI

Better Auth support `openapi` with `better-auth/plugins`.

However if we are using [@elysiajs/openapi](/plugins/openapi), you might want to extract the documentation from Better Auth instance.

We may do that with the following code:
```

---

## Integration with Node.js

**URL:** https://elysiajs.com/integrations/node.md

**Contents:**
  - Additional Setup (optional)
  - pnpm

---
url: 'https://elysiajs.com/integrations/node.md'
---

Elysia provide a runtime adapter to run Elysia on multiple runtime, including Node.js.

To run Elysia on Node.js, simply install Node adapter.

Then apply node adapter to your main Elysia instance.

This is all you need to run Elysia on Node.js.

For the best experience, we recommended installing `tsx` or `ts-node` with `nodemon`.

`tsx` is a CLI that transpiles TypeScript to JavaScript with hot-reload and several more feature you expected from a modern development environment.

Then open your `package.json` file and add the following scripts:

These scripts refer to the different stages of developing an application:

* **dev** - Start Elysia in development mode with auto-reload on code change.
* **build** - Build the application for production usage.
* **start** - Start an Elysia production server.

Make sure to create `tsconfig.json`

Don't forget to update `tsconfig.json` to include `compilerOptions.strict` to `true`:

This will give the hot reload, JSX support to run Elysia with the similar experience as `bun dev`

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.

**Examples:**

Example 1 (unknown):
```unknown
:::

Then apply node adapter to your main Elysia instance.
```

Example 2 (unknown):
```unknown
This is all you need to run Elysia on Node.js.

### Additional Setup (optional)

For the best experience, we recommended installing `tsx` or `ts-node` with `nodemon`.

`tsx` is a CLI that transpiles TypeScript to JavaScript with hot-reload and several more feature you expected from a modern development environment.

::: code-group
```

Example 3 (unknown):
```unknown
:::

Then open your `package.json` file and add the following scripts:
```

Example 4 (unknown):
```unknown
These scripts refer to the different stages of developing an application:

* **dev** - Start Elysia in development mode with auto-reload on code change.
* **build** - Build the application for production usage.
* **start** - Start an Elysia production server.

Make sure to create `tsconfig.json`
```

---

## Integration with Tanstack Start

**URL:** https://elysiajs.com/integrations/tanstack-start.md

**Contents:**
  - pnpm
- Eden
- Loader Data
- React Query

---
url: 'https://elysiajs.com/integrations/tanstack-start.md'
---

Elysia can runs inside Tanstack Start server routes.

1. Create **src/routes/api.$.ts**
2. Define an Elysia server
3. Export Elysia handler in **server.handlers**

Elysia should now be running on **/api**.

We may add additional methods to **server.handlers** to support other HTTP methods as need.

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.

We can add [Eden](/eden/overview.html) for **end-to-end type safety** similar to tRPC.

Notice that we use **createIsomorphicFn** to create a separate Eden Treaty instance for both server and client.

1. On server, Elysia is called directly without HTTP overhead.
2. On client, we call Elysia server through HTTP.

On React component, we can use `getTreaty` to call Elysia server with type safety.

Tanstack Start support **Loader** to fetch data before rendering the component.

Calling Elysia is a loader will be executed on server side during SSR, and doesn't have HTTP overhead.

Eden Treaty will ensure type safety on both server and client.

We can also use React Query to interact with Elysia server on client.

This can works with any React Query features like caching, pagination, infinite query, etc.

Please visit [Tanstack Start Documentation](https://tanstack.com/start) for more information about Tanstack Start.

**Examples:**

Example 1 (unknown):
```unknown
:::

Elysia should now be running on **/api**.

We may add additional methods to **server.handlers** to support other HTTP methods as need.

### pnpm

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.
```

Example 2 (unknown):
```unknown
## Eden

We can add [Eden](/eden/overview.html) for **end-to-end type safety** similar to tRPC.

::: code-group
```

Example 3 (unknown):
```unknown
:::

Notice that we use **createIsomorphicFn** to create a separate Eden Treaty instance for both server and client.

1. On server, Elysia is called directly without HTTP overhead.
2. On client, we call Elysia server through HTTP.

On React component, we can use `getTreaty` to call Elysia server with type safety.

## Loader Data

Tanstack Start support **Loader** to fetch data before rendering the component.

::: code-group
```

Example 4 (unknown):
```unknown
:::

Calling Elysia is a loader will be executed on server side during SSR, and doesn't have HTTP overhead.

Eden Treaty will ensure type safety on both server and client.

## React Query

We can also use React Query to interact with Elysia server on client.

::: code-group
```

---

## React Email

**URL:** https://elysiajs.com/integrations/react-email.md

**Contents:**
- Installation
  - TypeScript
- Your first email
- Preview your email
- Sending email

---
url: 'https://elysiajs.com/integrations/react-email.md'
---

React Email is a library that allows you to use React components to create emails.

As Elysia is using Bun as runtime environment, we can directly write a React Email component and import the JSX directly to our code to send emails.

To install React Email, run the following command:

Then add this script to `package.json`:

We recommend adding email templates into the `src/emails` directory as we can directly import the JSX files.

If you are using TypeScript, you may need to add the following to your `tsconfig.json`:

Create file `src/emails/otp.tsx` with the following code:

You may notice that we are using `@react-email/components` to create the email template.

This library provides a set of components including **styling with Tailwind** that are compatible with email clients like Gmail, Outlook, etc.

We also added a `PreviewProps` to the `OTPEmail` function. This is only apply when previewing the email on our playground.

To preview your email, run the following command:

This will open a browser window with the preview of your email.

![React Email playground showing an OTP email we have just written](/recipe/react-email/email-preview.webp)

To send an email, we can use `react-dom/server` to render the the email then submit using a preferred provider:

::: tip
Notice that we can directly import the email component out of the box thanks to Bun
:::

You may see all of the available integration with React Email in the [React Email Integration](https://react.email/docs/integrations/overview), and learn more about React Email in [React Email documentation](https://react.email/docs)

**Examples:**

Example 1 (bash):
```bash
bun add -d react-email
bun add @react-email/components react react-dom
```

Example 2 (json):
```json
{
  "scripts": {
    "email": "email dev --dir src/emails"
  }
}
```

Example 3 (json):
```json
{
  "compilerOptions": {
	"jsx": "react"
  }
}
```

Example 4 (tsx):
```tsx
import * as React from 'react'
import { Tailwind, Section, Text } from '@react-email/components'

export default function OTPEmail({ otp }: { otp: number }) {
    return (
        <Tailwind>
            <Section className="flex justify-center items-center w-full min-h-screen font-sans">
                <Section className="flex flex-col items-center w-76 rounded-2xl px-6 py-1 bg-gray-50">
                    <Text className="text-xs font-medium text-violet-500">
                        Verify your Email Address
                    </Text>
                    <Text className="text-gray-500 my-0">
                        Use the following code to verify your email address
                    </Text>
                    <Text className="text-5xl font-bold pt-2">{otp}</Text>
                    <Text className="text-gray-400 font-light text-xs pb-4">
                        This code is valid for 10 minutes
                    </Text>
                    <Text className="text-gray-600 text-xs">
                        Thank you for joining us
                    </Text>
                </Section>
            </Section>
        </Tailwind>
    )
}

OTPEmail.PreviewProps = {
    otp: 123456
}
```

---

## Prisma

**URL:** https://elysiajs.com/integrations/prisma.md

**Contents:**
  - Prismabox
  - How it works:
- Installation
- Prisma schema
- Using generated models

---
url: 'https://elysiajs.com/integrations/prisma.md'
---

[Prisma](https://prisma.io) is an ORM that allows us to interact with databases in a type-safe manner.

It provides a way to define your database schema using a Prisma schema file, and then generates TypeScript types based on that schema.

[Prismabox](https://github.com/m1212e/prismabox) is a library that generate TypeBox or Elysia validation models from Prisma schema.

We can use Prismabox to convert Prisma schema into Elysia validation models, which can then be used to ensure type validation in Elysia.

1. Define your database schema in Prisma Schema.
2. Add `prismabox` generator to generate Elysia schema.
3. Use the converted Elysia validation models to ensure type validation.
4. OpenAPI schema is generated from Elysia validation models.
5. Add [Eden Treaty](/eden/overview) to add type-safety to your frontend.

To install Prisma, run the following command:

Assuming you already have a `prisma/schema.prisma`.

We can add a `prismabox` generator to the Prisma schema file as follows:

This will generate Elysia validation models in the `generated/prismabox` directory.

Each model will have its own file, and the models will be named based on the Prisma model names.

* `User` model will be generated to `generated/prismabox/User.ts`
* `Post` model will be generated to `generated/prismabox/Post.ts`

Then we can import the generated models in our Elysia application:

This allows us to reuse the database schema in Elysia validation models.

For more information, please refer to the [Prisma](https://prisma.io), and [Prismabox](https://github.com/m1212e/prismabox) documentation.

**Examples:**

Example 1 (unknown):
```unknown
* ——————————————— *
                                                    |                 |
                                               | -> |  Documentation  |
* ————————— *             * ———————— * OpenAPI |    |                 |
|           |  prismabox  |          | ——————— |    * ——————————————— *
|  Prisma   | —————————-> |  Elysia  |
|           |             |          | ——————— |    * ——————————————— *
* ————————— *             * ———————— *   Eden  |    |                 |
                                               | -> |  Frontend Code  |
												    |                 |
												    * ——————————————— *
```

Example 2 (bash):
```bash
bun add @prisma/client prismabox && \
bun add -d prisma
```

Example 3 (unknown):
```unknown
:::

This will generate Elysia validation models in the `generated/prismabox` directory.

Each model will have its own file, and the models will be named based on the Prisma model names.

For example:

* `User` model will be generated to `generated/prismabox/User.ts`
* `Post` model will be generated to `generated/prismabox/Post.ts`

## Using generated models

Then we can import the generated models in our Elysia application:

::: code-group
```

---

## Cloudflare Worker Experimental

**URL:** https://elysiajs.com/integrations/cloudflare-worker.md

**Contents:**
  - pnpm
- Limitations
- Static File
- Binding
- AoT compilation

---
url: 'https://elysiajs.com/integrations/cloudflare-worker.md'
---

Elysia now supports Cloudflare Worker with an **experimental** Cloudflare Worker Adapter.

1. You will need [Wrangler](https://developers.cloudflare.com/workers/wrangler/install-and-update) to setup, and start a development server.

2. Then add Cloudflare Adapter to your Elysia app, and make sure to call `.compile()` before exporting the app.

3. Make sure to have `compatibility_date` set to at least `2025-06-01` in your wrangler config

4. Now you can start the development server with:

This should start a development server at `http://localhost:8787`

You don't need a `nodejs_compat` flag as Elysia doesn't use any Node.js built-in modules (or the ones we use don't support Cloudflare Worker yet).

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.

Here are some known limitations of using Elysia on Cloudflare Worker:

1. `Elysia.file`, and [Static Plugin](/plugins/static) doesn't work [due to the lack of `fs` module](https://developers.cloudflare.com/workers/runtime-apis/nodejs/#supported-nodejs-apis), see [static file](#static-file) section for alternative
2. [OpenAPI Type Gen](/blog/openapi-type-gen) doesn't work [due to the lack of `fs` module](https://developers.cloudflare.com/workers/runtime-apis/nodejs/#supported-nodejs-apis)
3. You can't define [**Response** before server start](https://x.com/saltyAom/status/1966602691754553832) or use plugin that does so
4. You can't inline a value due to 3.

[Static Plugin](/plugins/static) doesn't work, but you can still serve static files with [Cloudflare's built-in static file serving](https://developers.cloudflare.com/workers/static-assets/).

Add the following to your wrangler config:

Create a `public` folder and place your static files in it.

For example, if you have a folder structure like this:

Then you should be able to access your static file from the following path:

* **http://localhost:8787/kyuukurarin.mp4**
* **http://localhost:8787/static/mika.webp**

You can use a Cloudflare Workers binding by importing env from `cloudflare:workers`.

See [Cloudflare Workers: Binding](https://developers.cloudflare.com/workers/runtime-apis/bindings/#importing-env-as-a-global) for more information about binding.

Previously, to use Elysia on Cloudflare Worker, you have to pass `aot: false` to the Elysia constructor.

This is no longer necessary as [Cloudflare now supports Function compilation during startup](https://developers.cloudflare.com/workers/configuration/compatibility-flags/#enable-eval-during-startup).

As of Elysia 1.4.7, you can now use Ahead of Time Compilation with Cloudflare Worker, and drop the `aot: false` flag.

Otherwise, you can still use `aot: false` if you don't want Ahead of Time Compilation but we recommend you to use it for better performance, and accurate plugin encapsulation.

**Examples:**

Example 1 (bash):
```bash
wrangler init elysia-on-cloudflare
```

Example 2 (ts):
```ts
import { Elysia } from 'elysia'
import { CloudflareAdapter } from 'elysia/adapter/cloudflare-worker' // [!code ++]

export default new Elysia({
	adapter: CloudflareAdapter // [!code ++]
})
	.get('/', () => 'Hello Cloudflare Worker!')
	// This is required to make Elysia work on Cloudflare Worker
	.compile() // [!code ++]
```

Example 3 (unknown):
```unknown
:::

4. Now you can start the development server with:
```

Example 4 (unknown):
```unknown
This should start a development server at `http://localhost:8787`

You don't need a `nodejs_compat` flag as Elysia doesn't use any Node.js built-in modules (or the ones we use don't support Cloudflare Worker yet).

### pnpm

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.
```

---

## Integration with Next.js

**URL:** https://elysiajs.com/integrations/nextjs.md

**Contents:**
  - pnpm
- Prefix
- Eden
- React Query

---
url: 'https://elysiajs.com/integrations/nextjs.md'
---

With Next.js App Router, we can run Elysia on Next.js routes.

1. Create **app/api/\[\[...slugs]]/route.ts**
2. define an Elysia server
3. Export **Elysia.fetch** name of HTTP methods you want to use

Elysia will work normally because of WinterTC compliance.

You can treat the Elysia server as a normal Next.js API route.

With this approach, you can have co-location of both frontend and backend in a single repository and have [End-to-end type safety with Eden](/eden/overview) with both client-side and server action

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.

Because our Elysia server is not in the root directory of the app router, you need to annotate the prefix to the Elysia server.

For example, if you place Elysia server in **app/user/\[\[...slugs]]/route.ts**, you need to annotate prefix as **/user** to Elysia server.

This will ensure that Elysia routing will work properly in any location you place it.

We can add [Eden](/eden/overview) for **end-to-end type safety** similar to tRPC.

In this approach, we will use isomorphic fetch pattern to allow Elysia to:

1. On Server: directly calls Elysia without going through the network layer
2. On Client: calls Elysia through the network layer

To start, we need to do the following steps:

1. Export Elysia instance

2. Create a Treaty client with isomorphic approach

It's important that you should use `typeof process` instead of `typeof window` because `window` is not defined during build time, causing hydration error.

3. Use the client in both server and client components

This allows you to have type safety from the frontend to the backend with minimal effort and works with both server, client components and with Incremental Static Regeneration (ISR).

We can also use React Query to interact with Elysia server on client.

This can works with any React Query features like caching, pagination, infinite query, etc.

Please refer to [Next.js Route Handlers](https://nextjs.org/docs/app/building-your-application/routing/route-handlers#static-route-handlers) for more information.

**Examples:**

Example 1 (unknown):
```unknown
:::

Elysia will work normally because of WinterTC compliance.

You can treat the Elysia server as a normal Next.js API route.

With this approach, you can have co-location of both frontend and backend in a single repository and have [End-to-end type safety with Eden](/eden/overview) with both client-side and server action

### pnpm

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.
```

Example 2 (unknown):
```unknown
## Prefix

Because our Elysia server is not in the root directory of the app router, you need to annotate the prefix to the Elysia server.

For example, if you place Elysia server in **app/user/\[\[...slugs]]/route.ts**, you need to annotate prefix as **/user** to Elysia server.

::: code-group
```

Example 3 (unknown):
```unknown
:::

This will ensure that Elysia routing will work properly in any location you place it.

## Eden

We can add [Eden](/eden/overview) for **end-to-end type safety** similar to tRPC.

In this approach, we will use isomorphic fetch pattern to allow Elysia to:

1. On Server: directly calls Elysia without going through the network layer
2. On Client: calls Elysia through the network layer

To start, we need to do the following steps:

1. Export Elysia instance

::: code-group
```

Example 4 (unknown):
```unknown
:::

2. Create a Treaty client with isomorphic approach

::: code-group
```

---

## Deploy Elysia on Vercel

**URL:** https://elysiajs.com/integrations/vercel.md

**Contents:**
  - pnpm
  - Using Node.js
  - Using Bun
- If this doesn't work

---
url: 'https://elysiajs.com/integrations/vercel.md'
---

Elysia can deploys on Vercel with zero configuration using either Bun or Node runtime.

1. In **src/index.ts**, create or import an existing Elysia server
2. Export the Elysia server as default export

3. Develop locally with Vercel CLI

That's it. Your Elysia app is now running on Vercel.

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.

To deploy with Node.js, make sure to set `type: module` in your `package.json`

To deploy with Bun, make sure to set the runtime to Bun in your `vercel.json`

Vercel has zero configuration for Elysia, for additional configuration, please refers to [Vercel documentation](https://vercel.com/docs/frameworks/backend/elysia)

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia, t } from 'elysia'

export default new Elysia() // [!code ++]
    .get('/', () => 'Hello Vercel Function')
    .post('/', ({ body }) => body, {
        body: t.Object({
            name: t.String()
        })
    })
```

Example 2 (bash):
```bash
pnpm add @sinclair/typebox openapi-types
```

Example 3 (unknown):
```unknown
:::

### Using Bun

To deploy with Bun, make sure to set the runtime to Bun in your `vercel.json`

::: code-group
```

---

## Cheat Sheet

**URL:** https://elysiajs.com/integrations/cheat-sheet.md

**Contents:**
- Hello World
- Custom HTTP Method
- Path Parameter
- Return JSON
- Return a file
- Header and status
- Group
- Schema
- File upload
- Lifecycle Hook

---
url: 'https://elysiajs.com/integrations/cheat-sheet.md'
---

Here are a quick overview for a common Elysia patterns

Define route using custom HTTP methods/verbs

See [Route](/essential/route.html#custom-method)

Using dynamic path parameter

See [Path](/essential/route.html#path-type)

Elysia converts response to JSON automatically

See [Handler](/essential/handler.html)

A file can be return in as formdata response

The response must be a 1-level deep object

Set a custom header and a status code

See [Handler](/essential/handler.html)

Define a prefix once for sub routes

See [Group](/essential/route.html#group)

Enforce a data type of a route

See [Validation](/essential/validation)

See [Validation#file](/essential/validation#file)

Intercept an Elysia event in order

See [Lifecycle](/essential/life-cycle.html)

Enforce a data type of sub routes

See [Scope](/essential/plugin.html#scope)

Add custom variable to route context

See [Context](/essential/handler.html#context)

See [Handler](/essential/handler.html#redirect)

Create a separate instance

See [Plugin](/essential/plugin)

Create a realtime connection using Web Socket

See [Web Socket](/patterns/websocket)

Create interactive documentation using Scalar (or optionally Swagger)

See [openapi](/plugins/openapi.html)

Write a unit test of your Elysia app

See [Unit Test](/patterns/unit-test)

Create custom logic for parsing body

See [Parse](/essential/life-cycle.html#parse)

Create a custom GraphQL server using GraphQL Yoga or Apollo

See [GraphQL Yoga](/plugins/graphql-yoga)

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
    .get('/', () => 'Hello World')
    .listen(3000)
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
    .get('/hi', () => 'Hi')
    .post('/hi', () => 'From Post')
    .put('/hi', () => 'From Put')
    .route('M-SEARCH', '/hi', () => 'Custom Method')
    .listen(3000)
```

Example 3 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
    .get('/id/:id', ({ params: { id } }) => id)
    .get('/rest/*', () => 'Rest')
    .listen(3000)
```

Example 4 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
    .get('/json', () => {
        return {
            hello: 'Elysia'
        }
    })
    .listen(3000)
```

---

## Integration with Deno

**URL:** https://elysiajs.com/integrations/deno.md

**Contents:**
  - Change Port Number
  - pnpm

---
url: 'https://elysiajs.com/integrations/deno.md'
---

Elysia is built on top of Web Standard Request/Response, allowing us to run Elysia with Deno.serve directly.

To run Elysia on Deno, wrap `Elysia.fetch` in `Deno.serve`

Then you can run the server with `deno serve`:

This is all you need to run Elysia on Deno.

You can specify the port number in `Deno.serve`.

If you use pnpm, [pnpm doesn't auto install peer dependencies by default](https://github.com/orgs/pnpm/discussions/3995#discussioncomment-1893230) forcing you to install additional dependencies manually.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'

const app = new Elysia()
	.get('/', () => 'Hello Elysia')
	.listen(3000) // [!code --]

Deno.serve(app.fetch) // [!code ++]
```

Example 2 (bash):
```bash
deno serve --watch src/index.ts
```

Example 3 (ts):
```ts
Deno.serve(app.fetch) // [!code --]
Deno.serve({ port:8787 }, app.fetch) // [!code ++]
```

Example 4 (bash):
```bash
pnpm add @sinclair/typebox openapi-types
```

---
