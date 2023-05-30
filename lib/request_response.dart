import 'dart:io';

/// this will be the entity that will be passed through the app routing entities
abstract class PassedHttpEntity {}

class ResponseHolder implements PassedHttpEntity {
  final HttpResponse response;
  ResponseHolder(this.response);
  bool closed = false;
  String? closeMessage;
  dynamic closeData;

  Future<ResponseHolder> close({String? closeMessage}) async {
    closed = true;
    closeMessage = closeMessage;
    closeData = await response.close();
    return this;
  }

  ResponseHolder write(Object? object) {
    response.write(object);
    return this;
  }
}

class RequestHolder implements PassedHttpEntity {
  final HttpRequest request;
  Map<String, dynamic> context = {};
  RequestHolder(this.request);

  ResponseHolder get response => ResponseHolder(request.response);
}
// middleware can return either a request or a response(both are http entity)
// a handler can only return a response