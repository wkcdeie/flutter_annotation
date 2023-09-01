import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:path/path.dart' as path;

/// Log information
class LogInfo {
  /// The class in which the log output resides
  final String className;

  /// The method of the class in which the log output resides
  final String methodName;

  /// The file name of the class in which the log output resides
  final String fileName;

  /// The method line number of the class in which the log output resides
  final int lineNumber;

  /// Log output level
  final Level level;

  /// Log output messages
  final String message;

  /// Logger where this record is stored.
  final String logger;

  /// Time when this record was created.
  final DateTime time;

  /// Associated error (if any) when recording errors messages.
  final Object? error;

  /// Associated stackTrace (if any) when recording errors messages.
  final StackTrace? stackTrace;

  LogInfo(
      {required this.className,
      required this.methodName,
      required this.fileName,
      this.lineNumber = 0,
      required this.level,
      required this.message,
      required this.logger,
      required this.time,
      this.error,
      this.stackTrace});

  /// Based on the call stack information, obtain the log output class information
  factory LogInfo.from(StackTrace stackTrace,
      {required Level level,
      required String logger,
      required DateTime time,
      required String message,
      Object? error}) {
    String? className, methodName, fileName;
    int? lineNumber;
    final trace = Trace.from(stackTrace);
    if (trace.frames.isNotEmpty) {
      final frame = trace.frames.first;
      final members = frame.member?.split('.') ?? ['-', '-'];
      className = members.first;
      methodName = members.last;
      fileName = path.basename(frame.uri.path);
      lineNumber = frame.line;
    }
    return LogInfo(
        className: className ?? '-',
        methodName: methodName ?? '-',
        fileName: fileName ?? '-',
        lineNumber: lineNumber ?? 0,
        level: level,
        message: message,
        logger: logger,
        time: time,
        error: error,
        stackTrace: stackTrace);
  }
}
