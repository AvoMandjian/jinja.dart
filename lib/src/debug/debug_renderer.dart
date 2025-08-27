import 'dart:async';

import 'package:jinja/src/debug/debug_controller.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:jinja/src/runtime.dart';

/// Debug version of StringSinkRenderContext that tracks execution
base class DebugRenderContext extends StringSinkRenderContext {
  final DebugController debugController;
  final StringBuffer _outputBuffer = StringBuffer();
  int _currentLine = 0;
  bool _shouldStop = false;
  int _depth = 0;
  DebugAction _stepAction = DebugAction.continueExecution;

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
    var parent = withContext ? {...this.parent, ...context} : this.parent;
    return DebugRenderContext(
      environment,
      sink ?? this.sink,
      debugController: debugController,
      template: template ?? this.template,
      blocks: blocks,
      parent: parent,
      data: data,
    ).._depth = _depth;
  }

  @override
  void write(Object? value) {
    super.write(value);
    _outputBuffer.write(value);
  }

  String get outputSoFar => _outputBuffer.toString();

  void stopExecution() => _shouldStop = true;
  bool get shouldStop => _shouldStop;

  void setLine(int line) => _currentLine = line;
  int get currentLine => _currentLine;

  void stepIn() => _depth++;
  void stepOut() => _depth--;
  int get depth => _depth;

  void setStepAction(DebugAction action) => _stepAction = action;
  DebugAction get stepAction => _stepAction;

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

  Future<bool> _checkBreakpoint(Node node, DebugRenderContext context) async {
    if (node.line != null) {
      context.setLine(node.line!);
    }

    var breakpoints = context.debugController.getBreakpoints(context.currentLine);
    var stepBreak = context.stepAction == DebugAction.stepOver && context.depth <= 0 ||
        context.stepAction == DebugAction.stepIn;

    if (breakpoints.isNotEmpty || stepBreak) {
      var shouldBreak = stepBreak;
      if (!shouldBreak) {
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
      }

      if (shouldBreak) {
        var info = BreakpointInfo(
          nodeType: node.runtimeType.toString(),
          variables: context.getAllVariables(),
          outputSoFar: context.outputSoFar,
          lineNumber: context.currentLine,
        );

        var action = await context.debugController.handleBreakpoint(info);
        context.setStepAction(action);

        if (action == DebugAction.stop) {
          context.stopExecution();
          return false;
        }
      }
    }
    return true;
  }

  @override
  void visitData(Data node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      _checkBreakpoint(node, context).then((shouldContinue) {
        if (shouldContinue) {
          super.visitData(node, context);
        }
      });
    } else {
      super.visitData(node, context);
    }
  }

  @override
  void visitInterpolation(Interpolation node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      _checkBreakpoint(node, context).then((shouldContinue) {
        if (shouldContinue) {
          super.visitInterpolation(node, context);
        }
      });
    } else {
      super.visitInterpolation(node, context);
    }
  }

  @override
  void visitFor(For node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      _checkBreakpoint(node, context).then((shouldContinue) {
        if (shouldContinue) {
          super.visitFor(node, context);
        }
      });
    } else {
      super.visitFor(node, context);
    }
  }

  @override
  void visitIf(If node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      _checkBreakpoint(node, context).then((shouldContinue) {
        if (shouldContinue) {
          super.visitIf(node, context);
        }
      });
    } else {
      super.visitIf(node, context);
    }
  }

  @override
  void visitAssign(Assign node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      _checkBreakpoint(node, context).then((shouldContinue) {
        if (shouldContinue) {
          super.visitAssign(node, context);
        }
      });
    } else {
      super.visitAssign(node, context);
    }
  }

  @override
  void visitBlock(Block node, StringSinkRenderContext context) {
    if (context is DebugRenderContext) {
      _checkBreakpoint(node, context).then((shouldContinue) {
        if (shouldContinue) {
          super.visitBlock(node, context);
        }
      });
    } else {
      super.visitBlock(node, context);
    }
  }
}
