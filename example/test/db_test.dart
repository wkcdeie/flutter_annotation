import 'package:example/db/database.dart';
import 'package:example/db/person.dart';
import 'package:example/db/person_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as scf;

void main() {
  final handler = AppDatabase.create();
  late PersonRepository repository;

  setUp(() async {
    handler.databaseFactory = scf.databaseFactoryFfi;
    await handler.open('', inMemory: true);
    repository = PersonRepository.create(handler.database);
  });

  tearDown(() {
    handler.close();
  });

  test('insert person', () async {
    await repository.insert(Person(id: 0, name: 'tom', age: 22, height: 180));
  });

  test('insert person address', () async {
    await repository.insert(Person(
      id: 0,
      name: 'jack',
      age: 18,
      height: 160,
      address: Address(province: 'province', city: 'city', area: 'area'),
    ));
  });

  test('query entities', () async {
    final persons = await repository.findEntities(1);
    expect(persons, isEmpty);
  });

  test('query values', () async {
    final values = await repository.findValues();
    expect(values, isEmpty);
  });

  test('query person address', () async {
    final address = await repository.findAddressByName('jack');
    expect(address, isNull);
  });
}
