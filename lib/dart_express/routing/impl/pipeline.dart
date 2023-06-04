import '../repo/http_method.dart';
import '../repo/processor.dart';
import '../repo/request_processor.dart';
import '../repo/routing_entity.dart';
import 'handler.dart';
import 'middleware.dart';
import 'router.dart';

class Pipeline implements RequestProcessor {
  final List<RequestProcessor> requestProcessors = [];

  /// you can add any request processor, (handler, middleware, router or even another pipeline) but it's not recommended to add nested pipelines
  /// just use Cascade to gather pipelines together
  Pipeline addRawProcessor(RequestProcessor requestProcessor) {
    requestProcessors.add(requestProcessor);
    return this;
  }

  /// this will run for each request to this pipeline
  Pipeline addPipelineMiddleware(
    Processor processor, {
    String? signature,
  }) {
    Middleware middleware = Middleware(
      null,
      HttpMethods.all,
      processor,
      signature: signature,
    );
    return addRawProcessor(middleware);
  }

  Pipeline addMiddleware(
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
    return addRawProcessor(middleware);
  }

  Pipeline addHandler(
    String pathTemplate,
    HttpMethod method,
    Processor processor, {
    List<Middleware> middlewares = const [],
    String? signature,
  }) {
    Handler handler = Handler(
      pathTemplate,
      method,
      processor,
      middlewares: middlewares,
      signature: signature,
    );
    return addRawProcessor(handler);
  }

  Pipeline addRouter(Router router) {
    return addRawProcessor(router);
  }

  @override
  List<RoutingEntity> processors(String path, HttpMethod method) {
    List<RoutingEntity> prs = [];
    bool doHaveHandler = false;
    for (var requestProcessor in requestProcessors) {
      if (requestProcessor is Handler) {
        if (requestProcessor.isMyPath(path, method)) {
          doHaveHandler = true;
          // here i will just break because i met my handler after adding processor to the list
          prs.addAll(requestProcessor.processors(path, method));
          break;
        }
      } else if (requestProcessor is Middleware) {
        if (requestProcessor.isMyPath(path, method)) {
          // here i will just add it to the prs list
          prs.addAll(requestProcessor.processors(path, method));
        }
      } else if (requestProcessor is Router) {
        List<RoutingEntity> routerProcessors =
            requestProcessor.processors(path, method);
        if (routerProcessors.isNotEmpty) {
          doHaveHandler = true;

          // here i will break after adding all processors to the list
          prs.addAll(routerProcessors);
          break;
        }
      }
    }
    if (!doHaveHandler) return [];
    return prs;
  }
}
