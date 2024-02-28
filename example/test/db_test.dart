import 'dart:io';

import 'package:example/db/database.dart';
import 'package:example/db/person.dart';
import 'package:example/db/person_repository.dart';
import 'package:flutter_annotation_sqlite/flutter_annotation_sqlite.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final database = AppDatabase.create();
  FieldCoderRegistry.register('Person', _PersonCoder());
  FieldCoderRegistry.register('Address', _AddressCoder());

  late PersonRepository repository;

  setUp(() async {
    await database.open('${Directory.systemTemp.path}/test.db');
    repository = PersonRepository.create(database.database);
  });

  tearDown(() {
    database.close();
  });

  test('insert person', () async {
    await repository.insert(Person(id: 0, name: 'tom', age: 22, height: 180));
  });

  test('query entities', () async {
    final persons = await repository.findEntities(1);
    expect(persons, isNotEmpty);
  });

  test('query values', () async {
    final values = await repository.findValues();
    expect(values, isNotEmpty);
  });

  test('query person age', () async {
    final age = await repository.findAgeByName('jack');
    expect(age, 18);
  });
}

class _PersonCoder extends FieldCoder<Person, String> {
  @override
  Person decode(Object value) {
    print('Person map:$value');
    return Person.fromJson(value as Map<String, dynamic>);
  }

  @override
  String encode(Person? value) {
    // TODO: implement encode
    throw UnimplementedError();
  }
}

class _AddressCoder extends FieldCoder<Address, String> {
  @override
  Address decode(Object value) {
    print('Address map:$value');
    return Address.fromJson(value as Map<String, dynamic>);
  }

  @override
  String encode(Address? value) {
    // TODO: implement encode
    throw UnimplementedError();
  }
}
