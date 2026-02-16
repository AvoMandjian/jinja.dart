import 'dart:developer';

import 'environment.dart';
import 'exceptions.dart';
import 'nodes.dart';
import 'utils.dart';

typedef ContextCallback = void Function(Context context);

base class Context {
  Context(
    this.environment, {
    this.template,
    this.source,
    Map<String, List<ContextCallback>>? blocks,
    this.parent = const <String, Object?>{},
    Map<String, Object?>? data,
  })  : blocks = blocks ?? <String, List<ContextCallback>>{},
        context = <String, Object?>{...?data};

  final Environment environment;

  String? template;

  final String? source;

  final Map<String, List<ContextCallback>> blocks;

  final Map<String, Object?> parent;

  final Map<String, Object?> context;

  dynamic call(
    dynamic object,
    Object? node, [
    List<Object?> positional = const <Object?>[],
    Map<Symbol, Object?> named = const <Symbol, Object?>{},
  ]) {
    try {
      if (object is Function) {
        return environment.callCommon(object, positional, named, this);
      }

      if (object == null) {
        String? functionName;
        if (node is Call) {
          functionName = node.value.toSource();
        }
        final suggestions = <String>[
          'Check if the function is defined before calling it',
          if (functionName != null) 'Ensure \'$functionName\' is passed to the template context',
        ];
        throw TemplateRuntimeError(
          functionName != null ? 'The function $functionName is null at $positional' : 'Object is null at $positional',
          nodeValue: node is Node ? node : null,
          operationValue: 'Calling null function',
          suggestionsValue: suggestions,
          contextSnippetValue: (source != null && node is Node && node.line != null && node.column != null)
              ? errorContextSnippet(source!, node.line!, node.column!)
              : null,
        );
      }

      // Handle LoopContext specially - it has a call method that should be called directly
      if (object is LoopContext) {
        if (positional.isEmpty) {
          final suggestions = <String>[
            'LoopContext.call() requires at least one argument (the iterable to recurse)',
            'Usage: {{ loop(items) }}',
          ];
          throw TemplateRuntimeError(
            'LoopContext.call() requires an iterable argument.',
            nodeValue: node is Node ? node : null,
            operationValue: 'Calling LoopContext without arguments',
            suggestionsValue: suggestions,
          );
        }
        return object.call(positional[0]);
      }

      // Handle ContextFilter and EnvFilter - they wrap functions that need special handling
      if (object is ContextFilter || object is EnvFilter) {
        // These are handled by callCommon, which will extract the function and add context/env
        return environment.callCommon(object, positional, named, this);
      }

      // Try to find a 'call' method on the object (for callable classes)
      try {
        final callMethod = (object as dynamic).call;
        if (callMethod is Function) {
          return environment.callCommon(callMethod, positional, named, this);
        }
      } catch (_) {
        log('[DEBUG-JINJA] Context.call: Error calling .call method on object: $object');
        log('[DEBUG-JINJA] Context.call: Error: $_');
        log('[DEBUG-JINJA] Context.call: Node: $node');
        log('[DEBUG-JINJA] Context.call: Positional: $positional');
        log('[DEBUG-JINJA] Context.call: Named: $named');
        log('[DEBUG-JINJA] Context.call: This: $this');
        log('[DEBUG-JINJA] Context.call: Environment: $environment');
        // Ignore error if .call does not exist
      }

      // Fallback to callCommon which might handle other types or throw
      return environment.callCommon(object, positional, named, this);
    } on TemplateError {
      // Re-throw template errors as-is
      rethrow;
    } catch (e, stackTrace) {
      // Wrap non-template exceptions with context
      final contextSnapshot = captureContext(this);
      final suggestions = <String>[
        'Check if the object is callable',
        'Verify the function signature matches the arguments provided',
        'Ensure all required arguments are provided',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error calling function: ${e.toString()}',
        stackTrace: stackTrace,
        node: node is Node ? node : null,
        contextSnapshot: contextSnapshot,
        operation: 'Calling function with ${positional.length} positional and ${named.length} named arguments',
        suggestions: suggestions,
        templatePath: template,
        contextSnippet: (source != null && node is Node && node.line != null && node.column != null)
            ? errorContextSnippet(source!, node.line!, node.column!)
            : null,
      );
    }
  }

  Context derived({
    String? template,
    Map<String, Object?>? data,
  }) {
    return Context(
      environment,
      template: template ?? this.template,
      source: source,
      blocks: blocks,
      parent: parent,
      data: data,
    );
  }

  bool has(String key) {
    log('[DEBUG-JINJA] Context.has: Checking if variable "$key" exists');
    if (context.containsKey(key)) {
      log('[DEBUG-JINJA] Context.has: "$key" found in context');
      return true;
    }

    if (parent.containsKey(key)) {
      log('[DEBUG-JINJA] Context.has: "$key" found in parent');
      return true;
    }

    final inGlobals = environment.loader?.globals?.containsKey(key) ?? false;
    if (inGlobals) {
      log('[DEBUG-JINJA] Context.has: "$key" found in loader.globals');
    } else {
      log('[DEBUG-JINJA] Context.has: "$key" NOT FOUND');
    }
    return inGlobals;
  }

  Object? resolve(String name) {
    try {
      log('[DEBUG-JINJA] Context.resolve: Looking for variable "$name"');
      if (context.containsKey(name)) {
        final value = context[name];
        try {
          log('[DEBUG-JINJA] Context.resolve: Found "$name" in context = $value (type: ${value.runtimeType})');
        } catch (e) {
          log('[DEBUG-JINJA] Context.resolve: Found "$name" in context (type: ${value.runtimeType}, toString failed)');
        }
        return value;
      }

      if (parent.containsKey(name)) {
        final value = parent[name];
        try {
          log('[DEBUG-JINJA] Context.resolve: Found "$name" in parent = $value (type: ${value.runtimeType})');
        } catch (e) {
          log('[DEBUG-JINJA] Context.resolve: Found "$name" in parent (type: ${value.runtimeType}, toString failed)');
        }
        return value;
      }

      if (environment.loader?.globals?.containsKey(name) ?? false) {
        final value = environment.loader!.globals![name];
        try {
          log('[DEBUG-JINJA] Context.resolve: Found "$name" in loader.globals = $value (type: ${value.runtimeType})');
        } catch (e) {
          log('[DEBUG-JINJA] Context.resolve: Found "$name" in loader.globals (type: ${value.runtimeType}, toString failed)');
        }
        return value;
      }

      log('[DEBUG-JINJA] Context.resolve: Variable "$name" NOT FOUND (checked context, parent, loader.globals)');
      return undefined(name, template);
    } on TemplateError {
      // Re-throw template errors as-is (they already have context)
      rethrow;
    } catch (e, stackTrace) {
      // Wrap non-template exceptions with context
      final contextSnapshot = captureContext(this);
      final availableKeys = <String>[
        ...context.keys,
        ...parent.keys,
      ];
      final similarNames = getSimilarNames(name, availableKeys);
      final suggestions = <String>[
        'Check if \'$name\' is defined before using it: {% if $name %}...{% endif %}',
        if (similarNames.isNotEmpty) 'Did you mean one of these? ${similarNames.join(', ')}',
        'Ensure \'$name\' is passed to the template context',
        if (availableKeys.isNotEmpty) 'Available variables: ${availableKeys.take(10).join(', ')}${availableKeys.length > 10 ? '...' : ''}',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error resolving variable \'$name\': ${e.toString()}',
        stackTrace: stackTrace,
        contextSnapshot: contextSnapshot,
        operation: 'Resolving variable \'$name\'',
        suggestions: suggestions,
        templatePath: template,
      );
    }
  }

  /// Async version of resolve that awaits Future values.
  /// This is used when globals contain Future values that need to be awaited.
  Future<Object?> resolveAsync(String name) async {
    log('[DEBUG-JINJA] Context.resolveAsync: Looking for variable "$name"');
    if (context.containsKey(name)) {
      var value = context[name];
      if (value is Future) {
        log('[DEBUG-JINJA] Context.resolveAsync: Found "$name" in context as Future, awaiting...');
        final resolved = await value;
        log('[DEBUG-JINJA] Context.resolveAsync: "$name" Future resolved to = $resolved');
        return resolved;
      }
      log('[DEBUG-JINJA] Context.resolveAsync: Found "$name" in context = $value (type: ${value.runtimeType})');
      return value;
    }

    if (parent.containsKey(name)) {
      var value = parent[name];
      if (value is Future) {
        log('[DEBUG-JINJA] Context.resolveAsync: Found "$name" in parent as Future, awaiting...');
        final resolved = await value;
        log('[DEBUG-JINJA] Context.resolveAsync: "$name" Future resolved to = $resolved');
        return resolved;
      }
      log('[DEBUG-JINJA] Context.resolveAsync: Found "$name" in parent = $value (type: ${value.runtimeType})');
      return value;
    }

    if (environment.loader?.globals?.containsKey(name) ?? false) {
      var value = environment.loader!.globals![name];
      if (value is Future) {
        log('[DEBUG-JINJA] Context.resolveAsync: Found "$name" in loader.globals as Future, awaiting...');
        final resolved = await value;
        log('[DEBUG-JINJA] Context.resolveAsync: "$name" Future resolved to = $resolved');
        return resolved;
      }
      log('[DEBUG-JINJA] Context.resolveAsync: Found "$name" in loader.globals = $value (type: ${value.runtimeType})');
      return value;
    }

    log('[DEBUG-JINJA] Context.resolveAsync: Variable "$name" NOT FOUND');
    return undefined(name, template);
  }

  Object? get(String key) {
    log('[DEBUG-JINJA] Context.get: Getting key "$key"');
    final value = context[key];
    log('[DEBUG-JINJA] Context.get: Key "$key" = $value (type: ${value.runtimeType})');
    return value;
  }

  void set(String key, Object? value) {
    log('[DEBUG-JINJA] Context.set: Setting key "$key" = $value (type: ${value.runtimeType})');
    context[key] = value;
  }

  bool remove(String name) {
    if (context.containsKey(name)) {
      context.remove(name);
      return true;
    }

    return false;
  }

  Object? undefined(String name, [String? template]) {
    return environment.undefined(name, template);
  }

  Object? attribute(String name, Object? value, Object? node) {
    try {
      return environment.getAttribute(name, value, node: node, source: source);
    } on TemplateError {
      // Re-throw template errors as-is (they already have context from defaults.dart)
      rethrow;
    } catch (e, stackTrace) {
      // Wrap non-template exceptions with context
      final contextSnapshot = captureContext(this);
      final suggestions = <String>[
        'Check if the object is null before accessing attributes',
        'Use conditional rendering: {% if object %}{{ object.$name }}{% endif %}',
        'Verify the attribute name is correct',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error accessing attribute \'$name\': ${e.toString()}',
        stackTrace: stackTrace,
        node: node is Node ? node : null,
        contextSnapshot: contextSnapshot,
        operation: 'Accessing attribute \'$name\' on ${value.runtimeType}',
        suggestions: suggestions,
        templatePath: template,
        contextSnippet: (source != null && node is Node && node.line != null && node.column != null)
            ? errorContextSnippet(source!, node.line!, node.column!)
            : null,
      );
    }
  }

  Object? item(Object? name, Object? value, Object? node) {
    try {
      return environment.getItem(name, value, node: node, source: source);
    } on TemplateError {
      // Re-throw template errors as-is (they already have context from defaults.dart)
      rethrow;
    } catch (e, stackTrace) {
      // Wrap non-template exceptions with context
      final contextSnapshot = captureContext(this);
      final suggestions = <String>[
        'Check if the object is null before accessing items',
        'Use conditional rendering: {% if object %}{{ object[$name] }}{% endif %}',
        'Verify the key type matches the object type',
        if (value is Map) 'Check if the key exists: {% if object.$name is defined %}...{% endif %}',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error accessing item \'$name\': ${e.toString()}',
        stackTrace: stackTrace,
        node: node is Node ? node : null,
        contextSnapshot: contextSnapshot,
        operation: 'Accessing item \'$name\' on ${value.runtimeType}',
        suggestions: suggestions,
        templatePath: template,
        contextSnippet: (source != null && node is Node && node.line != null && node.column != null)
            ? errorContextSnippet(source!, node.line!, node.column!)
            : null,
      );
    }
  }

  dynamic filter(
    String name, [
    List<Object?> positional = const <Object?>[],
    Map<Symbol, Object?> named = const <Symbol, Object?>{},
  ]) {
    try {
      return environment.callFilter(name, positional, named, this);
    } on TemplateError {
      // Re-throw template errors as-is (they already have context from environment.dart)
      rethrow;
    } catch (e, stackTrace) {
      // Wrap non-template exceptions with context
      final contextSnapshot = captureContext(this);
      final availableFilters = environment.filters.keys.toList();
      final similarFilters = getSimilarNames(name, availableFilters);
      final suggestions = <String>[
        'Check if the filter \'$name\' exists',
        if (similarFilters.isNotEmpty) 'Did you mean one of these? ${similarFilters.join(', ')}',
        'Verify the filter arguments match the expected signature',
        if (availableFilters.isNotEmpty)
          'Available filters: ${availableFilters.take(10).join(', ')}${availableFilters.length > 10 ? '...' : ''}',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error calling filter \'$name\': ${e.toString()}',
        stackTrace: stackTrace,
        contextSnapshot: contextSnapshot,
        operation: 'Calling filter \'$name\' with ${positional.length} positional and ${named.length} named arguments',
        suggestions: suggestions,
        templatePath: template,
      );
    }
  }

  dynamic test(
    String name, [
    List<Object?> positional = const <Object?>[],
    Map<Symbol, Object?> named = const <Symbol, Object?>{},
  ]) {
    try {
      return environment.callTest(name, positional, named, this);
    } on TemplateError {
      // Re-throw template errors as-is (they already have context from environment.dart)
      rethrow;
    } catch (e, stackTrace) {
      // Wrap non-template exceptions with context
      final contextSnapshot = captureContext(this);
      final availableTests = environment.tests.keys.toList();
      final similarTests = getSimilarNames(name, availableTests);
      final suggestions = <String>[
        'Check if the test \'$name\' exists',
        if (similarTests.isNotEmpty) 'Did you mean one of these? ${similarTests.join(', ')}',
        'Verify the test arguments match the expected signature',
        if (availableTests.isNotEmpty) 'Available tests: ${availableTests.take(10).join(', ')}${availableTests.length > 10 ? '...' : ''}',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error calling test \'$name\': ${e.toString()}',
        stackTrace: stackTrace,
        contextSnapshot: contextSnapshot,
        operation: 'Calling test \'$name\' with ${positional.length} positional and ${named.length} named arguments',
        suggestions: suggestions,
        templatePath: template,
      );
    }
  }
}

