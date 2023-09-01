import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_annotation_configure/flutter_annotation_configure.dart';
import 'package:flutter_annotation_common/flutter_annotation_common.dart'
    as fac;
import 'package:source_gen/source_gen.dart';

class ConfigCollector {
  final configFieldChecker = TypeChecker.fromRuntime(ConfigField);
  final String fileName;

  ConfigCollector(this.fileName);

  String collect(ClassElement element, ConstantReader annotation) {
    final emitter = DartEmitter();
    final formatter = DartFormatter();
    final group = annotation.peek('name')?.stringValue ?? '';
    final env = annotation.peek('env')?.stringValue;
    final version = annotation.peek('version')?.stringValue;
    const storeVarName = '_persistence';
    final cls = Class((cb) {
      cb.name = '_\$${element.displayName}Impl';
      cb.extend = refer(element.displayName);
      cb.fields.add(Field((fb){
        fb.modifier = FieldModifier.final$;
        fb.type = refer('ConfigurePersistence');
        fb.name = storeVarName;
      }));
      cb.constructors.add(Constructor((ctb){
        ctb.requiredParameters.add(Parameter((pb){
          pb.name = storeVarName;
          pb.toThis = true;
        }));
        ctb.initializers.add(Code('super()'));
      }));
      final overrideRef = refer('override');
      for (var field in element.fields) {
        if (field.isStatic ||
            !field.isPublic ||
            field.displayName == storeVarName) {
          continue;
        }
        DartObject? defaultValueObject;
        String? fieldKey, customEncoder, customDecoder;
        DartObject? fieldAnnotation = configFieldChecker
            .firstAnnotationOf(field, throwOnUnresolved: false);
        if (fieldAnnotation != null) {
          fieldKey = fieldAnnotation.getField('key')?.toStringValue();
          defaultValueObject = fieldAnnotation.getField('defaultValue');
          customEncoder =
              fieldAnnotation.getField('encoder')?.toFunctionValue()?.name;
          customDecoder =
              fieldAnnotation.getField('decoder')?.toFunctionValue()?.name;
        }
        fieldKey ??= '$group.${field.displayName}';
        if (env != null) {
          fieldKey = '$fieldKey@$env';
        }
        if (version != null) {
          fieldKey = '$fieldKey#$version';
        }
        // key field
        final fieldRefKey = '_${field.displayName}Key';
        cb.fields.add(Field((fb) {
          fb.static = true;
          fb.modifier = FieldModifier.constant;
          fb.name = fieldRefKey;
          fb.assignment = Code("'$fieldKey'");
        }));
        final isNullability =
            field.type.nullabilitySuffix == NullabilitySuffix.question;
        final fieldType = field.type.getDisplayString(withNullability: true);
        // setter
        cb.methods.add(Method((mb) {
          mb.annotations.add(overrideRef);
          mb.type = MethodType.setter;
          mb.name = field.displayName;
          mb.requiredParameters.add(Parameter((pb) {
            pb.type = refer(fieldType);
            pb.name = field.displayName;
          }));
          final setterExpr = customEncoder != null
              ? "$customEncoder.call(${field.displayName})"
              : field.displayName;
          if (!isNullability) {
            mb.body = Code("$storeVarName.put($fieldRefKey, $setterExpr);");
          } else {
            mb.body = Code("""
          if (${field.displayName} == null) {
          $storeVarName.remove($fieldRefKey);
          } else {
          $storeVarName.put($fieldRefKey, $setterExpr);
          }""");
          }
        }));
        // getter
        cb.methods.add(Method((mb) {
          mb.annotations.add(overrideRef);
          mb.type = MethodType.getter;
          mb.name = field.displayName;
          mb.returns = refer(fieldType);
          final nonnullFieldType =
              field.type.getDisplayString(withNullability: false);
          StringBuffer code =
              StringBuffer("dynamic result = $storeVarName.get($fieldRefKey);");
          if (customDecoder != null) {
            code.writeln("if (result != null) {");
            code.writeln("return $customDecoder.call(result);");
            code.writeln("}");
          } else if (fac.TypeChecker.isListType(nonnullFieldType) ||
              fac.TypeChecker.isSetType(nonnullFieldType) ||
              fac.TypeChecker.isMapType(nonnullFieldType)) {
            code.writeln("if (result != null) {");
            code.writeln("return $nonnullFieldType.from(result);");
            code.writeln("}");
          }
          code.write('return result');
          if (isNullability && defaultValueObject != null) {
            final defaultValue = fac.parseValueObject(defaultValueObject);
            if (defaultValue != null) {
              code.write(" ?? $defaultValue");
            }
          }
          code.write(';');
          mb.body = Code(code.toString());
        }));
      }
    });

    final library = Library((lb) {
      lb.directives.add(Directive.partOf(fileName));
      lb.body.add(cls);
    });
    return formatter.format('${library.accept(emitter)}');
  }
}
