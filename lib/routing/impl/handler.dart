// ignore_for_file: overridden_fields

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
  final List<Middleware> middlewares = [];
  @override
  final String pathTemplate;

  Handler(
    this.pathTemplate,
    HttpMethod method,
    Processor processor, {
    List<Middleware> middlewares = const [],
  }) : super(pathTemplate, method, processor) {
    this.middlewares.addAll(middlewares);
  }

  /// local middlewares will run only for this handler and won't have any effect on other handlers
  Handler addLocalMiddleware(Processor processor) {
    Middleware middleware = Middleware(pathTemplate, method, processor);
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
}
