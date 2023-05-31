import 'dart:io';

import 'package:custom_shelf/utils/files_serving.dart';
import 'package:mime/mime.dart';

void main(List<String> arguments) async {
  // String mime = await getMimeType('bin/files/media2.mp3');
  // print(mime);

  print(isAlphaNumeric('hell55o'));
}

Future<String?> getMimeType(String filePath) async {
  File file = File(filePath);
  if (!file.existsSync()) {
    return '';
  }
  var dataHeader = await file.readAsBytes();
  String? mimeType = lookupMimeType(file.path, headerBytes: dataHeader);
  return mimeType;
}
