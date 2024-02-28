import 'dart:async';

import 'package:async/async.dart';
import 'package:http/http.dart';

class CancelToken {
  CancelableOperation<StreamedResponse>? _operation;

  bool get isCanceled => _operation?.isCanceled ?? false;

  Future<StreamedResponse> get result => _operation!.value;

  void bind(Future<StreamedResponse> task, [FutureOr Function()? onCancel]) {
    assert(_operation == null);
    _operation = CancelableOperation.fromFuture(
      task,
      onCancel: onCancel,
    );
  }

  Future<void> cancel() {
    if (_operation != null) {
      return _operation!.cancel();
    }
    return Future.value();
  }
}
