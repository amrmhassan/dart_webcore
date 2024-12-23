import 'dart:async';

import '../../server/impl/request_holder.dart';
import '../../server/impl/response_holder.dart';
import '../../server/repo/passed_http_entity.dart';

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

typedef AfterProcessor = FutureOr<void> Function(
  RequestHolder request,
  ResponseHolder response,
  Map<String, dynamic> pathArgs,
);
