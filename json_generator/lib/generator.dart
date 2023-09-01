import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_annotation_json/flutter_annotation_json.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import 'src/json_object_collector.dart';
import 'src/json_enum_collector.dart';

class JsonObjectGenerator extends GeneratorForAnnotation<JsonObject> {
  final String? jsonKey;

  const JsonObjectGenerator({this.jsonKey});

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@JsonObject` can only be used on classes.',
        element: element,
      );
    }
    return JsonObjectCollector(path.basename(buildStep.inputId.path), jsonKey)
        .collect(element, annotation);
  }
}

class JsonEnumGenerator extends GeneratorForAnnotation<JsonEnum> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! EnumElement) {
      throw InvalidGenerationSourceError(
        '`@JsonEnum` can only be used on enum.',
        element: element,
      );
    }
    return JsonEnumCollector(path.basename(buildStep.inputId.path))
        .collect(element, annotation);
  }
}