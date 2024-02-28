import 'guard.dart';

class RouteChain implements RouteListener {
  static RouteChain? _instance;
  final List<_GuardDispatcher> _guards = [];
  final List<String> _routeHistory = [];
  final String? initialRoute;

  static RouteChain get shared {
    _instance ??= RouteChain();
    return _instance!;
  }

  String? get previous {
    final index = _routeHistory.length - 1;
    if (index <= 0) {
      return null;
    }
    return _routeHistory[index - 1];
  }

  String? get current => _routeHistory.isNotEmpty ? _routeHistory.last : null;

  List<String> get routes => _routeHistory;

  RouteChain([this.initialRoute]) {
    if (initialRoute != null) {
      _routeHistory.add(initialRoute!);
    }
  }

  static RouteChain withInitialRoute(String initialRoute) {
    _instance = RouteChain(initialRoute);
    return _instance!;
  }

  void add(String pattern, RouteListener listener) {
    _guards.add(_GuardDispatcher(pattern, listener));
  }

  void remove(String pattern) {
    _guards.removeWhere((element) => element.matcher.pattern == pattern);
  }

  Future<bool> push(String target, Map<String, dynamic> args) {
    return onEnter(target,
        _routeHistory.isEmpty ? initialRoute : _routeHistory.last, args);
  }

  Future<bool> pop() {
    final p = previous;
    final c = current;
    if (c != null && p != null) {
      return onLeave(p, c);
    }
    return Future.value(false);
  }

  Future<bool> popTo(String target) async {
    int index = _routeHistory.indexOf(target);
    if (index != -1) {
      for (int i = _routeHistory.length - 1; i > index; i--) {
        final allowed = await onLeave(_routeHistory[i - 1], _routeHistory[i]);
        if (!allowed) {
          return false;
        }
        i = _routeHistory.length;
      }
    }
    return Future.value(true);
  }

  Future<bool> popToHome() {
    if (initialRoute != null) {
      return popTo(initialRoute!);
    }
    return Future.value(true);
  }

  String removeLast() => _routeHistory.removeLast();

  @override
  Future<bool> onEnter(
      String to, String? from, Map<String, dynamic> args) async {
    final guards = _findGuard(to);
    for (var element in guards) {
      final isAllowed = await element.onEnter(to, from, args);
      if (!isAllowed) {
        return false;
      }
    }
    _routeHistory.add(to);
    return true;
  }

  @override
  Future<bool> onLeave(String to, String from) async {
    final guards = _findGuard(from);
    for (var element in guards) {
      final isAllowed = await element.onLeave(to, from);
      if (!isAllowed) {
        return false;
      }
    }
    _routeHistory.remove(from);
    return true;
  }

  Iterable<RouteListener> _findGuard(String path) {
    return _guards
        .where((element) => element.matcher.hasMatch(path))
        .map((e) => e.listener);
  }
}

class _GuardDispatcher {
  final RegExp matcher;
  final RouteListener listener;

  _GuardDispatcher(String pattern, this.listener) : matcher = RegExp(pattern);
}
