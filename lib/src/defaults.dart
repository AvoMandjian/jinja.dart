import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/runtime.dart';
import 'package:jinja/src/utils.dart';

export 'package:jinja/src/filters.dart' show filters;
export 'package:jinja/src/tests.dart' show tests;

const Map<String, Object?> globals = <String, Object?>{
  'namespace': Namespace.factory,
  'list': list,
  'print': print,
  'range': range,
};

Object finalize(Context context, Object? value) {
  return value ?? '';
}

Object? getItem(
  Object? item,
  dynamic object, {
  Object? node,
}) {
  try {
    // TODO(dynamic): dynamic invocation
    // ignore: avoid_dynamic_calls
    return object[item];
  } catch (e) {
    if (object == null) {
      if (node is Attribute) {
        throw Exception(
            'Trying to access "$item" in an undefined object: "${(node.value as Name).name}", it may be {{${(node.value as Name).name}.$item}} in the jinja script');
      } else {
        throw Exception(
            'Jinja script contains {{.$item}}, but the provided "object" is null. No object in the Jinja data contains {{.$item}}.');
      }
    }
    throw Exception(
        'Attempted to access {{$item}} in the provided "object" {{$object}}, which may not be an object. Flutter Exception: ${e.toString()}');
  }
}

Object? undefined(String name, [String? template]) {
  return null;
}
