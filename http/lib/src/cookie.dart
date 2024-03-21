import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';

import 'adapter.dart';
import 'options.dart';
import 'middleware.dart';

class CookieJarMiddleware extends HttpMiddleware {
  final _setCookieReg = RegExp('(?<=)(,)(?=[^;]+?=)');
  final CookieJar cookieJar;

  CookieJarMiddleware(this.cookieJar);

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    final currentCookies = options.headers[HttpHeaders.cookieHeader];
    final cookies = await this.cookieJar.loadForRequest(options.url);
    if (currentCookies?.isNotEmpty ?? false) {
      cookies.insertAll(
          0,
          currentCookies!
              .split(_setCookieReg)
              .where((element) => element.isNotEmpty)
              .map((e) => Cookie.fromSetCookieValue(e)));
    }
    if (cookies.isNotEmpty) {
      options.headers[HttpHeaders.cookieHeader] =
          cookies.map((e) => '${e.name}=${e.value}').join('; ');
    }
    return options;
  }

  @override
  Future<RequestResponse> onResponse(RequestResponse response) {
    final serverCookies = response.headers[HttpHeaders.setCookieHeader];
    if (serverCookies?.isNotEmpty ?? false) {
      final cookies = serverCookies!
          .split(_setCookieReg)
          .expand(
              (e) => e.isNotEmpty ? [Cookie.fromSetCookieValue(e)] : <Cookie>[])
          .toList();
      if (cookies.isNotEmpty) {
        unawaited(this
            .cookieJar
            .saveFromResponse(response.request.url, cookies)
            .then((_) {})
            .catchError((_) {}));
      }
    }
    return Future.value(response);
  }
}
