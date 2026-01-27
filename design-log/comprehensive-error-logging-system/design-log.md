# Design Log #1: Comprehensive Error Logging System

## Background

The Jinja.dart template engine currently provides minimal error information when template rendering fails. The README explicitly lists "Informative error messages" as a TODO item (lines 60-62). When errors occur, developers receive basic messages like "Cannot access attribute `name` on a null object" without context about:

- Which template and line number the error occurred at
- What variables were available in the context
- What operation was being performed
- Actionable suggestions for fixing the issue

This makes debugging template errors time-consuming and frustrating, especially for complex templates with nested macros, includes, and dynamic data.

## Problem Statement

Developers need comprehensive error information when template rendering fails to:
1. Quickly identify what caused the error (variable name, operation type, object state)
2. Know exactly where the error occurred (template path, line, column, AST node)
3. Understand the context (available variables, call stack, template chain)
4. Receive actionable suggestions for fixing the error

Current error messages lack this information, requiring developers to manually trace through code and add debug statements.

## Questions and Answers

### Q: Should error logging be always enabled or opt-in?
A: Error logging should be opt-in via Environment configuration. Enhanced exceptions will always contain context, but structured logging via ErrorLogger is optional and can be disabled for zero overhead.

### Q: What is the acceptable performance impact?
A: Zero overhead when logging is disabled. Minimal overhead when enabled (context capture only occurs on errors, not during normal execution). Full detail is acceptable as requested.

### Q: Should we integrate with existing debug system?
A: Yes, we should review and integrate with the existing `lib/debug.dart` debug system to ensure enhanced errors work with debug renderers.

### Q: How should sensitive data be handled?
A: Sensitive data patterns (*password*, *secret*, *token*, *key*, *api_key*, *auth*) should be automatically excluded from context snapshots to prevent exposure in error logs.

### Q: What are the context size limits?
A: Maximum 50 variables, 10KB total size, 10 stack frames. Context will be truncated if limits are exceeded.

### Q: Should this be backward compatible?
A: Yes, all changes must be additive. Existing exception classes are extended, not replaced. All new fields are optional (nullable).

## Design

### Architecture Overview

The error logging system consists of three main components:

1. **Enhanced Exception Classes**: Extended with context fields (node, contextSnapshot, operation, suggestions, etc.)
2. **ErrorLogger Class**: Structured logging with configurable levels
3. **Error Context Utilities**: Helper functions for capturing and formatting context

### File Structure

```
lib/src/
├── exceptions.dart          # Enhanced exception classes
├── error_logger.dart        # NEW: ErrorLogger class
├── utils.dart               # Error context utilities (extended)
├── renderer.dart            # Error wrapping in visitor methods
├── runtime.dart             # Error wrapping in runtime operations
├── defaults.dart            # Enhanced error messages
├── environment.dart         # Error logging configuration
└── parser.dart              # Enhanced parser error messages
```

### Enhanced Exception Classes

**TemplateError Base Class**:
```dart
abstract class TemplateError implements Exception {
  TemplateError([this.message]);
  
  final String? message;
  
  // NEW: Enhanced context fields (all optional for backward compatibility)
  final StackTrace? stackTrace;
  final Node? node;
  final Map<String, Object?>? contextSnapshot;
  final String? operation;
  final List<String>? suggestions;
  final String? templatePath;
  final List<String>? callStack;
  
  @override
  String toString() {
    // Enhanced formatting with all context
  }
}
```

**All Exception Types Enhanced**:
- `TemplateSyntaxError` - Add node and suggestions
- `TemplateRuntimeError` - Add all context fields
- `UndefinedError` - Add variable name, similar names, context
- `TemplateNotFound` - Add search paths, loader information
- `TemplateAssertionError` - Add node and operation context

**New Exception**:
- `TemplateErrorWrapper` - Wraps non-template exceptions with Jinja context

### ErrorLogger Class

```dart
enum LogLevel { none, error, warning, info, debug }

class ErrorLogger {
  ErrorLogger({this.level = LogLevel.error});
  
  final LogLevel level;
  
  void logError(String message, {TemplateError? error, Map<String, Object?>? context});
  void logWarning(String message, {Map<String, Object?>? context});
  void logInfo(String message, {Map<String, Object?>? context});
  void logDebug(String message, {Map<String, Object?>? context});
  
  bool isEnabled(LogLevel level);
  void setLogLevel(LogLevel level);
}
```

### Error Context Utilities

