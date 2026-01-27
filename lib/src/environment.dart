import 'dart:math' show Random;

import 'package:meta/meta.dart';

import 'compiler.dart';
import 'defaults.dart' as defaults;
import 'exceptions.dart';
import 'lexer.dart';
import 'loaders.dart';
import 'nodes.dart';
import 'optimizer.dart';
import 'parser.dart';
import 'renderer.dart';
import 'runtime.dart';
import 'tests.dart' as tests_lib;
import 'utils.dart';

export 'package:jinja/src/exceptions.dart' show TemplateError;
export 'package:jinja/src/loaders.dart' show Loader;

/// {@template jinja.finalizer}
/// A function that can be used to process the result of a variable
/// expression before it is output.
///
/// For example one can convert `null` implicitly into an empty string here.
/// {@endtemplate}
typedef Finalizer = Object? Function(Object? value);

/// {@macro jinja.finalizer}
///
/// Takes [Context] as first argument.
typedef ContextFinalizer = Object? Function(Context context, Object? value);

/// {@macro jinja.finalizer}
///
/// Takes [Environment] as first argument.
typedef EnvironmentFinalizer = Object? Function(
  Environment environment,
  Object? value,
);

/// A function that can be used to get object atribute.
///
/// Used by `object.attribute` expression.
typedef AttributeGetter = Object? Function(
  String attribute,
  Object? object, {
  Object? node,
});

/// A function that can be used to get object item.
///
/// Used by `object['item']` expression.
typedef ItemGetter = Object? Function(
  Object? key,
  Object? object, {
  Object? node,
});

/// A function that returns a value or throws an error if the variable is not
/// found.
///
/// Used by `{{ user.field }}` expression when `user` not found.
typedef UndefinedCallback = Object? Function(String name, [String? template]);

/// Pass the [Context] as the first argument to the applied function when
/// called while rendering a template.
///
/// Can be used on functions, filters, and tests.
Object passContext(Function function) {
  return ContextFilter(function);
}

/// Pass the [Environment] as the first argument to the applied function when
/// called while rendering a template.
///
/// Can be used on functions, filters, and tests.
Object passEnvironment(Function function) {
  return EnvFilter(function);
}

