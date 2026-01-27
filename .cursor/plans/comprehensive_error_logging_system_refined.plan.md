---
name: ""
overview: ""
todos: []
isProject: false
---

# Comprehensive Error Logging System for Jinja - Refined Plan

## Overview

Add extensive error logging and debugging capabilities throughout the Jinja library to help identify what caused errors, where they occurred, and how to fix them. This implementation combines **enhanced exception classes with rich context** and an **ErrorLogger class for structured logging**, ensuring zero overhead when logging is disabled and comprehensive detail when enabled.

## Key Design Decisions

Based on review feedback:

1. **Enhanced Exceptions + Logging**: Enhanced exceptions contain all information; ErrorLogger provides structured logging
2. **Extend Existing Classes**: Backward compatible enhancement of current exception hierarchy
3. **Full Detail**: Performance is acceptable; capture comprehensive context
4. **Debug Integration**: Work with existing `lib/debug.dart` debug system
5. **Context Limits**: Prevent memory issues with size constraints
6. **Configurable Logging**: ErrorLogger supports multiple log levels and can be disabled

## Architecture

### 1. Enhanced Exception Classes (`lib/src/exceptions.dart`)

**Extend existing exception classes with additional context fields:**

```dart
abstract class TemplateError implements Exception {
  TemplateError([this.message]);
  
  final String? message;
  
  // NEW: Enhanced context fields
  final StackTrace? stackTrace;
  final Node? node;                    // AST node where error occurred
  final Map<String, Object?>? contextSnapshot;  // Variable state at error
  final String? operation;              // What operation was being performed
  final List<String>? suggestions;      // Actionable fix suggestions
  final String? templatePath;           // Template path (if available)
  final List<String>? callStack;         // Rendering call stack
  
  // Enhanced toString() with all context
}
```

**Enhance all exception types:**

- `TemplateSyntaxError` - Already has path/line/column, add node and suggestions
- `TemplateRuntimeError` - Add all context fields
- `UndefinedError` - Add variable name, similar names, context
- `TemplateNotFound` - Add search paths, loader information
- `TemplateAssertionError` - Add node and operation context

**New exception wrapper:**

- `TemplateErrorWrapper` - Wraps non-template exceptions (Dart exceptions) with full Jinja context

### 2. Error Logger (`lib/src/error_logger.dart`)

**Create new file with logging utilities:**

- `ErrorLogger` class with configurable log levels (none, error, warning, info, debug)
- `logError()` method for structured error logging
- `logWarning()` method for warning-level messages
- `logInfo()` method for informational messages
- `logDebug()` method for debug-level messages
- `setLogLevel()` method to configure logging level
- `isEnabled()` method to check if logging is enabled for a level
- Integration with enhanced exceptions for automatic logging

**Log Levels:**

- `none` - No logging (zero overhead)
- `error` - Only log errors (default)
- `warning` - Log errors and warnings
- `info` - Log errors, warnings, and info messages
- `debug` - Log everything including debug information

**Features:**

- Structured logging with error categorization
- Automatic logging when enhanced exceptions are created (if enabled)
- Configurable output (can be extended to support different backends)
- Performance: Zero overhead when logging is disabled
- Thread-safe logging (if needed for async operations)

**Usage Pattern:**

```dart
// In Environment or globally
final errorLogger = ErrorLogger(level: LogLevel.error);

// Automatic logging when exceptions are created
throw TemplateRuntimeError('...') // Automatically logged if level >= error

// Manual logging
errorLogger.logError('Custom error message', error: exception);
errorLogger.logWarning('Deprecated filter usage', context: {...});
```

### 3. Error Context Utilities (`lib/src/utils.dart`)

**Add context capture helper functions:**

