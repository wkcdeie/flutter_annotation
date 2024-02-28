import 'dart:io';

import 'package:flutter_annotation_cache/flutter_annotation_cache.dart';
import 'package:flutter_annotation_configure/flutter_annotation_configure.dart';
import 'package:sqflite/sqflite.dart';

part 'app_config.cfg.dart';

@EnableConfigure(
  name: 'app',
  env: 'test',
  version: 'v1',
)
abstract class AppConfig {
  static late final AppConfig _instance;

  static AppConfig get instance => _instance;

  String? userName;

  @ConfigField(key: 'p_w')
  int? weight;

  @ConfigField(defaultValue: false)
  late bool isVip;

  @ConfigField(encoder: colorValueEncode, decoder: colorValueDecode)
  Set<ColorValue>? colors;

  List<double>? fontSizes;

  static Future<void> initialize() async {
    await CacheDatabase.initialize(
        Directory.systemTemp.path, databaseFactorySqflitePlugin);
    final store = DefaultConfigureStore(CacheDatabase.store);
    store.setData(
        await CacheDatabase.store.getObjects(DefaultConfigureStore.tag));
    _instance = _$AppConfigImpl(store);
  }
}

class ColorValue {
  final int red;
  final int green;
  final int blue;
  final int alpha;

  ColorValue(this.red, this.green, this.blue, this.alpha);

  factory ColorValue.fromJson(Map<String, dynamic> json) =>
      ColorValue(json['red'], json['green'], json['blue'], json['alpha']);

  Map<String, dynamic> toJson() => {
        'red': red,
        'green': green,
        'blue': blue,
        'alpha': alpha,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorValue &&
          runtimeType == other.runtimeType &&
          red == other.red &&
          green == other.green &&
          blue == other.blue &&
          alpha == other.alpha;

  @override
  int get hashCode =>
      red.hashCode ^ green.hashCode ^ blue.hashCode ^ alpha.hashCode;
}

dynamic colorValueEncode(dynamic value) {
  final colors = value as Set<ColorValue>;
  return colors.map((e) => e.toJson()).toList();
}

dynamic colorValueDecode(dynamic value) {
  if (value is! List) {
    return Set<ColorValue>.identity();
  }
  return value.map((e) => ColorValue.fromJson(e)).toSet();
}
