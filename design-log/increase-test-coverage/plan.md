# Plan: Increase Test Coverage

## Overview

Increase test coverage for the Jinja.dart library from 64.61% to 80%+ by adding comprehensive unit tests for currently untested or under-tested modules.

## Current State

- **Current Coverage**: 64.61% (3,783/5,855 statements)
- **Target Coverage**: 80%+ (4,684+ statements)
- **Gap**: ~900 statements need coverage

## Modules Requiring Tests

### High Priority (No Dedicated Tests)
1. **`lib/src/compiler.dart`** (532 lines) - RuntimeCompiler class
   - Complex AST transformations
   - No dedicated test file
   - Tested indirectly through integration tests

2. **`lib/src/optimizer.dart`** (469 lines) - Optimizer class
   - Constant folding optimizations
   - No dedicated test file
   - Tested indirectly through integration tests

3. **`lib/src/reader.dart`** (118 lines) - TokenReader class
   - Token reading and manipulation
   - Partial coverage in `lexer_test.dart` (only 2 basic tests)
   - Missing: push(), look(), skip(), nextIf(), skipIf(), expect(), eof()

4. **`lib/src/utils.dart`** (453 lines) - Utility functions
   - Partial coverage through `error_context_utilities_test.dart`
   - Missing: boolean(), identity(), pair(), iterate(), list(), range(), escape(), unescape(), capitalize(), stripTags(), sum(), htmlSafeJsonEncode(), errorContextSnippet()

5. **`lib/src/runtime.dart`** (614 lines) - Context class
   - Some integration coverage
   - Missing unit tests for: call(), resolve(), attribute(), item(), filter(), test(), derived(), has()

## Implementation Strategy

### Phase 0: Baseline & Analysis
- Measure current coverage
- Analyze existing test patterns
- Identify specific gaps

### Phase 1: Core Utilities (High Impact, Low Complexity)
- Create `test/utils_test.dart` for utility functions
- Enhance `test/reader_test.dart` (complement existing lexer tests)

### Phase 2: Compiler (Medium Complexity)
- Create `test/compiler_test.dart`
- Test AST transformations independently

### Phase 3: Optimizer (Medium Complexity)
- Create `test/optimizer_test.dart`
- Test constant folding optimizations

### Phase 4: Runtime Context (High Complexity)
- Create `test/runtime_test.dart`
- Test Context methods with proper Environment setup

### Phase 5: Coverage Verification
- Run final coverage analysis
- Document improvements
- Verify all tests pass

## Test Patterns

Follow existing patterns from:
- `test/lexer_test.dart` - TokenReader examples
- `test/error_context_utilities_test.dart` - Utils testing patterns
- `test/api_test.dart` - Context usage examples

## Success Criteria

- Test coverage increased to 80%+ (4,684+ statements covered)
- All new tests follow project conventions
- All existing tests continue to pass
- Code formatted and analyzed (zero lint errors)
- Coverage improvements documented

## Notes

- This is a test coverage improvement, not a feature change
- No breaking changes to existing code
- Tests should be isolated unit tests where possible
- Integration tests already exist, focus on unit test gaps
