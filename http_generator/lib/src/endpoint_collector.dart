import 'dart:io';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_annotation_http/flutter_annotation_http.dart';
import 'package:flutter_annotation_common/flutter_annotation_common.dart'
    as fac;
import 'package:source_gen/source_gen.dart';

class EndpointCollector {
  final _getMethodChecker = const TypeChecker.fromRuntime(GET);
  final _postMethodChecker = const TypeChecker.fromRuntime(POST);
  final _headMethodChecker = const TypeChecker.fromRuntime(HEAD);
  final _deleteMethodChecker = const TypeChecker.fromRuntime(DELETE);
  final _putMethodChecker = const TypeChecker.fromRuntime(PUT);
  final _patchMethodChecker = const TypeChecker.fromRuntime(PATCH);
  final _requestParamChecker = const TypeChecker.fromRuntime(RequestParam);
  final _requestBodyChecker = const TypeChecker.fromRuntime(RequestBody);
  final _pathVariableChecker = const TypeChecker.fromRuntime(PathVariable);
  final _requestHeaderChecker = const TypeChecker.fromRuntime(RequestHeader);
  final _multipartRequestChecker = const TypeChecker.fromRuntime(Multipart);
  final _filePartChecker = const TypeChecker.fromRuntime(FilePart);

  final String fileName;
  bool _hasHeaders = false;
  bool _hasParameters = false;
  bool _hasRetry = false;

  // String? _baseUrl;
  int? _timeout;

  EndpointCollector(this.fileName);

  String collect(ClassElement element, ConstantReader annotation) {
    _timeout = annotation.peek('timeout')?.intValue;
    final baseUrl = annotation.peek('baseUrl')?.stringValue;
    final parameterField = annotation.peek('parameters')?.objectValue;
    final headerField = annotation.peek('headers')?.objectValue;
    final retryField = annotation.peek('retryOptions')?.objectValue;
    _hasHeaders = headerField != null;
    _hasParameters = parameterField != null;
    _hasRetry = retryField != null;
    final emitter = DartEmitter();
    final formatter = DartFormatter();
    final cls = Class((cb) {
      cb.name = '_\$${element.displayName}Impl';
      cb.implements.add(refer(element.displayName));
      if (_hasParameters) {
        // const String _parameters = {};
        cb.fields.add(_createField('Map<String, dynamic>', '_parameters',
            fac.parseValueObject(parameterField) ?? '{}'));
      }
      if (_hasHeaders) {
        // const String _headers = {};
        cb.fields.add(_createField('Map<String, String>', '_headers',
            fac.parseValueObject(headerField) ?? '{}'));
      }
      if (_hasRetry) {
        // final RetryOptions _retryOptions = ...;
        final retries = retryField!.getField('retries')!.toIntValue();
        final whenResponseName =
            retryField.getField('whenResponse')!.toFunctionValue()?.displayName;
        final whenErrorName =
            retryField.getField('whenError')!.toFunctionValue()?.displayName;
        final delayName =
            retryField.getField('delay')!.toFunctionValue()?.displayName;
        StringBuffer pc = StringBuffer();
        if (retries != 3) {
          pc.writeln('retries:$retries,');
        }
        if (whenResponseName != '_defaultWhen') {
          pc.writeln('whenResponse:$whenResponseName,');
        }
        if (whenErrorName != '_defaultWhenError') {
          pc.writeln('whenError:$whenErrorName,');
        }
        if (delayName != '_defaultDelay') {
          pc.writeln('delay:$delayName,');
        }
        cb.fields.add(_createField(
            'RetryOptions', '_retryOptions', 'RetryOptions(${pc.toString()})'));
      }
      // final HttpChain _chain;
      cb.fields.add(_createField('HttpChain?', '_chain', ''));
      cb.constructors.add(Constructor((cb) {
        cb.optionalParameters.add(Parameter((pb) {
          pb.name = '_chain';
          pb.toThis = true;
        }));
      }));

      for (var method in element.methods) {
        if (method.isStatic) {
          continue;
        }
        DartObject? methodAnnotation = _getRequestMethodAnnotation(method);
        if (methodAnnotation != null) {
          cb.methods.add(_createMethod(method, methodAnnotation, baseUrl));
        } else {
          methodAnnotation = _multipartRequestChecker.firstAnnotationOf(method,
              throwOnUnresolved: false);
          if (methodAnnotation != null) {
            cb.methods
                .add(_createMultipartMethod(method, methodAnnotation, baseUrl));
          }
        }
      }
      // _encodeUrl
      cb.methods.add(_encodeUrlMethod());
    });
    final library = Library((lb) {
      lb.directives.add(Directive.partOf(fileName));
      lb.body.add(cls);
    });
    return formatter.format('${library.accept(emitter)}');
  }

