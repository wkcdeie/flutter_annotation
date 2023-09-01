// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// EnableConfigGenerator
// **************************************************************************

part of 'app_config.dart';

class _$AppConfigImpl extends AppConfig {
  _$AppConfigImpl(this._persistence) : super();

  final ConfigurePersistence _persistence;

  static const _userNameKey = 'app.userName@test#v1';

  static const _weightKey = 'p_w@test#v1';

  static const _isVipKey = 'app.isVip@test#v1';

  static const _colorsKey = 'app.colors@test#v1';

  static const _fontSizesKey = 'app.fontSizes@test#v1';

  @override
  set userName(String? userName) {
    if (userName == null) {
      _persistence.remove(_userNameKey);
    } else {
      _persistence.put(_userNameKey, userName);
    }
  }

  @override
  String? get userName {
    dynamic result = _persistence.get(_userNameKey);
    return result;
  }

  @override
  set weight(int? weight) {
    if (weight == null) {
      _persistence.remove(_weightKey);
    } else {
      _persistence.put(_weightKey, weight);
    }
  }

  @override
  int? get weight {
    dynamic result = _persistence.get(_weightKey);
    return result;
  }

  @override
  set isVip(bool? isVip) {
    if (isVip == null) {
      _persistence.remove(_isVipKey);
    } else {
      _persistence.put(_isVipKey, isVip);
    }
  }

  @override
  bool? get isVip {
    dynamic result = _persistence.get(_isVipKey);
    return result ?? false;
  }

  @override
  set colors(Set<ColorValue>? colors) {
    if (colors == null) {
      _persistence.remove(_colorsKey);
    } else {
      _persistence.put(_colorsKey, colorValueEncode.call(colors));
    }
  }

  @override
  Set<ColorValue>? get colors {
    dynamic result = _persistence.get(_colorsKey);
    if (result != null) {
      return colorValueDecode.call(result);
    }
    return result;
  }

  @override
  set fontSizes(List<double>? fontSizes) {
    if (fontSizes == null) {
      _persistence.remove(_fontSizesKey);
    } else {
      _persistence.put(_fontSizesKey, fontSizes);
    }
  }

  @override
  List<double>? get fontSizes {
    dynamic result = _persistence.get(_fontSizesKey);
    if (result != null) {
      return List<double>.from(result);
    }
    return result;
  }
}
