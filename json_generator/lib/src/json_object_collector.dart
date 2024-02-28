import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_annotation_common/flutter_annotation_common.dart';
import 'package:source_gen/source_gen.dart' hide TypeChecker;
import 'json_field_collector.dart';

class JsonObjectCollector {
  static const String _prefix = '_\$';
  static final Set<String> _partFiles = <String>{};

  final String fileName;
  final String? jsonKey;
  late final JsonFieldCollector _fieldCollector;

  JsonObjectCollector(this.fileName, this.jsonKey);

  String collect(ClassElement element, ConstantReader annotation) {
    final emitter = DartEmitter();
    final formatter = DartFormatter();
    final className = element.displayName;
    bool enableToJsonMethod = false;
    bool enableCopyWithMethod = false;
    bool enableToJsonStringMethod = false;
    for (var method in element.methods) {
      if (method.displayName == 'toJson') {
        enableToJsonMethod = true;
      } else if (method.displayName == 'copyWith') {
        enableCopyWithMethod = true;
      } else if (method.displayName == 'toJsonString') {
        enableToJsonStringMethod = true;
      }
    }
    _fieldCollector = JsonFieldCollector(
        annotation.peek('underScoreCase')?.boolValue ?? false);
    _fieldCollector.collect(element, annotation);
    final lib = Library((lb) {
      if (!_partFiles.contains(fileName)) {
        lb.directives.add(Directive.partOf(fileName));
        _partFiles.add(fileName);
      }
      final fromJsonMethodName = '$_prefix${className}FromJson';
      final rootJsonKey = annotation.peek('jsonKey')?.stringValue ?? jsonKey;
      if (rootJsonKey != null) {
        lb.body.add(Method((mb) {
          mb.returns = refer(className);
          mb.name = '$_prefix${className}FromJsonByJsonKey';
          mb.requiredParameters.add(_jsonParameter);
          mb.lambda = true;
          mb.body = Code(
              "$fromJsonMethodName(DecodeHelper.visitMapValue('$rootJsonKey',json,defaultValue:{}))");
        }));
      }
      lb.body.add(Method(
          (mb) => _fromJson(mb, fromJsonMethodName, className, annotation)));
      if (enableToJsonMethod || enableToJsonStringMethod) {
        final outputNull = annotation.read('outputNull').boolValue;
        lb.body.add(Method((mb) => _toJson(mb, className, outputNull)));
      }
      if (enableToJsonStringMethod) {
        lb.body.add(Method((mb) => _toJsonString(mb, className)));
      }
      if (enableCopyWithMethod) {
        lb.body.add(Method((mb) => _copyWith(mb, className)));
      }
    });
    return formatter.format('${lib.accept(emitter)}');
  }

