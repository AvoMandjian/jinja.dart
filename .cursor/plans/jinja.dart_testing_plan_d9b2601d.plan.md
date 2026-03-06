---
name: Jinja.dart Testing Plan
overview: A comprehensive testing plan derived from a codebase coverage audit to improve the Jinja.dart template engine's test coverage, targeting the most critical untested branches across the renderer, filters, runtime, and debug components.
todos:
  - id: create-audit-docs
    content: Create test/AUDIT.md and folder-organized test plan documentation
    status: completed
  - id: implement-renderer-tests
    content: Implement missing tests in renderer_test.dart (visitSlice, visitFor, visitInterpolation, visitTrans, visitName)
    status: completed
  - id: implement-filters-tests
    content: Implement missing tests in filters_test.dart (doFromJson, doRandom, doSafe, doItem)
    status: completed
  - id: implement-runtime-tests
    content: Implement missing tests in runtime_test.dart for context and undefined behaviors
    status: completed
  - id: implement-debug-tests
    content: Implement missing tests for debug components (evaluator, debug_renderer)
    status: completed
  - id: implement-security-tests
    content: Implement tests for ReDoS and Parser Stack Overflow vulnerabilities
    status: completed
isProject: false
---

# Jinja.dart Comprehensive Testing Plan (Enhanced)

## Enhancement Summary

**Deepened on:** 2026-03-06
**Sections enhanced:** 4
**Research agents used:** test-patterns, dart-flutter-general-guidelines, code-reviewer, pattern-recognition-specialist, explore (Dart Testing Best Practices), security-auditor, architecture-strategist, code-simplicity-reviewer

### Key Improvements

1. **Security Test Safety**: Mandated strict `Timeout` parameters for ReDoS and Stack Overflow tests to prevent CI hangs. Addressed CI flakiness by verifying linear scaling over hard timeouts.
2. **Test Directory Purity**: Moved documentation files out of `test/` (to `.cursor/plans/` or via skipped tests) to prevent Dart package pollution.
3. **Table-Driven Testing**: Replaced individual test blocks with parameterized/table-driven testing for filters and boundaries to enforce the DRY principle.
4. **Environment Optimization**: Refined the State Isolation rule to allow a shared, immutable `Environment` for stateless rendering tests, drastically improving test suite performance.
5. **Code Simplicity**: Removed over-engineered concepts like custom Matcher classes (`RendersTo`) and Test Data Builders in favor of standard Dart assertions and literal maps.

### New Considerations Discovered

- **Implementation Leakage**: Tests must evaluate raw template strings (`env.fromString("...").render()`) rather than manually constructing AST nodes (like `Slice`) to prevent brittle coupling to the parser.
- **Async Assertions**: Must use `await expectLater(..., throwsA(...))` for `AsyncRenderContext` tests to prevent swallowed async errors crashing the event loop.

---

Based on a detailed code coverage analysis (using `dart test --coverage=coverage`), we have identified several components with significant coverage gaps. Overall, Jinja.dart has very strong parser and compiler coverage (>90%), but coverage drops in the renderer, runtime, filters, and debug features.

## Coverage Audit Findings


| Component               | Coverage | Key Missing Areas                                                                                                                         |
| ----------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `lib/src/renderer.dart` | 62.2%    | `visitSlice` (261 lines missing), `visitFor` (56 lines), `visitInterpolation` (32 lines), `visitTrans` (28 lines), `visitName` (24 lines) |
| `lib/src/filters.dart`  | 67.8%    | `doFromJson` (100 lines missing), `doRandom` (19 lines), `doSafe` (14 lines), `doItem` (12 lines)                                         |
| `lib/src/runtime.dart`  | 63.7%    | Context operations, undefined handling, scope management                                                                                  |
| `lib/src/debug/*.dart`  | 25-58%   | `evaluator.dart`, `debug_renderer.dart`, `debug_controller.dart`, `async_debug_renderer.dart`                                             |
| `lib/src/loaders.dart`  | 50.0%    | Specific loader edge cases and exceptions                                                                                                 |


## Testing Conventions & Quality Standards

