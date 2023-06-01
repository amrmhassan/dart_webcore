import 'dart:io';

import 'package:dart_express/dart_express.dart';

// routers are used to gather multiple handlers, and you can add a global middleware for the whole router
void main(List<String> arguments) async {
  Router router = Router()
    ..insertRouterMiddleware(HttpMethods.all, logRequest)
    ..get(
        '/hello',
        (request, response, pathArgs) =>
            response.writeHtml('<h1>Hello from dart_express</h1>'))
    ..get(
        '/hello/<name>',
        (request, response, pathArgs) => response.writeHtml(
            '<h1>Hello from dart_express <br>Your passed argument is ${pathArgs['name']}</h1>'));
  ServerHolder serverHolder = ServerHolder(router);
  await serverHolder.bind(InternetAddress.anyIPv4, 3000);
}
