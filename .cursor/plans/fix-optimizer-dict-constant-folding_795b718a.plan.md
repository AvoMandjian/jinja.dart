---
name: fix-optimizer-dict-constant-folding
overview: Investigate and fix the runtime type error in the Jinja optimizer when constant-folding dict literals, as surfaced by the real_world_test.dart example, and add regression coverage.
todos:
  - id: analyze-optimizer-visitdict
    content: Confirm current behavior and failure mode of Optimizer.visitDict using the real_world_test.dart template snippet and stack trace context.
    status: pending
  - id: design-safe-constant-folding-condition
    content: Design the updated condition in visitDict so that constant-folding only occurs when all dict key/value pairs are Constant, avoiding invalid casts for non-constant values.
    status: pending
  - id: implement-visitdict-fix
    content: Update visitDict in lib/src/optimizer.dart to use the safer condition and casting logic while preserving correct behavior for constant-only dicts and returning a Dict node otherwise.
    status: pending
  - id: add-regression-tests-for-dict-folding
    content: Add tests under test/ that cover mixed constant/non-constant dict literals and fully constant dict literals to guard against regressions in the optimizer.
    status: pending
  - id: run-tests-and-analyzer
    content: Run dart test, dart analyze, and re-run example/real_world_test.dart to ensure the error is resolved and no regressions are introduced.
    status: pending
isProject: false
---

### Goal

Fix the `type '({Constant key, Attribute value})' is not a subtype of type '({Constant key, Constant value})'` runtime error thrown from `Optimizer.visitDict` during template optimization, while preserving expected constant-folding behavior for fully constant dict literals.

### Approach

- **Reproduce and understand the failure**
  - Use the existing `example/real_world_test.dart` flow (around lines 9–40) to reproduce the exception and confirm it originates from a dict like `{"key": 'userToken', "value": login_response.workflow_results.login.login_user.token} | tojson`.
  - Inspect `Optimizer.visitDict` in `[lib/src/optimizer.dart](lib/src/optimizer.dart)` and confirm how it handles `Dict` nodes and under which condition it attempts to constant-fold them.
- **Design a safer constant-folding condition**
  - Identify why the current `pairs.any((pair) => pair.key is Constant && pair.value is Constant)` condition combined with `pairs.cast<({Constant key, Constant value})>()` is unsound when only some pairs are constant.
  - Update the logic so constant-folding occurs **only when all pairs** have `Constant` keys and values (e.g. using `every` instead of `any`, or equivalent), avoiding invalid casts when any value is a non-constant expression like `Attribute`.
  - Keep the behavior that, when not all pairs are constants, the optimizer should return a `Dict` node with individually optimized key/value expressions (via `visitNode`) but without attempting to pack them into a single `Constant`.
- **Implement the optimizer change**
  - In `visitDict` in `[lib/src/optimizer.dart](lib/src/optimizer.dart)`, adjust the conditional and casting logic to:
    - First, visit each key and value expression, building the `pairs` list as it already does.
    - Then, check that **every** pair has both key and value of type `Constant` before constructing the `constantPairs` view and returning a new `Constant` mapping.
    - Otherwise, skip the cast and just return `node.copyWith(pairs: pairs)`.
  - Optionally, refactor the cast to use a more type-safe approach (e.g. pattern matching into a new list of constant pairs) if it improves clarity without changing behavior.
- **Add regression tests**
  - Locate or create a suitable test file under `test/` (for example, a new test group that exercises optimizer behavior for dict literals).
  - Add a test that builds an environment via `Environment.fromString` (or similar helper) with a template fragment equivalent to the one in `real_world_test.dart`:
    - A dict literal with at least one entry whose value is a non-constant expression (`Attribute`/variable) and at least one fully constant entry.
    - Ensure rendering or compilation no longer throws, and that the produced output matches expectations (e.g. JSON contains the dynamic value at runtime).
  - Add a complementary test with a dict whose keys and values are all constants to verify that constant-folding still happens and yields the same runtime result as before (no behavioral regression).
- **Sanity check with examples and tooling**
  - Run `dart test` to ensure the new tests pass and no existing tests break.
  - Run `dart analyze` to confirm there are no new lints introduced.
  - Re-run `example/real_world_test.dart` to verify the original scenario no longer crashes and behaves as intended.

### Notes and trade-offs

- **Safety vs. optimization**: The change slightly narrows when constant-folding is applied (requiring all pairs to be constants), trading a minimal optimization opportunity for type safety and correctness in mixed-constant dicts.
- **Future enhancements**: If desired later, the optimizer could be extended to partially fold dicts (e.g. precomputing only the constant entries) but that is out of scope for this bugfix and would require more involved semantics decisions.

