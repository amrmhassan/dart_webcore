import 'package:custom_shelf/http_method.dart';
import 'package:custom_shelf/request_processor.dart';
import 'package:custom_shelf/router.dart';
import 'package:custom_shelf/routing_entities.dart';

class Pipeline implements RequestProcessor {
  final List<RequestProcessor> requestProcessors = [];

  Pipeline addRequestProcessor(RequestProcessor requestProcessor) {
    requestProcessors.add(requestProcessor);
    return this;
  }

  Pipeline addMiddleware(
    String pathTemplate,
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
  List<Processor> processors(String path, HttpMethod method) {
    List<Processor> prs = [];
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
        List<Processor> routerProcessors =
            requestProcessor.processors(path, method);
        if (requestProcessors.isNotEmpty) {
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

  //! add a method that will return a handler
  //! this class can extend another class that will have a common method that will return a handler
  //! and this method will take the request and return the right router
}
