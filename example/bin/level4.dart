import 'dart:io';

import 'package:dart_express/dart_express.dart';

// in this level you can host a whole static folder or a whole website
void main(List<String> arguments) async {
  Router router = Router()
    ..addRouterMiddleware(logRequest)
    ..get(
      // this * means that this pathArg key will have the rest of the path no matter it has a slash "/"or not
      // this pathTemplate will satisfy these paths /website/path/to/file or /website/file.html
      // if you have for example a path template like this /static/*<path> you must use a path from your html file like this /static/website/path/to/style-file.css or path to .js file or whatever
      '/*<path>',
      // in your html files paths make sure you are requesting the right path from the server (not the relative path from your html file)
      (request, response, pathArgs) => response.serverFolders(
        [
          FolderHost(path: './bin/website', alias: 'website'),
        ],
        pathArgs['path'],
        allowServingFoldersContent: false,
        autoViewIndexTextFiles: false,
        allowViewingEntityPath: true,
        viewTextBasedFiles: true,
      ),
    )
    ..get(
        '/hello/<name>',
        (request, response, pathArgs) => response.writeHtml(
            '<h1>Hello from dart_express <br>Your passed argument is ${pathArgs['name']}</h1>'));
  ServerHolder serverHolder = ServerHolder(router);
  await serverHolder.bind(InternetAddress.anyIPv4, 3000);
}
