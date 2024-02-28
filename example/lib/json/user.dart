

import 'package:flutter_annotation_json/flutter_annotation_json.dart';

part 'user.enum.dart';

part 'user.json.dart';

@JsonEnum('vip')
enum UserLevel {
  @EnumValue('normal')
  normal,
  @EnumValue('vip')
  vip,
  @EnumValue('svip')
  svip
}

extension UserLevelValues on UserLevel {
  String get value => _$getValueForUserLevel(this);
}

dynamic durationEncode(dynamic value) {
  return (value as Duration).inMilliseconds;
}

Duration durationDecode(dynamic value) {
  return Duration(milliseconds: value);
}

@JsonObject()
class UserInfo {
  final String name;
  final int age;
  final double height;
  final bool isVip;
  final DateTime lastLogin;
  final List<String> photos;
  final UserLevel level;
  final String? bio;
  final AddressInfo? addressInfo;
  @JsonField(encoder: durationEncode, decoder: durationDecode)
  final Duration session;

  UserInfo(
      {required this.name,
      required this.age,
      required this.height,
      required this.isVip,
      required this.lastLogin,
      required this.photos,
      required this.level,
      this.bio,
      this.addressInfo,
      required this.session});

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

@JsonObject()
class AddressInfo {
  final String province;
  final String city;
  final String area;

  AddressInfo({required this.province, required this.city, required this.area});

  factory AddressInfo.fromJson(Map<String, dynamic> json) =>
      _$AddressInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AddressInfoToJson(this);
}