  Field _createField(String type, String name, String body) {
    return Field((fb) {
      fb.type = refer(type);
      fb.name = name;
      fb.modifier = FieldModifier.final$;
      if (body.isNotEmpty) {
        fb.assignment = Code(body);
      }
    });
  }

  Method _createMethod(
      MethodElement method, DartObject annotation, String? baseUrl) {
    final returnType = _getMethodReturnType(method.returnType);
    return Method((mb) {
      mb.annotations.add(refer('override'));
      mb.returns =
          refer(method.hasImplicitReturnType ? 'void' : 'Future<$returnType>');
      mb.name = method.displayName;
      mb.modifier = MethodModifier.async;

      final methodReader = ConstantReader(annotation);
      final isJsonRequest = methodReader.peek('consume')?.stringValue ==
          RequestMapping.jsonHeader;
      final methodTimeout = methodReader.peek('timeout')?.intValue;
      StringBuffer code = StringBuffer();
      final parser = _ParameterParser(
        requestMethod:
            annotation.type?.element?.displayName ?? RequestMethod.get.method,
        requestPath: "${baseUrl ?? ''}${methodReader.read('path').stringValue}",
        headers: _parseHeaders(methodReader, isJsonRequest),
      );
      code.writeln(parser.parse(_addMethodParameters(method, mb)));
      final putQueryString = parser.isNoBody &&
          (_hasParameters || parser.queryParameters.isNotEmpty);
      // query string
      if (putQueryString) {
        code.writeln("final queryParameters = {");
        if (_hasParameters) {
          code.writeln('..._parameters,');
        }
        if (parser.queryParameters.isNotEmpty) {
          code.writeln(parser.queryParameters.join(','));
          code.write(',');
        }
        code.writeln('};');
      }
      code.writeln(
          "final urlString = _encodeUrl('${parser.requestPath}',${putQueryString ? 'queryParameters' : '{}'});");
      final putBody = !parser.isNoBody &&
          (_hasParameters ||
              parser.body.isNotEmpty ||
              parser.customBody.isNotEmpty);
      if (putBody) {
        code.write("final body =");
        if (isJsonRequest) {
          code.write('jsonEncode(');
        }
        code.write('{');
        if (_hasParameters) {
          code.writeln('..._parameters,');
        }
        if (parser.body.isNotEmpty) {
          code.writeln(parser.body.join(','));
          code.write(',');
        }
        if (parser.customBody.isNotEmpty) {
          code.writeln(parser.customBody.join(','));
          code.write(',');
        }
        code.write('}');
        if (isJsonRequest) {
          code.write(')');
        }
        code.writeln(';');
      }
      if (returnType != 'void') {
        code.write('final response = ');
      }
      code.write('await doWithClient((client) =>');
      code.write(
          "client.${parser.requestMethod.toLowerCase()}(Uri.parse(urlString)");
      // add header
      final hasHeader = _hasHeaders || parser.headers.isNotEmpty;
      if (hasHeader) {
        code.write(',headers:{');
      }
      if (_hasHeaders) {
        code.writeln('..._headers,');
      }
      if (parser.headers.isNotEmpty) {
        code.writeln(parser.headers.join(','));
        code.write(',');
      }
      if (hasHeader) {
        code.write('}');
      }
      // add body
      if (putBody) {
        code.writeln(",body: body,");
      }
      code.write("),");
      code.write('chain:_chain,');
      if (_hasRetry) {
        code.write('retryOptions:_retryOptions,');
      }
      int? timeout = methodTimeout ?? _timeout;
      if (timeout != null) {
        code.write('timeout:$timeout,');
      }
      if (parser.cancelTokenName != null) {
        code.write('cancelToken:${parser.cancelTokenName},');
      }
      code.write(');\n');
      // handle response
      code.writeln(_handleReturnType(
          returnType, methodReader.peek('produce')?.stringValue));
      mb.body = Code(code.toString());
    });
  }

