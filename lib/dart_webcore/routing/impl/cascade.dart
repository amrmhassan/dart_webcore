import 'package:dart_webcore/dart_webcore/routing/repo/parent_processor.dart';

import '../../documentation/parent_doc.dart';
import '../repo/http_method.dart';
import '../repo/request_processor.dart';
import '../repo/routing_entity.dart';
import 'pipeline.dart';

class Cascade implements RequestProcessor, ParentProcessor {
  @override
  ParentDoc? doc;

  Cascade({
    this.doc,
  });

  List<Pipeline> pipeLines = [];

  Cascade add(Pipeline pipeline) {
    pipeLines.add(pipeline);

    return this;
  }

  @override
  List<RoutingEntity> processors(String path, HttpMethod method) {
    List<RoutingEntity> prs = [];
    for (var pipeLine in pipeLines) {
      List<RoutingEntity> pipeLineProcessors =
          pipeLine.processors(path, method);
      if (pipeLineProcessors.isNotEmpty) {
        prs.addAll(pipeLineProcessors);
      }
    }
    return prs;
  }
}
