/// Specifies that the class is an entity.
class Entity {
  /// It specifies the table in the database with which this entity is mapped.
  final String? table;

  /// Table unique indexes
  final Set<List<String>> uniqueKeys;

  /// The joint primary key of the table
  final List<String> primaryKeys;

  const Entity(
      {this.table, this.uniqueKeys = const {}, this.primaryKeys = const []});
}

/// Specify the column mapping.
class Column {
  /// This is used for specifying the table’s column name.
  final String? name;

  /// Column default value
  final dynamic defaultValue;

  /// Represents a column as an index key
  final bool indexable;

  /// Represents a column as a unique key
  final bool unique;

  const Column(
      {this.name,
      this.defaultValue,
      bool indexable = false,
      this.unique = false})
      : indexable = unique ? false : indexable;
}

/// This annotation specifies the primary key of the entity.
class Id extends Column {
  /// Whether the primary key uses autoincrement, the column type must be Integer
  final bool autoincrement;

  const Id({this.autoincrement = true, super.name});
}
