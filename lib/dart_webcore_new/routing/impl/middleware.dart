import 'package:dart_webcore_new/dart_webcore_new/documentation/entity_doc.dart';

import '../../matchers/impl/path_checkers.dart';
import '../repo/http_method.dart';
import '../repo/processor.dart';
import '../repo/request_processor.dart';
import '../repo/routing_entity.dart';

/// the handler will return a RequestHolder or ResponseHolder
/// if the return is RequestHolder it will pass it to the next pipeline entity
/// if the return is ResponseHolder it won't be passed to the next pipeline entity
/// the pathTemplate for a middleware can be null, so it will be executed on all paths requested for a router
class Middleware extends RoutingEntity implements RequestProcessor {
  Middleware(
    String? pathTemplate,
    HttpMethod method,
    Processor processor, {
    String? signature,
    this.doc,
  }) : super(
          pathTemplate,
          method,
          processor,
          signature: signature,
        );

  @override
  List<RoutingEntity> processors(String path, HttpMethod method) {
    bool mine = PathCheckers(
      askedPath: path,
      askedMethod: method,
      routingEntity: this,
    ).isMyPath();
    if (mine) {
      return [this];
    }
    return [];
  }

  @override
  RequestProcessor get self => this;

  MiddlewareDoc? doc;
}
