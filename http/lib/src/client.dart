import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart' show IOStreamedResponse;
import 'package:http_parser/http_parser.dart' show MediaType;

import 'chain.dart';
import 'middleware.dart';
import 'retry.dart';
import 'cancelable.dart';

part 'internal.dart';

class AnnotationClient extends BaseClient {
  final _InternalClient _inner;
  final RetryOptions? retryOptions;

  AnnotationClient({
    this.retryOptions,
    int? timeout,
    CancelToken? cancelToken,
  }) : _inner = _InternalClient(timeout: timeout, cancelToken: cancelToken);

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    StreamedResponse response;
    final task =
        retryOptions != null ? _doRetryRequest(request) : _inner.send(request);
    if (_inner.cancelToken != null) {
      _inner.cancelToken?.bind(task);
      response = await _inner.cancelToken!.result;
    } else {
      response = await task;
    }
    final hasOk = response.statusCode >= 200 && response.statusCode < 300;
    if (!hasOk) {
      throw ClientException(
          response.reasonPhrase != null && response.reasonPhrase!.isNotEmpty
              ? response.reasonPhrase!
              : 'Http failed:${response.statusCode}',
          request.url);
    }
    return response;
  }

  @override
  void close() => _inner.close();

  Future<StreamedResponse> _doRetryRequest(BaseRequest request) async {
    final splitter = StreamSplitter(request.finalize());
    int i = 0;
    StreamedResponse? response;
    for (;;) {
      try {
        response = await _inner.send(_copyRequest(request, splitter.split()));
      } catch (error, stackTrace) {
        if (_inner._isCanceled ||
            i == retryOptions!.retries ||
            !await retryOptions!.whenError(error, stackTrace)) {
          rethrow;
        }
      }
      if (response != null) {
        if (i == retryOptions!.retries ||
            !await retryOptions!.whenResponse(response)) {
          break;
        } else {
          unawaited(response.stream.listen((_) {}).cancel().catchError((_) {}));
        }
      }
      await Future.delayed(retryOptions!.delay(i));
      i++;
    }
    return response;
  }

  StreamedRequest _copyRequest(BaseRequest original, Stream<List<int>> body) {
    final request = StreamedRequest(original.method, original.url)
      ..contentLength = original.contentLength
      ..followRedirects = original.followRedirects
      ..headers.addAll(original.headers)
      ..maxRedirects = original.maxRedirects
      ..persistentConnection = original.persistentConnection;
    body.listen(request.sink.add,
        onError: request.sink.addError,
        onDone: request.sink.close,
        cancelOnError: true);
    return request;
  }
}

Future<Response> doRequest(RequestOptions options,
    {HttpChain? chain,
    RetryOptions? retryOptions,
    int? timeout,
    CancelToken? cancelToken}) async {
  final client = AnnotationClient(
      retryOptions: retryOptions, timeout: timeout, cancelToken: cancelToken);
  try {
    StreamedResponse response;
    if (chain != null) {
      final request = await _buildRequest(await chain.onRequest(options));
      response = await client.send(request);
    } else {
      response = await client.send(await _buildRequest(options));
    }
    Response newResponse = await Response.fromStream(response);
    if (chain != null) {
      newResponse = await chain.onResponse(newResponse);
    }
    return newResponse;
  } finally {
    client.close();
  }
}

Future<BaseRequest> _buildRequest(RequestOptions options) async {
  BaseRequest request;
  if (options is MultipartRequestOptions) {
    final multipartRequest = MultipartRequest(options.method, options.url);
    multipartRequest.fields.addAll(
        options.fields.map((key, value) => MapEntry(key, value.toString())));
    for (var part in options.files) {
      final file = await MultipartFile.fromPath(
        part.field,
        part.filePath,
        filename: part.filename,
        contentType: MediaType.parse(part.contentType),
      );
      multipartRequest.files.add(file);
    }
    request = multipartRequest;
  } else {
    final formRequest = Request(options.method, options.url);
    final fields = (options as FormRequestOptions).fields;
    if (options.contentType != null &&
        options.contentType!.startsWith('application/json')) {
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
