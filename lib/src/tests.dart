import 'environment.dart';
import 'utils.dart';

/// Return `true` if the variable is odd.
bool isOdd(int value) {
  return value.isOdd;
}

/// Return `true` if the variable is even.
bool isEven(int value) {
  return value.isEven;
}

/// Check if a variable is divisible by a number.
bool isDivisibleBy(num value, num divider) {
  return divider == 0 ? false : value % divider == 0;
}

/// Return `true` if the variable is not `null`.
bool isDefined(Object? value) {
  return value != null;
}

/// Like `defined()` but the other way round.
bool isUndefined(Object? value) {
  return value == null;
}

/// Check if a filter exists by name. Useful if a filter may be
/// optionally available.
bool isFilter(Environment environment, String name) {
  return environment.filters.containsKey(name);
}

/// Check if a test exists by name. Useful if a test may be
/// optionally available.
bool isTest(Environment environment, String name) {
  return environment.tests.containsKey(name);
}

/// Return `true` if the variable is `null` (`none`).
bool isNull(Object? value) {
  return value == null;
}

/// Return `true` if the object is a [bool].
bool isBoolean(Object? object) {
  return object is bool;
}

/// Return `true` if the object is `false`.
bool isFalse(Object? value) {
  return value == false;
}

/// Return `true` if the object is `true`.
bool isTrue(Object? value) {
  return value == true;
}

/// Return `true` if the object is an [int].
bool isInteger(Object? value) {
  return value is int;
}

/// Return `true` if the object is a [double].
bool isFloat(Object? value) {
  return value is double;
}

/// Return `true` if the variable is lowercased.
bool isLower(String value) {
  return value == value.toLowerCase();
}

/// Return `true` if the variable is uppercased.
bool isUpper(String value) {
  return value == value.toUpperCase();
}

/// Return `true` if the object is a [String].
bool isString(Object? value) {
  return value is String;
}

/// Return `true` if the object is a [Map].
bool isMap(Object? value) {
  return value is Map;
}

/// Return `true` if the variable is a [num].
bool isNumber(Object? value) {
  return value is num;
}

/// Return `true` if the object is a [List].
bool isList(Object? object) {
  return object is List;
}

/// Check whether two references are to the same object.
bool isSameAs(Object? value, Object? other) {
  return identical(value, other);
}

/// Return `true` if the object is a [Iterable].
bool isIterable(Object? object) {
  return object is Iterable;
}

/// Check if value is in sequence.
bool isIn(Object? value, Object? values) {
  if (values case String strings) {
    if (value case Pattern pattern) {
      return strings.contains(pattern);
    }

    throw TypeError();
  }

  if (values case Iterable<Object?> values) {
    return values.contains(value);
  }

  if (values case Map<Object?, Object?> map) {
    return map.containsKey(value);
  }

  throw TypeError();
}

/// Same as `a != b`.
bool isNotEqual(Object? value, Object? other) {
  return value != other;
}

/// Same as `a < b`.
bool isLessThan(dynamic value, Object? other) {
  // ignore: avoid_dynamic_calls
  return (value < other) as bool;
}

/// Same as `a <= b`.
bool isLessThanOrEqual(dynamic value, Object? other) {
  // ignore: avoid_dynamic_calls
  return (value <= other) as bool;
}

/// Same as `a == b`.
bool isEqual(Object? value, Object? other) {
  return value == other;
}

/// Same as `a > b`.
bool isGreaterThan(dynamic value, Object? other) {
  // ignore: avoid_dynamic_calls
  return (value > other) as bool;
}

/// Same as `a >= b`.
bool isGreaterThanOrEqual(dynamic value, Object? other) {
  // ignore: avoid_dynamic_calls
  return (value >= other) as bool;
}

