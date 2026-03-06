# Security Test Plan

**Targets:** Lexer (`lib/src/lexer.dart`), Parser (`lib/src/parser.dart`)

## Test Cases

### 1. Lexer ReDoS
- **Category:** Security / Fuzzing
- **Edge cases / variants:**
  - Highly nested, unbalanced strings: `{{ "....`
  - Unclosed blocks: `{% raw %}....`
  - Unbalanced expressions: `{{(((....`
  - Exponentially increasing whitespace padding.
- **Verification:** Measure execution duration for payload sizes `N` and `N*10` to assert that duration scales linearly `O(n)`, not exponentially `O(2^n)`. Mandate a generous backstop `Timeout` (e.g., 5 seconds) to prevent CI hangs without flakiness.

### 2. Parser Stack Overflow
- **Category:** Security / Fuzzing
- **Edge cases / variants:**
  - Deeply nested blocks (e.g., nesting `{% if true %}` 500+ times).
- **Verification:** Ensure the parser enforces a `max_depth` limit. Explicitly assert that a controlled `TemplateSyntaxError` is thrown, failing the test if a native Dart `StackOverflowError` crashes the isolate. Use programmatic string generation, not hardcoded strings.
