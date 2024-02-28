// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// EnableAnnotationRouterGenerator
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter_annotation_router/flutter_annotation_router.dart';
import 'router.navigate.dart';
import 'package:example/page/home.dart';
import 'package:example/page/first_page.dart';
import 'package:example/page/second_page.dart';
import 'package:example/route/log.dart';

final _routes = {
  NavigateHelper.MyHomePageRoute: (settings) => MaterialPageRoute(
      settings: settings,
      builder: (ctx) {
        return const MyHomePage();
      }),
  NavigateHelper.FirstRoute: (settings) => MaterialPageRoute(
      settings: settings,
      builder: (ctx) {
        final args = Map<String, dynamic>.from(settings.arguments as Map);
        if (args['age'] == null) {
          throw ArgumentError.notNull('age');
        } else if (RegExp(r'\d+').hasMatch(args['age'].toString()) == false) {
          throw ArgumentError.value(
              args['age'], 'age', r'Unmatched expression: `\d+`');
        }
        return FirstPage(
            text: args['text'],
            isModal: args['isModal'] ?? true,
            age: args['age']);
      }),
  NavigateHelper.SecondPageRoute: (settings) => MaterialPageRoute(
      settings: settings,
      builder: (ctx) {
        final args = Map<String, dynamic>.from(settings.arguments as Map);
        return SecondPage(userInfo: args['userInfo']);
      }),
};
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  if (settings.name == null) {
    return null;
  }
  return getRoute(settings.name!, arguments: settings.arguments);
}

Route<dynamic>? getRoute(
  String name, {
  dynamic arguments,
}) {
  if (!_routes.containsKey(name)) {
    return null;
  }
  return _routes[name]?.call(RouteSettings(name: name, arguments: arguments));
}

void setupGuards() {
  final chain = RouteChain.withInitialRoute('/');
  chain.add('/*', RouteLoggingListener.withLog());
}

class FixNavigatorWithPop extends NavigatorObserver {
  @override
  void didPop(
    Route route,
    Route? previousRoute,
  ) {
    final name = route.settings.name;
    if (name != null && RouteChain.shared.routes.contains(name)) {
      RouteChain.shared.pop();
    }
    super.didPop(route, previousRoute);
  }
}
