import 'dart:async';
import 'dart:convert';
import 'dart:io';

class RequestDecoder {
  Future<dynamic> readAsJson(HttpRequest request) async {
    return json.decode(await readAsString(request));
  }

  Future<String> readAsString(HttpRequest request) async {
    final contentType = request.headers.contentType;
    if (contentType != null && contentType.charset != null) {
      final decoder = Encoding.getByName(contentType.charset!);
      if (decoder != null) {
        return decoder.decode(await readAsBytes(request));
      }
    }
    return utf8.decoder.bind(request).join();
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
}
