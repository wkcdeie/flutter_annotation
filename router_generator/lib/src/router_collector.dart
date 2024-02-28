import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_annotation_router/flutter_annotation_router.dart';
import 'package:flutter_annotation_common/flutter_annotation_common.dart'
    as fac;
import 'package:source_gen/source_gen.dart';

class RouterCollector {
  final _routeValueChecker = const TypeChecker.fromRuntime(RouteValue);
  final List<_RouteNode> _routeNodes = [];
  final List<_GuardNode> _guardNodes = [];

  String collect(String fileName, Element element, ConstantReader annotation) {
    final emitter = DartEmitter();
    final formatter = DartFormatter();
    final routePresent = annotation.peek('present')?.stringValue ?? 'Material';
    _routeNodes.sort((a, b) => a.compareTo(b));
    _guardNodes.sort((a, b) => a.compareTo(b));
    final lib = Library((lb) {
      if (routePresent == 'Cupertino') {
        lb.body.add(Directive.import('package:flutter/cupertino.dart'));
      } else {
        lb.body.add(Directive.import('package:flutter/material.dart'));
      }
      lb.body.add(Directive.import(
          'package:flutter_annotation_router/flutter_annotation_router.dart'));
      lb.body.add(Directive.import(
          '${path.basenameWithoutExtension(fileName)}.navigate.dart'));
      String? initialRoute;
      for (var node in _routeNodes) {
        lb.body.add(Directive.import(node.filePath));
        if (node.isRoot) {
          initialRoute = node.routePath;
        }
      }
      for (var node in _guardNodes) {
        lb.body.add(Directive.import(node.filePath));
      }
      // _routes
      lb.body.add(Field((fb) {
        fb.modifier = FieldModifier.final$;
        fb.name = '_routes';
        StringBuffer code = StringBuffer();
        code.writeln('{');
        for (var node in _routeNodes) {
          code.write(
              "NavigateHelper.${node.routeName}: (settings) => ${node.routePresent ?? routePresent}PageRoute(settings:settings,builder:(ctx) {");
          if (node.values.isNotEmpty) {
            code.writeln(
                'final args = Map<String, dynamic>.from(settings.arguments as Map);');
            final paramPart = node.values.map((e) {
              if (e.isRequired || e.validate != null) {
                code.writeln(
                    "if (args['${e.key}'] == null) { throw ArgumentError.notNull('${e.key}');}");
              }
              if (e.validate != null) {
                code.writeln(
                    "else if (RegExp(r'${e.validate}').hasMatch(args['${e.key}'].toString()) == false) {throw ArgumentError.value(args['${e.key}'], '${e.key}', r'Unmatched expression: `${e.validate}`');}");
              }
              String defaultValueExp = '';
              if (e.isNullability && e.defaultValue != null) {
                defaultValueExp = ' ?? ${e.defaultValue}';
              }
              return "${e.name}:args['${e.key}']$defaultValueExp";
            }).join(',');
            code.writeln('return ${node.className}($paramPart);');
          } else {
            code.writeln('return const ${node.className}();');
          }
          code.write('}),');
        }
        code.writeln('}');
        fb.assignment = Code(code.toString());
      }));
      // onGenerateRoute
      lb.body.add(Method((mb) {
        // mb.static = true;
        mb.returns = refer('Route<dynamic>?');
        mb.name = 'onGenerateRoute';
        mb.requiredParameters.add(Parameter((pb) {
          pb.type = refer('RouteSettings');
          pb.name = 'settings';
        }));
        mb.body = const Code("""
        if (settings.name == null) {
        return null;
        }
        return getRoute(settings.name!, arguments: settings.arguments);""");
      }));
      // getRoute
      lb.body.add(Method((mb) {
        // mb.static = true;
        mb.returns = refer('Route<dynamic>?');
        mb.name = 'getRoute';
        mb.requiredParameters.add(Parameter((pb) {
          pb.type = refer('String');
          pb.name = 'name';
        }));
        mb.optionalParameters.add(Parameter((pb) {
          pb.type = refer('dynamic');
          pb.name = 'arguments';
          pb.named = true;
        }));
        mb.body = const Code("""
        if (!_routes.containsKey(name)) {
        return null;
        }
        return _routes[name]?.call(RouteSettings(name: name, arguments: arguments));""");
      }));
      // setupGuards
      lb.body.add(Method((mb) {
        mb.returns = refer('void');
        mb.name = 'setupGuards';
        StringBuffer code = StringBuffer();
        code.writeln(
            'final chain = RouteChain.${initialRoute == null ? 'shared' : 'withInitialRoute(\'$initialRoute\')'};');
        for (var node in _guardNodes) {
          code.writeln(
              "chain.add('${node.pattern}', ${node.createFactory}());");
        }
        mb.body = Code(code.toString());
      }));
      // FixNavigatorWithPop
      lb.body.add(Class((cb) {
        cb.name = 'FixNavigatorWithPop';
        cb.extend = refer('NavigatorObserver');
        // didPop
        cb.methods.add(Method((mb) {
          mb.annotations.add(refer('override'));
          mb.returns = refer('void');
          mb.name = 'didPop';
          mb.requiredParameters.add(Parameter((pb) {
            pb.name = 'route';
            pb.type = refer('Route');
          }));
          mb.requiredParameters.add(Parameter((pb) {
            pb.name = 'previousRoute';
            pb.type = refer('Route?');
          }));
          mb.body = Code("""
          final name = route.settings.name;
          if (name != null && RouteChain.shared.routes.contains(name)) {
            RouteChain.shared.pop();
          }
          super.didPop(route, previousRoute);""");
        }));
      }));
    });
    return formatter.format('${lib.accept(emitter)}');
  }

  void addRoute(
      String fileName, ClassElement element, ConstantReader annotation) {
    List<_RouteValueNode> values = [];
    for (var field in element.fields) {
      if (field.isStatic) {
        continue;
      }
      final fieldAnnotation =
          _routeValueChecker.firstAnnotationOf(field, throwOnUnresolved: false);
      if (fieldAnnotation == null) {
        continue;
      }
      values.add(_RouteValueNode(
        key: fieldAnnotation.getField('name')?.toStringValue(),
        name: field.displayName,
        type: field.type.getDisplayString(withNullability: true),
        defaultValue:
            fac.parseValueObject(fieldAnnotation.getField('defaultValue')),
        isRequired:
            fieldAnnotation.getField('isRequired')?.toBoolValue() ?? false,
        isNullability:
            field.type.nullabilitySuffix == NullabilitySuffix.question,
        validate: fieldAnnotation.getField('validate')?.toStringValue(),
      ));
    }
    _routeNodes.add(_RouteNode(
      filePath: element.library.identifier,
      className: element.displayName,
      routeName:
          '${annotation.peek('alias')?.stringValue ?? element.displayName}Route',
      routePath: annotation.read('path').stringValue,
      routePresent: annotation.peek('present')?.stringValue,
      values: values,
      isRoot: annotation.read('isRoot').boolValue,
    ));
  }

  void addGuard(ClassElement element, ConstantReader annotation) {
    _guardNodes.add(_GuardNode(
      pattern: annotation.read('path').stringValue,
      createFactory:
          annotation.peek('createFactory')?.stringValue ?? element.displayName,
      filePath: element.library.identifier,
    ));
  }
}

class _RouteNode implements Comparable<_RouteNode> {
  final String filePath;
  final String className;
  final String routeName;
  final String routePath;
  final String? routePresent;
  final List<_RouteValueNode> values;
  final bool isRoot;

  const _RouteNode(
      {required this.filePath,
      required this.className,
      required this.routeName,
      required this.routePath,
      this.routePresent,
      required this.values,
      this.isRoot = false});

  @override
  int compareTo(_RouteNode other) {
    return routePath.compareTo(other.routePath);
  }
}

class _RouteValueNode {
  final String key;
  final String name;
  final String type;
  final String? defaultValue;
  final bool isRequired;
  final bool isNullability;
  final String? validate;

  _RouteValueNode(
      {String? key,
      required this.name,
      required this.type,
      this.defaultValue,
      bool isRequired = false,
      this.isNullability = false,
      this.validate})
      : key = key ?? name,
        isRequired = defaultValue == null ? isRequired : false;
}

class _GuardNode implements Comparable<_GuardNode> {
  final String pattern;
  final String createFactory;
  final String filePath;

  const _GuardNode(
      {required this.pattern,
      required this.createFactory,
      required this.filePath});

  @override
  int compareTo(_GuardNode other) {
    return pattern.compareTo(other.pattern);
  }
}
