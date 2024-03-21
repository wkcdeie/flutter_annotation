import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:http/http.dart' as http;
import 'options.dart';
import 'chain.dart';
import 'request.dart';
import 'retry.dart';
import 'cancelable.dart';
import 'client.dart';

class RequestResponse {
  final RequestOptions request;
  final int statusCode;
  final String? statusText;
  final Map<String, String> headers;
  final Uint8List bodyBytes;

  String get body => getEncoding().decode(bodyBytes);

  RequestResponse(
      {required this.request,
      required this.statusCode,
      this.statusText,
      required this.headers,
      required this.bodyBytes});

  Encoding getEncoding([Encoding fallback = latin1]) {
    String? charset;
    final contentType = headers[HttpHeaders.contentTypeHeader];
    if (contentType != null) {
      charset = ContentType.parse(contentType).charset;
    } else {
      charset = ContentType.binary.charset;
    }
    if (charset == null) return fallback;
    return Encoding.getByName(charset) ?? fallback;
  }
}

abstract class RequestAdapter {
  static final RequestAdapter defaultAdapter =
      DefaultRequestAdapter(chain: HttpChain());
  HttpChain? chain;

  Future<RequestResponse> doRequest(RequestOptions options,
      {RetryOptions? retryOptions, int? timeout, CancelToken? cancelToken});
}

class DefaultRequestAdapter implements RequestAdapter {
  @override
  HttpChain? chain;

  DefaultRequestAdapter({this.chain});

  @override
  Future<RequestResponse> doRequest(RequestOptions options,
      {RetryOptions? retryOptions,
      int? timeout,
      CancelToken? cancelToken}) async {
    final client = AnnotationClient(
        retryOptions: retryOptions, timeout: timeout, cancelToken: cancelToken);
    try {
      RequestOptions newOptions = options;
      if (this.chain != null) {
        newOptions = await this.chain!.onRequest(options);
      }
      final request = await _buildRequest(newOptions);
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      RequestResponse newResponse = RequestResponse(
          request: newOptions,
          statusCode: response.statusCode,
          statusText: response.reasonPhrase,
          headers: response.headers,
          bodyBytes: response.bodyBytes);
      if (this.chain != null) {
        newResponse = await this.chain!.onResponse(newResponse);
      }
      return newResponse;
    } catch (e) {
      throw e;
    } finally {
      client.close();
    }
  }

  Future<http.BaseRequest> _buildRequest(RequestOptions options) async {
    http.BaseRequest request;
    if (options is MultipartRequestOptions) {
      final multipartRequest =
          http.MultipartRequest(options.method, options.url);
      multipartRequest.fields.addAll(
          options.fields.map((key, value) => MapEntry(key, value.toString())));
      for (var part in options.files) {
        final file = await http.MultipartFile.fromPath(
          part.field,
          part.filePath,
          filename: part.filename,
          contentType: MediaType.parse(part.contentType),
        );
        multipartRequest.files.add(file);
      }
      request = multipartRequest;
    } else {
      final formRequest = http.Request(options.method, options.url);
      final fields = (options as FormRequestOptions).fields;
      if (options.contentType != null &&
          options.contentType!.startsWith(RequestMapping.jsonHeader)) {
        formRequest.body = jsonEncode(fields);
      } else {
        formRequest.bodyFields =
            fields.map((key, value) => MapEntry(key, value.toString()));
      }
      request = formRequest;
    }
    request.headers.addAll(options.headers);
    request.maxRedirects = options.maxRedirects;
    request.followRedirects = options.followRedirects;
    request.persistentConnection = options.persistentConnection;
    return request;
  }
}
