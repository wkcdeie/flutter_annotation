class DecodeHelper {
  static final List<String> boolTrueValues = [
    'TRUE',
    'true',
    'YES',
    'yes',
    '1'
  ];

  static int toInt(dynamic value, int defaultValue) {
    return tryToInt(value) ?? defaultValue;
  }

  static double toDouble(dynamic value, double defaultValue) {
    return tryToDouble(value) ?? defaultValue;
  }

  static num toNum(dynamic value, num defaultValue) {
    return tryToNum(value) ?? defaultValue;
  }

  static bool toBool(dynamic value, bool defaultValue) {
    return tryToBool(value) ?? defaultValue;
  }

  static Map<K, V> toMap<K, V>(dynamic value, {Map<K, V>? defaultValue}) {
    if (value == null || value is! Map) {
      return defaultValue ?? Map<K, V>.identity();
    }
    return Map<K, V>.from(value);
  }

  static List<T> toList<T>(dynamic value, {List<T>? defaultValue}) {
    if (value == null || value is! List) {
      return defaultValue ?? List<T>.empty(growable: true);
    }
    return List<T>.from(List.from(value).whereType<T>());
  }

  static DateTime toDateTime(dynamic value) {
    if (value is int) {
      if (value.toString().length == 10) {
        value *= 1000;
      }
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      if (value.length == 10) {
        value += '000';
      }
      try {
        final timestamp = num.tryParse(value);
        if (timestamp != null) {
          return DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
        }
        return DateTime.parse(value);
      } catch (e) {}
    }
    return DateTime(1970);
  }

  static int? tryToInt(dynamic value) {
    return tryToNum(value)?.toInt();
  }

  static double? tryToDouble(dynamic value) {
    return tryToNum(value)?.toDouble();
  }

  static num? tryToNum(dynamic value) {
    if (value == null) {
      return null;
    } else if (value is num) {
      return value;
    }
    return num.tryParse(value.toString());
  }

  static bool? tryToBool(dynamic value) {
    if (value == null) {
      return null;
    } else if (value is bool) {
      return value;
    }
    return boolTrueValues.contains(value.toString());
  }

  static Map<String, dynamic> visitMapValue(
      String jsonKey, Map<String, dynamic> json,
      {Map<String, dynamic>? defaultValue}) {
    List<String> keys = jsonKey.split('.');
    keys.removeWhere((element) => element.trim().isEmpty);
    Map<String, dynamic> result = json;
    for (var key in keys) {
      result = toMap<String, dynamic>(result[key], defaultValue: defaultValue);
    }
    return result;
  }
}
