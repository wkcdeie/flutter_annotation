typedef JsonFieldCoder = Function(dynamic value);

/// Annotation Class Properties
class JsonField {
  /// JSON Key
  final String? name;

  /// Default value
  final dynamic defaultValue;

  /// Whether to ignore
  final bool ignore;

  /// Custom encoding
  final JsonFieldCoder? encoder;

  /// Custom decoding
  final JsonFieldCoder? decoder;

  const JsonField(
      {this.name,
      this.defaultValue,
      this.ignore = false,
      this.encoder,
      this.decoder});
}
