import 'dart:async';
import 'package:http/http.dart' as http;
import 'middleware.dart';

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
  Future<http.BaseRequest> onRequest(http.BaseRequest request) async {
    final middlewares = _findMiddleware(request.url.path);
    http.BaseRequest newRequest = request;
    for (var element in middlewares) {
      newRequest = await element.onRequest(newRequest);
    }
    return newRequest;
  }

  @override
  Future<http.Response> onResponse(http.Response response) async {
    if (response.request == null) {
      return response;
    }
    final middlewares = _findMiddleware(response.request!.url.path);
    http.Response newResponse = response;
    for (var element in middlewares) {
      newResponse = await element.onResponse(http.Response.bytes(
        newResponse.bodyBytes,
        newResponse.statusCode,
        request: newResponse.request,
        headers: newResponse.headers,
        isRedirect: newResponse.isRedirect,
        persistentConnection: newResponse.persistentConnection,
        reasonPhrase: newResponse.reasonPhrase,
      ));
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
