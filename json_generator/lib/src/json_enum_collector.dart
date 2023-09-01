import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_annotation_json/flutter_annotation_json.dart' show EnumValue;
import 'package:source_gen/source_gen.dart';
import 'package:code_builder/code_builder.dart' hide EnumValue;
import 'package:dart_style/dart_style.dart';

class JsonEnumCollector {
  static const String _enumMapPrefix = '_\$';
  static const String _enumMapSuffix = 'EnumData';
  static final Set<String> _partFiles = <String>{};

  final String fileName;

  const JsonEnumCollector(this.fileName);

  String collect(EnumElement element, ConstantReader annotation) {
    final enumName = element.displayName;
    final enumDataName = '$_enumMapPrefix$enumName$_enumMapSuffix';
    final emitter = DartEmitter();
    final formatter = DartFormatter();
    const enumValueChecker = TypeChecker.fromRuntime(EnumValue);
    final defaultValueObject = annotation.peek('defaultValue');
    final lib = Library((builder) {
      if (!_partFiles.contains(fileName)) {
        builder.directives.add(Directive.partOf(fileName));
        _partFiles.add(fileName);
      }
      builder.body.add(Field((fb) {
        fb.modifier = FieldModifier.constant;
        fb.name = enumDataName;
        StringBuffer code = StringBuffer('{');
        for (var field in element.fields) {
          if (field.name == 'name' ||
              field.name == 'index' ||
              field.name == 'values') {
            continue;
          }
          final enumAnnotation = enumValueChecker.firstAnnotationOf(field);
          if (enumAnnotation == null) {
            continue;
          }
          final enumFieldType = '$enumName.${field.name}';
          DartObject valueObject = enumAnnotation.getField('value')!;
          final valueType = valueObject.type!;
          if (valueType.isDartCoreString) {
            code.writeln("'${valueObject.toStringValue()}':$enumFieldType,");
          } else if (valueType.isDartCoreInt) {
            code.writeln("${valueObject.toIntValue()}:$enumFieldType,");
          }
        }
        code.writeln('}');
        fb.assignment = Code(code.toString());
      }));
      // _$parseXXX
      builder.body.add(Method((mb) {
        dynamic defaultValue;
        if (defaultValueObject != null) {
          if (defaultValueObject.isInt) {
            defaultValue = defaultValueObject.intValue;
          } else if (defaultValueObject.isString) {
            defaultValue = defaultValueObject.stringValue;
          }
        }
        mb.returns = refer('$enumName${defaultValue == null ? '?' : ''}');
        mb.name = '${_enumMapPrefix}parse$enumName';
        mb.requiredParameters.add(Parameter((pb) {
          pb.name = 'value';
          pb.type = refer('dynamic');
        }));
        if (defaultValue != null) {
          mb.optionalParameters.add(Parameter((pb) {
            pb.name = 'defaultValue';
            pb.type = refer(defaultValueObject!.isInt ? 'int' : 'String');
            pb.named = true;
            pb.defaultTo = Code(
                defaultValueObject.isInt ? defaultValue : "'$defaultValue'");
          }));
        }
        mb.body = Code("""
        assert(value is String || value is int);
        return $enumDataName[value]${defaultValue != null ? ' ?? $enumDataName[defaultValue]!' : ''};
        """);
      }));
      builder.body.add(Method((mb){
        mb.returns = refer('dynamic');
        mb.name = '${_enumMapPrefix}getValueFor$enumName';
        mb.requiredParameters.add(Parameter((pb){
          pb.type = refer(enumName);
          pb.name = 'that';
        }));
        mb.body = Code("""
        for (dynamic key in $enumDataName.keys) {
        if ($enumDataName[key] == that) {
          return key;
        }
      }
      return null;""");
      }));
    });
    return formatter.format('${lib.accept(emitter)}');
  }
}
