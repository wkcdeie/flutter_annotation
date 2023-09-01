import 'dart:io';

import 'package:path/path.dart' as path;
import 'info.dart';
import 'output.dart';
import 'formatter.dart';

/// Output the log to a file
class FileLogOutput extends LogOutput {
  static final _fileRegex = RegExp(r'\d+\.log');
  late final File _logfile;
  IOSink? _ioSink;
  @override
  final LogFormatter formatter;

  /// The directory where log files are stored
  final Directory logDir;

  /// Limit the size of a single log file, 1M by default
  final int maximumFileSize;

  FileLogOutput(String logPath,
      {this.maximumFileSize = 1024 * 1024, LogFormatter? formatter})
      : logDir = Directory(logPath),
        formatter = formatter ?? SimpleLogFormatter() {
    if (!FileSystemEntity.isDirectorySync(logPath)) {
      throw ArgumentError('`$logPath` is not a directory.');
    }
    if (!logDir.existsSync()) {
      logDir.createSync(recursive: true);
      _logfile = _getLogFile();
    } else {
      final files = logDir
          .listSync(followLinks: false)
          .where((element) =>
              _fileRegex.hasMatch(element.path) &&
              FileSystemEntity.isFileSync(element.path))
          .toList();
      if (files.isNotEmpty) {
        files.sort((a, b) => a.path.compareTo(b.path));
        _logfile = _checkLogFile(File(files.last.path));
      } else {
        _logfile = _getLogFile();
      }
    }
  }

  /// Close the file stream
  Future<void> close() async {
    if (_ioSink != null) {
      await _ioSink?.flush();
      await _ioSink?.close();
      _ioSink = null;
    }
  }

  @override
  void output(LogInfo info) {
    _ioSink ??= _logfile.openWrite(mode: FileMode.append);
    _ioSink?.writeln(formatter.format(info));
  }

  File _getLogFile([int index = 1]) {
    final fileName = '${_getYYYYMMdd()}${index.toString().padLeft(2, '0')}.log';
    final logfile = File(path.join(logDir.path, fileName));
    if (!logfile.existsSync()) {
      logfile.createSync();
    }
    return logfile;
  }

  File _checkLogFile(File file) {
    final fileName = path.basenameWithoutExtension(file.path);
    if (fileName.length > 7 && fileName.substring(0, 8) != _getYYYYMMdd()) {
      return _getLogFile();
    }
    final fileSize = file.lengthSync();
    if (fileSize >= maximumFileSize) {
      // create new logfile
      final sn = int.tryParse(fileName.substring(8)) ?? 1;
      return _getLogFile(sn);
    }
    return file;
  }

  String _getYYYYMMdd() {
    final nowData = DateTime.now();
    return '${nowData.year}${nowData.month.toString().padLeft(2, '0')}${nowData.day.toString().padLeft(2, '0')}';
  }
}
