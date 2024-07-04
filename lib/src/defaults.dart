import 'package:jinja/src/context.dart';
import 'package:jinja/src/namespace.dart';
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

Object? getItem(Object? item, dynamic object) {
  try {
    // TODO(dynamic): dynamic invocation
    // ignore: avoid_dynamic_calls
    return object[item];
  } catch (e) {
    if (object == null) {
      throw Exception(
          'Jinja script contains {{.$item}}, but the provided "object" is null. No object in the Jinja data contains {{.$item}}.');
    }
    throw Exception(
        'Attempted to access {{$item}} in the provided "object" {{$object}}, which may not be an object. Flutter Exception: ${e.toString()}');
    return null;
  }
}

Object? undefined(String name) {
  return null;
}
