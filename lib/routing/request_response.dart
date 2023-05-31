import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:custom_shelf/utils/request_decoder.dart';

/// this will be the entity that will be passed through the app routing entities
abstract class PassedHttpEntity {}

class ResponseHolder implements PassedHttpEntity {
  final HttpResponse response;
  ResponseHolder(this.response);
  bool closed = false;
  String? closeMessage;
  dynamic closeData;

  Future<ResponseHolder> close({String? closeMessage}) async {
    closed = true;
    closeMessage = closeMessage;
    closeData = await response.close();
    return this;
  }

  ResponseHolder write(Object? object) {
    response.write(object);
    return this;
  }
}

class RequestHolder implements PassedHttpEntity {
  final HttpRequest request;
  Map<String, dynamic> context = {};
  RequestHolder(this.request);

  ResponseHolder get response => ResponseHolder(request.response);
  HttpHeaders get headers => request.headers;
  X509Certificate? get x509certificate => request.certificate;
  HttpConnectionInfo? get httpConnectionInfo => request.connectionInfo;
  int get contentLength => request.contentLength;
  List<Cookie> get cookies => request.cookies;
  String get method => request.method;
  bool get persistentConnection => request.persistentConnection;
  String get protocolVersion => request.protocolVersion;
  Uri get requestedUri => request.requestedUri;
  HttpResponse get httpResponse => request.response;
  HttpSession get session => request.session;
  Uri get uri => request.uri;
  Future<Uint8List> get first => request.first;
  bool get isBroadcast => request.isBroadcast;
  Future<bool> get isEmpty => request.isEmpty;
  Future<Uint8List> get last => request.last;
  Future<int> get length => request.length;
  Future<Uint8List> get single => request.single;

  //? some original request overrides
  @override
  int get hashCode => request.hashCode;
  @override
  Type get runtimeType => request.runtimeType;
  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }

  //? original request methods

  //? request decoders
  final RequestDecoder _requestDecoder = RequestDecoder();
  Future<dynamic> readAsJson() => _requestDecoder.readAsJson(request);
  Future<String> readAsString() => _requestDecoder.readAsString(request);
  Future<List<int>> readAsBytes() => _requestDecoder.readAsBytes(request);
}
