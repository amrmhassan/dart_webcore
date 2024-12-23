// ignore_for_file: constant_identifier_names

class HttpMethods {
  static const HttpMethod geT = _GetMethod();
  static const HttpMethod post = _PostMethod();
  static const HttpMethod put = _PutMethod();
  static const HttpMethod delete = _DeleteMethod();
  static const HttpMethod head = _HeadMethod();
  static const HttpMethod connect = _CONNECTMethod();
  static const HttpMethod options = _OptionsMethod();
  static const HttpMethod trace = _TraceMethod();
  static const HttpMethod patch = _PatchMethod();
  static const HttpMethod all = _All();
}

class HttpMethod {
  final String? methodString;
  const HttpMethod(this.methodString);
  static HttpMethod fromString(String? m) {
    String? method = m?.toLowerCase();
    if (method == const _GetMethod().methodString) {
      return const _GetMethod();
    } else if (method == const _PostMethod().methodString) {
      return const _PostMethod();
    } else if (method == const _PutMethod().methodString) {
      return const _PutMethod();
    } else if (method == const _DeleteMethod().methodString) {
      return const _DeleteMethod();
    } else if (method == const _HeadMethod().methodString) {
      return const _HeadMethod();
    } else if (method == const _CONNECTMethod().methodString) {
      return const _CONNECTMethod();
    } else if (method == const _OptionsMethod().methodString) {
      return const _OptionsMethod();
    } else if (method == const _TraceMethod().methodString) {
      return const _TraceMethod();
    } else if (method == const _PatchMethod().methodString) {
      return const _PatchMethod();
    } else if (method == const _All().methodString) {
      return const _All();
    }
    return const _UnknownMethod();
  }

  @override
  int get hashCode => methodString.hashCode;

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}

class _GetMethod extends HttpMethod {
  const _GetMethod() : super('get');
}

class _PostMethod extends HttpMethod {
  const _PostMethod() : super('post');
}

class _PutMethod extends HttpMethod {
  const _PutMethod() : super('put');
}

class _DeleteMethod extends HttpMethod {
  const _DeleteMethod() : super('delete');
}

class _HeadMethod extends HttpMethod {
  const _HeadMethod() : super('head');
}

class _CONNECTMethod extends HttpMethod {
  const _CONNECTMethod() : super('connect');
}

class _OptionsMethod extends HttpMethod {
  const _OptionsMethod() : super('options');
}

class _TraceMethod extends HttpMethod {
  const _TraceMethod() : super('trace');
}

class _PatchMethod extends HttpMethod {
  const _PatchMethod() : super('patch');
}

class _All extends HttpMethod {
  const _All() : super('all');
}

class _UnknownMethod extends HttpMethod {
  const _UnknownMethod() : super(null);
}
