class TypeChecker {
  static RegExp listTypeChecker = RegExp(r'^List(<.*>)?$');
  static RegExp mapTypeChecker = RegExp(r'^Map(<\w+,\s?\w+>)?$');
  static RegExp setTypeChecker = RegExp(r'^Set(<.*>)?$');
  static RegExp futureTypeChecker = RegExp(r'^FutureOr(<.*>)?$');

  static bool isCustomClass(String type) {
    if (isListType(type) ||
        isMapType(type) ||
        isSetType(type) ||
        isFutureOrType(type)) {
      return false;
    }
    return ![
      'String',
      'int',
      'double',
      'num',
      'bool',
      'Null',
      'Object',
      'Iterable',
      'Function',
      'Symbol',
      'dynamic',
      'void',
      'Future',
      'DateTime',
      'BigInt',
      'Duration'
    ].contains(type);
  }

  static bool isListType(String type) => type.startsWith(listTypeChecker);

  static bool isMapType(String type) => type.startsWith(mapTypeChecker);

  static bool isSetType(String type) => type.startsWith(setTypeChecker);

  static bool isFutureOrType(String type) => type.startsWith(futureTypeChecker);
}
