import 'dart:convert';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:textwrap/textwrap.dart' show TextWrapper;

import 'environment.dart';
import 'exceptions.dart';
import 'runtime.dart';
import 'utils.dart' as utils;

final RegExp _wordBeginningSplitRe = RegExp('([-\\s({\\[<]+)');

final RegExp _wordRe = RegExp('\\w+');

Iterable<Object> _prepareAttributeParts(Object? attribute) sync* {
  if (attribute == null) {
    return;
  }

  if (attribute is String) {
    for (var part in attribute.split('.')) {
      yield int.tryParse(part) ?? part;
    }
  } else {
    yield attribute;
  }
}

/// Returns a callable that looks up the given attribute from a
/// passed object with the rules of the environment.
Object? Function(Object? object) makeAttributeGetter(
  Environment environment,
  Object attribute, {
  Object? defaultValue,
}) {
  var parts = _prepareAttributeParts(attribute);

  Object? getter(Object? object) {
    for (var part in parts) {
      if (part is String) {
        object = environment.getAttribute(part, object, node: attribute) ?? defaultValue;
      } else {
        object = environment.getItem(part, object, node: attribute) ?? defaultValue;
      }
    }

    return object;
  }

  return getter;
}

/// Returns a callable that looks up the given item from a passed object with
/// the rules of the environment.
Object? Function(Object?) makeItemGetter(
  Environment environment,
  Object item, {
  Object? defaultValue,
  Object? attribute,
}) {
  Object? getter(Object? object) {
    return environment.getItem(item, object, node: attribute) ?? defaultValue;
  }

  return getter;
}

Object? doSafe(Object? value) {
  if (value is utils.SafeString) {
    return value;
  }
  return utils.SafeString(value?.toString() ?? '');
}

String doEscape(Object? value) {
  if (value is utils.SafeString) {
    return value.toString();
  }
  return utils.escape(value?.toString() ?? '');
}

String doString(Object? value) {
  return value.toString();
}

String doReplace(
  String value,
  String from,
  String to, [
  int? count,
]) {
  if (count == null) {
    value = value.replaceAll(from, to);
  } else {
    var start = value.indexOf(from);
    var n = 0;

    while (n < count && start != -1 && start < value.length) {
      value = value.replaceRange(start, start + from.length, to);
      start = value.indexOf(from, start + to.length);
      n += 1;
    }
  }

  return value;
}

String doReplaceEach(
  String value,
  String from,
  String to, [
  int? count,
]) {
  if (count == null) {
    for (var element in from.split('').toList()) {
      value = value.replaceAll(element, to);
    }
  } else {
    var start = value.indexOf(from);
    var n = 0;

    while (n < count && start != -1 && start < value.length) {
      value = value.replaceRange(start, start + from.length, to);
      start = value.indexOf(from, start + to.length);
      n += 1;
    }
  }

  return value;
}

String doRegexReplace(
  String value,
  String from,
  String to,
) {
  RegExp regex = RegExp(from);
  return value.replaceAll(regex, to);
}

String doUpper(String value) {
  return value.toUpperCase();
}

String doLower(String value) {
  return value.toLowerCase();
}

Iterable<List<Object?>> doItems(Map<Object?, Object?>? value) {
  if (value == null) {
    return Iterable<List<Object?>>.empty();
  }
  return value.entries.map<List<Object?>>(utils.pair);
}

String doCapitalize(String value) {
  return utils.capitalize(value);
}

String doTitle(String value) {
  if (value.isEmpty) {
    return '';
  }
  return value.splitMapJoin(
    _wordBeginningSplitRe,
    onMatch: (match) => match.group(0)!,
    onNonMatch: (nonMatch) => utils.capitalize(nonMatch),
  );
}

List<Object?> doDictSort(
  Map<Object?, Object?> dict, {
  bool caseSensetive = false,
  String by = 'key',
  bool reverse = false,
}) {
  var position = switch (by) {
    'key' => 0,
    'value' => 1,
    Object? value => throw ArgumentError.value(
        value,
        'by'
        "You can only sort by either 'key' or 'value'."),
  };

  var order = reverse ? -1 : 1;
  var entities = dict.entries.map<List<Object?>>(utils.pair).toList();

  Comparable<Object?> Function(List<Object?> values) get;

  if (caseSensetive) {
    get = (values) => values[position] as Comparable<Object?>;
  } else {
    get = (values) {
      var value = values[position];
      if (value case String string) {
        return string.toLowerCase();
      }
      return value as Comparable<Object?>;
    };
  }

  int sort(List<Object?> left, List<Object?> right) {
    return get(left).compareTo(get(right)) * order;
  }

  entities.sort(sort);
  return entities;
}

