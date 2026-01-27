import 'nodes.dart';

/// Base class for all template errors.
abstract class TemplateError implements Exception {
  /// Creates a new [TemplateError].
  TemplateError(
    String? messageValue, {
    StackTrace? stackTraceValue,
    Node? nodeValue,
    Map<String, Object?>? contextSnapshotValue,
    String? operationValue,
    List<String>? suggestionsValue,
    String? templatePathValue,
    List<String>? callStackValue,
  })  : message = messageValue,
        stackTrace = stackTraceValue,
        node = nodeValue,
        contextSnapshot = contextSnapshotValue,
        operation = operationValue,
        suggestions = suggestionsValue,
        templatePath = templatePathValue,
        callStack = callStackValue;

  /// The error message.
  final String? message;

  /// The stack trace where the error occurred.
  final StackTrace? stackTrace;

  /// The AST node where the error occurred.
  final Node? node;

  /// Snapshot of variable context at the time of error (sanitized, max 50 variables).
  final Map<String, Object?>? contextSnapshot;

  /// Description of what operation was being performed when the error occurred.
  final String? operation;

  /// Actionable suggestions for fixing the error.
  final List<String>? suggestions;

  /// The path to the template where the error occurred.
  final String? templatePath;

  /// The rendering call stack (template -> macro -> include chain, max 10 frames).
  final List<String>? callStack;

  @override
  String toString() {
    var buffer = StringBuffer();

    // Error type name
    buffer.write(runtimeType);

    // Basic message
    if (message case var message?) {
      buffer.write(': $message');
    }

    // Location information
    if (templatePath case var templatePath?) {
      buffer.write('\n  Location: template \'$templatePath\'');
      if (node case var node?) {
        if (node.line case var line?) {
          buffer.write(', line $line');
        }
        if (node.column case var column?) {
          buffer.write(', column $column');
        }
      }
    } else if (node case var node?) {
      if (node.line case var line?) {
        buffer.write('\n  Location: line $line');
        if (node.column case var column?) {
          buffer.write(', column $column');
        }
      }
    }

    // Node information
    if (node case var node?) {
      buffer.write('\n  Node: ${_getNodeType(node)}');
    }

    // Operation context
    if (operation case var operation?) {
      buffer.write('\n  Operation: $operation');
    }

    // Context snapshot
    final context = contextSnapshot;
    if (context != null && context.isNotEmpty) {
      buffer.write('\n  Context:');
      var count = 0;
      for (var entry in context.entries) {
        if (count >= 10) {
          buffer.write('\n    ... and ${context.length - 10} more variables');
          break;
        }
        var value = entry.value;
        var valueStr = value == null
            ? 'null'
            : value.toString().length > 50
                ? '${value.toString().substring(0, 50)}...'
                : value.toString();
        buffer.write('\n    - Variable \'${entry.key}\': $valueStr');
        count++;
      }
    }

    // Call stack
    final callStackValue = callStack;
    if (callStackValue != null && callStackValue.isNotEmpty) {
      buffer.write('\n  Call Stack:');
      for (var i = 0; i < callStackValue.length && i < 10; i++) {
        buffer.write('\n    ${i + 1}. ${callStackValue[i]}');
      }
    }

    // Suggestions
    final suggestionsValue = suggestions;
    if (suggestionsValue != null && suggestionsValue.isNotEmpty) {
      buffer.write('\n  Suggestions:');
      for (var suggestion in suggestionsValue) {
        buffer.write('\n    - $suggestion');
      }
    }

    // Stack trace (limited to 10 frames)
    if (stackTrace case var stackTrace?) {
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

    return buffer.toString();
  }

  /// Get human-readable node type name.
  String _getNodeType(Node node) {
    var typeName = node.runtimeType.toString();
    // Remove common suffixes and make readable
    typeName = typeName.replaceAll('Node', '').replaceAll('Expression', '').replaceAll('Statement', '');
    if (typeName.isEmpty) {
      typeName = node.runtimeType.toString();
    }
    return typeName;
  }
}

/// Raised if a template does not exist.
class TemplateNotFound extends TemplateError {
  /// Creates a new [TemplateNotFound].
  TemplateNotFound({
    this.name,
    String? message,
    StackTrace? stackTrace,
    Node? node,
    Map<String, Object?>? contextSnapshot,
    String? operation,
    List<String>? suggestions,
    String? templatePath,
    List<String>? callStack,
    this.searchPaths,
  }) : super(
          message,
          stackTraceValue: stackTrace,
          nodeValue: node,
          contextSnapshotValue: contextSnapshot,
          operationValue: operation,
          suggestionsValue: suggestions,
          templatePathValue: templatePath,
          callStackValue: callStack,
        );

  /// The name of the template that was not found.
  final String? name;

  /// The paths that were searched for the template.
  final List<String>? searchPaths;

