import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_annotation_configure/flutter_annotation_configure.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import 'src/config_collector.dart';

class EnableConfigGenerator extends GeneratorForAnnotation<EnableConfigure> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@EnableConfig` can only be used on classes.',
        element: element,
      );
    } else if (!element.isAbstract) {
      throw InvalidGenerationSourceError(
        '`${element.displayName}` must be an abstract class.',
        element: element,
      );
    }
    return ConfigCollector(path.basename(buildStep.inputId.path))
        .collect(element, annotation);
  }
}