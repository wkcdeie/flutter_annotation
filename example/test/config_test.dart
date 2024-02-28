import 'package:example/config/app_config.dart';
import 'package:flutter_annotation_cache/flutter_annotation_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await AppConfig.initialize();
  });

  tearDown(() {
    CacheDatabase.close();
  });

  test('set value', () {
    AppConfig.instance.userName = 'admin';
    expect(AppConfig.instance.userName, 'admin');
  });

  test('get default value', () {
    expect(AppConfig.instance.isVip, false);
  });

  test('set custom coder', () {
    final black = ColorValue(0, 0, 0, 255);
    expect(AppConfig.instance.colors == null, true);
    AppConfig.instance.colors = {black};
    expect(AppConfig.instance.colors?.first, black);
  });
}
