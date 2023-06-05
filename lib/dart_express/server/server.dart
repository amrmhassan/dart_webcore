import 'dart:io';

import '../../constants/runtime_variables.dart';
import '../routing/impl/middleware.dart';
import '../routing/repo/http_method.dart';
import '../routing/repo/processor.dart';
import '../routing/repo/request_processor.dart';
import 'impl/request_handler.dart';

class ServerHolder {
  final List<HttpServer> _servers = [];
  final RequestProcessor _requestProcessor;
  final Function()? _onDone;

  final Function()? _onError;
  final bool? _cancelOnError;
  final Processor? _onPathNotFound;
  final List<Middleware> _globalMiddlewares = [];
  final Processor? _onResponseClosed;

  ServerHolder(
    this._requestProcessor, {
    bool? cancelOnError,
    Function()? onDone,
    Function()? onError,
    Processor? onPathNotFound,
    Processor? onResponseClosed,
  })  : _onPathNotFound = onPathNotFound,
        _onError = onError,
        _onDone = onDone,
        _cancelOnError = cancelOnError,
        _onResponseClosed = onResponseClosed;

  HttpServer _handlerRequest(HttpServer server) {
    // String address = server.address == InternetAddress.anyIPv4
    //     ? '127.0.0.1'
    //     : server.address.address;
    dartExpressLogger.i('server listening on port ${server.port}');
    RequestHandler handler = RequestHandler(
      _requestProcessor,
      _globalMiddlewares,
      onPathNotFound: _onPathNotFound,
    );
    server.listen(
      handler.handler,
      cancelOnError: _cancelOnError,
      onDone: _onDone,
      onError: _onError,
    );
    _servers.add(server);
    return server;
  }

  Future<HttpServer> bind(
    InternetAddress address,
    int port, {
    int backlog = 0,
    bool v6Only = false,
    bool shared = false,
  }) async {
    var server = await HttpServer.bind(
      address,
      port,
      backlog: backlog,
      v6Only: v6Only,
      shared: shared,
    );
    return _handlerRequest(server);
  }

  Future<HttpServer> bindSecure(
    InternetAddress address,
    int port,
    SecurityContext context, {
    int backlog = 0,
    bool v6Only = false,
    bool requestClientCertificate = false,
    bool shared = false,
  }) async {
    var server = await HttpServer.bindSecure(
      address,
      port,
      context,
      backlog: backlog,
      v6Only: v6Only,
      requestClientCertificate: requestClientCertificate,
      shared: shared,
    );
    return _handlerRequest(server);
  }

  Future<HttpServer> listenOn(ServerSocket serverSocket) async {
    var server = HttpServer.listenOn(serverSocket);
    return _handlerRequest(server);
  }

  Future<void> closeAllRunningServers() async {
    for (var server in _servers) {
      try {
        await server.close();
        _servers.remove(server);
      } catch (e) {
        dartExpressLogger.e('can\'t close server on port ${server.port}');
      }
    }
  }

  ServerHolder addGlobalMiddleware(
    Processor processor, {
    String? pathTemplate,
    HttpMethod method = HttpMethods.all,
  }) {
    Middleware middleware = Middleware(pathTemplate, method, processor);
    _globalMiddlewares.add(middleware);

    return this;
  }
}
