---
name: async-set-assignment-jinja-dart
overview: Refactor the async renderer so that async function calls used in `{% set %}` assignments are awaited before later control-flow and attribute access, fixing the `login_response` bug in `real_world_test.dart` and similar templates.
todos:
  - id: engine-repro-test
    content: Add a minimal failing test that covers async `set` followed by an `if` accessing the assigned value.
    status: completed
  - id: engine-async-design
    content: Finalize the async renderer/interpreter design and decide whether to duplicate or extend `StringSinkRenderer` for async rendering.
    status: completed
  - id: engine-async-impl-core-nodes
    content: Implement async evaluation for calls, assignments, logical operators, attribute/item access, and `if` in the new async renderer.
    status: completed
  - id: engine-wire-async-renderer
    content: Wire `AsyncRenderer.render` and `Template.renderAsync` to use the new async evaluation path instead of the sync `_baseRenderer` + `_AsyncCollectingSink` for control-flow semantics.
    status: completed
  - id: engine-regression-tests
    content: Update `real_world_test.dart` login scenario and add regression tests to ensure async `set` values are visible to subsequent `if`/expressions.
    status: completed
  - id: engine-docs-async-behavior
    content: Update project documentation to describe async rendering behavior, supported patterns, and limitations.
    status: completed
isProject: false
---

# Async `set` assignment fix in jinja.dart

I'm using the writing-plans skill to create the implementation plan.

## Background and Problem Statement

- **Current behavior**: `AsyncRenderer.render` wraps the sync `StringSinkRenderer` in an `_AsyncCollectingSink`. When `visitAssign` sees a `Future` value, it registers an assignment `Future` with the collecting sink via `writeAssignmentFuture`, but the template body (including `{% if %}` conditions) is still evaluated synchronously using the *old* context.
- **Symptom in `example/real_world_test.dart`**: In the template snippet
  - `{% set login_response = jinja_action("handle_on_login","db") %}`
  - followed immediately by an `if` that reads `login_response.workflow_results...`,
  the `if` executes before the `jinja_action` future has completed and before the assignment has updated the context, so `login_response` resolves to `null` and attribute access throws `UndefinedError`.
- **Goal**: Make async `set` behave intuitively: when a template assigns from an async call, any *subsequent* expressions and control-flow that read that variable should see the resolved value, not `null`/undefined.

### Observed Runtime Failure (Current Engine)

- **Trace details**: The debug logs for `example/real_world_test.dart` show:
  - `visitAssign` sees `value=Instance of 'Future<dynamic>'`, logs `Value is Future`, and `_AsyncCollectingSink.writeAssignmentFuture` tracks the assignment future.
  - Immediately afterward, `visitIf` runs and the condition is evaluated; `visitName` for `login_response` (load) logs `Variable "login_response" NOT FOUND` and resolves it to `null`.
  - `visitAttribute` then attempts to access `workflow_results` on this `null` value, causing `UndefinedError: Cannot access attribute 'workflow_results' on a null object` at `StringSinkRenderer.visitAttribute`.
- **Implication**: The assignment future is only awaited *after* synchronous template evaluation has completed, so variable binding in the context lags behind control-flow evaluation. The plan must ensure that in async mode, the assignment completes and updates the context before any later `if`/expression that reads `login_response` executes, so this runtime error cannot occur.

## High-Level Design

- **Approach**: Introduce a truly async evaluation path for template nodes that can depend on async values (assignments, function calls, conditionals), rather than trying to retrofit semantics purely via `_AsyncCollectingSink` post-processing.
- **Key idea**: For async rendering (`Template.renderAsync`), route evaluation of statements/expressions through an async-aware interpreter that can `await`:
  - async globals before rendering (already done),
  - async function calls inside expressions and `set` assignments,
  - and only then evaluate `if`/logical operators and attribute access.
- **Scope**: Keep the existing sync `StringSinkRenderer` unchanged for `render` (purely sync templates), and add a new async-specific renderer or interpreter used solely by `AsyncRenderer.render`.

## Architecture Decisions

