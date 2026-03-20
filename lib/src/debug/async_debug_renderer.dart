import 'dart:async';

import '../exceptions.dart';
import '../nodes.dart';
import '../renderer.dart';
import '../runtime.dart';
import '../utils.dart';
import '../visitor.dart';
import 'debug_controller.dart';
import 'debug_renderer.dart';

/// Async version of the renderer for debugging
class AsyncDebugRenderer extends Visitor<DebugRenderContext, Future<Object?>> {
  AsyncDebugRenderer();

  /// Set to track which lines have already triggered breakpoints during this render
  final Set<int> _linesHitThisRender = {};

  /// Track if we're currently inside a for loop iteration
  final bool _inForIteration = false;

  /// Track the line number of the current for statement
  int? _currentForLine;

  final StringSinkRenderer _baseRenderer = const StringSinkRenderer();

  /// Helper method to get the line range of a node and all its children
  (int?, int?) _getNodeLineRange(Node node) {
    int? minLine = node.line;
    int? maxLine = node.line;

    void update(int? line) {
      if (line == null) return;
      if (minLine == null || line < minLine!) {
        minLine = line;
      }
      if (maxLine == null || line > maxLine!) {
        maxLine = line;
      }
    }

    update(node.line);
    for (var child in node.findAll<Node>()) {
      update(child.line);
    }

    return (minLine, maxLine);
  }

  Future<void> _checkBreakpoint(
    Node node,
    DebugRenderContext context,
    String nodeType, {
    String? nodeName,
    Object? nodeData,
    String? currentOutput,
  }) async {
    if (!context.debugController.enabled) return;
    if (context.debugController.stopped) throw DebugStoppedException();

    // Use actual source line from node if available, otherwise use context line
    int currentLine = node.line ?? context.currentLine;

    // Handle step over
    bool isStepOverHit = false;
    if (context.debugController.stepOverLine != null) {
      if (currentLine == context.debugController.stepOverLine) {
        return;
      }
      context.debugController.stepOverLine = null;
      isStepOverHit = true;
    }

    var breakpoints = context.debugController.getBreakpoints(currentLine);

    if ((breakpoints.isNotEmpty || isStepOverHit) && !_linesHitThisRender.contains(currentLine)) {
      var shouldBreak = isStepOverHit;
      if (!shouldBreak) {
        for (var bp in breakpoints) {
          if (bp.condition == null) {
            shouldBreak = true;
            break;
          }
          try {
            var template = context.environment.fromString('{{ ${bp.condition} }}');
            var result = template.render(context.getAllVariables());
            if (result == 'true') {
              shouldBreak = true;
              break;
            }
          } catch (e) {
            // Ignore errors in condition evaluation
          }
        }
      }

      if (shouldBreak) {
        // Mark this line as hit if it's a line breakpoint
        if (breakpoints.isNotEmpty || isStepOverHit) {
          _linesHitThisRender.add(currentLine);
        }

        var totalOutput = context.outputSoFar;
        var current = currentOutput ?? '';
        var soFar =
            (current.isNotEmpty && totalOutput.endsWith(current)) ? totalOutput.substring(0, totalOutput.length - current.length) : totalOutput;

        var info = BreakpointInfo(
          nodeType: nodeType,
          variables: context.getAllVariables(),
          outputSoFar: soFar,
          currentOutput: current,
          lineNumber: currentLine,
          nodeName: nodeName,
          nodeData: nodeData,
        );

        final action = await context.debugController.handleBreakpoint(info);
        if (action == DebugAction.stop) {
          throw DebugStoppedException();
        }
      }
    }
  }

  @override
  Future<List<Object?>> visitArray(
    Array node,
    DebugRenderContext context,
  ) async {
    var result = <Object?>[];
    for (var value in node.values) {
      result.add(await value.accept(this, context));
    }
    await _checkBreakpoint(node, context, 'Array', nodeData: result);
    return result;
  }

