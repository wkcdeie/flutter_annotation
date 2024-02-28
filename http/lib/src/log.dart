import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';

import 'middleware.dart';

class PrintCurlMiddleware implements HttpMiddleware {
  /// the severity level (a value between 0 and 2000);
  /// see the `package:logging` `Level` class for an overview of the possible values
  final int logLevel;

  const PrintCurlMiddleware([this.logLevel = 0]);

  @override
  Future<BaseRequest> onRequest(BaseRequest request) {
    StringBuffer cmd = StringBuffer();
    cmd.write('curl -X ${request.method.toUpperCase()} ');
    if (request.headers.isNotEmpty) {
      request.headers.forEach((key, value) {
        cmd.write('-H "$key: $value" ');
      });
    }
    if (request is MultipartRequest) {
      final multipartRequest = request;
      for (var field in multipartRequest.fields.entries) {
        cmd.write('-f "${field.key}: ${field.value}" ');
      }
      for (var file in multipartRequest.files) {
        cmd.write('-f "${file.field}: ${file.filename ?? ''}" ');
      }
    } else if (request is Request) {
      if (request.body.isNotEmpty) {
        cmd.write('-d "${request.body.replaceAll('"', '\\"')}" ');
      }
    }
    cmd.write('"${request.url}"');
    cmd.writeln();
    log(cmd.toString(), level: logLevel, name: 'HTTP');
    return Future.value(request);
  }

  @override
  Future<Response> onResponse(Response response) {
    return Future.value(response);
  }
}

enum OutputLogLevel {
  /// No logs.
  none,

  /// Logs request and response lines.
  ///
  /// Example:
  /// ```
  /// --> POST https://foo.bar/greeting (3-byte body)
  ///
  /// <-- 200 OK POST https://foo.bar/greeting (6-byte body)
  /// ```
  basic,

  /// Logs request and response lines and their respective headers.
  ///
  /// Example:
  /// ```
  /// --> POST https://foo.bar/greeting
  /// content-type: plain/text
  /// content-length: 3
  /// --> END POST
  ///
  /// <-- 200 OK POST https://foo.bar/greeting
  /// content-type: plain/text
  /// content-length: 6
  /// <-- END HTTP
  /// ```
  headers,

  /// Logs request and response lines and their respective headers and bodies (if present).
  ///
  /// Example:
  /// ```
  /// --> POST https://foo.bar/greeting
  /// content-type: plain/text
  /// content-length: 3
  ///
  /// Hi?
  /// --> END POST https://foo.bar/greeting
  ///
  /// <-- 200 OK POST https://foo.bar/greeting
  /// content-type: plain/text
  /// content-length: 6
  ///
  /// Hello!
  /// <-- END HTTP
  /// ```
  body,
}

class PrintLoggingMiddleware implements HttpMiddleware {
  final OutputLogLevel outputLogLevel;

  /// the severity level (a value between 0 and 2000);
  /// see the `package:logging` `Level` class for an overview of the possible values
  final int logLevel;

  bool get _logHeader => _logBody || outputLogLevel == OutputLogLevel.headers;

  bool get _logBody => outputLogLevel == OutputLogLevel.body;

  const PrintLoggingMiddleware(
      [this.outputLogLevel = OutputLogLevel.body, this.logLevel = 0]);

  @override
  Future<BaseRequest> onRequest(BaseRequest request) {
    if (outputLogLevel != OutputLogLevel.none) {
      StringBuffer msg = StringBuffer();
      msg.write('--> ${request.method} ${request.url}');
      if (_logHeader && request.contentLength != null) {
        msg.write(' (${request.contentLength}-byte body)');
      }
      msg.write('\n');
      if (_logHeader) {
        request.headers.forEach((key, value) {
          msg.writeln('$key:$value');
        });
        if (request.headers[HttpHeaders.contentLengthHeader] == null) {
          msg.writeln(
              '${HttpHeaders.contentLengthHeader}:${request.contentLength}');
        }
      }
      if (_logBody) {
        msg.writeln();
        if (request is Request) {
          msg.writeln(request.body);
        } else if (request is MultipartRequest) {
          request.fields.forEach((key, value) {
            msg.writeln('$key=$value');
          });
          for (var file in request.files) {
            msg.writeln(
                '${file.field}=${file.filename}/${file.length}/${file.contentType}');
          }
        }
      }
      if (_logHeader || _logBody) {
        msg.writeln('--> END ${request.method}');
      }
      log(msg.toString(), level: logLevel, name: 'HTTP');
    }
    return Future.value(request);
  }

  @override
  Future<Response> onResponse(Response response) {
    if (outputLogLevel != OutputLogLevel.none) {
      StringBuffer msg = StringBuffer();
      msg.writeln();
      msg.writeln(
          '<-- ${response.statusCode}${response.reasonPhrase != null ? ' ${response.reasonPhrase}' : ''} ${response.request?.method} ${response.request?.url}${!_logBody && _logHeader ? ' (${response.bodyBytes.length}-byte body)' : ''}');
      if (_logHeader) {
        response.headers.forEach((key, value) {
          msg.writeln('$key:$value');
        });
        if (response.headers[HttpHeaders.contentLengthHeader] == null) {
          msg.writeln(
              '${HttpHeaders.contentLengthHeader}:${response.contentLength}');
        }
      }
      if (_logBody && response.bodyBytes.isNotEmpty) {
        msg.writeln();
        if (response.bodyBytes.length > 1024 * 128) {
          msg.writeln(
              'The response content exceeds 128kb and the output is ignored.');
        } else {
          final checkBytes = response.bodyBytes.length > 1024
              ? response.bodyBytes.sublist(0, 1024)
              : response.bodyBytes;
          if (_isPlainText(checkBytes)) {
            msg.writeln(response.body);
          } else {
            msg.writeln(
                'Non-plain text data: ${response.headers[HttpHeaders.contentTypeHeader]}');
          }
        }
      }
      if (_logBody || _logHeader) {
        msg.writeln('<-- END HTTP');
      }
      log(msg.toString(), level: logLevel, name: 'HTTP');
    }
    return Future.value(response);
  }

  bool _isPlainText(Uint8List source) {
    int whiteListCharCount = 0;
    for (int i = 0; i < source.length; i++) {
      int byte = source[i];
      if (byte == 9 ||
          byte == 10 ||
          byte == 13 ||
          (byte >= 32 && byte <= 255)) {
        whiteListCharCount++;
      } else if (byte <= 6 || (byte >= 14 && byte <= 31)) {
        return false;
      }
    }
    return whiteListCharCount >= 1;
  }
}
