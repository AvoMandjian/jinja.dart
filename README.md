# jinja

[![Pub Package][pub_icon]][pub]
[![Test Status][test_ci_icon]][test_ci]
[![CodeCov][codecov_icon]][codecov]

[Jinja][jinja] (3.x) server-side template engine port for Dart 2.
Variables, expressions, control structures and template inheritance.

## Table of Contents

- [Installation](#installation)
- [Getting Started](#getting-started)
- [Template Loaders](#template-loaders)
- [Rendering](#rendering)
- [Core Concepts](#core-concepts)
- [Built-ins & Extensions](#built-ins--extensions)
- [Debugging & Error Handling](#debugging--error-handling)
- [Differences from Python Jinja2](#differences-from-python-jinja2)
- [Contributing](#contributing)
- [Support](#support)

## Installation

Add `jinja` to your `pubspec.yaml`:

```yaml
dependencies:
  jinja: ^2.0.0-dev.1
```

Then run:

```bash
dart pub get
```

## Getting Started

### Basic Usage

```dart
import 'package:jinja/jinja.dart';

// Create an environment
var environment = Environment();

// Load a template from a string
var template = environment.fromString('Hello {{ name }}!');

// Render with data
var result = template.render({'name': 'World'});
print(result); // Output: Hello World!
```

### Environment Configuration

The `Environment` class is the central configuration object. You can customize delimiters, auto-escaping, and more:

```dart
var env = Environment(
  // Custom delimiters
  blockStart: '{%',
  blockEnd: '%}',
  variableStart: '{{',
  variableEnd: '}}',
  commentStart: '{#',
  commentEnd: '#}',
  
  // Auto-escaping (disabled by default in v0.6.0+)
  autoEscape: false,
  
  // Whitespace control
  trimBlocks: true,
  leftStripBlocks: true,
  
  // Template optimization
  optimize: true,
  
  // Auto-reload templates (useful for development)
  autoReload: false,
);
```

### Writing to StringSink

For better performance when writing to streams or files:

```dart
import 'dart:io';

var template = env.fromString('Hello {{ name }}!');
var buffer = StringBuffer();
template.renderTo(buffer, {'name': 'World'});
print(buffer.toString()); // Output: Hello World!

// Works with any StringSink, including IOSink
var file = File('output.txt').openWrite();
template.renderTo(file, {'name': 'World'});
await file.close();
```

## Template Loaders

Loaders are responsible for loading templates from various sources. The package provides two built-in loaders:

### MapLoader

Load templates from an in-memory map. Useful for testing or when templates are stored in code:

```dart
var loader = MapLoader({
  'base.html': '''
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}Default Title{% endblock %}</title>
</head>
<body>
    {% block content %}{% endblock %}
</body>
</html>
''',
  'page.html': '''
{% extends "base.html" %}
{% block title %}My Page{% endblock %}
{% block content %}
    <h1>Welcome!</h1>
{% endblock %}
''',
});

var env = Environment(loader: loader);
var template = env.getTemplate('page.html');
print(template.render());
```

### FileSystemLoader

Load templates from the filesystem:

```dart
import 'package:jinja/loaders.dart';

// Single search path
var loader = FileSystemLoader('templates/');

// Multiple search paths
var loader = FileSystemLoader(['templates/', 'layouts/']);

// With file extension filter
var loader = FileSystemLoader(
  'templates/',
  extensions: ['.html', '.jinja'],
);

// Recursive directory scanning
var loader = FileSystemLoader(
  'templates/',
  followLinks: true,
);

var env = Environment(loader: loader);
var template = env.getTemplate('users.html');
```

## Rendering

### Synchronous Rendering

For most use cases, synchronous rendering is sufficient:

```dart
var template = env.fromString('Hello {{ name }}!');
var result = template.render({'name': 'World'});
```

### Asynchronous Rendering

When your data includes `Future` values or you need to await async operations during rendering:

```dart
Future<String> getUserName() async {
  await Future.delayed(Duration(milliseconds: 100));
  return 'Alice';
}

var template = env.fromString('Welcome, {{ user }}!');
var result = await template.renderAsync({
  'user': getUserName(), // Future<String> is automatically awaited
});
print(result); // Output: Welcome, Alice!
```

### Async Globals

You can pass `Future` values directly in the context, and they'll be automatically resolved:

```dart
Future<Map<String, dynamic>> getUser() async {
  await Future.delayed(Duration(milliseconds: 50));
  return {'name': 'Bob', 'age': 30};
}

var template = env.fromString('User: {{ user.name }}, Age: {{ user.age }}');
var result = await template.renderAsync({'user': getUser()});
print(result); // Output: User: Bob, Age: 30
```

### Async Filters and Tests

Filters and tests can also return `Future` values:

```dart
Future<String> fetchData() async {
  await Future.delayed(Duration(milliseconds: 200));
  return 'fetched data';
}

var env = Environment(
  filters: {
    'fetch': (value) async {
      await Future.delayed(Duration(milliseconds: 100));
      return await fetchData();
    },
  },
);

var template = env.fromString('{{ "trigger"|fetch }}');
var result = await template.renderAsync();
print(result); // Output: fetched data
```

## Core Concepts

### Variables and Expressions

Variables are accessed using `{{ }}` syntax:

```dart
var template = env.fromString('''
Hello {{ name }}!
You have {{ count }} messages.
Total: \${{ price * quantity }}
''');

var result = template.render({
  'name': 'Alice',
  'count': 5,
  'price': 10.50,
  'quantity': 3,
});
```

### Literals

Jinja supports various literal types:

```dart
var template = env.fromString('''
String: {{ "Hello World" }}
Number: {{ 42 }}
Float: {{ 3.14 }}
Scientific: {{ 1.23e4 }}
List: {{ [1, 2, 3] }}
Tuple: {{ (1, 2, 3) }}
Dict: {{ {'key': 'value'} }}
Boolean: {{ true }} / {{ false }}
Null: {{ null }}
''');
```

### Math Operations

```dart
var template = env.fromString('''
Addition: {{ 2 + 3 }}
Subtraction: {{ 5 - 2 }}
Multiplication: {{ 2 * 3 }}
Division: {{ 10 / 3 }}
Floor Division: {{ 10 // 3 }}
Modulo: {{ 10 % 3 }}
Power: {{ 2 ** 3 }}
''');
```

### Comparisons

```dart
var template = env.fromString('''
Equal: {{ 5 == 5 }}
Not Equal: {{ 5 != 3 }}
Greater: {{ 5 > 3 }}
Greater or Equal: {{ 5 >= 5 }}
Less: {{ 3 < 5 }}
Less or Equal: {{ 3 <= 3 }}
''');
```

### Logic Operators

```dart
var template = env.fromString('''
And: {{ true and false }}
Or: {{ true or false }}
Not: {{ not false }}
Grouping: {{ (true and false) or (true and true) }}
''');
```

### Conditional Expressions

Inline if-else expressions:

```dart
var template = env.fromString('''
{{ "Yes" if condition else "No" }}
{{ user.name if user else "Guest" }}
{{ list.last if list else "Empty" }}
''');
```

### Control Structures

#### If Statement

```dart
var template = env.fromString('''
{% if user %}
    Hello {{ user.name }}!
{% elif guest %}
    Hello Guest!
{% else %}
    Please log in.
{% endif %}
''');
```

#### For Loop

```dart
var template = env.fromString('''
<ul>
{% for item in items %}
    <li>{{ item }}</li>
{% endfor %}
</ul>

{% for user in users %}
    <div>{{ user.name }} - {{ user.email }}</div>
{% else %}
    <p>No users found.</p>
{% endfor %}
''');
```

#### Loop Variables

The `loop` variable provides information about the current iteration:

```dart
var template = env.fromString('''
{% for item in items %}
    Index: {{ loop.index }} (0-based: {{ loop.index0 }})
    Reverse Index: {{ loop.revindex }} (0-based: {{ loop.revindex0 }})
    First: {{ loop.first }}
    Last: {{ loop.last }}
    Length: {{ loop.length }}
    Previous: {{ loop.prev }}
    Next: {{ loop.next }}
    Cycle: {{ loop.cycle('odd', 'even') }}
{% endfor %}
''');
```

#### Break and Continue

```dart
var template = env.fromString('''
{% for i in range(10) %}
    {% if i == 5 %}{% break %}{% endif %}
    {{ i }}
{% endfor %}

{% for i in range(5) %}
    {% if i == 2 %}{% continue %}{% endif %}
    {{ i }}
{% endfor %}
''');
```

#### Recursive For Loops

Process nested structures recursively:

```dart
var template = env.fromString('''
{% for item in items recursive %}
    {{ item.name }}
    {% if item.children %}
        <ul>{{ loop(item.children) }}</ul>
    {% endif %}
{% endfor %}
''');

var result = template.render({
  'items': [
    {
      'name': 'Root',
      'children': [
        {'name': 'Child 1'},
        {
          'name': 'Child 2',
          'children': [
            {'name': 'Grandchild 1'},
          ],
        }
      ],
    }
  ],
});
```

#### With Statement

Create a scoped variable:

```dart
var template = env.fromString('''
{% with user = {"name": "Alice", "age": 25} %}
    {{ user.name }} is {{ user.age }} years old
{% endwith %}
{{ user.name }} {# Error: user is not defined here #}
''');
```

#### Set Statement

Assign variables:

```dart
var template = env.fromString('''
{% set name = "Bob" %}
{% set count = 0 %}
{% for i in range(5) %}
    {% set count = count + 1 %}
{% endfor %}
Count: {{ count }}
''');
```

#### Set Block

Assign block content to a variable:

```dart
var template = env.fromString('''
{% set content %}
    <div>Hello World</div>
{% endset %}
{{ content|upper }}
''');
```

#### Do Statement

Execute expressions without output:

```dart
var template = env.fromString('''
{% set items = [] %}
{% do items.add("item1") %}
{% do items.add("item2") %}
Items: {{ items|list }}
''');
```

#### Try-Catch

Handle errors gracefully:

```dart
var template = env.fromString('''
{% try %}
    {{ undefined_variable }}
{% catch %}
    Error: Variable is undefined
{% endtry %}
''');
```

### Macros

Macros are reusable template fragments:

```dart
var template = env.fromString('''
{% macro greet(name, greeting="Hello") %}
    {{ greeting }}, {{ name }}!
{% endmacro %}

{{ greet("Alice") }}
{{ greet("Bob", "Hi") }}
''');
```

#### Macro with Call Block

Macros can accept block content:

```dart
var template = env.fromString('''
{% macro render_card(title) %}
<div class="card">
    <h2>{{ title }}</h2>
    {{ caller() }}
</div>
{% endmacro %}

{% call render_card("My Card") %}
    <p>This is the card content</p>
{% endcall %}
''');
```

### Template Inheritance

#### Base Template

```dart
// base.html
var baseTemplate = '''
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}Default Title{% endblock %}</title>
</head>
<body>
    <header>{% block header %}Default Header{% endblock %}</header>
    <main>{% block content %}{% endblock %}</main>
    <footer>{% block footer %}Default Footer{% endblock %}</footer>
</body>
</html>
''';
```

#### Child Template

```dart
// page.html
var pageTemplate = '''
{% extends "base.html" %}
{% block title %}My Page{% endblock %}
{% block content %}
    <h1>Custom Content</h1>
    <p>This is custom content from child template.</p>
{% endblock %}
''';
```

#### Super Blocks

Access parent block content:

```dart
var template = env.fromString('''
{% extends "base.html" %}
{% block header %}
    {{ super() }} - Extended
{% endblock %}
''');
```

#### Required Blocks

Make blocks mandatory:

```dart
var template = env.fromString('''
{% block content required %}
    This block must be defined in child templates
{% endblock %}
''');
```

### Include

Include other templates:

```dart
var template = env.fromString('''
<div>
    <h1>Main Template</h1>
    {% include "partial.html" %}
    {% include "partial.html" ignore missing %}
</div>
''');
```

### Import

Import macros from other templates:

```dart
// macros.html
var macrosTemplate = '''
{% macro render_user(user) %}
<div class="user">
    <h3>{{ user.name }}</h3>
    <p>Age: {{ user.age }}</p>
</div>
{% endmacro %}
''';

// main.html
var mainTemplate = '''
{% import "macros.html" as macros %}
{{ macros.render_user({"name": "Alice", "age": 25}) }}
''';
```

#### From Import

Import specific macros:

```dart
var template = env.fromString('''
{% from "macros.html" import render_user %}
{{ render_user({"name": "Bob", "age": 30}) }}
''');
```

#### Import with Context

Import macros with access to current context:

```dart
var template = env.fromString('''
{% import "macros.html" as m with context %}
{{ m.print_user() }}
''');
```

## Built-ins & Extensions

### Filters

Filters transform variables. Over 120 filters are available. See [JINJA_FILTERS.md](JINJA_FILTERS.md) for a complete list.

#### String Filters

```dart
var template = env.fromString('''
{{ "hello world"|upper }}
{{ "HELLO WORLD"|lower }}
{{ "hello world"|capitalize }}
{{ "hello world"|title }}
{{ "  hello  "|trim }}
{{ "hello world"|replace("world", "Jinja") }}
{{ "hello world"|truncate(5) }}
''');
```

#### List Filters

```dart
var template = env.fromString('''
{{ [3, 1, 4, 1, 5]|sort|list }}
{{ [1, 2, 2, 3, 3, 3]|unique|list }}
{{ [1, 2, 3]|reverse|list }}
{{ [1, 2, 3, 4, 5]|first }}
{{ [1, 2, 3, 4, 5]|last }}
{{ [1, 2, 3]|length }}
{{ [1, 2, 3]|sum }}
{{ [1, 2, 3]|max }}
{{ [1, 2, 3]|min }}
''');
```

#### Map and Select Filters

```dart
var template = env.fromString('''
{{ users|map(attribute="name")|list }}
{{ users|selectattr("active")|list }}
{{ users|rejectattr("active")|list }}
{{ [1, 2, 3, 4]|select("even")|list }}
{{ [1, 2, 3, 4]|reject("odd")|list }}
''');
```

#### Grouping Filters

```dart
var template = env.fromString('''
{% for group in users|groupby("age") %}
    Age {{ group.key }}: {{ group.list|map(attribute="name")|list }}
{% endfor %}
''');
```

#### Batch and Slice Filters

```dart
var template = env.fromString('''
{% for batch in numbers|batch(3) %}
    Batch: {{ batch|list }}
{% endfor %}

{{ numbers|slice(3)|list }}
''');
```

#### Filter Block

Apply filters to block content:

```dart
var template = env.fromString('''
{% filter upper %}
    hello world
{% endfilter %}
''');
```

#### Autoescape Block

Control auto-escaping for a block:

```dart
var template = env.fromString('''
{% autoescape true %}
    {{ "<b>Safe</b>" }}
{% endautoescape %}
{% autoescape false %}
    {{ "<b>Unsafe</b>" }}
{% endautoescape %}
''');
```

### Tests

Tests check conditions. Over 40 tests are available:

#### Type Tests

```dart
var template = env.fromString('''
{% if value is defined %}Value is defined{% endif %}
{% if value is undefined %}Value is undefined{% endif %}
{% if value is none %}Value is null{% endif %}
{% if value is number %}Value is a number{% endif %}
{% if value is integer %}Value is an integer{% endif %}
{% if value is float %}Value is a float{% endif %}
{% if value is string %}Value is a string{% endif %}
{% if value is list %}Value is a list{% endif %}
{% if value is mapping %}Value is a map{% endif %}
{% if value is iterable %}Value is iterable{% endif %}
{% if value is callable %}Value is callable{% endif %}
''');
```

#### Comparison Tests

```dart
var template = env.fromString('''
{% if value == 42 %}Equal to 42{% endif %}
{% if value != 0 %}Not equal to 0{% endif %}
{% if value > 10 %}Greater than 10{% endif %}
{% if value >= 10 %}Greater or equal to 10{% endif %}
{% if value < 100 %}Less than 100{% endif %}
{% if value <= 100 %}Less or equal to 100{% endif %}
{% if value is sameas other %}Same object{% endif %}
{% if item in list %}Item in list{% endif %}
{% if 42 not in list %}42 not in list{% endif %}
''');
```

#### Numeric Tests

```dart
var template = env.fromString('''
{% if value is odd %}Value is odd{% endif %}
{% if value is even %}Value is even{% endif %}
{% if value is divisibleby 2 %}Value is divisible by 2{% endif %}
''');
```

#### String Tests

```dart
var template = env.fromString('''
{% if value is lower %}Value is lowercase{% endif %}
{% if value is upper %}Value is uppercase{% endif %}
{% if value is match "^[A-Z]" %}Value matches pattern{% endif %}
{% if value is search "pattern" %}Value contains pattern{% endif %}
''');
```

### Global Functions

Built-in global functions available in all templates:

#### Range

```dart
var template = env.fromString('''
{% for i in range(5) %}{{ i }}{% endfor %}
{% for i in range(1, 6) %}{{ i }}{% endfor %}
{% for i in range(0, 10, 2) %}{{ i }}{% endfor %}
''');
```

#### Dict

```dart
var template = env.fromString('''
{{ dict(a=1, b=2, c=3) }}
''');
```

#### List

```dart
var template = env.fromString('''
{{ list("hello") }}
{{ list([1, 2, 3]) }}
''');
```

#### Namespace

Create namespace objects for mutable variables:

```dart
var template = env.fromString('''
{% set ns = namespace() %}
{% set ns.count = 0 %}
{% for i in range(5) %}
    {% set ns.count = ns.count + 1 %}
{% endfor %}
Count: {{ ns.count }}
''');
```

#### Cycler

Cycle through values:

```dart
var template = env.fromString('''
{% for i in range(5) %}
    {{ cycler("red", "blue", "green") }}
{% endfor %}
''');
```

#### Joiner

Join items with a separator:

```dart
var template = env.fromString('''
{% set j = joiner(", ") %}
{% for item in ["a", "b", "c"] %}
    {{ j() }}{{ item }}
{% endfor %}
''');
```

#### Zip

Combine multiple iterables:

```dart
var template = env.fromString('''
{% for pair in zip([1, 2, 3], ["a", "b", "c"]) %}
    {{ pair }}
{% endfor %}
''');
```

#### Now

Get current DateTime:

```dart
var template = env.fromString('''
Current time: {{ now() }}
''');
```

#### Lipsum

Generate Lorem ipsum text:

```dart
var template = env.fromString('''
{{ lipsum() }}
{{ lipsum(paragraphs=3) }}
''');
```

### Internationalization (i18n)

The `{% trans %}` tag supports translation:

```dart
// Configure translation functions
var env = Environment(
  globals: {
    'gettext': (String msg) => msg, // Replace with your translation function
    'ngettext': (String singular, String plural, int count) {
      return count == 1 ? singular : plural;
    },
  },
);

var template = env.fromString('''
{% trans %}Hello World{% endtrans %}
{% trans count=items|length %}
    One item
{% plural %}
    {{ count }} items
{% endtrans %}
''');
```

### Whitespace Control

Control whitespace in templates:

```dart
var template = env.fromString('''
{%- if condition -%}
    Content
{%- endif -%}

{{- variable -}}

{#- Comment -#}
''');
```

The `-` character removes whitespace before or after the tag.

### Raw Blocks

Output content without processing:

```dart
var template = env.fromString('''
{% raw %}
    {{ variable }}
    {% if condition %}
{% endraw %}
''');
// Output: {{ variable }} {% if condition %}
```

## Debugging & Error Handling

### Enhanced Error Messages

The Jinja library provides comprehensive, actionable error messages with rich context to help you quickly identify and fix template errors.

#### Features

- **Detailed Location Information**: Template path, line number, and column where errors occur
- **Context Snapshots**: Variable state at the time of error (sanitized, max 50 variables)
- **Actionable Suggestions**: Specific recommendations for fixing common errors
- **Fuzzy Matching**: Suggestions for similar variable/filter/test names when typos occur
- **Call Stack**: Rendering call stack showing template → macro → include chain
- **Node Information**: AST node type and details where the error occurred

#### Example Error Output

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

#### Error Types

All error types (`TemplateSyntaxError`, `TemplateRuntimeError`, `UndefinedError`, `TemplateNotFound`, `TemplateAssertionError`) now include:

- **Location**: Template path, line, and column
- **Node**: AST node where error occurred
- **Operation**: Description of what was being performed
- **Context**: Variable state snapshot (sanitized)
- **Suggestions**: Actionable fix recommendations
- **Call Stack**: Template rendering call chain

#### Context Size Limits

To prevent memory issues, context capture has built-in limits:

- **Maximum 50 variables** in context snapshot
- **Maximum 10KB** total context size (truncated if exceeded)
- **Maximum 10 stack frames** in call stack
- **Sensitive data** automatically excluded (see below)

#### Sensitive Data Handling

The error system automatically sanitizes sensitive information from context snapshots. Keys matching these patterns are excluded:

- `*password*`
- `*secret*`
- `*token*`
- `*key*`
- `*api_key*`
- `*auth*`

This ensures that sensitive credentials are never included in error messages or logs.

#### ErrorLogger (Optional)

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

#### Common Error Scenarios

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

### Debug Statement

Output current context variables:

```dart
var template = env.fromString('''
{% debug %}
''');
```

### Debug Environment

For advanced debugging with breakpoints:

```dart
import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/debug_controller.dart';

var debugController = DebugController();
debugController.enabled = true;

// Add breakpoints
debugController.addBreakpoint(line: 5);
debugController.addBreakpoint(line: 10);

// Set breakpoint handler
debugController.onBreakpoint = (info) async {
  print('Breakpoint hit at line ${info.lineNumber}');
  print('Node Type: ${info.nodeType}');
  print('Variables: ${info.variables}');
  print('Output so far: ${info.outputSoFar}');
};

var env = Environment();
var template = env.fromString('''
{% for item in items %}
    <li>{{ item }}</li>
{% endfor %}
''');

var result = await template.renderDebug(
  {'items': ['a', 'b', 'c']},
  debugController: debugController,
);
```

## Differences from Python Jinja2

### Behavioral Differences

- The `default` filter compares values with `null` instead of Python's `None` semantics
- The `defined` and `undefined` tests compare values with `null`
- The `map` filter also compares values with `null`
  - Use `attribute` and `item` filters for `object.attribute` and `object[item]` expressions
- If `Environment({getAttribute})` is not passed, the `getItem` method will be used
  - This allows you to use `{{ map.key }}` as an expression equivalent to `{{ map['key'] }}`
- String slices and negative indexes are not supported
- Macro arguments without default values are required

### Not Supported

- Template module
- `*args` and `**kwargs` arguments support (removed in v0.6.0)
- Auto-escaping (removed in v0.6.0+)
  - Use the `escape` filter manually or escape values before passing them to the template

### Version 0.6.0 Breaking Changes

- `FilterArgumentError` error class removed
- `*args` and `**kwargs` arguments support removed
- Auto-escaping and related statements, filters and tests have been removed due to the impossibility of extending `String`
  - Use the `escape` filter manually or escape values before passing them to the template

For more information, see `CHANGELOG.md`.

### Dynamically Invoked Members

The following operations can increase the size of JavaScript output when compiling to web:

- `[]`, `+`, `-`, `*`, `/`, `~/`, `%` operators
- `object.length` getter
- `object.call` getter
- `Function.apply(function, ...)`

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
[codecov]: https://codecov.io/gh/ykmnkmi/jinja.dart/branch/main/graph/badge.svg?token=PRP3DHMO48
[jinja]: https://www.palletsprojects.com/p/jinja
[jinja_templates]: https://jinja.palletsprojects.com/en/3.0.x/templates
[conduit_example]: https://github.com/ykmnkmi/jinja_conduit_example
[reflectable_example]: https://github.com/ykmnkmi/jinja_reflectable_example
[filters]: https://github.com/ykmnkmi/jinja.dart/blob/master/lib/src/filters.dart
[tests]: https://github.com/ykmnkmi/jinja.dart/blob/master/lib/src/tests.dart
[issues]: https://github.com/ykmnkmi/jinja.dart/issues
