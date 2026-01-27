---
name: jinja-feature-demonstration
overview: Expand `example/async_globals_example.dart` to demonstrate almost every supported Jinja feature, particularly focusing on their asynchronous execution and integration with `renderAsync`.
todos:
  - id: update-loader
    content: Update MapLoader in async_globals_example.dart with base templates and macros.
    status: completed
  - id: add-globals-demo
    content: Add built-in globals demonstration (cycler, joiner, lipsum, etc.).
    status: completed
  - id: add-filters-demo
    content: Add complex filters demonstration (map, select, reject, groupby, etc.).
    status: completed
  - id: add-control-structures-demo
    content: Add control structures demonstration (async if/for, with, set).
    status: completed
  - id: add-macros-demo
    content: Add macros and call blocks demonstration.
    status: completed
  - id: add-inheritance-demo
    content: Add inheritance and inclusion demonstration (extends, include, import).
    status: completed
  - id: add-utils-demo
    content: Add error handling and utility statements (try/catch, do, debug).
    status: completed
  - id: add-custom-globals-demo
    content: Demonstrate custom globals from get_jinja.dart.
    status: completed
isProject: false
---

I will enhance `example/async_globals_example.dart` by adding more comprehensive examples covering built-in globals, filters, tests, and advanced statements like macros, inheritance, and error handling.

1. **Environment Setup**:
  - Update `MapLoader` to include base templates and macros for testing `extends`, `include`, and `import`.
  - Add more mock async data functions.
2. **Built-in Globals & Filters**:
  - Add examples for `cycler`, `joiner`, `lipsum`, `zip`, `range`, `dict`, `list`, `now`.
  - Add complex filter examples: `map`, `select`, `reject`, `groupby`, `sum`, `sort`, `unique`, `batch`, `slice`.
3. **Control Structures & Statements**:
  - **Async if/for**: Test `if` with async conditions and `for` with async iterables.
  - **Macros & Call Blocks**: Define and use macros with async logic.
  - **With & Set**: Demonstrate `with` scope and `set` (both simple and block versions).
  - **Inheritance & Inclusion**: Use `extends`, `block`, `include`, and `import`.
  - **Error Handling**: Demonstrate `try ... catch`.
  - **Do & Debug**: Show usage of `do` for side effects and `debug` for inspection.
4. **Custom Globals from @example/get_jinja.dart**:
  - Demonstrate `get_widget_by_id`, `callback`, `return`, `is_equal`, `translate`, `uuid`, etc.

Essential files:

- `[example/async_globals_example.dart](example/async_globals_example.dart)`: Main entry point for demonstrations.
- `[example/get_jinja.dart](example/get_jinja.dart)`: Environment configuration.