  void _fromJson(MethodBuilder builder, String methodName, String className,
      ConstantReader annotation) {
    builder.returns = refer(className);
    builder.name = methodName;
    builder.requiredParameters.add(_jsonParameter);
    builder.lambda = true;
    StringBuffer code = StringBuffer('$className(');
    for (var field in _fieldCollector.fields) {
      String valueConvertText;
      if (field.decoder != null) {
        valueConvertText = "${field.decoder}.call(json['${field.jsonKey}'])";
      } else if (field.typeName == 'String') {
        valueConvertText = "json['${field.jsonKey}']?.toString()";
        if (!field.hasNullSuffix) {
          valueConvertText += " ?? ${field.defaultValue ?? '\'\''}";
        }
      } else if (field.typeName == 'int') {
        if (!field.hasNullSuffix) {
          valueConvertText =
              "DecodeHelper.toInt(json['${field.jsonKey}'], ${field.defaultValue ?? 0})";
        } else {
          valueConvertText =
              "DecodeHelper.tryToInt(json['${field.jsonKey}'])";
        }
      } else if (field.typeName == 'double') {
        if (!field.hasNullSuffix) {
          valueConvertText =
              "DecodeHelper.toDouble(json['${field.jsonKey}'], ${field.defaultValue ?? 0.0})";
        } else {
          valueConvertText =
              "DecodeHelper.tryToDouble(json['${field.jsonKey}'])";
        }
      } else if (field.typeName == 'num') {
        if (!field.hasNullSuffix) {
          valueConvertText =
              "DecodeHelper.toNum(json['${field.jsonKey}'], ${field.defaultValue ?? 0.0})";
        } else {
          valueConvertText =
              "DecodeHelper.tryToNum(json['${field.jsonKey}'])";
        }
      } else if (field.typeName == 'bool') {
        if (!field.hasNullSuffix) {
          valueConvertText =
              "DecodeHelper.toBool(json['${field.jsonKey}'], ${field.defaultValue ?? false})";
        } else {
          valueConvertText =
              "DecodeHelper.tryToBool(json['${field.jsonKey}'])";
        }
      } else if (field.typeName == 'DateTime') {
        String parseDateTime =
            "DecodeHelper.toDateTime(json['${field.jsonKey}'])";
        valueConvertText = field.hasNullSuffix
            ? "json['${field.jsonKey}'] != null ? $parseDateTime : null"
            : parseDateTime;
      } else if (TypeChecker.isListType(field.typeName)) {
        String parseList;
        if (field.genericType == 'DateTime') {
          parseList =
              "DecodeHelper.toList(json['${field.jsonKey}']).map((e) => DecodeHelper.toDateTime(e)).toList()";
        } else if (TypeChecker.isCustomClass(field.genericType!)) {
          parseList =
              "DecodeHelper.toList<Map>(json['${field.jsonKey}']).map((e) => ${field.genericType}.fromJson(Map<String, dynamic>.from(e))).toList()";
        } else {
          parseList =
              "DecodeHelper.toList<${field.genericType}>(json['${field.jsonKey}'])";
        }
        valueConvertText = field.hasNullSuffix
            ? "json['${field.jsonKey}'] != null ? $parseList : null"
            : parseList;
      } else if (TypeChecker.isMapType(field.typeName)) {
        String parseMap;
        if (field.genericValueType == 'DateTime') {
          parseMap =
              "DecodeHelper.toMap<${field.genericKeyType}, dynamic>(json['${field.jsonKey}']).map((key, value) => MapEntry(key, DecodeHelper.toDateTime(value)))";
        } else if (TypeChecker.isCustomClass(field.genericValueType!)) {
          parseMap =
              "DecodeHelper.toMap<${field.genericKeyType}, dynamic>(json['${field.jsonKey}']).map((key, value) => MapEntry(key, ${field.genericValueType}.fromJson(Map<String, dynamic>.from(value))))";
        } else {
          parseMap =
              "DecodeHelper.toMap<${field.genericType}>(json['${field.jsonKey}'])";
        }
        valueConvertText = field.hasNullSuffix
            ? "json['${field.jsonKey}'] != null ? $parseMap : null"
            : parseMap;
      } else if (field.isEnum) {
        String parseEnum =
            _convertEnumSetter(field, "json['${field.jsonKey}']");
        valueConvertText = field.hasNullSuffix
            ? "json['${field.jsonKey}'] != null ? $parseEnum : null"
            : parseEnum;
      } else if (field.isCustomClass) {
        String parseCustomClass =
            "${field.typeName}.fromJson(DecodeHelper.toMap<String, dynamic>(json['${field.jsonKey}']))";
        valueConvertText = field.hasNullSuffix
            ? "json['${field.jsonKey}'] != null ? $parseCustomClass : null"
            : parseCustomClass;
      } else {
        valueConvertText = "json['${field.jsonKey}']";
      }
      code.writeln("${field.fieldName}: $valueConvertText,");
    }
    code.writeln(')');
    builder.body = Code(code.toString());
  }

