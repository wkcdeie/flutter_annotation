import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_annotation_sqlite/flutter_annotation_sqlite.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'person.dart';

part 'database.db.dart';

@Database(
  entities: [Person, Address],
  migrations: [V2Migrator],
)
abstract class AppDatabase {
  sqflite.Database get database;

  Future<void> open(String dbPath, {bool inMemory = false});

  Future<void> close();

  static AppDatabase create() => _$AppDatabase();

  sqflite.DatabaseFactory get sqliteFactory {
    if (kReleaseMode) {
      return sqflite.databaseFactorySqflitePlugin;
    }
    return sqlLoggerFactory(sqflite.databaseFactorySqflitePlugin);
  }
}

class V2Migrator extends Migrator {
  @override
  FutureOr<void> onMigration(sqflite.Database db) {
    // TODO: implement onMigration
    throw UnimplementedError();
  }

  @override
  // TODO: implement fromVersion
  int get fromVersion => throw UnimplementedError();

  @override
  // TODO: implement toVersion
  int get toVersion => throw UnimplementedError();
}
