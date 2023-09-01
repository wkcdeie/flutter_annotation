import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_annotation_router/flutter_annotation_router.dart';
import 'package:source_gen/source_gen.dart';

class NavigateCollector {
  final _routeValueChecker = const TypeChecker.fromRuntime(RouteValue);
  final List<_LinkNode> _linkNodes = [];

  String collect(String fileName, Element element, ConstantReader annotation) {
    final emitter = DartEmitter();
    final formatter = DartFormatter();
    final enableRouteGuard = annotation.read('enableRouteGuard').boolValue;
    _linkNodes.sort((a, b) => a.compareTo(b));
    final lib = Library((lb) {
      lb.body.add(Directive.import('package:flutter/material.dart'));
      lb.body.add(
          Directive.import('package:flutter_annotation_router/flutter_annotation_router.dart'));
      _linkNodes
          .expand((element) => element.values.map((e) => e.import))
          .where((element) => element != null)
          .forEach((url) {
        lb.body.add(Directive.import(url!));
      });
      lb.body.add(Extension((eb) {
        eb.name = 'NavigateHelper';
        eb.on = refer('BuildContext');
        const navigator = 'Navigator.of(this)';
        // backToHome
        eb.methods.add(Method((mb) {
          mb.returns = refer('void');
          mb.name = 'backToHome';
          mb.body = const Code("""
          final chain = RouteChain.shared;
          if (chain.initialRoute != null) {
            chain.popTo(chain.initialRoute!).then((allowed) {
              if (allowed) {
                $navigator.popUntil(ModalRoute.withName(RouteChain.shared.initialRoute!));
              }
            });
          }""");
        }));
        for (var node in _linkNodes) {
          List<String> values = [];
          List<Parameter> parameters = [];
          for (var value in node.values) {
            values.add("'${value.key}':${value.name}");
            parameters.add(Parameter((pb) {
              pb.type = refer(value.type);
              pb.name = value.name;
              pb.named = true;
              pb.required = !value.isNullability;
            }));
          }
          final argExpr =
              "Map<String, dynamic> args = {${values.isEmpty ? '' : values.join(',')}};";
          // toXXX
          if (node.toSelf) {
            eb.methods.add(Method((mb) {
              mb.returns = refer('Future<T?>');
              mb.name = 'to${node.alias}';
              mb.types.add(refer('T'));
              mb.optionalParameters.addAll(parameters);
              final source =
                  "return $navigator.pushNamed<T>('${node.routePath}', arguments: args);";
              StringBuffer code = StringBuffer();
              code.writeln(argExpr);
              if (enableRouteGuard) {
                mb.modifier = MethodModifier.async;
                code.writeln(
                    "final allowed = await RouteChain.shared.push('${node.routePath}', args);");
                code.writeln("if (allowed) {");
                code.writeln(source);
                code.writeln("}");
                code.writeln("return null;");
              } else {
                code.writeln(source);
              }
              mb.body = Code(code.toString());
            }));
          }
          // toXXXAndPopTo
          if (node.toSelfAndPopTo) {
            eb.methods.add(Method((mb) {
              mb.returns = refer('Future<T?>');
              mb.name = 'to${node.alias}AndPopTo';
              mb.types.add(refer('T'));
              mb.requiredParameters.add(Parameter((pb) {
                pb.type = refer('String');
                pb.name = 'predicate';
              }));
              mb.optionalParameters.addAll(parameters);
              final source =
                  "return $navigator.pushNamedAndRemoveUntil<T>('${node.routePath}', ModalRoute.withName(predicate), arguments: args);";
              StringBuffer code = StringBuffer();
              code.writeln(argExpr);
              if (enableRouteGuard) {
                mb.modifier = MethodModifier.async;
                code.writeln(
                    "bool allowed = await RouteChain.shared.push('${node.routePath}', args);");
                code.writeln("if (allowed) {");
                code.writeln(
                    "allowed = await RouteChain.shared.popTo(predicate);");
                code.writeln("if (allowed) {$source");
                code.writeln("} else {RouteChain.shared.removeLast();}");
                code.writeln("}");
                code.writeln("return null;");
              } else {
                code.writeln(source);
              }
              mb.body = Code(code.toString());
            }));
          }
          // replacementToXXX
          if (node.replacementToSelf) {
            eb.methods.add(Method((mb) {
              mb.returns = refer('Future<T?>');
              mb.name = 'replacementTo${node.alias}';
              mb.types.addAll([refer('T'), refer('R')]);
              mb.optionalParameters.add(Parameter((pb) {
                pb.type = refer('R?');
                pb.name = 'result';
                pb.named = true;
              }));
              mb.optionalParameters.addAll(parameters);
              final source =
                  "return $navigator.pushReplacementNamed<T, R>('${node.routePath}', result: result, arguments: args);";
              StringBuffer code = StringBuffer();
              if (enableRouteGuard) {
                mb.modifier = MethodModifier.async;
                code.writeln("bool allowed = await RouteChain.shared.pop();");
                code.writeln('if (!allowed) {return null;}');
                code.writeln(argExpr);
                code.writeln(
                    "allowed = await RouteChain.shared.push('${node.routePath}', args);");
                code.writeln("if (allowed) {$source}");
                code.writeln("return null;");
              } else {
                code.writeln(argExpr);
                code.writeln(source);
              }
              mb.body = Code(code.toString());
            }));
          }
          // backToXXX
          if (node.backToSelf) {
            eb.methods.add(Method((mb) {
              mb.returns = refer('void');
              mb.name = 'backTo${node.alias}';
              final source =
                  "$navigator.popUntil(ModalRoute.withName('${node.routePath}'));";
              mb.body = Code(enableRouteGuard
                  ? "RouteChain.shared.popTo('${node.routePath}').then((allowed) {if (allowed) {$source}});"
                  : source);
            }));
          }
          // popAndToXXX
          if (node.popAndToSelf) {
            eb.methods.add(Method((mb) {
              mb.returns = refer('Future<T?>');
              mb.name = 'popAndTo${node.alias}';
              mb.types.addAll([refer('T'), refer('R')]);
              mb.optionalParameters.add(Parameter((pb) {
                pb.type = refer('R?');
                pb.name = 'result';
                pb.named = true;
              }));
              mb.optionalParameters.addAll(parameters);
              final source =
                  "return to${node.alias}(${parameters.map((e) => '${e.name}:${e.name}').join(',')});";
              StringBuffer code = StringBuffer();
              if (enableRouteGuard) {
                mb.modifier = MethodModifier.async;
                code.writeln('bool allowed = true;');
                code.writeln('if (RouteChain.shared.previous != null) {');
                code.writeln('allowed = await RouteChain.shared.pop();');
                code.writeln('}');
                code.writeln('if (allowed) {');
                code.writeln('Navigator.of(this).pop(result);');
                code.writeln(source);
                code.writeln('}');
                code.writeln('return null;');
              } else {
                code.writeln('$navigator.pop(result);');
                code.writeln(source);
              }
              mb.body = Code(code.toString());
            }));
          }
          // popXXX
          eb.methods.add(Method((mb) {
            mb.returns = refer('void');
            mb.name = 'pop${node.alias}';
            mb.types.add(refer('T'));
            mb.optionalParameters.add(Parameter((pb) {
              pb.type = refer('T?');
              pb.name = 'result';
            }));
            mb.body = const Code(
                "RouteChain.shared.pop().then((allowed){ if (allowed) {Navigator.of(this).pop(result);}});");
          }));
        }
      }));
    });
    return formatter.format('${lib.accept(emitter)}');
  }

