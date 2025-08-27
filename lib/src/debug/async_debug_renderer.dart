import 'dart:async';

import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:jinja/src/runtime.dart';
import 'package:jinja/src/utils.dart';
import 'package:jinja/src/visitor.dart';

import 'debug_controller.dart';
import 'debug_renderer.dart';
import 'evaluator.dart';

/// Async version of the renderer for debugging
class AsyncDebugRenderer extends Visitor<DebugRenderContext, Future<Object?>> {
  AsyncDebugRenderer();

  /// Set to track which lines have already triggered breakpoints during this render
  final Set<int> _linesHitThisRender = {};

  final StringSinkRenderer _baseRenderer = const StringSinkRenderer();

  /// Helper method to get the line range of a node and all its children
  (int?, int?) _getNodeLineRange(Node node) {
    int? minLine = node.line;
    int? maxLine = node.line;

    // Recursively find all line numbers in the node tree
    void findLines(Node n) {
      if (n.line != null) {
        if (minLine == null || n.line! < minLine!) {
          minLine = n.line;
        }
        if (maxLine == null || n.line! > maxLine!) {
          maxLine = n.line;
        }
      }

      // Check all child nodes
      for (var child in n.findAll<Node>()) {
        findLines(child);
      }
    }

    findLines(node);
    return (minLine, maxLine);
  }

  Future<void> _checkBreakpoint(
    Node node,
    DebugRenderContext context,
    String nodeType, {
    String? nodeName,
    Object? nodeData,
  }) async {
    if (!context.debugController.enabled) return;

    // Use actual source line from node if available, otherwise use context line
    int currentLine = node.line ?? context.currentLine;

    var breakpoints = context.debugController.getBreakpoints(currentLine);
    var stepBreak = context.stepAction == DebugAction.stepOver && context.depth <= 0 || context.stepAction == DebugAction.stepIn;

    if ((breakpoints.isNotEmpty && !_linesHitThisRender.contains(currentLine)) || stepBreak) {
      var shouldBreak = stepBreak;
      if (!shouldBreak) {
        for (var bp in breakpoints) {
          if (bp.condition == null) {
            shouldBreak = true;
            break;
          }
          var expr = context.environment.parse(bp.condition!);
          var result = expr.accept(const ExpressionEvaluator(), context);
          if (result is bool && result) {
            shouldBreak = true;
            break;
          }
        }
      }

      if (shouldBreak) {
        // Mark this line as hit if it's a line breakpoint
        if (breakpoints.isNotEmpty) {
          _linesHitThisRender.add(currentLine);
        }
        var info = BreakpointInfo(
          nodeType: nodeType,
          variables: context.getAllVariables(),
          outputSoFar: context.outputSoFar,
          lineNumber: currentLine,
          nodeName: nodeName,
          nodeData: nodeData,
        );

        var action = await context.debugController.handleBreakpoint(info);
        context.setStepAction(action);

        switch (action) {
          case DebugAction.stop:
            throw StopException();
          case DebugAction.continueExecution:
          case DebugAction.stepOver:
          case DebugAction.stepIn:
          case DebugAction.stepOut:
            break;
        }
      }
    }
  }

  @override
  Future<List<Object?>> visitArray(Array node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Array');
    var result = <Object?>[];
    for (var value in node.values) {
      result.add(await value.accept(this, context));
    }
    return result;
  }

  @override
  Future<Object?> visitAttribute(Attribute node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Attribute', nodeName: node.attribute);
    var value = await node.value.accept(this, context);
    return context.attribute(node.attribute, value, node);
  }

  @override
  Future<Object?> visitCall(Call node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Call');
    var function = await node.value.accept(this, context);
    var params = await node.calling.accept(this, context) as Parameters;
    var (positional, named) = params;
    return context.call(function, node, positional, named);
  }

  @override
  Future<Parameters> visitCalling(Calling node, DebugRenderContext context) async {
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
  Future<bool> visitCompare(Compare node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Compare');
    return _baseRenderer.visitCompare(node, context);
  }

  @override
  Future<Object?> visitConcat(Concat node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Concat');
    var buffer = StringBuffer();
    for (var value in node.values) {
      buffer.write(await value.accept(this, context));
    }
    return buffer.toString();
  }

  @override
  Future<Object?> visitCondition(Condition node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Condition');
    var testResult = await node.test.accept(this, context);
    if (boolean(testResult)) {
      return await node.trueValue.accept(this, context);
    }
    return node.falseValue != null ? await node.falseValue!.accept(this, context) : null;
  }

  @override
  Future<Object?> visitConstant(Constant node, DebugRenderContext context) async {
    return node.value;
  }

  @override
  Future<Map<Object?, Object?>> visitDict(Dict node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Dict');
    var result = <Object?, Object?>{};
    for (var (:key, :value) in node.pairs) {
      var k = await key.accept(this, context);
      var v = await value.accept(this, context);
      result[k] = v;
    }
    return result;
  }

  @override
  Future<Object?> visitFilter(Filter node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Filter', nodeName: node.name);
    var params = await node.calling.accept(this, context) as Parameters;
    var (positional, named) = params;
    return context.filter(node.name, positional, named);
  }

  @override
  Future<Object?> visitItem(Item node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Item');
    var key = await node.key.accept(this, context);
    var value = await node.value.accept(this, context);
    return context.item(key, value, node);
  }

  @override
  Future<Object?> visitLogical(Logical node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Logical');
    return _baseRenderer.visitLogical(node, context);
  }

  @override
  Future<Object?> visitName(Name node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Name', nodeName: node.name);
    return _baseRenderer.visitName(node, context);
  }

  @override
  Future<NamespaceValue> visitNamespaceRef(NamespaceRef node, DebugRenderContext context) async {
    return NamespaceValue(node.name, node.attribute);
  }

  @override
  Future<Object?> visitScalar(Scalar node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Scalar');
    return _baseRenderer.visitScalar(node, context);
  }

  @override
  Future<Object?> visitTest(Test node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Test', nodeName: node.name);
    var params = await node.calling.accept(this, context) as Parameters;
    var (positional, named) = params;
    return context.test(node.name, positional, named);
  }

  @override
  Future<List<Object?>> visitTuple(Tuple node, DebugRenderContext context) async {
    var result = <Object?>[];
    for (var value in node.values) {
      result.add(await value.accept(this, context));
    }
    return result;
  }

  @override
  Future<Object?> visitUnary(Unary node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Unary');
    return _baseRenderer.visitUnary(node, context);
  }

  @override
  Future<void> visitAssign(Assign node, DebugRenderContext context) async {
    if (node.line != null) {
      context.setLine(node.line!);
    }
    String nodeName = '';
    if (node.target is Name) {
      nodeName = (node.target as Name).name;
    } else {
      nodeName = node.target.toString();
    }
    await _checkBreakpoint(node, context, 'Assign', nodeName: nodeName);
    var target = await node.target.accept(this, context);
    var values = await node.value.accept(this, context);
    context.assignTargets(target, values);
  }

  @override
  Future<void> visitAssignBlock(AssignBlock node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'AssignBlock');
    _baseRenderer.visitAssignBlock(node, context);
  }

