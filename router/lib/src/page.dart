/// Define a routing page
class RoutePage {
  /// Routing path
  final String path;

  /// Page rendering, supporting `Material` and `Cupertino`
  final String? present;

  /// Route alias, default class name
  final String? alias;

  /// Generate the 'toXXX' method
  final bool toSelf;

  /// Generate the 'toXXXAndPopTo' method
  final bool toSelfAndPopTo;

  /// Generate the 'replacementToXXX' method
  final bool replacementToSelf;

  /// Generate the 'backToXXX' method
  final bool backToSelf;

  /// Generate the 'popAndToXXX' method
  final bool popAndToSelf;

  /// Whether it is the root route
  final bool isRoot;

  const RoutePage(this.path,
      {this.alias,
      this.present,
      this.toSelf = true,
      this.toSelfAndPopTo = false,
      this.replacementToSelf = false,
      this.backToSelf = false,
      this.popAndToSelf = false,
      this.isRoot = false});
}

/// Define a routing parameter
class RouteValue {
  /// Route parameter name, which defaults to the parameter name.
  final String? name;

  /// Whether required, the default is false, that is,
  /// the parameter must be included in the request,
  /// if it is not included, an exception will be thrown
  final bool isRequired;

  /// The default value, if the value is set, required will automatically be set to false,
  /// whether you configure required or not, what value is configured, is false.
  final dynamic defaultValue;

  /// Parameter check expression
  final String? validate;

  const RouteValue(
      {this.name, bool isRequired = false, this.defaultValue, this.validate})
      : isRequired = defaultValue == null ? isRequired : false;
}
