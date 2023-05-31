import 'dart:io';

import 'package:custom_shelf/utils/request_handler.dart';

import '../routing/http_method.dart';
import '../routing/request_processor.dart';
import '../routing/routing_entities.dart';

class ServerHolder {
  final List<HttpServer> _servers = [];
  final RequestProcessor requestProcessor;
  final Function()? onRequestDone;

  final Function()? onRequestError;
  final bool? cancelOnError;
  final Processor? onPathNotFound;
  final List<Middleware> _globalMiddlewares = [];

  ServerHolder(
    this.requestProcessor, {
    this.cancelOnError,
    this.onRequestDone,
    this.onRequestError,
    this.onPathNotFound,
  });

  HttpServer _handlerRequest(HttpServer server) {
    String address = server.address == InternetAddress.anyIPv4
        ? '127.0.0.1'
        : server.address.address;
    print('server listening on http://$address:${server.port}');
    //! here use the processors getter and run on the request listener
    RequestHandler handler = RequestHandler(
      requestProcessor,
      _globalMiddlewares,
      onPathNotFound: onPathNotFound,
    );
    server.listen(
      handler.handler,
      cancelOnError: cancelOnError,
      onDone: onRequestDone,
      onError: onRequestError,
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
        print('can\'t close server on port ${server.port}');
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
