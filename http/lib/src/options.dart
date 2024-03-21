import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart' as mime;

class RequestOptions {
  String method;
  Uri url;
  final Map<String, String> headers = {};
  int maxRedirects = 5;
  bool followRedirects = true;
  bool persistentConnection = true;

  String? get contentType {
    return headers[HttpHeaders.contentTypeHeader];
  }

  int? get contentLength {
    final length = headers[HttpHeaders.contentLengthHeader];
    return length == null ? null : int.tryParse(length);
  }

  RequestOptions(this.method, this.url);
}

class FormRequestOptions extends RequestOptions {
  final Map<String, dynamic> fields = {};

  String get bodyString {
    final contentType = this.contentType ?? ContentType.text.mimeType;
    if (ContentType.json.mimeType.startsWith(contentType)) {
      return jsonEncode(fields);
    }
    return fields.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  @override
  int get contentLength {
    return utf8.encode(bodyString).length;
  }

  FormRequestOptions(super.method, super.url);
}

class MultipartFilePart {
  final String field;
  final String filePath;
  final String filename;
  final String contentType;

  int get length {
    return File(filePath).lengthSync();
  }

  MultipartFilePart(this.field, this.filePath,
      {String? filename, String? contentType})
      : filename = filename ?? path.basename(filePath),
        contentType = contentType ??
            mime.lookupMimeType(filePath) ??
            ContentType.binary.mimeType;
}

class MultipartRequestOptions extends FormRequestOptions {
  final List<MultipartFilePart> files = [];

  @override
  int get contentLength {
    int fieldLength = super.contentLength;
    return fieldLength +
        files
            .map((e) => e.length)
            .fold(0, (previousValue, element) => previousValue + element);
  }

  MultipartRequestOptions(super.method, super.url);
}
