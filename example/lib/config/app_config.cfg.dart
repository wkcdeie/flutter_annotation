// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// EnableConfigGenerator
// **************************************************************************

part of 'app_config.dart';

class _$AppConfigImpl extends AppConfig {
  _$AppConfigImpl(this._store) : super();

  final ConfigureStore _store;

  static const _userNameKey = 'app.userName@test#v1';

  static const _weightKey = 'p_w@test#v1';

  static const _isVipKey = 'app.isVip@test#v1';

  static const _colorsKey = 'app.colors@test#v1';

  static const _fontSizesKey = 'app.fontSizes@test#v1';

  @override
  set userName(String? userName) {
    if (userName == null) {
      _store.remove(_userNameKey);
    } else {
      _store.put(_userNameKey, userName);
    }
  }

  @override
  String? get userName {
    dynamic result = _store.get(_userNameKey);
    if (result != null) {
      if (result is String) {
        return result;
      }
    }
    return null;
  }

  @override
  set weight(int? weight) {
    if (weight == null) {
      _store.remove(_weightKey);
    } else {
      _store.put(_weightKey, weight);
    }
  }

  @override
  int? get weight {
    dynamic result = _store.get(_weightKey);
    if (result != null) {
      if (result is int) {
        return result;
      }
    }
    return null;
  }

  @override
  set isVip(bool isVip) {
    _store.put(_isVipKey, isVip);
  }

  @override
  bool get isVip {
    dynamic result = _store.get(_isVipKey);
    if (result != null) {
      if (result is bool) {
        return result;
      }
    }
    return false;
  }

  @override
  set colors(Set<ColorValue>? colors) {
    if (colors == null) {
      _store.remove(_colorsKey);
    } else {
      _store.put(_colorsKey, colorValueEncode.call(colors));
    }
  }

  @override
  Set<ColorValue>? get colors {
    dynamic result = _store.get(_colorsKey);
    if (result != null) {
      return colorValueDecode.call(result);
    }
    return null;
  }

  @override
  set fontSizes(List<double>? fontSizes) {
    if (fontSizes == null) {
      _store.remove(_fontSizesKey);
    } else {
      _store.put(_fontSizesKey, fontSizes);
    }
  }

  @override
  List<double>? get fontSizes {
    dynamic result = _store.get(_fontSizesKey);
    if (result != null) {
      if (result is List) {
        return List<double>.from(result);
      }
    }
    return null;
  }
}
