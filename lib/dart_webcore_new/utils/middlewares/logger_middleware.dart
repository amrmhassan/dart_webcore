import '../../constants/runtime_variables.dart';
import '../../server/impl/request_holder.dart';
import '../../server/impl/response_holder.dart';
import '../../server/repo/passed_http_entity.dart';

/// this will give info about the request and the time it took to run on the server
Future<PassedHttpEntity> logRequest(
  RequestHolder request,
  ResponseHolder response,
  Map<String, dynamic> pathArgs,
) async {
  _run(request, response, pathArgs);
  return request;
}

void _run(
  RequestHolder request,
  ResponseHolder response,
  Map<String, dynamic> pathArgs,
) async {
  String path = request.uri.path;
  DateTime before = DateTime.now();
  String method = request.request.method.toUpperCase();

  await response.response.done;
  DateTime after = DateTime.now();
  String timeTook =
      (after.difference(before).inMicroseconds / 1000).toStringAsFixed(2);
  dartExpressLogger
      .i('$path - $method ${response.response.statusCode} - $timeTook ms');
}
