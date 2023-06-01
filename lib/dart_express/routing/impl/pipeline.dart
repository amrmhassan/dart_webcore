import '../repo/http_method.dart';
import '../repo/processor.dart';
import '../repo/request_processor.dart';
import '../repo/routing_entity.dart';
import 'handler.dart';
import 'middleware.dart';
import 'router.dart';

class Pipeline implements RequestProcessor {
  final List<RequestProcessor> requestProcessors = [];

  Pipeline addRequestProcessor(RequestProcessor requestProcessor) {
    requestProcessors.add(requestProcessor);
    return this;
  }

  Pipeline addMiddleware(
    String? pathTemplate,
    HttpMethod method,
    Processor processor,
  ) {
    Middleware middleware = Middleware(pathTemplate, method, processor);
    return addRequestProcessor(middleware);
  }

  Pipeline addHandler(
    String pathTemplate,
    HttpMethod method,
    Processor processor,
  ) {
    Handler handler = Handler(pathTemplate, method, processor);
    return addRequestProcessor(handler);
  }

  Pipeline addRouter(Router router) {
    return addRequestProcessor(router);
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
