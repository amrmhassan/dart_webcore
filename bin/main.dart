import 'dart:io';

import 'package:custom_shelf/router.dart';
import 'package:custom_shelf/server/server.dart';

void main(List<String> arguments) async {
  Router router = Router()
    ..get(
      '/users/<user_id>/getUser',
      (request, response, pathArgs) {
        print('get $pathArgs');
        return response.write('get user');
      },
    )
    ..post(
      '/users/<user_id>/addUser',
      (request, response, pathArgs) {
        print('post $pathArgs');
        return response.write('post user');
      },
    );

  ServerHolder server = ServerHolder(
    router,
    onPathNotFound: (request, response, pathArgs) {
      return request.response.write('this path not found').close();
    },
  );

  var firstServer = await server.bind(InternetAddress.anyIPv4, 3000);
  print('server listening on ${firstServer.port}');
  // var data = PathCheckers.extractData('/users', '/users');
  // print(data);
}
