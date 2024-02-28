import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'generator.dart';

Builder logBuilder(BuilderOptions options) =>
    LibraryBuilder(EnableLoggingGenerator(), generatedExtension: '.log.dart');