List<Object?> doSort(
  Environment environment,
  Iterable<Object?> value, {
  bool reverse = false,
  bool caseSensitive = false,
  Object? attribute,
}) {
  var list = List<Object?>.from(value);

  if (attribute != null) {
    var getter = makeAttributeGetter(environment, attribute);
    list.sort((a, b) {
      var valA = getter(a);
      var valB = getter(b);
      return _compare(valA, valB, caseSensitive);
    });
  } else {
    list.sort((a, b) => _compare(a, b, caseSensitive));
  }

  if (reverse) {
    return list.reversed.toList();
  }

  return list;
}

int _compare(Object? a, Object? b, bool caseSensitive) {
  if (a == null && b == null) return 0;
  if (a == null) return -1;
  if (b == null) return 1;

  if (a is String && b is String && !caseSensitive) {
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  if (a is Comparable && b is Comparable) {
    try {
      return a.compareTo(b);
    } catch (_) {}
  }

  return a.toString().compareTo(b.toString());
}

Object? doDefault(
  Object? value, [
  Object? defaultValue = '',
  bool asBool = false,
]) {
  if (asBool) {
    return utils.boolean(value) ? value : defaultValue;
  }
  return value ?? defaultValue;
}

Object doJoin(
  Iterable<Object?> values, [
  String delimiter = '',
  Object? attribute,
]) {
  return values.join(delimiter);
}

String doCenter(String value, int width) {
  if (value.length >= width) {
    return value;
  }
  var padLength = (width - value.length) ~/ 2;
  var pad = ' ' * padLength;
  return pad + value + pad;
}

Object? doFirst(Object? values) {
  var list = utils.list(values);
  if (list.isEmpty) return null;
  return list.first;
}

Object? doLast(Object? values) {
  var list = utils.list(values);
  if (list.isEmpty) return null;
  return list.last;
}

Object? doRandom(Environment environment, Object? value) {
  if (value == null) {
    return null;
  }
  var values = utils.list(value);
  if (values.isEmpty) return null;
  var index = environment.random.nextInt(values.length);
  var result = values[index];
  if (value case Map<Object?, Object?> map) {
    return map[result];
  }
  return result;
}

String doFileSizeFormat(Object? value, [bool binary = false]) {
  const suffixes = <List<String>>[
    <String>[' KiB', ' kB'],
    <String>[' MiB', ' MB'],
    <String>[' GiB', ' GB'],
    <String>[' TiB', ' TB'],
    <String>[' PiB', ' PB'],
    <String>[' EiB', ' EB'],
    <String>[' ZiB', ' ZB'],
    <String>[' YiB', ' YB'],
  ];

  var base = binary ? 1024 : 1000;

  var bytes = switch (value) {
    num number => number.toDouble(),
    String string => double.parse(string),
    _ => throw TypeError(),
  };

  if (bytes == 1.0) {
    return '1 Byte';
  }

  if (bytes < base) {
    var size = bytes.toStringAsFixed(1);
    if (size.endsWith('.0')) {
      return '${size.substring(0, size.length - 2)} Bytes';
    }
    return '$size Bytes';
  }

  var k = binary ? 0 : 1;
  num unit = 0.0;

  for (var i = 0; i < suffixes.length; i += 1) {
    unit = math.pow(base, i + 2);
    if (bytes < unit) {
      return (base * bytes / unit).toStringAsFixed(1) + suffixes[i][k];
    }
  }

  return (base * bytes / unit).toStringAsFixed(1) + suffixes.last[k];
}

String doTruncate(
  String value, [
  int length = 255,
  bool killWords = false,
  String end = '...',
  int leeway = 5,
]) {
  if (length < end.length) {
    throw ArgumentError.value(value, 'leeway', 'Expected length >= ${end.length}, got $length.');
  } else if (leeway < 0) {
    throw ArgumentError.value(value, 'leeway', 'Expected leeway >= 0, got $leeway.');
  }

  if (value.length <= length + leeway) {
    return value;
  }

  var substring = value.substring(0, length - end.length);

  if (killWords) {
    return substring + end;
  }

  var found = substring.lastIndexOf(' ');

  if (found == -1) {
    return substring + end;
  }

  return substring.substring(0, found) + end;
}

String doWordWrap(
  Environment environment,
  String value,
  int width, {
  bool breakLongWords = true,
  String? wrapString,
  bool breakOnHyphens = true,
}) {
  var wrapper = TextWrapper(
    width: width,
    expandTabs: false,
    replaceWhitespace: false,
    breakLongWords: breakLongWords,
    breakOnHyphens: breakOnHyphens,
  );

  var wrap = wrapString ?? environment.newLine;
  return const LineSplitter().convert(value).expand<String>(wrapper.wrap).join(wrap);
}

int doWordCount(Object? value) {
  var matches = _wordRe.allMatches(value.toString());
  return matches.length;
}

int doInteger(Object? value, {int defaultValue = 0, int base = 10}) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value, radix: base) ?? defaultValue;
  return defaultValue;
}

