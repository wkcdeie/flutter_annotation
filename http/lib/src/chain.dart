import 'dart:async';
import 'middleware.dart';
import 'options.dart';
import 'adapter.dart';

class HttpChain implements HttpMiddleware {
  static HttpChain? _instance;

  final List<_MiddlewareDispatcher> _middlewares = [];

  static HttpChain get shared {
    _instance ??= HttpChain();
    return _instance!;
  }

  void add(String path, HttpMiddleware dispatcher) {
    _middlewares.add(_MiddlewareDispatcher(path, dispatcher));
  }

  void remove(String path) {
    for (int i = 0; i < _middlewares.length; i++) {
      if (_middlewares[i].matcher.pattern == path) {
        _middlewares.removeAt(i);
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
