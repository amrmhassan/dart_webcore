import 'dart:io';

import 'package:dart_webcore_new/dart_webcore_new.dart';

// routers are used to gather multiple handlers, and you can add a global middleware for the whole router
void main(List<String> arguments) async {
  Router router = Router()
    ..addRouterMiddleware(logRequest)
    ..get(
        '/hello',
        (request, response, pathArgs) =>
            response.writeHtml('<h1>Hello from dart_webcore</h1>'))
    ..get(
        '/hello/<name>',
        (request, response, pathArgs) => response.writeHtml(
            '<h1>Hello from dart_webcore <br>Your passed argument is ${pathArgs['name']}</h1>'));
  ServerHolder serverHolder = ServerHolder(router);
  await serverHolder.bind(InternetAddress.anyIPv4, 3000);
}
