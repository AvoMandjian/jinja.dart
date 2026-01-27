# jinja

[![Pub Package][pub_icon]][pub]
[![Test Status][test_ci_icon]][test_ci]
[![CodeCov][codecov_icon]][codecov]

[Jinja][jinja] (3.x) server-side template engine port for Dart 2.
Variables, expressions, control structures and template inheritance.

## Version 0.6.0 introduces breaking changes
- `FilterArgumentError` error class removed
- `*args` and `**kwargs` arguments support removed
- Auto-escaping and related statements, filters and tests have been removed due to the impossibility of extending `String`.
  Use the `escape` filter manually or escape values before passing them to the template.

For more information, see `CHANGELOG.md`.

## Documentation
It is mostly similar to [Jinja][jinja_templates] templates documentation, differences provided below.

_work in progress_.

## Differences with Python version
- The `default` filter compares values with `null`.
- The `defined` and `undefined` tests compare values with `null`.
- The `map` filter also compares values with `null`.
  Use `attribute` and `item` filters for `object.attribute` and `object[item]` expressions.
- If `Environment({getAttribute})` is not passed, the `getItem` method will be used.
  This allows you to use `{{ map.key }}` as an expression equivalent to `{{ map['key'] }}`.
- String slices and negative indexes are not supported.
- Macro arguments without default values are required.
- Not supported:
  - Template module.
- _work in progress_

## Dynamically invoked members (can increase the size of the JS output)
- `[]`, `+`, `-`, `*`, `/`, `~/`, `%` operators
- `object.length` getter
- `object.call` getter
- `Function.apply(function, ...)`

## Example
```dart
import 'package:jinja/jinja.dart';

// ...

var environment = Environment(blockStart: '...', blockEnd: '...');
var template = environment.fromString('...source...');
print(template.render({'key': value}));
// or write directly to StringSink (IOSink, HttpResponse, ...)
template.renderTo(stringSink, {'key': value});
```

See also examples with [conduit][conduit_example] and
[reflectable][reflectable_example].

## Error Handling Example

```dart
import 'package:jinja/jinja.dart';

var env = Environment();
var template = env.fromString('''
  {% for user in users %}
    <div>{{ user.name }}</div>
  {% endfor %}
''');

try {
  // This will throw UndefinedError with enhanced context
  template.render({'users': null});
} on UndefinedError catch (e) {
  print(e.toString());
  // Output includes:
  // - Location (template path, line, column)
  // - Available variables
  // - Suggestions for fixing the error
}
```

### Common Error Scenarios

**Undefined Variable**:
```dart
// Template: {{ userName }}
// Error includes: similar variable names, available variables, suggestions
```

**Attribute Access on Null**:
```dart
// Template: {{ user.name }}
// Context: user = null
// Error includes: available attributes, suggestions for null checks
```

**Filter Not Found**:
```dart
// Template: {{ text|uppercase }}
// Error includes: similar filter names, available filters
```

**Syntax Error**:
```dart
// Template: {% if condition %}
// Error includes: context snippet, tag stack, suggestions
```

## Enhanced Error Messages

The Jinja library now provides comprehensive, actionable error messages with rich context to help you quickly identify and fix template errors.

### Features

- **Detailed Location Information**: Template path, line number, and column where errors occur
- **Context Snapshots**: Variable state at the time of error (sanitized, max 50 variables)
- **Actionable Suggestions**: Specific recommendations for fixing common errors
- **Fuzzy Matching**: Suggestions for similar variable/filter/test names when typos occur
- **Call Stack**: Rendering call stack showing template → macro → include chain
- **Node Information**: AST node type and details where the error occurred

### Example Error Output

**Before** (basic error):
```
UndefinedError: Cannot access attribute `name` on a null object.
```

**After** (enhanced error):
```
UndefinedError: Cannot access attribute `name` on a null object.
  Location: template 'users.html', line 15, column 8
  Node: Attribute (user.name)
  Operation: Accessing attribute 'name' on null object
  Context:
    - Template: 'users.html'
    - Variable 'user': null
    - Available variables: ['users', 'userList', 'currentUser']
  Suggestions:
    - Check if 'user' is defined before accessing 'name': {% if user %}{{ user.name }}{% endif %}
    - Verify the variable name spelling (did you mean 'users' or 'currentUser'?)
    - Ensure 'user' is passed to the template context
```

### Error Types

All error types (`TemplateSyntaxError`, `TemplateRuntimeError`, `UndefinedError`, `TemplateNotFound`, `TemplateAssertionError`) now include:

- **Location**: Template path, line, and column
- **Node**: AST node where error occurred
- **Operation**: Description of what was being performed
- **Context**: Variable state snapshot (sanitized)
- **Suggestions**: Actionable fix recommendations
- **Call Stack**: Template rendering call chain

### Context Size Limits

To prevent memory issues, context capture has built-in limits:

- **Maximum 50 variables** in context snapshot
- **Maximum 10KB** total context size (truncated if exceeded)
- **Maximum 10 stack frames** in call stack
- **Sensitive data** automatically excluded (see below)

### Sensitive Data Handling

The error system automatically sanitizes sensitive information from context snapshots. Keys matching these patterns are excluded:

- `*password*`
- `*secret*`
- `*token*`
- `*key*`
- `*api_key*`
- `*auth*`

This ensures that sensitive credentials are never included in error messages or logs.

### ErrorLogger (Optional)

