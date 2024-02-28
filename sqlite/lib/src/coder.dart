import 'dart:convert';
import 'dart:typed_data';

abstract class FieldCoder<T, R> {
  R encode(T? value);

  T decode(Object value);
}

class FieldCoderRegistry {
  static final _defaultTypeCoder = <String, FieldCoder>{
    'bool': _BoolCoder(),
    'DateTime': _DataTimeCoder(),
    'List': _ListCoder(),
    'Set': _SetCoder(),
    'Map': _MapCoder(),
    'Duration': _DurationCoder(),
    'BigInt': _BigIntCoder(),
    'Uint8List': _Uint8ListCoder(),
  };

  static FieldCoder? get(String type) {
    return _defaultTypeCoder[type];
  }

  static void register(String type, FieldCoder coder) {
    _defaultTypeCoder[type] = coder;
  }

  static void remove(String type) {
    _defaultTypeCoder.remove(type);
  }
}

class _BoolCoder extends FieldCoder<bool, int> {
  @override
  int encode(bool? value) {
    return (value ?? false) ? 1 : 0;
  }

  @override
  bool decode(Object value) {
    return value == 1 ? true : false;
  }
}

class _DataTimeCoder extends FieldCoder<DateTime, String> {
  @override
  String encode(DateTime? value) {
    return value?.toIso8601String() ?? '';
  }

  @override
  DateTime decode(Object value) {
    if (value is! String) {
      return DateTime(1970);
    }
    return DateTime.parse(value);
  }
}

class _ListCoder extends FieldCoder<List, String> {
  @override
  List decode(Object value) {
    final obj = jsonDecode(value as String);
    return obj is List ? obj : [];
  }

  @override
  String encode(List<dynamic>? value) {
    return jsonEncode(value ?? []);
  }
}

class _SetCoder extends FieldCoder<Set, String> {
  @override
  Set decode(Object value) {
    final obj = jsonDecode(value as String);
    return obj is List ? obj.toSet() : {};
  }

  @override
  String encode(Set<dynamic>? value) {
    return jsonEncode((value?.toList() ?? []));
  }
}

class _MapCoder extends FieldCoder<Map, String> {
  @override
  Map decode(Object value) {
    if (value is Map) {
      return value;
    }
    final obj = jsonDecode(value as String);
    return obj is Map ? obj : {};
  }

  @override
  String encode(Map<dynamic, dynamic>? value) {
    return jsonEncode(value ?? {});
  }
}

class _DurationCoder extends FieldCoder<Duration, int> {
  @override
  Duration decode(Object value) {
    return Duration(seconds: value as int);
  }

  @override
  int encode(Duration? value) {
    return value?.inSeconds ?? 0;
  }
}

class _BigIntCoder extends FieldCoder<BigInt, String> {
  @override
  BigInt decode(Object value) {
    return BigInt.tryParse(value as String) ?? BigInt.zero;
  }

  @override
  String encode(BigInt? value) {
    return value?.toString() ?? '0';
  }
}

class _Uint8ListCoder extends FieldCoder<Uint8List, Object> {
  @override
  Uint8List decode(Object value) {
    if (value is List) {
      return Uint8List.fromList(List<int>.from(value));
    }
    return Uint8List(0);
  }

  @override
  Object encode(Uint8List? value) {
    return value ?? Uint8List(0);
  }
}