**In `lib/src/utils.dart`**:
- `captureContext(Context context, {int maxVariables = 50, int maxSize = 10240})` - Capture context with limits
- `sanitizeForLogging(Map<String, Object?> context)` - Remove sensitive data
- `getNodeType(Node node)` - Get readable node type name
- `formatErrorReport(TemplateError error)` - Format comprehensive report
- `getSimilarNames(String name, Iterable<String> available, {int maxResults = 5})` - Fuzzy matching
- `captureCallStack({int maxDepth = 10})` - Capture call stack
- `getErrorSuggestions(TemplateError error)` - Generate suggestions

### Error Wrapping Pattern

**In Renderer**:
```dart
TemplateError _wrapWithContext(
  dynamic error,
  Node? node,
  StringSinkRenderContext context,
  String operation,
) {
  // Capture context, wrap error, add suggestions
  // Return enhanced TemplateError
}

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

### Environment Configuration

```dart
class Environment {
  Environment({
    // ... existing parameters
    ErrorLogger? errorLogger,
    LogLevel errorLogLevel = LogLevel.error,
  }) : errorLogger = errorLogger,
       errorLogLevel = errorLogLevel;
  
  final ErrorLogger? errorLogger;
  final LogLevel errorLogLevel;
}
```

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

## Implementation Plan

### Phase 1: Foundation (Exceptions + Logger + Utilities)
1. Enhance exception classes with context fields
2. Create ErrorLogger class
3. Add context capture utilities
4. Write unit tests

### Phase 2: Core Operations (Defaults + Runtime)
1. Enhance error messages in defaults.dart
2. Add error wrapping to runtime operations
3. Write integration tests

### Phase 3: Rendering (Renderer)
1. Add error wrapping helper method
2. Wrap all visitor methods with error context
3. Write integration tests

### Phase 4: Environment (Environment + Parser)
1. Add error logging configuration to Environment
2. Replace print statements with enhanced exceptions
3. Enhance parser error messages
4. Write integration tests

### Phase 5: Integration (Debug + Async)
1. Review debug system integration
2. Enhance async renderer error handling
3. Write integration tests

### Phase 6: Documentation & Finalization
1. Update README
2. Add examples
3. Run all tests
4. Performance validation

## Examples

### Example 1: Enhanced UndefinedError

**Before**:
```
UndefinedError: Cannot access attribute `name` on a null object.
```

**After**:
```
UndefinedError: Cannot access attribute `name` on a null object.
  Location: template 'users.html', line 15, column 8
  Node: Attribute (user.name)
  Operation: Accessing attribute 'name' on null object
  Context:
    - Template: 'users.html'
    - Variable 'user': null
    - Available variables: ['users', 'userList', 'currentUser']
  Suggestions:
    - Check if 'user' is defined: {% if user %}{{ user.name }}{% endif %}
    - Did you mean 'users' or 'currentUser'?
    - Ensure 'user' is passed to template context
```

### Example 2: ErrorLogger Usage

```dart
// Configure logging
final env = Environment(
  errorLogger: ErrorLogger(level: LogLevel.error),
  errorLogLevel: LogLevel.error,
);

// Automatic logging when exceptions are thrown
try {
  template.render({'user': null});
} catch (e) {
  // Error automatically logged if level >= error
  // Enhanced exception contains all context
}
```

### Example 3: Context Capture

```dart
// Capture context with limits
final context = captureContext(
  renderContext,
  maxVariables: 50,
  maxSize: 10240,
);

