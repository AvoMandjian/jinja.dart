---
name: Enable Dynamic Global Data in Jinja Loader
overview: Updated `jinja.dart` core to allow dynamic resolution of global variables directly from the loader, enabling immediate visibility of runtime updates to `globalJinjaData` within the same render cycle.
todos:
  - id: update_loaders
    content: Modify `lib/src/loaders.dart` to expose `globalJinjaData` via `Loader.globals`.
    status: completed
  - id: update_runtime
    content: Modify `lib/src/runtime.dart` to resolve variables from `environment.loader?.globals`.
    status: completed
isProject: false
---

I have modified the `jinja.dart` library to support dynamic global data updates as requested.

### Changes Made

1. **Modified `lib/src/loaders.dart`**:
  - Added `Map<String, Object?>? get globals` getter to the abstract `Loader` class.
  - Implemented this getter in `MapLoader` to return `globalJinjaData`.
2. **Modified `lib/src/runtime.dart`**:
  - Updated `Context.resolve`, `Context.resolveAsync`, and `Context.has` to check `environment.loader?.globals` as a fallback.
  - This ensures that any variable not found in the local context or template-level globals (captured at load time) is looked up dynamically in the loader's current globals.

### How it works now

When you update `loader.globalJinjaData` inside a function like `run_data_source`:

```dart
loader.globalJinjaData['data'] = ...;
```

The subsequent expression `{{ data.result }}` in your Jinja script will now:

1. Check local context (not found).
2. Check template globals (not found, as it wasn't there at load time).
3. **Check `environment.loader.globals` (found!)**.

This makes the data available immediately in the same render pass, fixing the issue where it was only available on the second run.

### Verification

I created and ran a test case confirming that updates to `globalJinjaData` are immediately reflected in `template.render()` without needing a reload.