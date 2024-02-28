import 'dart:async';

abstract class CacheStore {
  void put(String name, String key, Object value, {int? expires});

  void remove(String name, String key);

  FutureOr<Object?> get(String name, String key);

  void clear(String name);
}
