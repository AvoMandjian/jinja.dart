import 'dart:developer';
import 'dart:math' as math;

import 'package:meta/dart2js.dart';

import 'environment.dart';
import 'exceptions.dart';
import 'nodes.dart';
import 'runtime.dart';
import 'tests.dart';
import 'utils.dart';
import 'visitor.dart';

abstract base class RenderContext extends Context {
  RenderContext(
    super.environment, {
    super.template,
    super.source,
    super.blocks,
    super.parent,
    super.data,
    bool? autoEscape,
  }) : autoEscape = autoEscape ?? environment.autoEscape;

  final bool autoEscape;

  void assignTargets(Object? target, Object? current) {
    if (target is String) {
      set(target, current);
    } else if (target is List) {
      var values = list(current);

      if (values.length < target.length) {
        throw StateError('Not enough values to unpack.');
      }

      if (values.length > target.length) {
        throw StateError('Too many values to unpack.');
      }

      for (var i = 0; i < target.length; i++) {
        assignTargets(target[i], values[i]);
      }
    } else if (target is NamespaceValue) {
      var value = resolve(target.name);

      if (value is! Namespace) {
        throw TemplateRuntimeError('Non-namespace object.');
      }

      value[target.item] = current;
    } else {
      throw TemplateRuntimeError(
        'Invalid target. ${target.toString()}, current: ${current.toString()}',
      );
    }
  }

  @override
  RenderContext derived({String? template, Map<String, Object?>? data});

  Object? finalize(Object? object) {
    return environment.finalize(this, object);
  }
}

base class StringSinkRenderContext extends RenderContext {
  StringSinkRenderContext(
    super.environment,
    this.sink, {
    super.template,
    super.source,
    super.blocks,
    super.parent,
    super.data,
    super.autoEscape,
  });

  final StringSink sink;

  @override
  StringSinkRenderContext derived({
    StringSink? sink,
    String? template,
    Map<String, Object?>? data,
    bool withContext = true,
    bool? autoEscape,
  }) {
    Map<String, Object?> parent;

    if (withContext) {
      parent = <String, Object?>{...this.parent, ...context};
    } else {
      parent = this.parent;
    }

    return StringSinkRenderContext(
      environment,
      sink ?? this.sink,
      template: template ?? this.template,
      blocks: blocks,
      parent: parent,
      data: data,
      autoEscape: autoEscape ?? this.autoEscape,
    );
  }

  @noInline
  void write(Object? value) {
    sink.write(value);
  }
}

/// Async version of StringSinkRenderContext that supports async global resolution.
base class AsyncRenderContext extends RenderContext {
  AsyncRenderContext(
    super.environment,
    this.sink, {
    super.template,
    super.source,
    super.blocks,
    super.parent,
    super.data,
    super.autoEscape,
  });

  final StringSink sink;

  @override
  AsyncRenderContext derived({
    StringSink? sink,
    String? template,
    Map<String, Object?>? data,
    bool withContext = true,
    bool? autoEscape,
  }) {
    Map<String, Object?> parent;

    if (withContext) {
      parent = <String, Object?>{...this.parent, ...context};
    } else {
      parent = this.parent;
    }

    return AsyncRenderContext(
      environment,
      sink ?? this.sink,
      template: template ?? this.template,
      blocks: blocks,
      parent: parent,
      data: data,
      autoEscape: autoEscape ?? this.autoEscape,
    );
  }

  @noInline
  void write(Object? value) {
    sink.write(value);
  }
}

