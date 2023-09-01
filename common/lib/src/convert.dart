import 'package:analyzer/dart/constant/value.dart';

String? parseValueObject(DartObject? object) {
  final valueType = object?.type;
  if (valueType != null) {
    if (valueType.isDartCoreString) {
      return "'${object?.toStringValue()}'";
    } else if (valueType.isDartCoreBool) {
      return '${object?.toBoolValue()}';
    } else if (valueType.isDartCoreInt) {
      return '${object?.toIntValue()}';
    } else if (valueType.isDartCoreDouble) {
      return '${object?.toDoubleValue()}';
    } else if (valueType.isDartCoreList) {
      return "[${object?.toListValue()?.map((e) => parseValueObject(e)).join(',')}]";
    } else if (valueType.isDartCoreMap) {
      return "{${object?.toMapValue()?.entries.map((e) => '${parseValueObject(e.key)}:${parseValueObject(e.value)}').join(',')}}";
    } else if (valueType.isDartCoreSet) {
      return "{${object?.toSetValue()?.map((e) => parseValueObject(e)).join(',')}}";
    }
  }
  return null;
}
