# All Jinja Examples Combined

This document contains all examples from `async_globals_example.dart` combined into a single comprehensive Jinja template script with all required data.

## Combined Jinja Template Script

```jinja
{# Example 4: Using environment globals #}
Welcome to {{ app_name }}, {{ user }}!

{# Example 5: Async global in a loop #}
<ul>
{% for item in items %}
  <li>{{ item }}</li>
{% endfor %}
</ul>

{# Example 6: Async global with a filter #}
{{ name|upper }}

{# Example 7: Nested async data structure #}
User: {{ user.name }}, Age: {{ user.age }}

{# Example 8: Synchronous global function with renderAsync #}
{{- greet() -}}

{# Example 9: Synchronous filter with renderAsync #}
{{ "hello"|reverse }}

{# Example 10: Synchronous complex object with renderAsync #}
Product: {{ product.name }} - ${{ product.price }}

{# Example 11: Async global in a loop #}
{% for item in items %}{{ item }}{% endfor %}

{# Example 12-13: Async function for calling API with http #}
{{ data }}

{# Example 14: Async global in a filter #}
{{ data|fetchDataFilter }}

{# Example 15: Async global in a global function #}
{{ fetchDataGlobal() }}

{# Example 16: Cycler global #}
{% for i in range(5) %}{{ cycler("red", "blue", "green") }}{% endfor %}

{# Example 17: Joiner global #}
{% set j = joiner(", ") %}{% for item in ["a", "b", "c"] %}{{ j() }}{{ item }}{% endfor %}

{# Example 18: Range global #}
{% for i in range(1, 6) %}{{ i }}{% endfor %}

{# Example 19: Dict global #}
{{ dict(a=1, b=2, c=3) }}

{# Example 20: List global #}
{{ list("hello") }}

{# Example 21: Zip global #}
{% for pair in zip([1, 2, 3], ["a", "b", "c"]) %}{{ pair }}{% endfor %}

{# Example 22: Now global #}
Current time: {{ now() }}

{# Example 23: Map filter #}
{{ users|map(attribute="name")|list }}

{# Example 24: Select filter #}
{{ users|select("defined")|list }}

{# Example 25: Reject filter #}
{{ users|reject("defined")|list }}

{# Example 26: Groupby filter #}
{% for group in users|groupby("age") %}{{ group.key }}: {{ group.list|map(attribute="name")|list }}{% endfor %}

{# Example 27: Sum filter #}
Total: {{ numbers|sum }}

{# Example 28: Sort filter #}
{{ numbers|sort|list }}

{# Example 29: Unique filter #}
{{ numbers|unique|list }}

{# Example 30: Batch filter #}
{% for batch in numbers|batch(3) %}{{ batch|list }}{% endfor %}

{# Example 31: Slice filter #}
{{ numbers|slice(3)|list }}

{# Example 32: Selectattr filter #}
{{ users|selectattr("active")|list }}

{# Example 33: Rejectattr filter #}
{{ users|rejectattr("active")|list }}

{# Example 34: Async if condition #}
{% if condition %}Condition is true{% else %}Condition is false{% endif %}

{# Example 35: Async for loop with else #}
{% for item in items %}{{ item }}{% else %}No items{% endfor %}

{# Example 36: With statement #}
{% with user = {"name": "Alice", "age": 25} %}{{ user.name }} is {{ user.age }} years old{% endwith %}

{# Example 37: Set statement #}
{% set name_var = "Bob" %}{{ name_var }}

{# Example 38: Set block #}
{% set content_block %}<div>Hello World</div>{% endset %}{{ content_block }}

{# Example 39: For loop with loop variables #}
{% for item in items %}{{ loop.index }}: {{ item }}{% endfor %}

{# Example 40: Define and use macro #}
{% macro greet_person(name) %}
Hello, {{ name }}!
{% endmacro %}
{{ greet_person("Alice") }}
{{ greet_person("Bob") }}

{# Example 41: Macro with default arguments #}
{% macro greet_with_greeting(name, greeting="Hi") %}
{{ greeting }}, {{ name }}!
{% endmacro %}
{{ greet_with_greeting("Alice") }}
{{ greet_with_greeting("Bob", "Hello") }}

{# Example 42: Macro with async data #}
{% macro display_user_info(user) %}
User: {{ user.name }}, Age: {{ user.age }}
{% endmacro %}
{{ display_user_info(user) }}

{# Example 43: Call block #}
{% macro render_card_template(card_title) %}
<div class="card">
    <h2>{{ card_title }}</h2>
    {{ caller() }}
</div>
{% endmacro %}
{% call render_card_template("My Card") %}
    <p>This is the card content</p>
{% endcall %}

{# Example 44: Self-contained template with blocks (no extends) #}
{% macro base_template() %}
<!DOCTYPE html>
<html>
<head>
    <title>{% block page_title %}Default Title{% endblock %}</title>
</head>
<body>
    <header>{% block page_header %}Default Header{% endblock %}</header>
    <main>{% block page_main %}{% endblock %}</main>
    <footer>{% block page_footer %}Default Footer{% endblock %}</footer>
</body>
</html>
{% endmacro %}
{% block page_title %}Custom Title{% endblock %}
{% block page_main %}
<h1>Custom Content</h1>
<p>This is custom content from child template.</p>
{% endblock %}

{# Example 45: Self-contained include (no external file) #}
<div>
    <h1>Main Template</h1>
    <div class="partial">
        <p>This is a partial template included inline.</p>
        <p>Current time: {{ now() }}</p>
    </div>
</div>

{# Example 46: Self-contained macros (no import) #}
{% macro render_user_macro(user) %}
<div class="user">
    <h3>{{ user.name }}</h3>
    <p>Age: {{ user.age }}</p>
</div>
{% endmacro %}

{% macro render_product_macro(product) %}
<div class="product">
    <h4>{{ product.name }}</h4>
    <p>Price: ${{ product.price }}</p>
</div>
{% endmacro %}
{{ render_user_macro({"name": "Alice", "age": 25}) }}
{{ render_product_macro({"name": "Laptop", "price": 1200}) }}

{# Example 47: Direct macro usage (no from import) #}
{{ render_user_macro({"name": "Bob", "age": 30}) }}

{# Example 48: Try catch #}
{% try %}
    {{ undefined_variable }}
{% catch %}
    Error: Variable is undefined
{% endtry %}

{# Example 49: Do statement #}
{% set items_list = [] %}
{% do items_list.add("item1") %}
{% do items_list.add("item2") %}
Items: {{ items_list|list }}

{# Example 50: Break in loop #}
{% for i in range(10) %}
    {% if i == 5 %}{% break %}{% endif %}
    {{ i }}
{% endfor %}

{# Example 51: Continue in loop #}
{% for i in range(5) %}
    {% if i == 2 %}{% continue %}{% endif %}
    {{ i }}
{% endfor %}

{# Example 52: get_widget_by_id #}
{{ get_widget_by_id("widget123") }}

{# Example 53: callback #}
{{ callback("callback_id", {"key": "value"}) }}

{# Example 54: return function #}
{{ return([1, 2, 3]) }}

{# Example 55: is_equal with async #}
{% if is_equal(value, 42) %}Equal{% else %}Not equal{% endif %}

{# Example 56: translate #}
{{ translate("Hello", "en", "fr") }}

{# Example 57: uuid #}
{{ uuid() }}

{# Example 58: get_current_date #}
{{ get_current_date() }}

{# Example 59: Complex filter combinations #}
{{ users|selectattr("active")|map(attribute="name")|list|sort|list }}

{# Example 60: Async data in nested structures #}
{% for user in users %}
    {% if user.active %}
        {{ user.name }} ({{ user.age }})
    {% endif %}
{% endfor %}

{# Example 61: Filter with async input #}
{{ text|upper|title }}

{# Example 62: Multiple async operations #}
{{ name }} is {{ age }} years old

{# Example 63: Tests in conditions #}
{% if value is defined %}Value is defined{% endif %}
{% if value is number %}Value is a number{% endif %}
{% if value is string %}Value is a string{% endif %}
{% if value is even %}Value is even{% endif %}
{% if value is odd %}Value is odd{% endif %}

{# Example 64: Complex expression with async #}
Result: {{ x + y * 2 }}

{# Example 65: Namespace usage #}
{% set ns = namespace() %}
{% set ns.count = 0 %}
{% for i in range(5) %}
    {% set ns.count = ns.count + 1 %}
{% endfor %}
Count: {{ ns.count }}

{# Example 66: Filter block #}
{% filter upper %}
    hello world
{% endfilter %}

{# Example 67: Autoescape #}
{% autoescape true %}
    {{ "<b>Safe</b>" }}
{% endautoescape %}
{% autoescape false %}
    {{ "<b>Unsafe</b>" }}
{% endautoescape %}

{# Example 68: Recursive for loop #}
{% for item in items recursive %}
    {{ item.name }}
    {% if item.children %}
        <ul>{{ loop(item.children) }}</ul>
    {% endif %}
{% endfor %}

{# Example 69: Raw block #}
{% raw %}
    {{ variable }}
    {% if condition %}
{% endraw %}

{# Example 70: Operators (Power and Concat) #}
{{ 2 ** 3 }} ~ {{ "hello" ~ " " ~ "world" }}

{# Example 71: More tests #}
{{ 10 is divisibleby 2 }}
{{ [1, 2] is iterable }}
{{ {"a": 1} is mapping }}
{{ none is none }}

{# Example 72: Inline If (Ternary Operator) #}
{{ "Yes" if true else "No" }} | {{ "Yes" if false else "No" }}

{# Example 73: Membership Operators #}
{{ 1 in [1, 2, 3] }} | {{ 4 not in [1, 2, 3] }}

{# Example 74: Debug statement #}
{% debug %}

{# Example 75: Tuple Unpacking #}
{% set a, b = [10, 20] %}
a: {{ a }}, b: {{ b }}
{% for x, y in points %}
  Point: {{ x }}, {{ y }}
{% endfor %}

{# Example 76: Macro varargs and kwargs #}
{% macro dump_extras() -%}
  Args: {{ varargs|list }}
  Kwargs: {{ kwargs|dictsort }}
{%- endmacro %}
{{ dump_extras(1, 2, a=3, b=4) }}

{# Example 77: Complex Logic #}
{{ (true and false) or (true and true) }}

{# Example 78: Self-contained inheritance pattern (no extends) #}
{% macro base_layout() %}
<!DOCTYPE html>
<html>
<head>
    <title>{% block head_title %}Base Title{% endblock %}</title>
</head>
<body>
    <header>{% block head_header %}Base Header{% endblock %}</header>
</body>
</html>
{% endmacro %}
{% block head_header %}
    Base Header - Extended
{% endblock %}

{# Example 79: Jinja Comments and Math #}
{# This is a comment and will not be rendered #}
Modulo: {{ 10 % 3 }}
Floor Division: {{ 10 // 3 }}

{# Example 80: Loop Cycle #}
{% for i in range(4) %}
    {{ i }} is {{ loop.cycle('even', 'odd') }}
{% endfor %}

{# Example 81: Dynamic template pattern (no extends) #}
{% macro dynamic_layout(layout_name) %}
Layout: {{ layout_name }}
{% block dynamic_title %}Dynamic Page{% endblock %}
{% block dynamic_content %}Page content with dynamic parent{% endblock %}
{% endmacro %}
{{ dynamic_layout("custom_layout") }}

{# Example 82: Recursive Macro #}
{% macro walk_tree(item) -%}
    {{ item.name }}
    {%- if item.children -%}
        <ul>
        {%- for child in item.children -%}
            <li>{{ walk_tree(child) }}</li>
        {%- endfor -%}
        </ul>
    {%- endif -%}
{%- endmacro %}
{{ walk_tree(root) }}

{# Example 83: Self Block Access #}
{% block warning_message %}
    WARNING: {{ message }}
{% endblock %}

<div class="alert">
    {{ self.warning_message() }}
</div>
<div class="footer-warning">
    {{ self.warning_message() }}
</div>

{# Example 84: Safe and Escape Filters #}
Safe: {{ "<b>Bold</b>"|safe }}
Escaped: {{ "<b>Bold</b>"|e }}
Force Escaped: {{ "<b>Bold</b>"|forceescape }}

{# Example 85: Format Filter #}
{{ "Hello %s! You have %d new messages."|format("User", 5) }}

{# Example 86: Macro with Context #}
{% macro footer_macro() %}
    &copy; 2023 {{ app_name }}
{% endmacro %}
{{ footer_macro() }}

{# Example 87: Self-contained content (no include) #}
Start
<div class="included-content">
    This would be included content
</div>
End

{# Example 88: Self-contained macro with context (no import) #}
{% macro print_user_macro() %}
  User: {{ user_name }}
{% endmacro %}
{{ print_user_macro() }}

{# Example 89: Template variable #}
Hello {{ name }}!

{# Example 90: Custom Finalizer #}
Value: {{ val }}

{# Example 91: Basic Async Rendering #}
Welcome, {{ user }}!

{# Example 92: Async Globals #}
User: {{ user.name }}, Age: {{ user.age }}

{# Example 93: Async Filters and Tests #}
{{ "trigger"|fetch }}
```

