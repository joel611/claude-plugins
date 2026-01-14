# Elysia - Plugins

**Pages:** 13

---

## OpenTelemetry

**URL:** https://elysiajs.com/plugins/opentelemetry.md

**Contents:**
- Usage
- Config
  - autoDetectResources - boolean
  - contextManager - ContextManager
  - textMapPropagator - TextMapPropagator
  - metricReader - MetricReader
  - views - View\[]
  - instrumentations - (Instrumentation | Instrumentation\[])\[]
  - resource - IResource
  - resourceDetectors - Array\<Detector | DetectorSync>

---
url: 'https://elysiajs.com/plugins/opentelemetry.md'
---

::: tip
This page is a **config reference** for **OpenTelemetry**, if you're looking to setup and integrate with OpenTelemetry, we recommended taking a look at [Integrate with OpenTelemetry](/patterns/opentelemetry) instead.
:::

To start using OpenTelemetry, install `@elysiajs/opentelemetry` and apply plugin to any instance.

![jaeger showing collected trace automatically](/blog/elysia-11/jaeger.webp)

Elysia OpenTelemetry is will **collect span of any library compatible OpenTelemetry standard**, and will apply parent and child span automatically.

See [opentelemetry](/patterns/opentelemetry) for usage and utilities

This plugin extends OpenTelemetry SDK parameters options.

Below is a config which is accepted by the plugin

Detect resources automatically from the environment using the default resource detectors.

Use a custom context manager.

default: `AsyncHooksContextManager`

Use a custom propagator.

default: `CompositePropagator` using W3C Trace Context and Baggage

Add a MetricReader that will be passed to the MeterProvider.

A list of views to be passed to the MeterProvider.

Accepts an array of View-instances. This parameter can be used to configure explicit bucket sizes of histogram metrics.

Configure instrumentations.

By default `getNodeAutoInstrumentations` is enabled, if you want to enable them you can use either metapackage or configure each instrumentation individually.

default: `getNodeAutoInstrumentations()`

Configure a resource.

Resources may also be detected by using the autoDetectResources method of the SDK.

Configure resource detectors. By default, the resource detectors are \[envDetector, processDetector, hostDetector]. NOTE: In order to enable the detection, the parameter autoDetectResources has to be true.

If resourceDetectors was not set, you can also use the environment variable OTEL\_NODE\_RESOURCE\_DETECTORS to enable only certain detectors, or completely disable them:

* env
* host
* os
* process
* serviceinstance (experimental)
* all - enable all resource detectors above
* none - disable resource detection

For example, to enable only the env, host detectors:

Configure a custom sampler. By default, all traces will be sampled.

Namespace to be identify as.

An array of span processors to register to the tracer provider.

Configure a trace exporter. If an exporter is configured, it will be used with a `BatchSpanProcessor`.

If an exporter OR span processor is not configured programmatically, this package will auto setup the default otlp exporter with http/protobuf protocol with a BatchSpanProcessor.

Configure tracing parameters. These are the same trace parameters used to configure a tracer.

**Examples:**

Example 1 (unknown):
```unknown
![jaeger showing collected trace automatically](/blog/elysia-11/jaeger.webp)

Elysia OpenTelemetry is will **collect span of any library compatible OpenTelemetry standard**, and will apply parent and child span automatically.

## Usage

See [opentelemetry](/patterns/opentelemetry) for usage and utilities

## Config

This plugin extends OpenTelemetry SDK parameters options.

Below is a config which is accepted by the plugin

### autoDetectResources - boolean

Detect resources automatically from the environment using the default resource detectors.

default: `true`

### contextManager - ContextManager

Use a custom context manager.

default: `AsyncHooksContextManager`

### textMapPropagator - TextMapPropagator

Use a custom propagator.

default: `CompositePropagator` using W3C Trace Context and Baggage

### metricReader - MetricReader

Add a MetricReader that will be passed to the MeterProvider.

### views - View\[]

A list of views to be passed to the MeterProvider.

Accepts an array of View-instances. This parameter can be used to configure explicit bucket sizes of histogram metrics.

### instrumentations - (Instrumentation | Instrumentation\[])\[]

Configure instrumentations.

By default `getNodeAutoInstrumentations` is enabled, if you want to enable them you can use either metapackage or configure each instrumentation individually.

default: `getNodeAutoInstrumentations()`

### resource - IResource

Configure a resource.

Resources may also be detected by using the autoDetectResources method of the SDK.

### resourceDetectors - Array\<Detector | DetectorSync>

Configure resource detectors. By default, the resource detectors are \[envDetector, processDetector, hostDetector]. NOTE: In order to enable the detection, the parameter autoDetectResources has to be true.

If resourceDetectors was not set, you can also use the environment variable OTEL\_NODE\_RESOURCE\_DETECTORS to enable only certain detectors, or completely disable them:

* env
* host
* os
* process
* serviceinstance (experimental)
* all - enable all resource detectors above
* none - disable resource detection

For example, to enable only the env, host detectors:
```

---

## Overview

**URL:** https://elysiajs.com/plugins/overview.md

**Contents:**
- Official plugins
- Community plugins
- Complementary projects:

---
url: 'https://elysiajs.com/plugins/overview.md'
---

Elysia is designed to be modular and lightweight.

Following the same idea as Arch Linux (btw, I use Arch):

> Design decisions are made on a case-by-case basis through developer consensus

This is to ensure developers end up with a performant web server they intend to create. By extension, Elysia includes pre-built common pattern plugins for convenient developer usage:

Here are some of the official plugins maintained by the Elysia team:

