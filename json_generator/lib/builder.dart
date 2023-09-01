import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'generator.dart';

Builder jsonObjectBuilder(BuilderOptions options) => LibraryBuilder(
    JsonObjectGenerator(jsonKey: options.config['jsonKey']?.toString()),
    generatedExtension: '.json.dart');

Builder jsonEnumBuilder(BuilderOptions options) =>
    LibraryBuilder(JsonEnumGenerator(), generatedExtension: '.enum.dart');
