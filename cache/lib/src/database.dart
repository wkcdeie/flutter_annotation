import 'dart:io';

import 'package:flutter_annotation_sqlite/flutter_annotation_sqlite.dart';
import 'package:sqflite_common/sqflite.dart' as sqflite;
import 'cache_data.dart';
import 'cache_data_repository.dart';
import 'persistent.dart';

part 'database.db.dart';

@Database(entities: [CacheData])
abstract class _AbstractCacheDatabase {
  sqflite.DatabaseFactory? _databaseFactory;

  sqflite.Database get database;

  sqflite.DatabaseFactory get sqliteFactory {
    if (_databaseFactory == null) {
      throw ArgumentError.notNull('databaseFactory');
    }
    return _databaseFactory!;
  }

  Future<void> open(String dbPath, {bool inMemory = false});

  Future<void> close();
}

final class CacheDatabase {
  static final _AbstractCacheDatabase _cacheDatabase =
      _$_AbstractCacheDatabase();
  static late final PersistentStore _store;

  static PersistentStore get store => _store;

  static Future<void> initialize(
      String cacheDir, sqflite.DatabaseFactory factory) async {
    _cacheDatabase._databaseFactory = factory;
    final rootDir = Directory('$cacheDir/fac');
    if (!await rootDir.exists()) {
      await rootDir.create(recursive: true);
    }
    await _cacheDatabase.open('${rootDir.path}/fac.db');
    _store = PersistentStore(
        cacheDir, CacheDataRepository.create(_cacheDatabase.database));
  }

  static void close() {
    _cacheDatabase.close();
  }
}
