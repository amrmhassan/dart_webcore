import 'dart:async';
import 'dart:io';

import 'package:custom_shelf/http_method.dart';
import 'package:custom_shelf/request_processor.dart';
import 'package:custom_shelf/request_response.dart';
import 'package:custom_shelf/routing_entities.dart';
import 'package:custom_shelf/utils/path_checkers.dart';

/// this is the class where choosing the right processors for incoming request runs
class RequestHandler {
  final RequestProcessor _requestProcessor;
  final Processor? _onPathNotFoundParam;
  final List<Middleware> _globalMiddlewares;

  RequestHandler(
    this._requestProcessor,
    this._globalMiddlewares, {
    Processor? onPathNotFound,
  }) : _onPathNotFoundParam = onPathNotFound;

  void handler(HttpRequest request) async {
    var responseHolder = await _getPassedEntity(request);
    await responseHolder.close();
  }

  FutureOr<ResponseHolder> _getPassedEntity(HttpRequest request) async {
    ResponseHolder? finalResponseHolder;
    String path = request.uri.path;
    HttpMethod method = HttpMethod.fromString(request.method);
    var matchedGlobalMiddlewares = _getMatchedGlobalMiddlewares(path, method);
    var processors = [
      ...matchedGlobalMiddlewares,
      ..._requestProcessor.processors(path, method),
    ];

    if (processors.isNotEmpty) {
      // here just run the onPathNotFound or the default one that will return a not found json obj
      RequestHolder requestHolder = RequestHolder(request);
      for (var routingEntity in processors) {
        // here i need to extract the pathArgs from the path itself
        PassedHttpEntity passedHttpEntity = await routingEntity.processor(
          requestHolder,
          requestHolder.response,
          PathCheckers(
            askedMethod: method,
            askedPath: path,
            routingEntity: routingEntity,
          ).extractPathData(),
        );
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

  List<RoutingEntity> _getMatchedGlobalMiddlewares(
    String path,
    HttpMethod method,
  ) {
    List<RoutingEntity> prs = [];
    for (var middleware in _globalMiddlewares) {
      bool mine = middleware.isMyPath(path, method);
      if (mine) {
        prs.add(middleware);
      }
    }
    return prs;
  }

  Future<ResponseHolder> _onPathNotFound(HttpRequest request) async {
    if (_onPathNotFoundParam != null) {
      var res = await _onPathNotFoundParam!(
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
