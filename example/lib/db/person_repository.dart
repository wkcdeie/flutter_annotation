import 'package:flutter_annotation_sqlite/flutter_annotation_sqlite.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'person.dart';

part 'person_repository.dao.dart';

@Repository(Person)
abstract class PersonRepository {
  static PersonRepository create(sqflite.Database database) =>
      _$PersonRepository(database);

  @Query()
  Future<List<Person>> findEntities(int page,
      {String? likeName, int limit = 20});

  @Query()
  Future<Person?> findById(int id);

  @Query()
  Future<Map> findMapByName(String name);

  @Query(fields: ['name', 'isVip'])
  Future<Map> findValueById(int id);

  @Query(fields: ['age'])
  Future<int> findAgeByName(String name);

  @Query(fields: ['birthday'])
  Future<DateTime> findBirthdayByName(String name);

  @Query(fields: [
    'name'
  ], orderBy: [
    {'age': OrderingTerm.desc},
    {'height': OrderingTerm.asc}
  ])
  Future<List<String>> findNames(bool isVip, {double? orGteHeight});

  @Query(fields: ['birthday'])
  Future<List<DateTime>> findBirthdays(bool isVip);

  @Query(
      fields: ['id', 'name', 'age', 'height', 'isVip', 'address', 'birthday'])
  Future<List<Map<String, dynamic>>> findValues([String? likeName]);

  @Insert(sqflite.ConflictAlgorithm.abort)
  Future<void> insert(Person entity);

  @Update()
  Future<void> updateById(Person entity, int id);

  @Update(conflict: sqflite.ConflictAlgorithm.replace, ignoreNull: true)
  Future<void> updateAll(Person entity);

  @Delete()
  Future<void> delete(int id);

  @Delete()
  Future<bool> deleteByAge(int age, {double? orHeight});
}
