import 'dart:io';

import 'package:dart_web_server/dart_web_server.dart';

void main(List<String> arguments) async {
  // if the user asked for /getFile/website/file.txt
  // this handler will be executed
  // /getFile will run route to this handler and /website will route to the corresponding folder from this alias
  // you can make nested folders as you need

  Handler pathArgHandler = Handler(
    '/getFile/*<path>',
    HttpMethods.geT,
    (request, response, pathArgs) => response.serveFolders(
      [
        FolderHost(path: './bin/website', alias: 'website'),
      ],
      pathArgs['path'],
      allowServingFoldersContent: true,
    ),
  );

  ServerHolder serverHolder = ServerHolder(pathArgHandler);
  serverHolder.bind(InternetAddress.anyIPv4, 3000);
}