double doFloat(Object? value, [double defaultValue = 0.0]) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

num doAbs(num number) {
  return number.abs();
}

String doTrim(String value, [String? characters]) {
  if (characters == null) {
    return value.trim();
  }
  var left = RegExp('^[$characters]+', multiLine: true);
  var right = RegExp('[$characters]+\$', multiLine: true);
  return value.replaceAll(left, '').replaceAll(right, '');
}

String doStripTags(String value) {
  return utils.stripTags(value);
}

List<List<Object?>> doSlice(Object? value, int slices, [Object? fillWith]) {
  var result = <List<Object?>>[];
  var values = utils.list(value);
  var length = values.length;
  var perSlice = length ~/ slices;
  var withExtra = length % slices;

  for (var i = 0, offset = 0; i < slices; i += 1) {
    var start = offset + i * perSlice;
    if (i < withExtra) {
      offset += 1;
    }
    var end = offset + (i + 1) * perSlice;
    var tmp = values.sublist(start, end);
    if (fillWith != null && i >= withExtra) {
      tmp.add(fillWith);
    }
    result.add(tmp);
  }
  return result;
}

List<List<Object?>> doBatch(
  Iterable<Object?> items,
  int lineCount, [
  Object? fillWith,
]) {
  var result = <List<Object?>>[];
  var temp = <Object?>[];

  for (var item in items) {
    if (temp.length == lineCount) {
      result.add(temp);
      temp = <Object?>[];
    }
    temp.add(item);
  }

  if (temp.isNotEmpty) {
    if (fillWith != null) {
      temp += List<Object?>.filled(lineCount - temp.length, fillWith);
    }
    result.add(temp);
  }
  return result;
}

int? doLength(dynamic object) {
  try {
    if (object == null) return 0;
    if (object is String) return object.length;
    if (object is Iterable) return object.length;
    if (object is Map) return object.length;
    // ignore: avoid_dynamic_calls
    return object.length as int;
  } on NoSuchMethodError {
    return 0;
  }
}

dynamic doSum(
  Environment environment,
  Iterable<Object?> values, {
  Object? attribute,
  num start = 0,
}) {
  if (attribute != null) {
    var getter = makeAttributeGetter(environment, attribute);
    values = values.map(getter);
  }

  // Check if we have futures in the values
  if (values.any((v) => v is Future)) {
    return Future(() async {
      var resolvedValues = <Object?>[];
      for (var v in values) {
        resolvedValues.add(v is Future ? await v : v);
      }
      return resolvedValues.cast<dynamic>().fold<dynamic>(start, utils.sum);
    });
  }

  return values.cast<dynamic>().fold<dynamic>(start, utils.sum);
}

List<Object?> doList(Object? object) {
  return utils.list(object);
}

Object? doReverse(Object? value) {
  var values = utils.list(value);
  return values.reversed;
}

