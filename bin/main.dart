import 'dart:io';

import 'package:custom_shelf/routing/router.dart';
import 'package:custom_shelf/server/server.dart';
import 'package:custom_shelf/serving_folder/files_serving.dart';

//! add the ability to add a path template that runs for more than one path part
//! like '/static/path/to/some/files' actual path
//! path template '/static/*/otherPart'
//! so instead of this * there can be any parts of path with any number of slashes
//! or you can just add the ability to add a custom regex template in the path itself
//! and the matches will happen after that but don't forget to perform your custom pathArgs extraction as normal on the regex itself

void main(List<String> arguments) async {
  Router router = Router()
    ..get(
      '/static',
      (request, response, pathArgs) => response.serverFolder(
        [
          FolderHost(path: './lib', alias: 'code'),
        ],
        request.headers.value('path')!,
        allowServingSubFolders: true,
        allowViewingEntityPath: true,
      ),
    );
  ServerHolder serverHolder = ServerHolder(router);
  serverHolder.bind(InternetAddress.anyIPv4, 3000);
}

// Future<String?> getMimeType(String filePath) async {
//   File file = File(filePath);
//   if (!file.existsSync()) {
//     return '';
//   }
//   var dataHeader = await file.readAsBytes();
//   String? mimeType = lookupMimeType(file.path, headerBytes: dataHeader);
//   return mimeType;
// }