  @override
  Future<Object?> visitAttribute(
    Attribute node,
    DebugRenderContext context,
  ) async {
    // Check breakpoints on Attribute nodes with the attribute name
    var value = await node.value.accept(this, context);
    var attributeValue = context.attribute(node.attribute, value, node);
    await _checkBreakpoint(
      node,
      context,
      'Attribute',
      nodeName: node.attribute,
      nodeData: attributeValue,
    );
    return attributeValue;
  }

  @override
  Future<Object?> visitCall(Call node, DebugRenderContext context) async {
    String? nodeName;
    if (node.value is Name) {
      nodeName = (node.value as Name).name;
    }
    var function = await node.value.accept(this, context);
    var params = await node.calling.accept(this, context) as Parameters;
    var (positional, named) = params;
    var result = context.call(function, node, positional, named);
    await _checkBreakpoint(
      node,
      context,
      'Call',
      nodeName: nodeName,
      nodeData: result,
    );
    return result;
  }

  @override
  Future<Parameters> visitCalling(
    Calling node,
    DebugRenderContext context,
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
  Future<bool> visitCompare(Compare node, DebugRenderContext context) async {
    var result = _baseRenderer.visitCompare(node, context);
    await _checkBreakpoint(node, context, 'Compare', nodeData: result);
    return result;
  }

  @override
  Future<Object?> visitConcat(Concat node, DebugRenderContext context) async {
    var buffer = StringBuffer();
    for (var value in node.values) {
      buffer.write(await value.accept(this, context));
    }
    var result = buffer.toString();
    await _checkBreakpoint(node, context, 'Concat', nodeData: result);
    return result;
  }

  @override
  Future<Object?> visitCondition(
    Condition node,
    DebugRenderContext context,
  ) async {
    var testResult = await node.test.accept(this, context);
    Object? result;
    if (boolean(testResult)) {
      result = await node.trueValue.accept(this, context);
    } else {
      result = node.falseValue != null ? await node.falseValue!.accept(this, context) : null;
    }
    await _checkBreakpoint(node, context, 'Condition', nodeData: result);
    return result;
  }

  @override
  Future<Object?> visitConstant(
    Constant node,
    DebugRenderContext context,
  ) async {
    return node.value;
  }

  @override
  Future<Map<Object?, Object?>> visitDict(
    Dict node,
    DebugRenderContext context,
  ) async {
    var result = <Object?, Object?>{};
    for (var (:key, :value) in node.pairs) {
      var k = await key.accept(this, context);
      var v = await value.accept(this, context);
      result[k] = v;
    }
    await _checkBreakpoint(node, context, 'Dict', nodeData: result);
    return result;
  }

  @override
  Future<Object?> visitFilter(Filter node, DebugRenderContext context) async {
    // Don't check breakpoints on Filter nodes - they're part of expression evaluation
    // The breakpoint should be on the Interpolation node that uses this filter
    var params = await node.calling.accept(this, context) as Parameters;
    var (positional, named) = params;
    return context.filter(node.name, positional, named);
  }

  @override
  Future<Object?> visitItem(Item node, DebugRenderContext context) async {
    var key = await node.key.accept(this, context);
    await _checkBreakpoint(node, context, 'Item', nodeData: key);
    var value = await node.value.accept(this, context);
    return context.item(key, value, node);
  }

  @override
  Future<Object?> visitLogical(Logical node, DebugRenderContext context) async {
    var result = _baseRenderer.visitLogical(node, context);
    await _checkBreakpoint(node, context, 'Logical', nodeData: result);
    return result;
  }

  @override
  Future<Object?> visitName(Name node, DebugRenderContext context) async {
    // Don't check breakpoints on Name nodes - they're part of expression evaluation
    // Let the parent Interpolation node handle the breakpoint after output is written
    return switch (node.context) {
      AssignContext.load => context.resolve(node.name),
      _ => node.name,
    };
  }

  @override
  Future<NamespaceValue> visitNamespaceRef(
    NamespaceRef node,
    DebugRenderContext context,
  ) async {
    return NamespaceValue(node.name, node.attribute);
  }

  @override
  Future<Object?> visitScalar(Scalar node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Scalar');
    return _baseRenderer.visitScalar(node, context);
  }

  @override
  Future<Object?> visitTest(Test node, DebugRenderContext context) async {
    var params = await node.calling.accept(this, context) as Parameters;
    var (positional, named) = params;
    var result = context.test(node.name, positional, named);
    await _checkBreakpoint(
      node,
      context,
      'Test',
      nodeName: node.name,
      nodeData: result,
    );
    return result;
  }

  @override
  Future<List<Object?>> visitTuple(
    Tuple node,
    DebugRenderContext context,
  ) async {
    var result = <Object?>[];
    for (var value in node.values) {
      result.add(await value.accept(this, context));
    }
    await _checkBreakpoint(node, context, 'Tuple', nodeData: result);
    return result;
  }

  @override
  Future<Object?> visitUnary(Unary node, DebugRenderContext context) async {
    var result = _baseRenderer.visitUnary(node, context);
    await _checkBreakpoint(node, context, 'Unary', nodeData: result);
    return result;
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

    // Evaluate target and value in the async debug context.
    var target = await node.target.accept(this, context);
    var value = await node.value.accept(this, context);

    // If the evaluated value is still a Future (for example, because a global like
    // `jinja_action` returns a Future), await it here so that subsequent reads of
    // the assigned variable see the resolved result instead of a Future.
    if (value is Future) {
      try {
        value = await value;
      } catch (e) {
        // In debug mode, surface the error through the debug controller rather than
        // wrapping it again; this keeps behavior consistent with other debug nodes.
        rethrow;
      }
    }

    await _checkBreakpoint(
      node,
      context,
      'Assign',
      nodeName: nodeName,
      nodeData: value,
    );
    context.assignTargets(target, value);
  }

  @override
  Future<void> visitAssignBlock(
    AssignBlock node,
    DebugRenderContext context,
  ) async {
    await _checkBreakpoint(node, context, 'AssignBlock');
    _baseRenderer.visitAssignBlock(node, context);
  }

  @override
  Future<void> visitAutoEscape(
    AutoEscape node,
    DebugRenderContext context,
  ) async {
    await _checkBreakpoint(node, context, 'AutoEscape');
    _baseRenderer.visitAutoEscape(node, context);
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
  Future<void> visitBreak(Break node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Break');
    _baseRenderer.visitBreak(node, context);
  }

  @override
  Future<void> visitCallBlock(
    CallBlock node,
    DebugRenderContext context,
  ) async {
    await _checkBreakpoint(node, context, 'CallBlock');
    _baseRenderer.visitCallBlock(node, context);
  }

  @override
  Future<void> visitContinue(Continue node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Continue');
    _baseRenderer.visitContinue(node, context);
  }

  @override
  Future<void> visitData(Data node, DebugRenderContext context) async {
    context.write(node.data);
    // Skip breakpoint for Data nodes on the for statement line when inside iterations
    // This prevents the whitespace after {% for %} from triggering on each iteration
    if (!(_inForIteration && node.line == _currentForLine)) {
      await _checkBreakpoint(
        node,
        context,
        'Data',
        nodeData: node.data,
        currentOutput: node.data,
      );
    }
  }

  @override
  Future<void> visitDebug(Debug node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Debug');
    _baseRenderer.visitDebug(node, context);
  }

  @override
  Future<void> visitDo(Do node, DebugRenderContext context) async {
    var value = await node.value.accept(this, context);
    await _checkBreakpoint(node, context, 'Do', nodeData: value);
  }

  @override
  Future<void> visitExtends(Extends node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Extends');
    _baseRenderer.visitExtends(node, context);
  }

  @override
  Future<void> visitFilterBlock(
    FilterBlock node,
    DebugRenderContext context,
  ) async {
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

    var targets = await node.target.accept(this, context);
    var iterable = await node.iterable.accept(this, context);

    await _checkBreakpoint(
      node,
      context,
      'For',
      nodeName: nodeName,
      nodeData: iterable,
    );

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

    if (node.test != null) {
      var test = node.test!;
      var filtered = <Object?>[];
      for (var value in values) {
        var data = _baseRenderer.getDataForTargets(targets, value);
        var newContext = context.derived(data: data);
        if (boolean(await test.accept(this, newContext))) {
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

    String recurse(Object? data, [int depth = 0]) {
      // Recursive loops are not supported in async mode yet.
      return '';
    }

    var loop = LoopContext(values, 0, recurse);

    int i = 0;
    for (var value in loop) {
      // When iterating, we clear the lines hit inside the loop body so that
      // breakpoints can be triggered again for each iteration.
      // But we need to be careful not to clear lines that shouldn't be repeated
      if (i > 0) {
        // Only clear lines after the first iteration
        var (minLine, maxLine) = _getNodeLineRange(node.body);
        if (minLine != null && maxLine != null) {
          _linesHitThisRender.removeWhere((line) {
            // Never clear line 2 (the for statement line) from the hit list
            // This prevents Data nodes on the for line from re-triggering
            if (line == 2) return false;
            // Only clear lines strictly within the loop body range
            return line >= minLine && line <= maxLine;
          });
        }
      }
      var data = _baseRenderer.getDataForTargets(targets, value);
      var forContext = context.derived(data: data);
      forContext.set('loop', loop);

      var outputBeforeIteration = context.outputSoFar;
      try {
        await node.body.accept(this, forContext);
      } on BreakException {
        break;
      } on ContinueException {
        continue;
      }
      var outputAfterIteration = context.outputSoFar;

      if (outputAfterIteration.length > outputBeforeIteration.length) {
        var currentOutput = outputAfterIteration.substring(
          outputBeforeIteration.length,
        );
        // This is a bit of a hack, but we need to manually trigger the breakpoint
        // for the content generated inside the loop, as the nodes inside won't
        // be aware that they are part of a loop's output.
        var info = BreakpointInfo(
          nodeType: 'ForLoopIteration',
          variables: forContext.getAllVariables(),
          outputSoFar: outputBeforeIteration,
          currentOutput: currentOutput,
          lineNumber: node.line ?? context.currentLine,
          nodeName: nodeName,
        );
        if (context.debugController.breakOnLoopIteration) {
          final action = await context.debugController.handleBreakpoint(info);
          if (action == DebugAction.stop) {
            throw DebugStoppedException();
          }
        }
      }
      i++;
    }
  }

  @override
  Future<void> visitFromImport(
    FromImport node,
    DebugRenderContext context,
  ) async {
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
  Future<void> visitInterpolation(
    Interpolation node,
    DebugRenderContext context,
  ) async {
    if (node.line != null) {
      context.setLine(node.line!);
    }
    var value = await node.value.accept(this, context);
    var finalized = context.finalize(value);
    context.write(finalized);
    var currentOutput = finalized.toString();

    // Extract nodeName from the value if it's a simple name or attribute chain
    String? nodeName;
    if (node.value is Name) {
      nodeName = (node.value as Name).name;
    }

    await _checkBreakpoint(
      node,
      context,
      'Interpolation',
      nodeName: nodeName,
      nodeData: finalized.toString(),
      currentOutput: currentOutput,
    );
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
  Future<void> visitTemplateNode(
    TemplateNode node,
    DebugRenderContext context,
  ) async {
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
  Future<void> visitTrans(Trans node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Trans');
    _baseRenderer.visitTrans(node, context);
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
