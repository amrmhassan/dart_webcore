import 'package:dart_express/dart_express.dart';

void main(List<String> arguments) {
  Router router = Router()
    ..get(
        '/hello',
        (request, response, pathArgs) =>
            response.write('hello from dart express'));
  ServerHolder serverHolder = ServerHolder(router);
  serverHolder.closeAllRunningServers()
}