- `captureContext(Context context, {int maxVariables = 50, int maxSize = 10240})` - Safely capture context state with size limits
- `sanitizeForLogging(Map<String, Object?> context)` - Remove sensitive data (password, secret, token, key patterns)
- `getNodeType(Node node)` - Get human-readable node type name
- `formatErrorReport(TemplateError error)` - Format comprehensive error report
- `getSimilarNames(String name, Iterable<String> available, {int maxResults = 5})` - Fuzzy match variable names for suggestions
- `captureCallStack({int maxDepth = 10})` - Capture rendering call stack
- `getErrorSuggestions(TemplateError error)` - Generate actionable suggestions based on error type

**Context Size Limits:**

- Maximum 50 variables in context snapshot
- Maximum 10KB total context size
- Maximum 10 stack frames
- Sensitive data patterns: `password`, `secret`, `token`, `key`, `api_key`, `auth`

### 4. Enhanced Error Context in Renderer (`lib/src/renderer.dart`)

**Add error wrapping helper method:**

```dart
TemplateError _wrapWithContext(
  dynamic error,
  Node? node,
  StringSinkRenderContext context,
  String operation,
) {
  // Capture context, wrap error, add suggestions
}
```

**Wrap all visitor methods with error context:**

Key methods to enhance (all `visit`* methods):

- `visitAttribute()` - attribute access errors
- `visitCall()` - function call errors  
- `visitFilter()` - filter application errors
- `visitName()` - variable resolution errors
- `visitItem()` - item access errors
- `visitFor()` - loop iteration errors
- `visitIf()` - condition evaluation errors
- `visitMacro()` - macro call errors
- `visitInclude()` - template inclusion errors
- `visitImport()` - template import errors
- `visitSlice()` - slice operation errors
- All other visitor methods

**Pattern for wrapping:**

```dart
@override
Object? visitAttribute(Attribute node, StringSinkRenderContext context) {
  try {
    var value = node.value.accept(this, context);
    return context.attribute(node.attribute, value, node);
  } catch (error, stackTrace) {
    throw _wrapWithContext(
      error,
      node,
      context,
      "Accessing attribute '${node.attribute}'",
    );
  }
}
```

### 5. Enhanced Error Context in Runtime (`lib/src/runtime.dart`)

**Add error context to runtime operations:**

- `resolve()` - Wrap with variable name, template path, similar names
- `call()` - Wrap with function name, arguments, argument types
- `attribute()` - Wrap with attribute name, object type, available attributes
- `item()` - Wrap with key, object type, available keys/indices
- `filter()` - Wrap with filter name, arguments
- `test()` - Wrap with test name, arguments

**Pattern:**

```dart
Object? resolve(String name) {
  try {
    // existing logic
  } catch (error, stackTrace) {
    if (error is TemplateError) {
      // Enhance existing error
      return _enhanceError(error, name, template);
    }
    // Wrap non-template error
    throw _wrapRuntimeError(error, stackTrace, "Resolving variable '$name'", template);
  }
}
```

### 6. Enhanced Error Messages in Defaults (`lib/src/defaults.dart`)

**Enhance error messages with detailed context:**

- `getAttribute()` - Include object type, attribute name, available attributes, suggestions
- `getItem()` - Include object type, key type, available keys/indices, suggestions  
- `undefined()` - Include variable name, template path, similar variable names (fuzzy matching), suggestions

**Example enhancement:**

```dart
Object? getAttribute(String attribute, Object? object, {Object? node}) {
  if (object == null) {
    var error = UndefinedError('Cannot access attribute `$attribute` on a null object.');
    // Add context: node, available attributes, suggestions
    return error;
  }
  // ... rest of logic with enhanced errors
}
```

### 7. Enhanced Error Context in Environment (`lib/src/environment.dart`)

**Add error logging configuration:**

- `errorLogger` property (ErrorLogger?) - Optional error logger instance
- `errorLogLevel` property (LogLevel) - Log level for error logging
- Constructor parameters for error logging configuration
- Automatic error logging when exceptions are thrown (if logger configured)

**Enhance filter/test error handling:**