/// {@template jinja.Environment}
/// The core component of Jinja 2 is the Environment.
/// {@endtemplate}
///
/// It contains important shared variables like configuration, filters, tests
/// and others.
///
/// Environment modifications can break templates that have been parsed or loaded.
base class Environment {
  /// {@macro jinja.Environment}
  Environment({
    this.commentStart = '{#',
    this.commentEnd = '#}',
    this.variableStart = '{{',
    this.variableEnd = '}}',
    this.blockStart = '{%',
    this.blockEnd = '%}',
    this.lineCommentPrefix,
    this.lineStatementPrefix,
    this.leftStripBlocks = false,
    this.trimBlocks = false,
    this.newLine = '\n',
    this.keepTrailingNewLine = false,
    this.optimize = true,
    this.autoEscape = false,
    Function finalize = defaults.finalize,
    this.loader,
    this.autoReload = true,
    Map<String, Object?>? globals,
    Map<String, Object>? filters,
    Map<String, Object>? tests,
    List<Node Function(Node)>? modifiers,
    Map<String, Template>? templates,
    Random? random,
    this.getAttribute = defaults.getAttribute,
    this.getItem = defaults.getItem,
    this.undefined = defaults.undefined,
  })  : finalize = wrapFinalizer(finalize),
        globals = <String, Object?>{...defaults.globals},
        filters = <String, Object>{...defaults.filters},
        tests = <String, Object>{...defaults.tests},
        modifiers = <Node Function(Node)>[],
        templates = <String, Template>{},
        random = random ?? Random() {
    if (newLine != '\r' && newLine != '\n' && newLine != '\r\n') {
      throw ArgumentError.value(newLine, 'newLine');
    }

    if (globals != null) {
      this.globals.addAll(globals);
    }

    if (filters != null) {
      this.filters.addAll(filters);
    }

    if (tests != null) {
      this.tests.addAll(tests);
    }

    if (modifiers != null) {
      this.modifiers.addAll(modifiers);
    }

    if (templates != null) {
      this.templates.addAll(templates);
    }
  }

  /// The string marking the beginning of a comment.
  final String commentStart;

  /// The string marking the end of a comment.
  final String commentEnd;

  /// The string marking the beginning of a print statement.
  final String variableStart;

  /// The string marking the end of a print statement.
  final String variableEnd;

  /// The string marking the beginning of a block.
  final String blockStart;

  /// The string marking the end of a block
  final String blockEnd;

  /// If given and a string, this will be used as prefix for line based
  /// comments.
  final String? lineCommentPrefix;

  /// If given and a string, this will be used as prefix for line based
  /// statements.
  final String? lineStatementPrefix;

  /// If this is set to `true` leading spaces and tabs are stripped
  /// from the start of a line to a block.
  final bool leftStripBlocks;

  /// If this is set to `true` the first newline after a block is
  /// removed (block, not variable tag!).
  final bool trimBlocks;

  /// The sequence that starts a newline.
  ///
  /// Must be one of `\r`, `\n` or `\r\n`.
  final String newLine;

  /// Preserve the trailing newline when rendering templates.
  /// The default is `false`, which causes a single newline,
  /// if present, to be stripped from the end of the template.
  final bool keepTrailingNewLine;

  /// Should the optimizer be enabled?
  final bool optimize;

  /// Should the variables be auto escaped?
  final bool autoEscape;

  /// A Function that can be used to process the result of a variable
  /// expression before it is output.
  ///
  /// For example one can convert `null` (`none`) implicitly into an empty
  /// string here.
  final ContextFinalizer finalize;

  /// The template loader for this environment.
  final Loader? loader;

  /// Some loaders load templates from locations where the template
  /// sources may change (ie: file system or database).
  ///
  /// If `autoReload` is set to `true` (default) every time a template is
  /// requested the loader checks if the source changed and if yes, it
  /// will reload the template. For higher performance it's possible to
  /// disable that.
  final bool autoReload;

  /// A map of variables that are available in every template loaded by
  /// the environment.
  final Map<String, Object?> globals;

  /// A map of filters that are available in every template loaded by
  /// the environment.
  final Map<String, Object> filters;

  /// A map of tests that are available in every template loaded by
  /// the environment.
  final Map<String, Object> tests;

  /// A list of template modifiers.
  final List<Node Function(Node)> modifiers;

  /// A map of parsed templates loaded by the environment.
  final Map<String, Template> templates;

  /// A random generator used by some filters.
  final Random random;

  /// Get an attribute of an object.
  ///
  /// If `getAttribute` is not passed to the [Environment], [getItem] is used
  /// instead.
  final AttributeGetter getAttribute;

  /// Get an item from an object.
  final ItemGetter getItem;

  /// Get an undefined object or throw an error if the variable is not found.
  ///
  /// Default implementation throws [UndefinedError].
  final UndefinedCallback undefined;

  @override
  int get hashCode {
    return Object.hash(
      blockStart,
      blockEnd,
      variableStart,
      variableEnd,
      commentStart,
      commentEnd,
      lineStatementPrefix,
      lineCommentPrefix,
      trimBlocks,
      leftStripBlocks,
      autoEscape,
    );
  }

  /// The [Lexer] for this environment.
  Lexer get lexer {
    return Lexer.cached(this);
  }

  @override
  bool operator ==(Object other) {
    return other is Environment &&
        blockStart == other.blockStart &&
        blockEnd == other.blockEnd &&
        variableStart == other.variableStart &&
        variableEnd == other.variableEnd &&
        commentStart == other.commentStart &&
        commentEnd == other.commentEnd &&
        lineStatementPrefix == other.lineStatementPrefix &&
        lineCommentPrefix == other.lineCommentPrefix &&
        trimBlocks == other.trimBlocks &&
        leftStripBlocks == other.leftStripBlocks &&
        autoEscape == other.autoEscape;
  }

  /// Common filter and test caller.
  @internal
  dynamic callCommon(
    Object function,
    List<Object?> positional,
    Map<Symbol, Object?> named,
    Context? context,
  ) {
    Function func;
    if (function is ContextFilter) {
      if (context == null) {
        throw TemplateRuntimeError(
          'Attempted to invoke context function without context.',
        );
      }
      positional = <Object?>[context, ...positional];
      func = function.function;
    } else if (function is EnvFilter) {
      positional = <Object?>[this, ...positional];
      func = function.function;
    } else if (function is Function) {
      func = function;
    } else {
      // Try to invoke as callable object (Joiner, Cycler)
      try {
        // This assumes dynamic dispatch will work for call() method
        // We might need to check for call method existence more robustly if needed
        return Function.apply(function as dynamic, positional, named);
      } catch (e) {
        throw TemplateRuntimeError('Invalid callable: $function');
      }
    }

    return Function.apply(func, positional, named);
  }

  /// If [name] filter not found [TemplateRuntimeError] thrown.
  dynamic callFilter(
    String name,
    List<Object?> positional, [
    Map<Symbol, Object?> named = const <Symbol, Object?>{},
    Context? context,
  ]) {
    final filter = filters[name];

    if (filter == null) {
      throw TemplateRuntimeError("No filter named '$name'.");
    }

    var finalPositional = positional;
    Function func;

    if (filter is ContextFilter) {
      if (context == null) {
        throw TemplateRuntimeError(
          'Attempted to invoke context filter without context.',
        );
      }
      finalPositional = <Object?>[context, ...positional];
      func = filter.function;
    } else if (filter is EnvFilter) {
      finalPositional = <Object?>[this, ...positional];
      func = filter.function;
    } else if (filter is Function) {
      func = filter;
    } else {
      throw TemplateRuntimeError('Filter "$name" is not a function.');
    }

    // Check if any arguments are Futures - if so, we need to be async
    bool hasAsyncArgs = finalPositional.any((arg) => arg is Future);

    if (hasAsyncArgs) {
      // Return a Future that resolves arguments then calls the filter
      return Future(() async {
        final resolvedPositional = <Object?>[];
        for (var arg in finalPositional) {
          if (arg is Future) {
            resolvedPositional.add(await arg);
          } else {
            resolvedPositional.add(arg);
          }
        }

        final result = Function.apply(func, resolvedPositional, named);
        return result is Future ? await result : result;
      });
    } else {
      // No async args - call filter synchronously
      final result = Function.apply(func, finalPositional, named);
      // Return result as is (can be Future or value)
      return result;
    }
  }

  /// If [name] not found throws [TemplateRuntimeError].
  @internal
  dynamic callTest(
    String name,
    List<Object?> positional, [
    Map<Symbol, Object?> named = const <Symbol, Object?>{},
    Context? context,
  ]) {
    final test = tests[name];
    if (test != null) {
      // Check if arguments are async
      bool hasAsyncArgs = positional.any((arg) => arg is Future);

      if (hasAsyncArgs) {
        return Future(() async {
          final resolvedPositional = <Object?>[];
          for (var arg in positional) {
            if (arg is Future)
              resolvedPositional.add(await arg);
            else
              resolvedPositional.add(arg);
          }
          // callCommon handles filter/env wrappers
          var result = callCommon(test, resolvedPositional, named, context);
          return result is Future ? await result : result;
        });
      }

      return callCommon(test, positional, named, context);
    }

    throw TemplateRuntimeError("No test named '$name'.");
  }

  /// Checks if a string matches a regex pattern (anchored to the start).
  bool match(String value, String pattern, {bool ignoreCase = false}) {
    return tests_lib.isMatch(value, pattern, ignoreCase: ignoreCase);
  }

  /// Checks if a string contains a regex pattern.
  bool search(String value, String pattern, {bool ignoreCase = false}) {
    return tests_lib.isSearch(value, pattern, ignoreCase: ignoreCase);
  }

  /// Checks if an iterable is a subset of another.
  bool subsetOf(Iterable<Object?> value, Iterable<Object?> other) {
    return tests_lib.isSubsetOf(value, other);
  }

  /// Checks if an iterable is a superset of another.
  bool supersetOf(Iterable<Object?> value, Iterable<Object?> other) {
    return tests_lib.isSupersetOf(value, other);
  }

  /// Performs version comparison (semantic versioning support).
  bool version(String value, String version, [String operator = '==']) {
    return tests_lib.isVersion(value, version, operator);
  }

  /// Lex the given source and return a list of tokens.
  ///
  /// This can be useful for extension development and debugging templates.
  Iterable<Token> lex(String source, {String? path}) {
    return lexer.tokenize(source, path: path);
  }

  /// Parse the list of tokens and return the AST node.
  ///
  /// This can be useful for debugging or to extract information from templates.
  Node scan(Iterable<Token> tokens, {String? path}) {
    // No template source available for scan, pass empty string for context.
    return Parser(this, '', path: path).scan(tokens);
  }

  /// Parse the source code and return the AST node.
  Node parse(String source, {String? path}) {
    return Parser(this, source, path: path).parse(source);
  }

  /// Load a template from a source string without using [loader].
  Template fromString(
    String source, {
    String? path,
    Map<String, Object?>? globals,
  }) {
    globals = <String, Object?>{...this.globals, ...?globals};

    var body = parse(source, path: path);

    for (var modifier in modifiers) {
      body = modifier(body);
    }

    if (optimize) {
      body = body.accept(const Optimizer(), Context(this, template: path));
    }

    body = body.accept(RuntimeCompiler(), null);

    return Template.fromNode(
      this,
      path: path,
      globals: globals,
      body: body,
    );
  }

  /// Load a template by name with `loader` and return a [Template].
  ///
  /// If the template does not exist a [TemplateNotFound] exception is thrown.
  /// If the loader is not specified a [StateError] is thrown.
  Template getTemplate(String name) {
    if (loader case var loader?) {
      var loaded = loader.load(this, name, globals: globals);

      if (autoReload) {
        return templates[name] = loaded;
      }

      return templates[name] ??= loaded;
    }

    throw StateError('No loader for this environment specified.');
  }

  /// Load a template from a list of names.
  ///
  /// If the template does not exist a [TemplatesNotFound] exception is thrown.
  Template selectTemplate(List<Object?> names) {
    if (names.isEmpty) {
      throw TemplatesNotFound(
        message: 'Tried to select from an empty list of templates.',
      );
    }

    for (var template in names) {
      if (template is Template) {
        return template;
      }

      if (template is String) {
        try {
          return getTemplate(template);
        } on TemplateNotFound {
          // ignore
        }
      }
    }

    throw TemplatesNotFound(names: names.cast<String>());
  }

  /// Returns a list of templates for this environment.
  ///
  /// If the [loader] is not specified a [StateError] is thrown.
  List<String> listTemplates() {
    if (loader case var loader?) {
      return loader.listTemplates();
    }

    throw StateError('No loader for this environment specified.');
  }

  /// @nodoc
  @protected
  static ContextFinalizer wrapFinalizer(Function function) {
    if (function is ContextFinalizer) {
      return (Context context, Object? value) {
        // Don't wrap Futures - let them pass through so AsyncRenderer can handle them
        if (value is Future) {
          return value;
        }
        var result = function(context, value);
        if (result is Future) {
          return result;
        }
        return result;
      };
    }

    if (function is EnvironmentFinalizer) {
      Object? finalizer(Context context, Object? value) {
        if (value is Future) {
          return value;
        }
        var result = function(context.environment, value);
        if (result is Future) {
          return result;
        }
        return result;
      }

      return finalizer;
    }

    if (function is Finalizer) {
      Object? finalizer(Context context, Object? value) {
        if (value is Future) {
          return value;
        }
        var result = function(value);
        if (result is Future) {
          return result;
        }
        return result;
      }

      return finalizer;
    }

    // Dart doesn't support union types, so we have to throw an error here.
    throw TypeError();
  }
}

