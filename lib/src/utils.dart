import 'dart:async';
import 'dart:convert';

import 'package:html_unescape/html_unescape.dart';
import 'package:textwrap/utils.dart';

import 'environment.dart';
import 'exceptions.dart';
import 'nodes.dart';
import 'runtime.dart';

final RegExp _tagsRe = RegExp('(<!--.*?-->|<[^>]*>)');

/// Wrapper for functions that need [Context] as the first argument.
class ContextFilter {
  final Function function;
  const ContextFilter(this.function);
}

/// Wrapper for functions that need [Environment] as the first argument.
class EnvFilter {
  final Function function;
  const EnvFilter(this.function);
}

/// A wrapper for string which should not be auto-escaped.
class SafeString {
  const SafeString(this._value);

  final String _value;

  @override
  String toString() {
    return _value;
  }
}

/// Convert value to [bool]
/// - [bool] returns as is
/// - [num] returns `true` if `value` is not equal to `0.0`
/// - [String] returns `true` if `value` is not empty
/// - [Iterable] returns `true` if `value` is not empty
/// - [Map] returns `true` if `value` is not empty
/// - otherwise returns `true` if `value` is not `null`.
bool boolean(Object? value) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0.0;
  }

  if (value is String) {
    return value.isNotEmpty;
  }

  if (value is Iterable) {
    return value.isNotEmpty;
  }

  if (value is Map) {
    return value.isNotEmpty;
  }

  return value != null;
}

/// Identity function.
Object? identity(Object? value) {
  return value;
}

/// Return a pair of the `[key, value]` items of a mapping entry.
List<Object?> pair(MapEntry<Object?, Object?> entry) {
  return <Object?>[entry.key, entry.value];
}

/// Convert value to [Iterable]
/// - [Iterable] returns as is
/// - [String] returns chars split by `''`
/// - [Map] returns [Map.keys]
/// - otherwise throws [TypeError].
Iterable<Object?> iterate(Object? value) {
  if (value is Iterable) {
    return value;
  }

  if (value is String) {
    return value.split('');
  }

  if (value is Map) {
    return value.keys;
  }

  if (value is MapEntry) {
    return pair(value);
  }

  throw TypeError();
}

/// Convert value to [List].
///
/// If `value` is `null` returns empty [List] else calls [iterate] and returns
/// [List] as is or wraps returned iterable with [List.of].
List<Object?> list(Object? value) {
  if (value == null) {
    return <Object?>[];
  }

  if (value is List) {
    return value;
  }

  return List<Object?>.of(iterate(value));
}

/// Creates an [Iterable] of [int]s that iterates from `start` to `stop` by `step`.
Iterable<int> range(int startOrStop, [int? stop, int step = 1]) sync* {
  if (step == 0) {
    // TODO(utils): add message
    throw ArgumentError.value(step, 'step', "Step can't be zero.");
  }

  int start;

  if (stop == null) {
    start = 0;
    stop = startOrStop;
  } else {
    start = startOrStop;
  }

  if (step > 0) {
    for (var i = start; i < stop; i += step) {
      yield i;
    }
  } else {
    for (var i = start; i >= stop; i += step) {
      yield i;
    }
  }
}

/// HTML escape [Converter].
final HtmlEscape htmlEscape = HtmlEscape(
  HtmlEscapeMode(
    escapeLtGt: true,
    escapeQuot: true,
    escapeApos: true,
  ),
);

/// HTML unescape [Converter].
final HtmlUnescape htmlUnescape = HtmlUnescape();

String escape(String text) {
  return htmlEscape.convert(text);
}

/// Serialize an object to a string of JSON with [JsonEncoder], then replace
/// HTML-unsafe characters with Unicode escapes.
///
/// This is available in templates as the `|tojson` filter.
///
/// The following characters are escaped: `<`, `>`, `&`, `'`.
///
/// {@macro jinja.safestring}
String htmlSafeJsonEncode(Object? value, [String? indent]) {
  var encoder = indent == null ? json.encoder : JsonEncoder.withIndent(indent);

  return encoder.convert(value).replaceAll('<', '\\u003c').replaceAll('>', '\\u003e').replaceAll('&', '\\u0026').replaceAll("'", '\\u0027');
}

String unescape(String text) {
  return htmlUnescape.convert(text);
}

/// Capitalize a value.
String capitalize(String value) {
  if (value.isEmpty) {
    return '';
  }

  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}

/// Remove tags and normalize whitespace to single spaces.
String stripTags(String value) {
  if (value.isEmpty) {
    return '';
  }

  return unescape(
    RegExp(r'\s+').split(value.replaceAll(_tagsRe, '')).join(' '),
  );
}

/// Sum two values.
// TODO(utils): move to op context
Object? sum(dynamic left, Object? right) {
  // TODO(dynamic): dynamic invocation
  // ignore: avoid_dynamic_calls
  return left + right;
}

