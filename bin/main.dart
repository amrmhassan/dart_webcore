import 'dart:io';

import 'package:custom_shelf/routing/http_method.dart';
import 'package:custom_shelf/routing/routing_entities.dart';
import 'package:custom_shelf/server/server.dart';

//! add headers and some other famous props to the request holder and readAsString, readAsJson, readAsBuffer and these kind of stuff
//! add some more functionality to the response holder like json, and many other things
//! add the concept of trailerWare the opposite of middleware
//! add the ability for each middleware to modify the context and add some data to it like time taken in this middleware and these kind of stuff, or just add it to a new thing called middlewareData object instead of context, and make it optional to record these data or not by the server settings
void main(List<String> arguments) async {
  Handler handler =
      Handler('/', HttpMethods.all, (request, response, pathArgs) async {
    return response..writeFile('./bin/video.mp4');
  });

  var serverHolder = ServerHolder(handler);
  var server = await serverHolder.bind(InternetAddress.anyIPv4, 3000);
  print('listening on http://127.0.0.1:${server.port}');
}