base class StringSinkRenderer extends Visitor<StringSinkRenderContext, Object?> {
  const StringSinkRenderer();

  Map<String, Object?> getDataForTargets(Object? targets, Object? current) {
    try {
      if (targets is String) {
        return <String, Object?>{targets: current};
      }

      if (targets is List<Object?>) {
        var names = targets.cast<String>();
        var values = list(current);

        if (values.length < names.length) {
          final suggestions = <String>[
            'Expected ${names.length} values but got ${values.length}',
            'Check if the iterable has enough items',
            'Ensure the for loop target matches the number of values',
          ];
          throw TemplateRuntimeError(
            'Not enough values to unpack (expected ${names.length}, got ${values.length}).',
            operationValue: 'Unpacking values for targets: ${names.join(', ')}',
            suggestionsValue: suggestions,
          );
        }

        if (values.length > names.length) {
          final suggestions = <String>[
            'Got ${values.length} values but expected ${names.length}',
            'Add more target variables or reduce the number of values',
            'Check if the iterable has the correct structure',
          ];
          throw TemplateRuntimeError(
            'Too many values to unpack (expected ${names.length}).',
            operationValue: 'Unpacking values for targets: ${names.join(', ')}',
            suggestionsValue: suggestions,
          );
        }

        return <String, Object?>{
          for (var i = 0; i < names.length; i++) names[i]: values[i],
        };
      }

      final suggestions = <String>[
        'Target must be a string or list of strings',
        'For single value: use a string target',
        'For multiple values: use a list of strings',
      ];
      throw TemplateRuntimeError(
        'Invalid target type: ${targets.runtimeType}. Expected String or List<String>.',
        operationValue: 'Unpacking values for target',
        suggestionsValue: suggestions,
      );
    } on BreakException {
      rethrow;
    } on ContinueException {
      rethrow;
    } on TemplateError {
      rethrow;
    } catch (e, stackTrace) {
      final suggestions = <String>[
        'Check if the target structure matches the value structure',
        'Verify the number of target variables matches the number of values',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error unpacking values for targets: ${e.toString()}',
        stackTrace: stackTrace,
        operation: 'Unpacking values for target',
        suggestions: suggestions,
      );
    }
  }

  MacroFunction getMacroFunction(
    MacroCall node,
    StringSinkRenderContext context,
  ) {
    Object? macro(List<Object?> positional, Map<Object?, Object?> named) {
      // Use the same sink type as context to preserve async behavior
      StringSink buffer;
      if (context.sink is _AsyncCollectingSink) {
        // For async contexts, use a new collecting sink
        buffer = _AsyncCollectingSink(StringBuffer());
      } else {
        buffer = StringBuffer();
      }
      var derived = context.derived(sink: buffer);

      var index = 0;
      var mandatoryLength = node.positional.length;

      try {
        // 1. Mandatory positional arguments
        for (; index < mandatoryLength; index += 1) {
          var key = node.positional[index].accept(this, context) as String;
          derived.set(key, positional[index]);
        }

        // 2. Optional arguments (node.named) - fill from positional if available, else named/default
        var remaining = named.keys.toSet();

        for (var (argument, defaultValue) in node.named) {
          var key = argument.accept(this, context) as String;

          if (index < positional.length) {
            // Use positional argument
            derived.set(key, positional[index]);
            index++;
          } else {
            // Check named arguments
            if (remaining.remove(key)) {
              derived.set(key, named[key]);
            } else if (remaining.remove(Symbol(key))) {
              derived.set(key, named[Symbol(key)]);
            } else {
              // Evaluate default value
              if (defaultValue is Name) {
                // For Name defaults like b=x, look in named arguments only
                // This allows defaults to reference other macro parameters
                // Check both String and Symbol keys
                var defaultValueValue = named[defaultValue.name];
                defaultValueValue ??= named[Symbol(defaultValue.name)];
                derived.set(key, defaultValueValue);
              } else {
                // For other defaults, evaluate in outer context
                var defaultValueResult = defaultValue.accept(this, context);
                derived.set(key, defaultValueResult);
              }
            }
          }
        }

        // 3. Varargs
        if (node.varargs) {
          derived.set('varargs', positional.sublist(index));
        } else if (index < positional.length) {
          throw TemplateRuntimeError('''Error at macro ${node.name},
            expected arguments count: $index
            given arguments count: ${positional.length}
            given arguments: ${positional.toString()},
            ''');
        }

        // 4. Kwargs
        if (node.kwargs) {
          var kwargs = <Object?, Object?>{};
          for (var key in remaining) {
            if (key is String) {
              kwargs[key] = named[key];
            } else if (key is Symbol) {
              // Convert Symbol to String for kwargs
              var keyStr = key.toString().replaceAll('Symbol("', '').replaceAll('")', '');
              kwargs[keyStr] = named[key];
            } else {
              kwargs[key] = named[key];
            }
          }
          derived.set('kwargs', kwargs);
        } else if (remaining.isNotEmpty) {
          throw TemplateRuntimeError('remaining.isNotEmpty: ${remaining.map((e) => e.toString()).join(', ')}');
        }
      } catch (e) {
        throw TemplateRuntimeError('''Error at macro ${node.name},
            expected arguments count: ${mandatoryLength + node.named.length} (mandatory: $mandatoryLength)
            given arguments count: ${positional.length}
            given arguments: ${positional.toString()},
            error: ${e.toString()}
            ''');
      }

      node.body.accept(this, derived);

      // If buffer is an async collecting sink, return a Future that resolves it
      if (buffer is _AsyncCollectingSink) {
        return buffer.getResolvedContent().then((content) {
          // Macro output should be safe if auto-escaping was enabled during rendering
          return SafeString(content);
        });
      }
      // Macro output should be safe if auto-escaping was enabled during rendering
      // This prevents double escaping when the macro result is used in an interpolation
      return SafeString(buffer.toString());
    }

    return macro;
  }

  // Expressions

  @override
  List<Object?> visitArray(Array node, StringSinkRenderContext context) {
    return <Object?>[
      for (var value in node.values) value.accept(this, context),
    ];
  }

  @override
  Object? visitAttribute(Attribute node, StringSinkRenderContext context) {
    log('[DEBUG-JINJA] visitAttribute: Accessing attribute "${node.attribute}" on value');
    var value = node.value.accept(this, context);
    log('[DEBUG-JINJA] visitAttribute: Value = $value (type: ${value.runtimeType}), accessing attribute "${node.attribute}"');
    final result = context.attribute(node.attribute, value, node);
    log('[DEBUG-JINJA] visitAttribute: Attribute "${node.attribute}" result = $result (type: ${result.runtimeType})');
    return result;
  }

  @override
  Object? visitCall(Call node, StringSinkRenderContext context) {
    log('[DEBUG-JINJA] visitCall: Calling function');
    var function = node.value.accept(this, context);
    log('[DEBUG-JINJA] visitCall: Function = $function (type: ${function.runtimeType})');
    var (positional, named) = node.calling.accept(this, context) as Parameters;
    log('[DEBUG-JINJA] visitCall: Positional args: ${positional.length}, named args: ${named.length}');
    final result = context.call(function, node, positional, named);
    log('[DEBUG-JINJA] visitCall: Function call result = $result (type: ${result.runtimeType})');
    return result;
  }

  @override
  Parameters visitCalling(Calling node, StringSinkRenderContext context) {
    var positional = <Object?>[
      for (var argument in node.arguments) argument.accept(this, context),
    ];

    var named = <Symbol, Object?>{
      for (var (:key, :value) in node.keywords) Symbol(key): value.accept(this, context),
    };

    return (positional, named);
  }

  @override
  bool visitCompare(Compare node, StringSinkRenderContext context) {
    var left = node.value.accept(this, context);

    for (var (operator, value) in node.operands) {
      var right = value.accept(this, context);

      var result = switch (operator) {
        CompareOperator.equal => isEqual(left, right),
        CompareOperator.notEqual => isNotEqual(left, right),
        CompareOperator.lessThan => isLessThan(left, right),
        CompareOperator.lessThanOrEqual => isLessThanOrEqual(left, right),
        CompareOperator.greaterThan => isGreaterThan(left, right),
        CompareOperator.greaterThanOrEqual => isGreaterThanOrEqual(left, right),
        CompareOperator.contains => isIn(left, right),
        CompareOperator.notContains => !isIn(left, right),
      };

      if (!result) {
        return false;
      }

      left = right;
    }

    return true;
  }

  @override
  Object? visitConcat(Concat node, StringSinkRenderContext context) {
    log('[DEBUG-JINJA] visitConcat: Concatenating ${node.values.length} values');
    var buffer = StringBuffer();

    for (var i = 0; i < node.values.length; i++) {
      final value = node.values[i].accept(this, context);
      log('[DEBUG-JINJA] visitConcat: Value $i = $value (type: ${value.runtimeType})');
      buffer.write(value);
    }

    final result = buffer.toString();
    log('[DEBUG-JINJA] visitConcat: Concatenated result = "$result" (length: ${result.length})');
    return result;
  }

  @override
  Object? visitCondition(Condition node, StringSinkRenderContext context) {
    log('[DEBUG-JINJA] visitCondition: Evaluating ternary condition');
    final testResult = node.test.accept(this, context);
    final testBool = boolean(testResult);
    log('[DEBUG-JINJA] visitCondition: Test result = $testResult, boolean = $testBool');
    if (testBool) {
      log('[DEBUG-JINJA] visitCondition: Condition true, returning trueValue');
      return node.trueValue.accept(this, context);
    }
    log('[DEBUG-JINJA] visitCondition: Condition false, returning falseValue');
    return node.falseValue?.accept(this, context);
  }

  @override
  Object? visitConstant(Constant node, StringSinkRenderContext context) {
    return node.value;
  }

  @override
  Map<Object?, Object?> visitDict(Dict node, StringSinkRenderContext context) {
    return <Object?, Object?>{
      for (var (:key, :value) in node.pairs) key.accept(this, context): value.accept(this, context),
    };
  }

  @override
  Object? visitFilter(Filter node, StringSinkRenderContext context) {
    log('[DEBUG-JINJA] visitFilter: Applying filter "${node.name}"');
    var (positional, named) = node.calling.accept(this, context) as Parameters;
    log('[DEBUG-JINJA] visitFilter: Filter "${node.name}" - positional args: ${positional.length}, named args: ${named.length}');
    // Return the Future without awaiting - the AsyncRenderer will handle it
    final result = context.filter(node.name, positional, named);
    log('[DEBUG-JINJA] visitFilter: Filter "${node.name}" result = $result (type: ${result.runtimeType})');
    return result;
  }

  @override
  Object? visitItem(Item node, StringSinkRenderContext context) {
    log('[DEBUG-JINJA] visitItem: Accessing item');
    var key = node.key.accept(this, context);
    var value = node.value.accept(this, context);
    log('[DEBUG-JINJA] visitItem: Key = $key (type: ${key.runtimeType}), value = $value (type: ${value.runtimeType})');
    final result = context.item(key, value, node);
    log('[DEBUG-JINJA] visitItem: Item access result = $result (type: ${result.runtimeType})');
    return result;
  }

  @override
  Object? visitLogical(Logical node, StringSinkRenderContext context) {
    var left = node.left.accept(this, context);

    return switch (node.operator) {
      LogicalOperator.and => boolean(left) ? node.right.accept(this, context) : left,
      LogicalOperator.or => boolean(left) ? left : node.right.accept(this, context),
    };
  }

  @override
  Object? visitName(Name node, StringSinkRenderContext context) {
    try {
      log('[DEBUG-JINJA] visitName: Resolving name "${node.name}" (context: ${node.context})');
      final result = switch (node.context) {
        AssignContext.load => context.resolve(node.name),
        _ => node.name,
      };
      try {
        log('[DEBUG-JINJA] visitName: Name "${node.name}" resolved to: $result (type: ${result.runtimeType})');
      } catch (e) {
        log('[DEBUG-JINJA] visitName: Name "${node.name}" resolved (type: ${result.runtimeType}, toString failed)');
      }
      return result;
    } on UndefinedError catch (e) {
      log('[DEBUG-JINJA] visitName: Name "${node.name}" is undefined');
      throw UndefinedError(
        e.message,
        stackTraceValue: e.stackTrace,
        nodeValue: node,
        contextSnapshotValue: e.contextSnapshot,
        operationValue: e.operation,
        suggestionsValue: e.suggestions,
        templatePathValue: context.template,
        callStackValue: e.callStack,
        contextSnippetValue: (context.source != null && node.line != null && node.column != null)
            ? errorContextSnippet(context.source!, node.line!, node.column!)
            : null,
        variableNameValue: e.variableName,
        similarNamesValue: e.similarNames,
      );
    } on TemplateError {
      rethrow;
    } catch (e, stackTrace) {
      final contextSnapshot = captureContext(context);
      final availableKeys = <String>[
        ...context.context.keys,
        ...context.parent.keys,
      ];
      final similarNames = getSimilarNames(node.name, availableKeys);
      final suggestions = <String>[
        'Check if \'${node.name}\' is defined before using it: {% if ${node.name} %}...{% endif %}',
        if (similarNames.isNotEmpty) 'Did you mean one of these? ${similarNames.join(', ')}',
        'Ensure \'${node.name}\' is passed to the template context',
        if (availableKeys.isNotEmpty) 'Available variables: ${availableKeys.take(10).join(', ')}${availableKeys.length > 10 ? '...' : ''}',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error resolving variable \'${node.name}\': ${e.toString()}',
        stackTrace: stackTrace,
        node: node,
        contextSnapshot: contextSnapshot,
        operation: 'Resolving variable \'${node.name}\'',
        suggestions: suggestions,
        templatePath: context.template,
        contextSnippet: (context.source != null && node.line != null && node.column != null)
            ? errorContextSnippet(context.source!, node.line!, node.column!)
            : null,
      );
    }
  }

  @override
  NamespaceValue visitNamespaceRef(
    NamespaceRef node,
    StringSinkRenderContext context,
  ) {
    return NamespaceValue(node.name, node.attribute);
  }

  @override
  Object? visitScalar(Scalar node, StringSinkRenderContext context) {
    var left = node.left.accept(this, context);
    var right = node.right.accept(this, context);

    return switch (node.operator) {
      ScalarOperator.power => math.pow(left as num, right as num),
      // ignore: avoid_dynamic_calls
      ScalarOperator.module => (left as dynamic) % right,
      // ignore: avoid_dynamic_calls
      ScalarOperator.floorDivision => (left as dynamic) ~/ right,
      // ignore: avoid_dynamic_calls
      ScalarOperator.division => (left as dynamic) / right,
      // ignore: avoid_dynamic_calls
      ScalarOperator.multiple => (left as dynamic) * right,
      // ignore: avoid_dynamic_calls
      ScalarOperator.minus => (left as dynamic) - right,
      // ignore: avoid_dynamic_calls
      ScalarOperator.plus => (left as dynamic) + right,
    };
  }

  @override
  Object? visitTest(Test node, StringSinkRenderContext context) {
    var (positional, named) = node.calling.accept(this, context) as Parameters;
    return context.test(node.name, positional, named);
  }

  @override
  List<Object?> visitTuple(Tuple node, StringSinkRenderContext context) {
    return <Object?>[
      for (var value in node.values) value.accept(this, context),
    ];
  }

  @override
  Object? visitUnary(Unary node, StringSinkRenderContext context) {
    var value = node.value.accept(this, context);

    return switch (node.operator) {
      UnaryOperator.plus => value,
      // ignore: avoid_dynamic_calls
      UnaryOperator.minus => -(value as dynamic),
      UnaryOperator.not => !boolean(value),
    };
  }

  // Statements

  @override
  void visitAssign(Assign node, StringSinkRenderContext context) {
    var target = node.target.accept(this, context);
    var values = node.value.accept(this, context);
    log('[DEBUG-JINJA] visitAssign: target="$target", value=$values (type: ${values.runtimeType})');
    if (values is Future) {
      log('[DEBUG-JINJA] visitAssign: Value is Future, type: ${values.runtimeType}');
      // For async rendering, we need to await the Future before assigning
      if (context.sink is _AsyncCollectingSink) {
        final sink = context.sink as _AsyncCollectingSink;
        // Create a Future that resolves and assigns
        final assignmentFuture = values.then((resolvedValue) {
          log('[DEBUG-JINJA] visitAssign: Future resolved to: $resolvedValue, assigning to context target="$target"');
          context.assignTargets(target, resolvedValue);
          log('[DEBUG-JINJA] visitAssign: Assignment complete, target="$target"');
          return resolvedValue;
        }).catchError((e) {
          log('[DEBUG-JINJA] ERROR visitAssign: Future failed: $e');
          throw e;
        });
        // Track the assignment Future separately - it shouldn't output anything
        sink.writeAssignmentFuture(assignmentFuture);
        log('[DEBUG-JINJA] visitAssign: Tracked assignment Future, will await before finalizing');
        return;
      }
    }
    log('[DEBUG-JINJA] visitAssign: Synchronous assignment, target="$target", value=$values');
    context.assignTargets(target, values);
  }

  @override
  void visitAssignBlock(AssignBlock node, StringSinkRenderContext context) {
    var target = node.target.accept(this, context);
    var buffer = StringBuffer();
    var derived = context.derived(sink: buffer);
    node.body.accept(this, derived);

    Object? value = buffer.toString();

    var filters = node.filters;

    if (filters.isEmpty) {
      context.assignTargets(target, value);
    } else {
      // TODO(renderer): replace with Filter { BlockExpression ( AssignBlock ) }
      for (var Filter(name: name, calling: calling) in filters) {
        var (positional, named) = calling.accept(this, context) as Parameters;
        positional = [value, ...positional];
        value = context.filter(name, positional, named);
      }

      context.assignTargets(target, value);
    }
  }

  @override
  void visitAutoEscape(AutoEscape node, StringSinkRenderContext context) {
    var newContext = context.derived(autoEscape: node.enable);
    node.body.accept(this, newContext);
  }

  @override
  void visitBlock(Block node, StringSinkRenderContext context) {
    log('[DEBUG-JINJA] visitBlock: Rendering block "${node.name}"');
    context.blocks[node.name]![0](context);
    log('[DEBUG-JINJA] visitBlock: Block "${node.name}" rendered');
  }

  @override
  void visitBreak(Break node, StringSinkRenderContext context) {
    throw BreakException();
  }

  @override
  void visitCallBlock(CallBlock node, StringSinkRenderContext context) {
    log('[DEBUG-JINJA] visitCallBlock: Calling macro block');
    var function = node.call.value.accept(this, context) as MacroFunction;
    log('[DEBUG-JINJA] visitCallBlock: Macro function = $function');
    var (arguments, _) = node.call.calling.accept(this, context) as Parameters;
    var [positional as List, named as Map] = arguments;
    log('[DEBUG-JINJA] visitCallBlock: Positional args: ${positional.length}, named args: ${named.length}');
    named['caller'] = getMacroFunction(node, context);
    var result = function(positional, named);
    log('[DEBUG-JINJA] visitCallBlock: Macro result = $result (type: ${result.runtimeType})');
    context.write(result);
  }

  @override
  void visitContinue(Continue node, StringSinkRenderContext context) {
    throw ContinueException();
  }

  @override
  void visitData(Data node, StringSinkRenderContext context) {
    context.write(node.data);
  }

  @override
  void visitDebug(Debug node, StringSinkRenderContext context) {
    var buffer = StringBuffer();
    buffer.writeln('Context:');

    // Sort keys for consistent output
    var sortedKeys = context.context.keys.toList()..sort();

    for (var key in sortedKeys) {
      buffer.writeln('$key: ${context.resolve(key)}');
    }

    context.write(buffer.toString());
  }

  @override
  void visitDo(Do node, StringSinkRenderContext context) {
    node.value.accept(this, context);
  }

  @override
  void visitExtends(Extends node, StringSinkRenderContext context) {
    try {
      log('[DEBUG-JINJA] visitExtends: Extending template');
      var templateOrPath = node.template.accept(this, context);
      log('[DEBUG-JINJA] visitExtends: Template path/value = $templateOrPath (type: ${templateOrPath.runtimeType})');

      var template = switch (templateOrPath) {
        String path => () {
            log('[DEBUG-JINJA] visitExtends: Loading template from path: $path');
            return context.environment.getTemplate(path);
          }(),
        Template template => template,
        Object? value => throw TemplateRuntimeError(
            'Invalid template value: ${value.runtimeType}. Expected String or Template.',
            nodeValue: node.template,
            operationValue: 'Extending template',
            suggestionsValue: <String>[
              'Template path must be a string or Template object',
              'Check if the template path expression evaluates correctly',
              'Verify the template exists in the loader',
            ],
          ),
      };
      log('[DEBUG-JINJA] visitExtends: Template loaded, rendering extended template body');
      template.body.accept(this, context);
      log('[DEBUG-JINJA] visitExtends: Extended template rendered');
    } on BreakException {
      rethrow;
    } on ContinueException {
      rethrow;
    } on TemplateError {
      // Re-throw template errors as-is (they already have context)
      rethrow;
    } catch (e, stackTrace) {
      final contextSnapshot = captureContext(context);
      final suggestions = <String>[
        'Check if the template path is correct',
        'Verify the template exists in the loader',
        'Ensure the template path expression evaluates to a string',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error extending template: ${e.toString()}',
        stackTrace: stackTrace,
        node: node.template,
        contextSnapshot: contextSnapshot,
        operation: 'Extending template',
        suggestions: suggestions,
        templatePath: context.template,
      );
    }
  }

  @override
  void visitFilterBlock(FilterBlock node, StringSinkRenderContext context) {
    var buffer = StringBuffer();
    var derived = context.derived(sink: buffer);
    node.body.accept(this, derived);

    Object? value = buffer.toString();

    for (var Filter(name: name, calling: calling) in node.filters) {
      var (positional, named) = calling.accept(this, context) as Parameters;
      positional = <Object?>[value, ...positional];
      value = context.filter(name, positional, named);
    }

    context.write(value);
  }

  @override
  void visitFor(For node, StringSinkRenderContext context) {
    try {
      log('[DEBUG-JINJA] visitFor: Starting for loop');
      var targets = node.target.accept(this, context);
      log('[DEBUG-JINJA] visitFor: Targets = $targets');
      var iterable = node.iterable.accept(this, context);
      log('[DEBUG-JINJA] visitFor: Iterable = $iterable (type: ${iterable.runtimeType})');

      // Define render function before null check so it can be called from Future callback
      String render(Object? iterable, [int depth = 0]) {
        try {
          log('[DEBUG-JINJA] visitFor.render: Processing iterable (depth: $depth)');
          List<Object?> values;

          if (iterable is Map) {
            values = List<Object?>.of(iterable.entries);
            log('[DEBUG-JINJA] visitFor.render: Iterable is Map, converted to ${values.length} entries');
          } else {
            values = list(iterable);
            log('[DEBUG-JINJA] visitFor.render: Iterable converted to list with ${values.length} items');
          }

          if (values.isEmpty) {
            log('[DEBUG-JINJA] visitFor.render: Iterable is empty');
            if (node.orElse case var orElse?) {
              log('[DEBUG-JINJA] visitFor.render: Rendering else block');
              orElse.accept(this, context);
            }

            // Empty string prevents calling `finalize` on `null`.
            return '';
          }

          if (node.test != null) {
            var test = node.test!;
            var filtered = <Object?>[];

            for (var value in values) {
              var data = getDataForTargets(targets, value);
              var newContext = context.derived(data: data);

              if (boolean(test.accept(this, newContext))) {
                filtered.add(value);
              }
            }

            values = filtered;
          }

          var loop = LoopContext(values, depth, render);
          log('[DEBUG-JINJA] visitFor.render: Created loop context with ${values.length} items');

          int iteration = 0;
          for (var value in loop) {
            iteration++;
            log('[DEBUG-JINJA] visitFor.render: Iteration $iteration/${values.length}, value = $value');
            var data = getDataForTargets(targets, value);
            var forContext = context.derived(data: data);
            forContext.set('loop', loop);

            try {
              node.body.accept(this, forContext);
            } on BreakException {
              log('[DEBUG-JINJA] visitFor.render: Break exception, exiting loop');
              break;
            } on ContinueException {
              log('[DEBUG-JINJA] visitFor.render: Continue exception, skipping to next iteration');
              continue;
            } on TemplateError {
              // Re-throw template errors as-is (they already have context)
              rethrow;
            } catch (e, stackTrace) {
              final contextSnapshot = captureContext(forContext);
              final suggestions = <String>[
                'Check if all variables in the loop body are defined',
                'Verify expressions in the loop body are valid',
                'Ensure filters and functions are called correctly',
              ];
              throw TemplateErrorWrapper(
                e,
                message: 'Error in for loop body: ${e.toString()}',
                stackTrace: stackTrace,
                node: node.body,
                contextSnapshot: contextSnapshot,
                operation: 'Rendering for loop body',
                suggestions: suggestions,
                templatePath: context.template,
              );
            }
          }

          // Empty string prevents calling `finalize` on `null`.
          return '';
        } on BreakException {
          rethrow;
        } on ContinueException {
          rethrow;
        } on TemplateError {
          rethrow;
        } catch (e, stackTrace) {
          final contextSnapshot = captureContext(context);
          final suggestions = <String>[
            'Check if the iterable can be converted to a list',
            'Verify the iterable structure is correct',
            'Ensure the iterable is not null',
          ];
          throw TemplateErrorWrapper(
            e,
            message: 'Error processing for loop iterable: ${e.toString()}',
            stackTrace: stackTrace,
            node: node.iterable,
            contextSnapshot: contextSnapshot,
            operation: 'Processing for loop iterable',
            suggestions: suggestions,
            templatePath: context.template,
          );
        }
      }

      // If iterable is a Future, write it to the sink so AsyncRenderer can handle it
      if (iterable is Future) {
        log('[DEBUG-JINJA] visitFor: Iterable is Future, writing to sink for async handling');
        context.write(iterable);
        return;
      }

      if (iterable == null) {
        // Extract variable name from node.iterable for async re-evaluation
        String? varNameToCheck;
        if (node.iterable is Name) {
          varNameToCheck = (node.iterable as Name).name;
          log('[DEBUG-JINJA] visitFor: Extracted variable name from Name: "$varNameToCheck"');
        } else if (node.iterable is Attribute) {
          // For Attribute (e.g., menu_data.list_data), extract the base variable name (menu_data)
          final attr = node.iterable as Attribute;
          if (attr.value is Name) {
            varNameToCheck = (attr.value as Name).name;
            log('[DEBUG-JINJA] visitFor: Extracted base variable name from Attribute: "$varNameToCheck" (attribute: ${attr.attribute})');
          } else {
            // If the value is not a Name, we can't extract a simple variable name
            log('[DEBUG-JINJA] visitFor: Attribute value is not a Name, cannot extract variable name');
          }
        }

        // Check if we're in async context and should wait for Futures before throwing error
        if (varNameToCheck != null && context.sink is _AsyncCollectingSink) {
          final varName = varNameToCheck; // Store in final variable for null safety
          log('[DEBUG-JINJA] visitFor: Iterable is null for "$varName", checking for Futures before throwing error');

          final sink = context.sink as _AsyncCollectingSink;
          // Capture current Futures count BEFORE creating checkFuture to avoid circular dependency
          // The checkFuture itself will be added to _futures, so we exclude it from waitForAllFutures()
          final currentFuturesCount = sink.futuresCount;
          // Wait for ALL Futures (not just assignment Futures) because run_data_source calls
          // in interpolations might update loader.globals
          final checkFuture = sink.waitForAllFutures(maxIndex: currentFuturesCount).then((_) {
            log('[DEBUG-JINJA] visitFor: All Futures complete, re-evaluating iterable for "$varName"');
            // Re-evaluate the iterable expression - this will now resolve to the updated value
            final reEvaluatedIterable = node.iterable.accept(this, context);
            log('[DEBUG-JINJA] visitFor: Re-evaluated iterable = $reEvaluatedIterable (type: ${reEvaluatedIterable.runtimeType})');

            if (reEvaluatedIterable is Future) {
              // If it's still a Future, write it to sink and return
              log('[DEBUG-JINJA] visitFor: Re-evaluated iterable is still a Future, writing to sink');
              context.write(reEvaluatedIterable);
              return;
            }

            if (reEvaluatedIterable == null) {
              // Still null after waiting - throw the error
              log('[DEBUG-JINJA] visitFor: Re-evaluated iterable is still null, throwing UndefinedError');
              final suggestions = <String>[
                'Check if the iterable variable is defined',
                'Ensure \'$varName\' is passed to the template context',
                'Verify the iterable is not null before the for loop',
                'Use conditional rendering: {% if $varName %}{% for ... %}{% endif %}',
              ];
              throw UndefinedError(
                'Trying to access an undefined list: "$varName" from the jinja data, in a for loop',
                nodeValue: node.iterable,
                operationValue: 'Iterating over undefined variable',
                variableNameValue: varName,
                suggestionsValue: suggestions,
                templatePathValue: context.template,
              );
            }

            // Value is now available - proceed with rendering
            log('[DEBUG-JINJA] visitFor: Re-evaluated iterable is now available, proceeding with render');
            render(reEvaluatedIterable);
          });

          // Write the Future to the sink so it gets awaited
          context.write(checkFuture);
          return;
        }

        // Not in async context or couldn't extract variable name - throw error immediately
        String? iterableName = varNameToCheck;
        final suggestions = <String>[
          'Check if the iterable variable is defined',
          if (iterableName != null) 'Ensure \'$iterableName\' is passed to the template context',
          'Verify the iterable is not null before the for loop',
          'Use conditional rendering: {% if $iterableName %}{% for ... %}{% endif %}',
        ];
        throw UndefinedError(
          iterableName != null
              ? 'Trying to access an undefined list: "$iterableName" from the jinja data, in a for loop'
              : 'Trying to access an undefined iterable in a for loop',
          nodeValue: node.iterable,
          operationValue: 'Iterating over undefined variable',
          variableNameValue: iterableName,
          suggestionsValue: suggestions,
          templatePathValue: context.template,
        );
      }

      render(iterable);
    } on BreakException {
      rethrow;
    } on ContinueException {
      rethrow;
    } on TemplateError {
      // Re-throw template errors as-is (they already have context)
      rethrow;
    } catch (e, stackTrace) {
      final contextSnapshot = captureContext(context);
      final suggestions = <String>[
        'Check if the for loop target and iterable are valid',
        'Verify the iterable expression evaluates correctly',
        'Ensure all variables in the for loop are defined',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error rendering for loop: ${e.toString()}',
        stackTrace: stackTrace,
        node: node,
        contextSnapshot: contextSnapshot,
        operation: 'Rendering for loop',
        suggestions: suggestions,
        templatePath: context.template,
      );
    }
  }

  @override
  void visitFromImport(FromImport node, StringSinkRenderContext context) {
    var templateOrParth = node.template.accept(this, context);

    var template = switch (templateOrParth) {
      String path => context.environment.getTemplate(path),
      Template template => template,
      // TODO(renderer): add error message
      Object? value => throw ArgumentError.value(value, 'template'),
    };

    for (var (name, alias) in node.names) {
      Object? macro(List<Object?> positional, Map<Object?, Object?> named) {
        Macro? targetMacro;

        for (var macro in template.body.macros) {
          if (macro.name == name) {
            targetMacro = macro;
            break;
          }
        }

        if (targetMacro == null) {
          throw TemplateRuntimeError(
            "The '${template.path}' does not export the requested name.",
          );
        }

        MacroFunction function;

        if (node.withContext) {
          function = getMacroFunction(targetMacro, context);
        } else {
          var newContext = context.derived(withContext: false);
          function = getMacroFunction(targetMacro, newContext);
        }

        return function(positional, named);
      }

      context.set(alias ?? name, macro);
    }
  }

  @override
  void visitIf(If node, StringSinkRenderContext context) {
    log('[DEBUG-JINJA] visitIf: Evaluating if condition');
    final testResult = node.test.accept(this, context);
    final testBool = boolean(testResult);
    log('[DEBUG-JINJA] visitIf: Test result = $testResult, boolean = $testBool');
    if (testBool) {
      log('[DEBUG-JINJA] visitIf: Condition true, rendering body');
      node.body.accept(this, context);
    } else if (node.orElse case var orElse?) {
      log('[DEBUG-JINJA] visitIf: Condition false, rendering else block');
      orElse.accept(this, context);
    } else {
      log('[DEBUG-JINJA] visitIf: Condition false, no else block');
    }
  }

  @override
  void visitImport(Import node, StringSinkRenderContext context) {
    var templateOrParth = node.template.accept(this, context);

    var template = switch (templateOrParth) {
      String path => context.environment.getTemplate(path),
      Template template => template,
      Object? value => throw ArgumentError.value(value, 'template'),
    };

    var namespace = Namespace();

    for (var macro in template.body.macros) {
      if (node.withContext) {
        namespace[macro.name] = getMacroFunction(macro, context);
      } else {
        var newContext = context.derived(withContext: false);
        namespace[macro.name] = getMacroFunction(macro, newContext);
      }
    }

    context.set(node.target, namespace);
  }

  @override
  void visitInclude(Include node, StringSinkRenderContext context) {
    log('[DEBUG-JINJA] visitInclude: Including template');
    var templateOrParth = node.template.accept(this, context);
    log('[DEBUG-JINJA] visitInclude: Template path/value = $templateOrParth (type: ${templateOrParth.runtimeType})');

    Template? template;

    try {
      template = switch (templateOrParth) {
        String path => () {
            log('[DEBUG-JINJA] visitInclude: Loading template from path: $path');
            return context.environment.getTemplate(path);
          }(),
        Template template => template,
        List<Object?> paths => () {
            log('[DEBUG-JINJA] visitInclude: Selecting template from ${paths.length} paths');
            return context.environment.selectTemplate(paths);
          }(),
        // TODO(renderer): add error message
        Object? value => throw ArgumentError.value(value, 'template'),
      };
    } on TemplateNotFound {
      if (!node.ignoreMissing) {
        rethrow;
      }
    }

    if (template != null) {
      if (!node.withContext) {
        context = context.derived(withContext: false);
      }

      template.body.accept(this, context);
    }
  }

  @override
  void visitInterpolation(Interpolation node, StringSinkRenderContext context) {
    try {
      log('[DEBUG-JINJA] visitInterpolation: Evaluating expression');
      var value = node.value.accept(this, context);
      log('[DEBUG-JINJA] visitInterpolation: Expression evaluated to: $value (type: ${value.runtimeType})');
      var finalized = context.finalize(value);
      log('[DEBUG-JINJA] visitInterpolation: Finalized value: $finalized (type: ${finalized.runtimeType})');

      if (finalized is Future) {
        log('[DEBUG-JINJA] visitInterpolation: Finalized value is Future, writing to sink');
        context.write(
          finalized.then((value) {
            log('[DEBUG-JINJA] visitInterpolation: Future resolved to: $value');
            if (value is SafeString) {
              return value.toString();
            }
            if (context.autoEscape) {
              return escape(value.toString());
            }
            return value;
          }),
        );
        return;
      }

      // Check if value is null/empty/null-string and we're in async mode with assignment Futures
      // If so, wait for assignment Futures and re-check loader.globals
      // Handle both direct Name access and Filter-wrapped Name access (e.g., {{data | tojson}})
      String? varNameToCheck;
      if (node.value is Name) {
        varNameToCheck = (node.value as Name).name;
      } else if (node.value is Filter) {
        // Extract the underlying Name from Filter (e.g., data | tojson -> data)
        final filterNode = node.value as Filter;
        if (filterNode.calling.arguments.isNotEmpty && filterNode.calling.arguments.first is Name) {
          varNameToCheck = (filterNode.calling.arguments.first as Name).name;
        }
      }

      final isNullOrEmpty = finalized == null || finalized == '' || (finalized is String && finalized == 'null');

      if (isNullOrEmpty && varNameToCheck != null && context.sink is _AsyncCollectingSink) {
        final varName = varNameToCheck; // Store in final variable for null safety
        log('[DEBUG-JINJA] visitInterpolation: Value is null/empty/null-string for "$varName", checking for Futures');

        final sink = context.sink as _AsyncCollectingSink;
        // Capture current Futures count BEFORE creating checkFuture to avoid circular dependency
        // The checkFuture itself will be added to _futures, so we exclude it from waitForAllFutures()
        final currentFuturesCount = sink.futuresCount;
        // Write a Future that waits for ALL Futures (not just assignment Futures)
        // because run_data_source calls in interpolations might update loader.globals
        final checkFuture = sink.waitForAllFutures(maxIndex: currentFuturesCount).then((_) {
          log('[DEBUG-JINJA] visitInterpolation: All Futures complete, re-evaluating expression for "$varName"');
          // Re-evaluate the entire expression (node.value) - this will now resolve to the updated value
          // The context.resolve will now find the variable in loader.globals
          final reEvaluatedValue = node.value.accept(this, context);
          log('[DEBUG-JINJA] visitInterpolation: Re-evaluated expression = $reEvaluatedValue (type: ${reEvaluatedValue.runtimeType})');
          final reFinalized = context.finalize(reEvaluatedValue);
          log('[DEBUG-JINJA] visitInterpolation: Re-finalized value = $reFinalized (type: ${reFinalized.runtimeType})');

          if (reFinalized is Future) {
            // If it's still a Future, await it
            return reFinalized.then((value) {
              if (value is SafeString) {
                return value.toString();
              }
              if (context.autoEscape) {
                return escape(value.toString());
              }
              return value?.toString() ?? '';
            });
          }

          if (reFinalized is SafeString) {
            return reFinalized.toString();
          }
          if (context.autoEscape && reFinalized is String) {
            return escape(reFinalized);
          }
          return reFinalized?.toString() ?? '';
        });

        context.write(checkFuture);
        return;
      }

      if (finalized is SafeString) {
        log('[DEBUG-JINJA] visitInterpolation: Writing SafeString: ${finalized.toString()}');
        context.write(finalized.toString());
        return;
      }

      final output = context.autoEscape ? escape(finalized.toString()) : finalized;
      log('[DEBUG-JINJA] visitInterpolation: Writing output: $output (autoEscape: ${context.autoEscape})');
      if (context.autoEscape) {
        context.write(escape(finalized.toString()));
      } else {
        context.write(finalized);
      }
    } on BreakException {
      rethrow;
    } on ContinueException {
      rethrow;
    } on TemplateError {
      // Re-throw template errors as-is (they already have context)
      rethrow;
    } catch (e, stackTrace) {
      final contextSnapshot = captureContext(context);
      final suggestions = <String>[
        'Check if the expression evaluates correctly',
        'Verify all variables in the expression are defined',
        'Ensure the expression returns a valid value for interpolation',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error rendering interpolation: ${e.toString()}',
        stackTrace: stackTrace,
        node: node.value,
        contextSnapshot: contextSnapshot,
        operation: 'Rendering interpolation expression',
        suggestions: suggestions,
        templatePath: context.template,
      );
    }
  }

  @override
  void visitMacro(Macro node, StringSinkRenderContext context) {
    var function = getMacroFunction(node, context);
    context.set(node.name, function);
  }

  @override
  void visitOutput(Output node, StringSinkRenderContext context) {
    try {
      for (var childNode in node.nodes) {
        childNode.accept(this, context);
      }
    } on BreakException {
      rethrow;
    } on ContinueException {
      rethrow;
    } on TemplateError {
      // Re-throw template errors as-is (they already have context)
      rethrow;
    } catch (e, stackTrace) {
      final contextSnapshot = captureContext(context);
      final suggestions = <String>[
        'Check if all expressions in the output block are valid',
        'Verify variables are defined before use',
        'Ensure filters and functions are called correctly',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error rendering output block: ${e.toString()}',
        stackTrace: stackTrace,
        node: node,
        contextSnapshot: contextSnapshot,
        operation: 'Rendering output block',
        suggestions: suggestions,
        templatePath: context.template,
      );
    }
  }

  @override
  void visitTemplateNode(TemplateNode node, StringSinkRenderContext context) {
    try {
      log('[DEBUG-JINJA] visitTemplateNode: Starting template node rendering');
      log('[DEBUG-JINJA] visitTemplateNode: Template has ${node.blocks.length} blocks');
      // TODO(renderer): add `TemplateReference`
      var self = Namespace();

      for (var block in node.blocks) {
        var blockName = block.name;
        log('[DEBUG-JINJA] visitTemplateNode: Processing block "$blockName"');

        // TODO(compiler): switch to `ContextCallback`
        String render() {
          var blocks = context.blocks[blockName];

          if (blocks == null) {
            final suggestions = <String>[
              'Check if the block \'$blockName\' is defined in a parent template',
              'Verify the block name matches between parent and child templates',
              'Ensure the block is defined before it is called',
            ];
            throw UndefinedError(
              "Block '$blockName' is not defined.",
              operationValue: 'Rendering block \'$blockName\'',
              suggestionsValue: suggestions,
              templatePathValue: context.template,
            );
          }

          // TODO(renderer): check if empty
          blocks[0](context);
          return '';
        }

        self[blockName] = render;

        var blocks = context.blocks[blockName] ??= <ContextCallback>[];

        if (block.required) {
          Never callback(Context context) {
            final suggestions = <String>[
              'Required block \'${block.name}\' must be defined in a child template',
              'Add {% block ${block.name} %}...{% endblock %} in the child template',
            ];
            throw TemplateRuntimeError(
              "Required block '${block.name}' not found.",
              operationValue: 'Rendering required block \'${block.name}\'',
              suggestionsValue: suggestions,
              templatePathValue: context.template,
            );
          }

          blocks.add(callback);
        } else {
          var parentIndex = blocks.length + 1;

          void callback(Context context) {
            var current = context.get('super');

            // TODO(renderer): add `BlockReference`
            String parent() {
              var blocks = context.blocks[blockName]!;

              if (parentIndex >= blocks.length) {
                final suggestions = <String>[
                  'Super block \'$blockName\' not found in parent template',
                  'Check if the parent template defines this block',
                  'Verify the block inheritance chain is correct',
                ];
                throw TemplateRuntimeError(
                  "Super block '$blockName' not found.",
                  operationValue: 'Calling super block \'$blockName\'',
                  suggestionsValue: suggestions,
                  templatePathValue: context.template,
                );
              }

              blocks[parentIndex](context);
              return '';
            }

            context.set('super', parent);
            block.body.accept(this, context);
            context.set('super', current);
          }

          blocks.add(callback);
        }
      }

      context.set('self', self);
      log('[DEBUG-JINJA] visitTemplateNode: Rendering template body');
      node.body.accept(this, context);
      log('[DEBUG-JINJA] visitTemplateNode: Template body rendered');
    } on BreakException {
      rethrow;
    } on ContinueException {
      rethrow;
    } on TemplateError {
      // Re-throw template errors as-is (they already have context)
      rethrow;
    } catch (e, stackTrace) {
      final contextSnapshot = captureContext(context);
      final suggestions = <String>[
        'Check if all blocks are properly defined',
        'Verify the template structure is correct',
        'Ensure block names match between templates',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error rendering template node: ${e.toString()}',
        stackTrace: stackTrace,
        node: node,
        contextSnapshot: contextSnapshot,
        operation: 'Rendering template node',
        suggestions: suggestions,
        templatePath: context.template,
      );
    }
  }

  @override
  void visitTrans(Trans node, StringSinkRenderContext context) {
    // Collect the body content
    var bodyBuffer = StringBuffer();
    var bodyContext = context.derived(sink: bodyBuffer);
    node.body.accept(this, bodyContext);
    var bodyText = bodyBuffer.toString();

    // Check if plural
    var countValue = node.count?.accept(this, context);

    String? pluralText;
    if (node.plural != null) {
      var pluralBuffer = StringBuffer();
      var pluralContext = context.derived(sink: pluralBuffer);
      node.plural!.accept(this, pluralContext);
      pluralText = pluralBuffer.toString();
    }

    // Prepare translations functions
    // We expect standard gettext functions to be available in the environment/context

    Object? result;

    if (countValue != null) {
      // Plural translation
      // ngettext(singular, plural, count) or npgettext(context, singular, plural, count)

      if (node.context != null) {
        // Contextual plural
        try {
          // Try npgettext
          var npgettext = context.resolve('npgettext');
          if (npgettext is Function) {
            result = Function.apply(npgettext, [node.context, bodyText, pluralText ?? bodyText, countValue]);
          } else {
            // Fallback to ngettext if context not supported directly or npgettext not found,
            // but we really should use context if provided.
            // If neither exists, we just output raw strings.
            var ngettext = context.resolve('ngettext');
            if (ngettext is Function) {
              result = Function.apply(ngettext, [bodyText, pluralText ?? bodyText, countValue]);
            }
          }
        } catch (e) {
          // ignore
        }
      } else {
        // Standard plural
        try {
          var ngettext = context.resolve('ngettext');
          if (ngettext is Function) {
            result = Function.apply(ngettext, [bodyText, pluralText ?? bodyText, countValue]);
          }
        } catch (e) {
          // ignore
        }
      }

      // Fallback if no translation function or it failed
      if (result == null) {
        var count = countValue is num ? countValue : 1;
        result = count == 1 ? bodyText : (pluralText ?? bodyText);
      }
    } else {
      // Singular translation
      // gettext(msg) or pgettext(context, msg)

      if (node.context != null) {
        try {
          var pgettext = context.resolve('pgettext');
          if (pgettext is Function) {
            result = Function.apply(pgettext, [node.context, bodyText]);
          } else {
            // Fallback
            var gettext = context.resolve('gettext');
            if (gettext is Function) {
              result = Function.apply(gettext, [bodyText]);
            }
          }
        } catch (e) {
          // ignore
        }
      } else {
        try {
          var gettext = context.resolve('gettext');
          if (gettext is Function) {
            result = Function.apply(gettext, [bodyText]);
          } else {
            // Try underscore alias
            var underscore = context.resolve('_');
            if (underscore is Function) {
              result = Function.apply(underscore, [bodyText]);
            }
          }
        } catch (e) {
          // ignore
        }
      }

      result ??= bodyText;
    }

    // Apply trimming if requested
    var text = result.toString();
    if (node.trimmed) {
      // Basic trimming: replace newlines and surrounding whitespace with single space
      // and strip leading/trailing whitespace
      text = text.trim().replaceAll(RegExp(r'\s*\n\s*'), ' ');
    }

    // Perform interpolation on the result string?
    // Jinja's trans tag usually treats the body as the message ID, and variable interpolation
    // happens *after* translation if using variable tags inside, OR passing vars to format.
    // However, in this implementation, we evaluated the body first (to get message ID/default).
    // If the body contained variables, they are already interpolated in `bodyText`.
    // Standard Jinja `{% trans %}` often disallows variables in body unless used for interpolation.
    // Given the complexity, this simple implementation assumes the `trans` body is the translation key.
    // Ideally, for `{% trans %}`, variables are placeholders.
    // Supporting full Jinja i18n is complex. This matches basic usage.

    context.write(text);
  }

  @override
  void visitTryCatch(TryCatch node, StringSinkRenderContext context) {
    try {
      node.body.accept(this, context);
    } on BreakException {
      rethrow;
    } on ContinueException {
      rethrow;
    } catch (error) {
      if (node.exception case var exception?) {
        var taget = exception.accept(this, context);
        context.assignTargets(taget, error);
      }

      node.catchBody.accept(this, context);
    }
  }

  @override
  void visitWith(With node, StringSinkRenderContext context) {
    var targets = <Object?>[
      for (var target in node.targets) target.accept(this, context),
    ];

    var values = <Object?>[
      for (var value in node.values) value.accept(this, context),
    ];

    var data = getDataForTargets(targets, values);
    var newContext = context.derived(data: data);
    node.body.accept(this, newContext);
  }

  @override
  Object? visitSlice(Slice node, StringSinkRenderContext context) {
    try {
      var value = node.value.accept(this, context);
      var start = node.start?.accept(this, context) ?? 0;
      var stop = node.stop?.accept(this, context);

      if (value is List && start is int && stop is int?) {
        if (start < 0 || (stop != null && stop < start)) {
          final suggestions = <String>[
            'Slice start must be >= 0',
            'Slice stop must be >= start',
            'Check if the slice indices are valid',
          ];
          throw TemplateRuntimeError(
            'Invalid slice indices: start=$start, stop=$stop',
            nodeValue: node,
            operationValue: 'Slicing list',
            suggestionsValue: suggestions,
            templatePathValue: context.template,
          );
        }
        if (start >= value.length) {
          final suggestions = <String>[
            'Slice start index ($start) is out of bounds for list of length ${value.length}',
            'Use a start index between 0 and ${value.length - 1}',
          ];
          throw TemplateRuntimeError(
            'Slice start index out of bounds: $start >= ${value.length}',
            nodeValue: node,
            operationValue: 'Slicing list',
            suggestionsValue: suggestions,
            templatePathValue: context.template,
          );
        }
        return value.sublist(start, stop);
      }

      final suggestions = <String>[
        'Slice operation only works on lists',
        'Value type: ${value.runtimeType}, expected List',
        'Start type: ${start.runtimeType}, expected int',
        if (stop != null) 'Stop type: ${stop.runtimeType}, expected int',
      ];
      throw TemplateRuntimeError(
        'Invalid slice operation: value is ${value.runtimeType}, not List.',
        nodeValue: node,
        operationValue: 'Slicing ${value.runtimeType}',
        suggestionsValue: suggestions,
        templatePathValue: context.template,
      );
    } on BreakException {
      rethrow;
    } on ContinueException {
      rethrow;
    } on TemplateError {
      rethrow;
    } catch (e, stackTrace) {
      final contextSnapshot = captureContext(context);
      final suggestions = <String>[
        'Check if the slice value is a list',
        'Verify slice indices are integers',
        'Ensure slice indices are within bounds',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error performing slice operation: ${e.toString()}',
        stackTrace: stackTrace,
        node: node,
        contextSnapshot: contextSnapshot,
        operation: 'Performing slice operation',
        suggestions: suggestions,
        templatePath: context.template,
      );
    }
  }
}

