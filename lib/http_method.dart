// ignore_for_file: constant_identifier_names

class HttpMethods {
  static HttpMethod geT = GETMethod();
  static HttpMethod post = POSTMethod();
  static HttpMethod put = PUTMethod();
  static HttpMethod delete = DELETEMethod();
  static HttpMethod all = ALLMethod();
}

abstract class HttpMethod {
  late String? methodString;
  static HttpMethod fromString(String? m) {
    String? method = m?.toUpperCase();
    switch (method) {
      case 'GET':
        return GETMethod();
      // add the rest here
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

class ALLMethod implements HttpMethod {
  @override
  String? methodString;
}
