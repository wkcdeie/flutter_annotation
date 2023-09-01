import 'package:logging/logging.dart';
import 'output.dart';
import 'info.dart';

void setupLog(Level level, LogOutput output) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((event) {
    final info = LogInfo.from(
      event.stackTrace ?? StackTrace.current,
      level: event.level,
      logger: event.loggerName,
      time: event.time,
      message: event.message,
      error: event.error,
    );
    output.output(info);
  });
}