  void _toJson(MethodBuilder builder, String className, bool outputNull) {
    builder.returns = refer('Map<String, dynamic>');
    builder.name = '_\$${className}ToJson';
    builder.requiredParameters.add(Parameter((pb) {
      pb.name = 'that';
      pb.type = refer(className);
    }));
    builder.lambda = true;
    StringBuffer code = StringBuffer('{');
    for (var field in _fieldCollector.fields) {
      String key = "'${field.jsonKey}'";
      String value = "that.${field.fieldName}";
      String valueSuffix = field.hasNullSuffix ? '?' : '';
      if (field.hasNullSuffix && !outputNull) {
        code.write('if ($value != null)');
      }
      if (field.encoder != null) {
        code.writeln("$key: ${field.encoder}.call($value),");
      } else if (field.typeName == 'DateTime') {
        code.writeln("$key: $value$valueSuffix.millisecondsSinceEpoch,");
      } else if (TypeChecker.isListType(field.typeName)) {
        if (field.genericType == 'DateTime') {
          code.writeln(
              "$key: $value$valueSuffix.map((e) => e.millisecondsSinceEpoch).toList(),");
        } else if (TypeChecker.isCustomClass(field.genericType!)) {
          code.writeln(
              "$key: $value$valueSuffix.map((e) => e.toJson()).toList(),");
        } else {
          code.writeln("$key: $value,");
        }
      } else if (TypeChecker.isMapType(field.typeName)) {
        if (field.genericValueType == 'DateTime') {
          code.writeln(
              "$key: $value$valueSuffix.map((key, value) => MapEntry(key, value.millisecondsSinceEpoch)),");
        } else if (TypeChecker.isCustomClass(field.genericValueType!)) {
          code.writeln(
              "$key: $value$valueSuffix.map((key, value) => MapEntry(key, value.toJson())),");
        } else {
          code.writeln("$key: $value,");
        }
      } else if (field.isEnum) {
        code.writeln("$key: $value$valueSuffix.value,");
      } else if (field.isCustomClass) {
        code.writeln("$key: $value$valueSuffix.toJson(),");
      } else {
        code.writeln("$key: $value,");
      }
    }
    code.writeln('}');
    builder.body = Code(code.toString());
  }

  void _toJsonString(MethodBuilder builder, String className) {
    builder.returns = refer('String');
    builder.name = '_\$${className}ToJsonString';
    builder.requiredParameters.add(Parameter((pb) {
      pb.name = 'that';
      pb.type = refer(className);
    }));
    builder.lambda = true;
    builder.body = Code("json.encode(_\$${className}ToJson(that))");
  }

  void _copyWith(MethodBuilder builder, String className) {
    builder.returns = refer(className);
    builder.name = '_\$${className}CopyWith';
    builder.requiredParameters.add(Parameter((pb) {
      pb.name = 'that';
      pb.type = refer(className);
    }));
    builder.lambda = true;
    builder.optionalParameters
        .addAll(_fieldCollector.fields.map((field) => Parameter((pb) {
              pb.type = refer('${field.typeName}?');
              pb.name = field.fieldName;
            })));
    StringBuffer code = StringBuffer("$className(");
    for (var field in _fieldCollector.fields) {
      code.writeln(
          "${field.fieldName}: ${field.fieldName} ?? that.${field.fieldName},");
    }
    code.writeln(')');
    builder.body = Code(code.toString());
  }

  String _convertEnumSetter(JsonFieldNode field, String getter,
      {String? enumType}) {
    String defaultEnum =
        "${field.defaultValue is String ? "'${field.defaultValue}'" : field.defaultValue}";
    String parseEnum;
    String typeName = enumType ?? field.genericType ?? field.typeName;
    if (field.defaultValue != null) {
      parseEnum = "_\$parse$typeName($getter, defaultValue: $defaultEnum)";
    } else {
      parseEnum = "_\$parse$typeName($getter)";
    }
    return parseEnum;
  }

  Parameter get _jsonParameter => Parameter((pb) {
        pb.type = refer('Map<String, dynamic>');
        pb.name = 'json';
      });
}
