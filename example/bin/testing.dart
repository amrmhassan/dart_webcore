import 'dart:io';

import 'package:dart_express/dart_express.dart';

void main(List<String> arguments) async {
  Router router = Router()
    ..insertMiddleware('/hello', HttpMethods.all,
        (request, response, pathArgs) async {
      await Future.delayed(Duration(seconds: 5));

      return request;
    }, signature: 'outside')
    ..get(
      '/hello',
      (request, response, pathArgs) => response.writeJson(request.logging),
      signature: 'test',
    ).addLocalMiddleware((request, response, pathArgs) {
      print(request.logging);
      return request;
    });

  ServerHolder serverHolder = ServerHolder(router);
  await serverHolder.bind(InternetAddress.anyIPv4, 3000);
}