To ensure test maintainability and prevent state leakage, all new tests MUST adhere to the following standards:

1. **State Isolation & Performance:** Use a shared, immutable `Environment` for pure, stateless rendering tests. Only create a fresh `Environment` instance via `setUp()` for tests that explicitly modify globals, register custom filters, or mutate caching behavior.
2. **Arrange-Act-Assert (AAA) & Given-When-Then:** Structure tests clearly. For integration-level tests, use the Given-When-Then narrative format in test descriptions.
3. **DRY Principle (Table-Driven Tests):** Use parameterized/table-driven tests for heavily branched logic like filters and slices. Iterate over a list of test cases `(String template, Map<String, Object?> context, dynamic expectedOutputOrError)` rather than writing dozens of individual `test()` blocks.
4. **No Magic Values:** Centralize test constants and boundary data.
5. **Simplified Matchers:** Use explicit type matchers for errors. Create lightweight top-level matchers like `Matcher throwsTemplateError(Pattern msg) => throwsA(isA<TemplateError>().having((e) => e.message, 'message', matches(msg)));`. Stick to `expect(template.render(context), equals(expected))` for rendering.
6. **Strict Typing:** No `dynamic` or `var` in tests. Use `final` for evaluated results and `const` for setup data. Explicitly type all variables and JSON payloads.
7. **Async Safety:** When expecting errors from asynchronous templates, strictly use `await expectLater(..., throwsA(...))` to prevent swallowed async errors from crashing the event loop.

### Research Insights

**Best Practices:**

- Limit `setUp` to initializing the `Environment`. Define context variables inside individual test blocks or pass them via Table-Driven tests to keep the AAA cycle visible. Use inline Dart map literals instead of fluent Test Data Builders.
- Create a central test utility function `Environment createTestEnv({Map<String, Object>? globals})` inside a `test/utils.dart` file to reduce boilerplate.

**Implementation Details:**

```dart
// Table-Driven Test Example
final testCases = [
  (template: '{{ items[1:3] }}', context: {'items': [1, 2, 3, 4]}, expected: '[2, 3]'),
  (template: '{{ items[::-1] }}', context: {'items': [1, 2]}, expected: '[2, 1]'),
];

for (final tc in testCases) {
  test('Given ${tc.template}, renders ${tc.expected}', () {
    final template = env.fromString(tc.template);
    expect(template.render(tc.context), equals(tc.expected));
  });
}
```

## Technical Implementation Details (Deepened)

### 1. Test Utilities (`test/matchers.dart`)

