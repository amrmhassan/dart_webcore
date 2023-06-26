class EntityDoc {
  // in the documentation i need the path-method-body-headers
  final List<HeaderField>? headers;
  final List<BodyField>? body;
  final String? description;
  final String? name;

  const EntityDoc({
    this.name,
    this.description,
    this.headers,
    this.body,
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
