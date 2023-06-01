import '../repo/http_method.dart';
import '../repo/processor.dart';
import '../repo/request_processor.dart';
import '../repo/routing_entity.dart';
import 'handler.dart';
import 'middleware.dart';

/// this router will return only one matching handler, it holds some handlers and their middlewares
class Router implements RequestProcessor {
  final List<RoutingEntity> routingEntities = [];
  int _handlersNumber = 0;

  /// these are the handlers that will be chosen from to run if the path and the method are fulfilled

  Handler add(Handler handler) {
    return addHandler(
      handler.pathTemplate,
      handler.method,
      handler.processor,
      middlewares: handler.middlewares,
    );
  }

  Handler addHandler(
    String pathTemplate,
    HttpMethod method,
    Processor processor, {
    List<Middleware> middlewares = const [],
  }) {
    _handlersNumber++;
    var handler =
        Handler(pathTemplate, method, processor, middlewares: middlewares);
    routingEntities.add(handler);
    return handler;
  }

  Handler get(
    String pathTemplate,
    Processor processor,
  ) {
    return addHandler(pathTemplate, HttpMethods.geT, processor);
  }

  Handler post(
    String pathTemplate,
    Processor processor,
  ) {
    return addHandler(pathTemplate, HttpMethods.post, processor);
  }

  /// routerMiddleware will work on it's following handlers in this router only
  /// and won't have any effect on other handlers of other routers or the handlers that are above the middleware in sequence
  /// router.get(handler1).get(handler2).addRouterMiddleware(middleware).get(handler3)
  /// this will only be added to handler3 only and won't be added to handler1 nor handler 2
  void insertRouterMiddleware(HttpMethod method, Processor processor) {
    return insertMiddleware(null, method, processor);
  }

  /// routerMiddleware will work on it's following handlers in this router only
  /// and won't have any effect on other handlers of other routers or the handlers that are above the middleware in sequence
  /// router.get(handler1).get(handler2).addRouterMiddleware(middleware).get(handler3)
  /// this will only be added to handler3 only and won't be added to handler1 nor handler 2
  void insertMiddleware(
    String? pathTemplate,
    HttpMethod method,
    Processor processor,
  ) {
    Middleware middleware = Middleware(pathTemplate, method, processor);
    routingEntities.add(middleware);
  }

  @override
  List<RoutingEntity> processors(String path, HttpMethod method) {
    if (_handlersNumber == 0) {
      throw Exception('router must have at least one handler');
    }

    List<RoutingEntity> prs = [];
    // this is to check if at least one handler is satisfied or not
    // if not then this router isn't the right router so i won't return anything from here at all
    bool doHaveHandler = false;
    for (var entity in routingEntities) {
      bool myPath = entity.isMyPath(path, method);
      if (!myPath) continue;

      if (entity is Handler) {
        doHaveHandler = true;
        // this will be the last in the loop so i will break after it
        // get the processor of that handler and add it to the prs
        prs.addAll(entity.processors(path, method));
        break;
      } else if (entity is Middleware) {
        // just return the processor if the method is ok
        prs.addAll(entity.processors(path, method));
      }
    }
    // if no handler is chosen i won't return any middleware because all middlewares in this router are only applicable to this router
    if (!doHaveHandler) return [];
    return prs;
  }
}
