import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'generator.dart';

Builder configBuilder(BuilderOptions options) =>
    LibraryBuilder(EnableConfigGenerator(), generatedExtension: '.cfg.dart');
