import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_annotation_sqlite/flutter_annotation_sqlite.dart';
import 'package:flutter_annotation_common/flutter_annotation_common.dart' as fc;
import 'package:source_gen/source_gen.dart';
import 'package:collection/collection.dart';
import 'entity_collector.dart';

class RepositoryCollector {
  final _sqlitePrefix = 'sqflite';
  final _entityChecker = TypeChecker.fromRuntime(Entity);
  final _queryChecker = TypeChecker.fromRuntime(Query);
  final _insertChecker = TypeChecker.fromRuntime(Insert);
  final _updateChecker = TypeChecker.fromRuntime(Update);
  final _deleteChecker = TypeChecker.fromRuntime(Delete);
  final _collector = EntityCollector();
  late String _entityClassName;

  String collect(
      String fileName, ClassElement element, ConstantReader annotation) {
    final emitter = DartEmitter();
    final formatter = DartFormatter();
    final entity = annotation.read('entity').typeValue.element as ClassElement;
    final entityAnnotation =
        _entityChecker.firstAnnotationOf(entity, throwOnUnresolved: false);
    _entityClassName = entity.displayName;
    _collector.collect(entity, ConstantReader(entityAnnotation));
    final coderElement = annotation.peek('coder')?.typeValue.element;
    final cls = Class((cb) {
      cb.name = '_\$${element.displayName}';
      cb.extend = refer(element.displayName);
      // _database
      cb.fields.add(Field((fb) {
        fb.modifier = FieldModifier.final$;
        fb.type = refer('$_sqlitePrefix.Database');
        fb.name = '_database';
      }));
      // _table
      cb.fields.add(Field((fb) {
        fb.modifier = FieldModifier.final$;
        fb.type = refer('String');
        fb.name = '_table';
        fb.assignment = Code("'${_collector.table}'");
      }));
      // _coder
      cb.fields.add(Field((fb) {
        fb.modifier = FieldModifier.final$;
        fb.type = refer('FieldCoder?');
        fb.name = '_coder';
        // fb.late = true;
      }));
      cb.constructors.add(Constructor((ctb) {
        ctb.requiredParameters.add(Parameter((pb) {
          pb.name = '_database';
          pb.toThis = true;
        }));
        ctb.initializers.add(Code(
            "_coder=${coderElement == null ? 'null' : '${coderElement.displayName}()'}"));
        ctb.body = Code(
            "if (_coder != null) {FieldCoderRegistry.register('${_entityClassName}', _coder!);}");
      }));
      for (var method in element.methods) {
        DartObject? methodAnnotation =
            _queryChecker.firstAnnotationOf(method, throwOnUnresolved: false);
        if (methodAnnotation != null) {
          cb.methods.add(_addQueryMethod(method, methodAnnotation));
          continue;
        }
        methodAnnotation =
            _insertChecker.firstAnnotationOf(method, throwOnUnresolved: false);
        if (methodAnnotation != null) {
          cb.methods.add(_addInsertMethod(method, methodAnnotation));
          continue;
        }
        methodAnnotation =
            _updateChecker.firstAnnotationOf(method, throwOnUnresolved: false);
        if (methodAnnotation != null) {
          cb.methods.add(_addUpdateMethod(method, methodAnnotation));
          continue;
        }
        methodAnnotation =
            _deleteChecker.firstAnnotationOf(method, throwOnUnresolved: false);
        if (methodAnnotation != null) {
          cb.methods.add(_addDeleteMethod(method, methodAnnotation));
          continue;
        }
      }
      // _geEntityColumnInfo
      cb.methods.add(Method((mb) {
        mb.returns = refer('Map<String, Map<String, String>>');
        mb.name = '_geEntityColumnInfo';
        StringBuffer code = StringBuffer();
        code.writeln('return {');
        for (var column in _collector.columns) {
          code.writeln(
              "'${column.columnName}': {'${column.fieldName}':'${fc.TypeSplitter.nonnullType(column.fieldType)}'},");
        }
        code.writeln('};');
        mb.body = Code(code.toString());
      }));
    });
    final lib = Library((lb) {
      lb.directives.add(Directive.partOf(fileName));
      lb.body.add(cls);
    });
    return formatter.format('${lib.accept(emitter)}');
  }

