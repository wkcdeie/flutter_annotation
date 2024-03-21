import 'package:example/http/json_placeholder.dart';
import 'package:example/http/todo.dart';
import 'package:flutter_annotation_http/flutter_annotation_http.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.middleware.dart';
import 'package:cookie_jar/cookie_jar.dart';

void main() {
  // HttpOverrides.global = ProxyHttpOverrides(
  //   host: '127.0.0.1',
  //   port: '8889',
  // );
  final api = JsonPlaceholderApi();
  setUp(() {
    setupMiddlewares(printLogging: true);
    RequestAdapter.defaultAdapter.chain
        ?.add('/*', CookieJarMiddleware(CookieJar()));
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
}
