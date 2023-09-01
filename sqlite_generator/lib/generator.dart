import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_annotation_sqlite/flutter_annotation_sqlite.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';
import 'src/database_collector.dart';
import 'src/repository_collector.dart';

class DatabaseGenerator extends GeneratorForAnnotation<Database> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          'The element annotated with @Database is not a class.',
          element: element);
    } else if (!element.isAbstract) {
      throw InvalidGenerationSourceError(
          'The database class has to be abstract.',
          element: element);
    }
    return DatabaseCollector()
        .collect(path.basename(buildStep.inputId.path), element, annotation);
  }
}

class RepositoryGenerator extends GeneratorForAnnotation<Repository> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          'The element annotated with @Repository is not a class.',
          element: element);
    } else if (!element.isAbstract) {
      throw InvalidGenerationSourceError(
          'The database class has to be abstract.',
          element: element);
    }
    return RepositoryCollector()
        .collect(path.basename(buildStep.inputId.path), element, annotation);
  }
}