  Method _addQueryMethod(MethodElement element, DartObject annotation) {
    return Method((mb) {
      _methodBuilder(element, mb);
      final queryFields = annotation
              .getField('fields')
              ?.toListValue()
              ?.map((e) => e.toStringValue()!) ??
          [];
      final groupByFields = annotation
              .getField('groupBy')
              ?.toListValue()
              ?.map((e) => e.toStringValue()!) ??
          [];
      final havingExpr = annotation.getField('having')?.toStringValue();
      final orderFields = annotation
              .getField('orderBy')
              ?.toListValue()
              ?.map((e) => e.toMapValue()!.map((key, value) => MapEntry(
                  key?.toStringValue(),
                  value?.getField('_name')?.toStringValue()?.toUpperCase())))
              .where((e) => e.isNotEmpty) ??
          [];
      bool hasPage = false;
      final parameters = element.parameters.where((e) {
        if (e.name == 'page' || e.name == 'limit') {
          hasPage = true;
          return false;
        }
        return true;
      }).toList();
      StringBuffer executeCode = StringBuffer();
      executeCode.write('final rows = await _database.query(_table');
      if (queryFields.isNotEmpty) {
        List<String> queryColumns = [];
        for (var column in queryFields) {
          final columnName = _collector.columns
              .firstWhereOrNull((e) => e.fieldName == column)
              ?.columnName;
          if (columnName != null) {
            queryColumns.add("'$columnName'");
          }
        }
        executeCode.write(', columns: [${queryColumns.join(',')}]');
      }
      if (parameters.isNotEmpty) {
        executeCode.write(
            ", where: whereString.isNotEmpty ? whereString.join(' ') : null");
        executeCode.write(', whereArgs: whereArgs');
      }
      if (groupByFields.isNotEmpty) {
        List<String> groupByColumns = [];
        for (var groupBy in groupByFields) {
          final columnName = _collector.columns
              .firstWhereOrNull((e) => e.fieldName == groupBy)
              ?.columnName;
          if (columnName != null) {
            groupByColumns.add(columnName);
          }
        }
        if (groupByColumns.isNotEmpty) {
          executeCode.write(", groupBy:'${groupByColumns.join(',')}'");
          if (havingExpr != null) {
            executeCode.write(", having: '$havingExpr'");
          }
        }
      }
      if (orderFields.isNotEmpty) {
        List<String> orderByExpr = [];
        for (var orderBy in orderFields) {
          final columnName = _collector.columns
              .firstWhereOrNull((e) => e.fieldName == orderBy.keys.first)
              ?.columnName;
          if (columnName != null) {
            orderByExpr.add('$columnName ${orderBy.values.first}');
          }
        }
        if (orderByExpr.isNotEmpty) {
          executeCode.write(", orderBy:'${orderByExpr.join(',')}'");
        }
      }
      if (hasPage) {
        executeCode.writeln(', limit: limit, offset: (page - 1) * limit');
      }
      executeCode.write(');');
      StringBuffer stmt = StringBuffer();
      if (hasPage) {
        stmt.write('assert(limit > 0 && page > 0);');
      }
      stmt.write(_getParameterBody(parameters));
      stmt.writeln(executeCode.toString());
      // =Future<type>
      String returnType =
          element.returnType.getDisplayString(withNullability: true);
      // =type or type?
      returnType = fc.TypeSplitter.genericType(returnType) ?? returnType;
      final isNullability = returnType.endsWith('?');
      // =type
      final nonnullReturnType = fc.TypeSplitter.nonnullType(returnType);
      final throwEmptyError =
          "if (rows.isEmpty) {${isNullability ? 'return null' : 'throw StateError(\'The result set is empty.\')'};}";
      if (nonnullReturnType == 'List<$_entityClassName>') {
        stmt.writeln(_getThrowDecoderError(_entityClassName));
        stmt.writeln('final columnMap = _geEntityColumnInfo();');
        stmt.writeln('return rows.map((e) {');
        stmt.writeln(_mapToEntity('e', _entityClassName));
        stmt.writeln('}).toList();');
      } else if (nonnullReturnType == _entityClassName) {
        stmt.writeln(throwEmptyError);
        stmt.writeln(
            "else if (rows.length > 1) {throw StateError('Too many results are returned.');}");
        stmt.writeln(_getThrowDecoderError(_entityClassName));
        stmt.writeln('final columnMap = _geEntityColumnInfo();');
        stmt.writeln(_mapToEntity('rows.first', returnType));
      } else if (fc.TypeChecker.isListType(nonnullReturnType)) {
        final genericType =
            fc.TypeSplitter.genericType(nonnullReturnType) ?? nonnullReturnType;
        final isNullabilityGenericType = genericType.endsWith('?');
        final nonnullGenericType = fc.TypeSplitter.nonnullType(genericType);
        final isMapType = fc.TypeChecker.isMapType(nonnullGenericType);
        final isBasicGenericType = _isBasicType(nonnullGenericType);
        if (!isBasicGenericType && !isMapType) {
          stmt.writeln(_getThrowDecoderError(nonnullGenericType));
        }
        stmt.write('return rows.map((e) {');
        if (isMapType) {
          if (queryFields.isEmpty) {
            stmt.writeln('return $nonnullGenericType.from(e);');
          } else {
            stmt.writeln('$nonnullGenericType result = {};');
            for (var fieldName in queryFields) {
              final column = _collector.columns
                  .firstWhereOrNull((e) => e.fieldName == fieldName)!;
              stmt.writeln("if (e['${column.columnName}'] != null) {");
              if (_isBasicType(column.fieldType)) {
                stmt.write("result['$fieldName'] = e['${column.columnName}'];");
              } else {
                stmt.writeln(_getThrowDecoderError(
                    fc.TypeSplitter.nonnullType(column.fieldType)));
                stmt.write(
                    "result['$fieldName'] = decoder.decode(e['${column.columnName}']!);");
              }
              stmt.writeln('}');
            }
            stmt.writeln('return result;');
          }
        } else {
          final columnName = _collector.columns
              .firstWhereOrNull((e) => e.fieldName == queryFields.first)
              ?.columnName;
          if (!isBasicGenericType) {
            stmt.writeln("final ${columnName} = e['${columnName}'];");
            stmt.writeln(
                "if (${columnName} == null) {${isNullabilityGenericType ? 'return null' : 'throw StateError(\'The column `${columnName}` returned null.\')'};}");
          }
          stmt.write('return ');
          if (!isBasicGenericType) {
            stmt.write('decoder.decode(${columnName})');
          } else {
            stmt.write("e['${columnName}']");
          }
          stmt.write(' as $genericType;');
        }
        stmt.write('}).toList();');
      } else if (fc.TypeChecker.isMapType(nonnullReturnType)) {
        stmt.writeln(throwEmptyError);
        if (queryFields.isEmpty) {
          stmt.writeln('return $nonnullReturnType.from(rows.first);');
        } else {
          stmt.writeln('final rs = rows.first;');
          stmt.writeln('$nonnullReturnType result = {};');
          for (var fieldName in queryFields) {
            final column = _collector.columns
                .firstWhereOrNull((e) => e.fieldName == fieldName)!;
            stmt.writeln("if (rs['${column.columnName}'] != null) {");
            if (_isBasicType(column.fieldType)) {
              stmt.write("result['$fieldName'] = rs['${column.columnName}'];");
            } else {
              stmt.writeln(_getThrowDecoderError(
                  fc.TypeSplitter.nonnullType(column.fieldType)));
              stmt.write(
                  "result['$fieldName'] = decoder.decode(rs['${column.columnName}']!);");
            }
            stmt.writeln('}');
          }
          stmt.writeln('return result;');
        }
      } else if (queryFields.isNotEmpty) {
        final columnName = _collector.columns
            .firstWhereOrNull((e) => e.fieldName == queryFields.first)
            ?.columnName;
        stmt.writeln(throwEmptyError);
        final isBasicType = _isBasicType(nonnullReturnType);
        if (!isBasicType) {
          stmt.writeln(_getThrowDecoderError(nonnullReturnType));
          stmt.writeln("final ${columnName} = rows.first['${columnName}'];");
          stmt.writeln(
              'if (${columnName} == null) {${isNullability ? 'return null' : 'throw StateError(\'The column `${columnName}` returned null.\')'};}');
        }
        stmt.write('return ');
        if (!isBasicType) {
          stmt.write('decoder.decode($columnName)');
        } else {
          stmt.write("rows.first['${columnName}']");
        }
        stmt.write(' as $returnType;');
      } else {
        stmt.writeln("throw UnsupportedError('Unknown type: `$returnType`');");
      }
      mb.body = Code(stmt.toString());
    });
  }

