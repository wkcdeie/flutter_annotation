import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'generator.dart';

Builder databaseBuilder(BuilderOptions options) =>
    LibraryBuilder(DatabaseGenerator(), generatedExtension: '.db.dart');

Builder repositoryBuilder(BuilderOptions options) =>
    LibraryBuilder(RepositoryGenerator(), generatedExtension: '.dao.dart');