  void addLink(ClassElement element, ConstantReader annotation) {
    List<_LinkValue> values = [];
    for (var field in element.fields) {
      if (field.isStatic) {
        continue;
      }
      final fieldAnnotation =
          _routeValueChecker.firstAnnotationOf(field, throwOnUnresolved: false);
      if (fieldAnnotation == null) {
        continue;
      }
      values.add(_LinkValue(
        key: fieldAnnotation.getField('name')?.toStringValue(),
        name: field.displayName,
        type: field.type.getDisplayString(withNullability: true),
        isNullability:
            field.type.nullabilitySuffix == NullabilitySuffix.question,
        import: field.type.element?.library?.isDartCore == false
            ? field.type.element?.library?.identifier
            : null,
      ));
    }
    _linkNodes.add(_LinkNode(
      alias: annotation.peek('alias')?.stringValue ?? element.displayName,
      routePath: annotation.read('path').stringValue,
      values: values,
      toSelf: annotation.read('toSelf').boolValue,
      toSelfAndPopTo: annotation.read('toSelfAndPopTo').boolValue,
      replacementToSelf: annotation.read('replacementToSelf').boolValue,
      backToSelf: annotation.read('backToSelf').boolValue,
      popAndToSelf: annotation.read('popAndToSelf').boolValue,
    ));
  }
}

class _LinkNode implements Comparable<_LinkNode> {
  final String routePath;
  final String alias;
  final List<_LinkValue> values;
  final bool toSelf;
  final bool toSelfAndPopTo;
  final bool replacementToSelf;
  final bool backToSelf;
  final bool popAndToSelf;

  const _LinkNode({
    required this.routePath,
    required this.alias,
    required this.values,
    this.toSelf = true,
    this.toSelfAndPopTo = false,
    this.replacementToSelf = false,
    this.backToSelf = false,
    this.popAndToSelf = false,
  });

  @override
  int compareTo(_LinkNode other) {
    return routePath.compareTo(other.routePath);
  }
}

class _LinkValue {
  final String key;
  final String name;
  final String type;
  final bool isNullability;
  final String? import;

  const _LinkValue(
      {String? key,
      required this.name,
      required this.type,
      this.isNullability = false,
      this.import})
      : key = key ?? name;
}
