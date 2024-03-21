// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// EnableHttpMiddlewareGenerator
// **************************************************************************

import 'package:flutter_annotation_http/flutter_annotation_http.dart';
import 'package:example/http/token_middleware.dart';

const bool _isReleaseMode = bool.fromEnvironment('dart.vm.product');
const bool _isProfileMode = bool.fromEnvironment('dart.vm.profile');
const bool isDebugMode = !_isReleaseMode && !_isProfileMode;
void setupMiddlewares({
  RequestAdapter? adapter,
  bool printCurl = isDebugMode,
  bool printLogging = isDebugMode,
}) {
  final chain = (adapter ?? RequestAdapter.defaultAdapter).chain;
  if (chain != null) {
    chain.add('/*', TokenMiddleware());
    if (printCurl) {
      chain.add('/*', const PrintCurlMiddleware());
    }
    if (printLogging) {
      chain.add('/*', const PrintLoggingMiddleware());
    }
  }
}
