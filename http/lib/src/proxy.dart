import 'dart:io';

class ProxyHttpOverrides extends HttpOverrides {
  String? host;
  String? port;
  String? noProxy;

  String? get _proxySetting => host != null ? '$host:${port ?? '8888'}' : null;

  ProxyHttpOverrides({this.host, this.port, this.noProxy});

  static ProxyHttpOverrides? get global =>
      HttpOverrides.current as ProxyHttpOverrides?;

  void setGlobal() {
    HttpOverrides.global = this;
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (cert, host, port) {
      return _proxySetting != null;
    };
    return client;
  }

  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
    final proxy = _proxySetting;
    if (proxy != null) {
      environment ??= {};
      environment['http_proxy'] = proxy;
      environment['https_proxy'] = proxy;
      if (noProxy != null) {
        environment['no_proxy'] = noProxy!;
      }
    }
    return super.findProxyFromEnvironment(url, environment);
  }
}
