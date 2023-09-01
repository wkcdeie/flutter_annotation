class KeyResolver {
  static final _keyRegExp = RegExp('#[a-zA-Z0-9.]+');

  static String resolve(String key) {
    final matches = KeyResolver._keyRegExp
        .allMatches(key)
        .toList(growable: false);
    StringBuffer cacheKey = StringBuffer();
    int? prevPos;
    for (int i = 0; i < matches.length; i++) {
      final matcher = matches[i];
      if (i == 0) {
        cacheKey.write(key.substring(0, matcher.start));
      }
      if (prevPos != null) {
        cacheKey.write(key.substring(prevPos, matcher.start));
      }
      cacheKey.write('\${${key.substring(matcher.start + 1, matcher.end)}}');
      prevPos = matcher.end;
    }
    if (prevPos != null) {
      cacheKey.write(key.substring(prevPos));
    }
    return cacheKey.toString();
  }
}
