import '../../utils/path_checkers.dart';
import '../http_method.dart';
import '../repo/http_method.dart';
import '../repo/request_processor.dart';
import '../repo/routing_entity.dart';
import '../request_processor.dart';

/// the handler will return a RequestHolder or ResponseHolder
/// if the return is RequestHolder it will pass it to the next pipeline entity
/// if the return is ResponseHolder it won't be passed to the next pipeline entity
/// the pathTemplate for a middleware can be null, so it will be executed on all paths requested for a router
class Middleware extends RoutingEntity implements RequestProcessor {
  Middleware(super.pathTemplate, super.method, super.processor);

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
}
