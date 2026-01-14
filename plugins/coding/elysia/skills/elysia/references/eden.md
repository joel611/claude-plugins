# Elysia - Eden

**Pages:** 11

---

## Eden Installation

**URL:** https://elysiajs.com/eden/installation.md

**Contents:**
- Gotcha
  - Type Strict
  - Unmatch Elysia version
  - TypeScript version
  - Method Chaining
  - Type Definitions
  - Path alias (monorepo)
    - Namespace

---
url: 'https://elysiajs.com/eden/installation.md'
---

Start by installing Eden on your frontend:

::: tip
Eden needs Elysia to infer utilities type.

Make sure to install Elysia with the version matching on the server.
:::

First, export your existing Elysia server type:

Then consume the Elysia API on client side:

Sometimes, Eden may not infer types from Elysia correctly, the following are the most common workarounds to fix Eden type inference.

Make sure to enable strict mode in **tsconfig.json**

Eden depends on Elysia class to import Elysia instance and infer types correctly.

Make sure that both client and server have the matching Elysia version.

You can check it with [`npm why`](https://docs.npmjs.com/cli/v10/commands/npm-explain) command:

And output should contain only one elysia version on top-level:

Elysia uses newer features and syntax of TypeScript to infer types in the most performant way. Features like Const Generic and Template Literal are heavily used.

Make sure your client has a **minimum TypeScript version if >= 5.0**

To make Eden work, Elysia must use **method chaining**

Elysia's type system is complex, methods usually introduce a new type to the instance.

Using method chaining will help save that new type reference.

Using this, **state** now returns a new **ElysiaInstance** type, introducing **build** into store replacing the current one.

Without method chaining, Elysia doesn't save the new type when introduced, leading to no type inference.

If you are using a Bun specific feature, like `Bun.file` or similar API and return it from a handler, you may need to install Bun type definitions to the client as well.

If you are using path alias in your monorepo, make sure that frontend is able to resolve the path as same as backend.

::: tip
Setting up path alias in monorepo is a bit tricky, you can fork our example template: [Kozeki Template](https://github.com/SaltyAom/kozeki-template) and modify it to your needs.
:::

For example, if you have the following path alias for your backend in **tsconfig.json**:

And your backend code is like this:

You **must** make sure that your frontend code is able to resolve the same path alias. Otherwise, type inference will be resolved as any.

To fix this, you must make sure that path alias is resolved to the same file in both frontend and backend.

So, you must change the path alias in **tsconfig.json** to:

If configured correctly, you should be able to resolve the same module in both frontend and backend.

We recommended adding a **namespace** prefix for each module in your monorepo to avoid any confusion and conflict that may happen.

Then, you can import the module like this:

We recommend creating a **single tsconfig.json** that defines a `baseUrl` as the root of your repo, provide a path according to the module location, and create a **tsconfig.json** for each module that inherits the root **tsconfig.json** which has the path alias.

You may find a working example of in this [path alias example repo](https://github.com/SaltyAom/elysia-monorepo-path-alias) or [Kozeki Template](https://github.com/SaltyAom/kozeki-template).

**Examples:**

Example 1 (bash):
```bash
bun add @elysiajs/eden
bun add -d elysia
```

Example 2 (typescript):
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

export type App = typeof app // [!code ++]
```

Example 3 (unknown):
```unknown
## Gotcha

Sometimes, Eden may not infer types from Elysia correctly, the following are the most common workarounds to fix Eden type inference.

### Type Strict

Make sure to enable strict mode in **tsconfig.json**
```

Example 4 (unknown):
```unknown
### Unmatch Elysia version

Eden depends on Elysia class to import Elysia instance and infer types correctly.

Make sure that both client and server have the matching Elysia version.

You can check it with [`npm why`](https://docs.npmjs.com/cli/v10/commands/npm-explain) command:
```

---

## Eden Test

**URL:** https://elysiajs.com/eden/test.md

**Contents:**
- Setup

---
url: 'https://elysiajs.com/eden/test.md'
---

Using Eden, we can create an integration test with end-to-end type safety and auto-completion.

We can use [Bun test](https://bun.sh/guides/test/watch-mode) to create tests.

Create **test/index.test.ts** in the root of project directory with the following:

Then we can perform tests by running **bun test**

This allows us to perform integration tests programmatically instead of manual fetch while supporting type checking automatically.

**Examples:**

Example 1 (typescript):
```typescript
// test/index.test.ts
import { describe, expect, it } from 'bun:test'

import { edenTreaty } from '@elysiajs/eden'

const app = new Elysia()
    .get('/', () => 'hi')
    .listen(3000)

const api = edenTreaty<typeof app>('http://localhost:3000')

describe('Elysia', () => {
    it('return a response', async () => {
        const { data } = await api.get()

        expect(data).toBe('hi')
    })
})
```

---

## Eden Treaty

**URL:** https://elysiajs.com/eden/treaty/overview.md

**Contents:**
- Tree like syntax
- Dynamic path

---
url: 'https://elysiajs.com/eden/treaty/overview.md'
---

Eden Treaty is an object representation to interact with a server and features type safety, auto-completion, and error handling.

To use Eden Treaty, first export your existing Elysia server type:

Then import the server type and consume the Elysia API on the client:

HTTP Path is a resource indicator for a file system tree.

File system consists of multiple levels of folders, for example:

* /documents/elysia
* /documents/kalpas
* /documents/kelvin

Each level is separated by **/** (slash) and a name.

However in JavaScript, instead of using **"/"** (slash) we use **"."** (dot) to access deeper resources.

Eden Treaty turns an Elysia server into a tree-like file system that can be accessed in the JavaScript frontend instead.

| Path         | Treaty       |
| ------------ | ------------ |
| /            |              |
| /hi          | .hi          |
| /deep/nested | .deep.nested |

Combined with the HTTP method, we can interact with the Elysia server.

| Path         | Method | Treaty              |
| ------------ | ------ | ------------------- |
| /            | GET    | .get()              |
| /hi          | GET    | .hi.get()           |
| /deep/nested | GET    | .deep.nested.get()  |
| /deep/nested | POST   | .deep.nested.post() |

However, dynamic path parameters cannot be expressed using notation. If they are fully replaced, we don't know what the parameter name is supposed to be.

To handle this, we can specify a dynamic path using a function to provide a key value instead.

| Path            | Treaty                           |
| --------------- | -------------------------------- |
| /item           | .item                            |
| /item/:name     | .item({ name: 'Skadi' })         |
| /item/:name/id  | .item({ name: 'Skadi' }).id      |

**Examples:**

Example 1 (typescript):
```typescript
// server.ts
import { Elysia, t } from 'elysia'

const app = new Elysia()
    .get('/hi', () => 'Hi Elysia')
    .get('/id/:id', ({ params: { id } }) => id)
    .post('/mirror', ({ body }) => body, {
        body: t.Object({
            id: t.Number(),
            name: t.String()
        })
    })
    .listen(3000)

export type App = typeof app // [!code ++]
```

Example 2 (unknown):
```unknown
## Tree like syntax

HTTP Path is a resource indicator for a file system tree.

File system consists of multiple levels of folders, for example:

* /documents/elysia
* /documents/kalpas
* /documents/kelvin

Each level is separated by **/** (slash) and a name.

However in JavaScript, instead of using **"/"** (slash) we use **"."** (dot) to access deeper resources.

Eden Treaty turns an Elysia server into a tree-like file system that can be accessed in the JavaScript frontend instead.

| Path         | Treaty       |
| ------------ | ------------ |
| /            |              |
| /hi          | .hi          |
| /deep/nested | .deep.nested |

Combined with the HTTP method, we can interact with the Elysia server.

| Path         | Method | Treaty              |
| ------------ | ------ | ------------------- |
| /            | GET    | .get()              |
| /hi          | GET    | .hi.get()           |
| /deep/nested | GET    | .deep.nested.get()  |
| /deep/nested | POST   | .deep.nested.post() |

## Dynamic path

However, dynamic path parameters cannot be expressed using notation. If they are fully replaced, we don't know what the parameter name is supposed to be.
```

Example 3 (unknown):
```unknown
To handle this, we can specify a dynamic path using a function to provide a key value instead.
```

---

## Response

**URL:** https://elysiajs.com/eden/treaty/response.md

**Contents:**
- Stream response
- Utility type

---
url: 'https://elysiajs.com/eden/treaty/response.md'
---

Once the fetch method is called, Eden Treaty returns a `Promise` containing an object with the following properties:

* data - returned value of the response (2xx)
* error - returned value from the response (>= 3xx)
* response `Response` - Web Standard Response class
* status `number` - HTTP status code
* headers `FetchRequestInit['headers']` - response headers

Once returned, you must provide error handling to ensure that the response data value is unwrapped, otherwise the value will be nullable. Elysia provides a `error()` helper function to handle the error, and Eden will provide type narrowing for the error value.

By default, Elysia infers `error` and `response` types to TypeScript automatically, and Eden will be providing auto-completion and type narrowing for accurate behavior.

::: tip
If the server responds with an HTTP status >= 300, then the value will always be `null`, and `error` will have a returned value instead.

Otherwise, response will be passed to `data`.
:::

Eden will interpret a stream response or [Server-Sent Events](/essential/handler.html#server-sent-events-sse) as `AsyncGenerator` allowing us to use `for await` loop to consume the stream.

Eden Treaty provides a utility type `Treaty.Data<T>` and `Treaty.Error<T>` to extract the `data` and `error` type from the response.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia, t } from 'elysia'
import { treaty } from '@elysiajs/eden'

const app = new Elysia()
    .post('/user', ({ body: { name }, status }) => {
        if(name === 'Otto') return status(400)

        return name
    }, {
        body: t.Object({
            name: t.String()
        })
    })
    .listen(3000)

const api = treaty<typeof app>('localhost:3000')

const submit = async (name: string) => {
    const { data, error } = await api.user.post({
        name
    })

    // type: string | null
    console.log(data)

    if (error)
        switch(error.status) {
            case 400:
                // Error type will be narrow down
                throw error.value

            default:
                throw error.value
        }

    // Once the error is handled, type will be unwrapped
    // type: string
    return data
}
```

Example 2 (unknown):
```unknown
:::

## Utility type

Eden Treaty provides a utility type `Treaty.Data<T>` and `Treaty.Error<T>` to extract the `data` and `error` type from the response.
```

---

## Parameters

**URL:** https://elysiajs.com/eden/treaty/parameters.md

**Contents:**
- Empty body
- Fetch parameters
- File Upload

---
url: 'https://elysiajs.com/eden/treaty/parameters.md'
---

We need to send a payload to server eventually.

To handle this, Eden Treaty's methods accept 2 parameters to send data to server.

Both parameters are type safe and will be guided by TypeScript automatically:

1. body
2. additional parameters
   * query
   * headers
   * fetch

Unless if the method doesn't accept body, then body will be omitted and left with single parameter only.

If the method **"GET"** or **"HEAD"**:

1. Additional parameters
   * query
   * headers
   * fetch

If body is optional or not need but query or headers is required, you may pass the body as `null` or `undefined` instead.

Eden Treaty is a fetch wrapper, we may add any valid [Fetch](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch) parameters to Eden by passing it to `$fetch`:

We may either pass one of the following to attach file(s):

* **File**
* **File\[]**
* **FileList**
* **Blob**

Attaching a file will results **content-type** to be **multipart/form-data**

Suppose we have the server as the following:

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia, t } from 'elysia'
import { treaty } from '@elysiajs/eden'

const app = new Elysia()
    .post('/user', ({ body }) => body, {
        body: t.Object({
            name: t.String()
        })
    })
    .listen(3000)

const api = treaty<typeof app>('localhost:3000')

// ✅ works
api.user.post({
    name: 'Elysia'
})

// ✅ also works
api.user.post({
    name: 'Elysia'
}, {
    // This is optional as not specified in schema
    headers: {
        authorization: 'Bearer 12345'
    },
    query: {
        id: 2
    }
})
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'
import { treaty } from '@elysiajs/eden'

const app = new Elysia()
    .get('/hello', () => 'hi')
    .listen(3000)

const api = treaty<typeof app>('localhost:3000')

// ✅ works
api.hello.get({
    // This is optional as not specified in schema
    headers: {
        hello: 'world'
    }
})
```

Example 3 (typescript):
```typescript
import { Elysia, t } from 'elysia'
import { treaty } from '@elysiajs/eden'

const app = new Elysia()
    .post('/user', () => 'hi', {
        query: t.Object({
            name: t.String()
        })
    })
    .listen(3000)

const api = treaty<typeof app>('localhost:3000')

api.user.post(null, {
    query: {
        name: 'Ely'
    }
})
```

Example 4 (typescript):
```typescript
import { Elysia, t } from 'elysia'
import { treaty } from '@elysiajs/eden'

const app = new Elysia()
    .get('/hello', () => 'hi')
    .listen(3000)

const api = treaty<typeof app>('localhost:3000')

const controller = new AbortController()

const cancelRequest = setTimeout(() => {
    controller.abort()
}, 5000)

await api.hello.get({
    fetch: {
        signal: controller.signal
    }
})

clearTimeout(cancelRequest)
```

---

## Eden Fetch

**URL:** https://elysiajs.com/eden/fetch.md

**Contents:**
- Error Handling
- When should I use Eden Fetch over Eden Treaty

---
url: 'https://elysiajs.com/eden/fetch.md'
---

A fetch-like alternative to Eden Treaty.

With Eden Fetch, you can interact with Elysia server in a type-safe manner using Fetch API.

First export your existing Elysia server type:

Then import the server type, and consume the Elysia API on client:

You can handle errors the same way as Eden Treaty:

Unlike Elysia < 1.0, Eden Fetch is not faster than Eden Treaty anymore.

The preference is base on you and your team agreement, however we recommend to use [Eden Treaty](/eden/treaty/overview) instead.

Using Eden Treaty requires a lot of down-level iteration to map all possible types in a single go, while in contrast, Eden Fetch can be lazily executed until you pick a route.

With complex types and a lot of server routes, using Eden Treaty on a low-end development device can lead to slow type inference and auto-completion.

But as Elysia has tweaked and optimized a lot of types and inference, Eden Treaty can perform very well in the considerable amount of routes.

If your single process contains **more than 500 routes**, and you need to consume all of the routes **in a single frontend codebase**, then you might want to use Eden Fetch as it has a significantly better TypeScript performance than Eden Treaty.

**Examples:**

Example 1 (typescript):
```typescript
// server.ts
import { Elysia, t } from 'elysia'

const app = new Elysia()
    .get('/hi', () => 'Hi Elysia')
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

Example 2 (typescript):
```typescript
import { edenFetch } from '@elysiajs/eden'
import type { App } from './server'

const fetch = edenFetch<App>('http://localhost:3000')

// response type: 'Hi Elysia'
const pong = await fetch('/hi', {})

// response type: 1895
const id = await fetch('/id/:id', {
    params: {
        id: '1895'
    }
})

// response type: { id: 1895, name: 'Skadi' }
const nendoroid = await fetch('/mirror', {
    method: 'POST',
    body: {
        id: 1895,
        name: 'Skadi'
    }
})
```

Example 3 (typescript):
```typescript
import { edenFetch } from '@elysiajs/eden'
import type { App } from './server'

const fetch = edenFetch<App>('http://localhost:3000')

// response type: { id: 1895, name: 'Skadi' }
const { data: nendoroid, error } = await fetch('/mirror', {
    method: 'POST',
    body: {
        id: 1895,
        name: 'Skadi'
    }
})

if(error) {
    switch(error.status) {
        case 400:
        case 401:
            throw error.value
            break

        case 500:
        case 502:
            throw error.value
            break

        default:
            throw error.value
            break
    }
}

const { id, name } = nendoroid
```

---

## Unit Test

**URL:** https://elysiajs.com/eden/treaty/unit-test.md

**Contents:**
- Type safety test

---
url: 'https://elysiajs.com/eden/treaty/unit-test.md'
---

According to [Eden Treaty config](/eden/treaty/config.html#urlorinstance) and [Unit Test](/patterns/unit-test), we may pass an Elysia instance to Eden Treaty directly to interact with Elysia server directly without sending a network request.

We may use this pattern to create a unit test with end-to-end type safety and type-level test all at once.

To perform a type safety test, simply run **tsc** on test folders.

This is useful to ensure type integrity for both client and server, especially during migrations.

**Examples:**

Example 1 (unknown):
```unknown
## Type safety test

To perform a type safety test, simply run **tsc** on test folders.
```

---

## End-to-End Type Safety&#x20;

**URL:** https://elysiajs.com/eden/overview.md

**Contents:**
- Eden
- Eden Treaty (Recommended)
- Eden Fetch

---
url: 'https://elysiajs.com/eden/overview.md'
---

Imagine you have a toy train set.

Each piece of the train track has to fit perfectly with the next one, like puzzle pieces.

End-to-end type safety is like making sure all the pieces of the track match up correctly so the train doesn't fall off or get stuck.

For a framework to have end-to-end type safety means you can connect client and server in a type-safe manner.

Elysia provides end-to-end type safety **without code generation** out of the box with an RPC-like connector, **Eden**

Other frameworks that support e2e type safety:

* tRPC
* Remix
* SvelteKit
* Nuxt
* TS-Rest

Elysia allows you to change the type on the server and it will be instantly reflected on the client, helping with auto-completion and type-enforcement.

Eden is an RPC-like client to connect Elysia with **end-to-end type safety** using only TypeScript's type inference instead of code generation.

It allows you to sync client and server types effortlessly, weighing less than 2KB.

Eden consists of 2 modules:

1. Eden Treaty **(recommended)**: an improved RPC version of Eden Treaty
2. Eden Fetch: Fetch-like client with type safety

Below is an overview, use-case and comparison for each module.

Eden Treaty is an object-like representation of an Elysia server providing end-to-end type safety and a significantly improved developer experience.

With Eden Treaty we can interact with an Elysia server with full-type support and auto-completion, error handling with type narrowing, and create type-safe unit tests.

Example usage of Eden Treaty:

A fetch-like alternative to Eden Treaty for developers that prefers fetch syntax.

::: tip NOTE
Unlike Eden Treaty, Eden Fetch doesn't provide Web Socket implementation for Elysia server.
:::

**Examples:**

Example 1 (unknown):
```unknown
## Eden Fetch

A fetch-like alternative to Eden Treaty for developers that prefers fetch syntax.
```

---

## Eden Treaty Legacy

**URL:** https://elysiajs.com/eden/treaty/legacy.md

**Contents:**
- Anatomy
  - Path
  - Path parameters
  - Query
  - Fetch
- Error Handling
  - Error type based on status
- WebSocket
- File Upload

---
url: 'https://elysiajs.com/eden/treaty/legacy.md'
---

::: tip NOTE
This is a documentation for Eden Treaty 1 or (edenTreaty)

For a new project, we recommended starting with Eden Treaty 2 (treaty) instead.
:::

Eden Treaty is an object-like representation of an Elysia server.

Providing accessor like a normal object with type directly from the server, helping us to move faster, and make sure that nothing break

To use Eden Treaty, first export your existing Elysia server type:

Then import the server type, and consume the Elysia API on client:

::: tip
Eden Treaty is fully type-safe with auto-completion support.
:::

Eden Treaty will transform all existing paths to object-like representation, that can be described as:

Eden will transform `/` into `.` which can be called with a registered `method`, for example:

* **/path** -> .path
* **/nested/path** -> .nested.path

Path parameters will be mapped automatically by their name in the URL.

* **/id/:id** -> .id.`<anyThing>`
* eg: .id.hi
* eg: .id\['123']

::: tip
If a path doesn't support path parameters, TypeScript will show an error.
:::

You can append queries to path with `$query`:

Eden Treaty is a fetch wrapper, you can add any valid [Fetch](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch) parameters to Eden by passing it to `$fetch`:

Eden Treaty will return a value of `data` and `error` as a result, both fully typed.

Both **data**, and **error** will be typed as nullable until you can confirm their statuses with a type guard.

To put it simply, if fetch is successful, data will have a value and error will be null, and vice-versa.

::: tip
Error is wrapped with an `Error` with its value return from the server can be retrieve from `Error.value`
:::

Both Eden Treaty and Eden Fetch can narrow down an error type based on status code if you explicitly provided an error type in the Elysia server.

An on the client side:

Eden supports WebSocket using the same API as a normal route.

To start listening to real-time data, call the `.subscribe` method:

We can use [schema](/integrations/cheat-sheet#schema) to enforce type-safety on WebSockets, just like a normal route.

**Eden.subscribe** returns **EdenWebSocket** which extends the [WebSocket](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket/WebSocket) class with type-safety. The syntax is identical with the WebSocket

If more control is need, **EdenWebSocket.raw** can be accessed to interact with the native WebSocket API.

You may either pass one of the following to the field to attach file:

* **File**
* **FileList**
* **Blob**

Attaching a file will results **content-type** to be **multipart/form-data**

Suppose we have the server as the following:

We may use the client as follows:

**Examples:**

Example 1 (typescript):
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

export type App = typeof app // [!code ++]
```

Example 2 (typescript):
```typescript
// client.ts
import { edenTreaty } from '@elysiajs/eden'
import type { App } from './server' // [!code ++]

const app = edenTreaty<App>('http://localhost:')

// response type: 'Hi Elysia'
const { data: pong, error } = app.get()

// response type: 1895
const { data: id, error } = app.id['1895'].get()

// response type: { id: 1895, name: 'Skadi' }
const { data: nendoroid, error } = app.mirror.post({
    id: 1895,
    name: 'Skadi'
})
```

Example 3 (typescript):
```typescript
EdenTreaty.<1>.<2>.<n>.<method>({
    ...body,
    $query?: {},
    $fetch?: RequestInit
})
```

Example 4 (typescript):
```typescript
app.get({
    $query: {
        name: 'Eden',
        code: 'Gold'
    }
})
```

---

## WebSocket

**URL:** https://elysiajs.com/eden/treaty/websocket.md

**Contents:**
- Response

---
url: 'https://elysiajs.com/eden/treaty/websocket.md'
---

Eden Treaty supports WebSocket using `subscribe` method.

**.subscribe** accepts the same parameter as `get` and `head`.

**Eden.subscribe** returns **EdenWS** which extends the [WebSocket](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket/WebSocket) results in identical syntax.

If more control is need, **EdenWebSocket.raw** can be accessed to interact with the native WebSocket API.

---

## Config

**URL:** https://elysiajs.com/eden/treaty/config.md

**Contents:**
- urlOrInstance
  - URL Endpoint (string)
  - Elysia Instance
- Options
- Fetch
- Headers
  - Headers Object
  - Function
  - Array
- Headers Priority

---
url: 'https://elysiajs.com/eden/treaty/config.md'
---

Eden Treaty accepts 2 parameters:

* **urlOrInstance** - URL endpoint or Elysia instance
* **options** (optional) - Customize fetch behavior

Accept either URL endpoint as string or a literal Elysia instance.

Eden will change the behavior based on type as follows:

If URL endpoint is passed, Eden Treaty will use `fetch` or `config.fetcher` to create a network request to an Elysia instance.

You may or may not specify a protocol for URL endpoint.

Elysia will append the endpoints automatically as follows:

1. If protocol is specified, use the URL directly
2. If the URL is localhost and ENV is not production, use http
3. Otherwise use https

This also applies to Web Socket as well for determining between **ws://** or **wss://**.

If Elysia instance is passed, Eden Treaty will create a `Request` class and pass to `Elysia.handle` directly without creating a network request.

This allows us to interact with Elysia server directly without request overhead, or the need to start a server.

If an instance is passed, generic is not needed to be passed as Eden Treaty can infer the type from a parameter directly.

This pattern is recommended for performing unit tests, or creating a type-safe reverse proxy server or micro-services.

2nd optional parameter for Eden Treaty to customize fetch behavior, accepting parameters as follows:

* [fetch](#fetch) - add default parameters to fetch initialization (RequestInit)
* [headers](#headers) - define default headers
* [fetcher](#fetcher) - custom fetch function eg. Axios, unfetch
* [onRequest](#onrequest) - Intercept and modify fetch request before firing
* [onResponse](#onresponse) - Intercept and modify fetch's response

Default parameters append to 2nd parameters of fetch extends type of **Fetch.RequestInit**.

All parameters that are passed to fetch will be passed to fetcher, which is equivalent to:

Provide an additional default headers to fetch, a shorthand of `options.fetch.headers`.

All parameters that passed to fetch, will be passed to fetcher, which is an equivalent to:

headers may accept the following as parameters:

If object is passed, then it will be passed to fetch directly

You may specify headers as a function to return custom headers based on condition

You may return object to append its value to fetch headers.

headers function accepts 2 parameters:

* path `string` - path which will be sent to parameter
  * note: hostname will be **exclude** eg. (/user/griseo)
* options `RequestInit`: Parameters that passed through 2nd parameter of fetch

You may define a headers function as an array if multiple conditions are needed.

Eden Treaty will **run all functions** even if the value is already returned.

Eden Treaty will prioritize the order headers if duplicated as follows:

1. Inline method - Passed in method function directly
2. headers - Passed in `config.headers`

* If `config.headers` is array, parameters that come after will be prioritized

3. fetch - Passed in `config.fetch.headers`

For example, for the following example:

If inline function doesn't specified headers, then the result will be "**Bearer Aponia**" instead.

Provide a custom fetcher function instead of using an environment's default fetch.

It's recommended to replace fetch if you want to use other client other than fetch, eg. Axios, unfetch.

Intercept and modify fetch request before firing.

You may return object to append the value to **RequestInit**.

If value is returned, Eden Treaty will perform a **shallow merge** for returned value and `value.headers`.

**onRequest** accepts 2 parameters:

* path `string` - path which will be sent to parameter
  * note: hostname will be **exclude** eg. (/user/griseo)
* options `RequestInit`: Parameters that passed through 2nd parameter of fetch

You may define an onRequest function as an array if multiples conditions are need.

Eden Treaty will **run all functions** even if the value is already returned.

Intercept and modify fetch's response or return a new value.

**onRequest** accepts 1 parameter:

* response `Response` - Web Standard Response normally returned from `fetch`

You may define an onResponse function as an array if multiple conditions are need.

Unlike [headers](#headers) and [onRequest](#onrequest), Eden Treaty will loop through functions until a returned value is found or error thrown, the returned value will be use as a new response.

**Examples:**

Example 1 (typescript):
```typescript
import { treaty } from '@elysiajs/eden'
import type { App } from './server'

const api = treaty<App>('localhost:3000')
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'
import { treaty } from '@elysiajs/eden'

const app = new Elysia()
    .get('/hi', 'Hi Elysia')
    .listen(3000)

const api = treaty(app)
```

Example 3 (typescript):
```typescript
export type App = typeof app // [!code ++]
import { treaty } from '@elysiajs/eden'
// ---cut---
treaty<App>('localhost:3000', {
    fetch: {
        credentials: 'include'
    }
})
```

Example 4 (typescript):
```typescript
fetch('http://localhost:3000', {
    credentials: 'include'
})
```

---
