enum RequestMethod { get, post, head, delete, put, patch }

extension RequestMethodValues on RequestMethod {
  String get method => name.toUpperCase();
}

class RequestMapping {
  static const String jsonHeader = 'application/json';
  static const String byteHeader = 'application/octet-stream';
  static const String textHeader = 'text/plain';
  static const String htmlHeader = 'text/html';
  static const String xmlHeader = 'application/xml';

  /// The request path, which can also be the full URL
  final String path;

  /// Request method, default `GET`
  final RequestMethod method;

  /// Request body serialization type
  final String? consume;

  /// Response body serialization type, default 'json'
  final String produce;

  /// Request headers
  final Map<String, String>? headers;

  /// Request timeout in milliseconds
  final int? timeout;

  const RequestMapping(this.path,
      {this.method = RequestMethod.get,
      this.consume,
      String? produce,
      this.headers,
      this.timeout})
      : produce = produce ?? jsonHeader;
}

/// Used to assign the specified request parameter to a formal parameter in the method.
class RequestParam {
  /// Request parameter name, which defaults to the parameter name.
  final String? name;

  /// Whether required, the default is false, that is,
  /// the parameter must be included in the request,
  /// if it is not included, an exception will be thrown
  final bool isRequired;

  /// The default value, if the value is set, required will automatically be set to false,
  /// whether you configure required or not, what value is configured, is false.
  final dynamic defaultValue;

  const RequestParam({this.name, bool isRequired = false, this.defaultValue})
      : isRequired = defaultValue == null ? isRequired : false;
}

/// Used to handle content that is not the default `application/x-www-form-urlcoded`, such as `application/json` or `application/xml`.
class RequestBody {
  /// Custom serialization factory function, default 'toJson'
  final Function? factory;

  const RequestBody([this.factory]);
}

/// Map a placeholder for a URL binding.
/// The {xxx} placeholder in the URL can be bound to the input parameter of a method by @PathVariable ("xxx").
class PathVariable {
  final String? name;

  const PathVariable([this.name]);
}

/// Set the method parameters to the request header.
class RequestHeader extends RequestParam {
  const RequestHeader(
      {String? name, bool isRequired = false, String? defaultValue})
      : super(name: name, isRequired: isRequired, defaultValue: defaultValue);
}

/// The GET method requests a representation of the specified resource.
/// Requests using GET should only be used to request data (they shouldn't include data).
class GET extends RequestMapping {
  const GET(String path,
      {String? produce, Map<String, String>? headers, int? timeout})
      : super(path,
            method: RequestMethod.get,
            produce: produce,
            headers: headers,
            timeout: timeout);
}

/// The POST method sends data to the server.
/// The type of the body of the request is indicated by the Content-Type header.
class POST extends RequestMapping {
  const POST(String path,
      {String? consume,
      String? produce,
      Map<String, String>? headers,
      int? timeout})
      : super(path,
            method: RequestMethod.post,
            consume: consume,
            produce: produce,
            headers: headers,
            timeout: timeout);
}

/// The HEAD method requests the headers that would be returned if the HEAD request's URL was instead requested with the HTTP GET method.
class HEAD extends RequestMapping {
  const HEAD(String path, {Map<String, String>? headers, int? timeout})
      : super(path,
            method: RequestMethod.head, headers: headers, timeout: timeout);
}

/// The DELETE request method deletes the specified resource.
class DELETE extends RequestMapping {
  const DELETE(String path,
      {String? consume,
      String? produce,
      Map<String, String>? headers,
      int? timeout})
      : super(path,
            method: RequestMethod.delete,
            consume: consume,
            produce: produce,
            headers: headers,
            timeout: timeout);
}

/// The PUT request method creates a new resource or replaces a representation of the target resource with the request payload.
class PUT extends RequestMapping {
  const PUT(String path,
      {String? consume,
      String? produce,
      Map<String, String>? headers,
      int? timeout})
      : super(path,
            method: RequestMethod.put,
            consume: consume,
            produce: produce,
            headers: headers,
            timeout: timeout);
}

/// The PATCH request method applies partial modifications to a resource.
class PATCH extends RequestMapping {
  const PATCH(String path,
      {String? consume,
      String? produce,
      Map<String, String>? headers,
      int? timeout})
      : super(path,
            method: RequestMethod.patch,
            consume: consume,
            produce: produce,
            headers: headers,
            timeout: timeout);
}

/// A `multipart/form-data` request.
class Multipart extends RequestMapping {
  const Multipart(String path,
      {RequestMethod? method,
      String? produce,
      Map<String, String>? headers,
      int? timeout})
      : super(path,
            method: method ?? RequestMethod.post,
            produce: produce,
            headers: headers,
            timeout: timeout);
}

/// A file to be uploaded as part of a [Multipart].
class FilePart {
  /// The name of the form field for the file.
  final String? name;

  /// The basename of the file.
  final String? filename;

  /// The content-type of the file.
  final String? contentType;

  const FilePart({this.name, this.filename, this.contentType});
}
