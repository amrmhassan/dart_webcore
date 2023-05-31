import 'dart:async';
import 'dart:io';

import 'package:custom_shelf/utils/request_decoder.dart';
import 'dart:convert' as convert;

import 'package:custom_shelf/utils/response_utils.dart';

/// this will be the entity that will be passed through the app routing entities
abstract class PassedHttpEntity {}

class ResponseHolder implements PassedHttpEntity {
  final HttpRequest request;
  HttpResponse get response => request.response;

  ResponseHolder(this.request);
  bool closed = false;
  String? closeMessage;
  dynamic closeData;

  Future<ResponseHolder> close({String? closeMessage}) async {
    try {
      closeData = await response.close();
      closed = true;
      closeMessage = closeMessage;
    } catch (e) {
      //
    }
    return this;
  }

  ResponseHolder write(Object? object) {
    response.write(object);
    return this;
  }

  ResponseHolder add(List<int> data) {
    response.headers.contentLength = data.length;
    response.add(data);
    return this;
  }

  ResponseHolder writeJson(Map<String, dynamic> obj) {
    response.headers.contentType = ContentType.json;
    return write(convert.json.encode(obj));
  }

  ResponseHolder writeHtml(String html) {
    response.headers.contentType = ContentType.html;
    return write(html);
  }

  ResponseHolder writeBinary(List<int> bytes) {
    response.headers.contentType = ContentType.binary;
    return add(bytes);
  }

  final ResponseUtils _responseUtils = ResponseUtils();

  Future<ResponseHolder> writeFile(String filePath) async {
    _responseUtils.sendChunkedFile(request, filePath);
    return this;
  }

  Future<ResponseHolder> streamMedia(String filePath) async {
    _responseUtils.streamV2(request, filePath);
    return this;
  }

  Future<ResponseHolder> addStream(Stream<List<int>> stream) async {
    await response.addStream(stream);
    return this;
  }

  //? original response properties
  late HttpHeaders headers = response.headers;
  // late bool bufferOutput = response.bufferOutput;
  // late HttpConnectionInfo? connectionInfo = response.connectionInfo;
  // late int contentLength = response.contentLength;
  // late List<Cookie> cookies = response.cookies;
  // late Duration? deadline = response.deadline;
  // late bool persistentConnection = response.persistentConnection;
  // late String reasonPhrase = response.reasonPhrase;
  // late int statusCode = response.statusCode;

  void test() {}
}

class RequestHolder implements PassedHttpEntity {
  final HttpRequest request;
  late ResponseHolder response = ResponseHolder(request);
  Map<String, dynamic> context = {};
  RequestHolder(this.request);

  late HttpHeaders headers = request.headers;
  // late X509Certificate? x509certificate = request.certificate;
  // late HttpConnectionInfo? httpConnectionInfo = request.connectionInfo;
  // late int contentLength = request.contentLength;
  // late List<Cookie> cookies = request.cookies;
  // late String method = request.method;
  // late bool persistentConnection = request.persistentConnection;
  // late String protocolVersion = request.protocolVersion;
  // late Uri requestedUri = request.requestedUri;
  // late HttpResponse httpResponse = request.response;
  // late HttpSession session = request.session;
  // late Uri uri = request.uri;
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
