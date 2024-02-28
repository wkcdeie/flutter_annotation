import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_annotation_http/flutter_annotation_http.dart';
import 'package:flutter_annotation_log/flutter_annotation_log.dart';
import 'package:flutter_annotation_router/flutter_annotation_router.dart';
import 'route/router.route.dart';
import 'main.middleware.dart';
import 'config/app_config.dart';

@EnableHttpMiddleware()
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final multipleLog = MultipleLogOutput([
    if (isDebugMode) ConsoleLogOutput(),
    FileLogOutput(Directory.systemTemp.path),
  ]);
  setupLog(Level.FINE, multipleLog);
  setupGuards();
  setupMiddlewares();
  AppConfig.initialize().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Annotation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: RouteChain.shared.initialRoute,
      onGenerateRoute: onGenerateRoute,
      navigatorObservers: [
        FixNavigatorWithPop(),
      ],
    );
  }
}
