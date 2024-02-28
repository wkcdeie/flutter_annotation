import 'dart:developer' as dev;
import 'output.dart';
import 'formatter.dart';
import 'info.dart';

/// Console log printing implementation
class ConsoleLogOutput extends LogOutput {
  @override
  final LogFormatter formatter;

  ConsoleLogOutput({LogFormatter? formatter})
      : formatter = formatter ?? SimpleLogFormatter();

  @override
  void output(LogInfo info) {
    dev.log(
      formatter.format(info),
      time: info.time,
      // sequenceNumber: record.sequenceNumber,
      level: info.level.value,
      name: info.logger,
      error: info.error,
      // stackTrace: info.stackTrace,
    );
  }
}
