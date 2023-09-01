import 'formatter.dart';
import 'info.dart';

/// Log printing interface
abstract class LogOutput {
  /// Log format implementer
  LogFormatter get formatter;

  /// Print the log
  void output(LogInfo info);
}
