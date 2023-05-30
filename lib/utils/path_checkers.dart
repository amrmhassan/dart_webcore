import 'package:custom_shelf/routing_entities.dart';

import '../http_method.dart';

class PathCheckers {
  static bool isMyPath({
    required String askedPath,
    required HttpMethod askedMethod,
    required RoutingEntity routingEntity,
  }) {
    String? myPathTemplate = routingEntity.pathTemplate;
    HttpMethod myMethod = routingEntity.method;
    // this will check if the request path is my path or not
    // this will deal with links like that "/users/<user_id>/getInfo" => this is the path template
    //                                     "/users/159875655/getInfo" => this is the path itself
    // this should make sure that the template and the actual path are the same so this RoutingEntity function will be executed on it
    myPathTemplate ??= askedPath;
    bool allMethod = myMethod == HttpMethods.all;
    myMethod = allMethod ? askedMethod : myMethod;

    bool mine = askedPath == myPathTemplate &&
        askedMethod.methodString == myMethod.methodString;
    return mine;
  }
}
