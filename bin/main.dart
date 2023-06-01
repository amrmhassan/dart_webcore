import 'dart:io';

import 'package:custom_shelf/routing/router.dart';
import 'package:custom_shelf/server/server.dart';
import 'package:custom_shelf/serving_folder/files_serving.dart';

//! allow
void main(List<String> arguments) async {
  Router router = Router()
    ..get(
      '*<path>',
      (request, response, pathArgs) {
        return response.serverFolder(
          [
            FolderHost(path: './lib', alias: 'code'),
            FolderHost(path: './bin/files', alias: ''),
          ],
          pathArgs['path'],
          viewTextBasedFiles: true,
          allowServingFoldersContent: false,
          allowViewingEntityPath: true,
          autoViewIndexTextFiles: true,
          // autoViewIndexFilesNames:
        );
      },
    );
  ServerHolder serverHolder = ServerHolder(router);
  serverHolder.bind(InternetAddress.anyIPv4, 3000);
}
