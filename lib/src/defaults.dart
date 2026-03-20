import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'exceptions.dart';
import 'nodes.dart';
import 'runtime.dart';
import 'utils.dart';

export 'package:jinja/src/filters.dart' show filters;
export 'package:jinja/src/tests.dart' show tests;

const Map<String, Object?> globals = <String, Object?>{
  'namespace': Namespace.factory,
  'dict': dict,
  'list': list,
  'print': print,
  'range': range,
  'cycler': makeCycler,
  'joiner': makeJoiner,
  'lipsum': lipsum,
  'zip': zip,
  'now': now,
};

Object finalize(Context context, Object? value) {
  return value ?? '';
}

/// Default attribute getter used for `.` access.
///
/// Handles `Map`, `List` methods, `LoopContext`, and `Namespace` objects.
Object? getAttribute(String attribute, Object? object, {Object? node, String? source}) {
  if (object == null) {
    // Collect available attributes for suggestions
    final suggestions = <String>[
      'Check if the object is null before accessing attributes',
      'Use conditional rendering: {% if object %}{{ object.$attribute }}{% endif %}',
    ];

    throw UndefinedError(
      'Cannot access attribute `$attribute` on a null object.',
      nodeValue: node is Node ? node : null,
      operationValue: 'Accessing attribute \'$attribute\' on null object',
      suggestionsValue: suggestions,
      contextSnippetValue: (source != null && node is Node && node.line != null && node.column != null)
          ? errorContextSnippet(source, node.line!, node.column!)
          : null,
    );
  }

  if (object is Map) {
    if (attribute == 'entries') {
      return object.entries;
    }

    if (attribute == 'keys') {
      return object.keys;
    }

    if (attribute == 'values') {
      return object.values;
    }

    // Return null (undefined) if key doesn't exist to match Jinja2 behavior
    // This allows {% if object.key %} to work correctly
    return object[attribute];
  }

  if (object is List) {
    switch (attribute) {
      case 'add':
        return object.add;
    }
    // List doesn't have this attribute
    final suggestions = <String>[
      'List attributes: add, length, isEmpty, isNotEmpty',
      'Use index access for list items: object[index]',
    ];
    throw UndefinedError(
      'List does not have attribute `$attribute`.',
      nodeValue: node is Node ? node : null,
      operationValue: 'Accessing attribute \'$attribute\' on List',
      suggestionsValue: suggestions,
    );
  }

  if (object is LoopContext) {
    return object[attribute];
  }

  if (object is Namespace) {
    return object[attribute];
  }

  if (object is String && attribute == 'format') {
    // Python-like numeric format support for strings like:
    //   "{:,.2f}".format(1000)
    //   "{:.2f}".format(1000)
    //   "{:.0f}".format(1000)
    //
    // We translate the spec into an `intl` NumberFormat pattern.
    final formatSpec = object.trim();
    if (!formatSpec.startsWith('{:') || !formatSpec.endsWith('}')) return null;

    final inner = formatSpec
        .substring(2, formatSpec.length - 1) // after '{:' and before '}'
        .replaceAll(RegExp(r'\s+'), '');

    // Only handle `f` for now.
    if (inner.isEmpty || inner[inner.length - 1] != 'f') return null;

    final useGrouping = inner.contains(',');

    // Python precision: default is 6 when omitted for `f`.
    const defaultPrecision = 6;
    final precisionMatch = RegExp(r'\.(\d+)').firstMatch(inner);
    final precision = precisionMatch != null ? int.parse(precisionMatch.group(1)!) : defaultPrecision;

    final integerPattern = useGrouping ? '#,##0' : '0';
    final fractionPattern = precision > 0 ? '.${List.filled(precision, '0').join()}' : '';
    final pattern = '$integerPattern$fractionPattern';

    final formatter = NumberFormat(pattern);

    return (Object? value) {
      final num? number = switch (value) {
        num n => n,
        String s => num.tryParse(s.replaceAll(',', '')),
        _ => null,
      };

      if (number == null) return null;
      return formatter.format(number);
    };
  }

  if (object is Cycler) {
    if (attribute == 'next') return object.next;
    if (attribute == 'reset') return object.reset;
    if (attribute == 'current') return object.current;
    // Cycler doesn't have this attribute
    final suggestions = <String>[
      'Cycler attributes: next, reset, current',
    ];
    throw UndefinedError(
      'Cycler does not have attribute `$attribute`.',
      nodeValue: node is Node ? node : null,
      operationValue: 'Accessing attribute \'$attribute\' on Cycler',
      suggestionsValue: suggestions,
    );
  }

  if (object is Joiner) {
    // Joiner is usually called directly, but if attributes needed?
  }

  // For other object types, attribute access is not supported by default
  // in the reflection-free model. Returning null is a safe fallback.
  return null;
}

