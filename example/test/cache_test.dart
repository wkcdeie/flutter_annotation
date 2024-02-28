import 'dart:io';

import 'package:example/cache/book.dart';
import 'package:flutter_annotation_cache/flutter_annotation_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late BookRepository repository;

  setUp(() async {
    await CacheDatabase.initialize(
        Directory.systemTemp.path, databaseFactoryFfi);
    repository = BookRepository.withCache(CacheDatabase.store);
  });

  tearDown(() {
    CacheDatabase.close();
  });

  test('Book save', () {
    final book = BookInfo('4567');
    final result = repository.saveBook(book);
    expect(result, book);
  });

  test('Book query', () async {
    final result = await repository.queryBook('4567');
    expect(result, isNotNull);
  });

  test('Book query no result', () async {
    final result = await repository.queryBook('123');
    expect(result, isNull);
  });
}
