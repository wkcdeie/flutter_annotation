import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show md5;

import 'cache_data_repository.dart';
import 'cache_data.dart';
import 'store.dart';

class PersistentStore extends AsyncCacheStore {
  static const _fsDir = 'fs';
  final String cacheDir;
  final CacheDataRepository repository;

  PersistentStore(this.cacheDir, this.repository);

  Future<List<MapEntry<String, Object>>> getObjects(String name) async {
    final key = _getCacheKey(name);
    final keyLength = key.length;
    List<MapEntry<String, Object>> entries = [];
    final values = await repository.findByName(key);
    for (var cacheData in values) {
      final cacheKey = cacheData.key.substring(keyLength);
      final object = await _readObject(name, cacheKey, cacheData);
      if (object != null) {
        entries.add(MapEntry(cacheKey, object));
      }
    }
    return entries;
  }

  @override
  void clear(String name) {
    final key = _getCacheKey(name);
    repository.findPathsByName(key).then((paths) {
      if (paths.isNotEmpty) {
        return repository.deleteByName(key).then((value) =>
            value ? paths.map((e) => File('$cacheDir/$e')).toList() : <File>[]);
      }
      return Future.value(<File>[]);
    }).then((result) async {
      for (var file in result) {
        if (await file.exists()) {
          file.delete();
        }
      }
    });
  }

  @override
  Object? get(String name, String key) {
    return null;
  }

  @override
  void put(String name, String key, Object value, {int? expires}) {
    asyncPut(name, key, value, expires: expires);
  }

  @override
  void remove(String name, String key) {
    repository.deleteByKey(_getCacheKey(name, key)).then((value) async {
      if (value) {
        final cacheFile = File(_getCacheFilePath(name, key));
        if (await cacheFile.exists()) {
          await cacheFile.delete();
        }
      }
    });
  }

  @override
  Future<Object?> asyncGet(String name, String key) async {
    final cacheData = await repository.findByKey(_getCacheKey(name, key));
    if (cacheData == null) {
      return null;
    }
    return _readObject(name, key, cacheData);
  }

  @override
  Future<void> asyncPut(String name, String key, Object value,
      {int? expires}) async {
    final jsonString = jsonEncode(value);
    final jsonData = utf8.encode(jsonString);
    final cacheKey = _getCacheKey(name, key);
    String? cacheFilePath;
    Uint8List? cacheData;
    if (jsonData.length > 16 * 1024) {
      final rootDir = Directory('$cacheDir/$_fsDir');
      if (!await rootDir.exists()) {
        await rootDir.create(recursive: true);
      }
      final cacheFile = File(_getCacheFilePath(name, key));
      await cacheFile.writeAsBytes(jsonData, mode: FileMode.writeOnly);
      cacheFilePath = cacheFile.path.substring(cacheDir.length + 1);
    } else {
      cacheData = Uint8List.fromList(jsonData);
    }
    await repository.insert(CacheData(
      cacheKey,
      jsonData.length,
      expireDate: expires,
      filePath: cacheFilePath,
      data: cacheData,
    ));
  }

  String _getCacheKey(String name, [String? key]) => '$name#${key ?? ''}';

  String _getCacheFilePath(String name, String key) {
    final fileName = md5.convert(utf8.encode(_getCacheKey(name, key)));
    return '$cacheDir/$_fsDir/$fileName.dat';
  }

  Future<Object?> _readObject(
      String name, String key, CacheData cacheData) async {
    if (cacheData.expireDate != null) {
      final nowDate = DateTime.now();
      final expireDate =
          DateTime.fromMillisecondsSinceEpoch(cacheData.expireDate!);
      if (expireDate.compareTo(nowDate) != 1) {
        remove(name, key);
        return null;
      }
    } else if (cacheData.data != null && cacheData.data!.isNotEmpty) {
      return _decodeData(cacheData.data!);
    }
    final cacheFile = File(_getCacheFilePath(name, key));
    if (await cacheFile.exists()) {
      final fileData = await cacheFile.readAsBytes();
      if (fileData.isNotEmpty) {
        return _decodeData(fileData);
      }
    }
    return null;
  }

  Object _decodeData(Uint8List data) {
    final jsonString = utf8.decode(data);
    return jsonDecode(jsonString);
  }
}