- `callFilter()` - Already has some logging (lines 381-384, 395-399), enhance with context
- `callTest()` - Already has some logging (lines 431-434), enhance with context
- `callCommon()` - Add error context
- `getTemplate()` - Add template search context

**Replace existing print statements with enhanced exceptions:**

- Remove `print()` statements
- Wrap errors with full context before rethrowing
- Add filter/test name, argument types, argument values (sanitized)

### 8. Enhanced Error Context in Parser (`lib/src/parser.dart`)

**Improve parser error messages:**

- Enhance `fail()` method to include AST node information
- Add suggestions for common syntax mistakes
- Include surrounding template context (already has `contextSnippet`)
- Add template path to all syntax errors

### 9. Debug System Integration (`lib/debug.dart`)

**Integrate with existing debug system:**

- Review `DebugController` and `DebugEnvironment` 
- Add error events to debug system (if applicable)
- Ensure enhanced errors work with debug renderers
- Document debug mode error behavior

### 10. Async Renderer Error Handling (`lib/src/renderer.dart`)

**Enhance async error handling:**

- Wrap async operations with error context
- Capture async call stack information
- Enhance async filter call errors (replace existing print statements)
- Wrap Future resolution errors with context

## Implementation Details

### Error Context Capture

When an error occurs, capture:

1. **Node Information**: Type, line, column, AST path
2. **Template Context**: Path, current template, parent templates (call stack)
3. **Variable Context**: Current variables (sanitized, max 50), parent variables
4. **Operation Context**: What operation was being performed
5. **Call Stack**: Rendering call stack (template -> macro -> include chain, max 10 frames)
6. **Error Details**: Original error, stack trace, error type
7. **Suggestions**: Actionable fix suggestions based on error type

### Error Message Format

Enhanced `toString()` output:

```
TemplateRuntimeError: [Operation] failed
  Location: template 'path/to/template.html', line 42, column 15
  Node: Attribute (user.name)
  Operation: Accessing attribute 'name' on null object
  Context: 
    - Template: 'path/to/template.html'
    - Variable 'user': null
    - Available variables: ['users', 'userList', 'currentUser']
  Call Stack:
    1. template.html:42 (main template)
    2. macro.html:15 (macro 'renderUser')
  Suggestions:
    - Check if 'user' is defined before accessing 'name': {% if user %}{{ user.name }}{% endif %}
    - Verify the variable name spelling (did you mean 'users' or 'currentUser'?)
    - Ensure 'user' is passed to the template context
  Stack Trace:
    [formatted stack trace, max 10 frames]
```

### Context Size Limits

- **Variables**: Maximum 50 variables in context snapshot
- **Total Size**: Maximum 10KB total context size (truncate if exceeded)
- **Stack Frames**: Maximum 10 frames in call stack
- **Sensitive Data**: Automatically exclude keys matching patterns: `*password`*, `*secret`*, `*token*`, `*key*`, `*api_key*`, `*auth*`

### Backward Compatibility

- All changes are **additive** - existing code continues to work
- Existing exception classes extended, not replaced
- `toString()` methods enhanced but remain compatible
- No breaking API changes
- Default behavior: enhanced errors with full context

## Files to Modify

1. `lib/src/exceptions.dart` - Enhance exception classes with context fields
2. `lib/src/error_logger.dart` - **NEW FILE** - Error logging utility class
3. `lib/src/utils.dart` - Add error context helper functions
4. `lib/src/renderer.dart` - Add error wrapping to all visitor methods
5. `lib/src/runtime.dart` - Add error context to runtime operations
6. `lib/src/defaults.dart` - Enhance error messages with context
7. `lib/src/environment.dart` - Add error logger config, replace print statements, enhance error handling
8. `lib/src/parser.dart` - Enhance parser error messages
9. `lib/debug.dart` - Review and document debug integration (if changes needed)

## Testing Strategy

### Unit Tests

