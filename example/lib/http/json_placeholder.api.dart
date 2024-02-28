// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// EndpointGenerator
// **************************************************************************

part of 'json_placeholder.dart';

class _$JsonPlaceholderApiImpl implements JsonPlaceholderApi {
  _$JsonPlaceholderApiImpl([this._chain]);

  final Map<String, dynamic> _parameters = {'x-app-platform': 'ios'};

  final Map<String, String> _headers = {'x-lang-platform': 'Dart'};

  final HttpChain? _chain;

  @override
  Future<TodoModel> getTodo(String id) async {
    final queryParameters = {
      ..._parameters,
    };
    final urlString = _encodeUrl(
        'https://jsonplaceholder.typicode.com/todos/${Uri.encodeQueryComponent(id)}',
        queryParameters);
    final options = FormRequestOptions('GET', Uri.parse(urlString));
    options.headers.addAll({
      ..._headers,
    });
    final response = await doRequest(
      options,
      chain: _chain,
    );
    final responseData = jsonDecode(response.body);
    if (responseData is Map) {
      return TodoModel.fromJson(Map<String, dynamic>.from(responseData));
    }
    throw UnsupportedError(
        'Could not find acceptable representation. Type convert:${responseData.runtimeType}=>TodoModel');
  }

  @override
  Future<List<TodoModel>> getTodos({String? title}) async {
    final queryParameters = {
      ..._parameters,
      if (title != null) 'title': title,
    };
    final urlString = _encodeUrl(
        'https://jsonplaceholder.typicode.com/todos', queryParameters);
    final options = FormRequestOptions('GET', Uri.parse(urlString));
    options.headers.addAll({
      ..._headers,
    });
    final response = await doRequest(
      options,
      chain: _chain,
    );
    final responseData = jsonDecode(response.body);
    if (responseData is List) {
      return List<Map<String, dynamic>>.from(responseData)
          .map(TodoModel.fromJson)
          .toList();
    }
    throw UnsupportedError(
        'Could not find acceptable representation. Type convert:${responseData.runtimeType}=>List<TodoModel>');
  }

  @override
  Future<TodoModel> createTodo(AddTodo data) async {
    final urlString =
        _encodeUrl('https://jsonplaceholder.typicode.com/todos', {});
    final options = FormRequestOptions('POST', Uri.parse(urlString));
    options.fields.addAll({
      ..._parameters,
      ...data.toJson(),
    });
    options.headers.addAll({
      ..._headers,
      'content-type': 'application/json; charset=utf-8',
    });
    final response = await doRequest(
      options,
      chain: _chain,
    );
    final responseData = jsonDecode(response.body);
    if (responseData is Map) {
      return TodoModel.fromJson(Map<String, dynamic>.from(responseData));
    }
    throw UnsupportedError(
        'Could not find acceptable representation. Type convert:${responseData.runtimeType}=>TodoModel');
  }

  @override
  Future<TodoModel> updateTodo(
    int id,
    AddTodo data,
  ) async {
    final urlString =
        _encodeUrl('https://jsonplaceholder.typicode.com/todos/$id', {});
    final options = FormRequestOptions('PUT', Uri.parse(urlString));
    options.fields.addAll({
      ..._parameters,
      ..._todoToJson.call(data),
    });
    options.headers.addAll({
      ..._headers,
      'content-type': 'application/json; charset=utf-8',
    });
    final response = await doRequest(
      options,
      chain: _chain,
    );
    final responseData = jsonDecode(response.body);
    if (responseData is Map) {
      return TodoModel.fromJson(Map<String, dynamic>.from(responseData));
    }
    throw UnsupportedError(
        'Could not find acceptable representation. Type convert:${responseData.runtimeType}=>TodoModel');
  }

  @override
  Future<TodoModel> patchTodo(
    int id,
    String title,
  ) async {
    final urlString =
        _encodeUrl('https://jsonplaceholder.typicode.com/todos/$id', {});
    final options = FormRequestOptions('PATCH', Uri.parse(urlString));
    options.fields.addAll({
      ..._parameters,
      'title': title,
    });
    options.headers.addAll({
      ..._headers,
      'x-user-tag': Uri.encodeQueryComponent('1'),
    });
    final response = await doRequest(
      options,
      chain: _chain,
    );
    final responseData = jsonDecode(response.body);
    if (responseData is Map) {
      return TodoModel.fromJson(Map<String, dynamic>.from(responseData));
    }
    throw UnsupportedError(
        'Could not find acceptable representation. Type convert:${responseData.runtimeType}=>TodoModel');
  }

  @override
  Future<http.Response> deleteTodo(int id) async {
    final urlString =
        _encodeUrl('https://jsonplaceholder.typicode.com/todos/$id', {});
    final options = FormRequestOptions('DELETE', Uri.parse(urlString));
    options.fields.addAll({
      ..._parameters,
    });
    options.headers.addAll({
      ..._headers,
    });
    final response = await doRequest(
      options,
      chain: _chain,
    );
    return response;
  }

  @override
  Future<String> upload(
    String type,
    String from,
    AddTodo todo,
    String imagePath,
  ) async {
    final urlString =
        _encodeUrl('https://jsonplaceholder.typicode.com/upload', {});
    final options = MultipartRequestOptions('POST', Uri.parse(urlString));
    options.headers.addAll({
      ..._headers,
      'type': Uri.encodeQueryComponent(type),
    });
    options.fields.addAll({
      ..._parameters,
      'from': from,
      ...todo.toJson(),
    });
    options.files.add(
        MultipartFilePart('imagePath', imagePath, contentType: 'image/jpeg'));
    final response = await doRequest(
      options,
      chain: _chain,
      timeout: 60000,
    );
    return response.body;
  }

  String _encodeUrl(
    String urlPath,
    Map<String, dynamic> queryParameters,
  ) {
    if (queryParameters.isEmpty) {
      return urlPath;
    }
    final queryString = queryParameters.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${e.value is String ? Uri.encodeQueryComponent(e.value) : e.value}')
        .join('&');
    if (urlPath.lastIndexOf('?') != -1) {
      return '$urlPath&$queryString';
    }
    return '$urlPath?$queryString';
  }
}