* [Bearer](/plugins/bearer) - retrieve [Bearer](https://swagger.io/docs/specification/authentication/bearer-authentication/) token automatically
* [CORS](/plugins/cors) - set up [Cross-origin resource sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
* [Cron](/plugins/cron) - set up [cron](https://en.wikipedia.org/wiki/Cron) job
* [Eden](/eden/overview) - end-to-end type safety client for Elysia
* [GraphQL Apollo](/plugins/graphql-apollo) - run [Apollo GraphQL](https://www.apollographql.com/) on Elysia
* [GraphQL Yoga](/plugins/graphql-yoga) - run [GraphQL Yoga](https://github.com/dotansimha/graphql-yoga) on Elysia
* [HTML](/plugins/html) - handle HTML responses
* [JWT](/plugins/jwt) - authenticate with [JWTs](https://jwt.io/)
* [OpenAPI](/plugins/openapi) - generate an [OpenAPI](https://swagger.io/specification/) documentation
* [OpenTelemetry](/plugins/opentelemetry) - add support for OpenTelemetry
* [Server Timing](/plugins/server-timing) - audit performance bottlenecks with the [Server-Timing API](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Server-Timing)
* [Static](/plugins/static) - serve static files/folders

* [Create ElysiaJS](https://github.com/kravetsone/create-elysiajs) - scaffold your Elysia project with the environment easily (help with ORM, Linters and Plugins)!
* [Lucia Auth](https://github.com/pilcrowOnPaper/lucia) - authentication, simple and clean
* [Elysia Clerk](https://github.com/wobsoriano/elysia-clerk) - unofficial Clerk authentication plugin
* [Elysia Polyfills](https://github.com/bogeychan/elysia-polyfills) - run Elysia ecosystem on Node.js and Deno
* [Vite server](https://github.com/kravetsone/elysia-vite-server) - plugin which starts and decorates [`vite`](https://vitejs.dev/) dev server in `development` and in `production` mode serves static files (if needed)
* [Vite](https://github.com/timnghg/elysia-vite) - serve entry HTML file with Vite's scripts injected
* [Nuxt](https://github.com/trylovetom/elysiajs-nuxt) - easily integrate Elysia with Nuxt!
* [Remix](https://github.com/kravetsone/elysia-remix) - use [Remix](https://remix.run/) with `HMR` support (powered by [`vite`](https://vitejs.dev/))! Close a really long-standing plugin request [#12](https://github.com/elysiajs/elysia/issues/12)
* [Sync](https://github.com/johnny-woodtke/elysiajs-sync) - a lightweight offline-first data synchronization framework powered by [Dexie.js](https://dexie.org/)
* [Connect middleware](https://github.com/kravetsone/elysia-connect-middleware) - plugin which allows you to use [`express`](https://www.npmjs.com/package/express)/[`connect`](https://www.npmjs.com/package/connect) middleware directly in Elysia!
* [Elysia HTTP Exception](https://github.com/codev911/elysia-http-exception) - Elysia plugin for HTTP 4xx/5xx error handling with structured exception classes
* [Elysia Helmet](https://github.com/DevTobias/elysia-helmet) - secure Elysia apps with various HTTP headers
* [Vite Plugin SSR](https://github.com/timnghg/elysia-vite-plugin-ssr) - Vite SSR plugin using Elysia server
* [OAuth 2.0](https://github.com/kravetsone/elysia-oauth2) - a plugin for [OAuth 2.0](https://en.wikipedia.org/wiki/OAuth) Authorization Flow with more than **42** providers and **type-safety**!
* [OAuth2](https://github.com/bogeychan/elysia-oauth2) - handle OAuth 2.0 authorization code flow
* [OAuth2 Resource Server](https://github.com/ap-1/elysia-oauth2-resource-server) - a plugin for validating JWT tokens from OAuth2 providers against JWKS endpoints with support for issuer, audience, and scope verification
* [Elysia OpenID Client](https://github.com/macropygia/elysia-openid-client) - OpenID client based on [openid-client](https://github.com/panva/node-openid-client)
* [Rate Limit](https://github.com/rayriffy/elysia-rate-limit) - simple, lightweight rate limiter
* [Logysia](https://github.com/tristanisham/logysia) - classic logging middleware
* [Logestic](https://github.com/cybercoder-naj/logestic) - an advanced and customisable logging library for ElysiaJS
* [Logger](https://github.com/bogeychan/elysia-logger) - [pino](https://github.com/pinojs/pino)-based logging middleware
* [Elysia Line](https://github.com/KrataiB/elysia-line) - LINE Messaging API and LINE Login integration for Elysia (wrapper around the official [@line/bot-sdk](https://github.com/line/line-bot-sdk-nodejs))
* [Elylog](https://github.com/eajr/elylog) - simple stdout logging library with some customization
* [Logify for Elysia.js](https://github.com/0xrasla/logify) - a beautiful, fast, and type-safe logging middleware for Elysia.js applications
* [Nice Logger](https://github.com/tanishqmanuja/nice-logger) - not the nicest, but a pretty nice and sweet logger for Elysia.
* [Sentry](https://github.com/johnny-woodtke/elysiajs-sentry) - capture traces and errors with this [Sentry](https://docs.sentry.io/) plugin
* [Elysia Lambda](https://github.com/TotalTechGeek/elysia-lambda) - deploy on AWS Lambda
* [Decorators](https://github.com/gaurishhs/elysia-decorators) - use TypeScript decorators
* [Autoload](https://github.com/kravetsone/elysia-autoload) - filesystem router based on a directory structure that generates types for [Eden](/eden/overview) with [`Bun.build`](https://github.com/kravetsone/elysia-autoload?tab=readme-ov-file#bun-build-usage) support
* [Msgpack](https://github.com/kravetsone/elysia-msgpack) - allows you to work with [MessagePack](https://msgpack.org)
* [XML](https://github.com/kravetsone/elysia-xml) - allows you to work with XML
* [Autoroutes](https://github.com/wobsoriano/elysia-autoroutes) - filesystem routes
* [Group Router](https://github.com/itsyoboieltr/elysia-group-router) - filesystem and folder-based router for groups
* [Basic Auth](https://github.com/itsyoboieltr/elysia-basic-auth) - basic HTTP authentication
* [ETag](https://github.com/bogeychan/elysia-etag) - automatic HTTP [ETag](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag) generation
* [CDN Cache](https://github.com/johnny-woodtke/elysiajs-cdn-cache) - Cache-Control plugin for Elysia - no more manually setting HTTP headers
* [Basic Auth](https://github.com/eelkevdbos/elysia-basic-auth) - basic HTTP authentication (using `request` event)
* [i18n](https://github.com/eelkevdbos/elysia-i18next) - [i18n](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/i18n) wrapper based on [i18next](https://www.i18next.com/)
* [Intlify](https://github.com/intlify/srvmid/blob/main/packages/elysia/README.md) - Internationalization server middleware & utilities
* [Elysia Request ID](https://github.com/gtramontina/elysia-requestid) - add/forward request IDs (`X-Request-ID` or custom)
* [Elysia HTMX](https://github.com/gtramontina/elysia-htmx) - context helpers for [HTMX](https://htmx.org/)
* [Elysia HMR HTML](https://github.com/gtrabanco/elysia-hmr-html) - reload HTML files when changing any file in a directory
* [Elysia Inject HTML](https://github.com/gtrabanco/elysia-inject-html) - inject HTML code in HTML files
* [Elysia HTTP Error](https://github.com/yfrans/elysia-http-error) - return HTTP errors from Elysia handlers
* [Elysia Http Status Code](https://github.com/sylvain12/elysia-http-status-code) - integrate HTTP status codes
* [NoCache](https://github.com/gaurishhs/elysia-nocache) - disable caching
* [Elysia Tailwind](https://github.com/gtramontina/elysia-tailwind) - compile [Tailwindcss](https://tailwindcss.com/) in a plugin.
* [Elysia Compression](https://github.com/gusb3ll/elysia-compression) - compress response
* [Elysia IP](https://github.com/gaurishhs/elysia-ip) - get the IP Address
* [OAuth2 Server](https://github.com/myazarc/elysia-oauth2-server) - developing an OAuth2 Server with Elysia
* [Elysia Flash Messages](https://github.com/gtramontina/elysia-flash-messages) - enable flash messages
* [Elysia AuthKit](https://github.com/gtramontina/elysia-authkit) - unnoficial [WorkOS' AuthKit](https://www.authkit.com/) authentication
* [Elysia Error Handler](https://github.com/gtramontina/elysia-error-handler) - simpler error handling
* [Elysia env](https://github.com/yolk-oss/elysia-env) - typesafe environment variables with typebox
* [Elysia Drizzle Schema](https://github.com/Edsol/elysia-drizzle-schema) - helps to use Drizzle ORM schema inside Elysia OpenAPI model.
* [Unify-Elysia](https://github.com/qlaffont/unify-elysia) - unify error code for Elysia
* [Unify-Elysia-GQL](https://github.com/qlaffont/unify-elysia-gql) - unify error code for Elysia GraphQL Server (Yoga & Apollo)
* [Elysia Auth Drizzle](https://github.com/qlaffont/elysia-auth-drizzle) - library who handle authentification with JWT (Header/Cookie/QueryParam).
* [graceful-server-elysia](https://github.com/qlaffont/graceful-server-elysia) - library inspired by [graceful-server](https://github.com/gquittet/graceful-server).
* [Logixlysia](https://github.com/PunGrumpy/logixlysia) - a beautiful and simple logging middleware for ElysiaJS with colors and timestamps.
* [Elysia Fault](https://github.com/vitorpldev/elysia-fault) - a simple and customizable error handling middleware with the possibility of creating your own HTTP errors
* [Elysia Compress](https://github.com/vermaysha/elysia-compress) - ElysiaJS plugin to compress responses inspired by [@fastify/compress](https://github.com/fastify/fastify-compress)
* [@labzzhq/compressor](https://github.com/labzzhq/compressor/) - Compact Brilliance, Expansive Results: HTTP Compressor for Elysia and Bunnyhop with gzip, deflate and brotli support.
* [Elysia Accepts](https://github.com/morigs/elysia-accepts) - Elysia plugin for accept headers parsing and content negotiation
* [Elysia Compression](https://github.com/chneau/elysia-compression) - Elysia plugin for compressing responses
* [Elysia Logger](https://github.com/chneau/elysia-logger) - Elysia plugin for logging HTTP requests and responses inspired by [hono/logger](https://hono.dev/docs/middleware/builtin/logger)
* [Elysia CQRS](https://github.com/jassix/elysia-cqrs) - Elysia plugin for CQRS pattern
* [Elysia Supabase](https://github.com/mastermakrela/elysia-supabase) - Seamlessly integrate [Supabase](https://supabase.com/) authentication and database functionality into Elysia, allowing easy access to authenticated user data and Supabase client instance. Especially useful for [Edge Functions](https://supabase.com/docs/guides/functions).
* [Elysia XSS](https://www.npmjs.com/package/elysia-xss) - a plugin for Elysia.js that provides XSS (Cross-Site Scripting) protection by sanitizing request body data.
* [Elysiajs Helmet](https://www.npmjs.com/package/elysiajs-helmet) - a comprehensive security middleware for Elysia.js applications that helps secure your apps by setting various HTTP headers.
* [Decorators for Elysia.js](https://github.com/Ateeb-Khan-97/better-elysia) - seamlessly develop and integrate APIs, Websocket and Streaming APIs with this small library.
* [Elysia Protobuf](https://github.com/ilyhalight/elysia-protobuf) - support protobuf for Elysia.
* [Elysia Prometheus](https://github.com/m1handr/elysia-prometheus) - Elysia plugin for exposing HTTP metrics for Prometheus.
* [Elysia Remote DTS](https://github.com/rayriffy/elysia-remote-dts) - A plugin that provide .d.ts types remotely for Eden Treaty to consume.
* [Cap Checkpoint plugin for Elysia](https://capjs.js.org/guide/middleware/elysia.html) - Cloudflare-like middleware for Cap, a lightweight, modern open-source CAPTCHA alternative designed using SHA-256 PoW.
* [Elysia Background](https://github.com/staciax/elysia-background) - A background task processing plugin for Elysia.js
* [@fedify/elysia](https://github.com/fedify-dev/fedify/tree/main/packages/elysia) - A plugin that provides seamless integration with [Fedify](https://fedify.dev/), the ActivityPub server framework.
* [elysia-healthcheck](https://github.com/iam-medvedev/elysia-healthcheck) - Healthcheck plugin for Elysia.js
* [elysia-csrf](https://github.com/lauhon/elysia-csrf) - A CSRF plugin, ported from [express-csrf](https://github.com/expressjs/csurf)
* [elysia-local-https](https://github.com/mrtcmn/elysia-local-https) - Automatic local HTTPS for Elysia — certs generated, managed, and refreshed in one line.
* [Eden TanStack Query](https://github.com/xkelxmc/eden-tanstack-query) - type-safe TanStack Query integration for Eden, like
  @trpc/react-query but for Elysia

* [prismabox](https://github.com/m1212e/prismabox) - Generator for typebox schemes based on your database models, works well with elysia

If you have a plugin written for Elysia, feel free to add your plugin to the list by **clicking Edit this page on GitHub** below 👇

---

## HTML Plugin

**URL:** https://elysiajs.com/plugins/html.md

**Contents:**
- JSX
- XSS
- Options
  - contentType
  - autoDetect
  - autoDoctype
  - isHtml

---
url: 'https://elysiajs.com/plugins/html.md'
---

Allows you to use [JSX](#jsx) and HTML with proper headers and support.

This plugin will automatically add `Content-Type: text/html; charset=utf8` header to the response, add `<!doctype html>`, and convert it into a Response object.

Elysia HTML is based on [@kitajs/html](https://github.com/kitajs/html) allowing us to define JSX to string in compile time to achieve high performance.

Name your file that needs to use JSX to end with affix **"x"**:

* .js -> .jsx
* .ts -> .tsx

To register the TypeScript type, please append the following to **tsconfig.json**:

That's it, now you can use JSX as your template engine:

If the error `Cannot find name 'Html'. Did you mean 'html'?` occurs, this import must be added to the JSX template:

It is important that it is written in uppercase.

Elysia HTML is based use of the Kita HTML plugin to detect possible XSS attacks in compile time.

You can use a dedicated `safe` attribute to sanitize user value to prevent XSS vulnerability.

However, when are building a large-scale app, it's best to have a type reminder to detect possible XSS vulnerabilities in your codebase.

To add a type-safe reminder, please install:

Then appends the following **tsconfig.json**

* Type: `string`
* Default: `'text/html; charset=utf8'`

The content-type of the response.

* Type: `boolean`
* Default: `true`

Whether to automatically detect HTML content and set the content-type.

* Type: `boolean | 'full'`
* Default: `true`

Whether to automatically add `<!doctype html>` to a response starting with `<html>`, if not found.

Use `full` to also automatically add doctypes on responses returned without this plugin

* Type: `(value: string) => boolean`
* Default: `isHtml` (exported function)

The function is used to detect if a string is a html or not. Default implementation if length is greater than 7, starts with `<` and ends with `>`.

Keep in mind there's no real way to validate HTML, so the default implementation is a best guess.

**Examples:**

Example 1 (bash):
```bash
bun add @elysiajs/html
```

Example 2 (unknown):
```unknown
This plugin will automatically add `Content-Type: text/html; charset=utf8` header to the response, add `<!doctype html>`, and convert it into a Response object.

## JSX

Elysia HTML is based on [@kitajs/html](https://github.com/kitajs/html) allowing us to define JSX to string in compile time to achieve high performance.

Name your file that needs to use JSX to end with affix **"x"**:

* .js -> .jsx
* .ts -> .tsx

To register the TypeScript type, please append the following to **tsconfig.json**:
```

Example 3 (unknown):
```unknown
That's it, now you can use JSX as your template engine:
```

Example 4 (unknown):
```unknown
If the error `Cannot find name 'Html'. Did you mean 'html'?` occurs, this import must be added to the JSX template:
```

---

## Swagger Plugin

**URL:** https://elysiajs.com/plugins/swagger.md

**Contents:**
- Config
  - provider
  - scalar
  - swagger
  - excludeStaticFile
  - path
  - exclude
- Pattern
- Change Swagger Endpoint
- Customize Swagger info

---
url: 'https://elysiajs.com/plugins/swagger.md'
---

::: warning
Swagger plugin is deprecated and is no longer be maintained. Please use [OpenAPI plugin](/plugins/openapi) instead.
:::

This plugin generates a Swagger endpoint for an Elysia server

Accessing `/swagger` would show you a Scalar UI with the generated endpoint documentation from the Elysia server. You can also access the raw OpenAPI spec at `/swagger/json`.

Below is a config which is accepted by the plugin

UI Provider for documentation. Default to Scalar.

Configuration for customizing Scalar.

Please refer to the [Scalar config](https://github.com/scalar/scalar/blob/main/documentation/configuration.md)

Configuration for customizing Swagger.

Please refer to the [Swagger specification](https://swagger.io/specification/v2/).

Determine if Swagger should exclude static files.

Endpoint to expose Swagger

Paths to exclude from Swagger documentation.

Value can be one of the following:

* **string**
* **RegExp**
* **Array\<string | RegExp>**

Below you can find the common patterns to use the plugin.

You can change the swagger endpoint by setting [path](#path) in the plugin config.

Elysia can separate the endpoints into groups by using the Swaggers tag system

Firstly define the available tags in the swagger config object

Then use the details property of the endpoint configuration section to assign that endpoint to the group

Which will produce a swagger page like the following

To secure your API endpoints, you can define security schemes in the Swagger configuration. The example below demonstrates how to use Bearer Authentication (JWT) to protect your endpoints:

This configuration ensures that all endpoints under the `/address` prefix require a valid JWT token for access.

**Examples:**

Example 1 (bash):
```bash
bun add @elysiajs/swagger
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'
import { swagger } from '@elysiajs/swagger'

new Elysia()
    .use(swagger())
    .get('/', () => 'hi')
    .post('/hello', () => 'world')
    .listen(3000)
```

Example 3 (typescript):
```typescript
import { Elysia } from 'elysia'
import { swagger } from '@elysiajs/swagger'

new Elysia()
    .use(
        swagger({
            path: '/v2/swagger'
        })
    )
    .listen(3000)
```

Example 4 (typescript):
```typescript
import { Elysia } from 'elysia'
import { swagger } from '@elysiajs/swagger'

new Elysia()
    .use(
        swagger({
            documentation: {
                info: {
                    title: 'Elysia Documentation',
                    version: '1.0.0'
                }
            }
        })
    )
    .listen(3000)
```

---

## CORS Plugin

**URL:** https://elysiajs.com/plugins/cors.md

**Contents:**
- Config
  - origin
  - methods
  - allowedHeaders
  - exposeHeaders
  - credentials
  - maxAge
  - preflight
- Pattern
- Allow CORS by top-level domain

---
url: 'https://elysiajs.com/plugins/cors.md'
---

This plugin adds support for customizing [Cross-Origin Resource Sharing](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) behavior.

This will set Elysia to accept requests from any origin.

Below is a config which is accepted by the plugin

Indicates whether the response can be shared with the requesting code from the given origins.

Value can be one of the following:

* **string** - Name of origin which will directly assign to [Access-Control-Allow-Origin](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin) header.
* **boolean** - If set to true, [Access-Control-Allow-Origin](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin) will be set to `*` (any origins)
* **RegExp** - Pattern to match request's URL, allowed if matched.
* **Function** - Custom logic to allow resource sharing, allow if `true` is returned.
  * Expected to have the type of:
  
* **Array\<string | RegExp | Function>** - iterate through all cases above in order, allowed if any of the values are `true`.

Allowed methods for cross-origin requests.

Assign [Access-Control-Allow-Methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Methods) header.

Value can be one of the following:

* **undefined | null | ''** - Ignore all methods.
* **\*** - Allows all methods.
* **string** - Expects either a single method or a comma-delimited string
  * (eg: `'GET, PUT, POST'`)
* **string\[]** - Allow multiple HTTP methods.
  * eg: `['GET', 'PUT', 'POST']`

Allowed headers for an incoming request.

Assign [Access-Control-Allow-Headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Headers) header.

Value can be one of the following:

* **string** - Expects either a single header or a comma-delimited string
  * eg: `'Content-Type, Authorization'`.
* **string\[]** - Allow multiple HTTP headers.
  * eg: `['Content-Type', 'Authorization']`

Response CORS with specified headers.

Assign [Access-Control-Expose-Headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Expose-Headers) header.

Value can be one of the following:

* **string** - Expects either a single header or a comma-delimited string.
  * eg: `'Content-Type, X-Powered-By'`.
* **string\[]** - Allow multiple HTTP headers.
  * eg: `['Content-Type', 'X-Powered-By']`

The Access-Control-Allow-Credentials response header tells browsers whether to expose the response to the frontend JavaScript code when the request's credentials mode [Request.credentials](https://developer.mozilla.org/en-US/docs/Web/API/Request/credentials) is `include`.

When a request's credentials mode [Request.credentials](https://developer.mozilla.org/en-US/docs/Web/API/Request/credentials) is `include`, browsers will only expose the response to the frontend JavaScript code if the Access-Control-Allow-Credentials value is true.

Credentials are cookies, authorization headers, or TLS client certificates.

Assign [Access-Control-Allow-Credentials](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Credentials) header.

Indicates how long the results of a [preflight request](https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request) (that is the information contained in the [Access-Control-Allow-Methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Methods) and [Access-Control-Allow-Headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Headers) headers) can be cached.

Assign [Access-Control-Max-Age](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Max-Age) header.

The preflight request is a request sent to check if the CORS protocol is understood and if a server is aware of using specific methods and headers.

Response with **OPTIONS** request with 3 HTTP request headers:

* **Access-Control-Request-Method**
* **Access-Control-Request-Headers**
* **Origin**

This config indicates if the server should respond to preflight requests.

Below you can find the common patterns to use the plugin.

This will allow requests from top-level domains with `saltyaom.com`

**Examples:**

Example 1 (bash):
```bash
bun add @elysiajs/cors
```

Example 2 (unknown):
```unknown
This will set Elysia to accept requests from any origin.

## Config

Below is a config which is accepted by the plugin

### origin

@default `true`

Indicates whether the response can be shared with the requesting code from the given origins.

Value can be one of the following:

* **string** - Name of origin which will directly assign to [Access-Control-Allow-Origin](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin) header.
* **boolean** - If set to true, [Access-Control-Allow-Origin](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin) will be set to `*` (any origins)
* **RegExp** - Pattern to match request's URL, allowed if matched.
* **Function** - Custom logic to allow resource sharing, allow if `true` is returned.
  * Expected to have the type of:
```

Example 3 (unknown):
```unknown
* **Array\<string | RegExp | Function>** - iterate through all cases above in order, allowed if any of the values are `true`.

***

### methods

@default `*`

Allowed methods for cross-origin requests.

Assign [Access-Control-Allow-Methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Methods) header.

Value can be one of the following:

* **undefined | null | ''** - Ignore all methods.
* **\*** - Allows all methods.
* **string** - Expects either a single method or a comma-delimited string
  * (eg: `'GET, PUT, POST'`)
* **string\[]** - Allow multiple HTTP methods.
  * eg: `['GET', 'PUT', 'POST']`

***

### allowedHeaders

@default `*`

Allowed headers for an incoming request.

Assign [Access-Control-Allow-Headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Headers) header.

Value can be one of the following:

* **string** - Expects either a single header or a comma-delimited string
  * eg: `'Content-Type, Authorization'`.
* **string\[]** - Allow multiple HTTP headers.
  * eg: `['Content-Type', 'Authorization']`

***

### exposeHeaders

@default `*`

Response CORS with specified headers.

Assign [Access-Control-Expose-Headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Expose-Headers) header.

Value can be one of the following:

* **string** - Expects either a single header or a comma-delimited string.
  * eg: `'Content-Type, X-Powered-By'`.
* **string\[]** - Allow multiple HTTP headers.
  * eg: `['Content-Type', 'X-Powered-By']`

***

### credentials

@default `true`

The Access-Control-Allow-Credentials response header tells browsers whether to expose the response to the frontend JavaScript code when the request's credentials mode [Request.credentials](https://developer.mozilla.org/en-US/docs/Web/API/Request/credentials) is `include`.

When a request's credentials mode [Request.credentials](https://developer.mozilla.org/en-US/docs/Web/API/Request/credentials) is `include`, browsers will only expose the response to the frontend JavaScript code if the Access-Control-Allow-Credentials value is true.

Credentials are cookies, authorization headers, or TLS client certificates.

Assign [Access-Control-Allow-Credentials](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Credentials) header.

***

### maxAge

@default `5`

Indicates how long the results of a [preflight request](https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request) (that is the information contained in the [Access-Control-Allow-Methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Methods) and [Access-Control-Allow-Headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Headers) headers) can be cached.

Assign [Access-Control-Max-Age](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Max-Age) header.

***

### preflight

The preflight request is a request sent to check if the CORS protocol is understood and if a server is aware of using specific methods and headers.

Response with **OPTIONS** request with 3 HTTP request headers:

* **Access-Control-Request-Method**
* **Access-Control-Request-Headers**
* **Origin**

This config indicates if the server should respond to preflight requests.

## Pattern

Below you can find the common patterns to use the plugin.

## Allow CORS by top-level domain
```

---

## JWT Plugin

**URL:** https://elysiajs.com/plugins/jwt.md

**Contents:**
- Config
  - name
  - secret
  - schema
  - alg
  - iss
  - sub
  - aud
  - jti
  - nbf

---
url: 'https://elysiajs.com/plugins/jwt.md'
---

This plugin adds support for using JWT in Elysia handlers.

This plugin extends config from [jose](https://github.com/panva/jose).

Below is a config that is accepted by the plugin.

Name to register `jwt` function as.

For example, `jwt` function will be registered with a custom name.

Because some might need to use multiple `jwt` with different configs in a single server, explicitly registering the JWT function with a different name is needed.

The private key to sign JWT payload with.

Type strict validation for JWT payload.

Below is a config that extends from [cookie](https://npmjs.com/package/cookie)

Signing Algorithm to sign JWT payload with.

Possible properties for jose are:
HS256
HS384
HS512
PS256
PS384
PS512
RS256
RS384
RS512
ES256
ES256K
ES384
ES512
EdDSA

The issuer claim identifies the principal that issued the JWT as per [RFC7519](https://www.rfc-editor.org/rfc/rfc7519#section-4.1.1)

TLDR; is usually (the domain) name of the signer.

The subject claim identifies the principal that is the subject of the JWT.

The claims in a JWT are normally statements about the subject as per [RFC7519](https://www.rfc-editor.org/rfc/rfc7519#section-4.1.2)

The audience claim identifies the recipients that the JWT is intended for.

Each principal intended to process the JWT MUST identify itself with a value in the audience claim as per [RFC7519](https://www.rfc-editor.org/rfc/rfc7519#section-4.1.3)

JWT ID claim provides a unique identifier for the JWT as per [RFC7519](https://www.rfc-editor.org/rfc/rfc7519#section-4.1.7)

The "not before" claim identifies the time before which the JWT must not be accepted for processing as per [RFC7519](https://www.rfc-editor.org/rfc/rfc7519#section-4.1.5)

The expiration time claim identifies the expiration time on or after which the JWT MUST NOT be accepted for processing as per [RFC7519](https://www.rfc-editor.org/rfc/rfc7519#section-4.1.4)

The "issued at" claim identifies the time at which the JWT was issued.

This claim can be used to determine the age of the JWT as per [RFC7519](https://www.rfc-editor.org/rfc/rfc7519#section-4.1.6)

This JWS Extension Header Parameter modifies the JWS Payload representation and the JWS Signing input computation as per [RFC7797](https://www.rfc-editor.org/rfc/rfc7797).

A hint indicating which key was used to secure the JWS.

This parameter allows originators to explicitly signal a change of key to recipients as per [RFC7515](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.4)

(X.509 certificate SHA-1 thumbprint) header parameter is a base64url-encoded SHA-1 digest of the DER encoding of the X.509 certificate [RFC5280](https://www.rfc-editor.org/rfc/rfc5280) corresponding to the key used to digitally sign the JWS as per [RFC7515](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.7)

(X.509 certificate chain) header parameter contains the X.509 public key certificate or certificate chain [RFC5280](https://www.rfc-editor.org/rfc/rfc5280) corresponding to the key used to digitally sign the JWS as per [RFC7515](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.6)

(X.509 URL) header parameter is a URI [RFC3986](https://www.rfc-editor.org/rfc/rfc3986) that refers to a resource for the X.509 public key certificate or certificate chain \[RFC5280] corresponding to the key used to digitally sign the JWS as per [RFC7515](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.5)

The "jku" (JWK Set URL) Header Parameter is a URI \[RFC3986] that refers to a resource for a set of JSON-encoded public keys, one of which corresponds to the key used to digitally sign the JWS.

The keys MUST be encoded as a JWK Set \[JWK] as per [RFC7515](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.2)

The `typ` (type) Header Parameter is used by JWS applications to declare the media type \[IANA.MediaTypes] of this complete JWS.

This is intended for use by the application when more than one kind of object could be present in an application data structure that can contain a JWS as per [RFC7515](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.9)

Content-Type parameter is used by JWS applications to declare the media type \[IANA.MediaTypes] of the secured content (the payload).

This is intended for use by the application when more than one kind of object could be present in the JWS Payload as per [RFC7515](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.9)

Below are the value added to the handler.

A dynamic object of collection related to use with JWT registered by the JWT plugin.

`JWTPayloadSpec` accepts the same value as [JWT config](#config)

Verify payload with the provided JWT config

`JWTPayloadSpec` accepts the same value as [JWT config](#config)

Below you can find the common patterns to use the plugin.

By default, the config is passed to `setCookie` and inherits its value.

This will sign JWT with an expiration date of the next 7 days.

**Examples:**

Example 1 (bash):
```bash
bun add @elysiajs/jwt
```

Example 2 (unknown):
```unknown
:::

## Config

This plugin extends config from [jose](https://github.com/panva/jose).

Below is a config that is accepted by the plugin.

### name

Name to register `jwt` function as.

For example, `jwt` function will be registered with a custom name.
```

Example 3 (unknown):
```unknown
Because some might need to use multiple `jwt` with different configs in a single server, explicitly registering the JWT function with a different name is needed.

### secret

The private key to sign JWT payload with.

### schema

Type strict validation for JWT payload.

***

Below is a config that extends from [cookie](https://npmjs.com/package/cookie)

### alg

@default `HS256`

Signing Algorithm to sign JWT payload with.

Possible properties for jose are:
HS256
HS384
HS512
PS256
PS384
PS512
RS256
RS384
RS512
ES256
ES256K
ES384
ES512
EdDSA

### iss

The issuer claim identifies the principal that issued the JWT as per [RFC7519](https://www.rfc-editor.org/rfc/rfc7519#section-4.1.1)

TLDR; is usually (the domain) name of the signer.

### sub

The subject claim identifies the principal that is the subject of the JWT.

The claims in a JWT are normally statements about the subject as per [RFC7519](https://www.rfc-editor.org/rfc/rfc7519#section-4.1.2)

### aud

The audience claim identifies the recipients that the JWT is intended for.

Each principal intended to process the JWT MUST identify itself with a value in the audience claim as per [RFC7519](https://www.rfc-editor.org/rfc/rfc7519#section-4.1.3)

### jti

JWT ID claim provides a unique identifier for the JWT as per [RFC7519](https://www.rfc-editor.org/rfc/rfc7519#section-4.1.7)

### nbf

The "not before" claim identifies the time before which the JWT must not be accepted for processing as per [RFC7519](https://www.rfc-editor.org/rfc/rfc7519#section-4.1.5)

### exp

The expiration time claim identifies the expiration time on or after which the JWT MUST NOT be accepted for processing as per [RFC7519](https://www.rfc-editor.org/rfc/rfc7519#section-4.1.4)

### iat

The "issued at" claim identifies the time at which the JWT was issued.

This claim can be used to determine the age of the JWT as per [RFC7519](https://www.rfc-editor.org/rfc/rfc7519#section-4.1.6)

### b64

This JWS Extension Header Parameter modifies the JWS Payload representation and the JWS Signing input computation as per [RFC7797](https://www.rfc-editor.org/rfc/rfc7797).

### kid

A hint indicating which key was used to secure the JWS.

This parameter allows originators to explicitly signal a change of key to recipients as per [RFC7515](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.4)

### x5t

(X.509 certificate SHA-1 thumbprint) header parameter is a base64url-encoded SHA-1 digest of the DER encoding of the X.509 certificate [RFC5280](https://www.rfc-editor.org/rfc/rfc5280) corresponding to the key used to digitally sign the JWS as per [RFC7515](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.7)

### x5c

(X.509 certificate chain) header parameter contains the X.509 public key certificate or certificate chain [RFC5280](https://www.rfc-editor.org/rfc/rfc5280) corresponding to the key used to digitally sign the JWS as per [RFC7515](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.6)

### x5u

(X.509 URL) header parameter is a URI [RFC3986](https://www.rfc-editor.org/rfc/rfc3986) that refers to a resource for the X.509 public key certificate or certificate chain \[RFC5280] corresponding to the key used to digitally sign the JWS as per [RFC7515](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.5)

### jwk

The "jku" (JWK Set URL) Header Parameter is a URI \[RFC3986] that refers to a resource for a set of JSON-encoded public keys, one of which corresponds to the key used to digitally sign the JWS.

The keys MUST be encoded as a JWK Set \[JWK] as per [RFC7515](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.2)

### typ

The `typ` (type) Header Parameter is used by JWS applications to declare the media type \[IANA.MediaTypes] of this complete JWS.

This is intended for use by the application when more than one kind of object could be present in an application data structure that can contain a JWS as per [RFC7515](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.9)

### ctr

Content-Type parameter is used by JWS applications to declare the media type \[IANA.MediaTypes] of the secured content (the payload).

This is intended for use by the application when more than one kind of object could be present in the JWS Payload as per [RFC7515](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.9)

## Handler

Below are the value added to the handler.

### jwt.sign

A dynamic object of collection related to use with JWT registered by the JWT plugin.

Type:
```

Example 4 (unknown):
```unknown
`JWTPayloadSpec` accepts the same value as [JWT config](#config)

### jwt.verify

Verify payload with the provided JWT config

Type:
```

---

## Bearer Plugin

**URL:** https://elysiajs.com/plugins/bearer.md

---
url: 'https://elysiajs.com/plugins/bearer.md'
---

Plugin for [elysia](https://github.com/elysiajs/elysia) for retrieving the Bearer token.

This plugin is for retrieving a Bearer token specified in [RFC6750](https://www.rfc-editor.org/rfc/rfc6750#section-2).

This plugin DOES NOT handle authentication validation for your server. Instead, the plugin leaves the decision to developers to apply logic for handling validation check themselves.

**Examples:**

Example 1 (bash):
```bash
bun add @elysiajs/bearer
```

---

## OpenAPI Plugin&#x20;

**URL:** https://elysiajs.com/plugins/openapi.md

**Contents:**
- Detail
- detail.hide
  - detail.deprecated
  - detail.description
  - detail.summary
- Config
- enabled
- documentation
- exclude
- exclude.methods

---
url: 'https://elysiajs.com/plugins/openapi.md'
---

Plugin for [elysia](https://github.com/elysiajs/elysia) to auto-generate API documentation page.

Accessing `/openapi` would show you a Scalar UI with the generated endpoint documentation from the Elysia server. You can also access the raw OpenAPI spec at `/openapi/json`.

::: tip
This page is the plugin configuration reference.

If you're looking for a common patterns or an advanced usage of OpenAPI, check out [Patterns: OpenAPI](/patterns/openapi)
:::

`detail` extends the [OpenAPI Operation Object](https://spec.openapis.org/oas/v3.0.3.html#operation-object)

The detail field is an object that can be used to describe information about the route for API documentation.

It may contain the following fields:

You can hide the route from the Swagger page by setting `detail.hide` to `true`

Declares this operation to be deprecated. Consumers SHOULD refrain from usage of the declared operation. Default value is `false`.

A verbose explanation of the operation behavior.

A short summary of what the operation does.

Below is a config which is accepted by the plugin

@default true
Enable/Disable the plugin

OpenAPI documentation information

@see https://spec.openapis.org/oas/v3.0.3.html

Configuration to exclude paths or methods from documentation

List of methods to exclude from documentation

List of paths to exclude from documentation

Exclude static file routes from documentation

List of tags to exclude from documentation

A custom mapping function from Standard schema to OpenAPI schema

The endpoint to expose OpenAPI documentation frontend

OpenAPI documentation frontend between:

* [Scalar](https://github.com/scalar/scalar)
* [SwaggerUI](https://github.com/swagger-api/swagger-ui)
* null: disable frontend

Additional OpenAPI reference for each endpoint

Scalar configuration, refers to [Scalar config](https://github.com/scalar/scalar/blob/main/documentation/configuration.md)

@default '/${path}/json'

The endpoint to expose OpenAPI specification in JSON format

Swagger config, refers to [Swagger config](https://swagger.io/docs/open-source-tools/swagger-ui/usage/configuration/)

Below you can find the common patterns to use the plugin.

**Examples:**

Example 1 (bash):
```bash
bun add @elysiajs/openapi
```

Example 2 (unknown):
```unknown
Accessing `/openapi` would show you a Scalar UI with the generated endpoint documentation from the Elysia server. You can also access the raw OpenAPI spec at `/openapi/json`.

::: tip
This page is the plugin configuration reference.

If you're looking for a common patterns or an advanced usage of OpenAPI, check out [Patterns: OpenAPI](/patterns/openapi)
:::

## Detail

`detail` extends the [OpenAPI Operation Object](https://spec.openapis.org/oas/v3.0.3.html#operation-object)

The detail field is an object that can be used to describe information about the route for API documentation.

It may contain the following fields:

## detail.hide

You can hide the route from the Swagger page by setting `detail.hide` to `true`
```

Example 3 (unknown):
```unknown
### detail.deprecated

Declares this operation to be deprecated. Consumers SHOULD refrain from usage of the declared operation. Default value is `false`.

### detail.description

A verbose explanation of the operation behavior.

### detail.summary

A short summary of what the operation does.

## Config

Below is a config which is accepted by the plugin

## enabled

@default true
Enable/Disable the plugin

## documentation

OpenAPI documentation information

@see https://spec.openapis.org/oas/v3.0.3.html

## exclude

Configuration to exclude paths or methods from documentation

## exclude.methods

List of methods to exclude from documentation

## exclude.paths

List of paths to exclude from documentation

## exclude.staticFile

@default true

Exclude static file routes from documentation

## exclude.tags

List of tags to exclude from documentation

## mapJsonSchema

A custom mapping function from Standard schema to OpenAPI schema

### Example
```

---

## Static Plugin

**URL:** https://elysiajs.com/plugins/static.md

**Contents:**
- Config
  - assets
  - prefix
  - ignorePatterns
  - staticLimit
  - alwaysStatic
  - headers
  - indexHTML
- Pattern
- Single file

---
url: 'https://elysiajs.com/plugins/static.md'
---

This plugin can serve static files/folders for Elysia Server

By default, the static plugin default folder is `public`, and registered with `/public` prefix.

Suppose your project structure is:

The available path will become:

* /public/takodachi.png
* /public/nested/takodachi.png

Below is a config which is accepted by the plugin

Path to the folder to expose as static

Path prefix to register public files

List of files to ignore from serving as static files

By default, the static plugin will register paths to the Router with a static name, if the limits are exceeded, paths will be lazily added to the Router to reduce memory usage.
Tradeoff memory with performance.

If set to true, static files path will be registered to Router skipping the `staticLimits`.

Set response headers of files

If set to true, the `index.html` file from the static directory will be served for any request that is matching neither a route nor any existing static file.

Below you can find the common patterns to use the plugin.

* [Single File](#single-file)

Suppose you want to return just a single file, you can use `file` instead of using the static plugin

**Examples:**

Example 1 (bash):
```bash
bun add @elysiajs/static
```

Example 2 (unknown):
```unknown
By default, the static plugin default folder is `public`, and registered with `/public` prefix.

Suppose your project structure is:
```

Example 3 (unknown):
```unknown
The available path will become:

* /public/takodachi.png
* /public/nested/takodachi.png

## Config

Below is a config which is accepted by the plugin

### assets

@default `"public"`

Path to the folder to expose as static

### prefix

@default `"/public"`

Path prefix to register public files

### ignorePatterns

@default `[]`

List of files to ignore from serving as static files

### staticLimit

@default `1024`

By default, the static plugin will register paths to the Router with a static name, if the limits are exceeded, paths will be lazily added to the Router to reduce memory usage.
Tradeoff memory with performance.

### alwaysStatic

@default `false`

If set to true, static files path will be registered to Router skipping the `staticLimits`.

### headers

@default `{}`

Set response headers of files

### indexHTML

@default `false`

If set to true, the `index.html` file from the static directory will be served for any request that is matching neither a route nor any existing static file.

## Pattern

Below you can find the common patterns to use the plugin.

* [Single File](#single-file)

## Single file

Suppose you want to return just a single file, you can use `file` instead of using the static plugin
```

---

## Server Timing Plugin

**URL:** https://elysiajs.com/plugins/server-timing.md

**Contents:**
- Config
  - enabled
  - allow
  - trace
- Pattern
- Allow Condition

---
url: 'https://elysiajs.com/plugins/server-timing.md'
---

This plugin adds support for auditing performance bottlenecks with Server Timing API

Server Timing then will append header 'Server-Timing' with log duration, function name, and detail for each life-cycle function.

To inspect, open browser developer tools > Network > \[Request made through Elysia server] > Timing.

![Developer tools showing Server Timing screenshot](/assets/server-timing.webp)

Now you can effortlessly audit the performance bottleneck of your server.

Below is a config which is accepted by the plugin

@default `NODE_ENV !== 'production'`

Determine whether or not Server Timing should be enabled

A condition whether server timing should be log

Allow Server Timing to log specified life-cycle events:

Trace accepts objects of the following:

* request: capture duration from request
* parse: capture duration from parse
* transform: capture duration from transform
* beforeHandle: capture duration from beforeHandle
* handle: capture duration from the handle
* afterHandle: capture duration from afterHandle
* total: capture total duration from start to finish

Below you can find the common patterns to use the plugin.

* [Allow Condition](#allow-condition)

You may disable Server Timing on specific routes via `allow` property

**Examples:**

Example 1 (bash):
```bash
bun add @elysiajs/server-timing
```

Example 2 (unknown):
```unknown
Server Timing then will append header 'Server-Timing' with log duration, function name, and detail for each life-cycle function.

To inspect, open browser developer tools > Network > \[Request made through Elysia server] > Timing.

![Developer tools showing Server Timing screenshot](/assets/server-timing.webp)

Now you can effortlessly audit the performance bottleneck of your server.

## Config

Below is a config which is accepted by the plugin

### enabled

@default `NODE_ENV !== 'production'`

Determine whether or not Server Timing should be enabled

### allow

@default `undefined`

A condition whether server timing should be log

### trace

@default `undefined`

Allow Server Timing to log specified life-cycle events:

Trace accepts objects of the following:

* request: capture duration from request
* parse: capture duration from parse
* transform: capture duration from transform
* beforeHandle: capture duration from beforeHandle
* handle: capture duration from the handle
* afterHandle: capture duration from afterHandle
* total: capture total duration from start to finish

## Pattern

Below you can find the common patterns to use the plugin.

* [Allow Condition](#allow-condition)

## Allow Condition

You may disable Server Timing on specific routes via `allow` property
```

---

## GraphQL Yoga Plugin

**URL:** https://elysiajs.com/plugins/graphql-yoga.md

**Contents:**
- Resolver
- Context
- Config
  - path

---
url: 'https://elysiajs.com/plugins/graphql-yoga.md'
---

This plugin integrates GraphQL yoga with Elysia

Accessing `/graphql` in the browser (GET request) would show you a GraphiQL instance for the GraphQL-enabled Elysia server.

optional: you can install a custom version of optional peer dependencies as well:

Elysia uses [Mobius](https://github.com/saltyaom/mobius) to infer type from **typeDefs** field automatically, allowing you to get full type-safety and auto-complete when typing **resolver** types.

You can add custom context to the resolver function by adding **context**

This plugin extends [GraphQL Yoga's createYoga options, please refer to the GraphQL Yoga documentation](https://the-guild.dev/graphql/yoga-server/docs) with inlining `schema` config to root.

Below is a config which is accepted by the plugin

Endpoint to expose GraphQL handler

**Examples:**

Example 1 (bash):
```bash
bun add @elysiajs/graphql-yoga
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'
import { yoga } from '@elysiajs/graphql-yoga'

const app = new Elysia()
	.use(
		yoga({
			typeDefs: /* GraphQL */ `
				type Query {
					hi: String
				}
			`,
			resolvers: {
				Query: {
					hi: () => 'Hello from Elysia'
				}
			}
		})
	)
	.listen(3000)
```

Example 3 (bash):
```bash
bun add graphql graphql-yoga
```

Example 4 (ts):
```ts
import { Elysia } from 'elysia'
import { yoga } from '@elysiajs/graphql-yoga'

const app = new Elysia()
	.use(
		yoga({
			typeDefs: /* GraphQL */ `
				type Query {
					hi: String
				}
			`,
			context: {
				name: 'Mobius'
			},
			// If context is a function on this doesn't present
			// for some reason it won't infer context type
			useContext(_) {},
			resolvers: {
				Query: {
					hi: async (parent, args, context) => context.name
				}
			}
		})
	)
	.listen(3000)
```

---

## GraphQL Apollo Plugin

**URL:** https://elysiajs.com/plugins/graphql-apollo.md

**Contents:**
- Context
- Config
  - path
  - enablePlayground

---
url: 'https://elysiajs.com/plugins/graphql-apollo.md'
---

Plugin for [elysia](https://github.com/elysiajs/elysia) for using GraphQL Apollo.

Accessing `/graphql` should show Apollo GraphQL playground work with.

Because Elysia is based on Web Standard Request and Response which is different from Node's `HttpRequest` and `HttpResponse` that Express uses, results in `req, res` being undefined in context.

Because of this, Elysia replaces both with `context` like route parameters.

This plugin extends Apollo's [ServerRegistration](https://www.apollographql.com/docs/apollo-server/api/apollo-server/#options) (which is `ApolloServer`'s' constructor parameter).

Below are the extended parameters for configuring Apollo Server with Elysia.

@default `"/graphql"`

Path to expose Apollo Server.

@default `process.env.ENV !== 'production'`

Determine whether should Apollo should provide Apollo Playground.

**Examples:**

Example 1 (bash):
```bash
bun add graphql @elysiajs/apollo @apollo/server
```

Example 2 (typescript):
```typescript
import { Elysia } from 'elysia'
import { apollo, gql } from '@elysiajs/apollo'

const app = new Elysia()
	.use(
		apollo({
			typeDefs: gql`
				type Book {
					title: String
					author: String
				}

				type Query {
					books: [Book]
				}
			`,
			resolvers: {
				Query: {
					books: () => {
						return [
							{
								title: 'Elysia',
								author: 'saltyAom'
							}
						]
					}
				}
			}
		})
	)
	.listen(3000)
```

Example 3 (typescript):
```typescript
const app = new Elysia()
	.use(
		apollo({
			typeDefs,
			resolvers,
			context: async ({ request }) => {
				const authorization = request.headers.get('Authorization')

				return {
					authorization
				}
			}
		})
	)
	.listen(3000)
```

---

## Cron Plugin

**URL:** https://elysiajs.com/plugins/cron.md

**Contents:**
- cron
  - name
  - pattern
  - timezone
  - startAt
  - stopAt
  - maxRuns
  - catch
  - interval
- Pattern

---
url: 'https://elysiajs.com/plugins/cron.md'
---

This plugin adds support for running cronjobs in the Elysia server.

The above code will log `heartbeat` every 10 seconds.

Create a cronjob for the Elysia server.

`CronConfig` accepts the parameters specified below:

Job name to register to `store`.

This will register the cron instance to `store` with a specified name, which can be used to reference in later processes eg. stop the job.

Time to run the job as specified by [cron syntax](https://en.wikipedia.org/wiki/Cron) specified as below:

This can be generated by tools like [Crontab Guru](https://crontab.guru/)

This plugin extends the cron method to Elysia using [cronner](https://github.com/hexagon/croner).

Below are the configs accepted by cronner.

Time zone in Europe/Stockholm format

Schedule start time for the job

Schedule stop time for the job

Maximum number of executions

Continue execution even if an unhandled error is thrown by a triggered function.

The minimum interval between executions, in seconds.

Below you can find the common patterns to use the plugin.

You can stop cronjob manually by accessing the cronjob name registered to `store`.

You can use predefined patterns from `@elysiajs/cron/schedule`

| Function                                 | Description                                           |
| ---------------------------------------- | ----------------------------------------------------- |
| `.everySeconds(2)`                       | Run the task every 2 seconds                          |
| `.everyMinutes(5)`                       | Run the task every 5 minutes                          |
| `.everyHours(3)`                         | Run the task every 3 hours                            |
| `.everyHoursAt(3, 15)`                   | Run the task every 3 hours at 15 minutes              |
| `.everyDayAt('04:19')`                   | Run the task every day at 04:19                       |
| `.everyWeekOn(Patterns.MONDAY, '19:30')` | Run the task every Monday at 19:30                    |
| `.everyWeekdayAt('17:00')`               | Run the task every day from Monday to Friday at 17:00 |
| `.everyWeekendAt('11:00')`               | Run the task on Saturday and Sunday at 11:00          |

| Function          | Constant                           |
| ----------------- | ---------------------------------- |
| `.everySecond()`  | EVERY\_SECOND                       |
| `.everyMinute()`  | EVERY\_MINUTE                       |
| `.hourly()`       | EVERY\_HOUR                         |
| `.daily()`        | EVERY\_DAY\_AT\_MIDNIGHT              |
| `.everyWeekday()` | EVERY\_WEEKDAY                      |
| `.everyWeekend()` | EVERY\_WEEKEND                      |
| `.weekly()`       | EVERY\_WEEK                         |
| `.monthly()`      | EVERY\_1ST\_DAY\_OF\_MONTH\_AT\_MIDNIGHT |
| `.everyQuarter()` | EVERY\_QUARTER                      |
| `.yearly()`       | EVERY\_YEAR                         |

| Constant                                 | Pattern              |
| ---------------------------------------- | -------------------- |
| `.EVERY_SECOND`                          | `* * * * * *`        |
| `.EVERY_5_SECONDS`                       | `*/5 * * * * *`      |
| `.EVERY_10_SECONDS`                      | `*/10 * * * * *`     |
| `.EVERY_30_SECONDS`                      | `*/30 * * * * *`     |
| `.EVERY_MINUTE`                          | `*/1 * * * *`        |
| `.EVERY_5_MINUTES`                       | `0 */5 * * * *`      |
| `.EVERY_10_MINUTES`                      | `0 */10 * * * *`     |
| `.EVERY_30_MINUTES`                      | `0 */30 * * * *`     |
| `.EVERY_HOUR`                            | `0 0-23/1 * * *`     |
| `.EVERY_2_HOURS`                         | `0 0-23/2 * * *`     |
| `.EVERY_3_HOURS`                         | `0 0-23/3 * * *`     |
| `.EVERY_4_HOURS`                         | `0 0-23/4 * * *`     |
| `.EVERY_5_HOURS`                         | `0 0-23/5 * * *`     |
| `.EVERY_6_HOURS`                         | `0 0-23/6 * * *`     |
| `.EVERY_7_HOURS`                         | `0 0-23/7 * * *`     |
| `.EVERY_8_HOURS`                         | `0 0-23/8 * * *`     |
| `.EVERY_9_HOURS`                         | `0 0-23/9 * * *`     |
| `.EVERY_10_HOURS`                        | `0 0-23/10 * * *`    |
| `.EVERY_11_HOURS`                        | `0 0-23/11 * * *`    |
| `.EVERY_12_HOURS`                        | `0 0-23/12 * * *`    |
| `.EVERY_DAY_AT_1AM`                      | `0 01 * * *`         |
| `.EVERY_DAY_AT_2AM`                      | `0 02 * * *`         |
| `.EVERY_DAY_AT_3AM`                      | `0 03 * * *`         |
| `.EVERY_DAY_AT_4AM`                      | `0 04 * * *`         |
| `.EVERY_DAY_AT_5AM`                      | `0 05 * * *`         |
| `.EVERY_DAY_AT_6AM`                      | `0 06 * * *`         |
| `.EVERY_DAY_AT_7AM`                      | `0 07 * * *`         |
| `.EVERY_DAY_AT_8AM`                      | `0 08 * * *`         |
| `.EVERY_DAY_AT_9AM`                      | `0 09 * * *`         |
| `.EVERY_DAY_AT_10AM`                     | `0 10 * * *`         |
| `.EVERY_DAY_AT_11AM`                     | `0 11 * * *`         |
| `.EVERY_DAY_AT_NOON`                     | `0 12 * * *`         |
| `.EVERY_DAY_AT_1PM`                      | `0 13 * * *`         |
| `.EVERY_DAY_AT_2PM`                      | `0 14 * * *`         |
| `.EVERY_DAY_AT_3PM`                      | `0 15 * * *`         |
| `.EVERY_DAY_AT_4PM`                      | `0 16 * * *`         |
| `.EVERY_DAY_AT_5PM`                      | `0 17 * * *`         |
| `.EVERY_DAY_AT_6PM`                      | `0 18 * * *`         |
| `.EVERY_DAY_AT_7PM`                      | `0 19 * * *`         |
| `.EVERY_DAY_AT_8PM`                      | `0 20 * * *`         |
| `.EVERY_DAY_AT_9PM`                      | `0 21 * * *`         |
| `.EVERY_DAY_AT_10PM`                     | `0 22 * * *`         |
| `.EVERY_DAY_AT_11PM`                     | `0 23 * * *`         |
| `.EVERY_DAY_AT_MIDNIGHT`                 | `0 0 * * *`          |
| `.EVERY_WEEK`                            | `0 0 * * 0`          |
| `.EVERY_WEEKDAY`                         | `0 0 * * 1-5`        |
| `.EVERY_WEEKEND`                         | `0 0 * * 6,0`        |
| `.EVERY_1ST_DAY_OF_MONTH_AT_MIDNIGHT`    | `0 0 1 * *`          |
| `.EVERY_1ST_DAY_OF_MONTH_AT_NOON`        | `0 12 1 * *`         |
| `.EVERY_2ND_HOUR`                        | `0 */2 * * *`        |
| `.EVERY_2ND_HOUR_FROM_1AM_THROUGH_11PM`  | `0 1-23/2 * * *`     |
| `.EVERY_2ND_MONTH`                       | `0 0 1 */2 *`        |
| `.EVERY_QUARTER`                         | `0 0 1 */3 *`        |
| `.EVERY_6_MONTHS`                        | `0 0 1 */6 *`        |
| `.EVERY_YEAR`                            | `0 0 1 1 *`          |
| `.EVERY_30_MINUTES_BETWEEN_9AM_AND_5PM`  | `0 */30 9-17 * * *`  |
| `.EVERY_30_MINUTES_BETWEEN_9AM_AND_6PM`  | `0 */30 9-18 * * *`  |
| `.EVERY_30_MINUTES_BETWEEN_10AM_AND_7PM` | `0 */30 10-19 * * *` |

**Examples:**

Example 1 (bash):
```bash
bun add @elysiajs/cron
```

Example 2 (unknown):
```unknown
The above code will log `heartbeat` every 10 seconds.

## cron

Create a cronjob for the Elysia server.

type:
```

Example 3 (unknown):
```unknown
`CronConfig` accepts the parameters specified below:

### name

Job name to register to `store`.

This will register the cron instance to `store` with a specified name, which can be used to reference in later processes eg. stop the job.

### pattern

Time to run the job as specified by [cron syntax](https://en.wikipedia.org/wiki/Cron) specified as below:
```

Example 4 (unknown):
```unknown
This can be generated by tools like [Crontab Guru](https://crontab.guru/)

***

This plugin extends the cron method to Elysia using [cronner](https://github.com/hexagon/croner).

Below are the configs accepted by cronner.

### timezone

Time zone in Europe/Stockholm format

### startAt

Schedule start time for the job

### stopAt

Schedule stop time for the job

### maxRuns

Maximum number of executions

### catch

Continue execution even if an unhandled error is thrown by a triggered function.

### interval

The minimum interval between executions, in seconds.

## Pattern

Below you can find the common patterns to use the plugin.

## Stop cronjob

You can stop cronjob manually by accessing the cronjob name registered to `store`.
```

---
