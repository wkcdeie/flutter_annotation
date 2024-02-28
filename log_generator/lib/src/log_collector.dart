import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_annotation_common/flutter_annotation_common.dart' as fc;
import 'package:flutter_annotation_log/flutter_annotation_log.dart';
import 'package:source_gen/source_gen.dart';

class LogCollector {
  final _logPointChecker = TypeChecker.fromRuntime(LogPoint);
  final String fileName;

  LogCollector(this.fileName);

  String collect(ClassElement element, ConstantReader annotation) {
    final emitter = DartEmitter();
    final formatter = DartFormatter();
    final loggerName =
        annotation.peek('name')?.stringValue ?? element.displayName;
    final logLevelName = annotation.read('level').stringValue;
    final isDetached = annotation.read('isDetached').boolValue;
    final cls = Class((cb) {
      cb.name = '_\$${element.displayName}WithLog';
      cb.extend = refer(element.displayName);
      cb.fields.add(Field((fb) {
        fb.modifier = FieldModifier.final$;
        fb.type = refer('Logger');
        fb.name = '_logger';
        fb.assignment =
            Code("Logger${isDetached ? '.detached' : ''}('$loggerName')");
      }));
      if (isDetached) {
        cb.fields.add(Field((fb) {
          fb.modifier = FieldModifier.final$;
          fb.type = refer('LogOutput');
          fb.name = '_output';
        }));
        cb.constructors.add(Constructor((ctb) {
          ctb.requiredParameters.add(Parameter((pb) {
            pb.name = '_output';
            pb.toThis = true;
          }));
          ctb.body = Code(
              "_logger.level = Level.LEVELS.firstWhere((e) => e.name == '$logLevelName', orElse: () => Level.INFO);"
                  "_logger.onRecord.listen((record) => _output.output(LogInfo.from(record.stackTrace ?? StackTrace.current,level: record.level, logger: record.loggerName, time: record.time,message: record.message,error: record.error)));");
        }));
      }
      for (var method in element.methods) {
        if (method.isStatic) {
          continue;
        }
        DartObject? methodAnnotation = _logPointChecker
            .firstAnnotationOf(method, throwOnUnresolved: false);
        if (methodAnnotation == null) {
          continue;
        }
        final methodReader = ConstantReader(methodAnnotation);
        final logMethod = methodReader.read('level').stringValue;
        final logMsg = methodReader.read('message').stringValue;
        cb.methods.add(Method((mb) {
          mb.annotations.add(refer('override'));
          mb.returns =
              refer(method.returnType.getDisplayString(withNullability: true));
          mb.name = method.displayName;
          StringBuffer mpc = StringBuffer();
          for (var parameter in method.parameters) {
            final p = Parameter((pb) {
              pb.type =
                  refer(parameter.type.getDisplayString(withNullability: true));
              pb.name = parameter.name;
              pb.named = parameter.isNamed;
              if (parameter.defaultValueCode != null) {
                pb.defaultTo = Code(parameter.defaultValueCode!);
              }
            });
            if (parameter.isRequired) {
              mb.requiredParameters.add(p);
              if (p.named) {
                mpc.write('${p.name}:${p.name}');
              } else {
                mpc.write(p.name);
              }
              mpc.write(',');
            } else if (parameter.isOptional) {
              mb.optionalParameters.add(p);
              mpc.write(p.name);
              mpc.write(',');
            }
          }
          mb.body = Code("""
          _logger.${logMethod}('${fc.KeyResolver.resolve(logMsg)}', null, StackTrace.current);
          return super.${method.displayName}(${mpc.toString()});
          """);
        }));
      }
    });
    final library = Library((lb) {
      lb.directives.add(Directive.partOf(fileName));
      lb.ignoreForFile.add('unnecessary_brace_in_string_interps');
      lb.ignoreForFile.add('unnecessary_string_interpolations');
      lb.body.add(cls);
    });
    return formatter.format('${library.accept(emitter)}');
  }
}
