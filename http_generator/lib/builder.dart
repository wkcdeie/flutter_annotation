import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'generator.dart';

Builder endpointBuilder(BuilderOptions options) =>
    LibraryBuilder(EndpointGenerator(), generatedExtension: '.api.dart');

Builder httpMiddlewareBuilder(BuilderOptions options) =>
    LibraryBuilder(EnableHttpMiddlewareGenerator(),
        generatedExtension: '.middleware.dart');

Builder middlewareObjectBuilder(BuilderOptions options) =>
    LibraryBuilder(MiddlewareGenerator(), generatedExtension: '.mdw.dart');
