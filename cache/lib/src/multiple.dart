import 'dart:async';
import 'store.dart';

class MultipleCache extends CacheStore {
  final List<CacheStore> _stores;

  MultipleCache(this._stores);

  @override
  void clear(String name) {
    for (var store in _stores) {
      store.clear(name);
    }
  }

  @override
  FutureOr<Object?> get(String name, String key) async {
    Object? result;
    for (var store in _stores) {
      result = await store.get(name, key);
      if (result != null) {
        break;
      }
    }
    return result;
  }

  @override
  void put(String name, String key, Object value, {int? expires}) {
    for (var store in _stores) {
      store.put(name, key, value, expires: expires);
    }
  }

  @override
  void remove(String name, String key) {
    for (var store in _stores) {
      store.remove(name, key);
    }
  }
}
