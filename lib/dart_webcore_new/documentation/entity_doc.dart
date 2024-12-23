import 'package:dart_webcore_new/dart_webcore_new/routing/repo/http_method.dart';

class HandlerDoc {
  // in the documentation i need the path-method-body-headers
  final List<HeaderField>? headers;
  final List<BodyField>? body;
  final String? description;
  final String? name;

  HandlerDoc({
    this.name,
    this.description,
    this.headers,
    this.body,
  });

  late String _path;
  late HttpMethod _method;

  void setPath(String path) {
    _path = path;
  }

  void setMethod(HttpMethod method) {
    _method = method;
  }

  void insertHeader(List<HeaderField> field) {
    headers?.insertAll(0, field);
  }

  void insertBody(List<BodyField> field) {
    body?.insertAll(0, field);
  }

  String get path => _path;
  HttpMethod get method => _method;
}

class MiddlewareDoc {
  final List<HeaderField>? headers;
  final List<BodyField>? body;
  const MiddlewareDoc({
    this.body,
    this.headers,
  });
}

class HeaderField {
  final String key;
  final String valueTemplate;
  final String? type;
  final String? description;

  const HeaderField(
    this.key,
    this.valueTemplate, {
    this.type,
    this.description,
  });
}

class BodyField {
  final String key;
  final String valueTemplate;
  final String? type;
  final String? description;

  const BodyField(
    this.key,
    this.valueTemplate, {
    this.type,
    this.description,
  });
}
