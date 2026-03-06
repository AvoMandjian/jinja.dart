# Renderer Test Plan

**Target:** `lib/src/renderer.dart`

## Test Cases

### 1. `visitSlice`
- **Category:** Renderer (AST node)
- **Edge cases / variants:**
  - Standard slice `[1:3]`
  - Negative slice `[::-1]`
  - Invalid slice indices (e.g. `start` > `stop`)
  - Missing keys/indices
- **Verification:** `template.render()` returns expected output, or throws `TemplateRuntimeError`. Use table-driven tests (`RenderTestCase`).

### 2. `visitFor`
- **Category:** Renderer (AST node)
- **Edge cases / variants:**
  - Basic iteration over a list.
  - Empty array (triggering `else` block if present).
- **Verification:** Table-driven tests matching expected strings.

### 3. `visitInterpolation`
- **Category:** Renderer (AST node)
- **Edge cases / variants:**
  - Variable injection.
  - Complex expressions (e.g. arithmetic inside `{{ ... }}`).
- **Verification:** Table-driven tests matching expected strings.

### 4. `visitTrans`
- **Category:** Renderer (AST node)
- **Edge cases / variants:**
  - Basic translation block.
  - Multi-line translation blocks.
- **Verification:** Table-driven tests.

### 5. `visitName`
- **Category:** Renderer (AST node)
- **Edge cases / variants:**
  - Resolving existing variables.
  - Resolving undefined variables (testing `undefined` object creation and subsequent access errors).
- **Verification:** Table-driven tests.

### 6. ErrorLogger Context Wrapping
- **Category:** Renderer / Error Handling
- **Edge cases / variants:**
  - Ensure `TemplateRuntimeError` includes the correct line numbers and template context when triggered by renderer faults.
- **Verification:** Use `runZoned` to intercept `print()` calls and assert on the string length/formatting. Verify case-insensitive redaction of `password`, nested keys, and that values are replaced with `[REDACTED]`.
