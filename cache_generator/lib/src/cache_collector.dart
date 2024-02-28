import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_annotation_cache/flutter_annotation_cache.dart';
import 'package:flutter_annotation_common/flutter_annotation_common.dart' as fc;
import 'package:source_gen/source_gen.dart';

class CacheCollector {
  final _cachePutChecker = TypeChecker.fromRuntime(CachePut);
  final _cacheableChecker = TypeChecker.fromRuntime(Cacheable);
  final _cacheEvictChecker = TypeChecker.fromRuntime(CacheEvict);
  final String fileName;

  CacheCollector(this.fileName);

  String collect(ClassElement element, ConstantReader annotation) {
    final emitter = DartEmitter();
    final formatter = DartFormatter();
    final cacheName = annotation.read('name').stringValue;
    const cacheStoreKey = 'cacheStore';
    final cls = Class((cb) {
      cb.name = '_\$${element.displayName}WithCache';
      cb.extend = refer(element.displayName);
      cb.fields.add(Field((fb) {
        fb.modifier = FieldModifier.final$;
        fb.type = refer('String');
        fb.name = '_cacheName';
        fb.assignment = Code("'$cacheName'");
      }));
      cb.fields.add(Field((fb) {
        fb.modifier = FieldModifier.final$;
        fb.type = refer('AsyncCacheStore');
        fb.name = cacheStoreKey;
      }));
      cb.constructors.add(Constructor((ctb) {
        ctb.initializers.add(Code('super()'));
        ctb.requiredParameters.add(Parameter((pb) {
          pb.name = cacheStoreKey;
          pb.toThis = true;
        }));
      }));
      for (var method in element.methods) {
        if (method.isStatic || method.isPrivate) {
          continue;
        }
        bool isPut = false;
        bool isQuery = false;
        bool isEvict = false;
        DartObject? methodAnnotation = _cachePutChecker
            .firstAnnotationOf(method, throwOnUnresolved: false);
        isPut = methodAnnotation != null;
        if (methodAnnotation == null) {
          methodAnnotation = _cacheableChecker.firstAnnotationOf(method,
              throwOnUnresolved: false);
          isQuery = methodAnnotation != null;
        }
        if (methodAnnotation == null) {
          methodAnnotation = _cacheEvictChecker.firstAnnotationOf(method,
              throwOnUnresolved: false);
          isEvict = methodAnnotation != null;
        }
        if (methodAnnotation == null) {
          continue;
        }
        final condition =
            methodAnnotation.getField('condition')?.toFunctionValue();
        final cacheKey = fc.KeyResolver.resolve(
            methodAnnotation.getField('key')?.toStringValue() ?? '');
        final allEntries =
            methodAnnotation.getField('allEntries')?.toBoolValue() ?? false;
        final beforeInvocation =
            methodAnnotation.getField('beforeInvocation')?.toBoolValue() ??
                false;
        final ttl = methodAnnotation.getField('ttl')?.toIntValue();
        final ttlExpr = ttl != null
            ? ', expires: DateTime.now().millisecondsSinceEpoch + $ttl'
            : '';
        final isFuture = method.returnType.isDartAsyncFuture;
        bool isNullability = false;
        String resultType =
            method.returnType.getDisplayString(withNullability: true);
        if (isFuture) {
          resultType = fc.TypeSplitter.genericType(resultType) ?? resultType;
        }
        isNullability = resultType.endsWith('?');
        resultType = fc.TypeSplitter.nonnullType(resultType);
        cb.methods.add(Method((mb) {
          mb.annotations.add(refer('override'));
          mb.returns = refer(method.hasImplicitReturnType
              ? 'void'
              : method.returnType.getDisplayString(withNullability: true));
          mb.name = method.displayName;
          if (isFuture || isQuery) {
            mb.modifier = MethodModifier.async;
          }
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
            } else if (parameter.isOptional) {
              mb.optionalParameters.add(p);
            }
          }
          final args = method.parameters.map((e) {
            if (e.isNamed) {
              return '${e.displayName}:${e.displayName}';
            }
            return e.displayName;
          }).join(',');
          final statement =
              "${isFuture ? 'await ' : ''}super.${method.displayName}(${args});";
          StringBuffer code = StringBuffer();
          if (condition != null) {
            code.writeln(
                "final shouldCache = ${condition.displayName}.call(this,'${method.displayName}', [$args]);");
            code.writeln("if (!shouldCache) { return $statement }");
          }
          if (!(isEvict && allEntries)) {
            code.writeln("final cacheKey = '${cacheKey}';");
          }
          final isCustomClass = fc.TypeChecker.isCustomClass(resultType);
          final isListType = fc.TypeChecker.isListType(resultType);
          final isSetType = fc.TypeChecker.isSetType(resultType);
          final typeName = isSetType ? 'Set' : 'List';
          String convertExpr = '';
          if (isCustomClass) {
            convertExpr = '.toJson()';
          } else if (isListType || isSetType) {
            convertExpr = '.map((e) => e.toJson()).to${typeName}()';
          }
          if (isPut) {
            code.writeln("final result = $statement");
            if (isNullability) {
              code.writeln('if (result != null) {');
            }
            code.writeln(
                "$cacheStoreKey.asyncPut(_cacheName, cacheKey, result$convertExpr$ttlExpr);");
            if (isNullability) {
              code.writeln('}');
            }
            code.writeln('return result;');
          } else if (isQuery) {
            code.writeln("$resultType? result;");
            code.writeln(
                "final cacheObject = await $cacheStoreKey.asyncGet(_cacheName, cacheKey);");
            code.writeln('if (cacheObject != null) {');
            if (isCustomClass) {
              code.writeln(
                  'result = $resultType.fromJson(cacheObject as Map<String, dynamic>);');
            } else if (isListType || isSetType) {
              final genericType = fc.TypeSplitter.genericType(resultType);
              if (genericType != null &&
                  fc.TypeChecker.isCustomClass(genericType)) {
                code.writeln(
                    'result = (cacheObject as $typeName).map((e) => $genericType.fromJson(e)).to${typeName}();');
              } else {
                code.writeln(
                    'result = $resultType.from(cacheObject as $typeName);');
              }
            } else {
              code.writeln('result = cacheObject as $resultType;');
            }
            code.writeln('}');
            code.writeln('if (result == null) {');
            code.writeln('result = $statement');
            if (isNullability) {
              code.writeln('if (result != null) {');
            }
            code.writeln(
                '$cacheStoreKey.asyncPut(_cacheName, cacheKey, result$convertExpr$ttlExpr);');
            if (isNullability) {
              code.writeln('}');
            }
            code.writeln('}');
            code.writeln('return result;');
          } else if (isEvict) {
            final evictExpr = allEntries
                ? '$cacheStoreKey.clear(_cacheName);'
                : '$cacheStoreKey.remove(_cacheName, cacheKey);';
            if (beforeInvocation) {
              code.writeln(evictExpr);
              code.writeln("return $statement");
            } else {
              code.writeln('try {');
              code.writeln("final result = $statement");
              code.writeln(evictExpr);
              code.writeln('return result;');
              code.writeln('} catch (e){rethrow;}');
            }
          }
          mb.body = Code(code.toString());
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
