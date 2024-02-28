// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

part of 'cache_data_repository.dart';

class _$CacheDataRepository extends CacheDataRepository {
  _$CacheDataRepository(this._database) : _coder = _CacheDataCoder() {
    if (_coder != null) {
      FieldCoderRegistry.register('CacheData', _coder!);
    }
  }

  final sqflite.Database _database;

  final String _table = 'fa_cache_data';

  final FieldCoder? _coder;

  @override
  Future<CacheData?> findByKey(String key) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('key=?');
    whereArgs.add(key);
    final rows = await _database.query(_table,
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
    if (rows.isEmpty) {
      return null;
    } else if (rows.length > 1) {
      throw StateError('Too many results are returned.');
    }
    final decoder = _coder;
    if (decoder == null) {
      throw StateError('No decoder of type `CacheData` found.');
    }
    final columnMap = _geEntityColumnInfo();
    final fieldMap = rows.first.map((key, value) {
      final fieldInfo = columnMap[key]!;
      final fk = fieldInfo.keys.first;
      final ft = fieldInfo.values.first;
      if (ft == 'int' || ft == 'double' || ft == 'String' || value == null) {
        return MapEntry(fk, value);
      }
      final fieldDecoder = FieldCoderRegistry.get(ft);
      if (fieldDecoder == null) {
        throw StateError('No decoder of type `$ft` found.');
      }
      return MapEntry(fk, fieldDecoder.decode(value));
    });
    return decoder.decode(fieldMap) as CacheData?;
  }

  @override
  Future<List<CacheData>> findByName(String likeKey) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('key LIKE ?');
    whereArgs.add('$likeKey%');
    final rows = await _database.query(_table,
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
    final decoder = _coder;
    if (decoder == null) {
      throw StateError('No decoder of type `CacheData` found.');
    }
    final columnMap = _geEntityColumnInfo();
    return rows.map((e) {
      final fieldMap = e.map((key, value) {
        final fieldInfo = columnMap[key]!;
        final fk = fieldInfo.keys.first;
        final ft = fieldInfo.values.first;
        if (ft == 'int' || ft == 'double' || ft == 'String' || value == null) {
          return MapEntry(fk, value);
        }
        final fieldDecoder = FieldCoderRegistry.get(ft);
        if (fieldDecoder == null) {
          throw StateError('No decoder of type `$ft` found.');
        }
        return MapEntry(fk, fieldDecoder.decode(value));
      });
      return decoder.decode(fieldMap) as CacheData;
    }).toList();
  }

  @override
  Future<List<String>> findPathsByName(String likeKey) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('key LIKE ?');
    whereArgs.add('$likeKey%');
    final rows = await _database.query(_table,
        columns: ['file_path'],
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
    return rows.map((e) {
      return e['file_path'] as String;
    }).toList();
  }

  @override
  Future<void> insert(CacheData entity) async {
    Map<String, Object?> values = {
      'key': entity.key,
      'size': entity.size,
      'expire_date': entity.expireDate,
      'file_path': entity.filePath,
      'data': entity.data == null
          ? null
          : FieldCoderRegistry.get('Uint8List')?.encode(entity.data),
    };
    await _database.insert(_table, values,
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  @override
  Future<bool> deleteByKey(String key) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('key=?');
    whereArgs.add(key);
    final result = await _database.delete(_table,
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
    return result > 0;
  }

  @override
  Future<bool> deleteByName(String likeKey) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('key LIKE ?');
    whereArgs.add('$likeKey%');
    final result = await _database.delete(_table,
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
    return result > 0;
  }

  Map<String, Map<String, String>> _geEntityColumnInfo() {
    return {
      'key': {'key': 'String'},
      'size': {'size': 'int'},
      'expire_date': {'expireDate': 'int'},
      'file_path': {'filePath': 'String'},
      'data': {'data': 'Uint8List'},
    };
  }
}
