// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// EnableLoggingGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps
// ignore_for_file: unnecessary_string_interpolations

part of 'main.dart';

class _$_FixNavigatorWithPopWithLog extends _FixNavigatorWithPop {
  _$_FixNavigatorWithPopWithLog(this._output) {
    _logger.level = Level.LEVELS
        .firstWhere((e) => e.name == 'INFO', orElse: () => Level.INFO);
    _logger.onRecord.listen((record) => _output.output(LogInfo.from(
        record.stackTrace ?? StackTrace.current,
        level: record.level,
        logger: record.loggerName,
        time: record.time,
        message: record.message,
        error: record.error)));
  }

  final Logger _logger = Logger.detached('Navigator');

  final LogOutput _output;

  @override
  void didPop(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    _logger.info('didPop:${route.settings.name}', null, StackTrace.current);
    return super.didPop(
      route,
      previousRoute,
    );
  }
}
