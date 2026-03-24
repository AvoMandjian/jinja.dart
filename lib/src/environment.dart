import 'dart:developer' show log;
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
import 'utils.dart'
    show
        captureCallStack,
        captureContext,
        getSimilarNames,
        ContextFilter,
        EnvFilter,
        withRenderFrame,
        withRenderFrameAsync;

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
  String? source,
});

/// A function that can be used to get object item.
///
/// Used by `object['item']` expression.
typedef ItemGetter = Object? Function(
  Object? key,
  Object? object, {
  Object? node,
  String? source,
});

/// A function that returns a value or throws an error if the variable is not
/// found.
///
/// Used by `{{ user.field }}` expression when `user` not found.
typedef UndefinedCallback = Object? Function(String name, [String? template]);

/// Logging interface used by the Jinja environment.
///
/// This allows host applications to plug in their own logging implementation
/// without the core library depending on a specific logging backend.
abstract class JinjaLogger {
  void debug(String message);
  void info(String message);
  void warn(String message);
  void error(String message, [Object? error, StackTrace? stackTrace]);
}

/// Default logger implementation used when no custom [JinjaLogger] is provided.
///
/// This delegates to `dart:developer`'s [log] function so that, when debug
/// logging is enabled, messages appear in the developer console.
class DefaultJinjaLogger implements JinjaLogger {
  const DefaultJinjaLogger();

  @override
  void debug(String message) {
    log(message);
  }

  @override
  void info(String message) {
    log(message);
  }

  @override
  void warn(String message) {
    log(message);
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    log(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

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
    this.enableJinjaDebugLogging = false,
    JinjaLogger? logger,
  })  : finalize = wrapFinalizer(finalize),
        globals = <String, Object?>{...defaults.globals},
        filters = <String, Object>{...defaults.filters},
        tests = <String, Object>{...defaults.tests},
        modifiers = <Node Function(Node)>[],
        templates = <String, Template>{},
        random = random ?? Random(),
        logger = logger ?? const DefaultJinjaLogger() {
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

  /// Whether internal `[DEBUG-JINJA]` debug logs are enabled.
  ///
  /// When this is `false` (the default), internal debug logging is skipped to
  /// avoid overhead. When enabled, debug messages are sent through [logger].
  final bool enableJinjaDebugLogging;

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

  /// Logger used for Jinja-related messages.
  ///
  /// Internal debug logging goes through this logger via [debugJinja].
  final JinjaLogger logger;

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

  /// Emit an internal Jinja debug log message if debug logging is enabled.
  ///
  /// All `[DEBUG-JINJA]` style debug logs should flow through this helper so
  /// that they can be toggled with [enableJinjaDebugLogging].
  void debugJinja(String message) {
    if (!enableJinjaDebugLogging) {
      return;
    }
    logger.debug('[DEBUG-JINJA] $message');
  }

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
    try {
      Function func;
      if (function is ContextFilter) {
        if (context == null) {
          final suggestions = <String>[
            'Context functions require a Context parameter',
            'Ensure the function is called from within a template rendering context',
          ];
          throw TemplateRuntimeError(
            'Attempted to invoke context function without context.',
            operationValue: 'Calling context function',
            suggestionsValue: suggestions,
          );
        }
        positional = <Object?>[context, ...positional];
        func = function.function;
      } else if (function is EnvFilter) {
        positional = <Object?>[this, ...positional];
        func = function.function;
      } else if (function is MacroFunction) {
        // MacroFunction wrappers generated by Renderer.getMacroFunction.macro
        // are invoked with the MacroFunction signature:
        //   macro(positionalArgsList, namedKwargsMap)
        //
        // But `is MacroFunction` can be a false-positive due to structural
        // compatibility. To stay safe, we only reinterpret the calling
        // convention for the two macro-shaped cases:
        //
        // 1) Packed calling convention:
        //    positional = [positionalArgsList, namedKwargsMap]
        //
        // 2) Unpacked macro invocation via a macro value:
        //    positional = [arg] and named is empty
        //
        // The second case fixes `view(value)` where the first parameter is
        // the whole argument list for the macro wrapper.
        final macroNamed = <Object?, Object?>{};
        for (final entry in named.entries) {
          macroNamed[entry.key] = entry.value;
        }

        final isPackedMacroCall = positional.length == 2 &&
            positional[0] is List &&
            positional[1] is Map;

        if (isPackedMacroCall) {
          final positionalArgsList = (positional[0] as List).cast<Object?>();
          final packedNamed = positional[1] as Map;
          macroNamed.addAll(Map<Object?, Object?>.from(packedNamed));
          return function(positionalArgsList, macroNamed);
        }

        // Unpacked macro value invocation:
        //   view(value) => positional = [value], named = {}
        if (positional.length == 1 && named.isEmpty) {
          return function(positional, macroNamed);
        }

        // Otherwise: treat it like a regular Function call.
        func = function;
      } else if (function is Function) {
        func = function;
      } else {
        // Try to invoke as callable object (Joiner, Cycler)
        try {
          // This assumes dynamic dispatch will work for call() method
          // We might need to check for call method existence more robustly if needed
          return Function.apply(function as dynamic, positional, named);
        } catch (_) {
          final suggestions = <String>[
            'Object must be a Function or have a call() method',
            'Object type: ${function.runtimeType}',
            'Check if the object is callable',
          ];
          throw TemplateRuntimeError(
            'Invalid callable: $function',
            operationValue: 'Calling function',
            suggestionsValue: suggestions,
          );
        }
      }

      return Function.apply(func, positional, named);
    } on TemplateError {
      rethrow;
    } catch (e, stackTrace) {
      final suggestions = <String>[
        'Check if the function signature matches the arguments',
        'Verify all required arguments are provided',
        'Ensure argument types match the function parameters',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error calling function: ${e.toString()}',
        stackTrace: stackTrace,
        operation:
            'Calling function with ${positional.length} positional and ${named.length} named arguments',
        suggestions: suggestions,
        callStack: captureCallStack(),
      );
    }
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
      final availableFilters = filters.keys.toList();
      final similarFilters = getSimilarNames(name, availableFilters);
      final suggestions = <String>[
        'Check if the filter name is spelled correctly',
        if (similarFilters.isNotEmpty)
          'Did you mean one of these? ${similarFilters.join(', ')}',
        if (availableFilters.isNotEmpty)
          'Available filters: ${availableFilters.take(10).join(', ')}${availableFilters.length > 10 ? '...' : ''}',
      ];
      throw TemplateRuntimeError(
        "No filter named '$name'.",
        operationValue: 'Calling filter \'$name\'',
        suggestionsValue: suggestions,
      );
    }