/// Custom sink that collects Futures written during rendering
class _AsyncCollectingSink implements StringSink {
  final StringSink _delegate;
  final List<Future<Object?>> _futures = [];
  final List<bool> _isAssignmentFuture = []; // Track if Future is from assignment (shouldn't output)
  final StringBuffer _buffer = StringBuffer();

  _AsyncCollectingSink(this._delegate);

  /// Get the current number of Futures being tracked
  int get futuresCount => _futures.length;

  @override
  void write(Object? obj) {
    if (obj is Future) {
      // Store the Future and write a placeholder
      log('[DEBUG-JINJA] _AsyncCollectingSink.write: Received Future (index ${_futures.length}), writing placeholder');
      _futures.add(obj);
      _isAssignmentFuture.add(false); // Default: not an assignment
      _buffer.write('__FUTURE_${_futures.length - 1}__');
    } else {
      log('[DEBUG-JINJA] _AsyncCollectingSink.write: Writing value: $obj (type: ${obj.runtimeType})');
      _buffer.write(obj);
    }
  }

  /// Write a Future from an assignment - this shouldn't output anything, just await it
  void writeAssignmentFuture(Future<Object?> future) {
    log('[DEBUG-JINJA] _AsyncCollectingSink.writeAssignmentFuture: Tracking assignment Future (index ${_futures.length})');
    _futures.add(future);
    _isAssignmentFuture.add(true); // Mark as assignment Future
    // Don't write anything to buffer - assignments shouldn't output
  }

