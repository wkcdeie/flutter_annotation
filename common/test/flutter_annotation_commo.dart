import 'package:flutter_annotation_common/flutter_annotation_common.dart';
import 'package:test/test.dart';

void main() {
  test('SM4', () {
    final crypto =  SM4Crypto();
    crypto.setKey('0123456789abcdeffedcba9876543210');
    const s = 'https://www.baidu.com';
    final t = crypto.encryptString(s);
    expect(crypto.decryptString(t), s);
  });

  test('SM3', () {
    const s = 'admin';
    final t = SM3.hashString(s, key: '95cb90ad5ba0c7c0e2a556f0072626b3');
    expect(t.length, 64);
  });
}