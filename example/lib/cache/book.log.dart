// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// EnableLoggingGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps
// ignore_for_file: unnecessary_string_interpolations

part of 'book.dart';

class _$BookRepositoryWithLog extends BookRepository {
  final Logger _logger = Logger('Book');

  @override
  BookInfo saveBook(BookInfo bookInfo) {
    _logger.info(
        'BookRepository:saveBook->${bookInfo.id}', null, StackTrace.current);
    return super.saveBook(
      bookInfo,
    );
  }

  @override
  Future<BookInfo?> queryBook(String bookId) {
    _logger.info(
        'BookRepository:queryBook->${bookId}', null, StackTrace.current);
    return super.queryBook(
      bookId,
    );
  }

  @override
  void deleteBook(String bookId) {
    _logger.info(
        'BookRepository:deleteBook->${bookId}', null, StackTrace.current);
    return super.deleteBook(
      bookId,
    );
  }

  @override
  Future<List<BookInfo>> getBookList(int page) {
    _logger.info(
        'BookRepository:getBookList->${page}', null, StackTrace.current);
    return super.getBookList(
      page,
    );
  }

  @override
  Future<String?> getAuthor(String bookId) {
    _logger.info(
        'BookRepository:getAuthor->${bookId}', null, StackTrace.current);
    return super.getAuthor(
      bookId,
    );
  }
}