  /// Returns a Future that resolves when all assignment Futures are complete
  Future<void> waitForAssignmentFutures() async {
    final assignmentCount = _isAssignmentFuture.where((isAssignment) => isAssignment).length;
    log('[DEBUG-JINJA] _AsyncCollectingSink.waitForAssignmentFutures: Waiting for $assignmentCount assignment Futures');
    for (int i = 0; i < _futures.length; i++) {
      if (_isAssignmentFuture[i]) {
        log('[DEBUG-JINJA] _AsyncCollectingSink.waitForAssignmentFutures: Awaiting assignment Future $i');
        await _futures[i];
        log('[DEBUG-JINJA] _AsyncCollectingSink.waitForAssignmentFutures: Assignment Future $i completed');
      }
    }
    log('[DEBUG-JINJA] _AsyncCollectingSink.waitForAssignmentFutures: All assignment Futures completed');
  }

  /// Returns a Future that resolves when ALL Futures (assignment and non-assignment) are complete
  /// [maxIndex] if provided, only awaits Futures up to this index (exclusive).
  /// This prevents circular dependencies when waitForAllFutures() itself creates Futures.
  Future<void> waitForAllFutures({int? maxIndex}) async {
    // If maxIndex is provided, use it; otherwise await all current Futures
    // This allows callers to exclude Futures added after waitForAllFutures() was called
    final futuresToAwait = maxIndex ?? _futures.length;
    log('[DEBUG-JINJA] _AsyncCollectingSink.waitForAllFutures: Waiting for $futuresToAwait Futures (current count: ${_futures.length}, maxIndex: $maxIndex)');
    for (int i = 0; i < futuresToAwait; i++) {
      log('[DEBUG-JINJA] _AsyncCollectingSink.waitForAllFutures: Awaiting Future $i/$futuresToAwait (isAssignment: ${_isAssignmentFuture[i]})');
      await _futures[i];
      log('[DEBUG-JINJA] _AsyncCollectingSink.waitForAllFutures: Future $i completed');
    }
    log('[DEBUG-JINJA] _AsyncCollectingSink.waitForAllFutures: All Futures completed');
  }