  @override
  Future<void> visitBlock(Block node, DebugRenderContext context) async {
    if (node.line != null) {
      context.setLine(node.line!);
    }
    await _checkBreakpoint(node, context, 'Block', nodeName: node.name);
    _baseRenderer.visitBlock(node, context);
  }

  @override
  Future<void> visitCallBlock(CallBlock node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'CallBlock');
    _baseRenderer.visitCallBlock(node, context);
  }

  @override
  Future<void> visitData(Data node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Data', nodeData: node.data);
    context.write(node.data);
  }

  @override
  Future<void> visitDo(Do node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Do');
    await node.value.accept(this, context);
  }

  @override
  Future<void> visitExtends(Extends node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Extends');
    _baseRenderer.visitExtends(node, context);
  }

  @override
  Future<void> visitFilterBlock(FilterBlock node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'FilterBlock');
    _baseRenderer.visitFilterBlock(node, context);
  }

  @override
  Future<void> visitFor(For node, DebugRenderContext context) async {
    if (node.line != null) {
      context.setLine(node.line!);
    }
    String nodeName;
    if (node.target is Name) {
      nodeName = (node.target as Name).name;
    } else {
      nodeName = node.target.toString();
    }
    await _checkBreakpoint(node, context, 'For', nodeName: nodeName);

    var targets = await node.target.accept(this, context);
    var iterable = await node.iterable.accept(this, context);

    List<Object?> values;
    if (iterable is Map) {
      values = List<Object?>.of(iterable.entries);
    } else {
      values = list(iterable);
    }

    if (values.isEmpty && node.orElse != null) {
      await node.orElse!.accept(this, context);
      return;
    }

    for (var value in values) {
      // When iterating, we clear the lines hit inside the loop body so that
      // breakpoints can be triggered again for each iteration.
      var (minLine, maxLine) = _getNodeLineRange(node.body);
      if (minLine != null && maxLine != null) {
        _linesHitThisRender
            .removeWhere((line) => line >= minLine && line <= maxLine);
      }
      var data = _baseRenderer.getDataForTargets(targets, value);
      var forContext = context.derived(data: data);
      await node.body.accept(this, forContext);
    }
  }

  @override
  Future<void> visitFromImport(FromImport node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'FromImport');
    _baseRenderer.visitFromImport(node, context);
  }

  @override
  Future<void> visitIf(If node, DebugRenderContext context) async {
    if (node.line != null) {
      context.setLine(node.line!);
    }
    await _checkBreakpoint(node, context, 'If');

    var testResult = await node.test.accept(this, context);
    if (boolean(testResult)) {
      await node.body.accept(this, context);
    } else if (node.orElse != null) {
      await node.orElse!.accept(this, context);
    }
  }

  @override
  Future<void> visitImport(Import node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Import');
    _baseRenderer.visitImport(node, context);
  }

  @override
  Future<void> visitInclude(Include node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Include');
    _baseRenderer.visitInclude(node, context);
  }

  @override
  Future<void> visitInterpolation(Interpolation node, DebugRenderContext context) async {
    if (node.line != null) {
      context.setLine(node.line!);
    }
    await _checkBreakpoint(node, context, 'Interpolation');
    var value = await node.value.accept(this, context);
    var finalized = context.finalize(value);
    context.write(finalized);
  }

  @override
  Future<void> visitMacro(Macro node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Macro', nodeName: node.name);
    _baseRenderer.visitMacro(node, context);
  }

  @override
  Future<void> visitOutput(Output node, DebugRenderContext context) async {
    for (var child in node.nodes) {
      await child.accept(this, context);
    }
  }

  @override
  Future<void> visitTemplateNode(TemplateNode node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Template');

    // Set up blocks
    for (var block in node.blocks) {
      context.blocks[block.name] ??= [];
      context.blocks[block.name]!.add((ctx) {
        block.body.accept(_baseRenderer, ctx);
      });
    }

    await node.body.accept(this, context);
  }

  @override
  Future<void> visitTryCatch(TryCatch node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'TryCatch');
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
  Future<void> visitWith(With node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'With');
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
  Future<Object?> visitSlice(Slice node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Slice');
    return _baseRenderer.visitSlice(node, context);
  }
}

/// Exception thrown when execution should stop
class StopException implements Exception {
  const StopException();
}
