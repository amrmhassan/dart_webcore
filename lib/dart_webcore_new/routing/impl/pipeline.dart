import 'package:dart_webcore_new/dart_webcore_new/documentation/router_doc.dart';

import '../repo/http_method.dart';
import '../repo/request_processor.dart';
import '../repo/routing_entity.dart';
import 'router.dart';

class Pipeline implements RequestProcessor {
  // can be router or middleware
  final List<Router> _requestProcessors = [];

  /// you can add any request processor, (handler, middleware, router or even another pipeline) but it's not recommended to add nested pipelines
  /// just use Cascade to gather pipelines together

  Pipeline addRouter(Router router) {
    _requestProcessors.add(router);
    return this;
  }

  @override
  List<RoutingEntity> processors(String path, HttpMethod method) {
    List<RoutingEntity> prs = [];
    bool doHaveHandler = false;
    for (var requestProcessor in _requestProcessors) {
      List<RoutingEntity> routerProcessors =
          requestProcessor.processors(path, method);
      if (routerProcessors.isNotEmpty) {
        doHaveHandler = true;

        // here i will break after adding all processors to the list
        prs.addAll(routerProcessors);
        break;
      }
    }
    if (!doHaveHandler) return [];
    return prs;
  }

  @override
  RequestProcessor get self => this;
  List<Router> get routers => _requestProcessors.whereType<Router>().toList();
  late List<RouterDoc> docs;

  void setDocs() {
    List<RouterDoc> d = [];
    for (var router in routers) {
      router.setDoc();
      var routerDoc = router.doc;
      if (routerDoc != null) {
        d.add(routerDoc);
      }
    }
    docs = d;
  }
}
