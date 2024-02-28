import 'package:flutter_annotation_log/flutter_annotation_log.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  final console = ConsoleLogOutput();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    console.output(LogInfo.from(record.stackTrace ?? StackTrace.current,
        level: record.level,
        logger: record.loggerName,
        time: record.time,
        message: record.message));
  });
  test('log', () {
    final logger = Logger('test');
    logger.fine('debug log');
    logger.info('info log');
    logger.warning('warning log');
    logger.severe('error log');
  });
}