  Method _addInsertMethod(MethodElement element, DartObject annotation) {
    return Method((mb) {
      _methodBuilder(element, mb);
      final conflict =
          annotation.getField('conflict')?.getField('_name')?.toStringValue();
      final updateEntity =
          element.parameters.firstWhereOrNull((e) => e.name == 'entity');
      if (updateEntity == null) {
        throw ArgumentError('The insert parameter `entity` cannot be empty.');
      }
      StringBuffer executeCode = StringBuffer();
      executeCode.write('await _database.insert(_table, values');
      if (conflict != null) {
        executeCode.write(
            ', conflictAlgorithm: $_sqlitePrefix.ConflictAlgorithm.$conflict');
      }
      executeCode.write(');');
      StringBuffer stmt = StringBuffer();
      stmt.write(_entityToMap(updateEntity));
      stmt.writeln(_getReturnBody(
          element.returnType.getDisplayString(withNullability: true),
          executeCode.toString()));
      mb.body = Code(stmt.toString());
    });
  }

  Method _addUpdateMethod(MethodElement element, DartObject annotation) {
    return Method((mb) {
      _methodBuilder(element, mb);
      final conflict =
          annotation.getField('conflict')?.getField('_name')?.toStringValue();
      final updateEntity =
          element.parameters.firstWhereOrNull((e) => e.name == 'entity');
      if (updateEntity == null) {
        throw ArgumentError('The update parameter `entity` cannot be empty.');
      }
      final parameters =
          element.parameters.where((e) => e != updateEntity).toList();
      StringBuffer executeCode = StringBuffer();
      executeCode.write('await _database.update(_table, values');
      if (parameters.isNotEmpty) {
        executeCode.write(
            ", where: whereString.isNotEmpty ? whereString.join(' ') : null");
        executeCode.write(', whereArgs: whereArgs');
      }
      if (conflict != null) {
        executeCode.write(
            ', conflictAlgorithm: $_sqlitePrefix.ConflictAlgorithm.$conflict');
      }
      executeCode.write(');');
      StringBuffer stmt = StringBuffer();
      stmt.write(_entityToMap(updateEntity,
          isUpdate: true,
          ignoreNull:
              annotation.getField('ignoreNull')?.toBoolValue() ?? false));
      stmt.write(_getParameterBody(parameters));
      stmt.writeln(_getReturnBody(
          element.returnType.getDisplayString(withNullability: true),
          executeCode.toString()));
      mb.body = Code(stmt.toString());
    });
  }

