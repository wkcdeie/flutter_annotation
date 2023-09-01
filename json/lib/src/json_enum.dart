/// Annotation enumeration type
class JsonEnum {
  /// Default value, only supports `String` and `int`
  final Object? defaultValue;

  const JsonEnum([this.defaultValue]);
}

/// Annotation Enumeration Members
class EnumValue {
  /// Enumeration values, only supports `String` and `int`
  final Object value;

  const EnumValue(this.value);
}
