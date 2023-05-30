import 'dart:io';

import 'package:custom_shelf/routing/http_method.dart';
import 'package:custom_shelf/routing/router.dart';
import 'package:custom_shelf/routing/routing_entities.dart';
import 'package:custom_shelf/server/server.dart';

void main(List<String> arguments) async {
  Handler handler = Handler(
          '/login',
          HttpMethods.post,
          (request, response, pathArgs) =>
              response.write('hello world 2, ${request.context}'))
      .addLocalMiddleware(
    (request, response, pathArgs) {
      if (request.request.headers.value('authorization') == null) {
        return response.write('no authorization provided');
      }
      request.context['jwt'] = request.request.headers.value('authorization');
      return request;
    },
  );
  Router router = Router()..add(handler);

  var serverHolder = ServerHolder(router);
  var server = await serverHolder.bind(InternetAddress.anyIPv4, 3000);
  print('listening on http://127.0.0.1:${server.port}');
}
