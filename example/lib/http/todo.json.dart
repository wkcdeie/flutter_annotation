// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// JsonObjectGenerator
// **************************************************************************

part of 'todo.dart';

AddTodo _$AddTodoFromJson(Map<String, dynamic> json) => AddTodo(
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      userId: DecodeHelper.toInt(json['userId'], 0),
    );
Map<String, dynamic> _$AddTodoToJson(AddTodo that) => {
      'title': that.title,
      'body': that.body,
      'userId': that.userId,
    };

TodoModel _$TodoModelFromJson(Map<String, dynamic> json) => TodoModel(
      id: DecodeHelper.toInt(json['id'], 0),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      userId: DecodeHelper.toInt(json['userId'], 0),
    );
