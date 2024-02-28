import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:synchronized/synchronized.dart';

import 'store.dart';

typedef _StoreNodeType = Map<String, _StorageData>;

class PersistentStore extends CacheStore {
  final Lock _lock = Lock();
  final Map<String, _StoreNodeType> _store = {};
  final String filePath;

  PersistentStore(this.filePath) {
    final file = File(filePath);
    _lock.synchronized(() async {
      final isExists = await file.exists();
      if (!isExists) {
        await file.create(recursive: true);
        // content = <String, _StoreNodeType>{};
      } else {
        final jsonString = await file.readAsString();
        final jsonObject = Map<String, dynamic>.from(jsonDecode(jsonString));
        final data = jsonObject.map((key, value) => MapEntry(
            key,
            Map<String, dynamic>.from(value).map(
                (key, value) => MapEntry(key, _StorageData.fromJson(value)))));
        _store.addAll(data);
      }
    });
  }

  @override
  void clear(String name) {
    _lock.synchronized(() async {
      if (_store.containsKey(name)) {
        _store.remove(name);
        await _flush(_store);
      }
    });
  }

  @override
  FutureOr<Object?> get(String name, String key) async {
    return _lock.synchronized<Object?>(() {
      final map = _store[name];
      if (map == null) {
        return null;
      }
      final node = map[key];
      if (node?.expires != null) {
        final nowDate = DateTime.now();
        final expireDate = DateTime.fromMillisecondsSinceEpoch(node!.expires!);
        if (expireDate.compareTo(nowDate) != 1) {
          map.remove(key);
          if (map.isEmpty) {
            _store.remove(name);
          }
          _flush(_store);
          return null;
        }
      }
      return node?.data;
    });
  }

  @override
  void put(String name, String key, Object value, {int? expires}) {
    _lock.synchronized(() {
      final node = _StorageData(value, expires);
      if (_store.containsKey(name)) {
        _store[name]![key] = node;
      } else {
        _store[name] = {key: node};
      }
      _flush(_store);
    });
  }

  @override
  void remove(String name, String key) {
    _lock.synchronized(() {
      if (_store.containsKey(name)) {
        final map = _store[name]!;
        if (map.containsKey(key)) {
          map.remove(key);
          if (map.isEmpty) {
            _store.remove(name);
          }
          _flush(_store);
        }
      }
    });
  }

  Future<void> _flush(Map<String, _StoreNodeType> data) async {
    final file = File(filePath);
    final contents = jsonEncode(data);
    await file.writeAsString(contents, flush: true);
  }
}

class _StorageData {
  final dynamic data;
  final int? expires;

  _StorageData(this.data, this.expires);

  factory _StorageData.fromJson(Map<String, dynamic> json) =>
      _StorageData(json['data'], json['expires']);

  Map<String, dynamic> toJson() => {'data': data, 'expires': expires};
}
