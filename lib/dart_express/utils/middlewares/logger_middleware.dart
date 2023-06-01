import '../../../dart_express.dart';
import '../../server/repo/passed_http_entity.dart';

PassedHttpEntity logRequest(
  RequestHolder request,
  ResponseHolder response,
  Map<String, dynamic> pathArgs,
) {
  String path = request.uri.path;
  DateTime now = DateTime.now();

  dartExpressLogger.i('$path - $now');
  return request;
}
