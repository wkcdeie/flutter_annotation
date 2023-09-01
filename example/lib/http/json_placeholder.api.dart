// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// EndpointGenerator
// **************************************************************************

part of 'json_placeholder.dart';

class _$JsonPlaceholderApiImpl implements JsonPlaceholderApi {
  _$JsonPlaceholderApiImpl([this._chain]);

  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  final Map<String, dynamic> _parameters = {'x-app-platform': 'ios'};

  final Map<String, String> _headers = {'x-lang-platform': 'Dart'};

  final HttpChain? _chain;

  @override
  Future<TodoModel> getTodo(String id) async {
    final queryParameters = {
      ..._parameters,
    };
    final urlString =
        _encodeUrl('/todos/${Uri.encodeQueryComponent(id)}', queryParameters);
    final response = await doWithClient(
      (client) => client.get(Uri.parse(urlString), headers: {
        ..._headers,
      }),
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
    final urlString = _encodeUrl('/todos', queryParameters);
    final response = await doWithClient(
      (client) => client.get(Uri.parse(urlString), headers: {
        ..._headers,
      }),
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
    final urlString = _encodeUrl('/todos', {});
    final body = jsonEncode({
      ..._parameters,
      ...data.toJson(),
    });
    final response = await doWithClient(
      (client) => client.post(
        Uri.parse(urlString),
        headers: {
          ..._headers,
          'content-type': 'application/json; charset=utf-8',
        },
        body: body,
      ),
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
    final urlString = _encodeUrl('/todos/$id', {});
    final body = jsonEncode({
      ..._parameters,
      ..._todoToJson.call(data),
    });
    final response = await doWithClient(
      (client) => client.put(
        Uri.parse(urlString),
        headers: {
          ..._headers,
          'content-type': 'application/json; charset=utf-8',
        },
        body: body,
      ),
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
    final urlString = _encodeUrl('/todos/$id', {});
    final body = {
      ..._parameters,
      'title': title,
    };
    final response = await doWithClient(
      (client) => client.patch(
        Uri.parse(urlString),
        headers: {
          ..._headers,
          'x-user-tag': Uri.encodeQueryComponent('1'),
        },
        body: body,
      ),
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
    final urlString = _encodeUrl('/todos/$id', {});
    final body = {
      ..._parameters,
    };
    final response = await doWithClient(
      (client) => client.delete(
        Uri.parse(urlString),
        headers: {
          ..._headers,
        },
        body: body,
      ),
      chain: _chain,
    );
    return response;
  }

  String _encodeUrl(
    String urlPath,
    Map<String, dynamic> queryParameters,
  ) {
    String urlString = _baseUrl;
    if (urlPath.startsWith('http') || urlPath.startsWith('https')) {
      urlString = urlPath;
    } else {
      urlString += urlPath;
    }
    if (queryParameters.isEmpty) {
      return urlString;
    }
    final queryString = queryParameters.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${e.value is String ? Uri.encodeQueryComponent(e.value) : e.value}')
        .join('&');
    if (urlString.lastIndexOf('?') != -1) {
      return '$urlString&$queryString';
    }
    return '$urlString?$queryString';
  }
}
