import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'store.dart';

typedef _StoreNodeType = Map<String, _StorageData>;

class PersistentStore extends CacheStore {
  final Completer<Map<String, _StoreNodeType>> _store = Completer();
  final String filePath;

  PersistentStore(this.filePath) {
    final file = File(filePath);
    file.exists().then((isExists) async {
      Map<String, _StoreNodeType> content;
      if (!isExists) {
        await file.create(recursive: true);
        content = <String, _StoreNodeType>{};
      } else {
        final jsonString = await file.readAsString();
        final jsonObject = Map<String, dynamic>.from(jsonDecode(jsonString));
        content = jsonObject.map((key, value) => MapEntry(
            key,
            Map<String, dynamic>.from(value).map(
                (key, value) => MapEntry(key, _StorageData.fromJson(value)))));
      }
      return _store.complete(content);
    }).catchError((err, s) => _store.completeError(err, s));
  }

  @override
  void clear(String name) {
    _store.future.then((data) {
      if (data.containsKey(name)) {
        data.remove(name);
        _flush(data);
      }
    });
  }

  @override
  FutureOr<Object?> get(String name, String key) async {
    final data = await _store.future;
    final map = data[name];
    if (map == null) {
      return null;
    }
    final node = map[key];
    if (node?.expires != null) {
      final nowDate = DateTime.now();
      final expireDate = DateTime.fromMillisecondsSinceEpoch(node!.expires!);
      if (expireDate.compareTo(nowDate) != 1) {
        map.remove(key);
        _flush(data);
        return null;
      }
    }
    return node?.data;
  }

  @override
  void put(String name, String key, Object value, {int? expires}) {
    _store.future.then((data) {
      final node = _StorageData(value, expires);
      if (data.containsKey(name)) {
        data[name]?[key] = node;
      } else {
        data[name] = {key: node};
      }
      _flush(data);
    });
  }

  @override
  void remove(String name, String key) {
    _store.future.then((data) {
      if (data.containsKey(name)) {
        final map = data[name]!;
        if (map.containsKey(key)) {
          map.remove(key);
          _flush(data);
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
