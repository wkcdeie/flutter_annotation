import 'dart:convert';

import 'package:flutter_annotation_sqlite/flutter_annotation_sqlite.dart';
import 'package:sqflite_common/sqflite.dart' as sqflite;
import 'cache_data.dart';

part 'cache_data_repository.dao.dart';

@Repository(CacheData, _CacheDataCoder)
abstract class CacheDataRepository {
  static CacheDataRepository create(sqflite.Database database) =>
      _$CacheDataRepository(database);

  @Query()
  Future<CacheData?> findByKey(String key);

  @Query()
  Future<List<CacheData>> findByName(String likeKey);

  @Query(fields: ['filePath'])
  Future<List<String>> findPathsByName(String likeKey);

  @Insert(sqflite.ConflictAlgorithm.replace)
  Future<void> insert(CacheData entity);

  @Delete()
  Future<bool> deleteByKey(String key);

  @Delete()
  Future<bool> deleteByName(String likeKey);
}

class _CacheDataCoder extends FieldCoder<CacheData, String> {
  @override
  String encode(CacheData? value) {
    if (value == null) {
      return '{}';
    }
    return jsonEncode(value.toJson());
  }

  @override
  CacheData decode(Object value) {
    Map<String, dynamic> jsonObject = {};
    if (value is String) {
      jsonObject = jsonDecode(value);
    } else if (value is Map) {
      jsonObject = Map<String, dynamic>.from(value);
    }
    return CacheData.fromJson(jsonObject);
  }
}
