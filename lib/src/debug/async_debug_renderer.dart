import 'dart:async';

import '../nodes.dart';
import '../renderer.dart';
import '../runtime.dart';
import '../utils.dart';
import '../visitor.dart';
import 'debug_controller.dart';
import 'debug_renderer.dart';
import 'evaluator.dart';

/// Exception thrown when debug execution is stopped.
class DebugStopException implements Exception {
  DebugStopException();
}

/// Async version of the renderer for debugging
class AsyncDebugRenderer extends Visitor<DebugRenderContext, Future<Object?>> {
  AsyncDebugRenderer();

  /// Set to track which lines have already triggered breakpoints during this render
  final Set<int> _linesHitThisRender = {};

  /// Track if we're currently inside a for loop iteration
  final bool _inForIteration = false;

  /// Track the line number of the current for statement
  int? _currentForLine;

  /// Current recursion depth for stepping logic
  int _currentDepth = 0;

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

    // Use actual source line from node if available, otherwise use context line
    int currentLine = node.line ?? context.currentLine;

    // Check stepping logic first
    var stepMode = context.debugController.stepMode;
    if (stepMode != null) {
      var stepDepth = context.debugController.stepDepth;
      switch (stepMode) {
        case DebugAction.stepOver:
          // Break only if we're at or above the step depth
          if (_currentDepth > stepDepth) {
            return; // Don't break, continue stepping
          }
          break;
        case DebugAction.stepIn:
          // Always break on step in
          break;
        case DebugAction.stepOut:
          // Break only if we're below the step depth (closer to surface)
          if (_currentDepth >= stepDepth) {
            return; // Don't break, continue stepping out
          }
          break;
        case DebugAction.resume:
        case DebugAction.stop:
          // These are handled elsewhere
          break;
      }
    }

    var breakpoints = context.debugController.getBreakpoints(currentLine);
    var shouldCheckBreakpoints = breakpoints.isNotEmpty && !_linesHitThisRender.contains(currentLine);

    // Also check if we're stepping and should break
    if (stepMode == DebugAction.stepIn || stepMode == DebugAction.stepOver || stepMode == DebugAction.stepOut) {
      shouldCheckBreakpoints = true;
    }

