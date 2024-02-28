/// Annotate classes that require JSON conversion
class JsonObject {
  /// Parsing the specified key from JSON
  final String? jsonKey;

  /// JSON Key names are mapped using underscores
  final bool underScoreCase;

  /// Whether to filter null when outputting JSON objects
  final bool outputNull;

  const JsonObject(
      {this.jsonKey, this.underScoreCase = false, this.outputNull = false});
}