  Method _addDeleteMethod(MethodElement element, DartObject annotation) {
    return Method((mb) {
      _methodBuilder(element, mb);
      StringBuffer executeCode = StringBuffer();
      executeCode.write('await _database.delete(_table');
      if (element.parameters.isNotEmpty) {
        executeCode.write(
            ", where: whereString.isNotEmpty ? whereString.join(' ') : null");
        executeCode.write(', whereArgs: whereArgs');
      }
      executeCode.write(');');
      StringBuffer stmt = StringBuffer();
      stmt.write(_getParameterBody(element.parameters));
      stmt.writeln(_getReturnBody(
          element.returnType.getDisplayString(withNullability: true),
          executeCode.toString()));
      mb.body = Code(stmt.toString());
    });
  }

  void _methodBuilder(MethodElement element, MethodBuilder mb) {
    mb.annotations.add(refer('override'));
    mb.returns =
        refer(element.returnType.getDisplayString(withNullability: true));
    mb.name = element.displayName;
    mb.modifier = MethodModifier.async;
    for (var parameter in element.parameters) {
      final param = Parameter((pb) {
        pb.type = refer(parameter.type.getDisplayString(withNullability: true));
        pb.name = parameter.displayName;
        pb.named = parameter.isNamed;
        if (parameter.defaultValueCode != null) {
          pb.defaultTo = Code(parameter.defaultValueCode!);
        }
      });
      if (parameter.isRequired) {
        mb.requiredParameters.add(param);
      } else if (parameter.isOptional) {
        mb.optionalParameters.add(param);
      }
    }
  }

