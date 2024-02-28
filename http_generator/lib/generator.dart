import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_annotation_http/flutter_annotation_http.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';
import 'src/endpoint_collector.dart';
import 'src/middleware_collector.dart';

class EndpointGenerator extends GeneratorForAnnotation<Endpoint> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@Endpoint` can only be used on classes.',
        element: element,
      );
    } else if (!element.isAbstract) {
      throw InvalidGenerationSourceError(
        '`${element.displayName}` must be an abstract class.',
        element: element,
      );
    }
    return EndpointCollector(path.basename(buildStep.inputId.path))
        .collect(element, annotation);
  }
}

final _middlewareCollector = MiddlewareCollector();

class EnableHttpMiddlewareGenerator
    extends GeneratorForAnnotation<EnableHttpMiddleware> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return _middlewareCollector.collect(
        path.basename(buildStep.inputId.path), element, annotation);
  }
}

class MiddlewareGenerator extends GeneratorForAnnotation<Middleware> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@Middleware` can only be used on classes.',
        element: element,
      );
    }
    _middlewareCollector.addMiddleware(element, annotation);
    return null;
  }
}