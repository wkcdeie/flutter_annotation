// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// DatabaseGenerator
// **************************************************************************

part of 'database.dart';

class _$AppDatabase extends AppDatabase {
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
          await _addTable(db, 'tb_person', [
            'id INTEGER PRIMARY KEY AUTOINCREMENT',
            'name TEXT UNIQUE',
            'age INTEGER NOT NULL',
            'height REAL NOT NULL',
            'is_vip INTEGER NOT NULL',
            'address TEXT',
            'birthday TEXT'
          ]);
          await _addIndex(db, 'tb_person', ['is_vip']);
          await _addTable(db, 'Address', [
            'province TEXT NOT NULL',
            'city TEXT NOT NULL',
            'area TEXT NOT NULL',
            'detail TEXT',
            'PRIMARY KEY(province,city,area)'
          ]);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          final migrations = [
            V2Migrator(),
          ].where((element) => element.fromVersion >= oldVersion).toList();
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

  Future<void> _addTable(
    sqflite.Database db,
    String table,
    List<String> columns,
  ) {
    return db
        .execute('CREATE TABLE IF NOT EXISTS $table(${columns.join(',')})');
  }

  Future<void> _addIndex(
    sqflite.Database db,
    String table,
    List<String> columns, [
    bool isUnique = false,
  ]) {
    return db.execute(
        'CREATE ${isUnique ? 'UNIQUE' : ''} INDEX IF NOT EXISTS ${table}_${columns.join('_')} ON $table(${columns.join(',')})');
  }
}
