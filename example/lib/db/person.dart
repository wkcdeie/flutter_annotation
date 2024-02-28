import 'package:flutter_annotation_sqlite/flutter_annotation_sqlite.dart';

@Entity(table: 'tb_person')
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

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'],
        name: json['name'],
        age: json['age'],
        height: json['height'],
        isVip: json['isVip'],
        address:
            json['address'] != null ? Address.fromJson(json['address']) : null,
        birthday: json['birthday'],
      );
}

@Entity(
  primaryKeys: ['province', 'city', 'area'],
)
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

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        province: json['province'],
        city: json['city'],
        area: json['area'],
        detail: json['detail'],
      );

  Map<String, dynamic> toJson() =>
      {'province': province, 'city': city, 'area': area, 'detail': detail};
}