    if (shouldCheckBreakpoints) {
      var shouldBreak = false;

      // Check breakpoint conditions
      if (breakpoints.isNotEmpty) {
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
      } else if (stepMode != null) {
        // Stepping without breakpoint - always break
        shouldBreak = true;
      }

      if (shouldBreak) {
        // Mark this line as hit if it's a line breakpoint
        if (breakpoints.isNotEmpty) {
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
          availableFilters: context.getAvailableFilters(),
          availableTests: context.getAvailableTests(),
          callStack: context.callStack,
        );

        var action = await context.debugController.handleBreakpoint(info);

        // Check for state updates
        var updates = context.debugController.popPendingStateUpdates();
        if (updates != null) {
          context.applyUpdates(updates);
        }

        // Update step mode based on action
        if (action == DebugAction.stepOver || action == DebugAction.stepIn) {
          context.debugController.setStepMode(action, _currentDepth);
        } else if (action == DebugAction.stepOut) {
          // Step out from current depth
          context.debugController.setStepMode(action, _currentDepth);
        } else if (action == DebugAction.stop) {
          throw DebugStopException();
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
    // Don't check breakpoints on Attribute nodes - they're part of expression evaluation
    var value = await node.value.accept(this, context);
    return context.attribute(node.attribute, value, node);
  }

  @override
  Future<Object?> visitCall(Call node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Call');
    var function = await node.value.accept(this, context);
    var params = await node.calling.accept(this, context);

    // Use dynamic for safety
    List<Object?> positional;
    Map<Symbol, dynamic> named;

    if (params is (List<Object?>, Map<Symbol, dynamic>)) {
      positional = params.$1;
      named = params.$2;
    } else if (params is (List<Object?>, Map)) {
      positional = params.$1;
      named = params.$2.cast<Symbol, dynamic>();
    } else {
      // Should not happen
      positional = [];
      named = {};
    }

    return context.call(function, node, positional, Map<Symbol, dynamic>.from(named));
  }

  @override
  Future<(List<Object?>, Map<Symbol, dynamic>)> visitCalling(Calling node, DebugRenderContext context) async {
    var positional = <Object?>[];
    for (var argument in node.arguments) {
      positional.add(await argument.accept(this, context));
    }

    var named = <Symbol, dynamic>{};
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
    // Don't check breakpoints on Filter nodes - they're part of expression evaluation
    // The breakpoint should be on the Interpolation node that uses this filter
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
    // Don't check breakpoints on Name nodes - they're part of expression evaluation
    // Let the parent Interpolation node handle the breakpoint after output is written
    return switch (node.context) {
      AssignContext.load => context.resolve(node.name),
      _ => node.name,
    };
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
  Future<void> visitAutoEscape(AutoEscape node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'AutoEscape');
    _baseRenderer.visitAutoEscape(node, context);
  }

  @override
  Future<void> visitBlock(Block node, DebugRenderContext context) async {
    if (node.line != null) {
      context.setLine(node.line!);
    }

    var label = 'Block: ${node.name}';
    context.debugController.startTimer(label);
    try {
      await _checkBreakpoint(node, context, 'Block', nodeName: node.name);
      _baseRenderer.visitBlock(node, context);
    } finally {
      context.debugController.stopTimer(label);
    }
  }

  @override
  Future<void> visitBreak(Break node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Break');
    _baseRenderer.visitBreak(node, context);
  }

  @override
  Future<void> visitCallBlock(CallBlock node, DebugRenderContext context) async {
    _currentDepth++;
    try {
      await _checkBreakpoint(node, context, 'CallBlock');

      var line = node.line ?? context.currentLine;
      context.pushFrame('callblock', line);

      try {
        _baseRenderer.visitCallBlock(node, context);
      } finally {
        context.popFrame();
      }
    } finally {
      _currentDepth--;
    }
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
      await _checkBreakpoint(node, context, 'Data', nodeData: node.data, currentOutput: node.data);
    }
  }

  @override
  Future<void> visitDebug(Debug node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Debug');
    _baseRenderer.visitDebug(node, context);
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
    _currentDepth++;

    String nodeName;
    if (node.target is Name) {
      nodeName = (node.target as Name).name;
    } else {
      nodeName = node.target.toString();
    }

    var label = 'For: $nodeName';
    context.debugController.startTimer(label);

    try {
      if (node.line != null) {
        context.setLine(node.line!);
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

      for (var i = 0; i < values.length; i++) {
        var value = values[i];
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

        var outputBeforeIteration = context.outputSoFar;
        await node.body.accept(this, forContext);
        var outputAfterIteration = context.outputSoFar;

        if (outputAfterIteration.length > outputBeforeIteration.length) {
          var currentOutput = outputAfterIteration.substring(outputBeforeIteration.length);
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
            availableFilters: forContext.getAvailableFilters(),
            availableTests: forContext.getAvailableTests(),
            callStack: forContext.callStack,
          );

          if (context.debugController.breakOnLoopIteration) {
            var action = await context.debugController.handleBreakpoint(info);

            // Check for state updates
            var updates = context.debugController.popPendingStateUpdates();
            if (updates != null) {
              context.applyUpdates(updates);
            }

            if (action == DebugAction.stop) {
              throw DebugStopException();
            }
          }
        }
      }
    } finally {
      _currentDepth--;
      context.debugController.stopTimer(label);
    }
  }

  @override
  Future<void> visitFromImport(FromImport node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'FromImport');
    _baseRenderer.visitFromImport(node, context);
  }

  @override
  Future<void> visitIf(If node, DebugRenderContext context) async {
    _currentDepth++;
    try {
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
    } finally {
      _currentDepth--;
    }
  }

  @override
  Future<void> visitImport(Import node, DebugRenderContext context) async {
    await _checkBreakpoint(node, context, 'Import');
    _baseRenderer.visitImport(node, context);
  }

  @override
  Future<void> visitInclude(Include node, DebugRenderContext context) async {
    _currentDepth++;
    try {
      await _checkBreakpoint(node, context, 'Include');

      // Try to get the template name from the node if available
      var templateName = 'include:${node.template}';
      var line = node.line ?? context.currentLine;
      context.pushFrame(templateName, line);

      try {
        _baseRenderer.visitInclude(node, context);
      } finally {
        context.popFrame();
      }
    } finally {
      _currentDepth--;
    }
  }

