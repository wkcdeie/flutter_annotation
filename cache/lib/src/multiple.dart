import 'dart:async';
import 'store.dart';

class MultipleCache extends AsyncCacheStore {
  final List<CacheStore> _stores;

  MultipleCache(this._stores);

  @override
  void clear(String name) {
    for (var store in _stores) {
      store.clear(name);
    }
  }

  @override
  Object? get(String name, String key) async {
    Object? result;
    for (var store in _stores) {
      result = store.get(name, key);
      if (result != null) {
        break;
      }
    }
    return result;
  }

  @override
  void put(String name, String key, Object value, {int? expires}) async {
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

  @override
  Future<Object?> asyncGet(String name, String key) async {
    final asyncStores = _stores.whereType<AsyncCacheStore>();
    Object? result;
    for (var store in asyncStores) {
      result = await store.asyncGet(name, key);
      if (result != null) {
        break;
      }
    }
    return result;
  }

  @override
  Future<void> asyncPut(String name, String key, Object value,
      {int? expires}) async {
    final asyncStores = _stores.whereType<AsyncCacheStore>();
    for (var store in asyncStores) {
      await store.asyncPut(name, key, value, expires: expires);
    }
  }
}