/// {@template jinja.Template}
/// The base `Template` class.
/// {@endtemplate}
// TODO(template): add module namespace
base class Template {
  /// {@macro jinja.Template}
  factory Template(
    String source, {
    Environment? environment,
    String? path,
    String blockStart = '{%',
    String blockEnd = '%}',
    String variableStatr = '{{',
    String variableEnd = '}}',
    String commentStart = '{#',
    String commentEnd = '#}',
    String? lineCommentPrefix,
    String? lineStatementPrefix,
    bool trimBlocks = false,
    bool leftStripBlocks = false,
    String newLine = '\n',
    bool keepTrailingNewLine = false,
    bool optimize = true,
    ContextFinalizer finalize = defaults.finalize,
    bool autoEscape = false,
    Map<String, Object?>? globals,
    Map<String, Object>? filters,
    Map<String, Object>? tests,
    List<Node Function(Node)>? modifiers,
    Random? random,
    AttributeGetter getAttribute = defaults.getAttribute,
    ItemGetter getItem = defaults.getItem,
    UndefinedCallback undefined = defaults.undefined,
  }) {
    if (environment == null) {
      return Environment(
        commentStart: commentStart,
        commentEnd: commentEnd,
        variableStart: variableStatr,
        variableEnd: variableEnd,
        blockStart: blockStart,
        blockEnd: blockEnd,
        lineCommentPrefix: lineCommentPrefix,
        lineStatementPrefix: lineStatementPrefix,
        leftStripBlocks: leftStripBlocks,
        trimBlocks: trimBlocks,
        newLine: newLine,
        keepTrailingNewLine: keepTrailingNewLine,
        optimize: optimize,
        autoEscape: autoEscape,
        finalize: finalize,
        autoReload: false,
        globals: globals,
        filters: filters?.cast(),
        tests: tests?.cast(),
        modifiers: modifiers,
        random: random,
        getAttribute: getAttribute,
        getItem: getItem,
        undefined: undefined,
      ).fromString(source, path: path);
    }

    return environment.fromString(source, path: path, globals: globals);
  }

  /// This is used internally by the [Environment.fromString] to create
  /// templates from parsed sources.
  @internal
  Template.fromNode(
    this.environment, {
    this.path,
    this.globals = const <String, Object?>{},
    required Node body,
  }) : body = body is TemplateNode ? body : TemplateNode(body: body);

  /// The environment used to parse and render template.
  final Environment environment;

  /// The path to the template if it was loaded.
  final String? path;

  /// The global variables for this template.
  final Map<String, Object?> globals;

  // @nodoc
  @internal
  final TemplateNode body;

  /// If no arguments are given the context will be empty.
  String render([Map<String, Object?>? data]) {
    var buffer = StringBuffer();
    renderTo(buffer, data);
    return buffer.toString();
  }

  /// If no arguments are given the context will be empty.
  void renderTo(StringSink sink, [Map<String, Object?>? data]) {
    var context = StringSinkRenderContext(
      environment,
      sink,
      template: path,
      parent: globals,
      data: data,
    );

    body.accept(const StringSinkRenderer(), context);
  }

  /// Async version of [render] that supports Future values in globals.
  ///
  /// All Future values in globals will be awaited before rendering.
  /// If no arguments are given the context will be empty.
  Future<String> renderAsync([Map<String, Object?>? data]) async {
    var buffer = StringBuffer();
    await renderToAsync(buffer, data);
    return buffer.toString();
  }

  /// Async version of [renderTo] that supports Future values in globals.
  ///
  /// All Future values in globals will be awaited before rendering.
  /// If no arguments are given the context will be empty.
  Future<void> renderToAsync(
    StringSink sink, [
    Map<String, Object?>? data,
  ]) async {
    var context = AsyncRenderContext(
      environment,
      sink,
      template: path,
      parent: globals,
      data: data,
    );

    await const AsyncRenderer().render(body, context);
  }
}