    var finalPositional = positional;
    Function func;

    if (filter is ContextFilter) {
      if (context == null) {
        final suggestions = <String>[
          'Context filters require a Context parameter',
          'Ensure the filter is called from within a template rendering context',
        ];
        throw TemplateRuntimeError(
          'Attempted to invoke context filter without context.',
          operationValue: 'Calling context filter \'$name\'',
          suggestionsValue: suggestions,
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
      final suggestions = <String>[
        'Filter must be a Function',
        'Filter type: ${filter.runtimeType}',
        'Check filter registration',
      ];
      throw TemplateRuntimeError(
        'Filter "$name" is not a function.',
        operationValue: 'Calling filter \'$name\'',
        suggestionsValue: suggestions,
      );
    }

    // Some Jinja templates use `default=...` for parameters that we implement
    // in Dart as `defaultValue=...` (to avoid reserved-word / naming issues).
    // Normalize keyword arguments before calling the underlying function.
    var finalNamed = Map<Symbol, Object?>.from(named);
    const symDefault = Symbol('default');
    const symDefaultValue = Symbol('defaultValue');
    if (finalNamed.containsKey(symDefault) &&
        !finalNamed.containsKey(symDefaultValue)) {
      finalNamed[symDefaultValue] = finalNamed.remove(symDefault);
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

        try {
          final result = Function.apply(func, resolvedPositional, finalNamed);
          return result is Future ? await result : result;
        } on TemplateError {
          rethrow;
        } catch (e, stackTrace) {
          final contextSnapshot =
              context != null ? captureContext(context) : null;
          final argTypes =
              resolvedPositional.map((e) => e.runtimeType).toList();
          final suggestions = <String>[
            'Check if the filter arguments match the expected signature',
            'Positional args types: $argTypes',
            'Verify all required arguments are provided',
            'Ensure argument types match the filter parameters',
          ];
          throw TemplateErrorWrapper(
            e,
            message: 'Error calling filter "$name": ${e.toString()}',
            stackTrace: stackTrace,
            contextSnapshot: contextSnapshot,
            operation:
                'Calling filter \'$name\' with ${resolvedPositional.length} positional and ${finalNamed.length} named arguments',
            suggestions: suggestions,
            templatePath: context?.template,
            callStack: captureCallStack(),
          );
        }
      });
    } else {
      // No async args - call filter synchronously
      try {
        final result = Function.apply(func, finalPositional, finalNamed);
        // Return result as is (can be Future or value)
        return result;
      } on TemplateError {
        rethrow;
      } catch (e, stackTrace) {
        final contextSnapshot =
            context != null ? captureContext(context) : null;
        final argTypes = finalPositional.map((e) => e.runtimeType).toList();
        final suggestions = <String>[
          'Check if the filter arguments match the expected signature',
          'Positional args types: $argTypes',
          'Verify all required arguments are provided',
          'Ensure argument types match the filter parameters',
        ];
        throw TemplateErrorWrapper(
          e,
          message: 'Error calling filter "$name": ${e.toString()}',
          stackTrace: stackTrace,
          contextSnapshot: contextSnapshot,
          operation:
              'Calling filter \'$name\' with ${finalPositional.length} positional and ${finalNamed.length} named arguments',
          suggestions: suggestions,
          templatePath: context?.template,
          callStack: captureCallStack(),
        );
      }
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
            if (arg is Future) {
              resolvedPositional.add(await arg);
            } else {
              resolvedPositional.add(arg);
            }
          }
          // callCommon handles filter/env wrappers
          try {
            var result = callCommon(test, resolvedPositional, named, context);
            return result is Future ? await result : result;
          } on TemplateError {
            rethrow;
          } catch (e, stackTrace) {
            final contextSnapshot =
                context != null ? captureContext(context) : null;
            final argTypes =
                resolvedPositional.map((e) => e.runtimeType).toList();
            final suggestions = <String>[
              'Check if the test arguments match the expected signature',
              'Positional args types: $argTypes',
              'Verify all required arguments are provided',
              'Ensure argument types match the test parameters',
            ];
            throw TemplateErrorWrapper(
              e,
              message: 'Error calling test "$name": ${e.toString()}',
              stackTrace: stackTrace,
              contextSnapshot: contextSnapshot,
              operation:
                  'Calling test \'$name\' with ${resolvedPositional.length} positional and ${named.length} named arguments',
              suggestions: suggestions,
              templatePath: context?.template,
              callStack: captureCallStack(),
            );
          }
        });
      }

      try {
        return callCommon(test, positional, named, context);
      } on TemplateError {
        rethrow;
      } catch (e, stackTrace) {
        final contextSnapshot =
            context != null ? captureContext(context) : null;
        final argTypes = positional.map((e) => e.runtimeType).toList();
        final suggestions = <String>[
          'Check if the test arguments match the expected signature',
          'Positional args types: $argTypes',
          'Verify all required arguments are provided',
          'Ensure argument types match the test parameters',
        ];
        throw TemplateErrorWrapper(
          e,
          message: 'Error calling test "$name": ${e.toString()}',
          stackTrace: stackTrace,
          contextSnapshot: contextSnapshot,
          operation:
              'Calling test \'$name\' with ${positional.length} positional and ${named.length} named arguments',
          suggestions: suggestions,
          templatePath: context?.template,
          callStack: captureCallStack(),
        );
      }
    }

    final availableTests = tests.keys.toList();
    final similarTests = getSimilarNames(name, availableTests);
    final suggestions = <String>[
      'Check if the test name is spelled correctly',
      if (similarTests.isNotEmpty)
        'Did you mean one of these? ${similarTests.join(', ')}',
      if (availableTests.isNotEmpty)
        'Available tests: ${availableTests.take(10).join(', ')}${availableTests.length > 10 ? '...' : ''}',
    ];
    throw TemplateRuntimeError(
      "No test named '$name'.",
      operationValue: 'Calling test \'$name\'',
      suggestionsValue: suggestions,
    );
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
      body = body.accept(
          const Optimizer(), Context(this, template: path, source: source));
    }

    body = body.accept(RuntimeCompiler(), null);

    return Template.fromNode(
      this,
      path: path,
      globals: globals,
      body: body,
      source: source,
    );
  }

  /// Load a template by name with `loader` and return a [Template].
  ///
  /// If the template does not exist a [TemplateNotFound] exception is thrown.
  /// If the loader is not specified a [StateError] is thrown.
  Template getTemplate(String name) {
    if (loader case var loader?) {
      try {
        var loaded = loader.load(this, name, globals: globals);

        if (autoReload) {
          return templates[name] = loaded;
        }

        return templates[name] ??= loaded;
      } on TemplateError {
        // Re-throw template errors as-is (they already have context)
        rethrow;
      } catch (e, stackTrace) {
        final suggestions = <String>[
          'Check if the template path is correct',
          'Verify the template exists in the loader',
          'Ensure the loader is configured correctly',
        ];
        throw TemplateErrorWrapper(
          e,
          message: 'Error loading template "$name": ${e.toString()}',
          stackTrace: stackTrace,
          operation: 'Loading template \'$name\'',
          suggestions: suggestions,
          templatePath: name,
          callStack: captureCallStack(),
        );
      }
    }

    final suggestions = <String>[
      'A loader must be specified to load templates',
      'Set the loader when creating the Environment',
      'Example: Environment(loader: FileSystemLoader(...))',
    ];
    throw TemplateRuntimeError(
      'No loader for this environment specified.',
      operationValue: 'Loading template \'$name\'',
      suggestionsValue: suggestions,
      templatePathValue: name,
    );
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
    this.source,
  }) : body = body is TemplateNode ? body : TemplateNode(body: body);

  /// The environment used to parse and render template.
  final Environment environment;

  /// The source code of the template.
  final String? source;

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
    withRenderFrame<void>(
      templatePath: path ?? '<string>',
      description: 'template root',
      body: () {
        var context = StringSinkRenderContext(
          environment,
          sink,
          template: path,
          source: source,
          parent: globals,
          data: data,
        );

        body.accept(const StringSinkRenderer(), context);
      },
    );
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
    await withRenderFrameAsync<void>(
      templatePath: path ?? '<string>',
      description: 'template root',
      body: () async {
        var context = AsyncRenderContext(
          environment,
          sink,
          template: path,
          source: source,
          parent: globals,
          data: data,
        );

        await AsyncRenderer().render(body, context);
      },
    );
  }
}