  @override
  String toString() {
    var buffer = StringBuffer('TemplateNotFound');

    if (message case var message?) {
      buffer.write(': $message');
    } else if (name case var name?) {
      buffer.write(': $name');
    }

    // Add template name
    if (name case var name?) {
      buffer.write('\n  Template name: \'$name\'');
    }

    // Add search paths
    final searchPathsValue = searchPaths;
    if (searchPathsValue != null && searchPathsValue.isNotEmpty) {
      buffer.write('\n  Searched paths:');
      for (var path in searchPathsValue) {
        buffer.write('\n    - $path');
      }
    }

    // Use base class enhanced toString() for remaining context
    var baseString = super.toString();
    if (baseString.startsWith('TemplateNotFound:')) {
      var remaining = baseString.substring('TemplateNotFound:'.length).trim();
      if (remaining.isNotEmpty) {
        buffer.write('\n$remaining');
      }
    } else {
      buffer.write('\n$baseString');
    }

    return buffer.toString();
  }
}

/// Like [TemplateNotFound], but raised if multiple templates are selected.
class TemplatesNotFound extends TemplateNotFound {
  /// Creates a new [TemplatesNotFound].
  TemplatesNotFound({this.names, super.message}) : super(name: names?.last);

  /// The names of the templates that were not found.
  final List<String>? names;

  @override
  String toString() {
    if (message case var message?) {
      return 'TemplatesNotFound: $message';
    }

    if (names case var names?) {
      return 'TemplatesNotFound: '
          'none of the templates given were found: '
          '${names.join(', ')}';
    }

    return 'TemplatesNotFound';
  }
}

/// Raised to tell the user that there is a problem with the template.
class TemplateSyntaxError extends TemplateError {
  /// Creates a new [TemplateSyntaxError].
  TemplateSyntaxError(
    super.message, {
    this.path,
    this.line,
    this.column,
    this.contextSnippet,
    StackTrace? stackTrace,
    Node? node,
    Map<String, Object?>? contextSnapshot,
    String? operation,
    List<String>? suggestions,
    String? templatePath,
    List<String>? callStack,
  }) : super(
          stackTraceValue: stackTrace,
          nodeValue: node,
          contextSnapshotValue: contextSnapshot,
          operationValue: operation,
          suggestionsValue: suggestions,
          templatePathValue: templatePath,
          callStackValue: callStack,
        );

  /// The path to the template that caused the error.
  final String? path;

  /// The line in the template that caused the error.
  final int? line;

  /// The column in the template that caused the error.
  final int? column;

  /// Optional snippet of template source with caret.
  final String? contextSnippet;

  @override
  String toString() {
    var buffer = StringBuffer('TemplateSyntaxError');

    // Use path from this class or templatePath from base class
    final effectivePath = path ?? templatePath;
    if (effectivePath case var effectivePath?) {
      buffer
        ..write(", file '")
        ..write(effectivePath)
        ..write("'");
    }

    // Use line/column from this class or node from base class
    final effectiveLine = line ?? node?.line;
    final effectiveColumn = column ?? node?.column;

    if (effectiveLine case var effectiveLine?) {
      buffer
        ..write(', line ')
        ..write(effectiveLine);
    }

    if (effectiveColumn case var effectiveColumn?) {
      buffer
        ..write(', column ')
        ..write(effectiveColumn);
    }

    if (message case var message?) {
      buffer
        ..write(': ')
        ..write(message);
    }

    // Add node information if available
    if (node case var node?) {
      buffer.write('\n  Node: ${_getNodeType(node)}');
    }

    // Add operation context
    if (operation case var operation?) {
      buffer.write('\n  Operation: $operation');
    }

    // Add context snippet (parser-specific)
    if (contextSnippet case var snippet?) {
      buffer
        ..write('\n')
        ..write(snippet);
    }

    // Add context snapshot
    final context = contextSnapshot;
    if (context != null && context.isNotEmpty) {
      buffer.write('\n  Context:');
      var count = 0;
      for (var entry in context.entries) {
        if (count >= 10) {
          buffer.write('\n    ... and ${context.length - 10} more variables');
          break;
        }
        var value = entry.value;
        var valueStr = value == null
            ? 'null'
            : value.toString().length > 50
                ? '${value.toString().substring(0, 50)}...'
                : value.toString();
        buffer.write('\n    - Variable \'${entry.key}\': $valueStr');
        count++;
      }
    }

    // Add suggestions
    final suggestionsValue = suggestions;
    if (suggestionsValue != null && suggestionsValue.isNotEmpty) {
      buffer.write('\n  Suggestions:');
      for (var suggestion in suggestionsValue) {
        buffer.write('\n    - $suggestion');
      }
    }

    // Add call stack
    final callStackValue = callStack;
    if (callStackValue != null && callStackValue.isNotEmpty) {
      buffer.write('\n  Call Stack:');
      for (var i = 0; i < callStackValue.length && i < 10; i++) {
        buffer.write('\n    ${i + 1}. ${callStackValue[i]}');
      }
    }

    // Add stack trace (limited)
    if (stackTrace case var stackTrace?) {
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

    return buffer.toString();
  }
}

/// Like a [TemplateSyntaxError], but covers cases where something in the
/// template caused an error at parsing time that wasn't necessarily caused
/// by a syntax error.
class TemplateAssertionError extends TemplateError {
  /// Creates a new [TemplateAssertionError].
  TemplateAssertionError(
    super.message, {
    super.stackTraceValue,
    super.nodeValue,
    super.contextSnapshotValue,
    super.operationValue,
    super.suggestionsValue,
    super.templatePathValue,
    super.callStackValue,
  });

