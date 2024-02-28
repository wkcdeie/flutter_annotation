import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_annotation_cache/flutter_annotation_cache.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import 'src/cache_collector.dart';

class EnableCachingGenerator extends GeneratorForAnnotation<EnableCaching> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@EnableCaching` can only be used on classes.',
        element: element,
      );
    }
    return CacheCollector(path.basename(buildStep.inputId.path))
        .collect(element, annotation);
  }
}
