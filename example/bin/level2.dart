import 'dart:io';

import 'package:dart_web_server/dart_web_server.dart';

// routers are used to gather multiple handlers, and you can add a global middleware for the whole router
void main(List<String> arguments) async {
  Router router = Router()
    ..addRouterMiddleware(logRequest)
    ..get(
        '/hello',
        (request, response, pathArgs) =>
            response.writeHtml('<h1>Hello from dart_web_server</h1>'))
    ..get(
        '/hello/<name>',
        (request, response, pathArgs) => response.writeHtml(
            '<h1>Hello from dart_web_server <br>Your passed argument is ${pathArgs['name']}</h1>'));
  ServerHolder serverHolder = ServerHolder(router);
  await serverHolder.bind(InternetAddress.anyIPv4, 3000);
}
