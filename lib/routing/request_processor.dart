import 'package:custom_shelf/routing/routing_entities.dart';

import 'http_method.dart';

abstract class RequestProcessor {
  List<RoutingEntity> processors(String path, HttpMethod method);
}
