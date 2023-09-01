import 'package:flutter_annotation_log/flutter_annotation_log.dart';
import 'package:flutter_annotation_router/flutter_annotation_router.dart';
import 'package:logging/logging.dart';

part 'log.log.dart';

@RouteGuard('/*', 'RouteLoggingListener.withLog')
@EnableLogging(name: 'Route')
class RouteLoggingListener implements RouteListener {
  RouteLoggingListener();

  factory RouteLoggingListener.withLog() => _$RouteLoggingListenerWithLog();

  @override
  @InfoLog('Enter to:#to  from:#from')
  Future<bool> onEnter(String to, String? from, Map<String, dynamic> args) {
    return Future.value(true);
  }

  @override
  @InfoLog('Leave from:#from  to:#to')
  Future<bool> onLeave(String to, String from) {
    return Future.value(true);
  }
}
