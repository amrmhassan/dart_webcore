import 'dart:io';

import 'package:custom_shelf/http_method.dart';
import 'package:custom_shelf/router.dart';
import 'package:custom_shelf/server/server.dart';

void main(List<String> arguments) async {
  Router router = Router()
    ..insertRouterMiddleware(
      HttpMethods.all,
      (request, pathArgs) {
        print(request.request.uri.path);
        return request;
      },
    )
    ..get('/login', (request, pathArgs) {
      return request.response.write('hello world').close();
    });
  ServerHolder server = ServerHolder(
    router,
    onPathNotFound: (request, pathArgs) {
      return request.response.write('this path not found').close();
    },
  );
  var firstServer = await server.bind(InternetAddress.anyIPv4, 3000);
  print('server listening on ${firstServer.port}');
}
