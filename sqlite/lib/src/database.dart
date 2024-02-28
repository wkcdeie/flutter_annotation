/// Mark the class as a database configuration entry.
class Database {
  /// The database version.
  final int version;

  /// The entities the database manages.
  final List<Type> entities;

  /// The migrations the database manages.
  final List<Type> migrations;

  const Database(
      {this.version = 1, required this.entities, this.migrations = const []});
}
