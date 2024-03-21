import 'dart:async';
import 'middleware.dart';
import 'options.dart';
import 'adapter.dart';

class HttpChain implements HttpMiddleware {
  final List<_MiddlewareDispatcher> _middlewares = [];

  void add(String path, HttpMiddleware dispatcher) {
    _middlewares.add(_MiddlewareDispatcher(path, dispatcher));
  }

  void removeWhere(bool Function(String, HttpMiddleware) test) {
    for (int i = _middlewares.length - 1; i >= 0; --i) {
      final middleware = _middlewares[i];
      if (test(middleware.matcher.pattern, middleware.dispatcher)) {
        _middlewares.removeAt(i);
        i = _middlewares.length;
      }
    }
  }

  void clear() => _middlewares.clear();

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    final middlewares = _findMiddleware(options.url.path);
    RequestOptions newOptions = options;
    for (var element in middlewares) {
      newOptions = await element.onRequest(newOptions);
    }
    return newOptions;
  }

  @override
  Future<RequestResponse> onResponse(RequestResponse response) async {
    final middlewares = _findMiddleware(response.request.url.path);
    RequestResponse newResponse = response;
    for (var element in middlewares) {
      newResponse = await element.onResponse(RequestResponse(
          request: newResponse.request,
          statusCode: newResponse.statusCode,
          statusText: newResponse.statusText,
          headers: newResponse.headers,
          bodyBytes: newResponse.bodyBytes));
    }
    return newResponse;
  }

  Iterable<HttpMiddleware> _findMiddleware(String path) {
    return _middlewares
        .where((element) => element.matcher.hasMatch(path))
        .map((e) => e.dispatcher);
  }
}

class _MiddlewareDispatcher {
  final RegExp matcher;
  final HttpMiddleware dispatcher;

  _MiddlewareDispatcher(String path, this.dispatcher) : matcher = RegExp(path);
}
