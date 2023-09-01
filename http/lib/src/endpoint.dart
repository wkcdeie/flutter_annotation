import 'retry.dart';

/// Define an API request
class Endpoint {
  /// Request the base URL
  final String? baseUrl;

  /// Request parameters, which take precedence over methods
  final Map<String, dynamic>? parameters;

  /// Request header, which takes precedence over method
  final Map<String, String>? headers;

  /// Request timeout in milliseconds
  final int? timeout;

  /// Request a retry configuration
  final RetryOptions? retryOptions;

  const Endpoint(
      {this.baseUrl,
      this.parameters,
      this.headers,
      this.timeout,
      this.retryOptions});
}
