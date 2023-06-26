import '../routing/impl/handler.dart';
import '../routing/impl/router.dart';
import '../routing/repo/request_processor.dart';

class DocGenerator {
  final RequestProcessor _processor;

  const DocGenerator(this._processor);
  void generate() {
    var processor = _processor;
    if (processor is Handler) {
      print(processor.pathTemplate);
      print(processor.method);
    } else if (processor is Router) {}
  }
}
