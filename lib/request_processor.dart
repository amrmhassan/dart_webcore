import 'package:custom_shelf/http_method.dart';
import 'package:custom_shelf/routing_entities.dart';

abstract class RequestProcessor {
  List<RoutingEntity> processors(String path, HttpMethod method);
}