**Exception Enhancement:**

- Test enhanced exception fields are populated correctly
- Test `toString()` output format
- Test context capture with various data types
- Test context size limits (truncation)
- Test sensitive data sanitization

**Error Logger:**

- Test `ErrorLogger` with different log levels
- Test `logError()`, `logWarning()`, `logInfo()`, `logDebug()` methods
- Test automatic logging when exceptions are created
- Test zero overhead when logging is disabled (logLevel = none)
- Test log level filtering (only log appropriate levels)

**Context Utilities:**

- Test `captureContext()` with various context sizes
- Test `sanitizeForLogging()` with sensitive data patterns
- Test `getSimilarNames()` fuzzy matching
- Test `formatErrorReport()` output
- Test `getErrorSuggestions()` for different error types

### Integration Tests

**Error Scenarios:**

- Undefined variable errors with context
- Attribute access errors on null objects
- Filter errors with argument context
- Template not found errors with search paths
- Syntax errors with enhanced context
- Macro call errors with call stack
- Include/import errors with template chain

**Edge Cases:**

- Null contexts
- Empty contexts
- Very large contexts (test truncation)
- Circular references in context
- Sensitive data in context
- Deep call stacks (test truncation)
- Missing node information

### Performance Tests

- Measure context capture overhead
- Measure exception creation overhead
- Measure `toString()` performance with large contexts
- Verify zero overhead when no errors occur

### Test Coverage Goals

- **Success paths**: No errors (existing tests should pass)
- **Error paths**: All error types with enhanced context
- **Edge cases**: Null, empty, large, sensitive data
- **Integration**: Full template rendering error scenarios

## Implementation Order

1. **Phase 1: Foundation** (Exceptions + Logger + Utilities)
  - Create `ErrorLogger` class in `error_logger.dart`
  - Enhance exception classes with context fields
  - Add context capture utilities to `utils.dart`
  - Add unit tests for ErrorLogger, exceptions, and utilities
2. **Phase 2: Core Operations** (Defaults + Runtime)
  - Enhance `defaults.dart` error messages
  - Enhance `runtime.dart` error context
  - Add integration tests
3. **Phase 3: Rendering** (Renderer)
  - Add error wrapping helper to `renderer.dart`
  - Wrap all visitor methods with error context
  - Add integration tests for rendering errors
4. **Phase 4: Environment** (Environment + Parser)
  - Replace print statements in `environment.dart`
  - Enhance `parser.dart` error messages
  - Add integration tests
5. **Phase 5: Integration** (Debug + Async)
  - Review debug system integration
  - Enhance async renderer error handling
  - Final integration tests

## Documentation

- Update `README.md` to document enhanced error messages
- Add examples of enhanced error output
- Document context size limits
- Document sensitive data handling
- Document debug integration

## Success Criteria

- ✅ All existing tests pass (backward compatibility)
- ✅ Enhanced exceptions provide comprehensive context
- ✅ Error messages include actionable suggestions
- ✅ Context capture respects size limits
- ✅ Sensitive data is sanitized
- ✅ Zero overhead when no errors occur and logging is disabled
- ✅ ErrorLogger provides structured logging when enabled
- ✅ Debug system integration works correctly
- ✅ Performance is acceptable (full detail as requested)

## Implementation Todos

### Phase 1: Foundation (Exceptions + Logger + Utilities)

