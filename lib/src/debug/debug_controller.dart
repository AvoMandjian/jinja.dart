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

/// Controller for debugging Jinja templates.
class DebugController {
  final Map<int, List<Breakpoint>> _breakpoints = {};
  final List<BreakpointInfo> _history = [];

  /// Callback when a breakpoint is hit.
  Future<void> Function(BreakpointInfo info)? onBreakpoint;

  /// Whether debugging is enabled.
  bool _enabled = false;
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

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
  Future<void> handleBreakpoint(BreakpointInfo info) async {
    _history.add(info);

    if (onBreakpoint != null) {
      await onBreakpoint!(info);
    }
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
  }
}
