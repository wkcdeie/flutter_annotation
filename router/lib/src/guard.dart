/// Define a route guard
class RouteGuard {
  /// Routing path
  final String path;

  /// The name of the method that created the instance
  final String? createFactory;

  const RouteGuard(this.path, [this.createFactory]);
}

/// Listen for the routing event interface
abstract class RouteListener {
  /// When entering a new route
  /// [to] New route
  ///
  /// [from] Previous route
  Future<bool> onEnter(String to, String? from, Map<String, dynamic> args);

  /// When returning to the previous route
  /// [to] Previous route
  ///
  /// [from] Current route
  Future<bool> onLeave(String to, String from);
}
