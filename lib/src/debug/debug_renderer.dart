import 'dart:async';

import 'package:jinja/src/debug/debug_controller.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:jinja/src/runtime.dart';

/// Debug version of StringSinkRenderContext that tracks execution
base class DebugRenderContext extends StringSinkRenderContext {
  final DebugController debugController;
  final StringBuffer _outputBuffer;
  int _currentLine = 0;

  DebugRenderContext(
    super.environment,
    super.sink, {
    required this.debugController,
    super.template,
    super.blocks,
    super.parent,
    super.data,
    StringBuffer? outputBuffer,
  }) : _outputBuffer = outputBuffer ?? StringBuffer();

  @override
  DebugRenderContext derived({
    StringSink? sink,
    String? template,
    Map<String, Object?>? data,
    bool withContext = true,
  }) {
    var parent = withContext ? {...this.parent, ...context} : this.parent;
    return DebugRenderContext(
      environment,
      sink ?? this.sink,
      debugController: debugController,
      template: template ?? this.template,
      blocks: blocks,
      parent: parent,
      data: data,
      outputBuffer: _outputBuffer,
    );
  }

  @override
  void write(Object? value) {
    super.write(value);
    _outputBuffer.write(value);
  }

  String get outputSoFar => _outputBuffer.toString();

  void setLine(int line) => _currentLine = line;
  int get currentLine => _currentLine;

  Map<String, Object?> getAllVariables() {
    var allVars = <String, Object?>{...parent, ...context};
    var allVarsToSend = <String, dynamic>{};
    for (var entry in allVars.entries) {
      if (entry.value is Namespace) {
        allVarsToSend.addAll((entry.value as Namespace).context);
      } else if (entry.value is! Function) {
        allVarsToSend[entry.key] = entry.value;
      }
    }
    return allVarsToSend;
  }
}

/// Debug renderer that supports breakpoints
base class DebugRenderer extends StringSinkRenderer {
  const DebugRenderer();

  Future<void> _checkBreakpoint(Node node, DebugRenderContext context) async {
    if (node.line != null) {
      context.setLine(node.line!);
    }

    var breakpoints = context.debugController.getBreakpoints(context.currentLine);

    if (breakpoints.isNotEmpty) {
      var shouldBreak = false;
      for (var bp in breakpoints) {
        if (bp.condition == null) {
          shouldBreak = true;
          break;
        }
        var expr = context.environment.parse(bp.condition!);
        var result = expr.accept(this, context);
        if (result is bool && result) {
          shouldBreak = true;
          break;
        }
      }

      if (shouldBreak) {
        var info = BreakpointInfo(
          nodeType: node.runtimeType.toString(),
          variables: context.getAllVariables(),
          outputSoFar: context.outputSoFar,
          lineNumber: context.currentLine,
        );

        await context.debugController.handleBreakpoint(info);
      }
    }
  }

  @override
  void visitData(Data node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      _checkBreakpoint(node, context).then((_) {
        super.visitData(node, context);
      });
    } else {
      super.visitData(node, context);
    }
  }

  @override
  void visitInterpolation(Interpolation node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      _checkBreakpoint(node, context).then((_) {
        super.visitInterpolation(node, context);
      });
    } else {
      super.visitInterpolation(node, context);
    }
  }

  @override
  void visitFor(For node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      _checkBreakpoint(node, context).then((_) {
        super.visitFor(node, context);
      });
    } else {
      super.visitFor(node, context);
    }
  }

  @override
  void visitIf(If node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      _checkBreakpoint(node, context).then((_) {
        super.visitIf(node, context);
      });
    } else {
      super.visitIf(node, context);
    }
  }

  @override
  void visitAssign(Assign node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      _checkBreakpoint(node, context).then((_) {
        super.visitAssign(node, context);
      });
    } else {
      super.visitAssign(node, context);
    }
  }

  @override
  void visitBlock(Block node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      _checkBreakpoint(node, context).then((_) {
        super.visitBlock(node, context);
      });
    } else {
      super.visitBlock(node, context);
    }
  }
}
