import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'generator.dart';

Builder cacheBuilder(BuilderOptions options) =>
    LibraryBuilder(EnableCachingGenerator(), generatedExtension: '.cache.dart');