For structured logging, you can configure an `ErrorLogger`:

```dart
import 'package:jinja/jinja.dart';
import 'package:jinja/src/error_logger.dart';

final env = Environment(
  // ErrorLogger is optional - enhanced exceptions work without it
  // errorLogger: ErrorLogger(level: LogLevel.error),
);

// Enhanced exceptions automatically include all context
try {
  template.render({'user': null});
} catch (e) {
  // Error contains: location, context, suggestions, call stack
  print(e.toString());
}
```

### Backward Compatibility

All enhancements are **additive** - existing code continues to work without changes. Enhanced error messages are automatically included when errors occur.

## Status:
### TODO:
- `Template` class:
  - `generate` method
  - `stream` method
- Relative template paths
- Async Support
- Template Inheritance
  - Super Blocks
    - `{{ super.super() }}`
- List of Control Structures
  - Extends
    - Execute non-`block` statements and expressions
      ```jinja
      {% extends 'base.html' %}
      {% set title = 'Index' %}
      {% macro header() %}
        <h1>{{ title }}</h1>
      {% endmacro %}      ```
      {% block body %}
        {{ header() }}
      {% endblock %}
      ```
- Expressions
  - Dart Methods and Properties
    - `!.`/`?.`
- Loaders
  - PackageLoader (VM)
  - ...
- List of Global Functions
  - `lipsum`
  - `cycler`
  - `joiner`
- Extensions
  - i18n
  - Loop Controls
  - Debug Statement
- Template compiler (builder)
- ...

### Done:
**Note**: ~~item~~ - _not supported_
- Informative error messages ✅
  - Template name ✅
  - Source span ✅
  - Enhanced context (variables, suggestions, call stack) ✅
- Variables
- Filters
  - ~~`forceescape`~~
  - ~~`safe`~~
  - ~~`unsafe`~~
- Tests
  - ~~`escaped`~~
- Comments
- Whitespace Control
- Escaping (only `escape` filter)
- Line Statements
  - Comments
  - Blocks
- Template Inheritance
  - Base Template
  - Child Template
  - Super Blocks
  - Nesting extends
  - Named Block End-Tags
  - Block Nesting and Scope
  - Required Blocks
  - Template Objects
- ~~HTML Escaping~~
- List of Control Structures
  - For
  - If
  - Macro
  - Call
  - Filters
  - Assignments
  - Block Assignments
  - Extends
  - Blocks
  - Include
  - Import
- Import Context Behavior
- Expressions with [filters][filters] and [tests][tests]
  - Literals
    - `"Hello World"`
    - `42` / `123_456`
    - `42.23` / `42.1e2` / `123_456.789`
    - `['list', 'of', 'objects']`
    - `('tuple', 'of', 'values')`
    - `{'dict': 'of', 'key': 'and', 'value': 'pairs'}`
    - `true` / `false`
    - `null`
  - Math
    - `+`
    - `-`
    - `/`
    - `//`
    - `%`
    - `*`
    - `**`
  - Comparisons
    - `==`
    - `!=`
    - `>`
    - `>=`
    - `<`
    - `<=`
  - Logic
    - `and`
    - `or`
    - `not`
    - `(expr)`
  - Other Operators
    - `in`
    - `is`
    - `|`
    - `~`
    - `()`
    - `.`/`[]`
  - If Expression
    - `{{ list.last if list }}`
    - `{{ user.name if user else 'Guest' }}`
  - Dart Methods and Properties (if reflection is on)
    - `{{ string.toUpperCase() }}`
    - `{{ list.add(item) }}`
- List of Global Functions
  - ~~`dict`~~
  - `print`
  - `range`
  - `list`
  - `namespace`
- Loaders
  - `FileSystemLoader`
  - `MapLoader` (`DictLoader`)
- Extensions
  - Expression Statement
  - With Statement
- ~~Autoescape Overrides~~

## Contributing
Contributions are welcome! Please open an issue or pull request on GitHub.
Look at the ToDo list and comments in the code for ideas on what to work on.
There are no strict rules, but please try to follow the existing code style.

As non-native English speaker and learner, I will be grateful for any
corrections in the documentation and code comments.

## Support
Post issues and feature requests on the GitHub [issue tracker][issues].

[pub_icon]: https://img.shields.io/pub/v/jinja.svg
[pub]: https://pub.dev/packages/jinja
[test_ci_icon]: https://github.com/ykmnkmi/jinja.dart/actions/workflows/test.yaml/badge.svg
[test_ci]: https://github.com/ykmnkmi/jinja.dart/actions/workflows/test.yaml
[codecov_icon]: https://codecov.io/gh/ykmnkmi/jinja.dart/branch/main/graph/badge.svg?token=PRP3DHMO48
[codecov]: https://codecov.io/gh/ykmnkmi/jinja.dart
[jinja]: https://www.palletsprojects.com/p/jinja
[jinja_templates]: https://jinja.palletsprojects.com/en/3.0.x/templates
[conduit_example]: https://github.com/ykmnkmi/jinja_conduit_example
[reflectable_example]: https://github.com/ykmnkmi/jinja_reflectable_example
[filters]: https://github.com/ykmnkmi/jinja.dart/blob/master/lib/src/filters.dart
[tests]: https://github.com/ykmnkmi/jinja.dart/blob/master/lib/src/tests.dart
[issues]: https://github.com/ykmnkmi/jinja.dart/issues