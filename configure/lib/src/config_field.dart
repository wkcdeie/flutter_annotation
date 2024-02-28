typedef ConfigFieldCoder = dynamic Function(dynamic value);

/// Annotation configuration fields
class ConfigField {
  /// Field Key, default field name
  final String? key;

  /// Field default value
  final dynamic defaultValue;

  /// Custom encoding
  final ConfigFieldCoder? encoder;

  /// Custom decoding
  final ConfigFieldCoder? decoder;

  const ConfigField({this.key, this.defaultValue, this.encoder, this.decoder});
}
