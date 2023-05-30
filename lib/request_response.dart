import 'dart:io';

/// this will be the entity that will be passed through the app routing entities
abstract class PassedHttpEntity {}

class ResponseHolder implements PassedHttpEntity {
  final HttpResponse response;
  const ResponseHolder(this.response);
}

class RequestHolder implements PassedHttpEntity {
  final HttpRequest request;
  Map<String, dynamic> context = {};
  RequestHolder(this.request);
}
//! middleware can return either a request or a response(both are http entity)
//! a handler can only return a response