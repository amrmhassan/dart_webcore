import 'http_method.dart';
import 'routing_entity.dart';

abstract class RequestProcessor {
  List<RoutingEntity> processors(String path, HttpMethod method);
  RequestProcessor get self;
}
