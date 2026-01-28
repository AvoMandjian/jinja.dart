import 'dart:async';

/// Action to take after a breakpoint is hit.
enum DebugAction {
  /// Continue execution until the next breakpoint.
  resume,

  /// Step over the current statement (execute without entering nested calls).
  stepOver,

  /// Step into the current statement (enter nested calls).
  stepIn,

  /// Step out of the current frame (finish current block/macro and return).
  stepOut,

  /// Stop execution immediately.
  stop,
}

/// Represents a node in the performance profile.
class ProfileNode {
  final String name;
  Duration totalDuration;
  int count;

  ProfileNode({
    required this.name,
    this.totalDuration = Duration.zero,
    this.count = 0,
  });

  void addSample(Duration duration) {
    totalDuration += duration;
    count++;
  }

  double get averageDurationMs => count == 0 ? 0 : totalDuration.inMicroseconds / count / 1000.0;

  Map<String, dynamic> toJson() => {
        'name': name,
        'totalDurationMs': totalDuration.inMicroseconds / 1000.0,
        'count': count,
        'averageDurationMs': averageDurationMs,
      };
}

/// Represents a frame in the call stack during template execution.
class StackFrame {
  final String name;
  final int line;
  final Map<String, Object?> variables;

  StackFrame({
    required this.name,
    required this.line,
    Map<String, Object?>? variables,
  }) : variables = variables ?? {};

  Map<String, dynamic> toJson() => {
        'name': name,
        'line': line,
        'variables': variables,
      };
}

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
  final List<String> availableFilters;
  final List<String> availableTests;
  final List<StackFrame> callStack;

  BreakpointInfo({
    required this.nodeType,
    required this.variables,
    required this.outputSoFar,
    this.currentOutput = '',
    required this.lineNumber,
    this.nodeName,
    this.nodeData,
    this.availableFilters = const [],
    this.availableTests = const [],
    this.callStack = const [],
  });

  Map<String, dynamic> toJson() => {
        'nodeType': nodeType,
        'variables': variables,
        'outputSoFar': outputSoFar,
        'currentOutput': currentOutput,
        'lineNumber': lineNumber,
        'nodeName': nodeName,
        'nodeData': nodeData?.toString(),
        'availableFilters': availableFilters,
        'availableTests': availableTests,
        'callStack': callStack.map((f) => f.toJson()).toList(),
      };
}

/// Controller for debugging Jinja templates.
class DebugController {
  final Map<int, List<Breakpoint>> _breakpoints = {};
  final List<BreakpointInfo> _history = [];

  /// Callback when a breakpoint is hit.
  /// Returns the action to take after the breakpoint.
  Future<DebugAction> Function(BreakpointInfo info)? onBreakpoint;

  /// Whether debugging is enabled.
  bool _enabled = false;
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  /// Whether to break on each iteration of a for loop.
  /// Defaults to false.
  bool breakOnLoopIteration = false;

  /// Current stepping mode.
  DebugAction? _stepMode;

  /// Depth at which to step (for stepOver/stepOut).
  int _stepDepth = 0;

  /// Pending state updates to apply.
  Map<String, Object?>? _pendingStateUpdates;

  /// Profiling data.
  final Map<String, ProfileNode> _profileData = {};

  /// Active timers.
  final Map<String, Stopwatch> _timers = {};

  /// Get the current step mode.
  DebugAction? get stepMode => _stepMode;

  /// Get the current step depth.
  int get stepDepth => _stepDepth;

  /// Get the profile data.
  Map<String, ProfileNode> get profileData => Map.unmodifiable(_profileData);

  /// Set the step mode and depth.
  void setStepMode(DebugAction action, int depth) {
    _stepMode = action;
    _stepDepth = depth;
  }

  /// Clear the step mode.
  void clearStepMode() {
    _stepMode = null;
    _stepDepth = 0;
  }

  /// Update a variable in the current context.
  /// This change will be applied when execution resumes.
  void updateVariable(String name, Object? value) {
    _pendingStateUpdates ??= {};
    _pendingStateUpdates![name] = value;
  }

  /// Get and clear pending state updates.
  Map<String, Object?>? popPendingStateUpdates() {
    var updates = _pendingStateUpdates;
    _pendingStateUpdates = null;
    return updates;
  }

  /// Start a timer for profiling.
  void startTimer(String label) {
    if (!_enabled) return;
    _timers[label] = Stopwatch()..start();
  }

  /// Stop a timer and record profiling data.
  void stopTimer(String label) {
    if (!_enabled) return;
    var stopwatch = _timers.remove(label);
    if (stopwatch != null) {
      stopwatch.stop();
      _profileData.putIfAbsent(label, () => ProfileNode(name: label)).addSample(stopwatch.elapsed);
    }
  }

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
  /// Returns the action to take after the breakpoint.
  Future<DebugAction> handleBreakpoint(BreakpointInfo info) async {
    _history.add(info);

    if (onBreakpoint != null) {
      // Pause timers while waiting for user input
      var pausedTimers = <String, Stopwatch>{};
      _timers.forEach((key, stopwatch) {
        if (stopwatch.isRunning) {
          stopwatch.stop();
          pausedTimers[key] = stopwatch;
        }
      });

      try {
        var action = await onBreakpoint!(info);
        // Update step mode if action is a stepping action
        if (action == DebugAction.stepOver || action == DebugAction.stepIn || action == DebugAction.stepOut) {
          _stepMode = action;
        } else if (action == DebugAction.resume) {
          clearStepMode();
        }
        return action;
      } finally {
        // Resume timers
        pausedTimers.forEach((key, stopwatch) {
          stopwatch.start();
        });
      }
    }

    // Default to resume if no callback
    return DebugAction.resume;
  }

  /// Get the history of breakpoint hits.
  List<BreakpointInfo> get history => List.unmodifiable(_history);

  /// Clear the history.
  void clearHistory() {
    _history.clear();
  }

  /// Clear profile data.
  void clearProfileData() {
    _profileData.clear();
    _timers.clear();
  }

  /// Reset the controller.
  void reset() {
    clearHistory();
    clearStepMode();
    clearProfileData();
    _pendingStateUpdates = null;
  }
}
