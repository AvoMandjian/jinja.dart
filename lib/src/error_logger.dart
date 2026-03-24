/// Log levels for error logging.
enum LogLevel {
  /// No logging (zero overhead).
  none,

  /// Only log errors.
  error,

  /// Log errors and warnings.
  warning,

  /// Log errors, warnings, and info messages.
  info,

  /// Log everything including debug information.
  debug,
}

/// Structured error logger for Jinja template engine.
///
/// Provides configurable logging with different log levels. When logging is
/// disabled (level = none), there is zero overhead.
class ErrorLogger {
  /// Creates a new [ErrorLogger].
  ErrorLogger({this.level = LogLevel.error});

  /// The current log level.
  LogLevel level;

  /// Sets the log level.
  void setLogLevel(LogLevel newLevel) {
    level = newLevel;
  }

  /// Checks if logging is enabled for the given level.
  bool isEnabled(LogLevel checkLevel) {
    if (level == LogLevel.none) {
      return false;
    }

    // Map levels to numeric values for comparison
    final levelValues = {
      LogLevel.none: 0,
      LogLevel.error: 1,
      LogLevel.warning: 2,
      LogLevel.info: 3,
      LogLevel.debug: 4,
    };

    return levelValues[level]! >= levelValues[checkLevel]!;
  }

  /// Logs an error-level message.
  void logError(
    String message, {
    Object? error,
    Map<String, Object?>? context,
    StackTrace? stackTrace,
  }) {
    if (!isEnabled(LogLevel.error)) {
      return;
    }

    _log('ERROR', message,
        error: error, context: context, stackTrace: stackTrace);
  }

  /// Logs a warning-level message.
  void logWarning(
    String message, {
    Map<String, Object?>? context,
  }) {
    if (!isEnabled(LogLevel.warning)) {
      return;
    }

    _log('WARNING', message, context: context);
  }

  /// Logs an info-level message.
  void logInfo(
    String message, {
    Map<String, Object?>? context,
  }) {
    if (!isEnabled(LogLevel.info)) {
      return;
    }

    _log('INFO', message, context: context);
  }

  /// Logs a debug-level message.
  void logDebug(
    String message, {
    Map<String, Object?>? context,
  }) {
    if (!isEnabled(LogLevel.debug)) {
      return;
    }

    _log('DEBUG', message, context: context);
  }

  /// Internal logging method.
  void _log(
    String level,
    String message, {
    Object? error,
    Map<String, Object?>? context,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer();
    buffer.write('[$level] $message');

    if (error != null) {
      buffer.write('\n  Error: $error');
    }

    if (context != null && context.isNotEmpty) {
      buffer.write('\n  Context:');
      var count = 0;
      for (var entry in context.entries) {
        if (count >= 10) {
          buffer.write('\n    ... and ${context.length - 10} more entries');
          break;
        }
        var value = entry.value;
        var valueStr = value == null
            ? 'null'
            : value.toString().length > 50
                ? '${value.toString().substring(0, 50)}...'
                : value.toString();
        buffer.write('\n    - ${entry.key}: $valueStr');
        count++;
      }
    }

    if (stackTrace != null) {
      buffer.write('\n  Stack Trace:');
      var lines = stackTrace.toString().split('\n');
      var frameCount = 0;
      for (var line in lines) {
        if (frameCount >= 10) break;
        if (line.trim().isNotEmpty) {
          buffer.write('\n    $line');
          frameCount++;
        }
      }
      if (lines.length > 10) {
        buffer.write('\n    ... and ${lines.length - 10} more frames');
      }
    }

    print(buffer.toString());
  }
}
