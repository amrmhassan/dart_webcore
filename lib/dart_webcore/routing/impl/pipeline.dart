import 'package:dart_webcore/dart_webcore/documentation/router_doc.dart';
import 'package:dart_webcore/dart_webcore/routing/repo/parent_processor.dart';
import 'package:dart_webcore/dart_webcore/routing/repo/pipeline_child.dart';

import '../repo/http_method.dart';
import '../repo/processor.dart';
import '../repo/request_processor.dart';
import '../repo/routing_entity.dart';
import 'middleware.dart';
import 'router.dart';

class Pipeline implements RequestProcessor, ParentProcessor {
  // can be router or middleware
  final List<PipelineChild> _requestProcessors = [];

  /// you can add any request processor, (handler, middleware, router or even another pipeline) but it's not recommended to add nested pipelines
  /// just use Cascade to gather pipelines together
  Pipeline addRawRouter(Router requestProcessor) {
    _requestProcessors.add(requestProcessor);
    return this;
  }

  Pipeline addRawMiddleware(Middleware middleware) {
    _requestProcessors.add(middleware);
    return this;
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
    return addRawMiddleware(middleware);
  }

  Pipeline addRouter(Router router) {
    return addRawRouter(router);
  }

  @override
  List<RoutingEntity> processors(String path, HttpMethod method) {
    List<RoutingEntity> prs = [];
    bool doHaveHandler = false;
    for (var requestProcessor in _requestProcessors) {
      if (requestProcessor is Middleware) {
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

  @override
  RequestProcessor get self => this;
  List<Router> get routers => _requestProcessors.whereType<Router>().toList();
  late List<RouterDoc> docs;
}
