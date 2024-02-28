import 'package:flutter_annotation_cache/flutter_annotation_cache.dart';

abstract class ConfigureStore {
  void put(String key, Object value);

  Object? get(String key);

  void remove(String key);

  void clear();
}

class DefaultConfigureStore implements ConfigureStore {
  static const tag = '_CFG_';
  final CacheStore store;
  late MemoryStore? _memory;

  DefaultConfigureStore(this.store, [bool useMemory = true]) {
    if (useMemory) {
      _memory = MemoryStore();
    }
  }

  /// Populate data to memory storage
  void setData(List<MapEntry<String, Object>> entries) {
    if (_memory == null) {
      return;
    }
    for (var entry in entries) {
      _memory!.put(tag, entry.key, entry.value);
    }
  }

  @override
  void clear() {
    _memory?.clear(tag);
    store.clear(tag);
  }

  @override
  Object? get(String key) {
    return _memory?.get(tag, key) ?? store.get(tag, key);
  }

  @override
  void put(String key, Object value) {
    _memory?.put(tag, key, value);
    store.put(tag, key, value);
  }

  @override
  void remove(String key) {
    _memory?.remove(tag, key);
    store.remove(tag, key);
  }
}
