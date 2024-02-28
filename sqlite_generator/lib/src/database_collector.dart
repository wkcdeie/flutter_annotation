import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_annotation_sqlite/flutter_annotation_sqlite.dart';
import 'package:source_gen/source_gen.dart';
import 'entity_collector.dart';

class DatabaseCollector {
  final sqlitePrefix = 'sqflite';
  final _entityChecker = TypeChecker.fromRuntime(Entity);

  String collect(
      String fileName, ClassElement element, ConstantReader annotation) {
    final emitter = DartEmitter();
    final formatter = DartFormatter();
    final dbVersion = annotation.read('version').intValue;
    final entities = annotation
        .read('entities')
        .listValue
        .map((e) => e.toTypeValue()?.element)
        .whereType<ClassElement>();
    final migrations = annotation
        .read('migrations')
        .listValue
        .map((e) => e.toTypeValue()?.element)
        .whereType<ClassElement>();
    final cls = Class((cb) {
      cb.name = '_\$${element.displayName}';
      cb.extend = refer(element.displayName);
      // _database
      cb.fields.add(Field((fb) {
        fb.type = refer('$sqlitePrefix.Database?');
        fb.name = '_database';
      }));
      cb.methods.add(Method((mb) {
        mb.annotations.add(refer('override'));
        mb.returns = refer('$sqlitePrefix.Database');
        mb.name = 'database';
        mb.type = MethodType.getter;
        mb.body = Code(
            "if (_database == null) {throw StateError('The database instance is not initialized or has been shut down, call the open method to reopen.');}return _database!;");
      }));
      // open
      cb.methods.add(_addOpenMethod(dbVersion, entities, migrations));
      // close
      cb.methods.add(Method((mb) {
        mb.annotations.add(refer('override'));
        mb.returns = refer('Future<void>');
        mb.name = 'close';
        mb.modifier = MethodModifier.async;
        mb.body = Code('_database?.close();\n_database = null;');
      }));
    });
    final lib = Library((lb) {
      lb.directives.add(Directive.partOf(fileName));
      lb.body.add(cls);
    });
    return formatter.format('${lib.accept(emitter)}');
  }

  Method _addOpenMethod(int dbVersion, Iterable<ClassElement> entities,
      Iterable<ClassElement> migrations) {
    return Method((mb) {
      mb.annotations.add(refer('override'));
      mb.returns = refer('Future<void>');
      mb.name = 'open';
      mb.requiredParameters.add(Parameter((pb) {
        pb.type = refer('String');
        pb.name = 'dbPath';
      }));
      mb.optionalParameters.add(Parameter((pb) {
        pb.type = refer('bool');
        pb.name = 'inMemory';
        pb.defaultTo = Code('false');
        pb.named = true;
      }));
      mb.modifier = MethodModifier.async;
      StringBuffer code = StringBuffer();
      code.writeln('await close();');
      code.write('_database = await sqliteFactory.openDatabase(');
      code.writeln('inMemory ? $sqlitePrefix.inMemoryDatabasePath : dbPath,');
      code.write('options: $sqlitePrefix.OpenDatabaseOptions(');
      code.write('version: $dbVersion,');
      code.write('onCreate: (db, version) async {');
      for (var element in entities) {
        final annotation =
            _entityChecker.firstAnnotationOf(element, throwOnUnresolved: false);
        if (annotation == null) {
          continue;
        }
        final collector = EntityCollector();
        collector.collect(element, ConstantReader(annotation));
        code.writeln(
            "await SqlHelper.createTable(db, '${collector.table}', [${collector.columns.map((e) => "'${e.sql}'").join(',')}]");
        if (collector.primaryKeys.isNotEmpty) {
          code.write(", primaryKeys: [${collector.primaryKeys.map((e) => "'${e}'").join(',')}]");
        }
        code.write(');');
        for (var keys in collector.uniqueKeys) {
          code.write(
              "await SqlHelper.createIndex(db, '${collector.table}', [${keys.join(',')}], true);");
        }
        if (collector.columnIndexes.isNotEmpty) {
          code.write(
              "await SqlHelper.createIndex(db, '${collector.table}', [${collector.columnIndexes.map((e) => "'${e}'").join(',')}]);");
        }
      }
      code.write('},');
      code.write('onUpgrade: (db, oldVersion, newVersion) async {');
      code.write('final migrations = [');
      for (var migration in migrations) {
        code.write('${migration.displayName}(),');
      }
      code.write(
          '].where((element) => element.fromVersion >= oldVersion).toList();');
      code.writeln(
          'migrations.sort((a, b) => a.fromVersion.compareTo(b.fromVersion));');
      code.writeln(
          'if (migrations.isEmpty || migrations.last.toVersion != newVersion) {');
      code.writeln(
          "throw StateError('There is no migration supplied to update the database to the current version. Aborting the migration.');");
      code.writeln('}');
      code.writeln(
          'for (var migrator in migrations) {await migrator.onMigration(db);}');
      code.write('},');
      code.write('),);');
      mb.body = Code(code.toString());
    });
  }
}
