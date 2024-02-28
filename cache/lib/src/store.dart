import 'dart:async';

abstract class CacheStore {
  void put(String name, String key, Object value, {int? expires});

  void remove(String name, String key);

  Object? get(String name, String key);

  void clear(String name);
}

abstract class AsyncCacheStore extends CacheStore {
  Future<void> asyncPut(String name, String key, Object value, {int? expires});

  Future<Object?> asyncGet(String name, String key);
}
