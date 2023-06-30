// ignore_for_file: overridden_fields

import 'package:dart_webcore/dart_webcore/documentation/entity_doc.dart';

import '../../matchers/impl/path_checkers.dart';
import '../repo/http_method.dart';
import '../repo/processor.dart';
import '../repo/request_processor.dart';
import '../repo/routing_entity.dart';
import 'middleware.dart';

/// the handler will return a ResponseHolder
/// the handler itself can have some middlewares that will be executed before it as a local middlewares
/// the pathTemplate of a handler can't be null
/// the handler processor should return the ResponseHolder as the final stage of the pipeline
/// because the pipeline will be closed after the handler processor runs
class Handler extends RoutingEntity implements RequestProcessor {
  //? the API consumer doesn't care about middlewares methods or paths
  //? he only cares about what headers or body fields the middleware needs so he will provide them with the request to a specific handler
  //? so for a handler i will need to get what the middleware needs in headers and body
  final List<Middleware> middlewares = [];
  @override
  final String pathTemplate;

  late HandlerDoc doc;

  Handler(
    this.pathTemplate,
    HttpMethod method,
    Processor processor, {
    List<Middleware> middlewares = const [],
    String? signature,
    HandlerDoc? docs,
  }) : super(
          pathTemplate,
          method,
          processor,
          signature: signature,
        ) {
    this.middlewares.addAll(middlewares);
    doc = docs ?? HandlerDoc();
  }

  /// local middlewares will run only for this handler and won't have any effect on other handlers
  Handler addLocalMiddleware(Processor processor) {
    Middleware middleware = Middleware(
      pathTemplate,
      method,
      processor,
      signature: originalSignature,
    );
    middlewares.add(middleware);
    return this;
  }

  @override
  List<RoutingEntity> processors(String path, HttpMethod method) {
    List<RoutingEntity> prs = [];
    bool handlerAdded = false;
    for (var middleware in middlewares) {
      prs.addAll(middleware.processors(path, method));
    }
    bool mine = PathCheckers(
      askedPath: path,
      askedMethod: method,
      routingEntity: this,
    ).isMyPath();
    if (mine) {
      prs.add(this);
      handlerAdded = true;
    }
    if (!handlerAdded) {
      return [];
    }
    return prs;
  }

  @override
  RequestProcessor get self => this;

  void setDoc() {
    List<HeaderField> headers = _getHeadersDoc();
    List<BodyField> body = _getBodyDoc();
    HandlerDoc entityDoc = HandlerDoc(
      body: body,
      headers: headers,
      name: doc.name,
      description: doc.description,
    );

    entityDoc.setMethod(method);
    entityDoc.setPath(pathTemplate);
    doc = entityDoc;
  }

  List<HeaderField> _getHeadersDoc() {
    List<HeaderField> headers = [];
    for (var middleware in middlewares) {
      if (middleware.doc?.headers != null) {
        headers.addAll(middleware.doc!.headers!);
      }
    }
    if (doc.headers != null) {
      headers.addAll(doc.headers!);
    }

    return headers;
  }

  List<BodyField> _getBodyDoc() {
    List<BodyField> body = [];
    for (var middleware in middlewares) {
      if (middleware.doc?.body != null) {
        body.addAll(middleware.doc!.body!);
      }
    }
    if (doc.body != null) {
      body.addAll(doc.body!);
    }

    return body;
  }
}
