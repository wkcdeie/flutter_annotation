import 'dart:collection';
import 'store.dart';

typedef CacheValue = Map<String, dynamic>;

class MemoryStore implements CacheStore {
  MemoryStore({Map<String, CacheValue>? map})
      : _map = map ?? HashMap<String, CacheValue>();

  factory MemoryStore.lru({int? maximumSize}) {
    return MemoryStore(map: _LruMap(maximumSize: maximumSize));
  }

  final Map<String, CacheValue> _map;

  @override
  void clear(String name) {
    _map.remove(name);
  }

  @override
  Object? get(String name, String key) {
    CacheValue? valueMap = _map[name];
    if (valueMap == null) {
      return null;
    }
    return valueMap[key];
  }

  @override
  void put(String name, String key, Object value, {int? expires}) {
    CacheValue? valueMap = _map[name];
    if (valueMap == null) {
      valueMap = <String, dynamic>{};
      _map[name] = valueMap;
    }
    valueMap[key] = value;
  }

  @override
  void remove(String name, String key) {
    final valueMap = _map[name];
    valueMap?.remove(key);
  }
}

abstract class _LruMap<K, V> implements Map<K, V> {
  factory _LruMap({int? maximumSize}) = _LinkedLruHashMap<K, V>;

  int get maximumSize;

  set maximumSize(int size);
}

class _LinkedEntry<K, V> {
  _LinkedEntry(this.key, this.value);

  K key;
  V value;

  _LinkedEntry<K, V>? next;
  _LinkedEntry<K, V>? previous;
}

class _LinkedLruHashMap<K, V> implements _LruMap<K, V> {
  factory _LinkedLruHashMap({int? maximumSize}) =>
      _LinkedLruHashMap._fromMap(HashMap<K, _LinkedEntry<K, V>>(),
          maximumSize: maximumSize);

  _LinkedLruHashMap._fromMap(this._entries, {int? maximumSize})
      // This pattern is used instead of a default value because we want to
      // be able to respect null values coming in from MapCache.lru.
      : _maximumSize = maximumSize ?? _defaultMaximumSize;

  static const _defaultMaximumSize = 100;

  final Map<K, _LinkedEntry<K, V>> _entries;

  int _maximumSize;

  _LinkedEntry<K, V>? _head;
  _LinkedEntry<K, V>? _tail;

