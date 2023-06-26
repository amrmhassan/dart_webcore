import 'package:dart_webcore/dart_webcore/documentation/entity_doc.dart';

class RouterDoc {
  final String? name;
  final String? description;

  RouterDoc(this.name, this.description);
  late List<HandlerDoc?> _handlers;

  void setHandlersDoc(List<HandlerDoc?> docs) {
    _handlers = docs;
  }

  List<HandlerDoc?> get handlersDocs => _handlers;
}
