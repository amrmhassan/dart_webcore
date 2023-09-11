import 'dart:io';

import 'package:dart_webcore/dart_webcore/documentation/doc_generator.dart';

import '../constants/runtime_variables.dart';
import '../routing/impl/middleware.dart';
import '../routing/repo/http_method.dart';
import '../routing/repo/processor.dart';
import '../routing/repo/request_processor.dart';
import 'impl/request_handler.dart';

class ServerHolder {
  final List<HttpServer> _servers = [];
  final RequestProcessor _requestProcessor;
  final Function()? _onDone;
  final bool serveDocs;
  final String docsEndpoint;

  final Function()? _onError;
  final bool? _cancelOnError;
  final Processor? _onPathNotFound;
  final List<Middleware> _globalMiddlewares = [];

  ServerHolder(
    this._requestProcessor, {
    bool? cancelOnError,
    Function()? onDone,
    Function()? onError,
    Processor? onPathNotFound,
    this.serveDocs = true,
    this.docsEndpoint = '/docs',
  })  : _onPathNotFound = onPathNotFound,
        _onError = onError,
        _onDone = onDone,
        _cancelOnError = cancelOnError;

  HttpServer _handlerRequest(
    HttpServer server, {
    required String Function(String address, int port)? afterServerRunMessage,
  }) {
    String address = server.address == InternetAddress.anyIPv4
        ? '127.0.0.1'
        : server.address.address;
    String message = afterServerRunMessage == null
        ? 'server listening on http://$address:${server.port}'
        : afterServerRunMessage(address, server.port);
    dartExpressLogger.i(message);
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
    String Function(String address, int port)? afterServerMessage,
  }) async {
    var server = await HttpServer.bind(
      address,
      port,
      backlog: backlog,
      v6Only: v6Only,
      shared: shared,
    );
    return _handlerRequest(
      server,
      afterServerRunMessage: afterServerMessage,
    );
  }

  Future<HttpServer> bindSecure(
    InternetAddress address,
    int port,
    SecurityContext context, {
    int backlog = 0,
    bool v6Only = false,
    bool requestClientCertificate = false,
    bool shared = false,
    String Function(String address, int port)? afterServerMessage,
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
    return _handlerRequest(
      server,
      afterServerRunMessage: afterServerMessage,
    );
  }

  // Future<HttpServer> _listenOn(ServerSocket serverSocket) async {
  //   var server = HttpServer.listenOn(serverSocket);
  //   return _handlerRequest(server);
  // }

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
    String? signature,
  }) {
    Middleware middleware = Middleware(
      pathTemplate,
      method,
      processor,
      signature: signature,
    );
    return addGlobalRawMiddleWare(middleware);
  }

  ServerHolder addGlobalRawMiddleWare(Middleware middleware) {
    _globalMiddlewares.add(middleware);
    return this;
  }

  RequestProcessor get requestProcessor {
    return _requestProcessor;
  }

  void generateDoc() {
    DocGenerator docGenerator = DocGenerator(requestProcessor);
    docGenerator.generate();
  }
}
