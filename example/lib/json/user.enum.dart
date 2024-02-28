// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// JsonEnumGenerator
// **************************************************************************

part of 'user.dart';

const _$UserLevelEnumData = {
  'normal': UserLevel.normal,
  'vip': UserLevel.vip,
  'svip': UserLevel.svip,
};
UserLevel _$parseUserLevel(
  dynamic value, {
  String defaultValue = 'vip',
}) {
  assert(value is String || value is int);
  return _$UserLevelEnumData[value] ?? _$UserLevelEnumData[defaultValue]!;
}

dynamic _$getValueForUserLevel(UserLevel that) {
  for (dynamic key in _$UserLevelEnumData.keys) {
    if (_$UserLevelEnumData[key] == that) {
      return key;
    }
  }
  return null;
}
