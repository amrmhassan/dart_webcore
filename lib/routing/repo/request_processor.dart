import 'package:custom_shelf/routing/repo/routing_entity.dart';

import 'http_method.dart';

abstract class RequestProcessor {
  List<RoutingEntity> processors(String path, HttpMethod method);
}
