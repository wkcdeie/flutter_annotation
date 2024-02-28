import 'dart:async';

import 'package:flutter_annotation_cache/flutter_annotation_cache.dart';
import 'package:flutter_annotation_log/flutter_annotation_log.dart';
import 'package:logging/logging.dart';

part 'book.cache.dart';

part 'book.log.dart';

@EnableCaching('Book')
@EnableLogging(name: 'Book')
class BookRepository {
  BookRepository();

  factory BookRepository.withCache(AsyncCacheStore store) =>
      _$BookRepositoryWithCache(store);

  factory BookRepository.withLog() => _$BookRepositoryWithLog();

  @CachePut('#bookInfo.id', condition: _cheIfCache, ttl: 6000)
  @InfoLog('BookRepository:saveBook->#bookInfo.id')
  BookInfo saveBook(BookInfo bookInfo) {
    return bookInfo;
  }

  @Cacheable('#bookId')
  @InfoLog('BookRepository:queryBook->#bookId')
  Future<BookInfo?> queryBook(String bookId) {
    // test
    if (bookId == '123') {
      return Future.value(null);
    }
    return Future.value(BookInfo(bookId));
  }

  @CacheEvict('#bookId', beforeInvocation: true)
  @InfoLog('BookRepository:deleteBook->#bookId')
  void deleteBook(String bookId) {}

  @Cacheable('list#page')
  @InfoLog('BookRepository:getBookList->#page')
  Future<List<BookInfo>> getBookList(int page) {
    return Future.value([]);
  }

  @Cacheable('author#bookId')
  @InfoLog('BookRepository:getAuthor->#bookId')
  Future<String?> getAuthor(String bookId) {
    return Future.value(null);
  }
}

bool _cheIfCache(Object target, String methodName, List args) => true;

class BookInfo {
  final String id;

  BookInfo(this.id);

  Map<String, dynamic> toJson() => {'id': id};

  factory BookInfo.fromJson(Map<String, dynamic> json) => BookInfo(json['id']);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookInfo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
