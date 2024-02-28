import 'dart:typed_data';

import 'package:flutter_annotation_sqlite/flutter_annotation_sqlite.dart';

@Entity(table: 'fa_cache_data')
class CacheData {
  @Column(unique: true)
  final String key;
  @Column()
  final int size;
  @Column(name: 'expire_date')
  final int? expireDate;
  @Column(name: 'file_path')
  final String? filePath;
  @Column()
  final Uint8List? data;

  CacheData(this.key, this.size, {this.expireDate, this.filePath, this.data});

  factory CacheData.fromJson(Map<String, dynamic> json) => CacheData(
        json['key'],
        json['size'],
        expireDate: json['expireDate'],
        filePath: json['filePath'],
        data: json['data'],
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'data': data,
        'size': size,
        'expireDate': expireDate,
        'filePath': filePath
      };
}
