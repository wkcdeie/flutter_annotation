/// Define an annotation route entry
class EnableAnnotationRouter {
  /// Page rendering, supporting `Material` and `Cupertino`
  final String? present;

  const EnableAnnotationRouter({this.present});
}

/// Define a jump-friendly route method to generate ingress
class EnableNavigateHelper {
  /// Whether route guards are enabled
  final bool enableRouteGuard;

  const EnableNavigateHelper({this.enableRouteGuard = true});
}
