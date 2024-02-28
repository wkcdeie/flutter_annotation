import 'package:sqflite_common/sqlite_api.dart' show ConflictAlgorithm;

/// Represents a DAO access object
class Repository {
  /// Represents the object type of the operation
  final Type entity;

  const Repository(this.entity);
}

/// SQL: `ORDER BY` options
enum OrderingTerm { asc, desc }

/// SQL: `SELECT` operation
class Query {
  /// Specifies the fields to return
  final List<String>? fields;

  /// Grouping based on specified columns
  final List<String>? groupBy;

  /// If specified, it is evaluated once for each group of rows as a boolean expression.
  final String? having;

  /// Sort the field
  final List<Map<String, OrderingTerm>>? orderBy;

  const Query({this.fields, this.groupBy, this.having, this.orderBy});
}

/// SQL: `INSERT` operation
class Insert {
  /// conflict resolver
  final ConflictAlgorithm? conflict;

  const Insert([this.conflict]);
}

/// SQL: `UPDATE` operation
class Update {
  /// conflict resolver
  final ConflictAlgorithm? conflict;

  /// Whether null values are ignored
  final bool ignoreNull;

  const Update({this.conflict, this.ignoreNull = false});
}

/// SQL: `DELETE` operation
class Delete {
  const Delete();
}