/// Default item getter used for `[]` access.
///
/// Handles `Map`, `List`, `MapEntry`, `LoopContext`, and `Namespace` objects.
Object? getItem(Object? key, Object? object, {Object? node, String? source}) {
  if (object == null) {
    final suggestions = <String>[
      'Check if the object is null before accessing items',
      'Use conditional rendering: {% if object %}{{ object[$key] }}{% endif %}',
    ];
    throw UndefinedError(
      'Cannot access item `$key` on a null object.',
      nodeValue: node is Node ? node : null,
      operationValue: 'Accessing item \'$key\' on null object',
      suggestionsValue: suggestions,
      contextSnippetValue: (source != null && node is Node && node.line != null && node.column != null)
          ? errorContextSnippet(source, node.line!, node.column!)
          : null,
    );
  }

  if (object is Map) {
    if (object.containsKey(key)) {
      return object[key];
    }
    // Return null (undefined) instead of throwing to match Jinja2 behavior
    return null;
  }

  if (object is List) {
    if (key is int) {
      if (key >= 0 && key < object.length) {
        return object[key];
      }
      final suggestions = <String>[
        'List has ${object.length} items (indices 0-${object.length - 1})',
        'Check list length before accessing: {% if list.length > $key %}...{% endif %}',
      ];
      throw UndefinedError(
        'Index `$key` is out of bounds for list of length `${object.length}`.',
        nodeValue: node is Node ? node : null,
        operationValue: 'Accessing index $key on List of length ${object.length}',
        suggestionsValue: suggestions,
      );
    }
    final suggestions = <String>[
      'List index must be an integer',
      'Use integer index: object[0], object[1], etc.',
    ];
    throw TemplateRuntimeError(
      'List index must be an integer, but got `${key.runtimeType}`.',
      nodeValue: node is Node ? node : null,
      operationValue: 'Accessing List with non-integer key',
      suggestionsValue: suggestions,
    );
  }

  if (object is MapEntry) {
    if (key == 0) {
      return object.key;
    }
    if (key == 1) {
      return object.value;
    }
    final suggestions = <String>[
      'MapEntry indices: 0 (key), 1 (value)',
    ];
    throw UndefinedError(
      'MapEntry index must be 0 or 1.',
      nodeValue: node is Node ? node : null,
      operationValue: 'Accessing MapEntry with invalid index',
      suggestionsValue: suggestions,
    );
  }

  if (object is LoopContext) {
    return object[key as String];
  }

  if (object is Namespace) {
    return object[key as String];
  }

  final suggestions = <String>[
    'Item access is only supported for Map, List, MapEntry, LoopContext, and Namespace',
    'Object type: ${object.runtimeType}',
  ];
  throw TemplateRuntimeError(
    'Cannot access item on object of type `${object.runtimeType}`.',
    nodeValue: node is Node ? node : null,
    operationValue: 'Accessing item on unsupported object type',
    suggestionsValue: suggestions,
  );
}

Object? undefined(String name, [String? template]) {
  // Return null for undefined variables to support "is defined" tests
  // Errors are thrown when variables are actually used (in getAttribute, getItem, etc.)
  return null;
}

// -- Globals Implementations --

class Cycler {
  final List<Object?> values;
  int _index = 0;

  Cycler(this.values);

