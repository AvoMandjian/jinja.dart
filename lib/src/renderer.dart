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
    super.blocks,
    super.parent,
    super.data,
    bool? autoEscape,
  }) : autoEscape = autoEscape ?? environment.autoEscape;

  final bool autoEscape;

  void assignTargets(Object? target, Object? current) {
    if (target is String) {
      set(target, current);
    } else if (target is List<String>) {
      var values = list(current);

      if (values.length < target.length) {
        throw StateError('Not enough values to unpack.');
      }

      if (values.length > target.length) {
        throw StateError('Too many values to unpack.');
      }

      for (var i = 0; i < target.length; i++) {
        set(target[i], values[i]);
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
    if (targets is String) {
      return <String, Object?>{targets: current};
    }

    if (targets is List<Object?>) {
      var names = targets.cast<String>();
      var values = list(current);

      if (values.length < names.length) {
        throw StateError('Not enough values to unpack (expected ${names.length}, '
            'got ${values.length}).');
      }

      if (values.length > names.length) {
        throw StateError(
          'Too many values to unpack (expected ${names.length}).',
        );
      }

      return <String, Object?>{
        for (var i = 0; i < names.length; i++) names[i]: values[i],
      };
    }

    // TODO(renderer): add error message
    throw ArgumentError.value(targets, 'targets');
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
      var length = node.positional.length;

      try {
        for (; index < length; index += 1) {
          var key = node.positional[index].accept(this, context) as String;
          derived.set(key, positional[index]);
        }
        if (node.varargs) {
          derived.set('varargs', positional.sublist(index));
        } else if (index < positional.length) {
          throw TemplateRuntimeError('''Error at macro ${node.name},
            expected arguments count: $index
            given arguments count: ${positional.length}
            given arguments: ${positional.toString()},
            ''');
        }
      } catch (e) {
        throw TemplateRuntimeError('''Error at macro ${node.name},
            expected arguments count: $length
            given arguments count: ${positional.length}
            given arguments: ${positional.toString()},
            error: ${e.toString()}
            ''');
      }

      var remaining = named.keys.toSet();

      for (var (argument, defaultValue) in node.named) {
        var key = argument.accept(this, context) as String;

        // Try to remove the key, handling both String and Symbol keys
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
    var value = node.value.accept(this, context);
    return context.attribute(node.attribute, value, node);
  }

  @override
  Object? visitCall(Call node, StringSinkRenderContext context) {
    var function = node.value.accept(this, context);
    var (positional, named) = node.calling.accept(this, context) as Parameters;
    return context.call(function, node, positional, named);
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
    var buffer = StringBuffer();

    for (var value in node.values) {
      buffer.write(value.accept(this, context));
    }

    return buffer.toString();
  }

  @override
  Object? visitCondition(Condition node, StringSinkRenderContext context) {
    if (boolean(node.test.accept(this, context))) {
      return node.trueValue.accept(this, context);
    }

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
    var (positional, named) = node.calling.accept(this, context) as Parameters;
    // Return the Future without awaiting - the AsyncRenderer will handle it
    return context.filter(node.name, positional, named);
  }

  @override
  Object? visitItem(Item node, StringSinkRenderContext context) {
    var key = node.key.accept(this, context);
    var value = node.value.accept(this, context);
    return context.item(key, value, node);
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
    return switch (node.context) {
      AssignContext.load => context.resolve(node.name),
      _ => node.name,
    };
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
    context.blocks[node.name]![0](context);
  }

  @override
  void visitBreak(Break node, StringSinkRenderContext context) {
    throw BreakException();
  }

  @override
  void visitCallBlock(CallBlock node, StringSinkRenderContext context) {
    var function = node.call.value.accept(this, context) as MacroFunction;
    var (arguments, _) = node.call.calling.accept(this, context) as Parameters;
    var [positional as List, named as Map] = arguments;
    named['caller'] = getMacroFunction(node, context);
    var result = function(positional, named);
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
    var templateOrParth = node.template.accept(this, context);

    var template = switch (templateOrParth) {
      String path => context.environment.getTemplate(path),
      Template template => template,
      Object? value => throw ArgumentError.value(value, 'template'),
    };

    template.body.accept(this, context);
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
    var targets = node.target.accept(this, context);
    var iterable = node.iterable.accept(this, context);

    // If iterable is a Future, write it to the sink so AsyncRenderer can handle it
    if (iterable is Future) {
      context.write(iterable);
      return;
    }

    if (iterable == null) {
      if (node.iterable is Name) {
        throw ArgumentError(
          'Trying to access an undefined list: "${(node.iterable as Name).name}" from the jinja data, in a for loop: it may be {% for $targets in ${(node.iterable as Name).name} %} in one of the jinja script: (${context.blocks.keys.toList().join(',')})',
        );
      } else if (node.iterable is Attribute) {
        throw ArgumentError(
          'Trying to access an undefined list: "${(node.iterable as Attribute).attribute}" from the jinja data, in a for loop: it may be {% for $targets in ${(node.iterable as Attribute).attribute} %} in one of the jinja script: (${context.blocks.keys.toList().join(',')})',
        );
      }
    }

    String render(Object? iterable, [int depth = 0]) {
      List<Object?> values;

      if (iterable is Map) {
        values = List<Object?>.of(iterable.entries);
      } else {
        values = list(iterable);
      }

      if (values.isEmpty) {
        if (node.orElse case var orElse?) {
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

      for (var value in loop) {
        var data = getDataForTargets(targets, value);
        var forContext = context.derived(data: data);
        forContext.set('loop', loop);

        try {
          node.body.accept(this, forContext);
        } on BreakException {
          break;
        } on ContinueException {
          continue;
        }
      }

      // Empty string prevents calling `finalize` on `null`.
      return '';
    }

    render(iterable);
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
    if (boolean(node.test.accept(this, context))) {
      node.body.accept(this, context);
    } else if (node.orElse case var orElse?) {
      orElse.accept(this, context);
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
    var templateOrParth = node.template.accept(this, context);

    Template? template;

    try {
      template = switch (templateOrParth) {
        String path => context.environment.getTemplate(path),
        Template template => template,
        List<Object?> paths => context.environment.selectTemplate(paths),
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
    var value = node.value.accept(this, context);
    var finalized = context.finalize(value);

    if (finalized is Future) {
      context.write(
        finalized.then((value) {
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

    if (finalized is SafeString) {
      context.write(finalized.toString());
      return;
    }

    if (context.autoEscape) {
      context.write(escape(finalized.toString()));
    } else {
      context.write(finalized);
    }
  }

  @override
  void visitMacro(Macro node, StringSinkRenderContext context) {
    var function = getMacroFunction(node, context);
    context.set(node.name, function);
  }

  @override
  void visitOutput(Output node, StringSinkRenderContext context) {
    for (var node in node.nodes) {
      node.accept(this, context);
    }
  }

  @override
  void visitTemplateNode(TemplateNode node, StringSinkRenderContext context) {
    // TODO(renderer): add `TemplateReference`
    var self = Namespace();

    for (var block in node.blocks) {
      var blockName = block.name;

      // TODO(compiler): switch to `ContextCallback`
      String render() {
        var blocks = context.blocks[blockName];

        if (blocks == null) {
          throw UndefinedError("Block '$blockName' is not defined.");
        }

        // TODO(renderer): check if empty
        blocks[0](context);
        return '';
      }

      self[blockName] = render;

      var blocks = context.blocks[blockName] ??= <ContextCallback>[];

      if (block.required) {
        Never callback(Context context) {
          throw TemplateRuntimeError(
            "Required block '${block.name}' not found.",
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
              throw TemplateRuntimeError("Super block '$blockName' not found.");
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
    node.body.accept(this, context);
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
    var value = node.value.accept(this, context);
    var start = node.start?.accept(this, context) ?? 0;
    var stop = node.stop?.accept(this, context);

    if (value is List && start is int && stop is int?) {
      return value.sublist(start, stop);
    }

    throw TemplateRuntimeError('Invalid slice operation.');
  }
}

/// Custom sink that collects Futures written during rendering
class _AsyncCollectingSink implements StringSink {
  final StringSink _delegate;
  final List<Future<Object?>> _futures = [];
  final StringBuffer _buffer = StringBuffer();

  _AsyncCollectingSink(this._delegate);

  @override
  void write(Object? obj) {
    if (obj is Future) {
      // Store the Future and write a placeholder
      _futures.add(obj);
      _buffer.write('__FUTURE_${_futures.length - 1}__');
    } else {
      _buffer.write(obj);
    }
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

    // Await all collected Futures
    List<Object?> resolvedValues = [];
    for (var future in _futures) {
      try {
        resolvedValues.add(await future);
      } catch (e) {
        resolvedValues.add('[Error: $e]');
      }
    }

    // Replace placeholders with resolved values
    for (int i = 0; i < resolvedValues.length; i++) {
      content = content.replaceAll(
        '__FUTURE_${i}__',
        resolvedValues[i]?.toString() ?? 'null',
      );
    }

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
    // First, resolve all async values in parent (globals)
    var resolvedGlobals = <String, Object?>{};
    for (var entry in context.parent.entries) {
      if (entry.value is Future) {
        resolvedGlobals[entry.key] = await (entry.value as Future);
      } else {
        resolvedGlobals[entry.key] = entry.value;
      }
    }

    // Also resolve async values in context data
    var resolvedData = <String, Object?>{};
    for (var entry in context.context.entries) {
      if (entry.value is Future) {
        resolvedData[entry.key] = await (entry.value as Future);
      } else {
        resolvedData[entry.key] = entry.value;
      }
    }

    // Create a custom sink that collects Futures
    _AsyncCollectingSink collectingSink = _AsyncCollectingSink(context.sink);

    // Create a sync context with the collecting sink
    var syncContext = StringSinkRenderContext(
      context.environment,
      collectingSink,
      template: context.template,
      blocks: context.blocks,
      parent: resolvedGlobals,
      data: resolvedData,
    );

    // Use the base synchronous renderer
    _baseRenderer.visitTemplateNode(node, syncContext);

    // Get the resolved content and write it to the original sink
    String resolvedContent = await collectingSink.getResolvedContent();
    context.sink.write(resolvedContent);
  }
}