  String _getParameterBody(List<ParameterElement> parameters) {
    StringBuffer stmt = StringBuffer();
    if (parameters.isNotEmpty) {
      stmt.writeln('List<Object?> whereArgs =[];');
      stmt.writeln('List<String> whereString=[];');
      for (var parameter in parameters) {
        final isNullability =
            parameter.type.nullabilitySuffix == NullabilitySuffix.question;
        if (isNullability) {
          stmt.writeln('if (${parameter.name} != null) {');
        }
        String key = parameter.name;
        if (parameter != parameters.first) {
          bool isOrExpr = key.startsWith('or');
          bool isAndExpr = key.startsWith('and');
          stmt.writeln("whereString.add('${isOrExpr ? 'OR' : 'AND'}');");
          if (isOrExpr) {
            key = key.substring(2);
          } else if (isAndExpr) {
            key = key.substring(3);
          }
        }
        bool isGtEqExpr = false,
            isLtEqExpr = false,
            isGtExpr = false,
            isLtExpr = false;
        bool isLikeExpr = key.startsWith('Like') || key.startsWith('like');
        if (!isLikeExpr) {
          isGtEqExpr = key.startsWith('Gte') || key.startsWith('gte');
          if (!isGtEqExpr) {
            isLtEqExpr = key.startsWith('Lte') || key.startsWith('lte');
            if (!isLtEqExpr) {
              isGtExpr = key.startsWith('Gt') || key.startsWith('gt');
              if (!isGtExpr) {
                isLtExpr = key.startsWith('Lt') || key.startsWith('lt');
              }
            }
          }
        }
        if (isLikeExpr) {
          key = key.substring(4);
        } else if (isGtEqExpr || isLtEqExpr) {
          key = key.substring(3);
        } else if (isGtExpr || isLtExpr) {
          key = key.substring(2);
        }
        key = _toCamelStyle(key);
        String operation;
        if (isGtExpr) {
          operation = '>';
        } else if (isGtEqExpr) {
          operation = '>=';
        } else if (isLtExpr) {
          operation = '<';
        } else if (isLtEqExpr) {
          operation = '<=';
        } else if (isLikeExpr) {
          operation = ' LIKE ';
        } else {
          operation = '=';
        }
        final columnName = _collector.columns
            .firstWhereOrNull((e) => e.fieldName == key)
            ?.columnName;
        if (columnName != null) {
          stmt.writeln("whereString.add('$columnName$operation?');");
          if (isLikeExpr) {
            stmt.writeln("whereArgs.add('\$${parameter.name}%');");
          } else {
            stmt.writeln('whereArgs.add(${parameter.name});');
          }
        }
        if (isNullability) {
          stmt.writeln('}');
        }
      }
    }
    return stmt.toString();
  }

