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
        callStack: captureCallStack(),
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
        buffer = _AsyncCollectingSink(StringBuffer(), context.environment);
      } else {
        buffer = StringBuffer();
      }
      var derived = context.derived(sink: buffer);

      // Normalize packed calling convention for MacroFunction.
      // Some call paths provide:
      //   positional = [positionalArgsList, namedKwargsMap]
      // and `named` is empty.
      // If `namedKwargsMap` is empty or uses Symbol keys, we unwrap it.
      var positionalArgs = positional;
      var namedArgs = named;
      if (namedArgs.isEmpty && positionalArgs.length == 2 && positionalArgs[0] is List && positionalArgs[1] is Map) {
        final second = positionalArgs[1] as Map;
        final secondHasSymbolKeys = second.keys.any((k) => k is Symbol);
        if (second.isEmpty || secondHasSymbolKeys) {
          positionalArgs = (positionalArgs[0] as List).cast<Object?>();
          namedArgs = Map<Object?, Object?>.from(second);
        }
      }

      var index = 0;
      var mandatoryLength = node.positional.length;
      var remaining = namedArgs.keys.toSet();
      const missing = Object();

      Object? takeNamedValue(String key) {
        // Keyword arg binding uses Symbol keys, but in some code paths we also
        // support string keys. Additionally, the parser rewrites `default=...`
        // keyword args to `defaultValue=...`, so map that back here.
        if (remaining.remove(key)) return namedArgs[key];

        final symKey = Symbol(key);
        if (remaining.remove(symKey)) return namedArgs[symKey];

        // Fall back: Symbols can differ by identity even when they represent
        // the same textual key (edge cases across compilation paths).
        // Use a stringified match to locate the actual Symbol in `remaining`.
        for (final k in remaining.whereType<Symbol>()) {
          if (k.toString().contains('Symbol("$key")')) {
            remaining.remove(k);
            return namedArgs[k];
          }
        }
        if (key == 'default') {
          // Avoid Symbol equality pitfalls by removing the exact Symbol instance
          // already present in `remaining`.
          final candidates = remaining.whereType<Symbol>().toList();
          for (final sym in candidates) {
            if (sym.toString().contains('defaultValue')) {
              remaining.remove(sym);
              return namedArgs[sym];
            }
          }
        }
        return missing;
      }

      try {
        // 1. Mandatory positional arguments
        for (; index < mandatoryLength; index += 1) {
          var key = node.positional[index].accept(this, context) as String;
          if (index < positionalArgs.length) {
            derived.set(key, positionalArgs[index]);
            continue;
          }

          // Support keyword arguments for parameters declared positionally.
          final taken = takeNamedValue(key);
          if (taken != missing) {
            derived.set(key, taken);
          } else {
            // Jinja templates often omit `default` for helper macros like
            // `_populate(..., optional=true)` and expect it to behave as
            // `None`/falsey.
            if (key == 'default') {
              derived.set(key, null);
            } else {
              throw TemplateRuntimeError(
                'Missing required macro argument "$key" for macro ${node.name}.',
                operationValue: 'Calling macro ${node.name}',
                templatePathValue: context.template,
              );
            }
          }
        }

        // 2. Optional arguments (node.named) - fill from positional if available, else named/default
        for (var (argument, defaultValue) in node.named) {
          var key = argument.accept(this, context) as String;

          if (index < positionalArgs.length) {
            // Use positional argument
            derived.set(key, positionalArgs[index]);
            index++;
          } else {
            // Check named arguments
            final taken = takeNamedValue(key);
            if (taken != missing) {
              derived.set(key, taken);
            } else {
              // Evaluate default value
              if (defaultValue is Name) {
                // For Name defaults like b=x, look in named arguments only
                // This allows defaults to reference other macro parameters
                // Check both String and Symbol keys
                var defaultValueValue = namedArgs[defaultValue.name];
                defaultValueValue ??= namedArgs[Symbol(defaultValue.name)];
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
          derived.set('varargs', positionalArgs.sublist(index));
        } else if (index < positionalArgs.length) {
          throw TemplateRuntimeError('''Error at macro ${node.name},
            expected arguments count: $index
            given arguments count: ${positionalArgs.length}
            given arguments: ${positionalArgs.toString()},
            ''');
        }

        // 4. Kwargs
        if (node.kwargs) {
          var kwargs = <Object?, Object?>{};
          for (var key in remaining) {
            if (key is String) {
              kwargs[key] = namedArgs[key];
            } else if (key is Symbol) {
              // Convert Symbol to String for kwargs
              var keyStr = key.toString().replaceAll('Symbol("', '').replaceAll('")', '');
              kwargs[keyStr] = namedArgs[key];
            } else {
              kwargs[key] = namedArgs[key];
            }
          }
          derived.set('kwargs', kwargs);
        } else if (remaining.isNotEmpty) {
          throw TemplateRuntimeError(
            'remaining.isNotEmpty: ${remaining.map((e) => e.toString()).join(', ')}',
          );
        }
      } catch (e) {
        throw TemplateRuntimeError('''Error at macro ${node.name},
            expected arguments count: ${mandatoryLength + node.named.length} (mandatory: $mandatoryLength)
            given arguments count: ${positionalArgs.length}
            given arguments: ${positionalArgs.toString()},
            error: ${e.toString()}
            ''');
      }

      final templatePath = derived.template ?? context.template ?? '<unknown>';

      // If buffer is an async collecting sink, return a Future that resolves it
      if (buffer is _AsyncCollectingSink) {
        final _AsyncCollectingSink asyncBuffer = buffer;
        return withRenderFrameAsync<SafeString>(
          templatePath: templatePath,
          line: node.line,
          description: 'macro ${node.name}',
          body: () async {
            node.body.accept(this, derived);
            final content = await asyncBuffer.getResolvedContent();
            // Macro output should be safe if auto-escaping was enabled during rendering
            return SafeString(content);
          },
        );
      }

      // Macro output should be safe if auto-escaping was enabled during rendering.
      // This prevents double escaping when the macro result is used in an interpolation.
      return withRenderFrame<SafeString>(
        templatePath: templatePath,
        line: node.line,
        description: 'macro ${node.name}',
        body: () {
          node.body.accept(this, derived);
          return SafeString(buffer.toString());
        },
      );
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
    context.environment.debugJinja(
      'visitAttribute: Accessing attribute "${node.attribute}" on value',
    );
    var value = node.value.accept(this, context);
    context.environment.debugJinja(
      'visitAttribute: Value = $value (type: ${value.runtimeType}), '
      'accessing attribute "${node.attribute}"',
    );
    final result = context.attribute(node.attribute, value, node);
    context.environment.debugJinja(
      'visitAttribute: Attribute "${node.attribute}" result = $result '
      '(type: ${result.runtimeType})',
    );
    return result;
  }

  @override
  Object? visitCall(Call node, StringSinkRenderContext context) {
    context.environment.debugJinja('visitCall: Calling function');
    var function = node.value.accept(this, context);
    context.environment.debugJinja(
      'visitCall: Function = $function (type: ${function.runtimeType})',
    );
    var (positional, named) = node.calling.accept(this, context) as Parameters;
    context.environment.debugJinja(
      'visitCall: Positional args: ${positional.length}, '
      'named args: ${named.length}',
    );
    final result = context.call(function, node, positional, named);
    context.environment.debugJinja(
      'visitCall: Function call result = $result (type: ${result.runtimeType})',
    );
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
    context.environment.debugJinja(
      'visitConcat: Concatenating ${node.values.length} values',
    );
    var buffer = StringBuffer();

    for (var i = 0; i < node.values.length; i++) {
      final value = node.values[i].accept(this, context);
      context.environment.debugJinja(
        'visitConcat: Value $i = $value (type: ${value.runtimeType})',
      );
      buffer.write(value);
    }

    final result = buffer.toString();
    context.environment.debugJinja(
      'visitConcat: Concatenated result = "$result" (length: ${result.length})',
    );
    return result;
  }

  @override
  Object? visitCondition(Condition node, StringSinkRenderContext context) {
    context.environment.debugJinja('visitCondition: Evaluating ternary condition');
    final testResult = node.test.accept(this, context);
    final testBool = boolean(testResult);
    context.environment.debugJinja(
      'visitCondition: Test result = $testResult, boolean = $testBool',
    );
    if (testBool) {
      context.environment.debugJinja(
        'visitCondition: Condition true, returning trueValue',
      );
      return node.trueValue.accept(this, context);
    }
    context.environment.debugJinja(
      'visitCondition: Condition false, returning falseValue',
    );
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
    context.environment.debugJinja(
      'visitFilter: Applying filter "${node.name}"',
    );
    var (positional, named) = node.calling.accept(this, context) as Parameters;
    context.environment.debugJinja(
      'visitFilter: Filter "${node.name}" - positional args: '
      '${positional.length}, named args: ${named.length}',
    );
    // Return the Future without awaiting - the AsyncRenderer will handle it
    final result = context.filter(node.name, positional, named);
    context.environment.debugJinja(
      'visitFilter: Filter "${node.name}" result = $result '
      '(type: ${result.runtimeType})',
    );
    return result;
  }

  @override
  Object? visitItem(Item node, StringSinkRenderContext context) {
    context.environment.debugJinja('visitItem: Accessing item');
    var key = node.key.accept(this, context);
    var value = node.value.accept(this, context);
    context.environment.debugJinja(
      'visitItem: Key = $key (type: ${key.runtimeType}), value = $value '
      '(type: ${value.runtimeType})',
    );
    final result = context.item(key, value, node);
    context.environment.debugJinja(
      'visitItem: Item access result = $result (type: ${result.runtimeType})',
    );
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
      context.environment.debugJinja(
        'visitName: Resolving name "${node.name}" (context: ${node.context})',
      );
      final result = switch (node.context) {
        AssignContext.load => context.resolve(node.name),
        _ => node.name,
      };
      try {
        context.environment.debugJinja(
          'visitName: Name "${node.name}" resolved to: $result '
          '(type: ${result.runtimeType})',
        );
      } catch (e) {
        context.environment.debugJinja(
          'visitName: Name "${node.name}" resolved '
          '(type: ${result.runtimeType}, toString failed)',
        );
      }
      return result;
    } on UndefinedError catch (e) {
      context.environment.debugJinja(
        'visitName: Name "${node.name}" is undefined',
      );
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
        callStack: captureCallStack(),
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
    context.environment.debugJinja(
      'visitAssign: target="$target", value=$values '
      '(type: ${values.runtimeType})',
    );
    if (values is Future) {
      context.environment.debugJinja(
        'visitAssign: Value is Future, type: ${values.runtimeType}',
      );
      // For async rendering, we need to await the Future before assigning
      if (context.sink is _AsyncCollectingSink) {
        final sink = context.sink as _AsyncCollectingSink;
        // Create a Future that resolves and assigns
        final assignmentFuture = values.then((resolvedValue) {
          context.environment.debugJinja(
            'visitAssign: Future resolved to: $resolvedValue, '
            'assigning to context target="$target"',
          );
          context.assignTargets(target, resolvedValue);
          context.environment.debugJinja(
            'visitAssign: Assignment complete, target="$target"',
          );
          return resolvedValue;
        }).catchError((e) {
          context.environment.debugJinja(
            'ERROR visitAssign: Future failed: $e',
          );
          throw e;
        });
        // Track the assignment Future separately - it shouldn't output anything
        sink.writeAssignmentFuture(assignmentFuture);
        context.environment.debugJinja(
          'visitAssign: Tracked assignment Future, will await before finalizing',
        );
        return;
      }
    }
    context.environment.debugJinja(
      'visitAssign: Synchronous assignment, target="$target", value=$values',
    );
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
    context.environment.debugJinja(
      'visitBlock: Rendering block "${node.name}"',
    );
    context.blocks[node.name]![0](context);
    context.environment.debugJinja(
      'visitBlock: Block "${node.name}" rendered',
    );
  }

  @override
  void visitBreak(Break node, StringSinkRenderContext context) {
    throw BreakException();
  }

  @override
  void visitCallBlock(CallBlock node, StringSinkRenderContext context) {
    context.environment.debugJinja('visitCallBlock: Calling macro block');
    var function = node.call.value.accept(this, context) as MacroFunction;
    context.environment.debugJinja(
      'visitCallBlock: Macro function = $function',
    );
    var (arguments, _) = node.call.calling.accept(this, context) as Parameters;
    var [positional as List, named as Map] = arguments;
    context.environment.debugJinja(
      'visitCallBlock: Positional args: ${positional.length}, '
      'named args: ${named.length}',
    );
    named['caller'] = getMacroFunction(node, context);
    var result = function(positional, named);
    context.environment.debugJinja(
      'visitCallBlock: Macro result = $result (type: ${result.runtimeType})',
    );
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
      context.environment.debugJinja('visitExtends: Extending template');
      var templateOrPath = node.template.accept(this, context);
      context.environment.debugJinja(
        'visitExtends: Template path/value = $templateOrPath '
        '(type: ${templateOrPath.runtimeType})',
      );

      var template = switch (templateOrPath) {
        String path => () {
            context.environment.debugJinja(
              'visitExtends: Loading template from path: $path',
            );
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
      context.environment.debugJinja(
        'visitExtends: Template loaded, rendering extended template body',
      );
      template.body.accept(this, context);
      context.environment.debugJinja('visitExtends: Extended template rendered');
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
        callStack: captureCallStack(),
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
      context.environment.debugJinja('visitFor: Starting for loop');
      var targets = node.target.accept(this, context);
      context.environment.debugJinja('visitFor: Targets = $targets');
      var iterable = node.iterable.accept(this, context);
      context.environment.debugJinja(
        'visitFor: Iterable = $iterable (type: ${iterable.runtimeType})',
      );

      // Define render function before null check so it can be called from Future callback
      String render(Object? iterable, [int depth = 0]) {
        try {
          context.environment.debugJinja(
            'visitFor.render: Processing iterable (depth: $depth)',
          );
          List<Object?> values;

          if (iterable is Map) {
            values = List<Object?>.of(iterable.entries);
            context.environment.debugJinja(
              'visitFor.render: Iterable is Map, converted to '
              '${values.length} entries',
            );
          } else {
            values = list(iterable);
            context.environment.debugJinja(
              'visitFor.render: Iterable converted to list with '
              '${values.length} items',
            );
          }

          if (values.isEmpty) {
            context.environment.debugJinja(
              'visitFor.render: Iterable is empty',
            );
            if (node.orElse case var orElse?) {
              context.environment.debugJinja(
                'visitFor.render: Rendering else block',
              );
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
          context.environment.debugJinja(
            'visitFor.render: Created loop context with '
            '${values.length} items',
          );

          int iteration = 0;
          for (var value in loop) {
            iteration++;
            context.environment.debugJinja(
              'visitFor.render: Iteration $iteration/${values.length}, '
              'value = $value',
            );
            var data = getDataForTargets(targets, value);
            var forContext = context.derived(data: data);
            forContext.set('loop', loop);

            try {
              node.body.accept(this, forContext);
            } on BreakException {
              context.environment.debugJinja(
                'visitFor.render: Break exception, exiting loop',
              );
              break;
            } on ContinueException {
              context.environment.debugJinja(
                'visitFor.render: Continue exception, '
                'skipping to next iteration',
              );
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
                callStack: captureCallStack(),
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
            callStack: captureCallStack(),
          );
        }
      }

      // If iterable is a Future, write it to the sink so AsyncRenderer can handle it
      if (iterable is Future) {
        context.environment.debugJinja(
          'visitFor: Iterable is Future, writing to sink for async handling',
        );
        context.write(iterable);
        return;
      }

      if (iterable == null) {
        // Extract variable name from node.iterable for async re-evaluation
        String? varNameToCheck;
        if (node.iterable is Name) {
          varNameToCheck = (node.iterable as Name).name;
          context.environment.debugJinja(
            'visitFor: Extracted variable name from Name: "$varNameToCheck"',
          );
        } else if (node.iterable is Attribute) {
          // For Attribute (e.g., menu_data.list_data), extract the base variable name (menu_data)
          final attr = node.iterable as Attribute;
          if (attr.value is Name) {
            varNameToCheck = (attr.value as Name).name;
            context.environment.debugJinja(
              'visitFor: Extracted base variable name from Attribute: '
              '"$varNameToCheck" (attribute: ${attr.attribute})',
            );
          } else {
            // If the value is not a Name, we can't extract a simple variable name
            context.environment.debugJinja(
              'visitFor: Attribute value is not a Name, '
              'cannot extract variable name',
            );
          }
        }

        // Check if we're in async context and should wait for Futures before throwing error
        if (varNameToCheck != null && context.sink is _AsyncCollectingSink) {
          final varName = varNameToCheck; // Store in final variable for null safety
          context.environment.debugJinja(
            'visitFor: Iterable is null for "$varName", '
            'checking for Futures before throwing error',
          );

          final sink = context.sink as _AsyncCollectingSink;
          // Capture current Futures count BEFORE creating checkFuture to avoid circular dependency
          // The checkFuture itself will be added to _futures, so we exclude it from waitForAllFutures()
          final currentFuturesCount = sink.futuresCount;
          // Wait for ALL Futures (not just assignment Futures) because run_data_source calls
          // in interpolations might update loader.globals
          final checkFuture = sink.waitForAllFutures(maxIndex: currentFuturesCount).then((_) {
            context.environment.debugJinja(
              'visitFor: All Futures complete, '
              're-evaluating iterable for "$varName"',
            );
            // Re-evaluate the iterable expression - this will now resolve to the updated value
            final reEvaluatedIterable = node.iterable.accept(this, context);
            context.environment.debugJinja(
              'visitFor: Re-evaluated iterable = $reEvaluatedIterable '
              '(type: ${reEvaluatedIterable.runtimeType})',
            );

            if (reEvaluatedIterable is Future) {
              // If it's still a Future, write it to sink and return
              context.environment.debugJinja(
                'visitFor: Re-evaluated iterable is still a Future, '
                'writing to sink',
              );
              context.write(reEvaluatedIterable);
              return;
            }

            if (reEvaluatedIterable == null) {
              // Still null after waiting - throw the error
              context.environment.debugJinja(
                'visitFor: Re-evaluated iterable is still null, '
                'throwing UndefinedError',
              );
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
            context.environment.debugJinja(
              'visitFor: Re-evaluated iterable is now available, '
              'proceeding with render',
            );
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
        callStack: captureCallStack(),
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

    var moduleContext = context.derived(withContext: node.withContext, sink: StringBuffer());
    template.body.accept(this, moduleContext);

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
            "The '${template.path}' does not export the requested name: '$name'",
          );
        }

        MacroFunction function = getMacroFunction(targetMacro, moduleContext);

        return function(positional, named);
      }

      context.set(alias ?? name, macro);
    }
  }

  @override
  void visitIf(If node, StringSinkRenderContext context) {
    context.environment.debugJinja('visitIf: Evaluating if condition');
    final testResult = node.test.accept(this, context);
    final testBool = boolean(testResult);
    context.environment.debugJinja(
      'visitIf: Test result = $testResult, boolean = $testBool',
    );
    if (testBool) {
      context.environment.debugJinja(
        'visitIf: Condition true, rendering body',
      );
      node.body.accept(this, context);
    } else if (node.orElse case var orElse?) {
      context.environment.debugJinja(
        'visitIf: Condition false, rendering else block',
      );
      orElse.accept(this, context);
    } else {
      context.environment.debugJinja(
        'visitIf: Condition false, no else block',
      );
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

    var moduleContext = context.derived(withContext: node.withContext, sink: StringBuffer());
    template.body.accept(this, moduleContext);

    for (var macro in template.body.macros) {
      namespace[macro.name] = getMacroFunction(macro, moduleContext);
    }

    context.set(node.target, namespace);
  }

  @override
  void visitInclude(Include node, StringSinkRenderContext context) {
    context.environment.debugJinja('visitInclude: Including template');
    var templateOrParth = node.template.accept(this, context);
    context.environment.debugJinja(
      'visitInclude: Template path/value = $templateOrParth '
      '(type: ${templateOrParth.runtimeType})',
    );

    Template? template;

    try {
      template = switch (templateOrParth) {
        String path => () {
            context.environment.debugJinja(
              'visitInclude: Loading template from path: $path',
            );
            return context.environment.getTemplate(path);
          }(),
        Template template => template,
        List<Object?> paths => () {
            context.environment.debugJinja(
              'visitInclude: Selecting template from ${paths.length} paths',
            );
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
      final Template includedTemplate = template;
      // Derive context for the included template, optionally without carrying over locals.
      if (node.withContext) {
        context = context.derived(
          template: includedTemplate.path ?? context.template,
        );
      } else {
        context = context.derived(
          template: includedTemplate.path ?? context.template,
          withContext: false,
        );
      }

      final templatePath = includedTemplate.path ?? context.template ?? '<unknown>';

      withRenderFrame<void>(
        templatePath: templatePath,
        line: node.line,
        description: includedTemplate.path != null ? 'include ${includedTemplate.path}' : 'include',
        body: () {
          includedTemplate.body.accept(this, context);
        },
      );
    }
  }

  @override
  void visitInterpolation(Interpolation node, StringSinkRenderContext context) {
    try {
      context.environment.debugJinja(
        'visitInterpolation: Evaluating expression',
      );
      var value = node.value.accept(this, context);
      context.environment.debugJinja(
        'visitInterpolation: Expression evaluated to: $value '
        '(type: ${value.runtimeType})',
      );
      var finalized = context.finalize(value);
      context.environment.debugJinja(
        'visitInterpolation: Finalized value: $finalized '
        '(type: ${finalized.runtimeType})',
      );

      if (finalized is Future) {
        context.environment.debugJinja(
          'visitInterpolation: Finalized value is Future, writing to sink',
        );
        context.write(
          finalized.then((value) {
            context.environment.debugJinja(
              'visitInterpolation: Future resolved to: $value',
            );
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
        context.environment.debugJinja(
          'visitInterpolation: Value is null/empty/null-string for '
          '"$varName", checking for Futures',
        );

        final sink = context.sink as _AsyncCollectingSink;
        // Capture current Futures count BEFORE creating checkFuture to avoid circular dependency
        // The checkFuture itself will be added to _futures, so we exclude it from waitForAllFutures()
        final currentFuturesCount = sink.futuresCount;
        // Write a Future that waits for ALL Futures (not just assignment Futures)
        // because run_data_source calls in interpolations might update loader.globals
        final checkFuture = sink.waitForAllFutures(maxIndex: currentFuturesCount).then((_) {
          context.environment.debugJinja(
            'visitInterpolation: All Futures complete, '
            're-evaluating expression for "$varName"',
          );
          // Re-evaluate the entire expression (node.value) - this will now resolve to the updated value
          // The context.resolve will now find the variable in loader.globals
          final reEvaluatedValue = node.value.accept(this, context);
          context.environment.debugJinja(
            'visitInterpolation: Re-evaluated expression = '
            '$reEvaluatedValue (type: ${reEvaluatedValue.runtimeType})',
          );
          final reFinalized = context.finalize(reEvaluatedValue);
          context.environment.debugJinja(
            'visitInterpolation: Re-finalized value = $reFinalized '
            '(type: ${reFinalized.runtimeType})',
          );

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
        context.environment.debugJinja(
          'visitInterpolation: Writing SafeString: ${finalized.toString()}',
        );
        context.write(finalized.toString());
        return;
      }

      final output = context.autoEscape ? escape(finalized.toString()) : finalized;
      context.environment.debugJinja(
        'visitInterpolation: Writing output: $output '
        '(autoEscape: ${context.autoEscape})',
      );
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
        callStack: captureCallStack(),
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
        callStack: captureCallStack(),
      );
    }
  }

  @override
  void visitTemplateNode(TemplateNode node, StringSinkRenderContext context) {
    try {
      context.environment.debugJinja(
        'visitTemplateNode: Starting template node rendering',
      );
      context.environment.debugJinja(
        'visitTemplateNode: Template has ${node.blocks.length} blocks',
      );
      // TODO(renderer): add `TemplateReference`
      var self = Namespace();

      for (var block in node.blocks) {
        var blockName = block.name;
        context.environment.debugJinja(
          'visitTemplateNode: Processing block "$blockName"',
        );

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
      context.environment.debugJinja(
        'visitTemplateNode: Rendering template body',
      );
      node.body.accept(this, context);
      context.environment.debugJinja(
        'visitTemplateNode: Template body rendered',
      );
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
            result = Function.apply(
              npgettext,
              [node.context, bodyText, pluralText ?? bodyText, countValue],
            );
          } else {
            // Fallback to ngettext if context not supported directly or npgettext not found,
            // but we really should use context if provided.
            // If neither exists, we just output raw strings.
            var ngettext = context.resolve('ngettext');
            if (ngettext is Function) {
              result = Function.apply(
                ngettext,
                [bodyText, pluralText ?? bodyText, countValue],
              );
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
            result = Function.apply(
              ngettext,
              [bodyText, pluralText ?? bodyText, countValue],
            );
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

      if (value is String && start is int && (stop == null || stop is int)) {
        final chars = value.split('');

        // Python/Jinja semantics:
        // - omitted start => 0
        // - omitted stop => len
        // - negative indices wrap from the end
        // - out-of-range indices clamp (no RangeError)
        final len = chars.length;

        int normalizeIndex(int i) {
          var idx = i;
          if (idx < 0) idx = len + idx;
          if (idx < 0) idx = 0;
          if (idx > len) idx = len;
          return idx;
        }

        final startIdx = normalizeIndex(start);
        final stopIdx = stop == null ? len : normalizeIndex(stop as int);

        final effectiveStop = stopIdx < startIdx ? startIdx : stopIdx;
        return chars.sublist(startIdx, effectiveStop).join();
      }

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
        callStack: captureCallStack(),
      );
    }
  }
}

/// Async version of the renderer used for normal (non-debug) async rendering.
///
/// This closely follows the structure of `AsyncDebugRenderer` but operates on
/// `AsyncRenderContext` and does not include any debugging or breakpoint logic.
class AsyncStringSinkRenderer extends Visitor<AsyncRenderContext, Future<Object?>> {
  AsyncStringSinkRenderer();

  final StringSinkRenderer _baseRenderer = const StringSinkRenderer();

  StringSinkRenderContext _toSyncContext(AsyncRenderContext context) {
    return StringSinkRenderContext(
      context.environment,
      context.sink,
      template: context.template,
      blocks: context.blocks,
      parent: context.parent,
      data: context.context,
      autoEscape: context.autoEscape,
    );
  }

  @override
  Future<List<Object?>> visitArray(
    Array node,
    AsyncRenderContext context,
  ) async {
    var result = <Object?>[];
    for (var value in node.values) {
      result.add(await value.accept(this, context));
    }
    return result;
  }

  @override
  Future<Object?> visitAttribute(
    Attribute node,
    AsyncRenderContext context,
  ) async {
    var value = await node.value.accept(this, context);
    return context.attribute(node.attribute, value, node);
  }

  @override
  Future<Object?> visitCall(Call node, AsyncRenderContext context) async {
    var function = await node.value.accept(this, context);
    var params = await node.calling.accept(this, context) as Parameters;
    var (positional, named) = params;
    return context.call(function, node, positional, named);
  }

  @override
  Future<Parameters> visitCalling(
    Calling node,
    AsyncRenderContext context,
  ) async {
    var positional = <Object?>[];
    for (var argument in node.arguments) {
      positional.add(await argument.accept(this, context));
    }

    var named = <Symbol, Object?>{};
    for (var (:key, :value) in node.keywords) {
      named[Symbol(key)] = await value.accept(this, context);
    }

    return (positional, named);
  }

  @override
  Future<bool> visitCompare(Compare node, AsyncRenderContext context) async {
    final syncContext = _toSyncContext(context);
    return _baseRenderer.visitCompare(node, syncContext);
  }

  @override
  Future<Object?> visitConcat(Concat node, AsyncRenderContext context) async {
    var buffer = StringBuffer();
    for (var value in node.values) {
      buffer.write(await value.accept(this, context));
    }
    return buffer.toString();
  }

  @override
  Future<Object?> visitCondition(
    Condition node,
    AsyncRenderContext context,
  ) async {
    var testResult = await node.test.accept(this, context);
    if (boolean(testResult)) {
      return await node.trueValue.accept(this, context);
    }
    return node.falseValue != null ? await node.falseValue!.accept(this, context) : null;
  }

  @override
  Future<Object?> visitConstant(
    Constant node,
    AsyncRenderContext context,
  ) async {
    return node.value;
  }

  @override
  Future<Map<Object?, Object?>> visitDict(
    Dict node,
    AsyncRenderContext context,
  ) async {
    var result = <Object?, Object?>{};
    for (var (:key, :value) in node.pairs) {
      var k = await key.accept(this, context);
      var v = await value.accept(this, context);
      result[k] = v;
    }
    return result;
  }

  @override
  Future<Object?> visitFilter(Filter node, AsyncRenderContext context) async {
    var params = await node.calling.accept(this, context) as Parameters;
    var (positional, named) = params;
    return context.filter(node.name, positional, named);
  }

  @override
  Future<Object?> visitItem(Item node, AsyncRenderContext context) async {
    var key = await node.key.accept(this, context);
    var value = await node.value.accept(this, context);
    return context.item(key, value, node);
  }

  @override
  Future<Object?> visitLogical(Logical node, AsyncRenderContext context) async {
    var left = await node.left.accept(this, context);
    return switch (node.operator) {
      LogicalOperator.and => boolean(left) ? await node.right.accept(this, context) : left,
      LogicalOperator.or => boolean(left) ? left : await node.right.accept(this, context),
    };
  }

  @override
  Future<Object?> visitName(Name node, AsyncRenderContext context) async {
    return switch (node.context) {
      AssignContext.load => context.resolve(node.name),
      _ => node.name,
    };
  }

  @override
  Future<NamespaceValue> visitNamespaceRef(
    NamespaceRef node,
    AsyncRenderContext context,
  ) async {
    return NamespaceValue(node.name, node.attribute);
  }

  @override
  Future<Object?> visitScalar(Scalar node, AsyncRenderContext context) async {
    final syncContext = _toSyncContext(context);
    return _baseRenderer.visitScalar(node, syncContext);
  }

  @override
  Future<Object?> visitTest(Test node, AsyncRenderContext context) async {
    var params = await node.calling.accept(this, context) as Parameters;
    var (positional, named) = params;
    return context.test(node.name, positional, named);
  }

  @override
  Future<List<Object?>> visitTuple(
    Tuple node,
    AsyncRenderContext context,
  ) async {
    var result = <Object?>[];
    for (var value in node.values) {
      result.add(await value.accept(this, context));
    }
    return result;
  }

  @override
  Future<Object?> visitUnary(Unary node, AsyncRenderContext context) async {
    final syncContext = _toSyncContext(context);
    return _baseRenderer.visitUnary(node, syncContext);
  }

  @override
  Future<void> visitAssign(Assign node, AsyncRenderContext context) async {
    // Evaluate the assignment target and value in the async context.
    var target = await node.target.accept(this, context);
    var value = await node.value.accept(this, context);

    // If the evaluated value is still a Future (for example, because a global like
    // `jinja_action` returns a Future), await it here so that subsequent reads of
    // the assigned variable see the resolved result instead of a Future.
    if (value is Future) {
      context.environment.debugJinja(
        'AsyncRenderer.visitAssign: value is Future (${value.runtimeType}), awaiting before assign',
      );
      try {
        value = await value;
        context.environment.debugJinja(
          'AsyncRenderer.visitAssign: Future resolved to: $value '
          'for target="$target"',
        );
      } catch (e, stackTrace) {
        throw TemplateErrorWrapper(
          e,
          message: 'Error awaiting async assignment for target "$target": ${e.toString()}',
          stackTrace: stackTrace,
          operation: 'Awaiting async assignment',
          suggestions: const [
            'Check if the async function used on the right-hand side completes successfully',
            'Verify it returns the expected JSON/map structure',
          ],
          templatePath: context.template,
          callStack: captureCallStack(),
        );
      }
    }

    context.assignTargets(target, value);
  }

  @override
  Future<void> visitAssignBlock(
    AssignBlock node,
    AsyncRenderContext context,
  ) async {
    final syncContext = _toSyncContext(context);
    _baseRenderer.visitAssignBlock(node, syncContext);
  }

  @override
  Future<void> visitAutoEscape(
    AutoEscape node,
    AsyncRenderContext context,
  ) async {
    final syncContext = _toSyncContext(context);
    _baseRenderer.visitAutoEscape(node, syncContext);
  }

  @override
  Future<void> visitBlock(Block node, AsyncRenderContext context) async {
    final syncContext = _toSyncContext(context);
    _baseRenderer.visitBlock(node, syncContext);
  }

  @override
  Future<void> visitBreak(Break node, AsyncRenderContext context) async {
    final syncContext = _toSyncContext(context);
    _baseRenderer.visitBreak(node, syncContext);
  }

  @override
  Future<void> visitCallBlock(
    CallBlock node,
    AsyncRenderContext context,
  ) async {
    final syncContext = _toSyncContext(context);
    _baseRenderer.visitCallBlock(node, syncContext);
  }

  @override
  Future<void> visitContinue(Continue node, AsyncRenderContext context) async {
    final syncContext = _toSyncContext(context);
    _baseRenderer.visitContinue(node, syncContext);
  }

  @override
  Future<void> visitData(Data node, AsyncRenderContext context) async {
    context.write(node.data);
  }

  @override
  Future<void> visitDebug(Debug node, AsyncRenderContext context) async {
    final syncContext = _toSyncContext(context);
    _baseRenderer.visitDebug(node, syncContext);
  }

  @override
  Future<void> visitDo(Do node, AsyncRenderContext context) async {
    await node.value.accept(this, context);
  }

  @override
  Future<void> visitExtends(Extends node, AsyncRenderContext context) async {
    final syncContext = _toSyncContext(context);
    _baseRenderer.visitExtends(node, syncContext);
  }

  @override
  Future<void> visitFilterBlock(
    FilterBlock node,
    AsyncRenderContext context,
  ) async {
    final syncContext = _toSyncContext(context);
    _baseRenderer.visitFilterBlock(node, syncContext);
  }

  @override
  Future<void> visitFor(For node, AsyncRenderContext context) async {
    var targets = await node.target.accept(this, context);
    var iterable = await node.iterable.accept(this, context);

    Future<void> render(Object? iterable, [int depth = 0]) async {
      List<Object?> values;

      if (iterable is Map) {
        values = List<Object?>.of(iterable.entries);
      } else {
        values = list(iterable);
      }

      if (values.isEmpty) {
        if (node.orElse != null) {
          await node.orElse!.accept(this, context);
        }
        return;
      }

      if (node.test case var test?) {
        var filtered = <Object?>[];
        for (var value in values) {
          var data = _baseRenderer.getDataForTargets(targets, value);
          var newContext = context.derived(data: data);
          var result = await test.accept(this, newContext);
          if (boolean(result)) {
            filtered.add(value);
          }
        }
        values = filtered;

        if (values.isEmpty) {
          if (node.orElse != null) {
            await node.orElse!.accept(this, context);
          }
          return;
        }
      }

      // LoopContext provides loop.index, loop.first, loop.last, etc.
      // Recursive rendering via loop.call() is not fully async-aware here,
      // but basic loop metadata is preserved.
      String recurse(Object? data, [int depth = 0]) {
        // Recursive loops are not supported in async mode yet.
        // Return empty string to avoid crashes if called.
        return '';
      }

      var loop = LoopContext(values, depth, recurse);

      for (var value in loop) {
        var data = _baseRenderer.getDataForTargets(targets, value);
        var forContext = context.derived(data: data);
        forContext.set('loop', loop);

        try {
          await node.body.accept(this, forContext);
        } on BreakException {
          break;
        } on ContinueException {
          continue;
        }
      }
    }

    await render(iterable);
  }

  @override
  Future<void> visitFromImport(
    FromImport node,
    AsyncRenderContext context,
  ) async {
    var templateOrPath = await node.template.accept(this, context);

    var template = switch (templateOrPath) {
      String path => context.environment.getTemplate(path),
      Template template => template,
      Object? value => throw ArgumentError.value(value, 'template'),
    };

    var asyncModuleContext = context.derived(withContext: node.withContext, sink: _AsyncCollectingSink(StringBuffer(), context.environment));
    await template.body.accept(this, asyncModuleContext);
    var syncModuleContext = _toSyncContext(asyncModuleContext);

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
            "The '${template.path}' does not export the requested name: '$name'",
          );
        }

        MacroFunction function = _baseRenderer.getMacroFunction(targetMacro, syncModuleContext);

        return function(positional, named);
      }

      context.set(alias ?? name, macro);
    }
  }

  @override
  Future<void> visitIf(If node, AsyncRenderContext context) async {
    var testResult = await node.test.accept(this, context);
    if (boolean(testResult)) {
      await node.body.accept(this, context);
    } else if (node.orElse != null) {
      await node.orElse!.accept(this, context);
    }
  }

  @override
  Future<void> visitImport(Import node, AsyncRenderContext context) async {
    var templateOrPath = await node.template.accept(this, context);

    var template = switch (templateOrPath) {
      String path => context.environment.getTemplate(path),
      Template template => template,
      Object? value => throw ArgumentError.value(value, 'template'),
    };

    var namespace = Namespace();

    var asyncModuleContext = context.derived(withContext: node.withContext, sink: _AsyncCollectingSink(StringBuffer(), context.environment));
    await template.body.accept(this, asyncModuleContext);
    var syncModuleContext = _toSyncContext(asyncModuleContext);

    for (var macro in template.body.macros) {
      namespace[macro.name] = _baseRenderer.getMacroFunction(macro, syncModuleContext);
    }

    context.set(node.target, namespace);
  }

  @override
  Future<void> visitInclude(Include node, AsyncRenderContext context) async {
    final syncContext = _toSyncContext(context);
    _baseRenderer.visitInclude(node, syncContext);
  }

  @override
  Future<void> visitInterpolation(
    Interpolation node,
    AsyncRenderContext context,
  ) async {
    var value = await node.value.accept(this, context);
    var finalized = context.finalize(value);

    if (finalized is SafeString) {
      context.write(finalized.toString());
    } else if (context.autoEscape) {
      context.write(escape(finalized?.toString() ?? ''));
    } else {
      context.write(finalized);
    }
  }

  @override
  Future<void> visitMacro(Macro node, AsyncRenderContext context) async {
    // Build macro function using the existing sync implementation, but
    // register it on the async context so that async rendering can call it.
    // We use an _AsyncCollectingSink so that macros can still work with
    // async values inside their bodies and return a Future when needed.
    final syncContext = StringSinkRenderContext(
      context.environment,
      _AsyncCollectingSink(StringBuffer(), context.environment),
      template: context.template,
      blocks: context.blocks,
      parent: context.parent,
      data: context.context,
      autoEscape: context.autoEscape,
    );
    final function = _baseRenderer.getMacroFunction(node, syncContext);
    // Register macro on both the async context (for normal calls) and the
    // sync context used by the underlying macro implementation so that
    // recursive macros can resolve their own name.
    syncContext.set(node.name, function);
    context.set(node.name, function);
  }

  @override
  Future<void> visitOutput(Output node, AsyncRenderContext context) async {
    for (var child in node.nodes) {
      await child.accept(this, context);
    }
  }

  @override
  Future<void> visitTemplateNode(
    TemplateNode node,
    AsyncRenderContext context,
  ) async {
    // Mirror the synchronous template rendering behavior so that
    // `self` and block callbacks behave the same way in async mode.
    // This is essentially an async-friendly version of
    // StringSinkRenderer.visitTemplateNode.

    // TODO(renderer): add `TemplateReference`
    var self = Namespace();

    for (var block in node.blocks) {
      var blockName = block.name;

      // Render function for `self.blockName()`
      String render() {
        // Use a synchronous render context for block execution so that
        // the underlying StringSinkRenderer sees the expected context type.
        final syncContext = _toSyncContext(context);
        var blocks = syncContext.blocks[blockName];

        if (blocks == null) {
          throw UndefinedError(
            "Block '$blockName' is not defined.",
            operationValue: "Rendering block '$blockName'",
            suggestionsValue: <String>[
              'Check if the block is defined in the template',
              'Verify the block name matches between templates',
            ],
            templatePathValue: context.template,
          );
        }

        // Call the current block implementation
        blocks[0](syncContext);
        return '';
      }

      self[blockName] = render;

      var blocks = context.blocks[blockName] ??= <ContextCallback>[];

      if (block.required) {
        Never callback(Context ctx) {
          throw TemplateRuntimeError(
            "Required block '${block.name}' not found.",
            operationValue: "Rendering required block '${block.name}'",
            suggestionsValue: <String>[
              'Add a block implementation in the child template',
              'Ensure the block name matches exactly',
            ],
            templatePathValue: ctx.template,
          );
        }

        blocks.add(callback);
      } else {
        var parentIndex = blocks.length + 1;

        void callback(Context ctx) {
          var current = ctx.get('super');

          String parent() {
            var parentBlocks = ctx.blocks[blockName]!;

            if (parentIndex >= parentBlocks.length) {
              throw TemplateRuntimeError(
                "Super block '$blockName' not found.",
                operationValue: "Calling super block '$blockName'",
                suggestionsValue: <String>[
                  'Check if the parent template defines this block',
                  'Verify the block inheritance chain is correct',
                ],
                templatePathValue: ctx.template,
              );
            }

            parentBlocks[parentIndex](ctx);
            return '';
          }

          ctx.set('super', parent);
          block.body.accept(_baseRenderer, ctx);
          ctx.set('super', current);
        }

        blocks.add(callback);
      }
    }

    context.set('self', self);
    await node.body.accept(this, context);
  }

  @override
  Future<void> visitTrans(Trans node, AsyncRenderContext context) async {
    final syncContext = _toSyncContext(context);
    _baseRenderer.visitTrans(node, syncContext);
  }

  @override
  Future<void> visitTryCatch(TryCatch node, AsyncRenderContext context) async {
    try {
      await node.body.accept(this, context);
    } catch (error) {
      if (node.exception != null) {
        var target = await node.exception!.accept(this, context);
        context.assignTargets(target, error);
      }
      await node.catchBody.accept(this, context);
    }
  }

  @override
  Future<void> visitWith(With node, AsyncRenderContext context) async {
    var targets = <Object?>[];
    for (var target in node.targets) {
      targets.add(await target.accept(this, context));
    }

    var values = <Object?>[];
    for (var value in node.values) {
      values.add(await value.accept(this, context));
    }

    var data = _baseRenderer.getDataForTargets(targets, values);
    var newContext = context.derived(data: data);
    await node.body.accept(this, newContext);
  }

  @override
  Future<Object?> visitSlice(Slice node, AsyncRenderContext context) async {
    final syncContext = _toSyncContext(context);
    return _baseRenderer.visitSlice(node, syncContext);
  }
}

/// Custom sink that collects Futures written during rendering.
class _AsyncCollectingSink implements StringSink {
  final StringSink _delegate;
  final List<Future<Object?>> _futures = [];
  // Track if Future is from assignment (shouldn't output)
  final List<bool> _isAssignmentFuture = [];
  final StringBuffer _buffer = StringBuffer();

  final Environment _environment;

  _AsyncCollectingSink(this._delegate, this._environment);

  /// Get the current number of Futures being tracked
  int get futuresCount => _futures.length;

  @override
  void write(Object? obj) {
    if (obj is Future) {
      // Store the Future and write a placeholder
      _environment.debugJinja(
        '_AsyncCollectingSink.write: Received Future '
        '(index ${_futures.length}), writing placeholder',
      );
      _futures.add(obj);
      _isAssignmentFuture.add(false); // Default: not an assignment
      _buffer.write('__FUTURE_${_futures.length - 1}__');
    } else {
      _environment.debugJinja(
        '_AsyncCollectingSink.write: Writing value: $obj '
        '(type: ${obj.runtimeType})',
      );
      _buffer.write(obj);
    }
  }

  /// Write a Future from an assignment - this shouldn't output anything, just await it
  void writeAssignmentFuture(Future<Object?> future) {
    _environment.debugJinja(
      '_AsyncCollectingSink.writeAssignmentFuture: Tracking assignment Future '
      '(index ${_futures.length})',
    );
    _futures.add(future);
    _isAssignmentFuture.add(true); // Mark as assignment Future
    // Don't write anything to buffer - assignments shouldn't output
  }

  /// Returns a Future that resolves when all assignment Futures are complete
  Future<void> waitForAssignmentFutures() async {
    final assignmentCount = _isAssignmentFuture.where((isAssignment) => isAssignment).length;
    _environment.debugJinja(
      '_AsyncCollectingSink.waitForAssignmentFutures: Waiting for '
      '$assignmentCount assignment Futures',
    );
    for (int i = 0; i < _futures.length; i++) {
      if (_isAssignmentFuture[i]) {
        _environment.debugJinja(
          '_AsyncCollectingSink.waitForAssignmentFutures: '
          'Awaiting assignment Future $i',
        );
        await _futures[i];
        _environment.debugJinja(
          '_AsyncCollectingSink.waitForAssignmentFutures: '
          'Assignment Future $i completed',
        );
      }
    }
    _environment.debugJinja(
      '_AsyncCollectingSink.waitForAssignmentFutures: '
      'All assignment Futures completed',
    );
  }

  /// Returns a Future that resolves when ALL Futures (assignment and non-assignment) are complete
  /// [maxIndex] if provided, only awaits Futures up to this index (exclusive).
  /// This prevents circular dependencies when waitForAllFutures() itself creates Futures.
  Future<void> waitForAllFutures({int? maxIndex}) async {
    // If maxIndex is provided, use it; otherwise await all current Futures
    // This allows callers to exclude Futures added after waitForAllFutures() was called
    final futuresToAwait = maxIndex ?? _futures.length;
    _environment.debugJinja(
      '_AsyncCollectingSink.waitForAllFutures: Waiting for '
      '$futuresToAwait Futures (current count: ${_futures.length}, '
      'maxIndex: $maxIndex)',
    );
    for (int i = 0; i < futuresToAwait; i++) {
      _environment.debugJinja(
        '_AsyncCollectingSink.waitForAllFutures: Awaiting Future '
        '$i/$futuresToAwait (isAssignment: ${_isAssignmentFuture[i]})',
      );
      await _futures[i];
      _environment.debugJinja(
        '_AsyncCollectingSink.waitForAllFutures: Future $i completed',
      );
    }
    _environment.debugJinja(
      '_AsyncCollectingSink.waitForAllFutures: All Futures completed',
    );
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
    _environment.debugJinja(
      '_AsyncCollectingSink.getResolvedContent: Starting, '
      '${_futures.length} Futures to await',
    );
    _environment.debugJinja(
      '_AsyncCollectingSink.getResolvedContent: Using delegate $_delegate',
    );
    _environment.debugJinja(
      '_AsyncCollectingSink.getResolvedContent: Buffer content length: '
      '${content.length}',
    );
    _environment.debugJinja(
      '_AsyncCollectingSink.getResolvedContent: Buffer preview: '
      '${content.length > 100 ? "${content.substring(0, 100)}..." : content}',
    );

    // Await all collected Futures
    List<Object?> resolvedValues = [];
    for (int i = 0; i < _futures.length; i++) {
      try {
        _environment.debugJinja(
          '_AsyncCollectingSink.getResolvedContent: Awaiting Future '
          '$i/${_futures.length} (isAssignment: ${_isAssignmentFuture[i]})',
        );
        resolvedValues.add(await _futures[i]);
        _environment.debugJinja(
          '_AsyncCollectingSink.getResolvedContent: Future $i resolved to: '
          '${resolvedValues[i]} (type: ${resolvedValues[i].runtimeType})',
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
          callStack: captureCallStack(),
        );
      }
    }

    // Replace placeholders with resolved values (skip assignment Futures)
    _environment.debugJinja(
      '_AsyncCollectingSink.getResolvedContent: Replacing placeholders '
      'in content',
    );
    for (int i = 0; i < resolvedValues.length; i++) {
      if (!_isAssignmentFuture[i]) {
        // Only replace placeholders for non-assignment Futures
        final placeholder = '__FUTURE_${i}__';
        final replacement = resolvedValues[i]?.toString() ?? 'null';
        _environment.debugJinja(
          '_AsyncCollectingSink.getResolvedContent: Replacing $placeholder '
          'with "$replacement"',
        );
        content = content.replaceAll(placeholder, replacement);
      } else {
        _environment.debugJinja(
          '_AsyncCollectingSink.getResolvedContent: Skipping placeholder '
          'replacement for assignment Future $i',
        );
      }
      // Assignment Futures don't have placeholders, so nothing to replace
    }

    _environment.debugJinja(
      '_AsyncCollectingSink.getResolvedContent: Final content length: '
      '${content.length}',
    );
    return content;
  }
}

/// Async renderer that supports async function calls and global resolution.
///
/// This renderer properly awaits Future values returned from function calls
/// during template rendering.
base class AsyncRenderer {
  AsyncRenderer();

  final StringSinkRenderer _syncRenderer = const StringSinkRenderer();
  final AsyncStringSinkRenderer _asyncRenderer = AsyncStringSinkRenderer();

  /// Renders a template node asynchronously, resolving all Future values in globals and during rendering.
  Future<void> render(TemplateNode node, AsyncRenderContext context) async {
    try {
      context.environment.debugJinja('AsyncRenderer.render: Starting async render');
      // First, resolve all async values in parent (globals)
      var resolvedGlobals = <String, Object?>{};
      context.environment.debugJinja(
        'AsyncRenderer.render: Resolving ${context.parent.length} parent globals',
      );
      for (var entry in context.parent.entries) {
        if (entry.value is Future) {
          try {
            context.environment.debugJinja(
              'AsyncRenderer.render: Resolving async global "${entry.key}"',
            );
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
              callStack: captureCallStack(),
            );
          }
        } else {
          resolvedGlobals[entry.key] = entry.value;
        }
      }

      // Also resolve async values in context data
      var resolvedData = <String, Object?>{};
      context.environment.debugJinja(
        'AsyncRenderer.render: Resolving ${context.context.length} context variables',
      );
      for (var entry in context.context.entries) {
        if (entry.value is Future) {
          try {
            context.environment.debugJinja(
              'AsyncRenderer.render: Resolving async context variable "${entry.key}"',
            );
            resolvedData[entry.key] = await (entry.value as Future);
            context.environment.debugJinja(
              'AsyncRenderer.render: Context variable "${entry.key}" '
              'resolved to: ${resolvedData[entry.key]}',
            );
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
              callStack: captureCallStack(),
            );
          }
        } else {
          resolvedData[entry.key] = entry.value;
          context.environment.debugJinja(
            'AsyncRenderer.render: Context variable "${entry.key}" '
            'is synchronous: ${entry.value}',
          );
        }
      }

      // If the template uses inheritance/extends, fall back to the original
      // sync renderer + collecting sink pipeline to preserve complex block and
      // super() semantics.
      final hasExtends = node.findAll<Extends>().isNotEmpty;
      if (hasExtends) {
        context.environment.debugJinja(
          'AsyncRenderer.render: Template uses extends, falling back to '
          'sync renderer with collecting sink',
        );

        // Create a custom sink that collects Futures
        final collectingSink = _AsyncCollectingSink(
          context.sink,
          context.environment,
        );

        // Create a sync context with the collecting sink
        final syncContext = StringSinkRenderContext(
          context.environment,
          collectingSink,
          template: context.template,
          blocks: context.blocks,
          parent: resolvedGlobals,
          data: resolvedData,
        );

        // Use the base synchronous renderer
        _syncRenderer.visitTemplateNode(node, syncContext);

        // Resolve all collected Futures and write final content
        final resolvedContent = await collectingSink.getResolvedContent();
        context.sink.write(resolvedContent);
        context.environment.debugJinja(
          'AsyncRenderer.render: Render complete (extends fallback)',
        );
      } else {
        // Create an async render context that will be used by the async renderer
        context.environment.debugJinja(
          'AsyncRenderer.render: Creating async context with '
          '${resolvedGlobals.length} globals, ${resolvedData.length} context vars',
        );
        var asyncContext = AsyncRenderContext(
          context.environment,
          context.sink,
          template: context.template,
          blocks: context.blocks,
          parent: resolvedGlobals,
          data: resolvedData,
        );

        // Use the async renderer
        context.environment.debugJinja(
          'AsyncRenderer.render: Starting async template rendering',
        );
        context.environment.debugJinja(
          'AsyncRenderer.render: Delegating to AsyncStringSinkRenderer',
        );
        await node.accept(_asyncRenderer, asyncContext);
        context.environment.debugJinja('AsyncRenderer.render: Render complete');
      }
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
