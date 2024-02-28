import 'package:flutter_annotation_json/flutter_annotation_json.dart';
import 'package:flutter_annotation_sqlite/flutter_annotation_sqlite.dart';

part 'person.json.dart';

@Entity(table: 'tb_person')
@JsonObject()
class Person {
  @Id()
  final int id;

  @Column(unique: true)
  final String name;
  @Column()
  final int age;
  @Column()
  final double height;

  @Column(name: 'is_vip', indexable: true)
  final bool isVip;

  @Column()
  final Address? address;

  @Column()
  final DateTime? birthday;

  Person(
      {required this.id,
      required this.name,
      required this.age,
      required this.height,
      this.isVip = false,
      this.address,
      this.birthday});

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  Map<String, dynamic> toJson() => _$PersonToJson(this);
}

@Entity(primaryKeys: ['province', 'city', 'area'])
@JsonObject()
class Address {
  @Column()
  final String province;
  @Column()
  final String city;
  @Column()
  final String area;
  @Column()
  final String? detail;

  Address(
      {required this.province,
      required this.city,
      required this.area,
      this.detail});

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
