part of 'client.dart';

class _InternalClient extends BaseClient {
  final CancelToken? cancelToken;
  HttpClient? _inner;

  bool get _isCanceled => cancelToken?.isCanceled ?? false;

  _InternalClient({int? timeout, this.cancelToken, HttpClient? inner})
      : _inner = inner ?? HttpClient() {
    if (timeout != null) {
      _inner?.connectionTimeout = Duration(milliseconds: timeout);
    }
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final uri = request.url;
    if (_isCanceled) {
      _throwCancelledError(uri);
    }
    if (_inner == null) {
      throw ClientException(
          'HTTP request failed. Client is already closed.', request.url);
    }
    final timeout = _inner?.connectionTimeout;
    try {
      final stream = request.finalize();
      var reqTask = _inner!.openUrl(request.method, request.url);
      if (timeout != null) {
        reqTask = reqTask.timeout(timeout);
      }

      var ioRequest = (await reqTask)
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..contentLength = (request.contentLength ?? -1)
        ..persistentConnection = request.persistentConnection;

      if (_isCanceled) {
        Future task = ioRequest.close();
        if (timeout != null) {
          task = task.timeout(timeout);
        }
        unawaited(task.then((_) {}).catchError((_) {}));
        _throwCancelledError(uri);
      }

      request.headers.forEach((name, value) {
        ioRequest.headers.set(name, value);
      });

      var respTask = stream.pipe(ioRequest);
      if (timeout != null) {
        respTask = respTask.timeout(timeout);
      }

      var response = (await respTask) as HttpClientResponse;

      if (_isCanceled) {
        unawaited(response
            .detachSocket()
            .then((value) => value.destroy())
            .then((_) {})
            .catchError((_) {}));
        _throwCancelledError(uri);
      }

      var headers = <String, String>{};
      response.headers.forEach((key, values) {
        headers[key] = values.join(',');
      });

      return IOStreamedResponse(
          response.handleError((Object error) {
            final httpException = error as HttpException;
            throw ClientException(httpException.message, httpException.uri);
          }, test: (error) => error is HttpException),
          response.statusCode,
          contentLength:
              response.contentLength == -1 ? null : response.contentLength,
          request: request,
          headers: headers,
          isRedirect: response.isRedirect,
          persistentConnection: response.persistentConnection,
          reasonPhrase: response.reasonPhrase,
          inner: response);
    } on TimeoutException catch (error) {
      throw ClientException(
          'Connecting timed out [${error.duration?.inMilliseconds}ms]', uri);
    } on SocketException catch (error) {
      throw _ClientSocketException(error, request.url);
    } on HttpException catch (error) {
      throw ClientException(error.message, error.uri);
    }
  }

  @override
  void close() {
    if (_inner != null) {
      _inner!.close(force: true);
      _inner = null;
    }
  }

  void _throwCancelledError(Uri uri) {
    throw ClientException('Cancel the request.', uri);
  }
}

class _ClientSocketException extends ClientException
    implements SocketException {
  final SocketException cause;

  _ClientSocketException(SocketException e, Uri url)
      : cause = e,
        super(e.message, url);

  @override
  InternetAddress? get address => cause.address;

  @override
  OSError? get osError => cause.osError;

  @override
  int? get port => cause.port;
}