  Method _createMultipartMethod(
      MethodElement method, DartObject annotation, String? baseUrl) {
    final returnType = _getMethodReturnType(method.returnType);
    return Method((mb) {
      mb.annotations.add(refer('override'));
      mb.returns =
          refer(method.hasImplicitReturnType ? 'void' : 'Future<$returnType>');
      mb.name = method.displayName;
      mb.modifier = MethodModifier.async;

      final methodReader = ConstantReader(annotation);
      final methodTimeout = methodReader.peek('timeout')?.intValue;
      final requestMethod =
          methodReader.read('method').read('_name').stringValue;

      StringBuffer code = StringBuffer();
      final parser = _ParameterParser(
        requestMethod:
            annotation.type?.element?.displayName ?? RequestMethod.get.method,
        requestPath: "${baseUrl ?? ''}${methodReader.read('path').stringValue}",
        headers: _parseHeaders(methodReader),
      );
      code.writeln(parser.parse(_addMethodParameters(method, mb)));
      code.writeln(
          "final urlString = _encodeUrl('${parser.requestPath}', {});");
      code.writeln(
          "final request = http.MultipartRequest('${requestMethod.toUpperCase()}', Uri.parse(urlString));");
      // add header
      if (_hasHeaders) {
        code.writeln('request.headers.addAll(_headers);');
      }
      if (parser.headers.isNotEmpty) {
        code.writeln('request.headers.addAll({${parser.headers.join(',')}});');
      }
      if (_hasParameters) {
        code.writeln("request.fields.addAll(_parameters);");
      }
      if (parser.body.isNotEmpty) {
        code.writeln("request.fields.addAll({${parser.body.join(',')}});");
      }
      if (parser.customBody.isNotEmpty) {
        code.writeln(
            "request.fields.addAll({${parser.customBody.join(',')}});");
      }
      // add file
      for (var part in parser.multiParts) {
        if (part.isNullability) {
          code.writeln('if (${part.name} != null) {');
        }
        code.writeln("request.files.add(${part.code});");
        if (part.isNullability) {
          code.writeln('}');
        }
      }
      if (returnType != 'void') {
        code.write('final rawResponse = ');
      }
      code.write('await doWithClient((client) => client.send(request),');
      code.write('chain:_chain,');
      if (_hasRetry) {
        code.write('retryOptions:_retryOptions,');
      }
      int? timeout = methodTimeout ?? _timeout;
      if (timeout != null) {
        code.write('timeout:$timeout,');
      }
      if (parser.cancelTokenName != null) {
        code.write('cancelToken:${parser.cancelTokenName},');
      }
      code.write(');');
      // handle response
      if (returnType != 'void') {
        code.writeln(
            "final response = await http.Response.fromStream(rawResponse);");
      }
      code.writeln(_handleReturnType(
          returnType, methodReader.peek('produce')?.stringValue));
      mb.body = Code(code.toString());
    });
  }

  Method _encodeUrlMethod() {
    return Method((mb) {
      mb.returns = refer('String');
      mb.name = '_encodeUrl';
      mb.requiredParameters.add(Parameter((pb) {
        pb.type = refer('String');
        pb.name = 'urlPath';
      }));
      mb.requiredParameters.add(Parameter((pb) {
        pb.type = refer('Map<String, dynamic>');
        pb.name = 'queryParameters';
      }));
      mb.body = Code("""
        if (queryParameters.isEmpty) {
          return urlPath;
        }
        final queryString = queryParameters.entries.map((e) => '\${Uri.encodeQueryComponent(e.key)}=\${e.value is String ? Uri.encodeQueryComponent(e.value) : e.value}').join('&');
        if (urlPath.lastIndexOf('?') != -1) {
          return '\$urlPath&\$queryString';
        }
        return '\$urlPath?\$queryString';""");
    });
  }