final class LoopContext extends Iterable<Object?> {
  LoopContext(this.values, this.depth0, this.recurse)
      : length = values.length,
        index0 = -1;

  final List<Object?> values;

  @override
  final int length;

  final int depth0;

  final String Function(Object? data, [int depth]) recurse;

  int index0;

  @override
  LoopIterator get iterator {
    return LoopIterator(this);
  }

  int get index {
    return index0 + 1;
  }

  int get depth {
    return depth0 + 1;
  }

  int get revindex0 {
    return length - index;
  }

  int get revindex {
    return length - index0;
  }

  @override
  bool get first {
    return index0 == 0;
  }

  @override
  bool get last {
    return index == length;
  }

  Object? get next {
    if (last) {
      return null;
    }

    return values[index0 + 1];
  }

  Object? get prev {
    if (first) {
      return null;
    }

    return values[index0 - 1];
  }

  Object? operator [](String key) {
    switch (key) {
      case 'length':
        return length;
      case 'index0':
        return index0;
      case 'depth0':
        return depth0;
      case 'index':
        return index;
      case 'depth':
        return depth;
      case 'revindex0':
        return revindex0;
      case 'revindex':
        return revindex;
      case 'first':
        return first;
      case 'last':
        return last;
      case 'prev':
      case 'previtem':
        return prev;
      case 'next':
      case 'nextitem':
        return next;
      case 'call':
        return call;
      case 'cycle':
        return cycle;
      case 'changed':
        return changed;
      default:
        var invocation = Invocation.getter(Symbol(key));
        throw NoSuchMethodError.withInvocation(this, invocation);
    }
  }

