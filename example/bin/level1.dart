import 'dart:io';

import 'package:dart_webcore_new/dart_webcore_new.dart';

void main(List<String> arguments) async {
  Handler handler = Handler('/hello', HttpMethods.geT,
      (request, response, pathArgs) => response.write('Hello world'),
      signature: 'thisisme');
  handler.addLocalMiddleware(logRequest);
  ServerHolder serverHolder = ServerHolder(handler);
  await serverHolder.bind(InternetAddress.anyIPv4, 3000);
}
