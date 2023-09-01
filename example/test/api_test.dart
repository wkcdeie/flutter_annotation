import 'package:example/http/http_bin.dart';
import 'package:example/http/json_placeholder.dart';
import 'package:example/http/todo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.middleware.dart';

void main() {
  // HttpOverrides.global = ProxyHttpOverrides(
  //   host: '127.0.0.1',
  //   port: '8889',
  // );

  final api = JsonPlaceholderApi();
  final httpBinApi = HttpBinApi();
  setUp(() {
    setupMiddlewares();
  });
  test('Todo List', () async {
    final todos = await api.getTodos();
    expect(todos, isNotEmpty);
  });
  test('Todo Create', () async {
    final todo = await api.createTodo(AddTodo(
        title: 'Test Create', body: 'This is todo create...', userId: 1));
    expect(todo.id, greaterThan(0));
  });
  test('Http status', () async {
    await httpBinApi.getStatus(500);
  });
}
