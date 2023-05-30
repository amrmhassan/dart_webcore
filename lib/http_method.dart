// ignore_for_file: constant_identifier_names

class HttpMethods {
  static HttpMethod geT = GETMethod();
  static HttpMethod post = POSTMethod();
  static HttpMethod put = PUTMethod();
  static HttpMethod delete = DELETEMethod();
  static HttpMethod all = ALLMethod();
}

abstract class HttpMethod {
  static HttpMethod fromString(String? m) {
    String? method = m?.toUpperCase();
    switch (method) {
      case 'GET':
        return GETMethod();
      // add the rest here
      default:
    }
    return ALLMethod();
  }
}

class GETMethod implements HttpMethod {}

class POSTMethod implements HttpMethod {}

class PUTMethod implements HttpMethod {}

class DELETEMethod implements HttpMethod {}

class ALLMethod implements HttpMethod {}
