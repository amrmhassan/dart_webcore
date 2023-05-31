import 'dart:io';

import 'package:custom_shelf/routing/cascade.dart';
import 'package:custom_shelf/routing/http_method.dart';
import 'package:custom_shelf/routing/pipeline.dart';
import 'package:custom_shelf/routing/router.dart';
import 'package:custom_shelf/routing/routing_entities.dart';
import 'package:custom_shelf/server/server.dart';

//! add headers and some other famous props to the request holder and readAsString, readAsJson, readAsBuffer and these kind of stuff
//! add some more functionality to the response holder like json, and many other things
//! add the concept of trailerWare the opposite of middleware
//! add the ability for each middleware to modify the context and add some data to it like time taken in this middleware and these kind of stuff, or just add it to a new thing called middlewareData object instead of context, and make it optional to record these data or not by the server settings
void main(List<String> arguments) async {
  Handler handler = Handler(
      '/login',
      HttpMethods.post,
      (request, response, pathArgs) =>
          response.write('hello world 2, ${request.context}'));
  Router router = Router()
    ..insertRouterMiddleware(HttpMethods.all, (request, response, pathArgs) {
      if (request.request.headers.value('authorization') == null) {
        return response..response.write('no authorization provided');
      }
      request.context['jwt'] = request.request.headers.value('authorization');
      return request;
    })
    ..add(handler);
  Router userDataRouter = Router()
    ..get('/user/<user_id>/getData',
        (request, response, pathArgs) => response.write(pathArgs))
    ..get(
        '/login',
        (request, response, pathArgs) =>
            response.write('another way to login without authorization'));
  Pipeline pipeline =
      Pipeline().addRouter(userDataRouter).addRequestProcessor(router);
  Pipeline pipeline2 = Pipeline().addHandler('/a7a', HttpMethods.options,
      (request, response, pathArgs) => response.write('opaque'));

  Cascade cascade = Cascade().add(pipeline).add(pipeline2);
  var serverHolder =
      ServerHolder(cascade).addGlobalMiddleware((request, response, pathArgs) {
    request.context['receivedAt'] = DateTime.now();
    return request;
  });
  var server = await serverHolder.bind(InternetAddress.anyIPv4, 3000);
  print('listening on http://127.0.0.1:${server.port}');
}
