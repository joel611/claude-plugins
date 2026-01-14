# Elysia - Essential

**Pages:** 6

---

## Validation&#x20;

**URL:** https://elysiajs.com/essential/validation.md

**Contents:**
  - TypeBox
  - Standard Schema
- Schema type
- Guard
  - Guard Schema Type
  - **override (default)**
  - **standalone**&#x20;
- Body
    - Specs
  - File

---
url: 'https://elysiajs.com/essential/validation.md'
---

Elysia provides a schema to validate data out of the box to ensure that the data is in the correct format.

**Elysia.t** is a schema builder based on [TypeBox](https://github.com/sinclairzx81/typebox) that provides type-safety at runtime, compile-time, and OpenAPI schema generation from a single source of truth.

Elysia tailor TypeBox for server-side validation for a seamless experience.

Elysia also support [Standard Schema](https://github.com/standard-schema/standard-schema), allowing you to use your favorite validation library:

* Zod
* Valibot
* ArkType
* Effect Schema
* Yup
* Joi
* [and more](https://github.com/standard-schema/standard-schema)

To use Standard Schema, simply import the schema and provide it to the route handler.

You can use any validator together in the same handler without any issue.

Elysia supports declarative schemas with the following types:

These properties should be provided as the third argument of the route handler to validate the incoming request.

The response should be as follows:
| URL | Query | Params |
| --- | --------- | ------------ |
| /id/a | ❌ | ❌ |
| /id/1?name=Elysia | ✅ | ✅ |
| /id/1?alias=Elysia | ❌ | ✅ |
| /id/a?name=Elysia | ✅ | ❌ |
| /id/a?alias=Elysia | ❌ | ❌ |

When a schema is provided, the type will be inferred from the schema automatically and an OpenAPI type will be generated for an API documentation, eliminating the redundant task of providing the type manually.

Guard can be used to apply a schema to multiple handlers.

This code ensures that the query must have **name** with a string value for every handler after it. The response should be listed as follows:

The response should be listed as follows:

| Path          | Response |
| ------------- | -------- |
| /none         | hi       |
| /none?name=a  | hi       |
| /query        | error    |
| /query?name=a | a        |

If multiple global schemas are defined for the same property, the latest one will take precedence. If both local and global schemas are defined, the local one will take precedence.

Guard supports 2 types to define a validation.

Override schema if schema is collide with each others.

![Elysia run with default override guard showing schema gets override](/blog/elysia-13/schema-override.webp)

Separate collided schema, and runs both independently resulting in both being validated.

![Elysia run with standalone merging multiple guard together](/blog/elysia-13/schema-standalone.webp)

To define schema type of guard with `schema`:

An incoming [HTTP Message](https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages) is the data sent to the server. It can be in the form of JSON, form-data, or any other format.

The validation should be as follows:
| Body | Validation |
| --- | --------- |
| { name: 'Elysia' } | ✅ |
| { name: 1 } | ❌ |
| { alias: 'Elysia' } | ❌ |
| `undefined` | ❌ |

Elysia disables body-parser for **GET** and **HEAD** messages by default, following the specs of HTTP/1.1 [RFC2616](https://www.rfc-editor.org/rfc/rfc2616#section-4.3)

> If the request method does not include defined semantics for an entity-body, then the message-body SHOULD be ignored when handling the request.

Most browsers disable the attachment of the body by default for **GET** and **HEAD** methods.

Validate an incoming [HTTP Message](https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages) (or body).

These messages are additional messages for the web server to process.

The body is provided in the same way as the `body` in `fetch` API. The content type should be set accordingly to the defined body.

File is a special type of body that can be used to upload files.

By providing a file type, Elysia will automatically assume that the content-type is `multipart/form-data`.

If you're using Standard Schema, it's important that Elysia will not be able to validate content type automatically similar to `t.File`.

But Elysia export a `fileType` that can be used to validate file type by using magic number.

It's very important that you **should use** `fileType` to validate the file type as **most validator doesn't actually validate the file** correctly, like checking the content type the value of it which can lead to security vulnerability.

Query is the data sent through the URL. It can be in the form of `?key=value`.

Query must be provided in the form of an object.

The validation should be as follows:
| Query | Validation |
| ---- | --------- |
| /?name=Elysia | ✅ |
| /?name=1 | ✅ |
| /?alias=Elysia | ❌ |
| /?name=ElysiaJS\&alias=Elysia | ✅ |
| / | ❌ |

A query string is a part of the URL that starts with **?** and can contain one or more query parameters, which are key-value pairs used to convey additional information to the server, usually for customized behavior like filtering or searching.

![URL Object](/essential/url-object.svg)

Query is provided after the **?** in Fetch API.

When specifying query parameters, it's crucial to understand that all query parameter values must be represented as strings. This is due to how they are encoded and appended to the URL.

Elysia will coerce applicable schema on `query` to respective type automatically.

See [Elysia behavior](/patterns/type#elysia-behavior) for more information.

By default, Elysia treat query parameters as a single string even if specified multiple time.

To use array, we need to explicitly declare it as an array.

Once Elysia detect that a property is assignable to array, Elysia will coerce it to an array of the specified type.

By default, Elysia format query array with the following format:

This format is used by [nuqs](https://nuqs.47ng.com).

By using **,** as a delimiter, a property will be treated as array.

If a key is assigned multiple time, the key will be treated as an array.

This is similar to HTML form format when an input with the same name is specified multiple times.

Params or path parameters are the data sent through the URL path.

They can be in the form of `/key`.

Params must be provided in the form of an object.

The validation should be as follows:
| URL | Validation |
| --- | --------- |
| /id/1 | ✅ |
| /id/a | ❌ |

Path parameter (not to be confused with query string or query parameter).

**This field is usually not needed as Elysia can infer types from path parameters automatically**, unless there is a need for a specific value pattern, such as a numeric value or template literal pattern.

If a params schema is not provided, Elysia will automatically infer the type as a string.

Headers are the data sent through the request's header.

Unlike other types, headers have `additionalProperties` set to `true` by default.

This means that headers can have any key-value pair, but the value must match the schema.

HTTP headers let the client and the server pass additional information with an HTTP request or response, usually treated as metadata.

This field is usually used to enforce some specific header fields, for example, `Authorization`.

Headers are provided in the same way as the `body` in `fetch` API.

::: tip
Elysia will parse headers as lower-case keys only.

Please make sure that you are using lower-case field names when using header validation.
:::

Cookie is the data sent through the request's cookie.

Cookies must be provided in the form of `t.Cookie` or `t.Object`.

Same as `headers`, cookies have `additionalProperties` set to `true` by default.

An HTTP cookie is a small piece of data that a server sends to the client. It's data that is sent with every visit to the same web server to let the server remember client information.

In simpler terms, it's a stringified state that is sent with every request.

This field is usually used to enforce some specific cookie fields.

A cookie is a special header field that the Fetch API doesn't accept a custom value for but is managed by the browser. To send a cookie, you must use a `credentials` field instead:

`t.Cookie` is a special type that is equivalent to `t.Object` but allows to set cookie-specific options.

Response is the data returned from the handler.

Responses can be set per status code.

This is an Elysia-specific feature, allowing us to make a field optional.

There are two ways to provide a custom error message when the validation fails:

1. Inline `status` property
2. Using [onError](/essential/life-cycle.html#on-error) event

Elysia offers an additional **error** property, allowing us to return a custom error message if the field is invalid.

The following is an example of using the error property on various types:

TypeBox offers an additional "**error**" property, allowing us to return a custom error message if the field is invalid.

In addition to a string, Elysia type's error can also accept a function to programmatically return a custom error for each property.

The error function accepts the same arguments as `ValidationError`

::: tip
Hover over the `error` to see the type.
:::

Please note that the error function will only be called if the field is invalid.

Please consider the following table:

We can customize the behavior of validation based on the [onError](/essential/life-cycle.html#on-error) event by narrowing down the error code to "**VALIDATION**".

The narrowed-down error type will be typed as `ValidationError` imported from **elysia/error**.

**ValidationError** exposes a property named **validator**, typed as [TypeCheck](https://github.com/sinclairzx81/typebox#typecheck), allowing us to interact with TypeBox functionality out of the box.

**ValidationError** provides a method `ValidatorError.all`, allowing us to list all of the error causes.

For more information about TypeBox's validator, see [TypeCheck](https://github.com/sinclairzx81/typebox#typecheck).

Sometimes you might find yourself declaring duplicate models or re-using the same model multiple times.

With a reference model, we can name our model and reuse it by referencing the name.

Let's start with a simple scenario.

Suppose we have a controller that handles sign-in with the same model.

We can refactor the code by extracting the model as a variable and referencing it.

This method of separating concerns is an effective approach, but we might find ourselves reusing multiple models with different controllers as the app gets more complex.

We can resolve that by creating a "reference model", allowing us to name the model and use auto-completion to reference it directly in `schema` by registering the models with `model`.

When we want to access the model's group, we can separate a `model` into a plugin, which when registered will provide a set of models instead of multiple imports.

Then in an instance file:

This approach not only allows us to separate concerns but also enables us to reuse the model in multiple places while integrating the model into OpenAPI documentation.

`model` accepts an object with the key as a model name and the value as the model definition. Multiple models are supported by default.

Duplicate model names will cause Elysia to throw an error. To prevent declaring duplicate model names, we can use the following naming convention.

Let's say that we have all models stored at `models/<name>.ts` and declare the prefix of the model as a namespace.

This can prevent naming duplication to some extent, but ultimately, it's best to let your team decide on the naming convention.

Elysia provides an opinionated option to help prevent decision fatigue.

We can get type definitions of every Elysia/TypeBox's type by accessing the `static` property as follows:

This allows Elysia to infer and provide type automatically, reducing the need to declare duplicate schema

A single Elysia/TypeBox schema can be used for:

* Runtime validation
* Data coercion
* TypeScript type
* OpenAPI schema

This allows us to make a schema as a **single source of truth**.

**Examples:**

Example 1 (unknown):
```unknown
### TypeBox

**Elysia.t** is a schema builder based on [TypeBox](https://github.com/sinclairzx81/typebox) that provides type-safety at runtime, compile-time, and OpenAPI schema generation from a single source of truth.

Elysia tailor TypeBox for server-side validation for a seamless experience.

### Standard Schema

Elysia also support [Standard Schema](https://github.com/standard-schema/standard-schema), allowing you to use your favorite validation library:

* Zod
* Valibot
* ArkType
* Effect Schema
* Yup
* Joi
* [and more](https://github.com/standard-schema/standard-schema)

To use Standard Schema, simply import the schema and provide it to the route handler.
```

Example 2 (unknown):
```unknown
You can use any validator together in the same handler without any issue.

## Schema type

Elysia supports declarative schemas with the following types:

***

These properties should be provided as the third argument of the route handler to validate the incoming request.
```

Example 3 (unknown):
```unknown
The response should be as follows:
| URL | Query | Params |
| --- | --------- | ------------ |
| /id/a | ❌ | ❌ |
| /id/1?name=Elysia | ✅ | ✅ |
| /id/1?alias=Elysia | ❌ | ✅ |
| /id/a?name=Elysia | ✅ | ❌ |
| /id/a?alias=Elysia | ❌ | ❌ |

When a schema is provided, the type will be inferred from the schema automatically and an OpenAPI type will be generated for an API documentation, eliminating the redundant task of providing the type manually.

## Guard

Guard can be used to apply a schema to multiple handlers.
```

Example 4 (unknown):
```unknown
This code ensures that the query must have **name** with a string value for every handler after it. The response should be listed as follows:

The response should be listed as follows:

| Path          | Response |
| ------------- | -------- |
| /none         | hi       |
| /none?name=a  | hi       |
| /query        | error    |
| /query?name=a | a        |

If multiple global schemas are defined for the same property, the latest one will take precedence. If both local and global schemas are defined, the local one will take precedence.

### Guard Schema Type

Guard supports 2 types to define a validation.

### **override (default)**

Override schema if schema is collide with each others.

![Elysia run with default override guard showing schema gets override](/blog/elysia-13/schema-override.webp)

### **standalone**&#x20;

Separate collided schema, and runs both independently resulting in both being validated.

![Elysia run with standalone merging multiple guard together](/blog/elysia-13/schema-standalone.webp)

To define schema type of guard with `schema`:
```

---

## Lifecycle&#x20;

**URL:** https://elysiajs.com/essential/life-cycle.md

**Contents:**
- Why
- Hook
- Local Hook
- Interceptor Hook
- Order of code
- Request
    - Example
  - Pre Context
- Parse
    - Example

---
url: 'https://elysiajs.com/essential/life-cycle.md'
---

Instead of a sequential process, Elysia's request handling is divided into multiple stages called **lifecycle events**.

It's designed to separate the process into distinct phases based on their responsibility without interfering with each others.

Here are the order of lifecycle events in order:

Elysia's lifecycle can be illustrated as the following.
![Elysia Life Cycle Graph](/assets/lifecycle-chart.svg)

> Click on image to enlarge

Let’s say we want to send back some HTML.

Normally, we’d set the **"Content-Type"** header to **"text/html"** so the browser can render it.

But manually setting one for each route is tedious.

Instead, what if the framework could detect when a response is HTML and automatically set the header for you? That’s where the idea of a lifecycle comes in.

Each function that intercepts the **lifecycle event** as **"hook"**.

(as the function **"hooks"** into the lifecycle event)

Hooks can be categorized into 2 types:

1. [Local Hook](#local-hook): Execute on a specific route
2. [Interceptor Hook](#interceptor-hook): Execute on every route **after the hook is registered**

::: tip
The hook will accept the same Context as a handler; you can imagine adding a route handler but at a specific point.
:::

A local hook is executed on a specific route.

To use a local hook, you can inline hook into a route handler:

The response should be listed as follows:

| Path | Content-Type             |
| ---- | ------------------------ |
| /    | text/html; charset=utf8  |
| /hi  | text/plain; charset=utf8 |

Register hook into every handler **of the current instance** that came after.

To add an interceptor hook, you can use `.on` followed by a lifecycle event in camelCase:

The response should be listed as follows:

| Path  | Content-Type             |
| ----- | ------------------------ |
| /none | text/**plain**; charset=utf8 |
| /     | text/**html**; charset=utf8  |
| /hi   | text/**html**; charset=utf8  |

Events from other plugins are also applied to the route, so the order of code is important.

Event will only apply to routes **after** it is registered.

If you put the `onError` before plugin, plugin will not inherit the `onError` event.

Console should log the following:

Notice that it doesn't log **2**, because the event is registered after the route so it is not applied to the route.

This also applies to the plugin.

In this example, only **1** will be logged because the event is registered after the plugin.

Every events will follows the same rule except is `onRequest`.
Because onRequest happens on request, it doesn't know which route to applied to so it's a global event

The first lifecycle event to get executed for every new request is received.

As `onRequest` is designed to provide only the most crucial context to reduce overhead, it is recommended to use in the following scenarios:

* Caching
* Rate Limiter / IP/Region Lock
* Analytic
* Provide custom header, eg. CORS

Below is a pseudocode to enforce rate-limits on a certain IP address.

If a value is returned from `onRequest`, it will be used as the response and the rest of the lifecycle will be skipped.

Context's `onRequest` is typed as `PreContext`, a minimal representation of `Context` with the attribute on the following:
request: `Request`

* set: `Set`
* store
* decorators

Context doesn't provide `derived` value because derive is based on `onTransform` event.

Parse is an equivalent of **body parser** in Express.

A function to parse body, the return value will be append to `Context.body`, if not, Elysia will continue iterating through additional parser functions assigned by `onParse` until either body is assigned or all parsers have been executed.

By default, Elysia will parse the body with content-type of:

* `text/plain`
* `application/json`
* `multipart/form-data`
* `application/x-www-form-urlencoded`

It's recommended to use the `onParse` event to provide a custom body parser that Elysia doesn't provide.

Below is an example code to retrieve value based on custom headers.

The returned value will be assigned to `Context.body`. If not, Elysia will continue iterating through additional parser functions from **onParse** stack until either body is assigned or all parsers have been executed.

`onParse` Context is extends from `Context` with additional properties of the following:

* contentType: Content-Type header of the request

All of the context is based on normal context and can be used like normal context in route handler.

By default, Elysia will try to determine body parsing function ahead of time and pick the most suitable function to speed up the process.

Elysia is able to determine that body function by reading `body`.

Take a look at this example:

Elysia read the body schema and found that, the type is entirely an object, so it's likely that the body will be JSON. Elysia then picks the JSON body parser function ahead of time and tries to parse the body.

Here's a criteria that Elysia uses to pick up type of body parser

* `application/json`: body typed as `t.Object`
* `multipart/form-data`: body typed as `t.Object`, and is 1 level deep with `t.File`
* `application/x-www-form-urlencoded`: body typed as `t.URLEncoded`
* `text/plain`: other primitive type

This allows Elysia to optimize body parser ahead of time, and reduce overhead in compile time.

However, in some scenario if Elysia fails to pick the correct body parser function, we can explicitly tell Elysia to use a certain function by specifying `type`.

This allows us to control Elysia behavior for picking body parser function to fit our needs in a complex scenario.

`type` may be one of the following:

When you need to integrate a third-party library with HTTP handler like `trpc`, `orpc`, and it throw `Body is already used`.

This is because Web Standard Request can be parsed only once.

Both Elysia and the third-party library both has its own body parser, so you can skip body parsing on Elysia side by specifying `parse: 'none'`

You can provide register a custom parser with `parser`:

Executed just before **Validation** process, designed to mutate context to conform with the validation or appending new value.

It's recommended to use transform for the following:

* Mutate existing context to conform with validation.
* `derive` is based on `onTransform` with support for providing type.

Below is an example of using transform to mutate params to be numeric values.

Append new value to context directly **before validation**. It's stored in the same stack as **transform**.

Unlike **state** and **decorate** that assigned value before the server started. **derive** assigns a property when each request happens. This allows us to extract a piece of information into a property instead.

Because **derive** is assigned once a new request starts, **derive** can access Request properties like **headers**, **query**, **body** where **store**, and **decorate** can't.

Unlike **state**, and **decorate**. Properties which assigned by **derive** is unique and not shared with another request.

::: tip
You might want to use [resolve](#resolve) instead of derive in most cases.

Resolve is similar to derive but execute after validation. This make resolve more secure as we can validate the incoming data before using it to derive new properties.
:::

`derive` and `transform` are stored in the same queue.

The console should log as the following:

Execute after validation and before the main route handler.

Designed to provide a custom validation to provide a specific requirement before running the main handler.

If a value is returned, the route handler will be skipped.

It's recommended to use Before Handle in the following situations:

* Restricted access check: authorization, user sign-in
* Custom request requirement over data structure

Below is an example of using the before handle to check for user sign-in.

The response should be listed as follows:

| Is signed in | Response     |
| ------------ | ------------ |
| ❌           | Unauthorized |
| ✅           | Hi           |

When we need to apply the same before handle to multiple routes, we can use `guard` to apply the same before handle to multiple routes.

Append new value to context **after validation**. It's stored in the same stack as **beforeHandle**.

Resolve syntax is identical to [derive](#derive), below is an example of retrieving a bearer header from the Authorization plugin.

Using `resolve` and `onBeforeHandle` is stored in the same queue.

The console should log as the following:

Same as **derive**, properties which assigned by **resolve** is unique and not shared with another request.

As resolve is not available in local hook, it's recommended to use guard to encapsulate the **resolve** event.

Execute after the main handler, for mapping a returned value of **before handle** and **route handler** into a proper response.

It's recommended to use After Handle in the following situations:

* Transform requests into a new value, eg. Compression, Event Stream
* Add custom headers based on the response value, eg. **Content-Type**

Below is an example of using the after handle to add HTML content type to response headers.

The response should be listed as follows:

| Path | Content-Type             |
| ---- | ------------------------ |
| /    | text/html; charset=utf8  |
| /hi  | text/plain; charset=utf8 |

If a value is returned After Handle will use a return value as a new response value unless the value is **undefined**

The above example could be rewritten as the following:

Unlike **beforeHandle**, after a value is returned from **afterHandle**, the iteration of afterHandle **will **NOT** be skipped.**

`onAfterHandle` context extends from `Context` with the additional property of `response`, which is the response to return to the client.

The `onAfterHandle` context is based on the normal context and can be used like the normal context in route handlers.

Executed just after **"afterHandle"**, designed to provide custom response mapping.

It's recommended to use transform for the following:

* Compression
* Map value into a Web Standard Response

Below is an example of using mapResponse to provide Response compression.

Like **parse** and **beforeHandle**, after a value is returned, the next iteration of **mapResponse** will be skipped.

Elysia will handle the merging process of **set.headers** from **mapResponse** automatically. We don't need to worry about appending **set.headers** to Response manually.

Designed for error handling. It will be executed when an error is thrown in any lifecycle.

It's recommended to use on Error in the following situations:

* providing a custom error message
* fail-safe handling, an error handler, or retrying a request
* logging and analytics

Elysia catches all the errors thrown in the handler, classifies the error code, and pipes them to `onError` middleware.

With `onError` we can catch and transform the error into a custom error message.

::: tip
It's important that `onError` must be called before the handler we want to apply it to.
:::

For example, returning custom 404 messages:

`onError` Context is extends from `Context` with additional properties of the following:

* **error**: A value that was thrown
* **code**: *Error Code*

Elysia error code consists of:

* **NOT\_FOUND**
* **PARSE**
* **VALIDATION**
* **INTERNAL\_SERVER\_ERROR**
* **INVALID\_COOKIE\_SIGNATURE**
* **INVALID\_FILE\_TYPE**
* **UNKNOWN**
* **number** (based on HTTP Status)

By default, the thrown error code is `UNKNOWN`.

::: tip
If no error response is returned, the error will be returned using `error.name`.
:::

Same as others life-cycle, we provide an error into an [scope](/essential/plugin.html#scope) using guard:

Executed after the response sent to the client.

It's recommended to use **After Response** in the following situations:

* Clean up response
* Logging and analytics

Below is an example of using the response handle to check for user sign-in.

Console should log as the following:

Similar to [Map Response](#map-resonse), `afterResponse` also accept a `responseValue` value.

`response` from `onAfterResponse`, is not a Web-Standard's `Response` but is a value that is returned from the handler.

To get a headers, and status returned from the handler, we can access `set` from the context.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'
import { isHtml } from '@elysiajs/html'

new Elysia()
    .get('/', () => '<h1>Hello World</h1>', {
        afterHandle({ responseValue, set }) {
            if (isHtml(responseValue))
                set.headers['Content-Type'] = 'text/html; charset=utf8'
        }
    })
    .get('/hi', () => '<h1>Hello World</h1>')
    .listen(3000)
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'
import { isHtml } from '@elysiajs/html'

new Elysia()
    .get('/none', () => '<h1>Hello World</h1>')
    .onAfterHandle(({ responseValue, set }) => {
        if (isHtml(responseValue))
            set.headers['Content-Type'] = 'text/html; charset=utf8'
    })
    .get('/', () => '<h1>Hello World</h1>')
    .get('/hi', () => '<h1>Hello World</h1>')
    .listen(3000)
```

Example 3 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
 	.onBeforeHandle(() => {
        console.log('1')
    })
	.get('/', () => 'hi')
    .onBeforeHandle(() => {
        console.log('2')
    })
    .listen(3000)
```

Example 4 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
	.onBeforeHandle(() => {
		console.log('1')
	})
	.use(someRouter)
	.onBeforeHandle(() => {
		console.log('2')
	})
	.listen(3000)
```

---

## Routing&#x20;

**URL:** https://elysiajs.com/essential/route.md

**Contents:**
- Path type
- Static Path
- Dynamic path
  - Multiple path parameters
- Optional path parameters
- Wildcards
- Path priority
- HTTP Verb
  - GET
  - POST

---
url: 'https://elysiajs.com/essential/route.md'
---

Web servers use the request's **path and method** to look up the correct resource, known as **"routing"**.

We can define a route with **HTTP verb method**, a path and a function to execute when matched.

We can access the web server by going to **http://localhost:3000**

By default, web browsers will send a GET method when visiting a page.

::: tip
Using the interactive browser above, hover on the blue highlight area to see different results between each path.
:::

Path in Elysia can be grouped into 3 types:

* **static paths** - static string to locate the resource
* **dynamic paths** - segment can be any value
* **wildcards** - path until a specific point can be anything

You can use all of the path types together to compose a behavior for your web server.

Static path is a hardcoded string to locate the resource on the server.

Dynamic paths match some part and capture the value to extract extra information.

To define a dynamic path, we can use a colon `:` followed by a name.

Here, a dynamic path is created with `/id/:id`. Which tells Elysia to capture the value `:id` segment with value like **/id/1**, **/id/123**, **/id/anything**.

When requested, the server should return the response as follows:

| Path                   | Response  |
| ---------------------- | --------- |
| /id/1                  | 1         |
| /id/123                | 123       |
| /id/anything           | anything  |
| /id/anything?name=salt | anything  |
| /id                    | Not Found |
| /id/anything/rest      | Not Found |

Dynamic paths are great to include things like IDs that can be used later.

We refer to the named variable path as **path parameter** or **params** for short.

You can have as many path parameters as you like, which will then be stored into a `params` object.

The server will respond as follows:

| Path                   | Response      |
| ---------------------- | ------------- |
| /id/1                  | 1             |
| /id/123                | 123           |
| /id/anything           | anything      |
| /id/anything?name=salt | anything      |
| /id                    | Not Found     |
| /id/anything/rest      | anything rest |

Sometime we might want a static and dynamic path to resolve the same handler.

We can make a path parameter optional by adding a question mark `?` after the parameter name.

Dynamic paths allow capturing a single segment while wildcards allow capturing the rest of the path.

To define a wildcard, we can use an asterisk `*`.

Elysia has a path priorities as follows:

1. static paths
2. dynamic paths
3. wildcards

If the path is resolved as the static wild dynamic path is presented, Elysia will resolve the static path rather than the dynamic path

HTTP defines a set of request methods to indicate the desired action to be performed for a given resource

There are several HTTP verbs, but the most common ones are:

Requests using GET should only retrieve data.

Submits a payload to the specified resource, often causing state change or side effect.

Replaces all current representations of the target resource using the request's payload.

Applies partial modifications to a resource.

Deletes the specified resource.

To handle each of the different verbs, Elysia has a built-in API for several HTTP verbs by default, similar to `Elysia.get`

Elysia HTTP methods accepts the following parameters:

* **path**: Pathname
* **function**: Function to respond to the client
* **hook**: Additional metadata

You can read more about the HTTP methods on [HTTP Request Methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods).

We can accept custom HTTP Methods with `Elysia.route`.

**Elysia.route** accepts the following:

* **method**: HTTP Verb
* **path**: Pathname
* **function**: Function to response to the client
* **hook**: Additional metadata

::: tip
Based on [RFC 7231](https://www.rfc-editor.org/rfc/rfc7231#section-4.1), HTTP Verb is case-sensitive.

It's recommended to use the UPPERCASE convention for defining a custom HTTP Verb with Elysia.
:::

Elysia provides an `Elysia.all` for handling any HTTP method for a specified path using the same API like **Elysia.get** and **Elysia.post**

Any HTTP method that matches the path, will be handled as follows:
| Path | Method | Result |
| ---- | -------- | ------ |
| / | GET | hi |
| / | POST | hi |
| / | DELETE | hi |

Most developers use REST clients like Postman, Insomnia or Hoppscotch to test their API.

However, Elysia can be programmatically test using `Elysia.handle`.

**Elysia.handle** is a function to process an actual request sent to the server.

::: tip
Unlike unit test's mock, **you can expect it to behave like an actual request** sent to the server.

But also useful for simulating or creating unit tests.
:::

When creating a web server, you would often have multiple routes sharing the same prefix:

This can be improved with `Elysia.group`, allowing us to apply prefixes to multiple routes at the same time by grouping them together:

This code behaves the same as our first example and should be structured as follows:

| Path          | Result  |
| ------------- | ------- |
| /user/sign-in | Sign in |
| /user/sign-up | Sign up |
| /user/profile | Profile |

`.group()` can also accept an optional guard parameter to reduce boilerplate of using groups and guards together:

You may find more information about grouped guards in [scope](/essential/plugin.html#scope).

We can separate a group into a separate plugin instance to reduce nesting by providing a **prefix** to the constructor.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
    .get('/', 'hello')
    .get('/hi', 'hi')
    .listen(3000)
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
    .get('/id/1', 'static path')
    .get('/id/:id', 'dynamic path')
    .get('/id/*', 'wildcard path')
    .listen(3000)
```

Example 3 (ts):
```ts
import { Elysia } from 'elysia'

new Elysia()
	.get('/hello', 'hello')
	.get('/hi', 'hi')
	.listen(3000)
```

Example 4 (unknown):
```unknown
Here, a dynamic path is created with `/id/:id`. Which tells Elysia to capture the value `:id` segment with value like **/id/1**, **/id/123**, **/id/anything**.

When requested, the server should return the response as follows:

| Path                   | Response  |
| ---------------------- | --------- |
| /id/1                  | 1         |
| /id/123                | 123       |
| /id/anything           | anything  |
| /id/anything?name=salt | anything  |
| /id                    | Not Found |
| /id/anything/rest      | Not Found |

Dynamic paths are great to include things like IDs that can be used later.

We refer to the named variable path as **path parameter** or **params** for short.

### Multiple path parameters

You can have as many path parameters as you like, which will then be stored into a `params` object.
```

---

## Plugin&#x20;

**URL:** https://elysiajs.com/essential/plugin.md

**Contents:**
- Dependency&#x20;
  - Deduplication&#x20;
  - Global vs Explicit Dependency
- Scope &#x20;
  - Scope level
  - Descendant
- Config
  - Functional callback
- Guard&#x20;
  - Grouped Guard

---
url: 'https://elysiajs.com/essential/plugin.md'
---

A plugin is a part that is **decoupled** from the main instance into a smaller part.

Every Elysia instance can run independently or use as a part of another instance.

We can use the plugin by passing an instance to **Elysia.use**.

The plugin will inherit all properties of the plugin instance like `state`, `decorate` but **WILL NOT inherit plugin [lifecycle](/essential/life-cycle)** as it's [isolated by default](#scope) (mentioned in the next section ↓).

Elysia will also handle the type inference automatically as well.

::: tip
It's highly recommended that you have read [Key Concept: Dependency](/key-concept.html#dependency) before continuing.
:::

Elysia by design, is compose of multiple mini Elysia apps which can run **independently** like a microservice that communicate with each other.

Each Elysia instance is independent and **can run as a standalone server**.

When an instance need to use another instance's service, you **must explicitly declare the dependency**.

This is similar to **Dependency Injection** where each instance must declare its dependencies.

This approach force you to be explicit about dependencies allowing better tracking, modularity.

By default, each plugin will be re-executed **every time** applying to another instance.

To prevent this, Elysia can deduplicate [lifecycle](/essential/life-cycle) with **an unique identifier** using `name` and optional `seed` property.

Adding the `name` and optional `seed` to the instance will make it a unique identifier prevent it from being called multiple times.

Learn more about this in [plugin deduplication](/essential/plugin.html#plugin-deduplication).

There are some case that global dependency make more sense than an explicit one.

**Global** plugin example:

* **Plugin that doesn't add types** - eg. cors, compress, helmet
* Plugin that add global [lifecycle](/essential/life-cycle) that no instance should have control over - eg. tracing, logging

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

Elysia [lifecycle](/essential/life-cycle) methods are **encapsulated** to its own instance only.

Which means if you create a new instance, it will not share the lifecycle methods with others.

In this example, the `isSignIn` check will only apply to `profile` but not `app`.

> Try changing the path in the URL bar to **/rename** and see the result

**Elysia isolate [lifecycle](/essential/life-cycle) by default** unless explicitly stated. This is similar to **export** in JavaScript, where you need to export the function to make it available outside the module.

To **"export"** the lifecycle to other instances, you must add specify the scope.

Casting lifecycle to **"global"** will export lifecycle to **every instance**.

Elysia has 3 levels of scope as the following:

Scope type are as the following:

1. **local** (default) - apply to only current instance and descendant only
2. **scoped** - apply to parent, current instance and descendants
3. **global** - apply to all instance that apply the plugin (all parents, current, and descendants)

Let's review what each scope type does by using the following example:

By changing the `type` value, the result should be as follows:

| type       | child | current | parent | main |
| ---------- | ----- | ------- | ------ | ---- |
| local      | ✅    | ✅      | ❌      | ❌   |
| scoped     | ✅    | ✅      | ✅      | ❌   |
| global     | ✅    | ✅      | ✅      | ✅   |

By default plugin will **apply hook to itself and descendants** only.

If the hook is registered in a plugin, instances that inherit the plugin will **NOT** inherit hooks and schema.

To apply hook to globally, we need to specify hook as global.

To make the plugin more useful, allowing customization via config is recommended.

You can create a function that accepts parameters that may change the behavior of the plugin to make it more reusable.

It's recommended to define a new plugin instance instead of using a function callback.

Functional callback allows us to access the existing property of the main instance. For example, checking if specific routes or stores existed but harder to handle encapsulation and scope correctly.

To define a functional callback, create a function that accepts Elysia as a parameter.

Once passed to `Elysia.use`, functional callback behaves as a normal plugin except the property is assigned directly to the main instance.

::: tip
You shall not worry about the performance difference between a functional callback and creating an instance.

Elysia can create 10k instances in a matter of milliseconds, the new Elysia instance has even better type inference performance than the functional callback.
:::

Guard allows us to apply hook and schema into multiple routes all at once.

This code applies validation for `body` to both '/sign-in' and '/sign-up' instead of inlining the schema one by one but applies not to '/'.

We can summarize the route validation as the following:
| Path | Has validation |
| ------- | ------------- |
| /sign-up | ✅ |
| /sign-in | ✅ |
| / | ❌ |

Guard accepts the same parameter as inline hook, the only difference is that you can apply hook to multiple routes in the scope.

This means that the code above is translated into:

We can use a group with prefixes by providing 3 parameters to the group.

1. Prefix - Route prefix
2. Guard - Schema
3. Scope - Elysia app callback

With the same API as guard apply to the 2nd parameter, instead of nesting group and guard together.

Consider the following example:

From nested groupped guard, we may merge group and guard together by providing guard scope to 2nd parameter of group:

Which results in the follows syntax:

To apply hook to parent may use one of the following:

1. [inline as](#inline-as) apply only to a single hook
2. [guard as](#guard-as) apply to all hook in a guard
3. [instance as](#instance-as) apply to all hook in an instance

Every event listener will accept `as` parameter to specify the scope of the hook.

However, this method is apply to only a single hook, and may not be suitable for multiple hooks.

Every event listener will accept `as` parameter to specify the scope of the hook.

Guard alllowing us to apply `schema` and `hook` to multiple routes all at once while specifying the scope.

However, it doesn't support `derive` and `resolve` method.

`as` will read all hooks and schema scope of the current instance, modify.

Sometimes we want to reapply plugin to parent instance as well but as it's limited by `scoped` mechanism, it's limited to 1 parent only.

To apply to the parent instance, we need to **lift the scope up** to the parent instance, and `as` is the perfect method to do so.

Which means if you have `local` scope, and want to apply it to the parent instance, you can use `as('scoped')` to lift it up.

Modules are eagerly loaded by default.

Elysia will make sure that all modules are registered before the server starts.

However, some modules may be computationally heavy or blocking, making the server startup slow.

To solve this, Elysia allows you to provide an async plugin that will not block the server startup.

The deferred module is an async plugin that can be registered after the server is started.

And in the main file:

Same as the async plugin, the lazy-load module will be registered after the server is started.

A lazy-load module can be both sync or async function, as long as the module is used with `import` the module will be lazy-loaded.

Using module lazy-loading is recommended when the module is computationally heavy and/or blocking.

To ensure module registration before the server starts, we can use `await` on the deferred module.

In a test environment, we can use `await app.modules` to wait for deferred and lazy-loading modules.

**Examples:**

Example 1 (unknown):
```unknown
We can use the plugin by passing an instance to **Elysia.use**.

The plugin will inherit all properties of the plugin instance like `state`, `decorate` but **WILL NOT inherit plugin [lifecycle](/essential/life-cycle)** as it's [isolated by default](#scope) (mentioned in the next section ↓).

Elysia will also handle the type inference automatically as well.

::: tip
It's highly recommended that you have read [Key Concept: Dependency](/key-concept.html#dependency) before continuing.
:::

## Dependency&#x20;

Elysia by design, is compose of multiple mini Elysia apps which can run **independently** like a microservice that communicate with each other.

Each Elysia instance is independent and **can run as a standalone server**.

When an instance need to use another instance's service, you **must explicitly declare the dependency**.
```

Example 2 (unknown):
```unknown
This is similar to **Dependency Injection** where each instance must declare its dependencies.

This approach force you to be explicit about dependencies allowing better tracking, modularity.

### Deduplication&#x20;

By default, each plugin will be re-executed **every time** applying to another instance.

To prevent this, Elysia can deduplicate [lifecycle](/essential/life-cycle) with **an unique identifier** using `name` and optional `seed` property.
```

Example 3 (unknown):
```unknown
Adding the `name` and optional `seed` to the instance will make it a unique identifier prevent it from being called multiple times.

Learn more about this in [plugin deduplication](/essential/plugin.html#plugin-deduplication).

### Global vs Explicit Dependency

There are some case that global dependency make more sense than an explicit one.

**Global** plugin example:

* **Plugin that doesn't add types** - eg. cors, compress, helmet
* Plugin that add global [lifecycle](/essential/life-cycle) that no instance should have control over - eg. tracing, logging

Example use cases:

* OpenAPI/Open - Global document
* OpenTelemetry - Global tracer
* Logging - Global logger

In case like this, it make more sense to create it as global dependency instead of applying it to every instance.

However, if your dependency doesn't fit into these categories, it's recommended to use **explicit dependency** instead.

**Explicit dependency** example:

* **Plugin that add types** - eg. macro, state, model
* Plugin that add business logic that instance can interact with - eg. Auth, Database

Example use cases:

* State management - eg. Store, Session
* Data modeling - eg. ORM, ODM
* Business logic - eg. Auth, Database
* Feature module - eg. Chat, Notification

## Scope &#x20;

Elysia [lifecycle](/essential/life-cycle) methods are **encapsulated** to its own instance only.

Which means if you create a new instance, it will not share the lifecycle methods with others.
```

Example 4 (unknown):
```unknown
In this example, the `isSignIn` check will only apply to `profile` but not `app`.

> Try changing the path in the URL bar to **/rename** and see the result

**Elysia isolate [lifecycle](/essential/life-cycle) by default** unless explicitly stated. This is similar to **export** in JavaScript, where you need to export the function to make it available outside the module.

To **"export"** the lifecycle to other instances, you must add specify the scope.
```

---

## Best Practice

**URL:** https://elysiajs.com/essential/best-practice.md

**Contents:**
- Folder Structure
- Controller
  - 1. Elysia instance as a controller
  - 2. Controller without HTTP request
  - ❌ Don't: Pass entire `Context` to a controller
  - Testing
- Service
  - 1. Abstract away Non-request dependent service
  - 2. Request dependent service as Elysia instance
  - ✅ Do: Decorate only request dependent property

---
url: 'https://elysiajs.com/essential/best-practice.md'
---

Elysia is a pattern-agnostic framework, leaving the decision of which coding patterns to use up to you and your team.

However, there are several concerns when trying to adapt an MVC pattern [(Model-View-Controller)](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) with Elysia, and we found it hard to decouple and handle types.

This page is a guide on how to follow Elysia structure best practices combined with the MVC pattern, but it can be adapted to any coding pattern you prefer.

Elysia is unopinionated about folder structure, leaving you to **decide** how to organize your code yourself.

However, **if you don't have a specific structure in mind**, we recommend a feature-based folder structure where each feature has its own folder containing controllers, services, and models.

This structure allows you to easily find and manage your code and keep related code together.

Here's an example code of how to distribute your code into a feature-based folder structure:

Each file has its own responsibility as follows:

* **Controller**: Handle HTTP routing, request validation, and cookie.
* **Service**: Handle business logic, decoupled from Elysia controller if possible.
* **Model**: Define the data structure and validation for the request and response.

Feel free to adapt this structure to your needs and use any coding pattern you prefer.

Due to type soundness of Elysia, it's not recommended to use a traditional controller class that is tightly coupled with Elysia's `Context` because:

1. **Elysia type is complex** and heavily depends on plugin and multiple level of chaining.
2. **Hard to type**, Elysia type could change at anytime, especially with decorators, and store
3. **Loss of type integrity**, and inconsistency between types and runtime code.

We recommended one of the following approach to implement a controller in Elysia.

1. Use Elysia instance as a controller itself
2. Create a controller that is not tied with HTTP request or Elysia.

> 1 Elysia instance = 1 controller

Treat an Elysia instance as a controller, and define your routes directly on the Elysia instance.

This approach allows Elysia to infer the `Context` type automatically, ensuring type integrity and consistency between types and runtime code.

This approach makes it hard to type `Context` properly, and may lead to loss of type integrity.

If you want to create a controller class, we recommend creating a class that is not tied to HTTP request or Elysia at all.

This approach allows you to decouple the controller from Elysia, making it easier to test, reuse, and even swap a framework while still follows the MVC pattern.

Tying the controller to Elysia Context may lead to:

1. Loss of type integrity
2. Make it harder to test and reuse
3. Lead to vendor lock-in

We recommended to keep the controller decoupled from Elysia as much as possible.

**Context is a highly dynamic type** that can be inferred from Elysia instance.

Do not pass an entire `Context` to a controller, instead use object destructuring to extract what you need and pass it to the controller.

This approach makes it hard to type `Context` properly, and may lead to loss of type integrity.

If you're using Elysia as a controller, you can test your controller using `handle` to directly call a function (and it's lifecycle)

You may find more information about testing in [Unit Test](/patterns/unit-test.html).

Service is a set of utility/helper functions decoupled as a business logic to use in a module/controller, in our case, an Elysia instance.

Any technical logic that can be decoupled from controller may live inside a **Service**.

There are 2 types of service in Elysia:

1. Non-request dependent service
2. Request dependent service

We recommend abstracting a service class/function away from Elysia.

If the service or function isn't tied to an HTTP request or doesn't access a `Context`, it's recommended to implement it as a static class or function.

If your service doesn't need to store a property, you may use `abstract class` and `static` instead to avoid allocating class instance.

**If the service is a request-dependent service** or needs to process HTTP requests, we recommend abstracting it as an Elysia instance to ensure type integrity and inference:

::: tip
Elysia handles [plugin deduplication](/essential/plugin.html#plugin-deduplication) by default, so you don't have to worry about performance, as it will be a singleton if you specify a **"name"** property.
:::

It's recommended to `decorate` only request-dependent properties, such as `requestIP`, `requestTime`, or `session`.

Overusing decorators may tie your code to Elysia, making it harder to test and reuse.

Model or [DTO (Data Transfer Object)](https://en.wikipedia.org/wiki/Data_transfer_object) is handle by [Elysia.t (Validation)](/essential/validation.html#elysia-type).

Elysia has a validation system built-in which can infers type from your code and validate it at runtime.

Elysia strength is prioritizing a single source of truth for both type and runtime validation.

Instead of declaring an interface, reuse validation's model instead:

We can get type of model by using `typeof` with `.static` property from the model.

Then you can use the `CustomBody` type to infer the type of the request body.

Do not declare a class instance as a model:

Do not declare a type separate from the model, instead use `typeof` with `.static` property to get the type of the model.

You can group multiple models into a single object to make it more organized.

Though this is optional, if you are strictly following MVC pattern, you may want to inject like a service into a controller. We recommended using [Elysia reference model](/essential/validation#reference-model)

Using Elysia's model reference

This approach provide several benefits:

1. Allow us to name a model and provide auto-completion.
2. Modify schema for later usage, or perform a [remap](/essential/handler.html#remap).
3. Show up as "models" in OpenAPI compliance client, eg. OpenAPI.
4. Improve TypeScript inference speed as model type will be cached during registration.

**Examples:**

Example 1 (unknown):
```unknown
| src
  | modules
	| auth
	  | index.ts (Elysia controller)
	  | service.ts (service)
	  | model.ts (model)
	| user
	  | index.ts (Elysia controller)
	  | service.ts (service)
	  | model.ts (model)
  | utils
	| a
	  | index.ts
	| b
	  | index.ts
```

Example 2 (unknown):
```unknown
:::

Each file has its own responsibility as follows:

* **Controller**: Handle HTTP routing, request validation, and cookie.
* **Service**: Handle business logic, decoupled from Elysia controller if possible.
* **Model**: Define the data structure and validation for the request and response.

Feel free to adapt this structure to your needs and use any coding pattern you prefer.

## Controller

Due to type soundness of Elysia, it's not recommended to use a traditional controller class that is tightly coupled with Elysia's `Context` because:

1. **Elysia type is complex** and heavily depends on plugin and multiple level of chaining.
2. **Hard to type**, Elysia type could change at anytime, especially with decorators, and store
3. **Loss of type integrity**, and inconsistency between types and runtime code.

We recommended one of the following approach to implement a controller in Elysia.

1. Use Elysia instance as a controller itself
2. Create a controller that is not tied with HTTP request or Elysia.

***

### 1. Elysia instance as a controller

> 1 Elysia instance = 1 controller

Treat an Elysia instance as a controller, and define your routes directly on the Elysia instance.
```

Example 3 (unknown):
```unknown
This approach allows Elysia to infer the `Context` type automatically, ensuring type integrity and consistency between types and runtime code.
```

Example 4 (unknown):
```unknown
This approach makes it hard to type `Context` properly, and may lead to loss of type integrity.

### 2. Controller without HTTP request

If you want to create a controller class, we recommend creating a class that is not tied to HTTP request or Elysia at all.

This approach allows you to decouple the controller from Elysia, making it easier to test, reuse, and even swap a framework while still follows the MVC pattern.
```

---

## Handler&#x20;

**URL:** https://elysiajs.com/essential/handler.md

**Contents:**
- Context
    - Property
    - Utility Function
    - Additional Property
- status&#x20;
- Set
  - set.headers
- Cookie
- Redirect
- Formdata

---
url: 'https://elysiajs.com/essential/handler.md'
---

**Handler** - a function that accept an HTTP request, and return a response.

A handler may be a literal value, and can be inlined.

Using an **inline value** always returns the same value which is useful to optimize performance for static resources like files.

This allows Elysia to compile the response ahead of time to optimize performance.

::: tip
Providing an inline value is not a cache.

Static resource values, headers and status can be mutated dynamically using lifecycle.
:::

**Context** contains request information which is unique for each request, and is not shared except for `store` (global mutable state).

**Context** can only be retrieved in a route handler. It consists of:

* [**body**](/essential/validation.html#body) - [HTTP message](https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages), form or file upload.
* [**query**](/essential/validation.html#query) - [Query String](https://en.wikipedia.org/wiki/Query_string), include additional parameters for search query as JavaScript Object. (Query is extracted from a value after pathname starting from '?' question mark sign)
* [**params**](/essential/validation.html#params) - Elysia's path parameters parsed as JavaScript object
* [**headers**](/essential/validation.html#headers) - [HTTP Header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers), additional information about the request like User-Agent, Content-Type, Cache Hint.
* [**cookie**](#cookie) - A global mutable signal store for interacting with Cookie (including get/set)
* [**store**](#state) - A global mutable store for Elysia instance

* [**redirect**](#redirect) - A function to redirect a response
* [**status**](#status) - A function to return custom status code
* [**set**](#set) - Property to apply to Response:
  * [**headers**](#set.headers) - Response headers

* [**request**](#request) - [Web Standard Request](https://developer.mozilla.org/en-US/docs/Web/API/Request)
* [**server**](#server-bun-only) - Bun server instance
* **path** - Pathname of the request

A function to return a custom status code with type narrowing.

It's recommended use **never-throw** approach to return **status** instead of throw as it:

* allows TypeScript to check if a return value is correctly type to response schema
* autocompletion for type narrowing based on status code
* type narrowing for error handling using End-to-end type safety ([Eden](/eden/overview))

**set** is a mutable property that form a response accessible via `Context.set`.

Allowing us to append or delete response headers represented as an Object.

::: tip
Elysia provide an auto-completion for lowercase for case-sensitivity consistency, eg. use `set-cookie` rather than `Set-Cookie`.
:::

Redirect a request to another resource.

When using redirect, returned value is not required and will be ignored. As response will be from another resource.

Set a default status code if not provided.

It's recommended to use this in a plugin that only needs to return a specific status code while allowing the user to return a custom value. For example, HTTP 201/206 or 403/405, etc.

Unlike `status` function, `set.status` cannot infer the return value type, therefore it can't check if the return value is correctly type to response schema.

::: tip
HTTP Status indicates the type of response. If the route handler is executed successfully without error, Elysia will return the status code 200.
:::

You can also set a status code using the common name of the status code instead of using a number.

Elysia provides a mutable signal for interacting with Cookie.

There's no get/set, you can extract the cookie name and retrieve or update its value directly.

See [Patterns: Cookie](/essentials/cookie) for more information.

Redirect a request to another resource.

When using redirect, returned value is not required and will be ignored. As response will be from another resource.

We may return a `FormData` by using returning `form` utility directly from the handler.

This pattern is useful if even need to return a file or multipart form data.

Or alternatively, you can return a single file by returning `file` directly without `form`.

To return a response streaming out of the box by using a generator function with `yield` keyword.

This this example, we may stream a response by using `yield` keyword.

Elysia supports [Server Sent Events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events) by providing a `sse` utility function.

When a value is wrapped in `sse`, Elysia will automatically set the response headers to `text/event-stream` and format the data as an SSE event.

Headers can only be set before the first chunk is yielded.

Once the first chunk is yielded, Elysia will send the headers to the client, therefore mutating headers after the first chunk is yielded will do nothing.

If the response is returned without yield, Elysia will automatically convert stream to normal response instead.

This allows us to conditionally stream a response or return a normal response if necessary.

Before response streaming is completed, if the user cancels the request, Elysia will automatically stop the generator function.

[Eden](/eden/overview) will interpret a stream response as `AsyncGenerator` allowing us to use `for await` loop to consume the stream.

Elysia is built on top of [Web Standard Request](https://developer.mozilla.org/en-US/docs/Web/API/Request) which is shared between multiple runtime like Node, Bun, Deno, Cloudflare Worker, Vercel Edge Function, and more.

Allowing you to access low-level request information if necessary.

Server instance is a Bun server instance, allowing us to access server information like port number or request IP.

Server will only be available when HTTP server is running with `listen`.

We can get request IP by using `server.requestIP` method

Elysia provides a minimal Context by default, allowing us to extend Context for our specific need using state, decorate, derive, and resolve.

See [Extends Context](/patterns/extends-context) for more information on how to extend a Context.

**Examples:**

Example 1 (typescript):
```typescript
import { Elysia } from 'elysia'

new Elysia()
    // the function `() => 'hello world'` is a handler
    .get('/', () => 'hello world')
    .listen(3000)
```

Example 2 (typescript):
```typescript
import { Elysia, file } from 'elysia'

new Elysia()
    .get('/', 'Hello Elysia')
    .get('/video', file('kyuukurarin.mp4'))
    .listen(3000)
```

Example 3 (unknown):
```unknown
**Context** can only be retrieved in a route handler. It consists of:

#### Property

* [**body**](/essential/validation.html#body) - [HTTP message](https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages), form or file upload.
* [**query**](/essential/validation.html#query) - [Query String](https://en.wikipedia.org/wiki/Query_string), include additional parameters for search query as JavaScript Object. (Query is extracted from a value after pathname starting from '?' question mark sign)
* [**params**](/essential/validation.html#params) - Elysia's path parameters parsed as JavaScript object
* [**headers**](/essential/validation.html#headers) - [HTTP Header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers), additional information about the request like User-Agent, Content-Type, Cache Hint.
* [**cookie**](#cookie) - A global mutable signal store for interacting with Cookie (including get/set)
* [**store**](#state) - A global mutable store for Elysia instance

#### Utility Function

* [**redirect**](#redirect) - A function to redirect a response
* [**status**](#status) - A function to return custom status code
* [**set**](#set) - Property to apply to Response:
  * [**headers**](#set.headers) - Response headers

#### Additional Property

* [**request**](#request) - [Web Standard Request](https://developer.mozilla.org/en-US/docs/Web/API/Request)
* [**server**](#server-bun-only) - Bun server instance
* **path** - Pathname of the request

## status&#x20;

A function to return a custom status code with type narrowing.
```

Example 4 (unknown):
```unknown
It's recommended use **never-throw** approach to return **status** instead of throw as it:

* allows TypeScript to check if a return value is correctly type to response schema
* autocompletion for type narrowing based on status code
* type narrowing for error handling using End-to-end type safety ([Eden](/eden/overview))

## Set

**set** is a mutable property that form a response accessible via `Context.set`.
```

---
