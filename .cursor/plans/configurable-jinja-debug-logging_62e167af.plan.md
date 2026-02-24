---
name: configurable-jinja-debug-logging
overview: Make all existing [DEBUG-JINJA] logs in the core renderer/runtime optional behind a boolean flag that can be enabled from the real_world_test example, defaulting to disabled.
todos:
  - id: inspect-config-and-logging
    content: Inspect `Environment` and logging utilities in `lib/src/environment.dart` (and any shared logging helpers) to decide exact placement of the debug flag and helper.
    status: completed
  - id: add-environment-flag
    content: Add `enableJinjaDebugLogging` (default false) to `Environment` (or central config) and wire it through constructors/factories.
    status: completed
  - id: add-debug-helper
    content: Implement a guarded debug helper (e.g. `Environment.debugJinja`) that checks the flag and delegates to existing logging.
    status: completed
  - id: update-runtime-logs
    content: Replace direct `[DEBUG-JINJA]` `log(...)` calls in `lib/src/runtime.dart` with the new helper, threading `Environment` access if needed.
    status: completed
  - id: update-renderer-logs
    content: Replace direct `[DEBUG-JINJA]` `log(...)` calls in `lib/src/renderer.dart` with the new helper, threading `Environment` access if needed.
    status: completed
  - id: update-real-world-example
    content: "Update `example/real_world_test.dart` to pass `enableJinjaDebugLogging: true` when constructing the environment to demonstrate the feature."
    status: completed
  - id: verification-steps
    content: Verify behavior with flag off/on, and run `dart analyze` and `dart test` to ensure no regressions.
    status: completed
isProject: false
---

## Enhancement Summary

**Deepened on:** 2026-02-24  
**Sections enhanced:** Goal, High-level design, Implementation steps  

### Key improvements

1. Clarified that `[DEBUG-JINJA]` logs are controlled by a single `enableJinjaDebugLogging` flag to keep the default behavior silent.
2. Introduced a dedicated, pluggable `JinjaLogger` service with levelled APIs (`debug/info/warn/error`) that can be injected from examples or host applications.
3. Added guidance based on Dart logging best practices (avoiding direct `print`, using dependency-injected loggers, and keeping logging overhead low when disabled).

## Goal

Add a boolean configuration flag (e.g. `enableJinjaDebugLogging`) on the core `Environment` (or equivalent central config) that controls all existing `[DEBUG-JINJA]` logs in `lib/src/renderer.dart` and `lib/src/runtime.dart`, with a default of `false`, and expose it so `example/real_world_test.dart` can turn it on.

## High-level design

- **New flag on core config**
  - Add a `bool enableJinjaDebugLogging` field (default `false`) on the central configuration object used by the renderer/runtime (likely `Environment` in `[lib/src/environment.dart](/Users/avo/Documents/Workplace/Projects/forked_projects/jinja.dart/lib/src/environment.dart)`).
  - Ensure this flag is constructible from user code and specifically used in `[example/real_world_test.dart](/Users/avo/Documents/Workplace/Projects/forked_projects/jinja.dart/example/real_world_test.dart)` so the example can toggle it.
- **Centralize debug logging helper**
  - Introduce a small helper in the core layer (e.g. `Environment.debugLog(String message)` or a top-level `debugJinjaLog(Environment env, String message)`) that:
    - Checks `enableJinjaDebugLogging` and **only emits** when `true`.
    - Uses the existing `log` mechanism (whatever is currently used around these calls) to keep behavior consistent when enabled.
  - Keep the helper close to where `Environment` and logging are already defined so it can be reused by both `renderer.dart` and `runtime.dart`.
- **Wire flag into runtime/renderer**
  - Thread either the flag or a reference to the owning `Environment` into the classes that currently call `log('[DEBUG-JINJA] ...')` (e.g. context and renderer visitor implementations in `[lib/src/runtime.dart](/Users/avo/Documents/Workplace/Projects/forked_projects/jinja.dart/lib/src/runtime.dart)` and `[lib/src/renderer.dart](/Users/avo/Documents/Workplace/Projects/forked_projects/jinja.dart/lib/src/renderer.dart)`).
  - Replace direct `log('[DEBUG-JINJA] ...')` calls with the new helper so they are all guarded by the flag.
  - Ensure the default behavior (no debug logs) remains unchanged when users construct an `Environment` without specifying the flag.