- **Simplified Matchers:** Avoid over-engineered `CustomMatcher` classes. For rendering, stick to standard idiomatic Dart: `expect(template.render(context), equals(expected))`.
- **Inline Test Data:** Leverage Dart's concise literal syntax (`{'user': {'role': 'admin'}}`) to keep test context transparent and local to the test block.
- **Traceback Assertions:** Use Dart's raw multi-line strings (`r'''...'''`) to assert debug tracebacks rather than building a custom file-based snapshot testing framework.

### 2. Table-Driven Renderer Tests

Use generic Dart 3 records for strict type-safe table-driven testing:

```dart
typedef RenderTestCase<T> = ({String name, String template, Map<String, Object?> data, T expected});
```

- **ErrorLogger Context Wrapping & DoS Prevention:** Use `runZoned` to intercept `print()`. Verify `logger.logError` limits context item *count* AND string *length* (preventing pathological `.toString()` DoS). Verify cyclic object handling.
- **Sanitization Testing:** Ensure ErrorLogger tests verify case-insensitive redaction (`PASSWORD`, `password`), nested keys (`{"config": {"api_key": "secret"}}`), and that values are safely replaced with `[REDACTED]`.

### 3. Filter Edge Cases

- `**fromjson`:** Test top-level scalars (`'42'`, `'true'`, `'null'`). Ensure malformed JSON throws `FormatException`.
- `**random`:** Inject a seeded `math.Random(42)` into the Environment, or test behaviorally using `contains(result)`.
- `**safe`:** Test idempotency (passing an already `SafeString` should return the same instance).
- `**item`:** Test out-of-bounds on Lists, missing keys on Maps (should return `null`, not throw), and invalid access on `MapEntry`.

### 4. Runtime & Debug Tests

- **Context Fallbacks:** Ensure `Context.resolve()` searches `data` -> `parent` -> `globals`. Ensure failed lookups return `undefined()` which throws with fuzzy matching suggestions if operated upon.
- **Debug Output:** Test `Evaluator` and `DebugRenderer` by verifying `BreakpointInfo` traces against raw multi-line strings (`r'''...'''`).

### 5. Security Pathological Fuzzing

- **Lexer ReDoS:** Do NOT rely solely on strict CI timeouts, as this causes flakiness. Measure execution duration for payload sizes `N` and `N*10` to assert that duration scales linearly `O(n)`, not exponentially `O(2^n)`. Test vectors must include unclosed strings `{{ "...`, raw blocks, and highly nested unbalanced expressions. Set a generous backstop timeout (e.g., 5 seconds).
- **Parser Stack Overflow:** Do NOT allow native `StackOverflowError` to occur. The parser must have a `max_depth` limit. Tests should programmatically nest `{% if true %}` 500+ times and explicitly assert that a controlled `TemplateSyntaxError` is thrown, failing the test if the isolate crashes.

## Implementation Strategy

We will proceed incrementally to create and implement tests for the lowest-coverage areas first.

### 1. Audit & Plan Documents

- Create folder-specific plan documents detailing the exact test cases for missing branches inside `.cursor/plans/` (Do NOT place `.md` files in the `test/` directory to avoid package pollution).
- Alternatively, use skipped tests (`test('...', () {}, skip: 'TODO: Coverage gap');`) as executable living documentation.

### 2. Renderer Tests (`test/renderer_test.dart` extensions)

- Add targeted integration tests for slice expressions (`visitSlice`), around negative indices, invalid stops, and exceptions (e.g. `TemplateRuntimeError`).
- Add integration tests for complex `for` loops (`visitFor`), translation blocks (`visitTrans`), and string interpolation.
- **Anti-Pattern Warning:** Evaluate raw template strings (`env.fromString("...").render()`). Do NOT manually construct AST nodes like `Slice()` to test the renderer, as this creates brittle implementation leakage.
- **ErrorLogger:** Do not defer ErrorLogger context wrapping tests. Verify that the newly tested edge cases produce the correct `TemplateRuntimeError` with the correct line numbers and template context attached.

### 3. Filters Tests (`test/filters_test.dart` extensions)

- Add robust table-driven tests for `fromjson` filter (JSON deserialization) with valid and malformed data. Assert exact strongly-typed structures (e.g., `isA<Map<String, dynamic>>()`).
- Test `random`, `safe`, and `item` filters. Ensure determinism in `doRandom` by asserting behavioral properties (e.g., `expect(inputList, contains(result))`) rather than exact values.

### 4. Runtime, Debug & Loader Tests

- Add tests focusing on missing `Context` behaviors and undefined variable coercions in `runtime_test.dart` (including default parameter value fallbacks).
- Implement tests for the `Evaluator` and `DebugRenderer` to ensure debugging metadata is properly captured.
- **Loader Mocking:** Use `MapLoader` for 95% of tests to isolate execution from the real file system. For `FileSystemLoader` edge cases (like `ignore missing`), use `Directory.systemTemp.createTempSync()` in `setUp()` and delete it in `tearDown()` to ensure clean disk I/O tests.

### 5. Security, Async & Edge Case Tests

- **Boundary Conditions:** Empty arrays in `visitFor`, missing keys in `visitSlice`, malformed JSON in `doFromJson`.
- **Type Coercion:** Fallbacks to `Undefined` or strict error modes.
- **Async Execution:** Async implementations in `AsyncRenderContext` and `async_debug_renderer.dart` MUST be tested with `await expectLater(template.renderAsync(), throwsA(...))` to prevent swallowed async errors from silently crashing the test isolate. Ensure delayed callbacks triggered within macros or loops are captured correctly.
- **Vulnerability Prevention:** Implement the ReDoS and Parser Stack Overflow vulnerability prevention assertions detailed in Technical Implementation Details.

