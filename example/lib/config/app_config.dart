import 'dart:io';

import 'package:flutter_annotation_configure/flutter_annotation_configure.dart';

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
  bool? isVip;

  @ConfigField(encoder: colorValueEncode, decoder: colorValueDecode)
  Set<ColorValue>? colors;

  List<double>? fontSizes;

  static Future<void> setup() async {
    final rootPath = Directory.systemTemp.path;
    final persistence = JsonPersistence('$rootPath/app.cfg',
        encryptKey: '0123456789abcdef0123456789abcdef');
    _instance = _$AppConfigImpl(persistence);
    await persistence.load();
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
