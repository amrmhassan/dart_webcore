import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_webcore/dart_webcore/server/impl/request_holder.dart';
import 'package:dart_webcore/dart_webcore/utils/form_receiver.dart';

//! add the ability to read form data as key value pairs

class RequestDecoder {
  Future<dynamic> readAsJson(HttpRequest request) async {
    var jsonBody = json.decode(await readAsString(request));
    return jsonBody;
  }

  Future<String> readAsString(HttpRequest request) async {
    final contentType = request.headers.contentType;
    var mimeType = contentType?.primaryType;
    List<String> allowedMimes = ['application', 'text'];
    // allowed mimes = text,application
    if (!allowedMimes.any((element) => element == mimeType)) {
      throw Exception('body content is not valid as string');
    }
    if (contentType != null && contentType.charset != null) {
      final decoder = Encoding.getByName(contentType.charset!);
      if (decoder != null) {
        var decodedBody = decoder.decode(await readAsBytes(request));
        return decodedBody;
      }
    }
    var decodedBody = await utf8.decoder.bind(request).join();
    return decodedBody;
  }

  Future<List<int>> readAsBytes(HttpRequest request) async {
    final completer = Completer<List<int>>();
    final bytes = <int>[];

    request.listen(
      (data) {
        bytes.addAll(data);
      },
      onDone: () => completer.complete(bytes),
      onError: (error) => completer.completeError(error),
      cancelOnError: true,
    );

    return completer.future;
  }

  Future<FormData> readFormData(
    RequestHolder request, {
    required bool? acceptFormFiles,
    required String? saveFolderPath,
  }) async {
    FormReceiver formReceiver = FormReceiver(
      request,
      acceptFormFiles: acceptFormFiles,
      saveFolderPath: saveFolderPath,
    );
    return formReceiver.receiveFormData();
  }

  Future<File> receiveFile(
    RequestHolder requestHolder,
    String? saveFolderPath, {
    bool throwErrorIfExist = false,
    bool overrideIfExist = false,
  }) {
    FormReceiver formReceiver = FormReceiver(
      requestHolder,
      saveFolderPath: saveFolderPath,
    );
    return formReceiver.receiveBinaryFile(
      overrideIfExist: overrideIfExist,
      throwErrorIfExist: throwErrorIfExist,
    );
  }
}
