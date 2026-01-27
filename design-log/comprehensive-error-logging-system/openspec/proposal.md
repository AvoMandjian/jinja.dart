## Why

Currently, when errors occur in Jinja template rendering, developers receive minimal information about what caused the error, where it occurred, and how to fix it. The README explicitly lists "Informative error messages" as a TODO item. This makes debugging template errors time-consuming and frustrating, especially for complex templates with nested macros, includes, and dynamic data.

Errors currently provide basic messages like "Cannot access attribute `name` on a null object" without context about:
- Which template and line number
- What variables were available
- What operation was being performed
- Actionable suggestions for fixing the issue

## What Changes

This change introduces comprehensive error logging and debugging capabilities throughout the Jinja library:

1. **Enhanced Exception Classes**: All exception classes are extended with rich context fields (node information, variable state, call stack, suggestions)
2. **ErrorLogger Class**: New structured logging system with configurable log levels
3. **Error Context Utilities**: Helper functions for capturing and formatting error context
4. **Error Wrapping**: All critical operations wrapped with error context capture
5. **Enhanced Error Messages**: Detailed, actionable error messages with suggestions

## Capabilities

### New Capabilities
- `error-logging`: Comprehensive error logging system with enhanced exceptions, structured logging, and context capture utilities

## Impact

- **Modified Files**: 
  - `lib/src/exceptions.dart` - Enhanced exception classes
  - `lib/src/error_logger.dart` - NEW FILE - ErrorLogger class
  - `lib/src/utils.dart` - Error context utilities
  - `lib/src/renderer.dart` - Error wrapping in visitor methods
  - `lib/src/runtime.dart` - Error context in runtime operations
  - `lib/src/defaults.dart` - Enhanced error messages
  - `lib/src/environment.dart` - Error logging configuration and enhanced error handling
  - `lib/src/parser.dart` - Enhanced parser error messages
  - `lib/debug.dart` - Debug system integration review

- **New Dependencies**: None (pure Dart implementation)

- **Breaking Changes**: None (all changes are additive, backward compatible)

- **Performance Impact**: Zero overhead when logging is disabled. Minimal overhead when enabled (context capture only occurs on errors).
