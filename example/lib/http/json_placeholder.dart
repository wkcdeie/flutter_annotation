import 'dart:convert';

import 'package:flutter_annotation_http/flutter_annotation_http.dart';
import 'package:http/http.dart' as http;
import 'todo.dart';

part 'json_placeholder.api.dart';

@Endpoint(
  baseUrl: 'https://jsonplaceholder.typicode.com',
  parameters: {'x-app-platform': 'ios'},
  headers: {'x-lang-platform': 'Dart'},
)
abstract class JsonPlaceholderApi {
  factory JsonPlaceholderApi([HttpChain? chain]) =>
      _$JsonPlaceholderApiImpl(chain);

  @GET('/todos/{id}', produce: RequestMapping.jsonHeader)
  Future<TodoModel> getTodo(@PathVariable() String id);

  @GET('/todos')
  Future<List<TodoModel>> getTodos({String? title});

  @POST('/todos', consume: RequestMapping.jsonHeader)
  Future<TodoModel> createTodo(@RequestBody() AddTodo data);

  @PUT('/todos/{id}', consume: RequestMapping.jsonHeader)
  Future<TodoModel> updateTodo(
      @PathVariable() int id, @RequestBody(_todoToJson) AddTodo data);

  @PATCH('/todos/{id}', headers: {'x-user-tag': '1'})
  Future<TodoModel> patchTodo(@PathVariable() int id, String title);

  @DELETE('/todos/{id}')
  Future<http.Response> deleteTodo(@PathVariable() int id);

  @Multipart('/upload', produce: RequestMapping.textHeader, timeout: 60 * 1000)
  Future<String> upload(
      @RequestHeader()
          String type,
      String from,
      @RequestBody()
          AddTodo todo,
      @FilePart(
          /*filename: 'image',*/
          contentType: 'image/jpeg')
          String imagePath);
}

Map<String, dynamic> _todoToJson(AddTodo todo) => todo.toJson();