/// Return whether the object is callable (i.e., some kind of function).
/// Note that classes are callable, as are instances of classes with
/// a `call()` method.
bool isCallable(dynamic object) {
  if (object is Function) {
    return true;
  }

  try {
    // TODO(dynamic): dynamic invocation
    // ignore: avoid_dynamic_calls
    return object.call is Function;
  } on NoSuchMethodError {
    return false;
  }
}

/// Check if value matches regex pattern (anchored to start).
bool isMatch(String value, String pattern, {bool ignoreCase = false}) {
  return RegExp(pattern, caseSensitive: !ignoreCase).matchAsPrefix(value) != null;
}

/// Check if value contains regex pattern.
bool isSearch(String value, String pattern, {bool ignoreCase = false}) {
  return RegExp(pattern, caseSensitive: !ignoreCase).hasMatch(value);
}

/// Check if iterable is a subset of another.
bool isSubsetOf(Iterable<Object?> value, Iterable<Object?> other) {
  var set = other.toSet();
  return value.every((element) => set.contains(element));
}

/// Check if iterable is a superset of another.
bool isSupersetOf(Iterable<Object?> value, Iterable<Object?> other) {
  var set = value.toSet();
  return other.every((element) => set.contains(element));
}

/// Version comparison test.
///
/// Compares a version string against another version string using an operator.
/// Supports simple semantic versioning (x.y.z).
///
/// Usage: `{{ '1.2.0' is version('1.0.0', '>=') }}`
bool isVersion(String value, String version, [String operator = '==']) {
  List<int> parse(String v) {
    return v.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  }

  var v1 = parse(value);
  var v2 = parse(version);

  // Pad with zeros to match length
  var len = v1.length > v2.length ? v1.length : v2.length;
  if (v1.length < len) v1.addAll(List.filled(len - v1.length, 0));
  if (v2.length < len) v2.addAll(List.filled(len - v2.length, 0));

  int compare(List<int> a, List<int> b) {
    for (var i = 0; i < len; i++) {
      if (a[i] > b[i]) return 1;
      if (a[i] < b[i]) return -1;
    }
    return 0;
  }

  var result = compare(v1, v2);

  switch (operator) {
    case '==':
    case 'eq':
      return result == 0;
    case '!=':
    case 'ne':
      return result != 0;
    case '>':
    case 'gt':
      return result > 0;
    case '>=':
    case 'ge':
      return result >= 0;
    case '<':
    case 'lt':
      return result < 0;
    case '<=':
    case 'le':
      return result <= 0;
    default:
      throw ArgumentError.value(operator, 'operator', 'Unknown operator');
  }
}

/// Tests map.
final Map<String, Object> tests = <String, Object>{
  'odd': isOdd,
  'even': isEven,
  'divisibleby': isDivisibleBy,
  'defined': isDefined,
  'undefined': isUndefined,
  'filter': EnvFilter(isFilter),
  'test': EnvFilter(isTest),
  'none': isNull,
  'null': isNull,
  'boolean': isBoolean,
  'false': isFalse,
  'true': isTrue,
  'integer': isInteger,
  'float': isFloat,
  'lower': isLower,
  'upper': isUpper,
  'string': isString,
  'map': isMap,
  'mapping': isMap,
  'number': isNumber,
  'list': isList,
  'sameas': isSameAs,
  'iterable': isIterable,
  'in': isIn,
  '!=': isNotEqual,
  '<': isLessThan,
  '<=': isLessThanOrEqual,
  '==': isEqual,
  '>': isGreaterThan,
  '>=': isGreaterThanOrEqual,
  'callable': isCallable,
  'eq': isEqual,
  'equalto': isEqual,
  'ge': isGreaterThanOrEqual,
  'greaterthan': isGreaterThan,
  'gt': isGreaterThan,
  'le': isLessThanOrEqual,
  'lessthan': isLessThan,
  'lt': isLessThan,
  'ne': isNotEqual,
  'match': isMatch,
  'search': isSearch,
  'subsetof': isSubsetOf,
  'supersetof': isSupersetOf,
  'version': isVersion,
};
