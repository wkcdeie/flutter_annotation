// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// EndpointGenerator
// **************************************************************************

part of 'http_bin.dart';

class _$HttpBinApiImpl implements HttpBinApi {
  _$HttpBinApiImpl([this._chain]);

  final RetryOptions _retryOptions = RetryOptions(
    whenResponse: retryWhenResponse,
  );

  final HttpChain? _chain;

  @override
  Future<void> getStatus(int codes) async {
    final urlString = _encodeUrl('https://httpbin.org/status/$codes', {});
    await doWithClient(
      (client) => client.get(Uri.parse(urlString)),
      chain: _chain,
      retryOptions: _retryOptions,
      timeout: 10000,
    );
  }

  @override
  Future<Map<dynamic, dynamic>> runJson() async {
    final urlString = _encodeUrl('https://httpbin.org/json', {});
    final response = await doWithClient(
      (client) => client.get(Uri.parse(urlString)),
      chain: _chain,
      retryOptions: _retryOptions,
      timeout: 10000,
    );
    final responseData = jsonDecode(response.body);
    if (responseData is Map) {
      return Map<dynamic, dynamic>.from(responseData);
    }
    throw UnsupportedError(
        'Could not find acceptable representation. Type convert:${responseData.runtimeType}=>Map<dynamic, dynamic>');
  }

  @override
  Future<String> getRobotsTxt() async {
    final urlString = _encodeUrl('https://httpbin.org/robots.txt', {});
    final response = await doWithClient(
      (client) => client.get(Uri.parse(urlString)),
      chain: _chain,
      retryOptions: _retryOptions,
      timeout: 10000,
    );
    return response.body;
  }

  @override
  Future<Uint8List> runBytes(int n) async {
    final urlString = _encodeUrl('https://httpbin.org/bytes/$n', {});
    final response = await doWithClient(
      (client) => client.get(Uri.parse(urlString)),
      chain: _chain,
      retryOptions: _retryOptions,
      timeout: 10000,
    );
    return response.bodyBytes;
  }

  @override
  Future<String> upload(
    String type,
    String from,
    UploadEnvInfo envInfo,
    String imagePath,
  ) async {
    final urlString = _encodeUrl('https://httpbin.org/upload', {});
    final request = http.MultipartRequest('POST', Uri.parse(urlString));
    request.headers.addAll({'type': Uri.encodeQueryComponent(type)});
    request.fields.addAll({'from': from});
    request.fields.addAll({...envInfo.toJson()});
    request.files.add(await http.MultipartFile.fromPath('imagePath', imagePath,
        filename: path.basename(imagePath),
        contentType: MediaType.parse(mime_type.lookupMimeType(imagePath) ??
            'application/octet-stream')));
    final rawResponse = await doWithClient(
      (client) => client.send(request),
      chain: _chain,
      retryOptions: _retryOptions,
      timeout: 60000,
    );
    final response = await http.Response.fromStream(rawResponse);
    return response.body;
  }

  @override
  Future<void> cancelRequest(
    int codes,
    CancelToken cancelToken,
  ) async {
    final urlString = _encodeUrl('https://httpbin.org/status/$codes', {});
    await doWithClient(
      (client) => client.get(Uri.parse(urlString)),
      chain: _chain,
      retryOptions: _retryOptions,
      timeout: 10000,
      cancelToken: cancelToken,
    );
  }

  String _encodeUrl(
    String urlPath,
    Map<String, dynamic> queryParameters,
  ) {
    if (queryParameters.isEmpty) {
      return urlPath;
    }
    final queryString = queryParameters.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${e.value is String ? Uri.encodeQueryComponent(e.value) : e.value}')
        .join('&');
    if (urlPath.lastIndexOf('?') != -1) {
      return '$urlPath&$queryString';
    }
    return '$urlPath?$queryString';
  }
}
