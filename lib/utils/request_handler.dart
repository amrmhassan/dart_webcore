import 'dart:async';
import 'dart:io';

import 'package:custom_shelf/http_method.dart';
import 'package:custom_shelf/request_processor.dart';
import 'package:custom_shelf/request_response.dart';
import 'package:custom_shelf/routing_entities.dart';

/// this is the class where choosing the right processors for incoming request runs
class RequestHandler {
  final RequestProcessor requestProcessor;
  final Processor? onPathNotFound;

  RequestHandler(
    this.requestProcessor, {
    this.onPathNotFound,
  });

  void handler(HttpRequest request) async {
    var responseHolder = await getPassedEntity(request);
    await responseHolder.close();
  }

  FutureOr<ResponseHolder> getPassedEntity(HttpRequest request) async {
    ResponseHolder? finalResponseHolder;
    String path = request.uri.path;
    HttpMethod method = HttpMethod.fromString(request.method);
    var processors = requestProcessor.processors(path, method);
    if (processors.isNotEmpty) {
      // here just run the onPathNotFound or the default one that will return a not found json obj
      RequestHolder requestHolder = RequestHolder(request);
      for (var processor in processors) {
        // here i need to extract the pathArgs from the path itself
        PassedHttpEntity passedHttpEntity = await processor(
            requestHolder, requestHolder.response, {
          'pathArgs': 'add the code for extracting path args from the string'
        });
        if (passedHttpEntity is RequestHolder) {
          requestHolder = passedHttpEntity;
        } else if (passedHttpEntity is ResponseHolder) {
          // here just break from the loop
          finalResponseHolder = passedHttpEntity;
          break;
        }
      }
    }
    if (finalResponseHolder == null) {
      return _onPathNotFound(request);
    }
    return finalResponseHolder;
  }

  Future<ResponseHolder> _onPathNotFound(HttpRequest request) async {
    if (onPathNotFound != null) {
      var res = await onPathNotFound!(
          RequestHolder(request),
          ResponseHolder(
            request.response,
          ),
          {});
      if (res is ResponseHolder) {
        return res;
      }
    }
    // here handle the onPath not found
    ResponseHolder responseHolder = ResponseHolder(request.response);

    await responseHolder.write('path not found').close();
    return responseHolder;
  }
}