  @override
  void addAll(Map<K, V> other) => other.forEach((k, v) => this[k] = v);

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    for (final entry in entries) {
      this[entry.key] = entry.value;
    }
  }

  @override
  _LinkedLruHashMap<K2, V2> cast<K2, V2>() {
    throw UnimplementedError('cast');
  }

  @override
  void clear() {
    _entries.clear();
    _head = _tail = null;
  }

  @override
  bool containsKey(Object? key) => _entries.containsKey(key);

  @override
  bool containsValue(Object? value) => values.contains(value);

  @override
  Iterable<MapEntry<K, V>> get entries =>
      _entries.values.map((entry) => MapEntry<K, V>(entry.key, entry.value));

  @override
  void forEach(void Function(K key, V value) action) {
    var head = _head;
    while (head != null) {
      action(head.key, head.value);
      head = head.next;
    }
  }

  @override
  int get length => _entries.length;

  @override
  bool get isEmpty => _entries.isEmpty;

  @override
  bool get isNotEmpty => _entries.isNotEmpty;

  Iterable<_LinkedEntry<K, V>> _iterable() {
    if (_head == null) {
      return const Iterable.empty();
    }
    return _GeneratingIterable<_LinkedEntry<K, V>>(() => _head!, (n) => n.next);
  }

  @override
  Iterable<K> get keys => _iterable().map((e) => e.key);

  @override
  Iterable<V> get values => _iterable().map((e) => e.value);

  @override
  Map<K2, V2> map<K2, V2>(Object Function(K key, V value) transform) {
    // Change Object to MapEntry<K2, V2> when
    // the MapEntry class has been added.
    throw UnimplementedError('map');
  }

  @override
  int get maximumSize => _maximumSize;

  @override
  set maximumSize(int maximumSize) {
    ArgumentError.checkNotNull(maximumSize, 'maximumSize');
    while (length > maximumSize) {
      _removeLru();
    }
    _maximumSize = maximumSize;
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    final entry =
        _entries.putIfAbsent(key, () => _createEntry(key, ifAbsent()));
    if (length > maximumSize) {
      _removeLru();
    }
    _promoteEntry(entry);
    return entry.value;
  }

  @override
  V? operator [](Object? key) {
    final entry = _entries[key];
    if (entry != null) {
      _promoteEntry(entry);
      return entry.value;
    } else {
      return null;
    }
  }

  @override
  void operator []=(K key, V value) {
    // Add this item to the MRU position.
    _insertMru(_createEntry(key, value));

    // Remove the LRU item if the size would be exceeded by adding this item.
    if (length > maximumSize) {
      assert(length == maximumSize + 1);
      _removeLru();
    }
  }

  @override
  V? remove(Object? key) {
    final entry = _entries.remove(key);
    if (entry == null) {
      return null;
    }
    if (entry == _head && entry == _tail) {
      _head = _tail = null;
    } else if (entry == _head) {
      _head = _head!.next;
      _head?.previous = null;
    } else if (entry == _tail) {
      _tail = _tail!.previous;
      _tail?.next = null;
    } else {
      entry.previous!.next = entry.next;
      entry.next!.previous = entry.previous;
    }
    return entry.value;
  }

  @override
  void removeWhere(bool Function(K key, V value) test) {
    var keysToRemove = <K>[];
    _entries.forEach((key, entry) {
      if (test(key, entry.value)) keysToRemove.add(key);
    });
    keysToRemove.forEach(remove);
  }

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    V newValue;
    if (containsKey(key)) {
      newValue = update(this[key] as V);
    } else {
      if (ifAbsent == null) {
        throw ArgumentError.value(key, 'key', 'Key not in map');
      }
      newValue = ifAbsent();
    }

    // Add this item to the MRU position.
    _insertMru(_createEntry(key, newValue));

    // Remove the LRU item if the size would be exceeded by adding this item.
    if (length > maximumSize) {
      assert(length == maximumSize + 1);
      _removeLru();
    }
    return newValue;
  }

  @override
  void updateAll(V Function(K key, V value) update) {
    _entries.forEach((key, entry) {
      var newValue = _createEntry(key, update(key, entry.value));
      _entries[key] = newValue;
    });
  }

  void _promoteEntry(_LinkedEntry<K, V> entry) {
    // If this entry is already in the MRU position we are done.
    if (entry == _head) {
      return;
    }

    if (entry.previous != null) {
      // If already existed in the map, link previous to next.
      entry.previous!.next = entry.next;

      // If this was the tail element, assign a new tail.
      if (_tail == entry) {
        _tail = entry.previous;
      }
    }
    // If this entry is not the end of the list then link the next entry to the previous entry.
    if (entry.next != null) {
      entry.next!.previous = entry.previous;
    }

    // Replace head with this element.
    if (_head != null) {
      _head!.previous = entry;
    }
    entry.previous = null;
    entry.next = _head;
    _head = entry;

    // Add a tail if this is the first element.
    if (_tail == null) {
      assert(length == 1);
      _tail = _head;
    }
  }

  _LinkedEntry<K, V> _createEntry(K key, V value) {
    return _LinkedEntry<K, V>(key, value);
  }

  void _insertMru(_LinkedEntry<K, V> entry) {
    // Insert a new entry if necessary (only 1 hash lookup in entire function).
    // Otherwise, just updates the existing value.
    final value = entry.value;
    _promoteEntry(_entries.putIfAbsent(entry.key, () => entry)..value = value);
  }

  void _removeLru() {
    // Remove the tail from the internal map.
    _entries.remove(_tail!.key);

    // Remove the tail element itself.
    _tail = _tail!.previous;
    _tail?.next = null;

    // If we removed the last element, clear the head too.
    if (_tail == null) {
      _head = null;
    }
  }
}

class _GeneratingIterable<T> extends IterableBase<T> {
  _GeneratingIterable(this._initial, this._next);

  final T Function() _initial;
  final T? Function(T value) _next;

  @override
  Iterator<T> get iterator => _GeneratingIterator(_initial(), _next);
}

class _GeneratingIterator<T> implements Iterator<T> {
  _GeneratingIterator(this.object, this.next);

  final T? Function(T value) next;
  T? object;
  bool started = false;

  @override
  T get current {
    final cur = started ? object : null;
    return cur!;
  }

  @override
  bool moveNext() {
    final obj = object;
    if (obj == null) return false;
    if (started) {
      object = next(obj);
    } else {
      started = true;
    }
    return object != null;
  }
}
