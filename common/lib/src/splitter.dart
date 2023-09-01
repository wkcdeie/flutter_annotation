class TypeSplitter {
  static String nonnullType(String type) {
    return type.lastIndexOf('?') == -1
        ? type
        : type.substring(0, type.length - 1);
  }

  static String? genericType(String type) {
    final start = type.indexOf('<');
    final end = type.lastIndexOf('>');
    return start != -1 && end != -1 ? type.substring(start + 1, end) : null;
  }
}