  @override
  String toString() {
    // Use base class enhanced toString()
    return super.toString();
  }
}

/// A generic runtime error in the template engine.
///
/// Under some situations Jinja may raise this exception.
class TemplateRuntimeError extends TemplateError {
  /// Creates a new [TemplateRuntimeError].
  TemplateRuntimeError(
    super.message, {
    super.stackTraceValue,
    super.nodeValue,
    super.contextSnapshotValue,
    super.operationValue,
    super.suggestionsValue,
    super.templatePathValue,
    super.callStackValue,
  });

  @override
  String toString() {
    // Use base class enhanced toString()
    return super.toString();
  }
}

/// Raised if a variable is undefined.
class UndefinedError extends TemplateRuntimeError {
  /// Creates a new [UndefinedError].
  UndefinedError(
    super.message, {
    super.stackTraceValue,
    super.nodeValue,
    super.contextSnapshotValue,
    super.operationValue,
    super.suggestionsValue,
    super.templatePathValue,
    super.callStackValue,
    String? variableNameValue,
    List<String>? similarNamesValue,
  })  : variableName = variableNameValue,
        similarNames = similarNamesValue;

  /// The name of the undefined variable.
  final String? variableName;

  /// Similar variable names found (for typo detection).
  final List<String>? similarNames;

  @override
  String toString() {
    var buffer = StringBuffer('UndefinedError');

    if (message case var message?) {
      buffer.write(': $message');
    }

    // Add variable name if available
    if (variableName case var variableName?) {
      buffer.write('\n  Variable: \'$variableName\'');
    }

    // Add similar names for typo detection
    final similarNamesValue = similarNames;
    if (similarNamesValue != null && similarNamesValue.isNotEmpty) {
      buffer.write('\n  Similar variables found: ${similarNamesValue.join(', ')}');
    }

    // Use base class enhanced toString() for remaining context
    var baseString = super.toString();
    // Remove the "UndefinedError:" prefix if we already added it
    if (baseString.startsWith('UndefinedError:')) {
      var remaining = baseString.substring('UndefinedError:'.length).trim();
      if (remaining.isNotEmpty) {
        buffer.write('\n$remaining');
      }
    } else {
      buffer.write('\n$baseString');
    }

    return buffer.toString();
  }
}

/// Wraps non-template exceptions (Dart exceptions) with full Jinja context.
class TemplateErrorWrapper extends TemplateRuntimeError {
  /// Creates a new [TemplateErrorWrapper].
  TemplateErrorWrapper(
    this.originalError, {
    String? message,
    StackTrace? stackTrace,
    Node? node,
    Map<String, Object?>? contextSnapshot,
    String? operation,
    List<String>? suggestions,
    String? templatePath,
    List<String>? callStack,
  }) : super(
          message ?? 'Non-template error occurred during template rendering',
          stackTraceValue: stackTrace ?? (originalError is Error ? originalError.stackTrace : null),
          nodeValue: node,
          contextSnapshotValue: contextSnapshot,
          operationValue: operation,
          suggestionsValue: suggestions,
          templatePathValue: templatePath,
          callStackValue: callStack,
        );

  /// The original non-template exception that was wrapped.
  final dynamic originalError;

  @override
  String toString() {
    var buffer = StringBuffer('TemplateErrorWrapper');

    buffer.write(': ${originalError.runtimeType}');
    if (message case var message?) {
      buffer.write(' - $message');
    }

    buffer.write('\n  Original Error: $originalError');

    // Use base class enhanced toString() for context
    var baseString = super.toString();
    if (baseString.startsWith('TemplateErrorWrapper:')) {
      var remaining = baseString.substring('TemplateErrorWrapper:'.length).trim();
      if (remaining.isNotEmpty && !remaining.contains('Original Error:')) {
        buffer.write('\n$remaining');
      }
    } else {
      buffer.write('\n$baseString');
    }

    return buffer.toString();
  }
}

/// Used internally for break statements in loops.
class BreakException implements Exception {}

/// Used internally for continue statements in loops.
class ContinueException implements Exception {}