  String call(Object? data) {
    return recurse(data, depth);
  }

  Object? cycle(Iterable<Object?> values) {
    var list = values.toList();

    if (list.isEmpty) {
      // TODO(loop): update error
      throw TypeError();
    }

    return list[index0 % list.length];
  }

  bool changed(Object? item) {
    if (index0 == 0) {
      return true;
    }

    if (item == prev) {
      return false;
    }

    return true;
  }

  @override
  String toString() {
    return 'LoopContext(length: $length, index: $index)';
  }
}

final class LoopIterator implements Iterator<Object?> {
  LoopIterator(this.context);

  final LoopContext context;

  @override
  Object? get current {
    return context.values[context.index0];
  }

  @override
  bool moveNext() {
    // Use index0 directly instead of index getter to avoid confusion
    // index0 starts at -1, so we check if the NEXT index would be valid
    if (context.index0 + 1 < context.length) {
      context.index0 += 1;
      return true;
    }

    return false;
  }
}

base class Namespace {
  Namespace([Map<String, Object?>? data]) : context = <String, Object?>{...?data};

  final Map<String, Object?> context;

  Object? operator [](String name) {
    return context[name];
  }

  void operator []=(String name, Object? value) {
    context[name] = value;
  }

  static Namespace factory([List<Object?>? datas]) {
    var namespace = Namespace();

    if (datas == null) {
      return namespace;
    }

    for (var data in datas) {
      if (data is! Map) {
        // TODO(namespace): update error
        throw TypeError();
      }

      namespace.context.addAll(data.cast<String, Object?>());
    }

    return namespace;
  }
}

final class NamespaceValue {
  NamespaceValue(this.name, this.item);

  final String name;

  final String item;
}
