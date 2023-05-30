import 'dart:io';

import 'package:custom_shelf/http_method.dart';
import 'package:custom_shelf/router.dart';
import 'package:custom_shelf/server/server.dart';

void main(List<String> arguments) async {
  Router router = Router()
    ..insertRouterMiddleware(
      HttpMethods.geT,
      (request, response, pathArgs) {
        print(request.request.uri.path);
        return request;
      },
    )
    ..get(
      '/login',
      (request, response, pathArgs) => response.write('get login'),
    )
    ..post(
      '/login',
      (request, response, pathArgs) => response.write('post login'),
    );
  ServerHolder server = ServerHolder(
    router,
    onPathNotFound: (request, response, pathArgs) {
      return request.response.write('this path not found').close();
    },
  );
  var firstServer = await server.bind(InternetAddress.anyIPv4, 3000);
  print('server listening on ${firstServer.port}');
}