- **Update example to demonstrate usage**
  - In `example/real_world_test.dart`, when constructing the `Environment` (or equivalent entry point), pass `enableJinjaDebugLogging: true` to show how to turn on the logs.
  - Optionally, add a short comment in the example to clarify that this is for verbose internal Jinja debugging.
- **Backwards compatibility and future-proofing**
  - Keep constructor signatures backwards-compatible by adding the new flag as an optional named parameter with a default of `false`.
  - Treat `enableJinjaDebugLogging` as the **single canonical switch** for internal `[DEBUG-JINJA]`-style logs going forward, so any future debug logs follow the same pattern.
- **Dedicated Jinja logging service**
  - Define a `JinjaLogger` abstraction in the core Jinja library with methods like `debug`, `info`, `warn`, and `error`.
  - Store a `JinjaLogger` instance on `Environment` (or the central config) and allow callers to inject a custom implementation from `example/real_world_test.dart` or other host code.
  - Have `enableJinjaDebugLogging` gate only the internal `[DEBUG-JINJA]` debug calls, while other log levels remain under the caller's control.
  - Keep the default logger implementation lightweight (no-op or simple console logger) so that libraries embedding Jinja do not pay logging costs unless they opt in.

## Implementation steps

- **Step 1 – Identify config & logging surfaces**
  - Inspect `Environment` (or equivalent) in `lib/src/environment.dart` to confirm where to add `enableJinjaDebugLogging`.
  - Locate where `log` is defined or imported so the debug helper can delegate to it.
- **Step 2 – Add the flag to Environment**
  - Add `final bool enableJinjaDebugLogging;` with a default of `false` to the `Environment` class (or central config), wiring it through constructors and any factory methods.
- **Step 3 – Implement a guarded debug helper**
  - Add a method such as `void debugJinja(String message)` on `Environment` that:
    - Returns immediately if `!enableJinjaDebugLogging`.
    - Otherwise calls the existing `log` function with the message.
- **Step 4 – Use the helper in runtime**
  - In `lib/src/runtime.dart`, update each `[DEBUG-JINJA]` call to use `environment.debugJinja('...')` (or equivalent), ensuring the relevant `Environment` reference is available in the `Context`/runtime types.
- **Step 5 – Use the helper in renderer**
  - In `lib/src/renderer.dart`, similarly replace direct `[DEBUG-JINJA]` log calls with the helper, threading access to the `Environment` if not already available via the `StringSinkRenderContext` or renderer class.
- **Step 6 – Update real_world_test example**
  - In `example/real_world_test.dart`, set `enableJinjaDebugLogging: true` when constructing the `Environment` used in the example, so that running the example shows the debug logs.
- **Step 7 – Verification plan**
  - Run the example once **without** setting the flag and confirm no `[DEBUG-JINJA]` logs appear.
  - Run the example again **with** `enableJinjaDebugLogging: true` and confirm that all previous `[DEBUG-JINJA]` logs show up as before.
  - Run `dart analyze` and `dart test` to ensure no type or test regressions.

### Research insights

**Best practices**

- Treat logging in a reusable Dart library as a pluggable concern: avoid hard-coded `print`/`stdout` calls and instead depend on an injected logger interface.
- Use log levels consistently (`debug`, `info`, `warning`, `error`) so that host applications can route or filter logs appropriately.
- Keep debug logging behind a fast, boolean flag check (`enableJinjaDebugLogging`) to avoid string interpolation and allocation costs when disabled.

**Implementation details (illustrative)**

```dart
abstract class JinjaLogger {
  void debug(String message);
  void info(String message);
  void warn(String message);
  void error(String message, [Object? error, StackTrace? stackTrace]);
}
```

In this plan, `Environment` would own a `JinjaLogger` instance and a `bool enableJinjaDebugLogging`, and internal code would call a helper like `environment.debugJinja(message)` that checks the flag before delegating to `logger.debug`.

**Edge cases**

- Ensure that logging calls inside hot paths (e.g. tight render loops) are cheap when disabled; avoid expensive string formatting unless the debug flag is on.
- When exposing `JinjaLogger` publicly, document that implementations should be non-throwing (logging failures must not break template rendering).

**References**

- [Add logging for debugging and monitoring](https://dart.dev/learn/tutorial/logging)
- [Dart `logging` package API](https://pub.dev/documentation/logging/latest/logging/logging-library.html)

