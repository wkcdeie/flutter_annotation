import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

class MiddlewareCollector {
  final List<_MiddlewareNode> _nodes = [];

  String collect(String fileName, Element element, ConstantReader annotation) {
    final emitter = DartEmitter();
    final formatter = DartFormatter();
    _nodes.sort((a, b) => a.compareTo(b));
    final lib = Library((lb) {
      lb.body.add(Directive.import(
          'package:flutter_annotation_http/flutter_annotation_http.dart'));
      for (var node in _nodes) {
        lb.body.add(Directive.import(node.filePath));
      }
      lb.body.add(Field((fb) {
        fb.modifier = FieldModifier.constant;
        fb.type = refer('bool');
        fb.name = '_isReleaseMode';
        fb.assignment = const Code("bool.fromEnvironment('dart.vm.product')");
      }));
      lb.body.add(Field((fb) {
        fb.modifier = FieldModifier.constant;
        fb.type = refer('bool');
        fb.name = '_isProfileMode';
        fb.assignment = const Code("bool.fromEnvironment('dart.vm.profile')");
      }));
      lb.body.add(Field((fb) {
        fb.modifier = FieldModifier.constant;
        fb.type = refer('bool');
        fb.name = 'isDebugMode';
        fb.assignment = const Code("!_isReleaseMode && !_isProfileMode");
      }));
      lb.body.add(Method((mb) {
        mb.returns = refer('void');
        mb.name = 'setupMiddlewares';
        mb.optionalParameters.add(Parameter((pb) {
          pb.type = refer('RequestAdapter?');
          pb.name = 'adapter';
          pb.named = true;
        }));
        mb.optionalParameters.add(Parameter((pb) {
          pb.type = refer('bool');
          pb.name = 'printCurl';
          pb.defaultTo = const Code('isDebugMode');
          pb.named = true;
        }));
        mb.optionalParameters.add(Parameter((pb) {
          pb.type = refer('bool');
          pb.name = 'printLogging';
          pb.defaultTo = const Code('isDebugMode');
          pb.named = true;
        }));
        StringBuffer code = StringBuffer();
        code.writeln("final chain = (adapter ?? RequestAdapter.defaultAdapter).chain;");
        code.writeln('if (chain != null) {');
        for (var element in _nodes) {
          code.writeln("chain.add('${element.pattern}', ${element.createFactory}());");
        }
        code.writeln(
            "if(printCurl){chain.add('/*', const PrintCurlMiddleware());}");
        code.writeln(
            "if(printLogging){chain.add('/*', const PrintLoggingMiddleware());}");
        code.writeln('}');
        mb.body = Code(code.toString());
      }));
    });
    return formatter.format('${lib.accept(emitter)}');
  }

  void addMiddleware(ClassElement element, ConstantReader annotation) {
    if (element.interfaces
        .where((e) =>
            e.getDisplayString(withNullability: false) == 'HttpMiddleware')
        .isEmpty) {
      throw InvalidGenerationSourceError(
        "`${element.name}` must implement interface `HttpMiddleware`.",
        element: element,
      );
    }
    _nodes.add(_MiddlewareNode(
        element.library.identifier,
        annotation.peek('createFactory')?.stringValue ?? element.displayName,
        annotation.read('path').stringValue,
        annotation.read('priority').intValue));
  }
}

class _MiddlewareNode implements Comparable<_MiddlewareNode> {
  final String filePath;
  final String createFactory;
  final String pattern;
  final int priority;

  _MiddlewareNode(
      this.filePath, this.createFactory, this.pattern, this.priority);

  @override
  int compareTo(_MiddlewareNode other) {
    return priority.compareTo(other.priority);
  }
}