- **Preserve public API behavior**: `Template.render` remains purely synchronous and unchanged; all async semantics are provided only via `Template.renderAsync`, avoiding breaking changes for existing users.
- **Async renderer as a separate path**: Implement async evaluation in a dedicated renderer/interpreter (e.g. `AsyncStringSinkRenderer` or `AsyncInterpreter`) that reuses the existing AST and context types but does not change `StringSinkRenderer` semantics.
- **Minimal surface-area for changes**: Restrict engine modifications to `lib/src/renderer.dart` (and an optional `lib/src/async_renderer.dart`) plus `Template.renderAsync` wiring, leaving parser, lexer, and runtime APIs untouched.
- **Streaming output compatibility**: Keep `_AsyncCollectingSink` available for streaming async outputs (e.g. `{{ async_call() }}`) but remove its role in controlling assignment and `if` semantics so variable binding and control-flow are driven by the async renderer instead of post-processing.

### External Best-Practice Alignment

- **Jinja2 async patterns**: Python Jinja2’s own async support (`render_async`, async loaders) treats async evaluation as a separate execution path and does not attempt to magically await coroutines inside otherwise-synchronous code paths. Mirroring this, `renderAsync` in jinja.dart should have a clearly documented async semantics model instead of trying to “retrofit” async on top of the sync renderer.
- **Template semantics over transport**: The engine should guarantee that from the template author’s perspective, `{% set x = async_call() %}` followed by `{% if x and x.foo %}` behaves as if `async_call()` completed before the `if`, regardless of whether output is streamed or buffered.
- **Explicit async limitations**: Similar to upstream Jinja2, explicitly document any constructs that remain unsupported or discouraged in async mode (e.g. deeply nested async calls inside macros, or custom filters that return Futures but are used in sync-only contexts), and ensure the engine fails with clear `TemplateError` messages instead of surprising runtime type errors on `Future`/null values.

## Plan

### Task 1: Tighten Understanding and Add a Minimal Repro Test

- **Files**:
  - Modify: `example/real_world_test.dart` (template snippet around lines 9–11)
  - Add: A focused unit/integration test under `test/` that exercises async `set` + `if` (e.g. `test/async_set_if_test.dart`).
- **Steps**:
  - Extract the minimal failing pattern into a small template:
    - e.g. `{% set result = async_func() %}{% if result and result.foo %}OK{% endif %}` where `async_func` returns a `Future<Map>`.
  - Register a mock `async_func` global in the test environment that returns a completed `Future` with a known value.
  - Assert that `renderAsync` currently either throws or fails to render `OK` even though the async call succeeds.
  - This test should **fail** with current code and become the primary guard for the fix.

### Task 2: Design the Async Evaluation Strategy

- **Files**:
  - Inspect only: `lib/src/renderer.dart`, `lib/src/runtime.dart`, `lib/src/nodes/*.dart` as needed.
- **Steps**:
  - Decide on the async renderer structure:
    - Option 1 (preferred for clarity): Create a new `AsyncStringSinkRenderer` that mirrors `StringSinkRenderer` but with async methods (e.g. `FutureOr<Object?> visitX(...)`).
    - Option 2 (fallback): Create a separate `AsyncInterpreter` that walks the AST without relying on the existing `accept`/visitor types, using `switch`/type checks per node.
  - Evaluate impact on existing APIs:
    - Keep `Template.render` behavior 100% unchanged.
    - Ensure `Template.renderAsync` becomes the single entry point for async evaluation and uses the new async renderer.
  - Decide where async values can appear and must be supported:
    - RHS of `Assign` (`{% set x = async_call() %}`).
    - Function calls and filters inside expressions used in `if`, `for`, and output.
    - Attribute/item access on objects returned by async calls.

### Task 3: Implement Async Node Evaluation

- **Files**:
  - Modify: `lib/src/renderer.dart`
  - Possibly add: `lib/src/async_renderer.dart` (if you prefer to separate async logic for readability).
- **Steps**:
  - Implement an async rendering entry point, e.g. `Future<void> renderAsyncNode(TemplateNode node, AsyncRenderContext context)` that:
    - Writes directly to `context.sink` (no extra collecting sink for control-flow), or uses a simpler collecting sink only for streaming output, **not** for controlling semantics.
  - Implement async-aware evaluation for the key node types first:
    - **Function calls (`visitCall`)**: When the callable returns a `Future`, `await` it before returning the value to the caller.
    - **Assignments (`visitAssign`)**: If the RHS evaluates to a `Future`, `await` it and then call `context.assignTargets(target, resolvedValue)` before returning; this guarantees that any subsequent `visitName` sees the resolved value.
    - **Conditionals (`visitIf`)**: Ensure the test expression is fully resolved (await any nested futures in logical expressions and attribute access) before deciding which branch to visit.
    - **Logical operators (`visitLogical`)**: When either side can be async, `await` the left, apply short-circuit rules, and only `await` the right if needed.
    - **Attribute and item access (`visitAttribute`, `visitItem`)**: If the base value is the result of an async call, ensure it is resolved (or that it can never be a `Future` because `visitCall` already awaited it) so attribute access never sees `Future`.
  - For nodes that never involve async (e.g. literals), keep them essentially identical to the current sync implementation.
  - Leave the existing `_AsyncCollectingSink` in place for now if it’s still useful for streaming async outputs, but ensure that semantics of variable binding and control-flow no longer depend on it.

