import 'dart:async';

/// Debug action that can be taken when a breakpoint is hit
enum DebugAction {
  /// Continue execution
  continueExecution,

  /// Stop execution
  stop,

  /// Restart from beginning with potentially new template
  restart,
}

/// Information about a breakpoint hit
class BreakpointInfo {
  final String nodeType;
  final Map<String, Object?> variables;
  final String outputSoFar;
  final int lineNumber;
  final String? nodeName;
  final dynamic nodeData;

  BreakpointInfo({
    required this.nodeType,
    required this.variables,
    required this.outputSoFar,
    required this.lineNumber,
    this.nodeName,
    this.nodeData,
  });

  Map<String, dynamic> toJson() => {
        'nodeType': nodeType,
        'variables': variables,
        'outputSoFar': outputSoFar,
        'lineNumber': lineNumber,
        'nodeName': nodeName,
        'nodeData': nodeData?.toString(),
      };
}

/// Controller for debugging Jinja templates
class DebugController {
  final Set<String> _breakpointNodeTypes = {};
  final Set<int> _breakpointLines = {};
  final List<BreakpointInfo> _history = [];

  /// Callback when a breakpoint is hit
  Future<DebugAction> Function(BreakpointInfo info)? onBreakpoint;

  /// Whether debugging is enabled
  bool _enabled = false;
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  /// Add a breakpoint for a specific node type
  void addNodeBreakpoint(String nodeType) {
    _breakpointNodeTypes.add(nodeType);
  }

  /// Remove a breakpoint for a specific node type
  void removeNodeBreakpoint(String nodeType) {
    _breakpointNodeTypes.remove(nodeType);
  }

  /// Add a breakpoint at a specific line
  void addLineBreakpoint(int line) {
    _breakpointLines.add(line);
  }

  /// Remove a breakpoint at a specific line
  void removeLineBreakpoint(int line) {
    _breakpointLines.remove(line);
  }

  /// Clear all breakpoints
  void clearBreakpoints() {
    _breakpointNodeTypes.clear();
    _breakpointLines.clear();
  }

  /// Check if we should break at this node
  bool shouldBreak(String nodeType, int lineNumber) {
    if (!_enabled) return false;
    return _breakpointNodeTypes.contains(nodeType) || _breakpointLines.contains(lineNumber);
  }
  
  /// Check if there's a line breakpoint at the given line
  bool hasLineBreakpoint(int lineNumber) {
    return _breakpointLines.contains(lineNumber);
  }
  
  /// Check if there's a node breakpoint for the given type
  bool hasNodeBreakpoint(String nodeType) {
    return _breakpointNodeTypes.contains(nodeType);
  }

  /// Handle a breakpoint hit
  Future<DebugAction> handleBreakpoint(BreakpointInfo info) async {
    _history.add(info);

    if (onBreakpoint != null) {
      return await onBreakpoint!(info);
    }

    // Default to continue if no handler
    return DebugAction.continueExecution;
  }

  /// Get the history of breakpoint hits
  List<BreakpointInfo> get history => List.unmodifiable(_history);

  /// Clear the history
  void clearHistory() {
    _history.clear();
  }

  /// Reset the controller
  void reset() {
    clearHistory();
  }
}