  List<String> _parseHeaders(ConstantReader reader,
      [bool isJsonRequest = false]) {
    final methodHeaders = reader.peek('headers')?.mapValue;
    List<String> headers = [
      if (isJsonRequest)
        "'${HttpHeaders.contentTypeHeader}':'${RequestMapping.jsonHeader}; charset=utf-8'",
    ];
    if (methodHeaders != null && methodHeaders.isNotEmpty) {
      methodHeaders.forEach((key, value) {
        final k = fac.parseValueObject(key);
        final v = fac.parseValueObject(value);
        if (k != null && v != null) {
          headers.add("$k:Uri.encodeQueryComponent($v)");
        }
      });
    }
    return headers;
  }

  String _handleReturnType(String returnType, String? responseType) {
    StringBuffer code = StringBuffer();
    const reason = 'Could not find acceptable representation.';
    final nonnullReturnType = fac.TypeSplitter.nonnullType(returnType);
    if (nonnullReturnType == 'http.Response') {
      code.writeln('return response;');
    } else if (nonnullReturnType == 'void') {
    } else if (responseType == RequestMapping.byteHeader) {
      code.writeln('return response.bodyBytes;');
    } else if (responseType == RequestMapping.textHeader ||
        responseType == RequestMapping.htmlHeader ||
        responseType == RequestMapping.xmlHeader) {
      code.writeln('return response.body;');
    } else if (responseType == RequestMapping.jsonHeader) {
      code.writeln('final responseData = jsonDecode(response.body);');
      if (fac.TypeChecker.isCustomClass(nonnullReturnType)) {
        code.writeln(
            'if (responseData is Map) {return $nonnullReturnType.fromJson(Map<String, dynamic>.from(responseData));}');
      } else if (fac.TypeChecker.isListType(nonnullReturnType)) {
        final genericType = fac.TypeSplitter.genericType(nonnullReturnType) ??
            nonnullReturnType;
        code.writeln('if (responseData is List) {');
        if (fac.TypeChecker.isCustomClass(genericType)) {
          code.writeln(
              'return List<Map<String, dynamic>>.from(responseData).map($genericType.fromJson).toList();');
        } else {
          code.writeln('return $nonnullReturnType.from(responseData);');
        }
        code.writeln('}');
      } else if (fac.TypeChecker.isSetType(nonnullReturnType)) {
        code.writeln(
            'if (responseData is List) {return $nonnullReturnType.from(responseData);}');
      } else if (fac.TypeChecker.isMapType(nonnullReturnType)) {
        code.writeln(
            'if (responseData is Map) {return $nonnullReturnType.from(responseData);}');
      }
      code.writeln(
          "throw UnsupportedError('$reason Type convert:\${responseData.runtimeType}=>$nonnullReturnType');");
    } else {
      code.writeln("throw UnsupportedError('$reason');");
    }
    return code.toString();
  }