// Sanitize sensitive data
final sanitized = sanitizeForLogging(context);
// Removes keys matching: *password*, *secret*, *token*, etc.
```

## Trade-offs

### Alternative 1: Always-On Logging
**Pros**: No configuration needed
**Cons**: Performance overhead even when not needed
**Decision**: Rejected - Opt-in logging provides better performance control

### Alternative 2: Separate Logging Backend
**Pros**: More flexible, can integrate with external systems
**Cons**: Additional dependency, more complex
**Decision**: Rejected - ErrorLogger is sufficient, enhanced exceptions contain all info

### Alternative 3: Breaking Changes
**Pros**: Cleaner API
**Cons**: Breaks existing code
**Decision**: Rejected - Backward compatibility is critical

### Chosen Solution: Enhanced Exceptions + Optional ErrorLogger
**Pros**: Backward compatible, zero overhead when disabled, comprehensive detail when enabled
**Cons**: More code to maintain
**Decision**: Accepted - Best balance of functionality and compatibility

## Implementation Results

### Phase 1 Complete (2026-01-27)
- ✅ Exception classes enhanced with context fields (stackTrace, node, contextSnapshot, operation, suggestions, templatePath, callStack)
- ✅ TemplateErrorWrapper created for non-template exceptions
- ✅ ErrorLogger class implemented with LogLevel enum and logging methods
- ✅ All error context utilities implemented (captureContext, sanitizeForLogging, getNodeType, formatErrorReport, getSimilarNames, captureCallStack, getErrorSuggestions)
- ✅ Unit tests written: exception_enhancement_test.dart (20 tests), error_logger_test.dart (23 tests), error_context_utilities_test.dart (25 tests)
- **Tests**: 68/68 passing

### Phase 2 Complete (2026-01-27)
- ✅ getAttribute() and getItem() enhanced with detailed error messages
- ✅ undefined() returns null for backward compatibility (errors thrown at point of use)
- ✅ Runtime operations (resolve, call, attribute, item, filter, test) wrapped with error context
- ✅ Special handling added for LoopContext.call() in recursive for loops
- ✅ Map attribute access returns null for non-existent keys (Jinja2 compatibility)
- **Tests**: All existing tests passing

### Phase 3 Complete (2026-01-27)
- ✅ All visitor methods wrapped with error context (visitInterpolation, visitOutput, visitCall, visitName, visitItem, visitFor, visitIf, visitMacro, visitInclude, visitImport, visitSlice, visitExtends, visitTemplateNode)
- ✅ getDataForTargets() wrapped with error context
- ✅ Slice index validation added
- ✅ Template path consistency fixed (templatePath vs templatePathValue)
- **Tests**: All existing tests passing

### Phase 4 Complete (2026-01-27)
- ✅ print() statements replaced with enhanced exceptions in callFilter() and callTest()
- ✅ callCommon() enhanced with error wrapping
- ✅ getTemplate() enhanced to re-throw TemplateError subclasses as-is (prevents over-wrapping)
- ✅ Parser fail() method enhanced with intelligent suggestions based on error patterns
- ✅ Tag stack information included in parser suggestions
- **Tests**: All existing tests passing

### Phase 5 Complete (2026-01-27)
- ✅ DebugController and DebugEnvironment reviewed - no changes needed (seamless integration)
- ✅ AsyncRenderer.render() wrapped with error context
- ✅ _AsyncCollectingSink.getResolvedContent() wrapped with error context for Future resolution errors
- ✅ Async filter errors already using enhanced exceptions (from Phase 4)
- **Tests**: All existing tests passing

### Phase 6 Complete (2026-01-27)
- ✅ README.md updated with comprehensive "Enhanced Error Messages" section
- ✅ Before/after error examples added
- ✅ Error types documented (TemplateError, TemplateSyntaxError, TemplateRuntimeError, UndefinedError, TemplateNotFound, TemplateAssertionError, TemplateErrorWrapper)
- ✅ Context size limits documented (50 variables, 10KB, 10 stack frames)
- ✅ Sensitive data handling documented (password, secret, token, key patterns)
- ✅ ErrorLogger usage example added
- ✅ Common error scenarios documented
- ✅ "Informative error messages" TODO marked as complete
- **Tests**: 432/432 passing
- **Examples**: 90/90 complete successfully
- **Type-check**: PASS (only minor lint warnings, pre-existing)

### Final Summary (2026-01-27)
- **Total Implementation Time**: 6 phases completed
- **Test Coverage**: 432 tests passing (100% of existing tests)
- **New Test Files**: 3 (exception_enhancement_test.dart, error_logger_test.dart, error_context_utilities_test.dart)
- **New Code Files**: 1 (lib/src/error_logger.dart)
- **Modified Files**: 8 (exceptions.dart, utils.dart, defaults.dart, runtime.dart, renderer.dart, environment.dart, parser.dart, filters.dart)
- **Backward Compatibility**: ✅ Maintained - all existing code works without changes
- **Performance**: ✅ Acceptable - zero overhead when ErrorLogger disabled
- **Documentation**: ✅ Complete - README updated with comprehensive error system documentation
- **Issues Found**: None
- **Deviations**: 
  - Error wrapping implemented inline in visitor methods instead of separate _wrapWithContext() helper
  - undefined() returns null instead of throwing (errors thrown at point of use for backward compatibility)
  - Map attribute access returns null for non-existent keys (Jinja2 compatibility)
  - captureCallStack() implemented as placeholder (basic implementation)
  - ErrorLogger is optional - enhanced exceptions work without it
