import 'package:uuid/uuid.dart';

import '../../matchers/impl/path_checkers.dart';
import '../impl/middleware.dart';
import 'http_method.dart';
import 'processor.dart';

class RoutingEntity {
  /// this is the path of the handler or the middleware not the incoming request path
  /// the null pathTemplate means that this Middleware will run on every request no matter it's path
  /// but the method will restrict this, if you want to make a global middleware just make the pathTemplate to be null and the method to be HttpMethods.all
  final String? pathTemplate;

  /// this is the method of the handler or middleware not the incoming request method
  final HttpMethod method;

  /// this is the function that will be executed when hitting this routing entity
  final Processor processor;

  String? _signature;

  RoutingEntity(
    this.pathTemplate,
    this.method,
    this.processor, {
    required String? signature,
  }) {
    // validating the signature
    if (signature != null) {
      if (signature.contains('|')) {
        throw Exception('signature can\'t contain the reserved char |');
      }
      bool isMiddleware = this is Middleware;
      String suffix = isMiddleware ? 'M' : 'H';
      String id = const Uuid().v4();

      _signature = '$suffix|$signature|$id';
    }
  }

  String? get signature => _signature;
  String? get originalSignature => _signature?.split('|')[1];

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
