import 'dart:async';
import 'dart:math' as math;

import 'package:http/http.dart';

typedef RetryWhenResponse = FutureOr<bool> Function(BaseResponse);
typedef RetryWhenError = FutureOr<bool> Function(Object, StackTrace);
typedef RetryDelay = Duration Function(int);

/// A request retries the configuration class
class RetryOptions {
  /// The callback that determines whether a request should be retried.
  final RetryWhenResponse whenResponse;

  /// The callback that determines whether a request when an error is thrown.
  final RetryWhenError whenError;

  /// The callback that determines how long to wait before retrying a request.
  final RetryDelay delay;

  /// The number of times a request should be retried.
  final int retries;

  const RetryOptions({
    this.retries = 3,
    this.whenResponse = _defaultWhen,
    this.whenError = _defaultWhenError,
    this.delay = _defaultDelay,
  });
}

bool _defaultWhen(BaseResponse response) => response.statusCode == 503;

bool _defaultWhenError(Object error, StackTrace stackTrace) => false;

Duration _defaultDelay(int retryCount) =>
    const Duration(milliseconds: 500) * math.pow(1.5, retryCount);
