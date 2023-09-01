import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:flutter_annotation_json/flutter_annotation_json.dart';
import 'package:flutter_annotation_common/flutter_annotation_common.dart'
    as fac;
import 'package:source_gen/source_gen.dart';

class JsonFieldNode {
  final String fieldName;
  final String fieldType;
  final String typeName;
  final String jsonKey;
  final bool hasNullSuffix;
  final dynamic defaultValue;
  final bool isCustomClass;
  final String? genericType;
  final String? genericKeyType;
  final String? genericValueType;
  final bool isEnum;
  final String? encoder;
  final String? decoder;

  JsonFieldNode(
      {required this.fieldName,
      required this.fieldType,
      required this.typeName,
      required this.jsonKey,
      required this.hasNullSuffix,
      this.defaultValue,
      required this.isCustomClass,
      this.genericType,
      this.genericKeyType,
      this.genericValueType,
      required this.isEnum,
      this.encoder,
      this.decoder});
}

class JsonFieldCollector {
  final jsonFieldChecker = const TypeChecker.fromRuntime(JsonField);
  final jsonObjectChecker = const TypeChecker.fromRuntime(JsonObject);
  final jsonEnumChecker = const TypeChecker.fromRuntime(JsonEnum);
  final Set<String> _excludeFields = {'hashCode'};
  final List<JsonFieldNode> _fields = [];
  final bool underScoreCase;

  List<JsonFieldNode> get fields => _fields;

  JsonFieldCollector(this.underScoreCase);

  void collect(ClassElement element, ConstantReader annotation) {
    ClassElement? superElement = element.supertype?.element as ClassElement?;
    while (superElement != null && !superElement.isDartCoreObject) {
      for (FieldElement field in superElement.fields) {
        _addFieldNode(field);
      }
      superElement = superElement.supertype?.element as ClassElement?;
    }
    for (FieldElement field in element.fields) {
      _addFieldNode(field);
    }
  }

  void _addFieldNode(FieldElement field) {
    String fieldName = field.displayName;
    if (field.isStatic ||
        !field.isPublic ||
        field.getter == null ||
        _excludeFields.contains(fieldName)) {
      return;
    }
    DartObject? fieldAnnotation =
        jsonFieldChecker.firstAnnotationOf(field, throwOnUnresolved: false);
    fieldAnnotation ??= jsonFieldChecker.firstAnnotationOf(field.getter!);
    if (fieldAnnotation != null) {
      bool ignore = fieldAnnotation.getField('ignore')?.toBoolValue() ?? false;
      if (ignore) {
        return;
      }
    }
    DartType fieldType = field.type;
    bool isEnum = fieldType.element?.kind == ElementKind.ENUM;
    String typeName = fieldType.getDisplayString(withNullability: false);
    String? genericType, genericKeyType, genericValueType;
    if (fac.TypeChecker.isListType(typeName)) {
      int startIndex = typeName.indexOf('<');
      int endIndex = typeName.lastIndexOf('>');
      if (startIndex != -1 && endIndex != -1) {
        genericType = typeName.substring(startIndex + 1, endIndex);
      } else {
        genericType = 'dynamic';
      }
    } else if (fac.TypeChecker.isMapType(typeName)) {
      int startIndex = typeName.indexOf('<');
      int endIndex = typeName.lastIndexOf('>');
      if (startIndex != -1 && endIndex != -1) {
        genericType = typeName.substring(startIndex + 1, endIndex);
      } else {
        genericType = 'dynamic, dynamic';
      }
      final values = genericType.split(',');
      genericKeyType = values.first.trim();
      genericValueType = values.last.trim();
    } else if (field.type.element?.kind == ElementKind.ENUM) {
      if (jsonEnumChecker.firstAnnotationOf(fieldType.element!) == null) {
        print('`$typeName` has no annotation `@JsonEnum`');
        return;
      }
    } else if (fac.TypeChecker.isCustomClass(typeName) &&
        jsonObjectChecker.firstAnnotationOf(fieldType.element!) == null) {
      print('`$typeName` has no annotation `@JsonObject`');
      return;
    }
    DartObject? defaultValueObject = fieldAnnotation?.getField('defaultValue');
    dynamic defaultValue;
    if (defaultValueObject != null) {
      if (fieldType.isDartCoreString) {
        defaultValue = defaultValueObject.toStringValue();
      } else if (fieldType.isDartCoreBool) {
        defaultValue = defaultValueObject.toBoolValue();
      } else if (fieldType.isDartCoreDouble || fieldType.isDartCoreNum) {
        defaultValue = defaultValueObject.toDoubleValue();
      } else if (fieldType.isDartCoreInt) {
        defaultValue = defaultValueObject.toIntValue();
      } else if (isEnum) {
        defaultValue = defaultValueObject.toStringValue() ??
            defaultValueObject.toIntValue();
      }
    }
    String? jsonKey = fieldAnnotation?.getField('name')?.toStringValue();
    if (jsonKey == null) {
      jsonKey = fieldName;
      if (underScoreCase) {
        // 使用下划线命名
        jsonKey = _splitUnderScoreCase(jsonKey);
      }
    }
    fields.add(JsonFieldNode(
      fieldName: fieldName,
      fieldType: fieldType.getDisplayString(withNullability: true),
      typeName: typeName,
      jsonKey: jsonKey,
      hasNullSuffix: fieldType.nullabilitySuffix == NullabilitySuffix.question,
      defaultValue: defaultValue,
      isCustomClass: fac.TypeChecker.isCustomClass(typeName),
      genericType: genericType,
      genericKeyType: genericKeyType,
      genericValueType: genericValueType,
      isEnum: isEnum,
      encoder:
          fieldAnnotation?.getField('encoder')?.toFunctionValue()?.displayName,
      decoder:
          fieldAnnotation?.getField('decoder')?.toFunctionValue()?.displayName,
    ));
  }

  String _splitUnderScoreCase(String src) {
    StringBuffer name = StringBuffer();
    for (int i = 0; i < src.length; i++) {
      final a = src[i].codeUnitAt(0);
      if (a >= 65 && a <= 90) {
        if (i > 0) {
          name.write('_');
        }
        name.write(src[i].toLowerCase());
      } else {
        name.write(src[i]);
      }
    }
    return name.toString();
  }
}
