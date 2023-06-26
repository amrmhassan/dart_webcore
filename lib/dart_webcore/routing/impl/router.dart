import 'package:dart_webcore/dart_webcore/documentation/parent_doc.dart';
import 'package:dart_webcore/dart_webcore/routing/repo/parent_processor.dart';

import '../repo/http_method.dart';
import '../repo/processor.dart';
import '../repo/request_processor.dart';
import '../repo/routing_entity.dart';
import 'handler.dart';
import 'middleware.dart';

/// this router will return only one matching handler, it holds some handlers and their middlewares
class Router implements RequestProcessor, ParentProcessor {
  @override
  ParentDoc? doc;

  Router({
    this.doc,
  });

  final List<RoutingEntity> _routingEntities = [];
  final List<Middleware> _upperMiddlewares = [];
  int _handlersNumber = 0;

  //? adding middlewares
  /// routerMiddleware will work on it's following handlers in this router only
  /// and won't have any effect on other handlers of other routers or the handlers that are above the middleware in sequence
  /// router.get(handler1).get(handler2).addRouterMiddleware(middleware).get(handler3)
  /// this will only be added to handler3 only and won't be added to handler1 nor handler 2
  /// `it will work on every request for this router`
  Router addRouterMiddleware(
    Processor processor, {
    String? signature,
  }) {
    return insertMiddleware(
      null,
      HttpMethods.all,
      processor,
      signature: signature,
    );
  }

  /// upper middlewares will be add before any other handler or middleware in the router
  /// and they have their own order, so first added upper middlewares will be executed first and so on
  Router addUpperRawMiddleware(Middleware middleware) {
    _upperMiddlewares.add(middleware);
    return this;
  }

  /// upper middlewares will be add before any other handler or middleware in the router
  /// and they have their own order, so first added upper middlewares will be executed first and so on
  Router addUpperMiddleware(
    String? pathTemplate,
    HttpMethod method,
    Processor processor, {
    String? signature,
  }) {
    Middleware middleware = Middleware(
      pathTemplate,
      method,
      processor,
      signature: signature,
    );
    return addUpperRawMiddleware(middleware);
  }

  /// routerMiddleware will work on it's following handlers in this router only
  /// and won't have any effect on other handlers of other routers or the handlers that are above the middleware in sequence
  /// router.get(handler1).get(handler2).addRouterMiddleware(middleware).get(handler3)
  /// this will only be added to handler3 only and won't be added to handler1 nor handler 2
  Router insertMiddleware(
    String? pathTemplate,
    HttpMethod method,
    Processor processor, {
    String? signature,
  }) {
    Middleware middleware = Middleware(
      pathTemplate,
      method,
      processor,
      signature: signature,
    );
    return addRawMiddleware(middleware);
  }

  Router addRawMiddleware(Middleware middleware) {
    _routingEntities.add(middleware);
    return this;
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
    _routingEntities.insertAll(0, _upperMiddlewares);
    for (var entity in _routingEntities) {
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

  //? adding handlers

  /// these are the handlers that will be chosen from to run if the path and the method are fulfilled
  Handler addRawHandler(Handler handler) {
    _handlersNumber++;
    _routingEntities.add(handler);
    return handler;
  }

  Handler addHandler(
    String pathTemplate,
    HttpMethod method,
    Processor processor, {
    List<Middleware> middlewares = const [],
    String? signature,
  }) {
    var handler = Handler(
      pathTemplate,
      method,
      processor,
      middlewares: middlewares,
      signature: signature,
    );
    return addRawHandler(handler);
  }

  // handlers short hands
  Handler get(
    String pathTemplate,
    Processor processor, {
    String? signature,
    List<Middleware> middlewares = const [],
  }) {
    return addHandler(
      pathTemplate,
      HttpMethods.geT,
      processor,
      signature: signature,
      middlewares: middlewares,
    );
  }

  Handler post(
    String pathTemplate,
    Processor processor, {
    String? signature,
    List<Middleware> middlewares = const [],
  }) {
    return addHandler(
      pathTemplate,
      HttpMethods.post,
      processor,
      middlewares: middlewares,
      signature: signature,
    );
  }

  Handler put(
    String pathTemplate,
    Processor processor, {
    String? signature,
    List<Middleware> middlewares = const [],
  }) {
    return addHandler(
      pathTemplate,
      HttpMethods.put,
      processor,
      middlewares: middlewares,
      signature: signature,
    );
  }

  Handler delete(
    String pathTemplate,
    Processor processor, {
    String? signature,
    List<Middleware> middlewares = const [],
  }) {
    return addHandler(
      pathTemplate,
      HttpMethods.delete,
      processor,
      middlewares: middlewares,
      signature: signature,
    );
  }

  Handler head(
    String pathTemplate,
    Processor processor, {
    String? signature,
    List<Middleware> middlewares = const [],
  }) {
    return addHandler(
      pathTemplate,
      HttpMethods.head,
      processor,
      middlewares: middlewares,
      signature: signature,
    );
  }

  Handler connect(
    String pathTemplate,
    Processor processor, {
    String? signature,
    List<Middleware> middlewares = const [],
  }) {
    return addHandler(
      pathTemplate,
      HttpMethods.connect,
      processor,
      middlewares: middlewares,
      signature: signature,
    );
  }

  Handler options(
    String pathTemplate,
    Processor processor, {
    String? signature,
    List<Middleware> middlewares = const [],
  }) {
    return addHandler(
      pathTemplate,
      HttpMethods.options,
      processor,
      middlewares: middlewares,
      signature: signature,
    );
  }

  Handler trace(
    String pathTemplate,
    Processor processor, {
    String? signature,
    List<Middleware> middlewares = const [],
  }) {
    return addHandler(
      pathTemplate,
      HttpMethods.trace,
      processor,
      middlewares: middlewares,
      signature: signature,
    );
  }

  Handler patch(
    String pathTemplate,
    Processor processor, {
    String? signature,
    List<Middleware> middlewares = const [],
  }) {
    return addHandler(
      pathTemplate,
      HttpMethods.patch,
      processor,
      middlewares: middlewares,
      signature: signature,
    );
  }
}
