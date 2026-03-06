# Filters Test Plan

**Target:** `lib/src/filters.dart`

## Test Cases

### 1. `fromjson` Filter (`doFromJson`)
- **Category:** Filter
- **Edge cases / variants:**
  - Valid JSON object/array.
  - Top-level scalars: `'42'`, `'true'`, `'null'`.
  - Malformed JSON (throws `FormatException` or engine-specific error).
- **Verification:** Table-driven tests asserting strongly-typed structure returns (e.g., `isA<Map<String, dynamic>>()`) or errors.

### 2. `random` Filter (`doRandom`)
- **Category:** Filter
- **Edge cases / variants:**
  - Standard list selection.
  - Empty iterables (`[]`, `{}`).
  - Deterministic evaluation (inject `math.Random(42)`).
- **Verification:** Check behavioral properties (e.g., `contains(result)`) or deterministic seeded outcomes.

### 3. `safe` Filter (`doSafe`)
- **Category:** Filter
- **Edge cases / variants:**
  - Basic HTML string wrapping.
  - Idempotency: passing an existing `SafeString` should return the identical instance.
  - Non-string values (e.g. `42`, which should be `.toString()`'d).
- **Verification:** Object identity checks (`identical(a, b)`) and type assertions.

### 4. `item` Filter (`doItem`)
- **Category:** Filter
- **Edge cases / variants:**
  - Valid Map/List item access.
  - List out-of-bounds indices.
  - Map missing keys (should return `null`, not throw).
  - Invalid access on `MapEntry` (e.g., index `2`).
- **Verification:** Table-driven test evaluating expected returns and specific error types (e.g. `UndefinedError`).
