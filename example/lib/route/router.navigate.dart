// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// EnableNavigateHelperGenerator
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter_annotation_router/flutter_annotation_router.dart';
import 'package:example/json/user.dart';

extension NavigateHelper on BuildContext {
  void backToHome() {
    final chain = RouteChain.shared;
    if (chain.initialRoute != null) {
      chain.popTo(chain.initialRoute!).then((allowed) {
        if (allowed) {
          Navigator.of(this)
              .popUntil(ModalRoute.withName(RouteChain.shared.initialRoute!));
        }
      });
    }
  }

  Future<T?> toMyHomePage<T>() async {
    Map<String, dynamic> args = {};
    final allowed = await RouteChain.shared.push('/', args);
    if (allowed) {
      return Navigator.of(this).pushNamed<T>('/', arguments: args);
    }
    return null;
  }

  void popMyHomePage<T>([T? result]) {
    RouteChain.shared.pop().then((allowed) {
      if (allowed) {
        Navigator.of(this).pop(result);
      }
    });
  }

  Future<T?> toFirst<T>({
    required String text,
    bool? isModal,
    required int age,
  }) async {
    Map<String, dynamic> args = {'text': text, 'isModal': isModal, 'age': age};
    final allowed = await RouteChain.shared.push('/first', args);
    if (allowed) {
      return Navigator.of(this).pushNamed<T>('/first', arguments: args);
    }
    return null;
  }

  void popFirst<T>([T? result]) {
    RouteChain.shared.pop().then((allowed) {
      if (allowed) {
        Navigator.of(this).pop(result);
      }
    });
  }

  Future<T?> toSecondPage<T>({UserInfo? userInfo}) async {
    Map<String, dynamic> args = {'userInfo': userInfo};
    final allowed = await RouteChain.shared.push('/second', args);
    if (allowed) {
      return Navigator.of(this).pushNamed<T>('/second', arguments: args);
    }
    return null;
  }

  Future<T?> toSecondPageAndPopTo<T>(
    String predicate, {
    UserInfo? userInfo,
  }) async {
    Map<String, dynamic> args = {'userInfo': userInfo};
    bool allowed = await RouteChain.shared.push('/second', args);
    if (allowed) {
      allowed = await RouteChain.shared.popTo(predicate);
      if (allowed) {
        return Navigator.of(this).pushNamedAndRemoveUntil<T>(
            '/second', ModalRoute.withName(predicate),
            arguments: args);
      } else {
        RouteChain.shared.removeLast();
      }
    }
    return null;
  }

  Future<T?> replacementToSecondPage<T, R>({
    R? result,
    UserInfo? userInfo,
  }) async {
    bool allowed = await RouteChain.shared.pop();
    if (!allowed) {
      return null;
    }
    Map<String, dynamic> args = {'userInfo': userInfo};
    allowed = await RouteChain.shared.push('/second', args);
    if (allowed) {
      return Navigator.of(this).pushReplacementNamed<T, R>('/second',
          result: result, arguments: args);
    }
    return null;
  }

  void backToSecondPage() {
    RouteChain.shared.popTo('/second').then((allowed) {
      if (allowed) {
        Navigator.of(this).popUntil(ModalRoute.withName('/second'));
      }
    });
  }

  Future<T?> popAndToSecondPage<T, R>({
    R? result,
    UserInfo? userInfo,
  }) async {
    bool allowed = true;
    if (RouteChain.shared.previous != null) {
      allowed = await RouteChain.shared.pop();
    }
    if (allowed) {
      Navigator.of(this).pop(result);
      return toSecondPage(userInfo: userInfo);
    }
    return null;
  }

  void popSecondPage<T>([T? result]) {
    RouteChain.shared.pop().then((allowed) {
      if (allowed) {
        Navigator.of(this).pop(result);
      }
    });
  }
}
