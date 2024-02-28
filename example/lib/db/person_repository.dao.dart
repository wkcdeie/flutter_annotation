// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

part of 'person_repository.dart';

class _$PersonRepository extends PersonRepository {
  _$PersonRepository(this._database) : _coder = _PersonCoder() {
    if (_coder != null) {
      FieldCoderRegistry.register('Person', _coder!);
    }
  }

  final sqflite.Database _database;

  final String _table = 'tb_person';

  final FieldCoder? _coder;

  @override
  Future<List<Person>> findEntities(
    int page, {
    String? likeName,
    int limit = 20,
  }) async {
    assert(limit > 0 && page > 0);
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    if (likeName != null) {
      whereString.add('name LIKE ?');
      whereArgs.add('$likeName%');
    }
    final rows = await _database.query(_table,
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs,
        limit: limit,
        offset: (page - 1) * limit);
    final decoder = _coder;
    if (decoder == null) {
      throw StateError('No decoder of type `Person` found.');
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
      return decoder.decode(fieldMap) as Person;
    }).toList();
  }

  @override
  Future<Person?> findById(int id) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('id=?');
    whereArgs.add(id);
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
      throw StateError('No decoder of type `Person` found.');
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
    return decoder.decode(fieldMap) as Person?;
  }

  @override
  Future<Map<dynamic, dynamic>> findMapByName(String name) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('name=?');
    whereArgs.add(name);
    final rows = await _database.query(_table,
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
    if (rows.isEmpty) {
      throw StateError('The result set is empty.');
    }
    return Map<dynamic, dynamic>.from(rows.first);
  }

  @override
  Future<Map<dynamic, dynamic>> findValueById(int id) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('id=?');
    whereArgs.add(id);
    final rows = await _database.query(_table,
        columns: ['name', 'is_vip'],
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
    if (rows.isEmpty) {
      throw StateError('The result set is empty.');
    }
    final rs = rows.first;
    Map<dynamic, dynamic> result = {};
    if (rs['name'] != null) {
      result['name'] = rs['name'];
    }
    if (rs['is_vip'] != null) {
      final decoder = FieldCoderRegistry.get('bool');
      if (decoder == null) {
        throw StateError('No decoder of type `bool` found.');
      }
      result['isVip'] = decoder.decode(rs['is_vip']!);
    }
    return result;
  }

  @override
  Future<int> findAgeByName(String name) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('name=?');
    whereArgs.add(name);
    final rows = await _database.query(_table,
        columns: ['age'],
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
    if (rows.isEmpty) {
      throw StateError('The result set is empty.');
    }
    return rows.first['age'] as int;
  }

  @override
  Future<DateTime> findBirthdayByName(String name) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('name=?');
    whereArgs.add(name);
    final rows = await _database.query(_table,
        columns: ['birthday'],
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
    if (rows.isEmpty) {
      throw StateError('The result set is empty.');
    }
    final decoder = FieldCoderRegistry.get('DateTime');
    if (decoder == null) {
      throw StateError('No decoder of type `DateTime` found.');
    }
    final birthday = rows.first['birthday'];
    if (birthday == null) {
      throw StateError('The column `birthday` returned null.');
    }
    return decoder.decode(birthday) as DateTime;
  }

  @override
  Future<Address?> findAddressByName(String name) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('name=?');
    whereArgs.add(name);
    final rows = await _database.query(_table,
        columns: ['address'],
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
    if (rows.isEmpty) {
      return null;
    }
    final decoder = FieldCoderRegistry.get('Address');
    if (decoder == null) {
      throw StateError('No decoder of type `Address` found.');
    }
    final address = rows.first['address'];
    if (address == null) {
      return null;
    }
    return decoder.decode(address) as Address?;
  }

  @override
  Future<List<String>> findNames(
    bool isVip, {
    double? orGteHeight,
  }) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('is_vip=?');
    whereArgs.add(isVip);
    if (orGteHeight != null) {
      whereString.add('OR');
      whereString.add('height>=?');
      whereArgs.add(orGteHeight);
    }
    final rows = await _database.query(_table,
        columns: ['name'],
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs,
        orderBy: 'age DESC,height ASC');
    return rows.map((e) {
      return e['name'] as String;
    }).toList();
  }

  @override
  Future<List<DateTime>> findBirthdays(bool isVip) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('is_vip=?');
    whereArgs.add(isVip);
    final rows = await _database.query(_table,
        columns: ['birthday'],
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
    final decoder = FieldCoderRegistry.get('DateTime');
    if (decoder == null) {
      throw StateError('No decoder of type `DateTime` found.');
    }
    return rows.map((e) {
      final birthday = e['birthday'];
      if (birthday == null) {
        throw StateError('The column `birthday` returned null.');
      }
      return decoder.decode(birthday) as DateTime;
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> findValues([String? likeName]) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    if (likeName != null) {
      whereString.add('name LIKE ?');
      whereArgs.add('$likeName%');
    }
    final rows = await _database.query(_table,
        columns: [
          'id',
          'name',
          'age',
          'height',
          'is_vip',
          'address',
          'birthday'
        ],
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
    return rows.map((e) {
      Map<String, dynamic> result = {};
      if (e['id'] != null) {
        result['id'] = e['id'];
      }
      if (e['name'] != null) {
        result['name'] = e['name'];
      }
      if (e['age'] != null) {
        result['age'] = e['age'];
      }
      if (e['height'] != null) {
        result['height'] = e['height'];
      }
      if (e['is_vip'] != null) {
        final decoder = FieldCoderRegistry.get('bool');
        if (decoder == null) {
          throw StateError('No decoder of type `bool` found.');
        }
        result['isVip'] = decoder.decode(e['is_vip']!);
      }
      if (e['address'] != null) {
        final decoder = FieldCoderRegistry.get('Address');
        if (decoder == null) {
          throw StateError('No decoder of type `Address` found.');
        }
        result['address'] = decoder.decode(e['address']!);
      }
      if (e['birthday'] != null) {
        final decoder = FieldCoderRegistry.get('DateTime');
        if (decoder == null) {
          throw StateError('No decoder of type `DateTime` found.');
        }
        result['birthday'] = decoder.decode(e['birthday']!);
      }
      return result;
    }).toList();
  }

  @override
  Future<void> insert(Person entity) async {
    Map<String, Object?> values = {
      'name': entity.name,
      'age': entity.age,
      'height': entity.height,
      'is_vip': FieldCoderRegistry.get('bool')?.encode(entity.isVip),
      'address': entity.address == null
          ? null
          : FieldCoderRegistry.get('Address')?.encode(entity.address),
      'birthday': entity.birthday == null
          ? null
          : FieldCoderRegistry.get('DateTime')?.encode(entity.birthday),
    };
    await _database.insert(_table, values,
        conflictAlgorithm: sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> updateById(
    Person entity,
    int id,
  ) async {
    Map<String, Object?> values = {
      'age': entity.age,
      'height': entity.height,
      'is_vip': FieldCoderRegistry.get('bool')?.encode(entity.isVip),
      'address': entity.address == null
          ? null
          : FieldCoderRegistry.get('Address')?.encode(entity.address),
      'birthday': entity.birthday == null
          ? null
          : FieldCoderRegistry.get('DateTime')?.encode(entity.birthday),
    };
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('id=?');
    whereArgs.add(id);
    await _database.update(_table, values,
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
  }

  @override
  Future<void> updateAll(Person entity) async {
    Map<String, Object?> values = {
      'age': entity.age,
      'height': entity.height,
      'is_vip': FieldCoderRegistry.get('bool')?.encode(entity.isVip),
      'address': entity.address == null
          ? null
          : FieldCoderRegistry.get('Address')?.encode(entity.address),
      'birthday': entity.birthday == null
          ? null
          : FieldCoderRegistry.get('DateTime')?.encode(entity.birthday),
    };
    values.removeWhere((key, value) => value == null);
    await _database.update(_table, values,
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  @override
  Future<void> delete(int id) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('id=?');
    whereArgs.add(id);
    await _database.delete(_table,
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
  }

  @override
  Future<bool> deleteByAge(
    int age, {
    double? orHeight,
  }) async {
    List<Object?> whereArgs = [];
    List<String> whereString = [];
    whereString.add('age=?');
    whereArgs.add(age);
    if (orHeight != null) {
      whereString.add('OR');
      whereString.add('height=?');
      whereArgs.add(orHeight);
    }
    final result = await _database.delete(_table,
        where: whereString.isNotEmpty ? whereString.join(' ') : null,
        whereArgs: whereArgs);
    return result > 0;
  }

  Map<String, Map<String, String>> _geEntityColumnInfo() {
    return {
      'id': {'id': 'int'},
      'name': {'name': 'String'},
      'age': {'age': 'int'},
      'height': {'height': 'double'},
      'is_vip': {'isVip': 'bool'},
      'address': {'address': 'Address'},
      'birthday': {'birthday': 'DateTime'},
    };
  }
}
