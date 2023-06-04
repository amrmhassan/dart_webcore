import 'package:dart_express/dart_express/routing/repo/processor.dart';

import '../../matchers/impl/path_checkers.dart';
import '../repo/http_method.dart';
import '../repo/request_processor.dart';
import '../repo/routing_entity.dart';

/// the handler will return a RequestHolder or ResponseHolder
/// if the return is RequestHolder it will pass it to the next pipeline entity
/// if the return is ResponseHolder it won't be passed to the next pipeline entity
/// the pathTemplate for a middleware can be null, so it will be executed on all paths requested for a router
class Middleware extends RoutingEntity implements RequestProcessor {
  // late String? _signature;

  Middleware(
    String? pathTemplate,
    HttpMethod method,
    Processor processor, {
    String? signature,
  }) : super(
          pathTemplate,
          method,
          processor,
          signature: signature,
        );
  //  {
  // validating the signature
  // if (signature != null) {
  //   if (signature.contains('|')) {
  //     throw Exception('signature can\'t contain the reserved char |');
  //   }
  //   _signature = signature + const Uuid().v4();
  // }
  // }
  // String? get signature => _signature;

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