// Error Context Utilities

/// Sensitive data patterns that should be excluded from context snapshots.
final _sensitivePatterns = [
  RegExp(r'.*password.*', caseSensitive: false),
  RegExp(r'.*secret.*', caseSensitive: false),
  RegExp(r'.*token.*', caseSensitive: false),
  RegExp(r'.*key.*', caseSensitive: false),
  RegExp(r'.*api_key.*', caseSensitive: false),
  RegExp(r'.*auth.*', caseSensitive: false),
];

/// Safely capture context state with size limits.
///
/// Limits context to [maxVariables] variables and [maxSize] total size.
/// Returns a sanitized context map suitable for error reporting.
Map<String, Object?> captureContext(
  Context context, {
  int maxVariables = 50,
  int maxSize = 10240,
}) {
  final snapshot = <String, Object?>{};
  var currentSize = 0;
  var variableCount = 0;

  // Capture context variables
  for (var entry in context.context.entries) {
    if (variableCount >= maxVariables) {
      break;
    }

    // Check if key matches sensitive patterns
    var isSensitive = _sensitivePatterns.any((pattern) => pattern.hasMatch(entry.key));
    if (isSensitive) {
      continue;
    }

    var valueStr = _valueToString(entry.value);
    var entrySize = entry.key.length + valueStr.length + 10; // Rough estimate

    if (currentSize + entrySize > maxSize) {
      break;
    }

    snapshot[entry.key] = entry.value;
    currentSize += entrySize;
    variableCount++;
  }

  return snapshot;
}

/// Remove sensitive data from context map.
///
/// Returns a new map with sensitive keys removed based on pattern matching.
Map<String, Object?> sanitizeForLogging(Map<String, Object?> context) {
  final sanitized = <String, Object?>{};

  for (var entry in context.entries) {
    var isSensitive = _sensitivePatterns.any((pattern) => pattern.hasMatch(entry.key));
    if (!isSensitive) {
      sanitized[entry.key] = entry.value;
    }
  }

  return sanitized;
}

/// Get human-readable node type name.
String getNodeType(Node node) {
  var typeName = node.runtimeType.toString();
  // Remove common suffixes and make readable
  typeName = typeName.replaceAll('Node', '').replaceAll('Expression', '').replaceAll('Statement', '');
  if (typeName.isEmpty) {
    typeName = node.runtimeType.toString();
  }
  return typeName;
}

/// Format comprehensive error report.
///
/// Returns a formatted string with all error context information.
String formatErrorReport(TemplateError error) {
  return error.toString();
}