  @override
  Future<void> visitInterpolation(Interpolation node, DebugRenderContext context) async {
    if (node.line != null) {
      context.setLine(node.line!);
    }

    // Check breakpoint before execution to allow state modification
    var currentLine = node.line ?? context.currentLine;

    // Check stepping logic (same as _checkBreakpoint)
    var stepMode = context.debugController.stepMode;
    var shouldCheck = false;
    if (stepMode != null) {
      var stepDepth = context.debugController.stepDepth;
      switch (stepMode) {
        case DebugAction.stepOver:
          if (_currentDepth <= stepDepth) shouldCheck = true;
          break;
        case DebugAction.stepIn:
          shouldCheck = true;
          break;
        case DebugAction.stepOut:
          if (_currentDepth < stepDepth) shouldCheck = true;
          break;
        default:
          break;
      }
    }

    var breakpoints = context.debugController.getBreakpoints(currentLine);
    if ((breakpoints.isNotEmpty && !_linesHitThisRender.contains(currentLine)) || shouldCheck) {
      _linesHitThisRender.add(currentLine);

      var info = BreakpointInfo(
        nodeType: 'Interpolation',
        variables: context.getAllVariables(),
        outputSoFar: context.outputSoFar,
        lineNumber: currentLine,
        availableFilters: context.getAvailableFilters(),
        availableTests: context.getAvailableTests(),
        callStack: context.callStack,
      );

      var action = await context.debugController.handleBreakpoint(info);

      // Check for state updates
      var updates = context.debugController.popPendingStateUpdates();
      if (updates != null) {
        context.applyUpdates(updates);
      }

      if (action == DebugAction.stepOver || action == DebugAction.stepIn) {
        context.debugController.setStepMode(action, _currentDepth);
      } else if (action == DebugAction.stepOut) {
        context.debugController.setStepMode(action, _currentDepth);
      } else if (action == DebugAction.stop) {
        throw DebugStopException();
      }
    }

    var value = await node.value.accept(this, context);
    var finalized = context.finalize(value);
    context.write(finalized);
  }

  @override
  Future<void> visitMacro(Macro node, DebugRenderContext context) async {
    // Definition only, execution via _getMacroFunction
    await _checkBreakpoint(node, context, 'Macro', nodeName: node.name);

    // Register the macro in the context using our async-compatible function
    context.set(node.name, _getMacroFunction(node, context));
  }

  /// Create an async macro function that uses this renderer for execution.
  /// This allows breakpoints and debugging inside the macro body.
  Function _getMacroFunction(MacroCall node, DebugRenderContext context) {
    Future<Object?> macro(List<Object?> positional, Map<Object?, Object?> named) async {
      // Create a derived context for the macro execution
      var buffer = StringBuffer();
      // We need to create a derived context that captures the variables but writes to a new buffer
      // However, DebugRenderContext expects _outputBuffer to be the same if not passed.
      // We must pass a new buffer.
      // Also, macros should not inherit variables unless configured?
      // Standard behavior: macros don't inherit context variables by default.
      // But they do if `with context` (ImportContext) - but Macro definition doesn't have that.
      // Macros are closures.
      // In StringSinkRenderer, it uses derived(sink: buffer).

      var derived = context.derived(sink: buffer, outputBuffer: buffer);

      var index = 0;
      var mandatoryLength = node.positional.length;

      // Argument handling (simplified from StringSinkRenderer for brevity but functional)
      try {
        // 1. Mandatory positional arguments
        for (; index < mandatoryLength; index += 1) {
          var key = await node.positional[index].accept(this, context) as String;
          derived.set(key, positional.length > index ? positional[index] : null);
        }

        // 2. Named arguments (simplified)
        for (var (argument, defaultValue) in node.named) {
          var key = await argument.accept(this, context) as String;
          if (named.containsKey(Symbol(key))) {
            derived.set(key, named[Symbol(key)]);
          } else {
            // Evaluate default
            var defaultVal = await defaultValue.accept(this, context);
            derived.set(key, defaultVal);
          }
        }
      } catch (e) {
        // Fallback or rethrow
      }

      // Track stack frame
      _currentDepth++;
      var label = 'MacroCall: ${node.name}';
      context.debugController.startTimer(label);

      // Push frame to the ORIGINAL context's controller (derived shares it)
      var line = node.body.line ?? node.line ?? context.currentLine;
      context.pushFrame('macro:${node.name}', line);

      try {
        await node.body.accept(this, derived);
        return SafeString(buffer.toString());
      } finally {
        context.popFrame();
        _currentDepth--;
        context.debugController.stopTimer(label);
      }
    }

    return macro;
  }

  @override
  Future<void> visitOutput(Output node, DebugRenderContext context) async {
    for (var child in node.nodes) {
      await child.accept(this, context);
    }
  }

  @override
  Future<void> visitTemplateNode(TemplateNode node, DebugRenderContext context) async {
    _currentDepth++;

    var label = 'Template';
    context.debugController.startTimer(label);

    try {
      await _checkBreakpoint(node, context, 'Template');

      var templateName = context.template ?? '<template>';
      var line = node.line ?? context.currentLine;
      context.pushFrame(templateName, line);

      try {
        // Set up blocks
        for (var block in node.blocks) {
          context.blocks[block.name] ??= [];
          context.blocks[block.name]!.add((ctx) {
            block.body.accept(_baseRenderer, ctx);
          });
        }

        await node.body.accept(this, context);
      } finally {
        context.popFrame();
      }
    } finally {
      _currentDepth--;
      context.debugController.stopTimer(label);
    }
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
