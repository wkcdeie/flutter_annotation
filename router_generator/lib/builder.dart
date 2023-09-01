import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'generator.dart';

Builder annotationRouterBuilder(BuilderOptions options) =>
    LibraryBuilder(EnableAnnotationRouterGenerator(),
        generatedExtension: '.route.dart');

Builder navigateHelperBuilder(BuilderOptions options) =>
    LibraryBuilder(EnableNavigateHelperGenerator(),
        generatedExtension: '.navigate.dart');

Builder routePageBuilder(BuilderOptions options) =>
    LibraryBuilder(RoutePageGenerator(), generatedExtension: '.rp.dart');

Builder routeGuardBuilder(BuilderOptions options) =>
    LibraryBuilder(GuardGenerator(), generatedExtension: '.rg.dart');
