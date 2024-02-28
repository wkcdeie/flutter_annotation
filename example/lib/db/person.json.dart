// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// JsonObjectGenerator
// **************************************************************************

part of 'person.dart';

Person _$PersonFromJson(Map<String, dynamic> json) => Person(
      id: DecodeHelper.toInt(json['id'], 0),
      name: json['name']?.toString() ?? '',
      age: DecodeHelper.toInt(json['age'], 0),
      height: DecodeHelper.toDouble(json['height'], 0.0),
      isVip: DecodeHelper.toBool(json['isVip'], false),
      address: json['address'] != null
          ? Address.fromJson(
              DecodeHelper.toMap<String, dynamic>(json['address']))
          : null,
      birthday: json['birthday'] != null
          ? DecodeHelper.toDateTime(json['birthday'])
          : null,
    );
Map<String, dynamic> _$PersonToJson(Person that) => {
      'id': that.id,
      'name': that.name,
      'age': that.age,
      'height': that.height,
      'isVip': that.isVip,
      if (that.address != null) 'address': that.address?.toJson(),
      if (that.birthday != null)
        'birthday': that.birthday?.millisecondsSinceEpoch,
    };

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      province: json['province']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      detail: json['detail']?.toString(),
    );
Map<String, dynamic> _$AddressToJson(Address that) => {
      'province': that.province,
      'city': that.city,
      'area': that.area,
      if (that.detail != null) 'detail': that.detail,
    };
