// ignore_for_file: overridden_fields

import 'dart:async';

import 'package:custom_shelf/routing/request_processor.dart';
import 'package:custom_shelf/routing/request_response.dart';
import 'package:custom_shelf/utils/path_checkers.dart';

import 'http_method.dart';

/// this is the processor function that deals with either the middleware or the handler itself
typedef Processor = FutureOr<PassedHttpEntity> Function(
  RequestHolder request,
  ResponseHolder response,

  /// this is the arguments passed to the path itself like
  /// /users/<user_id>/getInfo => path template
  /// /users/159876663/getInfo => actual request path
  /// {'user_id':159876663} this will be the pathArgs map
  Map<String, dynamic> pathArgs,
);

abstract class RoutingEntity {
  /// this is the path of the handler or the middleware not the incoming request path
  /// the null pathTemplate means that this Middleware will run on every request no matter it's path
  /// but the method will restrict this, if you want to make a global middleware just make the pathTemplate to be null and the method to be HttpMethods.all
  final String? pathTemplate;

  /// this is the method of the handler or middleware not the incoming request method
  final HttpMethod method;

  /// this is the function that will be executed when hitting this routing entity
  final Processor processor;

  const RoutingEntity(this.pathTemplate, this.method, this.processor);

  bool isMyPath(
    String askedPath,
    HttpMethod askedMethod,
  ) =>
      PathCheckers(
        askedMethod: askedMethod,
        askedPath: askedPath,
        routingEntity: this,
      ).isMyPath();
}

/// the handler will return a ResponseHolder
/// the handler itself can have some middlewares that will be executed before it as a local middlewares
/// the pathTemplate of a handler can't be null
class Handler extends RoutingEntity implements RequestProcessor {
  final List<Middleware> middlewares = [];
  @override
  final String pathTemplate;

  Handler(
    this.pathTemplate,
    HttpMethod method,
    Processor processor, {
    List<Middleware> middlewares = const [],
  }) : super(pathTemplate, method, processor) {
    this.middlewares.addAll(middlewares);
  }

  /// local middlewares will run only for this handler and won't have any effect on other handlers
  Handler addLocalMiddleware(Processor processor) {
    Middleware middleware = Middleware(pathTemplate, method, processor);
    middlewares.add(middleware);
    return this;
  }

  @override
  List<RoutingEntity> processors(String path, HttpMethod method) {
    List<RoutingEntity> prs = [];
    bool handlerAdded = false;
    for (var middleware in middlewares) {
      prs.addAll(middleware.processors(path, method));
    }
    bool mine = PathCheckers(
      askedPath: path,
      askedMethod: method,
      routingEntity: this,
    ).isMyPath();
    if (mine) {
      prs.add(this);
      handlerAdded = true;
    }
    if (!handlerAdded) {
      return [];
    }
    return prs;
  }
}

/// the handler will return a RequestHolder or ResponseHolder
/// if the return is RequestHolder it will pass it to the next pipeline entity
/// if the return is ResponseHolder it won't be passed to the next pipeline entity
/// the pathTemplate for a middleware can be null, so it will be executed on all paths requested for a router
class Middleware extends RoutingEntity implements RequestProcessor {
  Middleware(super.pathTemplate, super.method, super.processor);

  @override
  List<RoutingEntity> processors(String path, HttpMethod method) {
    bool mine = PathCheckers(
      askedPath: path,
      askedMethod: method,
      routingEntity: this,
    ).isMyPath();
    if (mine) {
      return [this];
    }
    return [];
  }
}