Object? Function(Object? object) _prepareMap(
  Context context,
  List<Object?> positional,
  Map<Object?, Object?> named,
) {
  if (positional.isEmpty) {
    // Handle attribute parameter
    if (named.remove('attribute') ?? named.remove(#attribute) case String attribute?) {
      var defaultValue =
          named.remove('defaultValue') ?? named.remove('default') ?? named.remove(#defaultValue) ?? named.remove(Symbol('default'));
      if (named.isNotEmpty) {
        var first = named.keys.first;
        throw ArgumentError.value(named[first], first.toString(), 'Unexpected keyword argument.');
      }
      return makeAttributeGetter(context.environment, attribute, defaultValue: defaultValue);
    }

    // Handle item parameter
    if (named.remove('item') ?? named.remove(#item) case Object? item?) {
      var defaultValue =
          named.remove('defaultValue') ?? named.remove('default') ?? named.remove(#defaultValue) ?? named.remove(Symbol('default'));
      if (named.isNotEmpty) {
        var first = named.keys.first;
        throw ArgumentError.value(named[first], first.toString(), 'Unexpected keyword argument.');
      }
      return (Object? object) {
        var value = context.item(item, object, context.environment);
        return value ?? defaultValue;
      };
    }
  }

  try {
    var name = positional.first as String;
    positional = positional.sublist(1);
    var symbols = <Symbol, Object?>{};

    named.forEach((key, value) {
      if (key is Symbol) {
        symbols[key] = value;
      } else if (key is String) {
        symbols[Symbol(key)] = value;
      }
    });

    // Return a closure that handles both sync and async results from the filter
    Object? getter(Object? object) {
      return context.filter(name, <Object?>[object, ...positional], symbols);
    }

    return getter;
  } on StateError {
    throw ArgumentError('Map requires a filter argument.', 'filter');
  } on RangeError {
    throw ArgumentError('Map requires a filter argument.', 'filter');
  }
}

Iterable<Object?> doMap(
  Context context,
  Iterable<Object?>? values,
  List<Object?> positional,
  Map<Object?, Object?> named,
) sync* {
  if (values != null) {
    // Handle case where compiler transformation puts keyword arguments
    // as a Map in positional arguments (backward compatibility)
    var finalNamed = Map<Object?, Object?>.from(named);
    var finalPositional = List<Object?>.from(positional);

    // Check if any positional argument is a Map that should be merged into named
    // This handles the case where the compiler puts keywords as Dict in arguments
    // When Function.apply calls doMap, if the Map is the 4th positional arg,
    // it becomes the 'named' parameter. But if it's nested in the 'positional' list,
    // we need to extract it here.
    for (var i = finalPositional.length - 1; i >= 0; i--) {
      if (finalPositional[i] is Map<Object?, Object?>) {
        finalNamed.addAll(finalPositional[i] as Map<Object?, Object?>);
        finalPositional.removeAt(i);
      }
    }

    var func = _prepareMap(context, finalPositional, finalNamed.cast<String, Object?>());
    for (var value in values) {
      yield func(value);
    }
  }
}

Object? doAttribute(Environment environment, Object? value, String attribute) {
  return environment.getAttribute(attribute, value, node: environment);
}

Object? doItem(Environment environment, Object? value, Object item) {
  return environment.getItem(item, value, node: environment);
}

String doToJson(Object? value, [bool? indent]) {
  return utils.htmlSafeJsonEncode(value, indent == true ? '  ' : null);
}

String doRuntimeType(dynamic object) {
  // If it's a TemplateErrorWrapper, return the original error's runtime type
  // This allows templates to access the original error type even when wrapped
  if (object is TemplateErrorWrapper) {
    return object.originalError.runtimeType.toString();
  }
  return object.runtimeType.toString();
}

String doUrlEncode(Object? value) {
  if (value == null) return '';
  if (value is Map) {
    var parts = <String>[];
    for (var entry in value.entries) {
      parts.add('${Uri.encodeQueryComponent(entry.key.toString())}=${Uri.encodeQueryComponent(entry.value.toString())}');
    }
    return parts.join('&');
  }
  return Uri.encodeQueryComponent(value.toString());
}

String doXmlAttr(Map<Object?, Object?>? d, {bool autospace = true}) {
  if (d == null) return '';
  var parts = <String>[];
  for (var entry in d.entries) {
    if (entry.value == null) continue;
    parts.add('${entry.key}="${utils.escape(entry.value.toString())}"');
  }
  var result = parts.join(' ');
  return (autospace && result.isNotEmpty) ? ' $result' : result;
}

List<Object?> doUnique(
  Environment environment,
  Iterable<Object?> value, {
  bool caseSensitive = false,
  Object? attribute,
}) {
  var list = List<Object?>.from(value);
  if (attribute != null) {
    var getter = makeAttributeGetter(environment, attribute);
    var seen = <Object?>{};
    var result = <Object?>[];
    for (var item in list) {
      var key = getter(item);
      if (caseSensitive == false && key is String) {
        key = key.toLowerCase();
      }
      if (seen.add(key)) {
        result.add(item);
      }
    }
    return result;
  } else {
    if (caseSensitive == false) {
      var seen = <Object?>{};
      var result = <Object?>[];
      for (var item in list) {
        var key = item;
        if (key is String) key = key.toLowerCase();
        if (seen.add(key)) {
          result.add(item);
        }
      }
      return result;
    }
    return list.toSet().toList();
  }
}

Object? doMin(
  Environment environment,
  Iterable<Object?> value, {
  bool caseSensitive = false,
  Object? attribute,
}) {
  if (value.isEmpty) return null;
  var sorted = doSort(environment, value, caseSensitive: caseSensitive, attribute: attribute);
  return sorted.first;
}

Object? doMax(
  Environment environment,
  Iterable<Object?> value, {
  bool caseSensitive = false,
  Object? attribute,
}) {
  if (value.isEmpty) return null;
  var sorted = doSort(environment, value, caseSensitive: caseSensitive, attribute: attribute);
  return sorted.last;
}

List<Object?> doIntersect(Iterable<Object?> value, Iterable<Object?> other) {
  var set1 = value.toSet();
  var set2 = other.toSet();
  return set1.intersection(set2).toList();
}

List<Object?> doDifference(Iterable<Object?> value, Iterable<Object?> other) {
  var set1 = value.toSet();
  var set2 = other.toSet();
  return set1.difference(set2).toList();
}

String doPPrint(Object? value) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(value);
}

Object? doFromJson(String value) {
  return json.decode(value);
}

String doBase64Encode(Object? value) {
  if (value is List<int>) {
    return base64.encode(value);
  }
  return base64.encode(utf8.encode(value.toString()));
}

String doBase64Decode(String value) {
  return utf8.decode(base64.decode(value));
}

String doSlugify(String value) {
  value = value.toLowerCase().trim();
  value = value.replaceAll(RegExp(r'[^a-z0-9\s-]'), '');
  value = value.replaceAll(RegExp(r'[\s-]+'), '-');
  return value;
}

String doUrlize(
  String value, {
  int trimUrlLimit = 0,
  bool nofollow = false,
  String? target,
  String rel = '',
}) {
  final urlRegex = RegExp(r'https?://[^\s<]+');
  return value.replaceAllMapped(urlRegex, (match) {
    var url = match.group(0)!;
    var displayUrl = url;
    if (trimUrlLimit > 0 && url.length > trimUrlLimit) {
      displayUrl = '${url.substring(0, trimUrlLimit - 3)}...';
    }
    var relAttr = rel.isNotEmpty ? ' rel="$rel"' : '';
    if (nofollow) {
      relAttr = ' rel="nofollow$relAttr"';
    }
    var targetAttr = target != null ? ' target="$target"' : '';
    return '<a href="$url"$targetAttr$relAttr>$displayUrl</a>';
  });
}

String doIndent(String value, [int width = 4, bool first = false, bool blank = false]) {
  var indent = ' ' * width;
  var lines = const LineSplitter().convert(value);
  var buffer = StringBuffer();

  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    if (i == 0 && !first) {
      buffer.writeln(line);
    } else {
      if (line.isEmpty && !blank) {
        buffer.writeln(line);
      } else {
        buffer.writeln('$indent$line');
      }
    }
  }
  var result = buffer.toString();
  if (result.endsWith('\n') && !value.endsWith('\n')) {
    return result.substring(0, result.length - 1);
  }
  return result;
}

String doQuote(Object? value) {
  return '"$value"';
}

String doStrftime(Object? value, [String format = 'yyyy-MM-dd']) {
  DateTime? date;
  if (value is DateTime) {
    date = value;
  } else if (value is String) {
    date = DateTime.tryParse(value);
  }
  if (date == null) return value.toString();
  try {
    return DateFormat(format).format(date);
  } catch (e) {
    return date.toString();
  }
}

num doIncrement(num value) {
  return value + 1;
}

num doRound(num value, [int precision = 0, String method = 'common']) {
  if (method == 'common') {
    if (precision == 0) return value.round();
    var mod = math.pow(10, precision);
    return (value * mod).round() / mod;
  } else if (method == 'ceil') {
    if (precision == 0) return value.ceil();
    var mod = math.pow(10, precision);
    return (value * mod).ceil() / mod;
  } else if (method == 'floor') {
    if (precision == 0) return value.floor();
    var mod = math.pow(10, precision);
    return (value * mod).floor() / mod;
  }
  return value;
}

num doRoundToEven(num value) {
  var integer = value.truncate();
  var decimal = (value - integer).abs();
  if (decimal == 0.5) {
    return integer.isEven ? integer : integer + (value.sign.toInt());
  }
  return value.round();
}

Map<Object?, List<Object?>> doGroupBy(
  Environment environment,
  Iterable<Object?> value,
  Object attribute,
) {
  var getter = makeAttributeGetter(environment, attribute);
  return groupBy(value, (item) => getter(item));
}

Object doSelect(
  Context context,
  Iterable<Object?> value,
  String testName, [
  List<Object?>? args,
]) {
  var test = context.environment.tests[testName];
  if (test == null) throw TemplateRuntimeError("No test named '$testName'.");

  var positionalArgs = args ?? const [];

  Function func;
  bool needsContext = false;
  bool needsEnvironment = false;

  if (test is utils.ContextFilter) {
    func = test.function;
    needsContext = true;
  } else if (test is utils.EnvFilter) {
    func = test.function;
    needsEnvironment = true;
  } else if (test is Function) {
    func = test;
  } else {
    throw TemplateRuntimeError('Test "$testName" is not a function.');
  }

  List<Object?> getPositional(Object? item) {
    var positional = [item, ...positionalArgs];
    if (needsContext) {
      return [context, ...positional];
    } else if (needsEnvironment) {
      return [context.environment, ...positional];
    }
    return positional;
  }

  var results = <Object?>[];
  bool isAsync = false;

  for (var item in value) {
    var result = Function.apply(func, getPositional(item));
    if (result is Future) {
      isAsync = true;
      break;
    }
    if (result == true) {
      results.add(item);
    }
  }

  if (isAsync) {
    return _doSelectAsync(context, value, testName, args);
  }
  return results;
}

Future<List<Object?>> _doSelectAsync(
  Context context,
  Iterable<Object?> value,
  String testName, [
  List<Object?>? args,
]) async {
  var test = context.environment.tests[testName]!;
  var results = <Object?>[];
  for (var item in value) {
    var result = await context.environment.callCommon(test, [item, ...?args], const {}, context);
    if (result == true) results.add(item);
  }
  return results;
}

Object doReject(
  Context context,
  Iterable<Object?> value,
  String testName, [
  List<Object?>? args,
]) {
  var test = context.environment.tests[testName];
  if (test == null) throw TemplateRuntimeError("No test named '$testName'.");

  var positionalArgs = args ?? const [];

  Function func;
  bool needsContext = false;
  bool needsEnvironment = false;

  if (test is utils.ContextFilter) {
    func = test.function;
    needsContext = true;
  } else if (test is utils.EnvFilter) {
    func = test.function;
    needsEnvironment = true;
  } else if (test is Function) {
    func = test;
  } else {
    throw TemplateRuntimeError('Test "$testName" is not a function.');
  }

  List<Object?> getPositional(Object? item) {
    var positional = [item, ...positionalArgs];
    if (needsContext) {
      return [context, ...positional];
    } else if (needsEnvironment) {
      return [context.environment, ...positional];
    }
    return positional;
  }

  var results = <Object?>[];
  bool isAsync = false;

  for (var item in value) {
    var result = Function.apply(func, getPositional(item));
    if (result is Future) {
      isAsync = true;
      break;
    }
    if (result == false) {
      results.add(item);
    }
  }

  if (isAsync) {
    return _doRejectAsync(context, value, testName, args);
  }
  return results;
}

Future<List<Object?>> _doRejectAsync(
  Context context,
  Iterable<Object?> value,
  String testName, [
  List<Object?>? args,
]) async {
  var test = context.environment.tests[testName]!;
  var results = <Object?>[];
  for (var item in value) {
    var result = await context.environment.callCommon(test, [item, ...?args], const {}, context);
    if (result == false) results.add(item);
  }
  return results;
}

Object doSelectAttr(
  Context context,
  Iterable<Object?> value,
  Object attribute, [
  String? testName,
  List<Object?>? args,
]) {
  testName ??= 'defined';
  var test = context.environment.tests[testName];
  if (test == null) throw TemplateRuntimeError("No test named '$testName'.");

  var getter = makeAttributeGetter(context.environment, attribute);
  var positionalArgs = args ?? const [];

  Function func;
  bool needsContext = false;
  bool needsEnvironment = false;

  if (test is utils.ContextFilter) {
    func = test.function;
    needsContext = true;
  } else if (test is utils.EnvFilter) {
    func = test.function;
    needsEnvironment = true;
  } else if (test is Function) {
    func = test;
  } else {
    throw TemplateRuntimeError('Test "$testName" is not a function.');
  }

  List<Object?> getPositional(Object? attrVal) {
    var positional = [attrVal, ...positionalArgs];
    if (needsContext) {
      return [context, ...positional];
    } else if (needsEnvironment) {
      return [context.environment, ...positional];
    }
    return positional;
  }

  var results = <Object?>[];
  bool isAsync = false;

  for (var item in value) {
    var attrVal = getter(item);
    var result = Function.apply(func, getPositional(attrVal));
    if (result is Future) {
      isAsync = true;
      break;
    }
    if (result == true) {
      results.add(item);
    }
  }

  if (isAsync) {
    return _doSelectAttrAsync(context, value, attribute, testName, args);
  }
  return results;
}

Future<List<Object?>> _doSelectAttrAsync(
  Context context,
  Iterable<Object?> value,
  Object attribute, [
  String? testName,
  List<Object?>? args,
]) async {
  var test = context.environment.tests[testName!]!;
  var getter = makeAttributeGetter(context.environment, attribute);
  var results = <Object?>[];
  for (var item in value) {
    var attrVal = getter(item);
    var result = await context.environment.callCommon(test, [attrVal, ...?args], const {}, context);
    if (result == true) results.add(item);
  }
  return results;
}

Object doRejectAttr(
  Context context,
  Iterable<Object?> value,
  Object attribute, [
  String? testName,
  List<Object?>? args,
]) {
  testName ??= 'defined';
  var test = context.environment.tests[testName];
  if (test == null) throw TemplateRuntimeError("No test named '$testName'.");

  var getter = makeAttributeGetter(context.environment, attribute);
  var positionalArgs = args ?? const [];

  Function func;
  bool needsContext = false;
  bool needsEnvironment = false;

  if (test is utils.ContextFilter) {
    func = test.function;
    needsContext = true;
  } else if (test is utils.EnvFilter) {
    func = test.function;
    needsEnvironment = true;
  } else if (test is Function) {
    func = test;
  } else {
    throw TemplateRuntimeError('Test "$testName" is not a function.');
  }

  List<Object?> getPositional(Object? attrVal) {
    var positional = [attrVal, ...positionalArgs];
    if (needsContext) {
      return [context, ...positional];
    } else if (needsEnvironment) {
      return [context.environment, ...positional];
    }
    return positional;
  }

  var results = <Object?>[];
  bool isAsync = false;

  for (var item in value) {
    var attrVal = getter(item);
    var result = Function.apply(func, getPositional(attrVal));
    if (result is Future) {
      isAsync = true;
      break;
    }
    if (result == false) {
      results.add(item);
    }
  }

  if (isAsync) {
    return _doRejectAttrAsync(context, value, attribute, testName, args);
  }
  return results;
}

Future<List<Object?>> _doRejectAttrAsync(
  Context context,
  Iterable<Object?> value,
  Object attribute, [
  String? testName,
  List<Object?>? args,
]) async {
  var test = context.environment.tests[testName!]!;
  var getter = makeAttributeGetter(context.environment, attribute);
  var results = <Object?>[];
  for (var item in value) {
    var attrVal = getter(item);
    var result = await context.environment.callCommon(test, [attrVal, ...?args], const {}, context);
    if (result == false) results.add(item);
  }
  return results;
}

Map<Object?, Object?> doCombine(Map<Object?, Object?> value, Map<Object?, Object?> other) {
  return {...value, ...other};
}

List<Object?> doShuffle(Environment environment, Iterable<Object?> value) {
  var list = List<Object?>.from(value);
  list.shuffle(environment.random);
  return list;
}

bool doBool(Object? value) => utils.boolean(value);
int doInt(Object? value, {int defaultValue = 0, int base = 10}) => doInteger(value, defaultValue: defaultValue, base: base);
double doFloatFilter(Object? value, [double defaultValue = 0.0]) => doFloat(value, defaultValue);

String doRegexReplaceFilter(String value, String pattern, String replacement, {bool ignoreCase = false}) {
  return value.replaceAll(RegExp(pattern, caseSensitive: !ignoreCase), replacement);
}

Object? doRegexSearch(String value, String pattern, {bool ignoreCase = false}) {
  return RegExp(pattern, caseSensitive: !ignoreCase).firstMatch(value)?.group(0);
}

List<String> doRegexFindall(String value, String pattern, {bool ignoreCase = false}) {
  return RegExp(pattern, caseSensitive: !ignoreCase).allMatches(value).map((m) => m.group(0)!).toList();
}

/// Filters map.
final Map<String, Object> filters = <String, Object>{
  'e': doEscape,
  'escape': doEscape,
  'safe': doSafe,
  'string': doString,
  'urlencode': doUrlEncode,
  'replace': doReplace,
  'replace_each': doReplaceEach,
  'regex_replace': doRegexReplaceFilter,
  'upper': doUpper,
  'lower': doLower,
  'items': doItems,
  'xmlattr': doXmlAttr,
  'capitalize': doCapitalize,
  'title': doTitle,
  'dictsort': doDictSort,
  'sort': utils.EnvFilter(doSort),
  'unique': utils.EnvFilter(doUnique),
  'min': utils.EnvFilter(doMin),
  'max': utils.EnvFilter(doMax),
  'd': doDefault,
  'default': doDefault,
  'join': doJoin,
  'center': doCenter,
  'first': doFirst,
  'last': doLast,
  'random': utils.EnvFilter(doRandom),
  'filesizeformat': doFileSizeFormat,
  'pprint': doPPrint,
  'urlize': doUrlize,
  'indent': doIndent,
  'truncate': doTruncate,
  'wordwrap': utils.EnvFilter(doWordWrap),
  'wordcount': doWordCount,
  'int': doInt,
  'float': doFloatFilter,
  'abs': doAbs,
  // 'format': doFormat,
  'trim': doTrim,
  'striptags': doStripTags,
  'slice': doSlice,
  'batch': doBatch,
  'round': doRound,
  'round_to_even': doRoundToEven,
  'groupby': utils.EnvFilter(doGroupBy),
  'count': doLength,
  'length': doLength,
  'sum': utils.EnvFilter(doSum),
  'list': doList,
  'reverse': doReverse,
  'attr': utils.EnvFilter(doAttribute),
  'item': utils.EnvFilter(doItem),
  'map': utils.ContextFilter(doMap),
  'select': utils.ContextFilter(doSelect),
  'reject': utils.ContextFilter(doReject),
  'selectattr': utils.ContextFilter(doSelectAttr),
  'rejectattr': utils.ContextFilter(doRejectAttr),
  'tojson': doToJson,
  'fromjson': doFromJson,
  'runtimetype': doRuntimeType,
  'intersect': doIntersect,
  'difference': doDifference,
  'slugify': doSlugify,
  'base64encode': doBase64Encode,
  'base64decode': doBase64Decode,
  'quote': doQuote,
  'strftime': doStrftime,
  'dateformat': doStrftime,
  'increment': doIncrement,
  'bool': doBool,
  'regex_search': doRegexSearch,
  'regex_findall': doRegexFindall,
  'shuffle': utils.EnvFilter(doShuffle),
  'combine': doCombine,
  'pluck': utils.ContextFilter(
    (Context context, Iterable<Object?>? values, String attribute) => doMap(context, values, [attribute], {}),
  ),
};
