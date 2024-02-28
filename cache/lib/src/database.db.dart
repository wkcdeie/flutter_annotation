// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// DatabaseGenerator
// **************************************************************************

part of 'database.dart';

class _$_AbstractCacheDatabase extends _AbstractCacheDatabase {
  sqflite.Database? _database;

  @override
  sqflite.Database get database {
    if (_database == null) {
      throw StateError(
          'The database instance is not initialized or has been shut down, call the open method to reopen.');
    }
    return _database!;
  }

  @override
  Future<void> open(
    String dbPath, {
    bool inMemory = false,
  }) async {
    await close();
    _database = await sqliteFactory.openDatabase(
      inMemory ? sqflite.inMemoryDatabasePath : dbPath,
      options: sqflite.OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await SqlHelper.createTable(db, 'fa_cache_data', [
            'key TEXT UNIQUE',
            'size INTEGER NOT NULL',
            'expire_date INTEGER',
            'file_path TEXT',
            'data BLOB'
          ]);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          final migrations =
              [].where((element) => element.fromVersion >= oldVersion).toList();
          migrations.sort((a, b) => a.fromVersion.compareTo(b.fromVersion));
          if (migrations.isEmpty || migrations.last.toVersion != newVersion) {
            throw StateError(
                'There is no migration supplied to update the database to the current version. Aborting the migration.');
          }
          for (var migrator in migrations) {
            await migrator.onMigration(db);
          }
        },
      ),
    );
  }

  @override
  Future<void> close() async {
    _database?.close();
    _database = null;
  }
}
