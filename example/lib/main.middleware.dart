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
  HttpChain? chain,
  bool printCurl = isDebugMode,
  bool printLogging = isDebugMode,
}) {
  final ch = chain ?? HttpChain.shared;
  ch.add('/*', TokenMiddleware());
  if (printCurl) {
    ch.add('/*', const PrintCurlMiddleware());
  }
  if (printLogging) {
    ch.add('/*', const PrintLoggingMiddleware());
  }
}