  List<_ApiParamNode> _addMethodParameters(
      MethodElement method, MethodBuilder mb) {
    List<_ApiParamNode> nodes = [];
    for (var parameter in method.parameters) {
      final param = Parameter((pb) {
        pb.type = refer(parameter.type.getDisplayString(withNullability: true));
        pb.name = parameter.name;
        pb.named = parameter.isNamed;
        if (pb.named) {
          pb.required = parameter.isRequired;
        }
        if (parameter.defaultValueCode != null) {
          pb.defaultTo = Code(parameter.defaultValueCode!);
        }
      });
      if (parameter.isRequiredNamed || parameter.isOptional) {
        mb.optionalParameters.add(param);
      } else if (parameter.isRequired) {
        mb.requiredParameters.add(param);
      }
      final isNullability =
          parameter.type.nullabilitySuffix == NullabilitySuffix.question;
      final paramType = parameter.type.getDisplayString(withNullability: false);
      _ApiParamNode? node;
      DartObject? paramObject = _requestHeaderChecker
          .firstAnnotationOf(parameter, throwOnUnresolved: false);
      if (paramObject != null) {
        final reader = ConstantReader(paramObject);
        node = _ApiParamNode(
          key: reader.peek('name')?.stringValue,
          name: parameter.name,
          type: paramType,
          defaultValue:
              fac.parseValueObject(reader.peek('defaultValue')?.objectValue),
          isRequired: reader.peek('isRequired')?.boolValue ?? false,
          isNullability: isNullability,
          isHeader: true,
        );
      }
      if (paramObject == null) {
        paramObject = _pathVariableChecker.firstAnnotationOf(parameter,
            throwOnUnresolved: false);
        if (paramObject != null) {
          node = _ApiParamNode(
            key: paramObject.getField('name')?.toStringValue(),
            name: parameter.name,
            type: paramType,
            isNullability: isNullability,
            isPathVariable: true,
          );
        }
      }
      if (paramObject == null) {
        paramObject = _requestBodyChecker.firstAnnotationOf(parameter,
            throwOnUnresolved: false);
        if (paramObject != null) {
          node = _ApiParamNode(
            name: parameter.name,
            type: paramType,
            isNullability: isNullability,
            isRequestBody: true,
            factoryName:
                paramObject.getField('factory')?.toFunctionValue()?.displayName,
          );
        }
      }
      if (paramObject == null) {
        paramObject = _requestParamChecker.firstAnnotationOf(parameter,
            throwOnUnresolved: false);
        if (paramObject != null) {
          node = _ApiParamNode(
            key: paramObject.getField('name')?.toStringValue(),
            name: parameter.name,
            type: paramType,
            defaultValue:
                fac.parseValueObject(paramObject.getField('defaultValue')),
            isRequired:
                paramObject.getField('isRequired')?.toBoolValue() ?? false,
            isNullability: isNullability,
          );
        }
      }
      if (paramObject == null) {
        paramObject = _filePartChecker.firstAnnotationOf(parameter,
            throwOnUnresolved: false);
        if (paramObject != null) {
          node = _ApiParamNode(
            key: paramObject.getField('name')?.toStringValue(),
            name: parameter.name,
            type: paramType,
            isNullability: isNullability,
            isMultipart: true,
            filename: paramObject.getField('filename')?.toStringValue(),
            contentType: paramObject.getField('contentType')?.toStringValue(),
          );
        }
      }
      node ??= _ApiParamNode(
        name: parameter.name,
        type: paramType,
        isNullability: isNullability,
      );
      nodes.add(node);
    }
    return nodes;
  }

  DartObject? _getRequestMethodAnnotation(Element element) {
    DartObject? methodAnnotation =
        _getMethodChecker.firstAnnotationOf(element, throwOnUnresolved: false);
    methodAnnotation ??=
        _postMethodChecker.firstAnnotationOf(element, throwOnUnresolved: false);
    methodAnnotation ??=
        _headMethodChecker.firstAnnotationOf(element, throwOnUnresolved: false);
    methodAnnotation ??= _deleteMethodChecker.firstAnnotationOf(element,
        throwOnUnresolved: false);
    methodAnnotation ??=
        _putMethodChecker.firstAnnotationOf(element, throwOnUnresolved: false);
    methodAnnotation ??= _patchMethodChecker.firstAnnotationOf(element,
        throwOnUnresolved: false);
    return methodAnnotation;
  }

  String _getMethodReturnType(DartType returnType) {
    final mt = returnType as InterfaceType;
    if (mt.isDartAsyncFuture) {
      final result = mt.typeArguments.isNotEmpty
          ? mt.typeArguments.first.getDisplayString(withNullability: true)
          : 'dynamic';
      return result == 'Response' ? 'http.$result' : result;
    }
    return mt.getDisplayString(withNullability: true);
  }
}

class _ParameterParser {
  final List<String> body = [];
  final List<String> customBody = [];
  final List<String> queryParameters = [];
  final List<_MultiPartNode> multiParts = [];
  final String requestMethod;
  final List<String> headers;
  String requestPath;
  String? _cancelTokenName;

  bool get isNoBody =>
      requestMethod == RequestMethod.get.method ||
      requestMethod == RequestMethod.head.method;

