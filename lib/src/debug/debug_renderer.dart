import 'dart:async';
import 'package:jinja/src/debug/debug_controller.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';

/// Debug version of StringSinkRenderContext that tracks execution
base class DebugRenderContext extends StringSinkRenderContext {
  final DebugController debugController;
  final StringBuffer _outputBuffer = StringBuffer();
  int _currentLine = 0;
  bool _shouldStop = false;

  DebugRenderContext(
    super.environment,
    super.sink, {
    required this.debugController,
    super.template,
    super.blocks,
    super.parent,
    super.data,
  });

  @override
  DebugRenderContext derived({
    StringSink? sink,
    String? template,
    Map<String, Object?>? data,
    bool withContext = true,
  }) {
    Map<String, Object?> parent;

    if (withContext) {
      parent = <String, Object?>{...this.parent, ...context};
    } else {
      parent = this.parent;
    }

    return DebugRenderContext(
      environment,
      sink ?? this.sink,
      debugController: debugController,
      template: template ?? this.template,
      blocks: blocks,
      parent: parent,
      data: data,
    );
  }

  @override
  void write(Object? value) {
    super.write(value);
    _outputBuffer.write(value);
  }

  String get outputSoFar => _outputBuffer.toString();

  void stopExecution() {
    _shouldStop = true;
  }

  bool get shouldStop => _shouldStop;

  void incrementLine() {
    _currentLine++;
  }

  int get currentLine => _currentLine;

  /// Get all current variables in scope
  Map<String, Object?> getAllVariables() {
    var allVars = <String, Object?>{};
    allVars.addAll(parent);
    allVars.addAll(context);
    return allVars;
  }
}

/// Debug renderer that supports breakpoints
base class DebugRenderer extends StringSinkRenderer {
  const DebugRenderer();

  Future<bool> _checkBreakpoint(Node node, DebugRenderContext context, String nodeType, {String? nodeName, dynamic nodeData}) async {
    if (context.debugController.shouldBreak(nodeType, context.currentLine)) {
      var info = BreakpointInfo(
        nodeType: nodeType,
        variables: context.getAllVariables(),
        outputSoFar: context.outputSoFar,
        lineNumber: context.currentLine,
        nodeName: nodeName,
        nodeData: nodeData,
      );

      var action = await context.debugController.handleBreakpoint(info);

      switch (action) {
        case DebugAction.stop:
          context.stopExecution();
          return false;
        case DebugAction.restart:
          throw RestartException();
        case DebugAction.continueExecution:
          return true;
      }
    }
    return true;
  }

  @override
  void visitData(Data node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      var shouldContinue = _checkBreakpoint(node, context, 'Data', nodeData: node.data).then((value) => value);

      // For simplicity in sync context, we'll use sync check
      if (context.shouldStop) return;
    }
    super.visitData(node, context);
  }

  @override
  void visitInterpolation(Interpolation node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      context.incrementLine();
      var shouldContinue = _checkBreakpoint(node, context, 'Interpolation', nodeData: node.value).then((value) => value);

      if (context.shouldStop) return;
    }
    super.visitInterpolation(node, context);
  }

  @override
  void visitFor(For node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      context.incrementLine();
      var shouldContinue =
          _checkBreakpoint(node, context, 'For', nodeName: node.target.toString(), nodeData: node.iterable).then((value) => value);

      if (context.shouldStop) return;
    }
    super.visitFor(node, context);
  }

  @override
  void visitIf(If node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      context.incrementLine();
      var shouldContinue = _checkBreakpoint(node, context, 'If', nodeData: node.test).then((value) => value);

      if (context.shouldStop) return;
    }
    super.visitIf(node, context);
  }

  @override
  void visitAssign(Assign node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      context.incrementLine();
      var shouldContinue =
          _checkBreakpoint(node, context, 'Assign', nodeName: node.target.toString(), nodeData: node.value).then((value) => value);

      if (context.shouldStop) return;
    }
    super.visitAssign(node, context);
  }

  @override
  void visitBlock(Block node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      context.incrementLine();
      var shouldContinue = _checkBreakpoint(node, context, 'Block', nodeName: node.name).then((value) => value);

      if (context.shouldStop) return;
    }
    super.visitBlock(node, context);
  }
}

/// Exception thrown when restart is requested
class RestartException implements Exception {
  const RestartException();
}
