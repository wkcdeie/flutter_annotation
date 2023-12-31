import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart' show IOStreamedResponse;

import 'chain.dart';
import 'retry.dart';
import 'cancelable.dart';

part 'internal.dart';

class AnnotationClient extends BaseClient {
  final _InternalClient _inner;
  final HttpChain? chain;
  final RetryOptions? retryOptions;

  AnnotationClient({
    this.chain,
    this.retryOptions,
    int? timeout,
    CancelToken? cancelToken,
  }) : _inner = _InternalClient(timeout: timeout, cancelToken: cancelToken);

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    BaseRequest newRequest = request;
    if (chain != null) {
      newRequest = await chain!.onRequest(newRequest);
    }
    StreamedResponse response;
    final task = retryOptions != null
        ? _doRetryRequest(newRequest)
        : _inner.send(newRequest);
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
          newRequest.url);
    }
    Response newResponse = await Response.fromStream(response);
    if (chain != null) {
      newResponse = await chain!.onResponse(newResponse);
    }
    return StreamedResponse(
      ByteStream.fromBytes(newResponse.bodyBytes),
      newResponse.statusCode,
      contentLength: newResponse.contentLength,
      request: newResponse.request,
      headers: newResponse.headers,
      isRedirect: newResponse.isRedirect,
      persistentConnection: newResponse.persistentConnection,
      reasonPhrase: newResponse.reasonPhrase,
    );
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

Future<T> doWithClient<T>(
  Future<T> Function(Client) fn, {
  HttpChain? chain,
  RetryOptions? retryOptions,
  int? timeout,
  CancelToken? cancelToken,
}) async {
  final client = AnnotationClient(
    chain: chain,
    retryOptions: retryOptions,
    timeout: timeout,
    cancelToken: cancelToken,
  );
  try {
    return await fn(client);
  } finally {
    client.close();
  }
}
