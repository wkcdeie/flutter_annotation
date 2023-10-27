// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// JsonObjectGenerator
// **************************************************************************

part of 'user.dart';

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      name: json['name']?.toString() ?? '',
      age: DecodeHelper.toInt(json['age'], 0),
      height: DecodeHelper.toDouble(json['height'], 0.0),
      isVip: DecodeHelper.toBool(json['isVip'], false),
      lastLogin: DecodeHelper.toDateTime(json['lastLogin']),
      photos: DecodeHelper.toList<String>(json['photos']),
      level: _$parseUserLevel(json['level']),
      bio: json['bio']?.toString(),
      addressInfo: json['addressInfo'] != null
          ? AddressInfo.fromJson(
              DecodeHelper.toMap<String, dynamic>(json['addressInfo']))
          : null,
      session: durationDecode.call(json['session']),
    );
Map<String, dynamic> _$UserInfoToJson(UserInfo that) {
  return {
    'name': that.name,
    'age': that.age,
    'height': that.height,
    'isVip': that.isVip,
    'lastLogin': that.lastLogin.millisecondsSinceEpoch,
    'photos': that.photos,
    'level': that.level.value,
    if (that.bio != null) 'bio': that.bio,
    if (that.addressInfo != null) 'addressInfo': that.addressInfo?.toJson(),
    'session': durationEncode.call(that.session),
  };
}

AddressInfo _$AddressInfoFromJson(Map<String, dynamic> json) => AddressInfo(
      province: json['province']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
    );
Map<String, dynamic> _$AddressInfoToJson(AddressInfo that) {
  return {
    'province': that.province,
    'city': that.city,
    'area': that.area,
  };
}
