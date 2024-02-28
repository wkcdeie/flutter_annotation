import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:flutter_annotation_sqlite/flutter_annotation_sqlite.dart';
import 'package:source_gen/source_gen.dart';
import 'package:flutter_annotation_common/flutter_annotation_common.dart' as fc;

class EntityCollector {
  final _columnChecker = TypeChecker.fromRuntime(Column);
  final _idChecker = TypeChecker.fromRuntime(Id);

  late String table;
  final List<String> primaryKeys = [];
  final List<Iterable<String>> uniqueKeys = [];
  final List<String> columnIndexes = [];
  final List<TableColumn> columns = [];

  void collect(ClassElement element, ConstantReader reader) {
    table = reader.peek('table')?.stringValue ?? element.displayName;
    for (var field in element.fields) {
      DartObject? columnAnnotation =
          _idChecker.firstAnnotationOf(field, throwOnUnresolved: false);
      bool autoincrement = false;
      if (columnAnnotation != null) {
        autoincrement =
            columnAnnotation.getField('autoincrement')?.toBoolValue() ?? false;
        if (!field.type.isDartCoreInt) {
          autoincrement = false;
        }
      } else {
        columnAnnotation =
            _columnChecker.firstAnnotationOf(field, throwOnUnresolved: false);
      }
      if (columnAnnotation == null) {
        continue;
      }
      final fieldType = field.type.getDisplayString(withNullability: true);
      final columnName = columnAnnotation.getField('name')?.toStringValue() ??
          field.displayName;
      if (autoincrement) {
        columns.add(TableColumn.autoincrement(
            field.displayName, fieldType, columnName));
      } else {
        final defaultValue =
            fc.parseValueObject(columnAnnotation.getField('defaultValue'));
        final isUnique =
            columnAnnotation.getField('unique')?.toBoolValue() ?? false;
        if (isUnique) {
          columns.add(TableColumn.unique(field.displayName, fieldType,
              columnName, _getColumnType(field.type)));
        } else {
          final isIndexable =
              columnAnnotation.getField('indexable')?.toBoolValue() ?? false;
          if (isIndexable) {
            columnIndexes.add(columnName);
          }
          String? constraint;
          if (field.type.nullabilitySuffix != NullabilitySuffix.question) {
            constraint ??= '';
            constraint += 'NOT NULL';
          }
          if (defaultValue != null) {
            constraint ??= '';
            constraint += 'DEFAULT(${defaultValue})';
          }
          columns.add(TableColumn(
              fieldName: field.displayName,
              fieldType: fieldType,
              columnName: columnName,
              columnType: _getColumnType(field.type),
              constraint: constraint));
        }
      }
    }

    final primaryKeys =
        reader.peek('primaryKeys')?.listValue.map((e) => e.toStringValue()!);
    if (primaryKeys != null && primaryKeys.isNotEmpty) {
      this.primaryKeys.addAll(primaryKeys);
    }
    final uniqueKeys = reader.peek('uniqueKeys')?.setValue ?? {};
    for (var key in uniqueKeys) {
      final keys = key.toListValue()?.map((e) => "'${e.toStringValue()}'");
      if (keys != null && keys.isNotEmpty) {
        this.uniqueKeys.add(keys);
      }
    }
  }

  String _getColumnType(DartType type) {
    if (type.isDartCoreInt || type.isDartCoreBool) {
      return 'INTEGER';
    } else if (type.isDartCoreDouble || type.isDartCoreNum) {
      return 'REAL';
    } else {
      final columnType = type.getDisplayString(withNullability: false);
      if (columnType == 'Uint8List') {
        return 'BLOB';
      }
    }
    return 'TEXT';
  }
}

class TableColumn {
  final String fieldName;
  final String fieldType;
  final String columnName;
  final String columnType;
  final String? constraint;
  final bool isPrimaryKey;
  final bool isUniqueKey;

  bool get isNullability => fieldType.endsWith('?');

  String get sql =>
      '$columnName $columnType${constraint != null ? ' $constraint' : ''}';

  TableColumn(
      {required this.fieldName,
      required this.fieldType,
      required this.columnName,
      required this.columnType,
      this.constraint,
      this.isPrimaryKey = false,
      this.isUniqueKey = false});

  factory TableColumn.autoincrement(
          String fieldName, String fieldType, String columnName) =>
      TableColumn(
          fieldName: fieldName,
          fieldType: fieldType,
          columnName: columnName,
          columnType: 'INTEGER',
          constraint: 'PRIMARY KEY AUTOINCREMENT',
          isPrimaryKey: true);

  factory TableColumn.unique(String fieldName, String fieldType,
          String columnName, String columnType) =>
      TableColumn(
          fieldName: fieldName,
          fieldType: fieldType,
          columnName: columnName,
          columnType: columnType,
          constraint: 'UNIQUE',
          isUniqueKey: true);
}