  @override
  void writeCharCode(int charCode) {
    _buffer.writeCharCode(charCode);
  }

  @override
  void writeln([Object? obj = '']) {
    write(obj);
    _buffer.writeln();
  }

  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) {
    var iterator = objects.iterator;
    if (!iterator.moveNext()) return;
    if (separator.isEmpty) {
      do {
        write(iterator.current);
      } while (iterator.moveNext());
    } else {
      write(iterator.current);
      while (iterator.moveNext()) {
        write(separator);
        write(iterator.current);
      }
    }
  }

  Future<String> getResolvedContent() async {
    String content = _buffer.toString();
    log('[DEBUG-JINJA] _AsyncCollectingSink.getResolvedContent: Starting, ${_futures.length} Futures to await');
    log('[DEBUG-JINJA] _AsyncCollectingSink.getResolvedContent: Buffer content length: ${content.length}');
    log(
      '[DEBUG-JINJA] _AsyncCollectingSink.getResolvedContent: Buffer preview: ${content.length > 100 ? "${content.substring(0, 100)}..." : content}',
    );

    // Await all collected Futures
    List<Object?> resolvedValues = [];
    for (int i = 0; i < _futures.length; i++) {
      try {
        log(
          '[DEBUG-JINJA] _AsyncCollectingSink.getResolvedContent: Awaiting Future $i/${_futures.length} (isAssignment: ${_isAssignmentFuture[i]})',
        );
        resolvedValues.add(await _futures[i]);
        log(
          '[DEBUG-JINJA] _AsyncCollectingSink.getResolvedContent: Future $i resolved to: ${resolvedValues[i]} (type: ${resolvedValues[i].runtimeType})',
        );
      } on BreakException {
        rethrow;
      } on ContinueException {
        rethrow;
      } on TemplateError {
        // Re-throw template errors as-is (they already have context)
        rethrow;
      } catch (e, stackTrace) {
        // Wrap non-template exceptions with context
        final suggestions = <String>[
          'Check if the async function completes successfully',
          'Verify the async function returns the expected type',
          'Ensure the async function handles errors properly',
        ];
        throw TemplateErrorWrapper(
          e,
          message: 'Error resolving async Future at index $i: ${e.toString()}',
          stackTrace: stackTrace,
          operation: 'Resolving async Future value',
          suggestions: suggestions,
        );
      }
    }

    // Replace placeholders with resolved values (skip assignment Futures)
    log('[DEBUG-JINJA] _AsyncCollectingSink.getResolvedContent: Replacing placeholders in content');
    for (int i = 0; i < resolvedValues.length; i++) {
      if (!_isAssignmentFuture[i]) {
        // Only replace placeholders for non-assignment Futures
        final placeholder = '__FUTURE_${i}__';
        final replacement = resolvedValues[i]?.toString() ?? 'null';
        log('[DEBUG-JINJA] _AsyncCollectingSink.getResolvedContent: Replacing $placeholder with "$replacement"');
        content = content.replaceAll(placeholder, replacement);
      } else {
        log('[DEBUG-JINJA] _AsyncCollectingSink.getResolvedContent: Skipping placeholder replacement for assignment Future $i');
      }
      // Assignment Futures don't have placeholders, so nothing to replace
    }

    log('[DEBUG-JINJA] _AsyncCollectingSink.getResolvedContent: Final content length: ${content.length}');
    return content;
  }
}

