import 'package:flutter_annotation_http/flutter_annotation_http.dart';
import 'package:http/http.dart';

@Middleware('/*')
class TokenMiddleware implements HttpMiddleware {
  final String headerKey;
  String? _token;

  String? get token => _token;

  TokenMiddleware([this.headerKey = 'token']);

  @override
  Future<RequestOptions> onRequest(RequestOptions options) {
    if (token != null) {
      options.headers[headerKey] = token!;
    }
    return Future.value(options);
  }

  @override
  Future<Response> onResponse(Response response) {
    if (response.headers[headerKey] != null) {
      _token = response.headers[headerKey];
    }
    return Future.value(response);
  }
}
