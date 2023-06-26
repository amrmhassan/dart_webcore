library dart_webcore;

//! add addUpperMiddleware
//! add addRawUpperMiddleware
//! to router, pipeline

//! edit cascade to accept adding routers

export './dart_webcore/routing/impl/router.dart';
export './dart_webcore/routing/impl/cascade.dart';
export './dart_webcore/routing/impl/handler.dart';
export './dart_webcore/routing/impl/pipeline.dart';
export './dart_webcore/routing/impl/middleware.dart';
export 'dart_webcore/server/server_holder.dart';
export './dart_webcore/serving_folder/files_serving.dart';
export './dart_webcore/routing/repo/http_method.dart';
export './dart_webcore/utils/middlewares/logger_middleware.dart';
export './dart_webcore/documentation/doc_generator.dart';