/// Async renderer that supports async function calls and global resolution.
///
/// This renderer properly awaits Future values returned from function calls
/// during template rendering.
base class AsyncRenderer {
  const AsyncRenderer();

  final StringSinkRenderer _baseRenderer = const StringSinkRenderer();

  /// Renders a template node asynchronously, resolving all Future values in globals and during rendering.
  Future<void> render(TemplateNode node, AsyncRenderContext context) async {
    try {
      log('[DEBUG-JINJA] AsyncRenderer.render: Starting async render');
      // First, resolve all async values in parent (globals)
      var resolvedGlobals = <String, Object?>{};
      log('[DEBUG-JINJA] AsyncRenderer.render: Resolving ${context.parent.length} parent globals');
      for (var entry in context.parent.entries) {
        if (entry.value is Future) {
          try {
            log('[DEBUG-JINJA] AsyncRenderer.render: Resolving async global "${entry.key}"');
            resolvedGlobals[entry.key] = await (entry.value as Future);
          } on BreakException {
            rethrow;
          } on ContinueException {
            rethrow;
          } on TemplateError {
            rethrow;
          } catch (e, stackTrace) {
            final suggestions = <String>[
              'Check if the async global \'${entry.key}\' completes successfully',
              'Verify the async global returns the expected type',
              'Ensure the async global handles errors properly',
            ];
            throw TemplateErrorWrapper(
              e,
              message: 'Error resolving async global \'${entry.key}\': ${e.toString()}',
              stackTrace: stackTrace,
              operation: 'Resolving async global \'${entry.key}\'',
              suggestions: suggestions,
              templatePath: context.template,
            );
          }
        } else {
          resolvedGlobals[entry.key] = entry.value;
        }
      }

      // Also resolve async values in context data
      var resolvedData = <String, Object?>{};
      log('[DEBUG-JINJA] AsyncRenderer.render: Resolving ${context.context.length} context variables');
      for (var entry in context.context.entries) {
        if (entry.value is Future) {
          try {
            log('[DEBUG-JINJA] AsyncRenderer.render: Resolving async context variable "${entry.key}"');
            resolvedData[entry.key] = await (entry.value as Future);
            log('[DEBUG-JINJA] AsyncRenderer.render: Context variable "${entry.key}" resolved to: ${resolvedData[entry.key]}');
          } on BreakException {
            rethrow;
          } on ContinueException {
            rethrow;
          } on TemplateError {
            rethrow;
          } catch (e, stackTrace) {
            final suggestions = <String>[
              'Check if the async variable \'${entry.key}\' completes successfully',
              'Verify the async variable returns the expected type',
              'Ensure the async variable handles errors properly',
            ];
            throw TemplateErrorWrapper(
              e,
              message: 'Error resolving async variable \'${entry.key}\': ${e.toString()}',
              stackTrace: stackTrace,
              operation: 'Resolving async variable \'${entry.key}\'',
              suggestions: suggestions,
              templatePath: context.template,
            );
          }
        } else {
          resolvedData[entry.key] = entry.value;
          log('[DEBUG-JINJA] AsyncRenderer.render: Context variable "${entry.key}" is synchronous: ${entry.value}');
        }
      }

      // Create a custom sink that collects Futures
      log('[DEBUG-JINJA] AsyncRenderer.render: Creating _AsyncCollectingSink');
      _AsyncCollectingSink collectingSink = _AsyncCollectingSink(context.sink);

      // Create a sync context with the collecting sink
      log(
        '[DEBUG-JINJA] AsyncRenderer.render: Creating sync context with ${resolvedGlobals.length} globals, ${resolvedData.length} context vars',
      );
      var syncContext = StringSinkRenderContext(
        context.environment,
        collectingSink,
        template: context.template,
        blocks: context.blocks,
        parent: resolvedGlobals,
        data: resolvedData,
      );

      // Use the base synchronous renderer
      log('[DEBUG-JINJA] AsyncRenderer.render: Starting synchronous template rendering');
      _baseRenderer.visitTemplateNode(node, syncContext);
      log('[DEBUG-JINJA] AsyncRenderer.render: Synchronous rendering complete, resolving Futures');

      // Get the resolved content and write it to the original sink
      String resolvedContent = await collectingSink.getResolvedContent();
      log('[DEBUG-JINJA] AsyncRenderer.render: All Futures resolved, writing final content (length: ${resolvedContent.length})');
      context.sink.write(resolvedContent);
      log('[DEBUG-JINJA] AsyncRenderer.render: Render complete');
    } on BreakException {
      rethrow;
    } on ContinueException {
      rethrow;
    } on TemplateError {
      // Re-throw template errors as-is (they already have context)
      rethrow;
    } catch (e, stackTrace) {
      // Wrap non-template exceptions with context
      final contextSnapshot = captureContext(context);
      final suggestions = <String>[
        'Check if all async values resolve successfully',
        'Verify async function calls complete without errors',
        'Ensure async globals and variables are properly awaited',
      ];
      throw TemplateErrorWrapper(
        e,
        message: 'Error during async template rendering: ${e.toString()}',
        stackTrace: stackTrace,
        contextSnapshot: contextSnapshot,
        operation: 'Rendering template asynchronously',
        suggestions: suggestions,
        templatePath: context.template,
      );
    }
  }
}
