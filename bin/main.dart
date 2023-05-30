import 'dart:io';

import 'package:custom_shelf/cascade.dart';
import 'package:custom_shelf/http_method.dart';
import 'package:custom_shelf/pipeline.dart';
import 'package:custom_shelf/router.dart';
import 'package:custom_shelf/routing_entities.dart';
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
      '/register',
      (request, response, pathArgs) => response.write('post register'),
    );
  Pipeline authPipeline = Pipeline()
      .addMiddleware('/login', HttpMethods.all,
          (request, response, pathArgs) => response.write('response closed'))
      .addRouter(router);
  Cascade cascade = Cascade().add(authPipeline);

  ServerHolder server = ServerHolder(
    authPipeline,
    onPathNotFound: (request, response, pathArgs) {
      return request.response.write('this path not found').close();
    },
  );

  var firstServer = await server.bind(InternetAddress.anyIPv4, 3000);
  print('server listening on ${firstServer.port}');
}