- Enhance `TemplateError` base class with context fields (stackTrace, node, contextSnapshot, operation, suggestions, templatePath, callStack)
- Enhance `TemplateSyntaxError` with node and suggestions fields
- Enhance `TemplateRuntimeError` with all context fields
- Enhance `UndefinedError` with variable name, similar names, context
- Enhance `TemplateNotFound` with search paths, loader information
- Create `TemplateErrorWrapper` for non-template exceptions
- Create `error_logger.dart` with `ErrorLogger` class
- Implement `LogLevel` enum (none, error, warning, info, debug)
- Implement `logError()`, `logWarning()`, `logInfo()`, `logDebug()` methods
- Implement automatic logging in exception constructors (if logger available)
- Add `captureContext()` utility to `utils.dart` with size limits
- Add `sanitizeForLogging()` utility to `utils.dart`
- Add `getNodeType()` utility to `utils.dart`
- Add `formatErrorReport()` utility to `utils.dart`
- Add `getSimilarNames()` utility to `utils.dart`
- Add `captureCallStack()` utility to `utils.dart`
- Add `getErrorSuggestions()` utility to `utils.dart`
- Write unit tests for exception enhancements
- Write unit tests for ErrorLogger
- Write unit tests for context utilities

### Phase 2: Core Operations (Defaults + Runtime)

- Enhance `getAttribute()` in `defaults.dart` with detailed error context
- Enhance `getItem()` in `defaults.dart` with detailed error context
- Enhance `undefined()` in `defaults.dart` with fuzzy matching and suggestions
- Add error wrapping to `resolve()` in `runtime.dart`
- Add error wrapping to `call()` in `runtime.dart`
- Add error wrapping to `attribute()` in `runtime.dart`
- Add error wrapping to `item()` in `runtime.dart`
- Add error wrapping to `filter()` in `runtime.dart`
- Add error wrapping to `test()` in `runtime.dart`
- Write integration tests for defaults errors
- Write integration tests for runtime errors

### Phase 3: Rendering (Renderer)

- Add `_wrapWithContext()` helper method to `renderer.dart`
- Wrap `visitAttribute()` with error context
- Wrap `visitCall()` with error context
- Wrap `visitFilter()` with error context
- Wrap `visitName()` with error context
- Wrap `visitItem()` with error context
- Wrap `visitFor()` with error context
- Wrap `visitIf()` with error context
- Wrap `visitMacro()` with error context
- Wrap `visitInclude()` with error context
- Wrap `visitImport()` with error context
- Wrap `visitSlice()` with error context
- Wrap all other visitor methods with error context
- Write integration tests for rendering errors

### Phase 4: Environment (Environment + Parser)

- Add `errorLogger` property to `Environment` class
- Add `errorLogLevel` property to `Environment` class
- Add constructor parameters for error logging configuration
- Replace `print()` statements in `callFilter()` with enhanced exceptions and logging
- Replace `print()` statements in `callTest()` with enhanced exceptions and logging
- Enhance `callCommon()` error handling in `environment.dart` with logging
- Enhance `getTemplate()` error handling in `environment.dart` with logging
- Enhance `fail()` method in `parser.dart` with node information and logging
- Add suggestions to parser syntax errors
- Write integration tests for environment errors
- Write integration tests for parser errors
- Write integration tests for error logging configuration

### Phase 5: Integration (Debug + Async)

- Review `DebugController` and `DebugEnvironment` for integration points
- Document debug system integration (if changes needed)
- Enhance async renderer error handling in `renderer.dart`
- Replace async filter error `print()` statements with enhanced exceptions
- Write integration tests for async error handling
- Write integration tests for debug system integration

### Phase 6: Documentation & Finalization

- Update `README.md` with enhanced error message documentation
- Add examples of enhanced error output
- Document context size limits
- Document sensitive data handling
- Run all existing tests to verify backward compatibility
- Run performance tests
- Final review and cleanup

## Open Questions Resolved

1. **Context Size Limits**: 50 variables, 10KB total, 10 stack frames ✅
2. **Sensitive Data Patterns**: `password`, `secret`, `token`, `key`, `api_key`, `auth` ✅
3. **Debug Integration**: Review and document integration with existing debug system ✅
4. **Performance**: Full detail acceptable, no performance concerns ✅
5. **Logging Backend**: None - enhanced exceptions contain all information ✅
6. **Backward Compatibility**: Extend existing classes, no breaking changes ✅

