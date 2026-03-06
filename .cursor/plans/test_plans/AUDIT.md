# Jinja.dart Test Audit & Folder Plans

This directory contains the detailed plans for testing individual components to improve coverage.

## Overview
- `renderer_TEST_PLAN.md`: Tests for `lib/src/renderer.dart` (visitSlice, visitFor, etc.)
- `filters_TEST_PLAN.md`: Tests for `lib/src/filters.dart` (doFromJson, doRandom, doSafe, doItem)
- `runtime_debug_TEST_PLAN.md`: Tests for `lib/src/runtime.dart` and `lib/src/debug/*.dart`
- `security_TEST_PLAN.md`: Tests for ReDoS and Parser Stack Overflow vulnerabilities

## Test Audit Status

| Area | Component | Status | Missing Branches / Edge Cases |
| :--- | :--- | :--- | :--- |
| **Renderer** | `visitSlice` | Pending | Negative indices, invalid stops, `TemplateRuntimeError` |
| **Renderer** | `visitFor` | Pending | Empty arrays, complex loops |
| **Renderer** | `visitInterpolation` | Pending | Standard variables, arithmetic |
| **Renderer** | `visitTrans` | Pending | Translation blocks |
| **Renderer** | `visitName` | Pending | Context variable resolution |
| **Filters** | `doFromJson` | Pending | Scalars (`'42'`, `'true'`, `'null'`), malformed JSON |
| **Filters** | `doRandom` | Pending | Deterministic behavioral check, empty iterables |
| **Filters** | `doSafe` | Pending | Idempotency (`SafeString`), non-strings, nulls |
| **Filters** | `doItem` | Pending | List out-of-bounds, Map missing keys, MapEntry invalid index |
| **Runtime** | `Context` | Pending | Fallbacks (`data` -> `parent` -> `globals`), `undefined()` behaviors |
| **Debug** | `Evaluator` / `DebugRenderer` | Pending | Debug output formatting, tracebacks (`BreakpointInfo`) |
| **Loaders** | `FileSystemLoader` | Pending | `ignore missing`, disk I/O tests via temporary directories |
| **Security** | Lexer | Pending | ReDoS vulnerabilities, `Timeout` constraints |
| **Security** | Parser | Pending | Stack Overflow vulnerabilities, max depth constraints |
