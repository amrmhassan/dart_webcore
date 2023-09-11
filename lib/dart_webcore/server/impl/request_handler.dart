import 'dart:async';
import 'dart:io';

import '../../matchers/impl/path_checkers.dart';
import '../../models/routing_log.dart';
import '../../routing/impl/middleware.dart';
import '../../routing/repo/http_method.dart';
import '../../routing/repo/processor.dart';
import '../../routing/repo/request_processor.dart';
import '../../routing/repo/routing_entity.dart';
import '../repo/passed_http_entity.dart';
import 'request_holder.dart';
import 'response_holder.dart';

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
    try {
      var responseHolder = await _getPassedEntity(request);
      await responseHolder.close();
    } catch (e) {
      await request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Error occurred')
        ..close();
    }
  }

  FutureOr<ResponseHolder> _getPassedEntity(HttpRequest request) async {
    ResponseHolder? finalResponseHolder;
    String path = request.uri.path;
    HttpMethod method = HttpMethod.fromString(request.method);
    // if (method == HttpMethods.options) {
    //   //
    //   ResponseHolder responseHolder = ResponseHolder(request);
    //   responseHolder.headers.add('Access-Control-Allow-Origin',
    //       '*'); // Replace with your desired origin(s)
    //   responseHolder.headers
    //       .add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
    //   responseHolder.headers
    //       .add('Access-Control-Allow-Headers', 'Content-Type');
    //   responseHolder.write('connected').close();
    //   return responseHolder;
    // }
    var matchedGlobalMiddlewares = _getMatchedGlobalMiddlewares(path, method);
    var processors = [
      ...matchedGlobalMiddlewares,
      ..._requestProcessor.processors(path, method),
    ];

    // here i handle running the processors
    if (processors.isNotEmpty) {
      finalResponseHolder = await _runProcessors(
        method: method,
        path: path,
        processors: processors,
        request: request,
      );
    }

    if (finalResponseHolder == null) {
      return _onPathNotFound(request);
    }
    return finalResponseHolder;
  }

  Future<ResponseHolder?> _runProcessors({
    required HttpRequest request,
    required List<RoutingEntity> processors,
    required HttpMethod method,
    required String path,
  }) async {
    ResponseHolder? finalResponseHolder;

    // here just run the onPathNotFound or the default one that will return a not found json obj
    RequestHolder requestHolder = RequestHolder(request);

    for (var routingEntity in processors) {
      DateTime routingEntityReceived = DateTime.now();
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

      DateTime routingEntityFinished = DateTime.now();

      if (routingEntity.signature != null &&
          passedHttpEntity is RequestHolder) {
        // here add the  log to the passedHttpEntity logging system
        RoutingLog routingLog = RoutingLog(
          startTime: routingEntityReceived,
          endTime: routingEntityFinished,
        );

        passedHttpEntity.logging[routingEntity.signature!] =
            routingLog.toJSON();
      }

      if (passedHttpEntity is RequestHolder) {
        requestHolder = passedHttpEntity;
      } else if (passedHttpEntity is ResponseHolder) {
        // here just break from the loop
        finalResponseHolder = passedHttpEntity;
        break;
      }
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
          RequestHolder(request), ResponseHolder(request), {});
      if (res is ResponseHolder) {
        return res;
      }
    }
    // here handle the onPath not found
    ResponseHolder responseHolder = ResponseHolder(request);

    return responseHolder
      ..response.statusCode = HttpStatus.notFound
      ..write('path not found, try changing path or method')
      ..close();
  }
}
