import '../http_method.dart';

class PathCheckers {
  static bool isMyPath({
    required String askedPath,
    required HttpMethod askedMethod,
    required String? myPathTemplate,
    required HttpMethod myMethod,
  }) {
    // this will check if the request path is my path or not
    // this will deal with links like that "/users/<user_id>/getInfo" => this is the path template
    //                                     "/users/159875655/getInfo" => this is the path itself
    // this should make sure that the template and the actual path are the same so this RoutingEntity function will be executed on it
    myPathTemplate ??= askedPath;
    myMethod = myMethod == HttpMethods.all ? askedMethod : myMethod;

    bool mine = askedPath == myPathTemplate &&
        askedMethod.methodString == myMethod.methodString;
    return mine;
  }
}
