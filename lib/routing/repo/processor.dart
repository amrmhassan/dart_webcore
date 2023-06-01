import 'dart:async';

import '../request_response.dart';

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
