import 'package:dart_webcore_new/dart_webcore_new.dart';
import 'package:dart_webcore_new/dart_webcore_new/routing/repo/request_executer.dart';
import 'package:dart_webcore_new/dart_webcore_new/routing/repo/request_processor.dart';

class DocGenerator {
  RequestProcessor requestExecuter;
  DocGenerator(this.requestExecuter) {
    if (requestExecuter is! RequestExecuter) {
      throw Exception(
          'requestProcessor in serverHolder must be a requestExecuter(pipeline, router or a handler)');
    }
  }

  void generate() {
    if (requestExecuter is Pipeline) {
      print('Pipeline');
    } else if (requestExecuter is Router) {
      print('Router');
    } else if (requestExecuter is Handler) {
      print('Handler');
    }
  }
}
