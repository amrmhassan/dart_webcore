import 'dart:io';

import 'package:dart_express/dart_express.dart';

// in this level you can host a whole static folder or a whole website
void main(List<String> arguments) async {
  Router router = Router()
    ..get(
        '/hello/<name>',
        (request, response, pathArgs) => response.writeHtml(
            '<h1>Hello from dart_express <br>Your passed argument is ${pathArgs['name']}</h1>'))
    ..get(
      // this * means that this pathArg key will have the rest of the path no matter it has a slash "/"or not
      // this pathTemplate will satisfy these paths /website/path/to/file or /website/file.html
      // if you have for example a path template like this /static/*<path> you must use a path from your html file like this /static/website/path/to/style-file.css or path to .js file or whatever
      '/prefix/*<path>',
      // in your html files paths make sure you are requesting the right path from the server (not the relative path from your html file)
      (request, response, pathArgs) {
        return response.serveFolders(
          [
            FolderHost(path: './bin/website', alias: 'website'),
          ],
          pathArgs['path'],
          allowServingFoldersContent: true,
          autoViewIndexTextFiles: true,
          allowViewingEntityPath: true,
          viewTextBasedFiles: true,
        );
      },
    )
    ..get(
        '/downloadImage',
        (request, response, pathArgs) =>
            response.writeFile('./bin/website/images/img.jpg'))
    ..get(
      // this will do the same as the previous handler with just changing the path from '/prefix/*<path>' to '*<path>'
      '/*<path>',
      // in your html files paths make sure you are requesting the right path from the server
      (request, response, pathArgs) {
        return response.serveFolders(
          [
            FolderHost(path: './bin/website', alias: 'website'),
          ],
          pathArgs['path'],
          allowServingFoldersContent: true,
          autoViewIndexTextFiles: true,
          allowViewingEntityPath: true,
          viewTextBasedFiles: true,
        );
      },
    );

  ServerHolder serverHolder = ServerHolder(router)
    ..addGlobalMiddleware(logRequest);
  await serverHolder.bind(InternetAddress.anyIPv4, 3000);
}
