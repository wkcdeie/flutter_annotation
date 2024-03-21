import 'options.dart';
import 'adapter.dart';

/// Represents a middleware class
class Middleware {
  /// Middleware intercepts the path
  final String path;

  /// Middleware execution priority
  final int priority;

  /// The name of the method that created the instance
  final String? createFactory;

  const Middleware(this.path, {this.priority = 1, this.createFactory});
}

/// Indicates whether the HTTP middleware feature is enabled
class EnableHttpMiddleware {
  const EnableHttpMiddleware();
}

/// HTTP middleware interface
abstract class HttpMiddleware {
  /// The request is about to start
  Future<RequestOptions> onRequest(RequestOptions options);

  /// Before the response is returned
  Future<RequestResponse> onResponse(RequestResponse response);
}
