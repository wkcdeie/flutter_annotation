import 'package:example/cache/book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final book = BookInfo('123');
  final repository = BookRepository.withCache();
  test('Book save', () {
    final result = repository.saveBook(book);
    expect(result, book);
  });

  test('Book query in cache', () async {
    final result = await repository.queryBook(book.id);
    expect(result, book);
  });

  test('Book query no cache', () async {
    final result = await repository.queryBook('000');
    expect(result, isNot(book));
  });
}
