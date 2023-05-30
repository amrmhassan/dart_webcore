// ignore_for_file: constant_identifier_names

class HttpMethods {
  static HttpMethod geT = GETMethod();
  static HttpMethod post = POSTMethod();
  static HttpMethod put = PUTMethod();
  static HttpMethod delete = DELETEMethod();
  static HttpMethod all = ALLMethod();
  static HttpMethod head = HEADMethod();
  static HttpMethod connect = CONNECTMethod();
  static HttpMethod options = OPTIONSMethod();
  static HttpMethod trace = TRACEMethod();
  static HttpMethod patch = PATCHMethod();
}

abstract class HttpMethod {
  late String? methodString;
  static HttpMethod fromString(String? m) {
    String? method = m?.toLowerCase();
    if (method == GETMethod().methodString) {
      return GETMethod();
    } else if (method == POSTMethod().methodString) {
      return POSTMethod();
    } else if (method == PUTMethod().methodString) {
      return PUTMethod();
    } else if (method == DELETEMethod().methodString) {
      return DELETEMethod();
    } else if (method == HEADMethod().methodString) {
      return HEADMethod();
    } else if (method == CONNECTMethod().methodString) {
      return CONNECTMethod();
    } else if (method == OPTIONSMethod().methodString) {
      return OPTIONSMethod();
    } else if (method == TRACEMethod().methodString) {
      return TRACEMethod();
    } else if (method == PATCHMethod().methodString) {
      return PATCHMethod();
    }
    return ALLMethod();
  }

  @override
  int get hashCode => methodString.hashCode;

  @override
  bool operator ==(Object other) {
    return super.hashCode == other.hashCode;
  }
}

class GETMethod implements HttpMethod {
  @override
  String? methodString = 'get';
}

class POSTMethod implements HttpMethod {
  @override
  String? methodString = 'post';
}

class PUTMethod implements HttpMethod {
  @override
  String? methodString = 'put';
}

class DELETEMethod implements HttpMethod {
  @override
  String? methodString = 'delete';
}

class HEADMethod implements HttpMethod {
  @override
  String? methodString = 'head';
}

class CONNECTMethod implements HttpMethod {
  @override
  String? methodString = 'connect';
}

class OPTIONSMethod implements HttpMethod {
  @override
  String? methodString = 'options';
}

class TRACEMethod implements HttpMethod {
  @override
  String? methodString = 'trace';
}

class PATCHMethod implements HttpMethod {
  @override
  String? methodString = 'patch';
}

class ALLMethod implements HttpMethod {
  @override
  String? methodString;
}