  String _getReturnBody(String returnType, String executeCode) {
    returnType = fc.TypeSplitter.genericType(returnType) ?? returnType;
    returnType = fc.TypeSplitter.nonnullType(returnType);
    if (returnType == 'int') {
      return 'return $executeCode';
    } else if (returnType == 'bool') {
      return 'final result = $executeCode\nreturn result > 0;';
    }
    return executeCode;
  }

  String _entityToMap(ParameterElement element,
      {bool isUpdate = false, bool ignoreNull = false}) {
    final entityElement = element.type.element as ClassElement;
    final updateAnnotation = _entityChecker.firstAnnotationOf(entityElement,
        throwOnUnresolved: false);
    final updateCollector = EntityCollector();
    updateCollector.collect(entityElement, ConstantReader(updateAnnotation));
    StringBuffer stmt = StringBuffer();
    stmt.writeln(' Map<String, Object?> values = {');
    for (var column in _collector.columns) {
      if (!column.isPrimaryKey && (!isUpdate || !column.isUniqueKey)) {
        stmt.write("'${column.columnName}': ");
        final key = 'entity.${column.fieldName}';
        String dataType = fc.TypeSplitter.nonnullType(column.fieldType);
        if (column.isNullability && !_isBasicType(dataType)) {
          stmt.write('$key == null ? null:');
        }
        if (fc.TypeChecker.isListType(dataType)) {
          dataType = 'List';
        } else if (fc.TypeChecker.isMapType(dataType)) {
          dataType = 'Map';
        } else if (fc.TypeChecker.isSetType(dataType)) {
          dataType = 'Set';
        }
        if (_isBasicType(dataType)) {
          stmt.write('$key');
        } else if (dataType == 'num') {
          stmt.write('$key${column.isNullability ? '?' : ''}.toDouble()');
        } else {
          stmt.write("FieldCoderRegistry.get('$dataType')?.encode($key)");
        }
        stmt.write(',');
      }
    }
    stmt.writeln('};');
    if (ignoreNull) {
      stmt.writeln('values.removeWhere((key, value) => value == null);');
    }
    return stmt.toString();
  }

  String _toCamelStyle(String key) =>
      '${key.substring(0, 1).toLowerCase()}${key.substring(1)}';

  String _getThrowDecoderError(String type) {
    final coderExpr = type == _entityClassName ? '_coder' : "FieldCoderRegistry.get('$type')";
    return """
    final decoder = ${coderExpr};
    if (decoder == null) {
      throw StateError('No decoder of type `$type` found.');
    }""";
  }

  bool _isBasicType(String type) {
    return type == 'int' || type == 'double' || type == 'String';
  }

  String _mapToEntity(String key, String entityType) {
    return """
    final fieldMap = $key.map((key, value) {
      final fieldInfo = columnMap[key]!;
      final fk = fieldInfo.keys.first;
      final ft = fieldInfo.values.first;
      if (ft == 'int' || ft == 'double' || ft == 'String' || value == null) {
        return MapEntry(fk, value);
      }
      final fieldDecoder = FieldCoderRegistry.get(ft);
      if (fieldDecoder == null) {
        throw StateError('No decoder of type `\$ft` found.');
      }
      return MapEntry(fk, fieldDecoder.decode(value));
    });
    return decoder.decode(fieldMap) as $entityType;""";
  }
}
