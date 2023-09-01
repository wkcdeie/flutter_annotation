import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_annotation_log/flutter_annotation_log.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import 'src/log_collector.dart';

class EnableLoggingGenerator extends GeneratorForAnnotation<EnableLogging> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@EnableLogging` can only be used on classes.',
        element: element,
      );
    }
    return LogCollector(path.basename(buildStep.inputId.path))
        .collect(element, annotation);
  }
}
