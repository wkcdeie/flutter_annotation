import 'dart:developer';

import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common/sqflite_logger.dart';

DatabaseFactory sqlLoggerFactory(DatabaseFactory impl) {
  final options = SqfliteLoggerOptions(
    log: _printSqlLog,
    type: SqfliteDatabaseFactoryLoggerType.invoke,
  );
  return SqfliteDatabaseFactoryLogger(
    impl,
    options: options,
  );
}

void _printSqlLog(SqfliteLoggerEvent event) {
  final obj = event as SqfliteLoggerInvokeEvent;
  final args = obj.arguments as Map?;
  if (args != null && args['sql'] != null) {
    StringBuffer sb = StringBuffer();
    sb.write('[${args['sql']}]');
    if (args['arguments'] != null) {
      sb.write(' arguments:${args['arguments']}');
    }
    if (obj.sw != null) {
      sb.write(' time:${obj.sw!.elapsedMicroseconds / 1000.0}ms');
    }
    log(sb.toString(), name: 'SQL');
  }
}