  String? get cancelTokenName => _cancelTokenName;

  _ParameterParser(
      {required this.requestMethod,
      required this.requestPath,
      List<String>? headers})
      : headers = headers ?? [];

  String parse(List<_ApiParamNode> nodes) {
    StringBuffer code = StringBuffer();
    for (var node in nodes) {
      // add exception
      if (node.isRequired) {
        code.writeln(
            "if (${node.name} == null) { throw ArgumentError.notNull('${node.name}');}");
      }
      final isString = node.type == 'String';
      final nullCheckExp =
          node.isNullability && !node.isRequired && node.defaultValue == null
              ? 'if (${node.name} != null)'
              : '';
      final defaultValueExp = node.isNullability && node.defaultValue != null
          ? ' ?? ${node.defaultValue}'
          : '';
      if (node.isCancelToken) {
        _cancelTokenName = node.name;
      } else if (node.isPathVariable) {
        if (node.isNullability && !node.isRequired) {
          throw UnsupportedError(
              '`@PathVariable` decorated variable cannot be null');
        }
        requestPath = requestPath.replaceAll('{${node.key}}',
            '\$${isString ? '{Uri.encodeQueryComponent(${node.name})}' : node.name}');
      } else if (node.isHeader) {
        headers.add(
            "$nullCheckExp'${node.key}':Uri.encodeQueryComponent(${node.name}$defaultValueExp)");
      } else if (node.isRequestBody) {
        if (isNoBody) {
          throw UnsupportedError(
              '`$requestMethod` requests do not support `@RequestBody`');
        }
        if (node.factoryName != null) {
          customBody
              .add('$nullCheckExp...${node.factoryName}.call(${node.name})');
        } else if (fac.TypeChecker.isMapType(node.type)) {
          customBody.add('$nullCheckExp...${node.name}');
        } else {
          customBody.add('$nullCheckExp...${node.name}.toJson()');
        }
      } else if (node.isMultipart) {
        final isBytes = node.type == 'Uint8List' || node.type == 'List<int>';
        StringBuffer part =
            StringBuffer('${isBytes ? '' : 'await '}http.MultipartFile.');
        if (isBytes) {
          part.write('fromBytes');
        } else {
          part.write('fromPath');
        }
        part.write("('${node.key}',${node.name}");
        part.write(",filename: ");
        if (node.filename != null) {
          part.write("'${node.filename}'");
        } else {
          part.write("path.basename(${node.name})");
        }
        part.write(',contentType:MediaType.parse(');
        if (node.contentType != null) {
          part.write("'${node.contentType}'");
        } else {
          part.write(
              "mime_type.lookupMimeType(${node.name}) ?? 'application/octet-stream'");
        }
        part.write('))');
        multiParts.add(
            _MultiPartNode(node.isNullability, node.name, part.toString()));
      } else if (isNoBody) {
        queryParameters
            .add("$nullCheckExp'${node.key}': ${node.name}$defaultValueExp");
      } else {
        body.add("$nullCheckExp'${node.key}':${node.name}$defaultValueExp");
      }
    }
    return code.toString();
  }
}

class _ApiParamNode {
  final String key;
  final String name;
  final String type;
  final String? defaultValue;
  final bool isRequired;
  final bool isNullability;
  final bool isPathVariable;
  final bool isRequestBody;
  final bool isHeader;
  final String? factoryName;
  final bool isMultipart;
  final String? filename;
  final String? contentType;

  bool get isCancelToken => type == 'CancelToken';

  _ApiParamNode(
      {String? key,
      required this.name,
      required this.type,
      this.defaultValue,
      bool isRequired = false,
      this.isNullability = false,
      this.isPathVariable = false,
      this.isRequestBody = false,
      this.isHeader = false,
      this.factoryName,
      this.isMultipart = false,
      this.filename,
      this.contentType})
      : key = key ?? name,
        isRequired = defaultValue == null ? isRequired : false;
}

class _MultiPartNode {
  final bool isNullability;
  final String name;
  final String code;

  const _MultiPartNode(this.isNullability, this.name, this.code);
}
