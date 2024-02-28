const offLevel = 'OFF';
const debugLevel = 'FINE';
const infoLevel = 'INFO';
const warnLevel = 'WARNING';
const errorLevel = 'SEVERE';

/// Enables logging for the current identity class
class EnableLogging {
  /// Logger name
  final String? name;

  /// Output log level
  final String level;

  /// If set to true, it is equivalent to `Logger.detached`
  final bool isDetached;

  const EnableLogging(
      {this.name, this.level = infoLevel, this.isDetached = false});
}

/// Log output point
class LogPoint {
  /// Output log messages
  final String message;

  /// Output log level
  final String level;

  const LogPoint(this.message, this.level);
}

/// `DEBUG` log
class DebugLog extends LogPoint {
  const DebugLog(String message) : super(message, 'fine');
}

/// `INFO` log
class InfoLog extends LogPoint {
  const InfoLog(String message) : super(message, 'info');
}

/// `WARNING` log
class WarnLog extends LogPoint {
  const WarnLog(String message) : super(message, 'warning');
}

/// `ERROR` log
class ErrorLog extends LogPoint {
  const ErrorLog(String message) : super(message, 'severe');
}
