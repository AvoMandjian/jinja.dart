---
name: Fix Nested Macros
overview: Fix Jinja.dart template imports to evaluate module context and correctly resolve nested macros, and update example script to use proper Jinja imports.
todos:
  - id: patch-renderer-sync
    content: Patch `StringSinkRenderer` `visitImport` and `visitFromImport` to evaluate module context
    status: completed
  - id: patch-renderer-async
    content: Patch `AsyncStringSinkRenderer` `visitImport` and `visitFromImport` to evaluate module context
    status: completed
  - id: update-example
    content: Update `example/real_world_test.dart` to use Jinja imports
    status: completed
isProject: false
---

# Fix Nested Macros from Loaders

The issue stems from two factors:

1. **Jinja Module Scope:** In standard Jinja (and `jinja.dart`), templates provided via `MapLoader` act as separate files. Their macros are not globally available. To use a macro defined in a different template, you must explicitly import it using `{% from '...' import ... %}`. Because `jinjaScript` didn't import `outer_macro_from_loader`, it evaluated to `null`, causing the exception you saw.
2. **Underlying Bug in `jinja.dart`:** If you *had* imported it, you would have hit a deeper bug in `jinja.dart`. Currently, `jinja.dart`'s renderer (`visitImport` and `visitFromImport`) simply extracts the `Macro` AST nodes and bounds them to the caller's context, without executing the rest of the imported template's statements. Because of this, imported macros are unable to resolve their own nested imports or variables (e.g., `inner_macro_from_loader` would be null inside `outer_macro_from_loader`).

## Implementation Plan

1. **Patch `lib/src/renderer.dart`:**
  Modify `visitImport` and `visitFromImport` inside `StringSinkRenderer` (sync) and `AsyncStringSinkRenderer` (async). 
  - Instead of immediately creating the macro function using an empty derived context, we will evaluate the imported template's `body.accept(this, moduleContext)` first.
  - This ensures all `{% from ... %}` and `{% set ... %}` statements inside the imported template execute and correctly populate the module's context before the macro functions are extracted.
2. **Update `example/real_world_test.dart`:**
  - In `MapLoader`, add the necessary import to `outer_macro_from_loader`:
   `{% from "inner_macro_from_loader" import inner_macro_from_loader %}`
  - In `jinjaScript`, add the import to make `outer_macro_from_loader` available:
  `{% from 'outer_macro_from_loader' import outer_macro_from_loader %}`

