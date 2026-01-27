## ADDED Requirements

### Requirement: Enhanced Exception Context
The system SHALL provide enhanced exception classes with comprehensive context information including node location, variable state, call stack, and actionable suggestions.

#### Scenario: Exception with Full Context
- WHEN an error occurs during template rendering
- THEN the exception SHALL contain:
  - Node information (type, line, column)
  - Template path
  - Variable context snapshot (sanitized, max 50 variables)
  - Operation description
  - Call stack (max 10 frames)
  - Actionable fix suggestions
- AND the exception toString() SHALL format all context in a human-readable format

### Requirement: ErrorLogger Class
The system SHALL provide an ErrorLogger class with configurable log levels (none, error, warning, info, debug) for structured error logging.

#### Scenario: Configurable Logging
- WHEN ErrorLogger is configured with a log level
- THEN only messages at or above that level SHALL be logged
- AND logging SHALL have zero overhead when level is 'none'
- AND logging SHALL automatically occur when enhanced exceptions are created (if logger configured)

#### Scenario: Log Level Filtering
- WHEN ErrorLogger level is set to 'warning'
- THEN 'error' and 'warning' messages SHALL be logged
- AND 'info' and 'debug' messages SHALL be ignored

### Requirement: Context Capture Utilities
The system SHALL provide utilities for safely capturing error context with size limits and sensitive data sanitization.

#### Scenario: Context Size Limits
- WHEN capturing context for error reporting
- THEN the system SHALL limit context to:
  - Maximum 50 variables
  - Maximum 10KB total size
  - Maximum 10 stack frames
- AND context SHALL be truncated if limits exceeded

#### Scenario: Sensitive Data Sanitization
- WHEN capturing context containing sensitive data
- THEN keys matching patterns (*password*, *secret*, *token*, *key*, *api_key*, *auth*) SHALL be excluded
- AND sanitized context SHALL be included in error reports

### Requirement: Error Wrapping in Renderer
The system SHALL wrap all visitor methods in the renderer with error context capture.

#### Scenario: Renderer Error Context
- WHEN an error occurs in any visitor method (visitAttribute, visitCall, visitFilter, etc.)
- THEN the error SHALL be wrapped with:
  - AST node information
  - Current render context
  - Operation description
  - Template path
- AND the wrapped error SHALL be rethrown with enhanced context

### Requirement: Enhanced Error Messages
The system SHALL provide enhanced error messages with actionable suggestions.

#### Scenario: Undefined Variable Error
- WHEN a variable is undefined
- THEN the error message SHALL include:
  - Variable name
  - Template path and line number
  - Similar variable names (fuzzy matching)
  - Suggestions for fixing (check spelling, ensure variable is passed to template)

#### Scenario: Attribute Access Error
- WHEN attribute access fails on null object
- THEN the error message SHALL include:
  - Attribute name
  - Object type (null)
  - Available attributes (if object type known)
  - Suggestions (check if object is null, use conditional rendering)

### Requirement: Environment Error Logging Configuration
The system SHALL allow Environment to be configured with an optional ErrorLogger instance and log level.

#### Scenario: Environment Logging Configuration
- WHEN creating an Environment instance
- THEN optional errorLogger and errorLogLevel parameters SHALL be available
- AND if errorLogger is provided, errors SHALL be automatically logged
- AND if errorLogger is not provided, errors SHALL still be thrown with enhanced context

### Requirement: Backward Compatibility
The system SHALL maintain backward compatibility with existing code.

#### Scenario: Existing Code Compatibility
- WHEN existing code catches TemplateError exceptions
- THEN the code SHALL continue to work without modification
- AND enhanced context fields SHALL be optional (nullable)
- AND toString() methods SHALL be enhanced but remain compatible
