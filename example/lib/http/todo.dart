

import 'package:flutter_annotation_json/flutter_annotation_json.dart';

part 'todo.json.dart';

@JsonObject()
class AddTodo {
  final String title;
  final String body;
  final int userId;

  AddTodo({required this.title, required this.body, required this.userId});

  Map<String, dynamic> toJson() => _$AddTodoToJson(this);
}

@JsonObject()
class TodoModel {
  final int id;
  final String title;
  final String body;
  final int userId;

  TodoModel(
      {required this.id,
      required this.title,
      required this.body,
      required this.userId});

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);
}
