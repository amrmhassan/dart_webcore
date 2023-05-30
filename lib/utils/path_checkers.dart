import '../routing/http_method.dart';
import '../routing/routing_entities.dart';

class PathCheckers {
  final String askedPath;
  final HttpMethod askedMethod;
  final RoutingEntity routingEntity;

  const PathCheckers({
    required this.askedPath,
    required this.askedMethod,
    required this.routingEntity,
  });

  bool isMyPath() {
    String? myPathTemplate = routingEntity.pathTemplate;
    HttpMethod myMethod = routingEntity.method;
    // this will check if the request path is my path or not
    // this will deal with links like that "/users/<user_id>/getInfo" => this is the path template
    //                                     "/users/159875655/getInfo" => this is the path itself
    // this should make sure that the template and the actual path are the same so this RoutingEntity function will be executed on it
    myPathTemplate ??= askedPath;
    bool allMethod = myMethod == HttpMethods.all;
    myMethod = allMethod ? askedMethod : myMethod;

    // checking if it is mine

    List<String> actualLinkParts = askedPath.split('/');
    List<String> templateParts = myPathTemplate.split('/');
    if (actualLinkParts.length != templateParts.length) {
      // if they don't contain the same amount of parts for each link then not the intended path
      return false;
    }
    for (var i = 0; i < actualLinkParts.length; i++) {
      String tempPart = templateParts[i];
      String pathPart = actualLinkParts[i];
      bool isPlaceHolder = _isPlaceHolder(tempPart);
      if (!isPlaceHolder && tempPart != pathPart) {
        return false;
      }
    }

    return true;
  }

  bool _isPlaceHolder(String part) {
    return part.startsWith('<') && part.endsWith('>');
  }

  Map<String, dynamic> extractPathData() {
    String? pathTemplate = routingEntity.pathTemplate;
    String path = askedPath;
    // when the path template is null then it must be a middleware which doesn't care about data so it will be {}
    if (pathTemplate == null) {
      return {};
    }
    var extractedData = _extractData(pathTemplate, path);
    return extractedData;
  }

  Map<String, String> _extractData(
    String linkTemplate,
    String actualLink,
  ) {
    RegExp regExp = RegExp(r'<([a-zA-Z_]+)>');
    Map<String, String> extractedData = {};

    List<RegExpMatch> matches = regExp.allMatches(linkTemplate).toList();
    List<String> actualLinkParts = actualLink.split('/');
    List<String> templateParts = linkTemplate.split('/');

    for (RegExpMatch match in matches) {
      String placeholder = match.group(0) ?? '';
      String key = match.group(1) ?? '';
      int keyIndex = templateParts.indexOf(placeholder);

      String placeholderValue = actualLinkParts.elementAt(keyIndex);

      extractedData[key] = placeholderValue;
    }
    var finalRes = extractedData;

    return finalRes.cast();
  }
}
