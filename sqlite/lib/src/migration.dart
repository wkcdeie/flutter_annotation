import 'dart:async';
import 'package:sqflite_common/sqlite_api.dart' show Database;

/// Base class for a database migration.
abstract class Migrator {
  /// The old version of the database.
  int get fromVersion;

  /// The new version of the database.
  int get toVersion;

  /// Function that performs the migration.
  FutureOr<void> onMigration(Database db);
}
