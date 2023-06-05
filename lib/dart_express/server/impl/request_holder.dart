import 'dart:io';

import '../../utils/request_decoder.dart';
import '../repo/passed_http_entity.dart';
import 'response_holder.dart';

class RequestHolder extends PassedHttpEntity {
  final HttpRequest request;
  late ResponseHolder response = ResponseHolder(request);

  RequestHolder(this.request);
  Map<String, dynamic> logging = {};
  Map<String, dynamic> context = {};

  late HttpHeaders headers = request.headers;
  late Uri uri = request.uri;
  late Uri requestedUri = request.requestedUri;
  // late X509Certificate? x509certificate = request.certificate;
  // late HttpConnectionInfo? httpConnectionInfo = request.connectionInfo;
  // late int contentLength = request.contentLength;
  // late List<Cookie> cookies = request.cookies;
  // late String method = request.method;
  // late bool persistentConnection = request.persistentConnection;
  // late String protocolVersion = request.protocolVersion;
  // late HttpResponse httpResponse = request.response;
  // late HttpSession session = request.session;
  // late Future<Uint8List> first = request.first;
  // late bool isBroadcast = request.isBroadcast;
  // late Future<bool> isEmpty = request.isEmpty;
  // late Future<Uint8List> last = request.last;
  // late Future<int> length = request.length;
  // late Future<Uint8List> single = request.single;

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
