import 'output.dart';
import 'formatter.dart';
import 'info.dart';

/// Aggregate multiple log outputs
class MultipleLogOutput extends LogOutput {
  final List<LogOutput> _outputs;

  MultipleLogOutput(this._outputs);

  @override
  void output(LogInfo info) {
    for (var element in _outputs) {
      element.output(info);
    }
  }

  @override
  LogFormatter get formatter => throw UnimplementedError();
}
