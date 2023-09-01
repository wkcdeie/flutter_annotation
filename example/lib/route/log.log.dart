// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// EnableLoggingGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps
// ignore_for_file: unnecessary_string_interpolations

part of 'log.dart';

class _$RouteLoggingListenerWithLog extends RouteLoggingListener {
  final Logger _logger = Logger('Route');

  @override
  Future<bool> onEnter(
    String to,
    String? from,
    Map<String, dynamic> args,
  ) {
    _logger.info('Enter to:${to}  from:${from}', null, StackTrace.current);
    return super.onEnter(
      to,
      from,
      args,
    );
  }

  @override
  Future<bool> onLeave(
    String to,
    String from,
  ) {
    _logger.info('Leave from:${from}  to:${to}', null, StackTrace.current);
    return super.onLeave(
      to,
      from,
    );
  }
}
