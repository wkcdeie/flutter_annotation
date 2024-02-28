// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// EnableCachingGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps
// ignore_for_file: unnecessary_string_interpolations

part of 'book.dart';

class _$BookRepositoryWithCache extends BookRepository {
  _$BookRepositoryWithCache(this.cacheStore) : super();

  final String _cacheName = 'Book';

  final AsyncCacheStore cacheStore;

  @override
  BookInfo saveBook(BookInfo bookInfo) {
    final shouldCache = _cheIfCache.call(this, 'saveBook', [bookInfo]);
    if (!shouldCache) {
      return super.saveBook(bookInfo);
    }
    final cacheKey = '${bookInfo.id}';
    final result = super.saveBook(bookInfo);
    cacheStore.asyncPut(_cacheName, cacheKey, result.toJson(),
        expires: DateTime.now().millisecondsSinceEpoch + 6000);
    return result;
  }

  @override
  Future<BookInfo?> queryBook(String bookId) async {
    final cacheKey = '${bookId}';
    BookInfo? result;
    final cacheObject = await cacheStore.asyncGet(_cacheName, cacheKey);
    if (cacheObject != null) {
      result = BookInfo.fromJson(cacheObject as Map<String, dynamic>);
    }
    if (result == null) {
      result = await super.queryBook(bookId);
      if (result != null) {
        cacheStore.asyncPut(_cacheName, cacheKey, result.toJson());
      }
    }
    return result;
  }

  @override
  void deleteBook(String bookId) {
    final cacheKey = '${bookId}';
    cacheStore.remove(_cacheName, cacheKey);
    return super.deleteBook(bookId);
  }

  @override
  Future<List<BookInfo>> getBookList(int page) async {
    final cacheKey = 'list${page}';
    List<BookInfo>? result;
    final cacheObject = await cacheStore.asyncGet(_cacheName, cacheKey);
    if (cacheObject != null) {
      result = (cacheObject as List).map((e) => BookInfo.fromJson(e)).toList();
    }
    if (result == null) {
      result = await super.getBookList(page);
      cacheStore.asyncPut(
          _cacheName, cacheKey, result.map((e) => e.toJson()).toList());
    }
    return result;
  }

  @override
  Future<String?> getAuthor(String bookId) async {
    final cacheKey = 'author${bookId}';
    String? result;
    final cacheObject = await cacheStore.asyncGet(_cacheName, cacheKey);
    if (cacheObject != null) {
      result = cacheObject as String;
    }
    if (result == null) {
      result = await super.getAuthor(bookId);
      if (result != null) {
        cacheStore.asyncPut(_cacheName, cacheKey, result);
      }
    }
    return result;
  }
}
