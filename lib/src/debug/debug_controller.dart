import 'dart:async';

/// Represents a breakpoint in a template.
class Breakpoint {
  static int _idCounter = 0;
  final int id;
  final int line;
  final String? condition;

  Breakpoint({required this.line, this.condition}) : id = _idCounter++;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Breakpoint && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Information about a breakpoint hit.
class BreakpointInfo {
  final String nodeType;
  final Map<String, Object?> variables;
  final String outputSoFar;
  final String currentOutput;
  final int lineNumber;
  final String? nodeName;
  final dynamic nodeData;

  BreakpointInfo({
    required this.nodeType,
    required this.variables,
    required this.outputSoFar,
    this.currentOutput = '',
    required this.lineNumber,
    this.nodeName,
    this.nodeData,
  });

  Map<String, dynamic> toJson() => {
        'nodeType': nodeType,
        'variables': variables,
        'outputSoFar': outputSoFar,
        'currentOutput': currentOutput,
        'lineNumber': lineNumber,
        'nodeName': nodeName,
        'nodeData': nodeData?.toString(),
      };
}

/// Enum representing the next action to take in the debugger.
enum DebugAction {
  /// Continue execution until the next breakpoint is hit.
  continue_,

  /// Stop the current execution and return the results so far.
  stop,

  /// Step over the current line, hitting only breakpoints on other lines.
  stepOver,

  /// Step into the current node (not yet fully implemented in Jinja.dart).
  stepIn,

  /// Step out of the current context (not yet fully implemented in Jinja.dart).
  stepOut,
}

/// Controller for debugging Jinja templates.
class DebugController {
  final Map<int, List<Breakpoint>> _breakpoints = {};
  final List<BreakpointInfo> _history = [];

  /// Callback when a breakpoint is hit.
  Future<DebugAction> Function(BreakpointInfo info)? onBreakpoint;

  /// Whether debugging is enabled.
  bool enabled = false;

  /// Whether to stop the current execution.
  bool stopped = false;

  /// The current step-over line, if any.
  int? stepOverLine;

  /// Whether to break on each iteration of a for loop.
  /// Defaults to false.
  bool breakOnLoopIteration = false;

  /// Adds a breakpoint.
  Breakpoint addBreakpoint({required int line, String? condition}) {
    var breakpoint = Breakpoint(line: line, condition: condition);
    _breakpoints.putIfAbsent(line, () => []).add(breakpoint);
    return breakpoint;
  }

  /// Removes a breakpoint.
  void removeBreakpoint(Breakpoint breakpoint) {
    _breakpoints[breakpoint.line]?.remove(breakpoint);
    if (_breakpoints[breakpoint.line]?.isEmpty ?? false) {
      _breakpoints.remove(breakpoint.line);
    }
  }

  /// Clear all breakpoints.
  void clearBreakpoints() {
    _breakpoints.clear();
  }

  /// Returns all breakpoints for a given line.
  List<Breakpoint> getBreakpoints(int line) {
    return _breakpoints[line] ?? [];
  }

  /// Handle a breakpoint hit.
  Future<DebugAction> handleBreakpoint(BreakpointInfo info) async {
    _history.add(info);

    if (onBreakpoint != null) {
      final action = await onBreakpoint!(info);
      if (action == DebugAction.stop) {
        stopped = true;
      } else if (action == DebugAction.stepOver) {
        stepOverLine = info.lineNumber;
      }
      return action;
    }
    return DebugAction.continue_;
  }

  /// Get the history of breakpoint hits.
  List<BreakpointInfo> get history => List.unmodifiable(_history);

  /// Clear the history.
  void clearHistory() {
    _history.clear();
  }

  /// Reset the controller.
  void reset() {
    clearHistory();
    stopped = false;
    stepOverLine = null;
  }
}