## Required Data

```dart
final data = {
  // Example 4
  'app_name': 'My App',
  'user': 'Alice', // or Future<String>
  
  // Example 5, 11, 35, 39
  'items': ['Item 1', 'Item 2', 'Item 3'], // or Future<List>
  
  // Example 6
  'name': 'filtered', // or Future<String>
  
  // Example 7, 42, 60, 92
  'user': {'name': 'Bob', 'age': 30}, // or Future<Map>
  
  // Example 10
  'product': {'name': 'Laptop', 'price': 1200},
  
  // Example 12-13, 14
  'data': 'Data fetched successfully', // or Future<String>
  
  // Example 23-26, 32-33, 59-60
  'users': [
    {'name': 'Alice', 'age': 25, 'active': true},
    {'name': 'Bob', 'age': 30, 'active': false},
    {'name': 'Charlie', 'age': 25, 'active': true},
  ],
  
  // Example 27-31
  'numbers': [1, 2, 3, 4, 5, 6, 7, 8, 9],
  
  // Example 34
  'condition': true, // or Future<bool>
  
  // Example 55, 63
  'value': 42,
  
  // Example 61
  'text': 'hello world', // or Future<String>
  
  // Example 62
  'name': 'Alice', // or Future<String>
  'age': 25, // or Future<int>
  
  // Example 64
  'x': 10, // or Future<int>
  'y': 5, // or Future<int>
  
  // Example 68, 82
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
  
  // Example 75
  'points': [
    [1, 2],
    [3, 4],
    [5, 6],
  ],
  
  // Example 82
  'root': {
    'name': 'Root',
    'children': [
      {'name': 'A'},
      {
        'name': 'B',
        'children': [
          {'name': 'B1'},
        ],
      },
    ],
  },
  
  // Example 83
  'message': 'System Failure',
  
  // Example 88
  'user_name': 'Admin',
  
  // Example 89
  'name': 'World',
  
  // Example 90
  'val': null,
};
```