  Object? get current => values.isEmpty ? null : values[_index];

  Object? call() {
    var res = current;
    next();
    return res;
  }

  Object? next() {
    if (values.isEmpty) return null;
    var res = current;
    _index = (_index + 1) % values.length;
    return res;
  }

  void reset() {
    _index = 0;
  }

  @override
  String toString() {
    return 'Cycler($values, $_index)';
  }
}

Cycler makeCycler([Object? arg1, Object? arg2, Object? arg3, Object? arg4, Object? arg5]) {
  var args = [if (arg1 != null) arg1, if (arg2 != null) arg2, if (arg3 != null) arg3, if (arg4 != null) arg4, if (arg5 != null) arg5];
  return Cycler(args);
}

class Joiner {
  final String sep;
  bool _used = false;

  Joiner([this.sep = ', ']);

  String call() {
    if (!_used) {
      _used = true;
      return '';
    }
    return sep;
  }
}

Joiner makeJoiner([String sep = ', ']) {
  return Joiner(sep);
}

const _lipsumText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod '
    'tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, '
    'quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo '
    'consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse '
    'cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat '
    'non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

String lipsum({int n = 5, bool html = true, int min = 20, int max = 100}) {
  var words = _lipsumText.split(' ');
  var random = math.Random();
  var buffer = StringBuffer();

  String generateParagraph() {
    var count = min + random.nextInt(max - min + 1);
    var result = <String>[];
    var current = 0;
    while (result.length < count) {
      if (current >= words.length) current = 0;
      result.add(words[current]);
      current++;
    }
    // Capitalize first
    if (result.isNotEmpty) {
      result[0] = result[0].substring(0, 1).toUpperCase() + result[0].substring(1);
    }
    // Add dot at end if missing
    var text = result.join(' ');
    if (!text.endsWith('.')) text += '.';
    return text;
  }

  for (var i = 0; i < n; i++) {
    var p = generateParagraph();
    if (html) {
      buffer.writeln('<p>$p</p>');
    } else {
      buffer.writeln(p);
      buffer.writeln();
    }
  }

  return buffer.toString().trim();
}

/// Zip multiple iterables.
/// Supports up to 5 iterables.
Iterable<List<Object?>> zip(Iterable<Object?> i1, [Iterable<Object?>? i2, Iterable<Object?>? i3, Iterable<Object?>? i4, Iterable<Object?>? i5]) {
  var iterables = [i1];
  if (i2 != null) iterables.add(i2);
  if (i3 != null) iterables.add(i3);
  if (i4 != null) iterables.add(i4);
  if (i5 != null) iterables.add(i5);
  return IterableZip(iterables);
}

/// Current time.
DateTime now() {
  return DateTime.now();
}

/// Creates a dictionary from keyword arguments or positional arguments.
///
/// Accepts:
/// - Keyword arguments: `dict(a=1, b=2)` creates `{'a': 1, 'b': 2}`
/// - Positional maps: `dict(map1, map2)` merges maps
/// - Positional iterables of pairs: `dict([['a', 1], ['b', 2]])` creates `{'a': 1, 'b': 2}`
///
/// Multiple arguments are merged left to right, with later values overriding earlier ones.
Map<Object?, Object?> dict([List<Object?>? args]) {
  var result = <Object?, Object?>{};

  if (args == null || args.isEmpty) {
    return result;
  }

  for (var arg in args) {
    if (arg is Map) {
      result.addAll(arg);
    } else if (arg is Iterable) {
      // Handle iterables of pairs like [['key', 'value'], ...]
      for (var item in arg) {
        if (item is List && item.length == 2) {
          result[item[0]] = item[1];
        } else if (item is MapEntry) {
          result[item.key] = item.value;
        } else {
          throw TemplateRuntimeError(
            'dict() argument must be a map or iterable of pairs, '
            'got iterable containing ${item.runtimeType}',
          );
        }
      }
    } else {
      throw TemplateRuntimeError(
        'dict() argument must be a map or iterable, got ${arg.runtimeType}',
      );
    }
  }

  return result;
}
