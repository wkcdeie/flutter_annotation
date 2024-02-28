import 'package:sqflite_common/sqflite.dart' show Database;
import 'package:sqflite_common/sql.dart';

class SqlHelper {
  static Future<void> createTable(
      Database db, String table, List<String> columns,
      {List<String>? primaryKeys}) {
    final tableName = escapeName(table);
    final escapeColumns = columns.map((e) => escapeName(e)).toList();
    if (primaryKeys != null && primaryKeys.isNotEmpty) {
      escapeColumns.add(
          'PRIMARY KEY(${primaryKeys.map((e) => escapeName(e)).join(',')})');
    }
    final columnsExpr = escapeColumns.join(',');
    return db.execute('CREATE TABLE IF NOT EXISTS $tableName($columnsExpr)');
  }

  static Future<void> createIndex(
      Database db, String table, List<String> columns,
      [bool isUnique = false]) {
    final tableName = escapeName(table);
    final escapeColumns = columns.map((e) => escapeName(e));
    final columnsExpr = escapeColumns.join(',');
    final indexName = '${tableName}_${escapeColumns.join('_')}';
    return db.execute(
        'CREATE ${isUnique ? 'UNIQUE ' : ''}INDEX IF NOT EXISTS $indexName ON $tableName($columnsExpr)');
  }
}
