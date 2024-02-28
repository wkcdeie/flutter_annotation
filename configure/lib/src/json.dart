import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_annotation_common/flutter_annotation_common.dart'
    show SM4Crypto;
import 'package:synchronized/synchronized.dart';

import 'persistence.dart';

class JsonPersistence extends ConfigurePersistence {
  final String filePath;

  /// Compressed('gzip'), default true
  final bool compress;

  /// Encryption key, length 32
  final String? encryptKey;

  final Map<String, dynamic> _cache = {};
  final Lock _lock = Lock();

  JsonPersistence(this.filePath, {this.compress = true, this.encryptKey});

  @override
  void clear() {
    _lock.synchronized(() async {
      final store = File(filePath);
      final ret = await store.exists();
      if (ret) {
        await store.delete();
      }
      _cache.clear();
    });
  }

  @override
  dynamic get(String key) {
    return _cache[key];
  }

  @override
  void put(String key, dynamic value) {
    _cache[key] = value;
    flush();
  }

  @override
  dynamic remove(String key) {
    final result = _cache.remove(key);
    flush();
    return result;
  }

  Future<void> load() async {
    final args = [filePath, compress, encryptKey];
    final result = await Isolate.run(() => _read(args));
    _cache.addAll(result);
  }

  Future<void> flush() {
    return _lock.synchronized(() {
      final args = [_cache, filePath, compress, encryptKey];
      return Isolate.run(() => _write(args));
    }).catchError((e, st) => log(e.toString(), stackTrace: st));
  }
}

Map<String, dynamic> _read(List args) {
  final file = File(args[0] as String);
  if (!file.existsSync()) {
    return {};
  }
  List<int> jsonData = file.readAsBytesSync();
  final encryptKey = args[2] as String?;
  if (encryptKey != null) {
    final crypto = SM4Crypto();
    crypto.setKey(encryptKey);
    jsonData = crypto.decrypt(jsonData);
  }
  final isCompress = args[1] as bool;
  if (isCompress) {
    jsonData = gzip.decode(jsonData);
  }
  final jsonString = utf8.decode(jsonData);
  if (jsonString.isEmpty) {
    return {};
  }
  final data = jsonDecode(jsonString);
  if (data is! Map) {
    return {};
  }
  return Map<String, dynamic>.from(data);
}

void _write(List args) {
  final data = args[0] as Map;
  final filePath = args[1] as String;
  final isCompress = args[2] as bool;
  final encryptKey = args[3] as String?;
  final jsonString = jsonEncode(data);
  List<int> jsonData = utf8.encode(jsonString);
  if (isCompress) {
    jsonData = gzip.encode(jsonData);
  }
  if (encryptKey != null) {
    final crypto = SM4Crypto();
    crypto.setKey(encryptKey);
    jsonData = crypto.encrypt(jsonData);
  }
  final file = File(filePath);
  file.writeAsBytesSync(jsonData);
}
