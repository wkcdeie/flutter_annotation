// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// EndpointGenerator
// **************************************************************************

part of 'json_placeholder.dart';

class _$JsonPlaceholderApiImpl implements JsonPlaceholderApi {
  _$JsonPlaceholderApiImpl({RequestAdapter? adapter})
      : this._adapter = adapter ?? RequestAdapter.defaultAdapter;

  final RegExp _urlRegex = RegExp(r'^w+://');

  final Uri _baseUri = Uri.parse('https://jsonplaceholder.typicode.com');

  final Map<String, dynamic> _parameters = {'x-app-platform': 'ios'};

  final Map<String, String> _headers = {'x-lang-platform': 'Dart'};

  final RequestAdapter _adapter;

  @override
  Future<TodoModel> getTodo(String id) async {
    final queryParameters = {
      ..._parameters,
    };
    final uri = _encodeUrl('/todos/$id', queryParameters);
    final options = FormRequestOptions('GET', uri);
    options.headers.addAll({
      ..._headers,
    });
    final response = await _adapter.doRequest(
      options,
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
    final uri = _encodeUrl('/todos', queryParameters);
    final options = FormRequestOptions('GET', uri);
    options.headers.addAll({
      ..._headers,
    });
    final response = await _adapter.doRequest(
      options,
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
    final uri = _encodeUrl('/todos', {});
    final options = FormRequestOptions('POST', uri);
    options.fields.addAll({
      ..._parameters,
      ...data.toJson(),
    });
    options.headers.addAll({
      ..._headers,
      'content-type': 'application/json; charset=utf-8',
    });
    final response = await _adapter.doRequest(
      options,
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
    final uri = _encodeUrl('/todos/$id', {});
    final options = FormRequestOptions('PUT', uri);
    options.fields.addAll({
      ..._parameters,
      ..._todoToJson.call(data),
    });
    options.headers.addAll({
      ..._headers,
      'content-type': 'application/json; charset=utf-8',
    });
    final response = await _adapter.doRequest(
      options,
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
    final uri = _encodeUrl('/todos/$id', {});
    final options = FormRequestOptions('PATCH', uri);
    options.fields.addAll({
      ..._parameters,
      'title': title,
    });
    options.headers.addAll({
      ..._headers,
      'x-user-tag': Uri.encodeQueryComponent('1'),
    });
    final response = await _adapter.doRequest(
      options,
    );
    final responseData = jsonDecode(response.body);
    if (responseData is Map) {
      return TodoModel.fromJson(Map<String, dynamic>.from(responseData));
    }
    throw UnsupportedError(
        'Could not find acceptable representation. Type convert:${responseData.runtimeType}=>TodoModel');
  }

  @override
  Future<RequestResponse> deleteTodo(int id) async {
    final uri = _encodeUrl('/todos/$id', {});
    final options = FormRequestOptions('DELETE', uri);
    options.fields.addAll({
      ..._parameters,
    });
    options.headers.addAll({
      ..._headers,
    });
    final response = await _adapter.doRequest(
      options,
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
    final uri = _encodeUrl('/upload', {});
    final options = MultipartRequestOptions('POST', uri);
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
    final response = await _adapter.doRequest(
      options,
      timeout: 60000,
    );
    return response.body;
  }

  Uri _encodeUrl(
    String urlPath,
    Map<String, dynamic> queryParameters,
  ) {
    Uri uri = _baseUri;
    if (_urlRegex.hasMatch(urlPath)) {
      uri = Uri.parse(urlPath);
    } else {
      uri = _baseUri.replace(path: urlPath);
    }
    if (queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }
    return uri;
  }
}
