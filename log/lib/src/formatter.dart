import 'info.dart';

/// Log formatting interface
abstract class LogFormatter {
  /// Format the log as a string
  String format(LogInfo info);
}

/// Default log formatting implementation, format: '[level] time class.method(file:line) message'
class SimpleLogFormatter extends LogFormatter {
  @override
  String format(LogInfo info) {
    StringBuffer log = StringBuffer();
    log.write('[${info.level.name}] ');
    log.write(info.time.toIso8601String());
    if (info.className != '-') {
      log.write(' ');
      log.write(info.className);
      if (info.methodName != '-') {
        log.write('.${info.methodName}');
      }
      if (info.fileName != '-') {
        log.write('(${info.fileName}');
        if (info.lineNumber > 0) {
          log.write(':${info.lineNumber}');
        }
        log.write(')');
      }
    }
    log.write(' ');
    log.write(info.message);
    return log.toString();
  }
}
