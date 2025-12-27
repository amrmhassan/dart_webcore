# dart_webcore_new

## Project Overview
dart_webcore_new is a lightweight Dart backend web server package that provides routing, middleware pipelines, request/response helpers, and static file serving on top of dart:io. It aims to keep core HTTP server concerns in one place without pulling in a full web framework.

Use dart_webcore_new when you want:
- A structured routing system with path templates and method matching.
- A middleware pipeline that can short-circuit or continue requests.
- Built-in helpers for JSON, HTML, files, and static hosting.

Use shelf or dart:io directly when:
- You want the shelf ecosystem and middleware model.
- You need a minimal, low-level server with complete manual control.

## Key Features
- Routing via Router and Handler with path templates and args.
- Middleware pipeline with global, router, and handler-level middleware.
- HTTP method handling through HttpMethods and Router shortcuts.
- Request/response abstraction with RequestHolder and ResponseHolder.
- Static file serving with FolderHost and ResponseHolder.serveFolders.
- Form handling through RequestHolder.readFormData and FormData helpers.
- Logging middleware via logRequest.
- Extensibility through Processor and RequestProcessor.

## Installation
Add the dependency to your pubspec.yaml:

```yaml
dependencies:
  dart_webcore_new: ^0.3.1
```

Dart SDK requirement:
- >=2.19.6 <4.0.0

## Quick Start
Minimal server with a GET route:

```dart
import 'dart:io';
import 'package:dart_webcore_new/dart_webcore_new.dart';

void main() async {
  Handler handler = Handler(
    '/hello',
    HttpMethods.geT,
    (request, response, pathArgs) => response.write('Hello world'),
  );

  ServerHolder server = ServerHolder(handler);
  await server.bind(InternetAddress.anyIPv4, 3000);
}
```

## Core Architecture
- Server layer: ServerHolder binds HttpServer instances and delegates requests to RequestHandler.
- Routing layer: Router groups Handler and Middleware entities; Pipeline selects the first router that matches.
- Middleware pipeline: Middleware processors run in order and can return either RequestHolder (continue) or ResponseHolder (stop).
- Request lifecycle: RequestHandler builds a processor list (global middlewares + matched routing processors), then executes them sequentially until a ResponseHolder is returned.

## Routing System
- HTTP methods: HttpMethods.geT, post, put, delete, head, connect, options, trace, patch, and all.
- Route matching: path templates support `<param>` and `*<rest>` wildcards; extracted values are passed as `pathArgs`.
- Cascading and pipelines: Pipeline chains routers and stops at the first router with a matching handler. A Cascade type is present in source but commented out, so Pipeline is the available chaining mechanism.
- Routing entities: Handler, Middleware, Router, Pipeline, and the base RoutingEntity.

Example path args:

```dart
Router router = Router()
  ..get('/users/<user_id>', (req, res, args) {
    return res.write('User ${args['user_id']}');
  })
  ..get('/files/*<path>', (req, res, args) {
    return res.write('Path ${args['path']}');
  });
```

## Middleware
Middleware processors receive `RequestHolder`, `ResponseHolder`, and `pathArgs`. Returning a `RequestHolder` continues the pipeline; returning a `ResponseHolder` ends it.

Order of execution:
- ServerHolder global middlewares (addGlobalMiddleware).
- Router upper middlewares (addUpperMiddleware).
- Router middlewares in order (addRouterMiddleware or addRawMiddleware).
- Handler local middlewares (addLocalMiddleware).
- Handler processor.

Logger middleware example:

```dart
Router router = Router()
  ..addRouterMiddleware(logRequest)
  ..get('/health', (req, res, args) => res.success('ok'));
```

## Request & Response Handling
RequestHolder wraps HttpRequest and adds helpers:
- readAsJson, readAsString, readAsBytes
- readFormData
- receiveFile

ResponseHolder wraps HttpResponse and provides:
- write, writeJson, writeHtml, writeBinary
- writeFile, streamMedia, addStream
- serveFolders
- status helpers: success, badRequest, unauthorized, forbidden, notFound

## Static File Serving
Static hosting is handled by ResponseHolder.serveFolders with FolderHost aliases.

```dart
Router router = Router()
  ..get('/*<path>', (req, res, args) {
    return res.serveFolders(
      [FolderHost(path: './public', alias: 'public')],
      args['path'],
      allowServingFoldersContent: true,
      allowViewingEntityPath: true,
      autoViewIndexTextFiles: true,
      viewTextBasedFiles: true,
    );
  });
```

Notes:
- FolderHost maps a public alias to a real folder path.
- Serving a folder can return a JSON listing (EntityInfo) or auto-serve index.html/htm.

## Forms & Payloads
Form decoding is available through RequestHolder.readFormData:

```dart
Router router = Router()
  ..post('/upload', (req, res, args) async {
    FormData form = await req.readFormData(saveFolderPath: 'uploads');
    FormField? image = form.getField('image');
    return res.success(image?.value);
  });
```

Helpers and validation:
- FormData.getField and FormData.getFile simplify access to fields and uploaded files.
- readFormData can reject files when acceptFormFiles is false.
- receiveFile handles raw binary uploads and can throw if the file already exists.

## Error Handling
- StorageExceptions include FileExistsException for file upload conflicts.
- RequestDecoder throws if a body cannot be decoded as text or application content.
- ServerHolder supports a custom onPathNotFound processor; otherwise a 404 response is returned.

## Internal Documentation Utilities
The package includes developer-facing documentation helpers:
- doc_generator: DocGenerator checks the request processor type.
- router_doc: RouterDoc holds handler documentation entries.
- entity_doc: HandlerDoc and MiddlewareDoc describe headers and body expectations with HeaderField and BodyField.

These utilities are intended for internal tooling and metadata collection, not runtime request processing.

## Project Structure Overview
- lib/constants: runtime variables and logging setup.
- lib/documentation: documentation model classes and generator.
- lib/exceptions: storage and file-related exceptions.
- lib/matchers: path matching and argument extraction.
- lib/models: routing log models.
- lib/routing: routing entities, methods, and processors.
- lib/server: server holder and request/response wrappers.
- lib/serving_folder: static file hosting and result types.
- lib/utils: request decoding, form receiver, and response utilities.

## Example Use Cases
- REST API server with Router, middleware, and JSON responses.
- Static website hosting with FolderHost and serveFolders.
- Internal tooling backend with custom middleware and logging.

## Best Practices
- Add global middleware for logging or cross-cutting concerns before router-specific middleware.
- Keep wildcard routes like `/*<path>` at the end of a router or pipeline to avoid shadowing.
- Validate request payloads early using readAsJson/readFormData and return explicit error responses.
- Separate routers by domain and compose them with Pipeline for clearer ownership.

## License
See LICENSE.
