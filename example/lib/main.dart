import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_annotation_http/flutter_annotation_http.dart';
import 'package:flutter_annotation_log/flutter_annotation_log.dart';
import 'package:flutter_annotation_router/flutter_annotation_router.dart';
import 'route/router.route.dart';
import 'main.middleware.dart';
import 'config/app_config.dart';

part 'main.log.dart';

@EnableHttpMiddleware()
void main() {
  final multipleLog = MultipleLogOutput([
    ConsoleLogOutput(),
    FileLogOutput(Directory.systemTemp.path),
  ]);
  setupLog(Level.FINE, multipleLog);
  setupGuards();
  setupMiddlewares();
  AppConfig.setup().then((value) => runApp(const MyApp()));
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
        _FixNavigatorWithPop.withLog(),
      ],
    );
  }
}

@EnableLogging(name: 'Navigator', isDetached: true)
class _FixNavigatorWithPop extends NavigatorObserver {
  _FixNavigatorWithPop();

  factory _FixNavigatorWithPop.withLog() =>
      _$_FixNavigatorWithPopWithLog(ConsoleLogOutput());

  @override
  @InfoLog('didPop:#route.settings.name')
  void didPop(Route route, Route? previousRoute) {
    final name = route.settings.name;
    if (name != null && RouteChain.shared.routes.contains(name)) {
      RouteChain.shared.pop();
    }
    super.didPop(route, previousRoute);
  }
}
