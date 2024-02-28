import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_annotation_http/flutter_annotation_http.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart' as mime_type;
import 'package:path/path.dart' as path;

part 'http_bin.api.dart';

@Endpoint(
  baseUrl: 'https://httpbin.org',
  timeout: 10 * 1000,
  retryOptions: RetryOptions(
    whenResponse: retryWhenResponse,
  ),
)
abstract class HttpBinApi {
  factory HttpBinApi([HttpChain? chain]) => _$HttpBinApiImpl(chain);

  @GET('/status/{codes}')
  Future<void> getStatus(@PathVariable() int codes);

  @GET('/json', produce: RequestMapping.jsonHeader)
  Future<Map> runJson();

  @GET('/robots.txt', produce: RequestMapping.textHeader)
  Future<String> getRobotsTxt();

  @GET('/bytes/{n}', produce: RequestMapping.byteHeader)
  Future<Uint8List> runBytes(@PathVariable() int n);

  @Multipart('/upload', produce: RequestMapping.textHeader, timeout: 60 * 1000)
  Future<String> upload(
      @RequestHeader()
          String type,
      String from,
      @RequestBody()
          UploadEnvInfo envInfo,
      @FilePart(/*filename: 'image', contentType: 'image/jpeg'*/)
          String imagePath);

  @GET('/status/{codes}')
  Future<void> cancelRequest(@PathVariable() int codes, CancelToken cancelToken);
}

class UploadEnvInfo {
  Map<String, String> toJson() => {};
}

FutureOr<bool> retryWhenResponse(http.BaseResponse response) =>
    response.statusCode >= 500;
