import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_annotation_router/flutter_annotation_router.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';
import 'src/router_collector.dart';
import 'src/navigate_collector.dart';

final _routerCollector = RouterCollector();

class EnableAnnotationRouterGenerator
    extends GeneratorForAnnotation<EnableAnnotationRouter> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return _routerCollector.collect(
        path.basename(buildStep.inputId.path), element, annotation);
  }
}

final _navigateCollector = NavigateCollector();

class EnableNavigateHelperGenerator
    extends GeneratorForAnnotation<EnableNavigateHelper> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return _navigateCollector.collect(
        path.basename(buildStep.inputId.path), element, annotation);
  }
}

class RoutePageGenerator extends GeneratorForAnnotation<RoutePage> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@RoutePage` can only be used on classes.',
        element: element,
      );
    }
    _navigateCollector.addLink(element, annotation);
    _routerCollector.addRoute(
        path.basename(buildStep.inputId.path), element, annotation);
    return null;
  }
}

class GuardGenerator extends GeneratorForAnnotation<RouteGuard> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@Guard` can only be used on classes.',
        element: element,
      );
    }
    _routerCollector.addGuard(element, annotation);
    return null;
  }
}
