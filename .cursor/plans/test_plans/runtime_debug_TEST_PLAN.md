# Runtime & Debug Test Plan

**Targets:** `lib/src/runtime.dart`, `lib/src/debug/evaluator.dart`, `lib/src/debug/debug_renderer.dart`, `lib/src/loaders.dart`

## Test Cases

### 1. `Context` Behaviors
- **Category:** Runtime
- **Edge cases / variants:**
  - Fallbacks during variable resolution (`data` -> `parent` -> `globals`).
  - Handling of undefined variables (coercion to `undefined()`, returning fuzzy matching suggestions if operated upon).
  - Default parameter value fallbacks.
- **Verification:** Unit tests asserting `context.resolve()` outputs and `ThrowsA` for operations on `undefined()`.

### 2. Debug Output (`Evaluator` & `DebugRenderer`)
- **Category:** Debug
- **Edge cases / variants:**
  - Breakpoint hitting and `BreakpointInfo` generation.
  - Correct tracking of template line numbers during rendering.
- **Verification:** Validate `BreakpointInfo` traces against raw multi-line strings (`r'''...'''`).

### 3. Loaders (`MapLoader` & `FileSystemLoader`)
- **Category:** Loaders
- **Edge cases / variants:**
  - `MapLoader`: 95% of tests should use this for isolation.
  - `FileSystemLoader`: the `ignore missing` modifier, extending missing base files.
- **Verification:** Create `Directory.systemTemp.createTempSync()` in `setUp()` and delete in `tearDown()` to verify true disk I/O logic and failure modes (`TemplateNotFound`).

### 4. `AsyncRenderContext`
- **Category:** Async Runtime
- **Edge cases / variants:**
  - Delayed callbacks triggered inside macros or loops.
  - Eager context resolution errors (`Future.error`).
- **Verification:** MUST be tested with `await expectLater(template.renderAsync(), throwsA(...))` to prevent swallowed async errors from crashing the isolate.
