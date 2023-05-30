import 'package:custom_shelf/routing/pipeline.dart';
import 'package:custom_shelf/routing/request_processor.dart';
import 'package:custom_shelf/routing/routing_entities.dart';

import 'http_method.dart';

class Cascade implements RequestProcessor {
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
