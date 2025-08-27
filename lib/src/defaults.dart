import 'package:jinja/src/exceptions.dart';
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

/// Default attribute getter used for `.` access.
///
/// Handles `Map`, `List` methods, `LoopContext`, and `Namespace` objects.
Object? getAttribute(String attribute, Object? object, {Object? node}) {
  if (object == null) {
    throw UndefinedError('Cannot access attribute `$attribute` on a null object.');
  }

  if (object is Map) {
    return object[attribute];
  }

  if (object is List) {
    switch (attribute) {
      case 'add':
        return object.add;
    }
  }

  if (object is LoopContext) {
    return object[attribute];
  }

  if (object is Namespace) {
    return object[attribute];
  }

  // For other object types, attribute access is not supported by default
  // in the reflection-free model. Returning null is a safe fallback.
  return null;
}

/// Default item getter used for `[]` access.
///
/// Handles `Map`, `List`, `MapEntry`, `LoopContext`, and `Namespace` objects.
Object? getItem(Object? key, Object? object, {Object? node}) {
  if (object == null) {
    throw UndefinedError('Cannot access item `$key` on a null object.');
  }

  if (object is Map) {
    if (object.containsKey(key)) {
      return object[key];
    }
    throw UndefinedError('Map does not contain key `$key`.');
  }

  if (object is List) {
    if (key is int) {
      if (key >= 0 && key < object.length) {
        return object[key];
      }
      throw UndefinedError(
          'Index `$key` is out of bounds for list of length `${object.length}`.');
    }
    throw TemplateRuntimeError(
        'List index must be an integer, but got `${key.runtimeType}`.');
  }

  if (object is MapEntry) {
    if (key == 0) {
      return object.key;
    }
    if (key == 1) {
      return object.value;
    }
    throw UndefinedError('MapEntry index must be 0 or 1.');
  }

  if (object is LoopContext) {
    return object[key as String];
  }

  if (object is Namespace) {
    return object[key as String];
  }

  throw TemplateRuntimeError(
      'Cannot access item on object of type `${object.runtimeType}`.');
}

Object? undefined(String name, [String? template]) {
  return null;
}