### Task 4: Wire AsyncRenderer to Use the New Async Evaluation

- **Files**:
  - Modify: `lib/src/renderer.dart` (`AsyncRenderer.render` implementation)
  - Modify if needed: `lib/src/environment.dart` (`Template.renderAsync`).
- **Steps**:
  - Keep the pre-step where async globals and context variables in `context.parent`/`context.data` are resolved before rendering (the existing `resolvedGlobals` / `resolvedData` logic).
  - Replace the call to `_baseRenderer.visitTemplateNode(node, syncContext)` + `_AsyncCollectingSink.getResolvedContent()` with:
    - A call to the new async renderer on the same AST (`await asyncRenderer.renderTemplateNode(node, asyncContext)`), writing directly to the final sink.
  - Remove or reduce dependence on `_AsyncCollectingSink` for control-flow semantics; keep it only if you still need deferred replacement for async outputs written mid-stream.

### Task 5: Update the Real-World Example and Add Regression Tests

- **Files**:
  - Modify: `example/real_world_test.dart` (ensure the `login_response` condition is logically correct and null-safe, e.g. `if login_response and login_response.workflow_results ...`).
  - Modify/Add: `test/` files that cover:
    - Async `set` followed by an `if` using attributes from the async result.
    - Async `set` followed by multiple conditionals and outputs.
    - Edge cases where the async call fails or returns `null`.
- **Steps**:
  - Re-run the minimal repro test from Task 1 and confirm it now passes.
  - Add a regression test that mirrors the `real_world_test.dart` login flow: verify that when the mocked `jinja_action("handle_on_login","db")` returns a structure with a non-empty token, the template’s `if` branch executes correctly under `renderAsync`.

### Task 6: Documentation and Limitations

- **Files**:
  - Modify: `README.md` or relevant docs under `docs/` (if present) to document async behavior.
- **Steps**:
  - Document the supported async patterns clearly:
    - Async globals and context variables.
    - Async function calls and filters inside `{% set %}`, `if` conditions, and output expressions.
  - Call out any remaining limitations (e.g. if there are constructs where async still isn’t supported) so users know what to avoid.
  - Note that `render` remains purely synchronous; async behavior is only guaranteed under `renderAsync`.

## Testing Strategy and Validation

- **Unit / integration tests**:
  - Add focused tests under `test/async_set_if_test.dart` that cover:
    - Successful async `set` followed by an `if` using attributes from the async result.
    - Multiple reads of the same async-assigned variable across several conditionals and output expressions.
    - Failure modes where the async call throws or returns `null`, ensuring errors are surfaced as `TemplateError` with useful context.
  - Add a regression test that mirrors the real-world login flow in `example/real_world_test.dart` to guard against future regressions.
- **Regression guardrail**:
  - Keep the minimal repro test from Task 1 and the real-world login scenario test as permanent fixtures; they should both fail if async `set` semantics regress.
- **Verification commands**:
  - Run `dart analyze` to ensure no analyzer errors are introduced.
  - Run `dart test` (and, if needed, `dart test test/async_set_if_test.dart`) to verify all new and existing tests pass.

## Todos

- **engine-repro-test**: Add a minimal failing test that covers async `set` followed by an `if` accessing the assigned value.
- **engine-async-design**: Finalize the async renderer/interpreter design and decide whether to duplicate or extend `StringSinkRenderer`.
- **engine-async-impl-core-nodes**: Implement async evaluation for calls, assignments, logical operators, attribute/item access, and `if`.
- **engine-wire-async-renderer**: Wire `AsyncRenderer.render` and `Template.renderAsync` to use the new async evaluation path.
- **engine-regression-tests**: Update `real_world_test.dart` login scenario tests and add regression tests ensuring async `set` works as expected.
- **engine-docs-async-behavior**: Update documentation to describe supported async patterns and any remaining limitations.

