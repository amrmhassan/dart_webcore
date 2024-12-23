import 'dart:io';
import 'package:dart_webcore_new/dart_webcore_new.dart';

void main(List<String> args) {
  Router router = Router()
    ..post('/upload', (request, response, pathArgs) async {
      var form = await request.readFormData(saveFolderPath: 'formFields');
      // form should be on the format
      /*
      image: image_path
      you can add any other fields as you want 
      
       */
      var field = form.getField('image');

      return response.success(field?.value);
    })
    ..get(
      '/*<file_name>',
      (request, response, pathArgs) => response.serveFolders(
        [
          FolderHost(
            path: 'formFields',
            alias: 'formFields',
          ),
        ],
        pathArgs['file_name'],
      ),
    );
  ServerHolder serverHolder = ServerHolder(router);
  serverHolder.bind(InternetAddress.anyIPv4, 8000);
}