/// Fuzzy match variable names for typo detection.
///
/// Returns up to [maxResults] similar variable names from [available] names.
List<String> getSimilarNames(
  String name,
  Iterable<String> available, {
  int maxResults = 5,
}) {
  if (available.isEmpty) {
    return [];
  }

  // Simple Levenshtein-like distance calculation
  int distance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final matrix = List.generate(
      s1.length + 1,
      (_) => List.generate(s2.length + 1, (_) => 0),
    );

    for (var i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= s1.length; i++) {
      for (var j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  // Calculate distances and sort
  final distances = <(String, int)>[];
  for (var availableName in available) {
    final dist = distance(name.toLowerCase(), availableName.toLowerCase());
    distances.add((availableName, dist));
  }

  distances.sort((a, b) => a.$2.compareTo(b.$2));

  // Return top matches (within reasonable distance)
  final maxDistance = (name.length / 2).ceil();
  return distances.where((entry) => entry.$2 <= maxDistance).take(maxResults).map((entry) => entry.$1).toList();
}

/// Zone key used to store the current rendering call stack.
const Object _renderCallStackKey = Object();

/// Internal representation of a single rendering frame.
///
/// This describes where we are in template rendering, for example:
/// - template path
/// - line number (if available)
/// - human readable description, e.g. "template root", "macro renderUser", "include sidebar.html"
class _RenderFrame {
  const _RenderFrame({
    this.templatePath,
    this.line,
    required this.description,
  });

  final String? templatePath;
  final int? line;
  final String description;
}

List<_RenderFrame> _getCurrentFrames() {
  final frames = Zone.current[_renderCallStackKey] as List<_RenderFrame>?;
  if (frames == null) {
    return const <_RenderFrame>[];
  }
  return frames;
}

T _withRenderFrame<T>(_RenderFrame frame, T Function() body) {
  final current = _getCurrentFrames();
  final updated = List<_RenderFrame>.of(current)..add(frame);
  return runZoned<T>(
    body,
    zoneValues: <Object?, Object?>{
      _renderCallStackKey: updated,
    },
  );
}

Future<T> _withRenderFrameAsync<T>(
  _RenderFrame frame,
  Future<T> Function() body,
) {
  final current = _getCurrentFrames();
  final updated = List<_RenderFrame>.of(current)..add(frame);
  return runZoned<Future<T>>(
    () => body(),
    zoneValues: <Object?, Object?>{
      _renderCallStackKey: updated,
    },
  );
}

T withRenderFrame<T>({
  String? templatePath,
  int? line,
  required String description,
  required T Function() body,
}) {
  return _withRenderFrame<T>(
    _RenderFrame(
      templatePath: templatePath,
      line: line,
      description: description,
    ),
    body,
  );
}

Future<T> withRenderFrameAsync<T>({
  String? templatePath,
  int? line,
  required String description,
  required Future<T> Function() body,
}) {
  return _withRenderFrameAsync<T>(
    _RenderFrame(
      templatePath: templatePath,
      line: line,
      description: description,
    ),
    body,
  );
}

/// Capture rendering call stack.
///
/// Returns a list of call stack frames (max [maxDepth] frames).
List<String> captureCallStack({int maxDepth = 10}) {
  if (maxDepth <= 0) {
    return <String>[];
  }

  final frames = _getCurrentFrames();

  if (frames.isNotEmpty) {
    final result = <String>[];
    for (var i = 0; i < frames.length && i < maxDepth; i++) {
      final frame = frames[i];
      final path = frame.templatePath ?? '<unknown>';
      final linePart = frame.line != null ? ':${frame.line}' : '';
      result.add('$path$linePart (${frame.description})');
    }
    return result;
  }

  // Fallback to Dart stack trace when no rendering call stack is available.
  final stackLines = StackTrace.current.toString().split('\n');
  final result = <String>[];
  for (final line in stackLines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    result.add(trimmed);
    if (result.length >= maxDepth) {
      break;
    }
  }

  return result;
}

/// Generate actionable suggestions based on error type.
///
/// Returns a list of suggestions for fixing the error.
List<String> getErrorSuggestions(TemplateError error) {
  final suggestions = <String>[];

  if (error is UndefinedError) {
    if (error.variableName != null) {
      suggestions.add(
        'Check if \'${error.variableName}\' is defined before using it: '
        '{% if ${error.variableName} %}...{% endif %}',
      );

      if (error.similarNames != null && error.similarNames!.isNotEmpty) {
        suggestions.add(
          'Did you mean one of these? ${error.similarNames!.join(', ')}',
        );
      }

      suggestions.add(
        'Ensure \'${error.variableName}\' is passed to the template context',
      );
    }
  } else if (error is TemplateRuntimeError) {
    if (error.operation != null) {
      if (error.operation!.contains('attribute')) {
        suggestions.add('Check if the object is null before accessing attributes');
        suggestions.add(
          'Use conditional rendering: {% if object %}{{ object.attr }}{% endif %}',
        );
      } else if (error.operation!.contains('item')) {
        suggestions.add('Check if the key exists before accessing items');
        suggestions.add('Verify the key type matches the object type');
      }
    }
  } else if (error is TemplateSyntaxError) {
    suggestions.add('Check the template syntax at the indicated line and column');
    suggestions.add('Verify all tags are properly closed');
    suggestions.add('Check for typos in tag names');
  }

  return suggestions;
}

/// Convert a value to a string representation for logging.
///
/// Handles null, long strings, and complex objects.
String _valueToString(Object? value) {
  if (value == null) {
    return 'null';
  }

  if (value is String) {
    return value.length > 100 ? '${value.substring(0, 100)}...' : value;
  }

  try {
    final str = value.toString();
    return str.length > 100 ? '${str.substring(0, 100)}...' : str;
  } catch (e) {
    // If toString() throws (e.g., MyMap.keys throws UnimplementedError),
    // return a safe representation without calling methods that might fail
    return '${value.runtimeType}(toString failed: ${e.runtimeType})';
  }
}

/// Helper to extract a context snippet with a caret for error display.
String errorContextSnippet(
  String source,
  int line,
  int column, {
  int contextLines = 1,
}) {
  var lines = source.split('\n');
  var buffer = StringBuffer();
  if (lines.isEmpty) {
    return '';
  }
  // Clamp line and column to valid ranges
  // Ensure line is at least 1 (1-based index)
  var safeLine = line < 1 ? 1 : line;
  if (safeLine > lines.length) safeLine = lines.length;

  var start = (safeLine - contextLines - 1).clamp(0, lines.length - 1);
  var end = (safeLine + contextLines - 1).clamp(0, lines.length - 1);

  for (var i = start; i <= end; i++) {
    var lineNum = i + 1;
    buffer.writeln('$lineNum: ${lines[i]}');
    if (lineNum == safeLine && column > 0) {
      var caretPos = column - 1;
      if (caretPos <= lines[i].length) {
        buffer.writeln('${' ' * (lineNum.toString().length + 3 + caretPos)}^');
      }
    }
  }
  return buffer.toString();
}