## Helper Functions

```dart
// Example 8
String greet() => 'Hi there';

// Example 14
String fetchDataFilter(String data) => 'Filtered: $data';

// Example 15
Future<String> fetchDataGlobal() async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return 'Data fetched successfully';
}

// Example 52
String get_widget_by_id(String id) => 'Widget: $id';

// Example 53
Future<Map<String, dynamic>> callback(String id, Map<String, dynamic> payload) async {
  await Future<void>.delayed(const Duration(seconds: 2));
  return {'mock_data': 'test_data'};
}

// Example 54
List<int> return(List<int> value) => value;

// Example 55
bool is_equal(dynamic a, dynamic b) => a == b;

// Example 56
String translate(String text, String from, String to) => 'Bonjour'; // Simplified

// Example 57
String uuid() => '123e4567-e89b-12d3-a456-426614174000';

// Example 58
String get_current_date() => DateTime.now().toString();

// Example 93
Future<String> fetch(String trigger) async {
  await Future<void>.delayed(const Duration(milliseconds: 100));
  return 'fetched data';
}
```

## Environment Setup

```dart
final env = Environment(
  filters: {
    'reverse': (value) => value.toString().split('').reversed.join(),
    'fetch': (value) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return fetchData();
    },
  },
  globals: {
    'greet': greet,
    'fetchDataFilter': fetchDataFilter,
    'fetchDataGlobal': fetchDataGlobal,
    'get_widget_by_id': get_widget_by_id,
    'callback': callback,
    'return': return,
    'is_equal': is_equal,
    'translate': translate,
    'uuid': uuid,
    'get_current_date': get_current_date,
  },
);

final template = env.fromString(/* template string above */);
final result = await template.renderAsync(data);
```
