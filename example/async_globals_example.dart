import 'dart:async';

import 'package:jinja/jinja.dart';

import 'get_jinja.dart';

void main() async {
  final errors = <String?>[];

  // Setup MapLoader with base templates for inheritance and inclusion
  final loader = MapLoader({
    'base.html': '''
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
''',
    'macros.html': '''
{% macro render_user(user) %}
<div class="user">
    <h3>{{ user.name }}</h3>
    <p>Age: {{ user.age }}</p>
</div>
{% endmacro %}

{% macro render_product(product) %}
<div class="product">
    <h4>{{ product.name }}</h4>
    <p>Price: \${{ product.price }}</p>
</div>
{% endmacro %}

{% macro async_data_display(data) %}
<div class="data">
    {{ data }}
</div>
{% endmacro %}
''',
    'partial.html': '''
<div class="partial">
    <p>This is a partial template included via include.</p>
    <p>Current time: {{ now() }}</p>
</div>
''',
  });

  final env = GetJinja.environment(
    MockBuildContext(),
    loader,
    valueListenableJinjaError: (error) {
      print('Jinja Error: $error');
      errors.add(error);
    },
    callbackToParentProject: ({required payload}) async {
      await Future<void>.delayed(const Duration(seconds: 2));
      print('Mock callbackToParentProject called with: $payload');
      return {'mock_data': 'test_data'};
    },
  );

  // Example 4: Using environment globals
  print('\n=== Example 4: Using environment globals ===');

  Future<String> getUsername() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return 'Alice';
  }

  var template4 = env.fromString('Welcome to {{ app_name }}, {{ user }}!');
  var result4 = await template4.renderAsync({
    'app_name': 'My App',
    'user': getUsername(),
  });
  print(result4); // Should print: Welcome to My App, Alice!

  // Example 5: Async global in a loop
  print('\n=== Example 5: Async global in a loop ===');
  var template5 = env.fromString(
    '''
<ul>
{% for item in items %}
  <li>{{ item }}</li>
{% endfor %}
</ul>
''',
  );

  Future<String> fetchItem(int i) async {
    await Future<void>.delayed(Duration(milliseconds: 20 * i));
    return 'Item $i';
  }

  var result5 = await template5.renderAsync({
    'items': [fetchItem(1), fetchItem(2), fetchItem(3)],
  });
  print(result5.trim());

  // Example 6: Async global with a filter
  print('\n=== Example 6: Async global with a filter ===');
  var template6 = env.fromString('{{ name|upper }}');

  Future<String> getFilterName() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return 'filtered';
  }

  var result6 = await template6.renderAsync({'name': getFilterName()});
  print(result6); // Should print: FILTERED

  // Example 7: Nested async data structure
  print('\n=== Example 7: Nested async data structure ===');
  var template7 = env.fromString('User: {{ user.name }}, Age: {{ user.age }}');

  Future<Map<String, dynamic>> getUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    return {'name': 'Bob', 'age': 30};
  }

  var result7 = await template7.renderAsync({'user': getUser()});
  print(result7); // Should print: User: Bob, Age: 30

  // Example 8: Synchronous global function with renderAsync
  print('\n=== Example 8: Synchronous global function with renderAsync ===');
  var template8 = env.fromString('{{- greet() -}}');

  String getSyncGreeting() {
    return 'Hi there';
  }

  var result8 = await template8.renderAsync({'greet': getSyncGreeting});
  print(result8); // Should print: Hi there

  // Example 9: Synchronous filter with renderAsync
  print('\n=== Example 9: Synchronous filter with renderAsync ===');
  var envWithFilter = Environment(
    filters: {...env.filters, 'reverse': (value) => value.toString().split('').reversed.join()},
    globals: env.globals,
    loader: env.loader,
  );
  var template9 = envWithFilter.fromString('{{ "hello"|reverse }}');
  var result9 = await template9.renderAsync();
  print(result9); // Should print: olleh

  // Example 10: Synchronous complex object with renderAsync
  print('\n=== Example 10: Synchronous complex object with renderAsync ===');
  var template10 = env.fromString('Product: {{ product.name }} - \${{ product.price }}');
  var product = {
    'name': 'Laptop',
    'price': 1200,
  };
  var result10 = await template10.renderAsync({'product': product});
  print(result10); // Should print: Product: Laptop - $1200

  if (errors.isNotEmpty) {
    print('\nErrors encountered:');
    errors.forEach(print);
  } else {
    print('\n=== All examples completed successfully! ===');
  }

  // Example 11: Async global in a loop
  print('\n=== Example 11: Async global in a loop ===');
  var template11 = env.fromString('{% for item in items %}{{ item }}{% endfor %}');
  var result11 = await template11.renderAsync({
    'items': [fetchItem(1), fetchItem(2), fetchItem(3)],
  });
  print(result11.trim());

  // Example 12: Async function for calling API with http
  print('\n=== Example 12: Async function for calling API with http');
  var template12 = env.fromString('{{ data }}');
  var result12 = await template12.renderAsync({
    'data': await fetchData(),
  });
  print(result12.trim());

  // Example 13: Async function for calling API with http
  print('\n=== Example 13: Async function for calling API with http');
  var template13 = env.fromString('{{ data }}');
  var result13 = await template13.renderAsync({
    'data': await fetchData(),
  });
  print(result13.trim());

  // Example 14: Async global in a filter
  print('\n=== Example 14: Async global in a filter ===');
  var template14 = env.fromString('{{ data|fetchDataFilter }}');
  var result14 = await template14.renderAsync();
  print(result14.trim());

  // Example 15: Async global in a global function
  print('\n=== Example 15: Async global in a global function ===');
  var template15 = env.fromString('{{ fetchDataGlobal() }}');
  var result15 = await template15.renderAsync();
  print(result15.trim());

  // ========== BUILT-IN GLOBALS DEMONSTRATION ==========

  // Example 16: Cycler global
  print('\n=== Example 16: Cycler global ===');
  var template16 = env.fromString('{% for i in range(5) %}{{ cycler("red", "blue", "green") }}{% endfor %}');
  var result16 = await template16.renderAsync();
  print(result16.trim());

  // Example 17: Joiner global
  print('\n=== Example 17: Joiner global ===');
  var template17 = env.fromString('{% set j = joiner(", ") %}{% for item in ["a", "b", "c"] %}{{ j() }}{{ item }}{% endfor %}');
  var result17 = await template17.renderAsync();
  print(result17.trim());

  // Example 18: Range global
  print('\n=== Example 18: Range global ===');
  var template18 = env.fromString('{% for i in range(1, 6) %}{{ i }}{% endfor %}');
  var result18 = await template18.renderAsync();
  print(result18.trim());

  // Example 19: Dict global
  print('\n=== Example 19: Dict global ===');
  var template19 = env.fromString('{{ dict(a=1, b=2, c=3) }}');
  var result19 = await template19.renderAsync();
  print(result19.trim());

  // Example 20: List global
  print('\n=== Example 20: List global ===');
  var template20 = env.fromString('{{ list("hello") }}');
  var result20 = await template20.renderAsync();
  print(result20.trim());

  // Example 21: Zip global
  print('\n=== Example 21: Zip global ===');
  var template21 = env.fromString('{% for pair in zip([1, 2, 3], ["a", "b", "c"]) %}{{ pair }}{% endfor %}');
  var result21 = await template21.renderAsync();
  print(result21.trim());

  // Example 22: Now global
  print('\n=== Example 22: Now global ===');
  var template22 = env.fromString('Current time: {{ now() }}');
  var result22 = await template22.renderAsync();
  print(result22.trim());

  // ========== COMPLEX FILTERS DEMONSTRATION ==========

  // Example 23: Map filter
  print('\n=== Example 23: Map filter ===');
  var template23 = env.fromString('{{ users|map(attribute="name")|list }}');
  var result23 = await template23.renderAsync({
    'users': [
      {'name': 'Alice', 'age': 25},
      {'name': 'Bob', 'age': 30},
      {'name': 'Charlie', 'age': 35},
    ],
  });
  print(result23.trim());

  // Example 24: Select filter
  print('\n=== Example 24: Select filter ===');
  var template24 = env.fromString('{{ users|select("defined")|list }}');
  var result24 = await template24.renderAsync({
    'users': [
      {'name': 'Alice', 'active': true},
      {'name': 'Bob', 'active': false},
      {'name': 'Charlie', 'active': true},
    ],
  });
  print(result24.trim());

  // Example 25: Reject filter
  print('\n=== Example 25: Reject filter ===');
  var template25 = env.fromString('{{ users|reject("defined")|list }}');
  var result25 = await template25.renderAsync({
    'users': [
      {'name': 'Alice', 'active': true},
      {'name': 'Bob', 'active': false},
      {'name': 'Charlie', 'active': true},
    ],
  });
  print(result25.trim());

  // Example 26: Groupby filter
  print('\n=== Example 26: Groupby filter ===');
  var template26 =
      env.fromString('{% for group in users|groupby("age") %}{{ group.key }}: {{ group.list|map(attribute="name")|list }}{% endfor %}');
  var result26 = await template26.renderAsync({
    'users': [
      {'name': 'Alice', 'age': 25},
      {'name': 'Bob', 'age': 30},
      {'name': 'Charlie', 'age': 25},
    ],
  });
  print(result26.trim());

  // Example 27: Sum filter
  print('\n=== Example 27: Sum filter ===');
  var template27 = env.fromString('Total: {{ numbers|sum }}');
  var result27 = await template27.renderAsync({
    'numbers': [1, 2, 3, 4, 5],
  });
  print(result27.trim());

  // Example 28: Sort filter
  print('\n=== Example 28: Sort filter ===');
  var template28 = env.fromString('{{ numbers|sort|list }}');
  var result28 = await template28.renderAsync({
    'numbers': [3, 1, 4, 1, 5],
  });
  print(result28.trim());

  // Example 29: Unique filter
  print('\n=== Example 29: Unique filter ===');
  var template29 = env.fromString('{{ numbers|unique|list }}');
  var result29 = await template29.renderAsync({
    'numbers': [1, 2, 2, 3, 3, 3],
  });
  print(result29.trim());

  // Example 30: Batch filter
  print('\n=== Example 30: Batch filter ===');
  var template30 = env.fromString('{% for batch in numbers|batch(3) %}{{ batch|list }}{% endfor %}');
  var result30 = await template30.renderAsync({
    'numbers': [1, 2, 3, 4, 5, 6, 7],
  });
  print(result30.trim());

  // Example 31: Slice filter
  print('\n=== Example 31: Slice filter ===');
  var template31 = env.fromString('{{ numbers|slice(3)|list }}');
  var result31 = await template31.renderAsync({
    'numbers': [1, 2, 3, 4, 5, 6, 7, 8, 9],
  });
  print(result31.trim());

  // Example 32: Selectattr filter
  print('\n=== Example 32: Selectattr filter ===');
  var template32 = env.fromString('{{ users|selectattr("active")|list }}');
  var result32 = await template32.renderAsync({
    'users': [
      {'name': 'Alice', 'active': true},
      {'name': 'Bob', 'active': false},
      {'name': 'Charlie', 'active': true},
    ],
  });
  print(result32.trim());

  // Example 33: Rejectattr filter
  print('\n=== Example 33: Rejectattr filter ===');
  var template33 = env.fromString('{{ users|rejectattr("active")|list }}');
  var result33 = await template33.renderAsync({
    'users': [
      {'name': 'Alice', 'active': true},
      {'name': 'Bob', 'active': false},
      {'name': 'Charlie', 'active': true},
    ],
  });
  print(result33.trim());

  // ========== CONTROL STRUCTURES DEMONSTRATION ==========

  // Example 34: Async if condition
  print('\n=== Example 34: Async if condition ===');
  Future<bool> checkCondition() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  var template34 = env.fromString('{% if condition %}Condition is true{% else %}Condition is false{% endif %}');
  var result34 = await template34.renderAsync({
    'condition': checkCondition(),
  });
  print(result34.trim());

  // Example 35: Async for loop with else
  print('\n=== Example 35: Async for loop with else ===');
  Future<List<String>> getItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return ['item1', 'item2', 'item3'];
  }

  var template35 = env.fromString('{% for item in items %}{{ item }}{% else %}No items{% endfor %}');
  var result35 = await template35.renderAsync({
    'items': getItems(),
  });
  print(result35.trim());

  // Example 36: With statement
  print('\n=== Example 36: With statement ===');
  var template36 = env.fromString('{% with user = {"name": "Alice", "age": 25} %}{{ user.name }} is {{ user.age }} years old{% endwith %}');
  var result36 = await template36.renderAsync();
  print(result36.trim());

  // Example 37: Set statement
  print('\n=== Example 37: Set statement ===');
  var template37 = env.fromString('{% set name = "Bob" %}{{ name }}');
  var result37 = await template37.renderAsync();
  print(result37.trim());

  // Example 38: Set block
  print('\n=== Example 38: Set block ===');
  var template38 = env.fromString('{% set content %}<div>Hello World</div>{% endset %}{{ content }}');
  var result38 = await template38.renderAsync();
  print(result38.trim());

  // Example 39: For loop with loop variables
  print('\n=== Example 39: For loop with loop variables ===');
  var template39 = env.fromString('{% for item in items %}{{ loop.index }}: {{ item }}{% endfor %}');
  var result39 = await template39.renderAsync({
    'items': ['a', 'b', 'c'],
  });
  print(result39.trim());

  // ========== MACROS DEMONSTRATION ==========

  // Example 40: Define and use macro
  print('\n=== Example 40: Define and use macro ===');
  var template40 = env.fromString('''
{% macro greet(name) %}
Hello, {{ name }}!
{% endmacro %}
{{ greet("Alice") }}
{{ greet("Bob") }}
''');
  var result40 = await template40.renderAsync();
  print(result40.trim());

  // Example 41: Macro with default arguments
  print('\n=== Example 41: Macro with default arguments ===');
  var template41 = env.fromString('''
{% macro greet(name, greeting="Hi") %}
{{ greeting }}, {{ name }}!
{% endmacro %}
{{ greet("Alice") }}
{{ greet("Bob", "Hello") }}
''');
  var result41 = await template41.renderAsync();
  print(result41.trim());

  // Example 42: Macro with async data
  print('\n=== Example 42: Macro with async data ===');
  Future<Map<String, dynamic>> getUserData() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return {'name': 'Charlie', 'age': 30};
  }

  var template42 = env.fromString('''
{% macro display_user(user) %}
User: {{ user.name }}, Age: {{ user.age }}
{% endmacro %}
{{ display_user(user) }}
''');
  var result42 = await template42.renderAsync({
    'user': getUserData(),
  });
  print(result42.trim());

  // Example 43: Call block
  print('\n=== Example 43: Call block ===');
  var template43 = env.fromString('''
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
  var result43 = await template43.renderAsync();
  print(result43.trim());

  // ========== INHERITANCE & INCLUSION DEMONSTRATION ==========

  // Example 44: Extends and blocks
  print('\n=== Example 44: Extends and blocks ===');
  var template44 = env.fromString('''
{% extends "base.html" %}
{% block title %}Custom Title{% endblock %}
{% block content %}
<h1>Custom Content</h1>
<p>This is custom content from child template.</p>
{% endblock %}
''');
  var result44 = await template44.renderAsync();
  print(result44.trim());

  // Example 45: Include
  print('\n=== Example 45: Include ===');
  var template45 = env.fromString('''
<div>
    <h1>Main Template</h1>
    {% include "partial.html" %}
</div>
''');
  var result45 = await template45.renderAsync();
  print(result45.trim());

  // Example 46: Import macros
  print('\n=== Example 46: Import macros ===');
  var template46 = env.fromString('''
{% import "macros.html" as macros %}
{{ macros.render_user({"name": "Alice", "age": 25}) }}
{{ macros.render_product({"name": "Laptop", "price": 1200}) }}
''');
  var result46 = await template46.renderAsync();
  print(result46.trim());

  // Example 47: From import
  print('\n=== Example 47: From import ===');
  var template47 = env.fromString('''
{% from "macros.html" import render_user %}
{{ render_user({"name": "Bob", "age": 30}) }}
''');
  var result47 = await template47.renderAsync();
  print(result47.trim());

  // ========== ERROR HANDLING & UTILITY STATEMENTS ==========

  // Example 48: Try catch
  print('\n=== Example 48: Try catch ===');
  var template48 = env.fromString('''
{% try %}
    {{ undefined_variable }}
{% catch %}
    Error: Variable is undefined
{% endtry %}
''');
  var result48 = await template48.renderAsync();
  print(result48.trim());

  // Example 49: Do statement
  print('\n=== Example 49: Do statement ===');
  var template49 = env.fromString('''
{% set items = [] %}
{% do items.add("item1") %}
{% do items.add("item2") %}
Items: {{ items|list }}
''');
  var result49 = await template49.renderAsync();
  print(result49.trim());

  // Example 50: Break in loop
  print('\n=== Example 50: Break in loop ===');
  var template50 = env.fromString('''
{% for i in range(10) %}
    {% if i == 5 %}{% break %}{% endif %}
    {{ i }}
{% endfor %}
''');
  var result50 = await template50.renderAsync();
  print(result50.trim());

  // Example 51: Continue in loop
  print('\n=== Example 51: Continue in loop ===');
  var template51 = env.fromString('''
{% for i in range(5) %}
    {% if i == 2 %}{% continue %}{% endif %}
    {{ i }}
{% endfor %}
''');
  var result51 = await template51.renderAsync();
  print(result51.trim());

  // ========== CUSTOM GLOBALS DEMONSTRATION ==========

  // Example 52: get_widget_by_id
  print('\n=== Example 52: get_widget_by_id ===');
  var template52 = env.fromString('{{ get_widget_by_id("widget123") }}');
  var result52 = await template52.renderAsync();
  print(result52.trim());

  // Example 53: callback
  print('\n=== Example 53: callback ===');
  var template53 = env.fromString('{{ callback("callback_id", {"key": "value"}) }}');
  var result53 = await template53.renderAsync();
  print(result53.trim());

  // Example 54: return function
  print('\n=== Example 54: return function ===');
  var template54 = env.fromString('{{ return([1, 2, 3]) }}');
  var result54 = await template54.renderAsync();
  print(result54.trim());

  // Example 55: is_equal with async
  print('\n=== Example 55: is_equal with async ===');
  Future<int> getValue() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return 42;
  }

  var template55 = env.fromString('{% if is_equal(value, 42) %}Equal{% else %}Not equal{% endif %}');
  var result55 = await template55.renderAsync({
    'value': getValue(),
  });
  print(result55.trim());

  // Example 56: translate
  print('\n=== Example 56: translate ===');
  var template56 = env.fromString('{{ translate("Hello", "en", "fr") }}');
  var result56 = await template56.renderAsync();
  print(result56.trim());

  // Example 57: uuid
  print('\n=== Example 57: uuid ===');
  var template57 = env.fromString('{{ uuid() }}');
  var result57 = await template57.renderAsync();
  print(result57.trim());

  // Example 58: get_current_date
  print('\n=== Example 58: get_current_date ===');
  var template58 = env.fromString('{{ get_current_date() }}');
  var result58 = await template58.renderAsync();
  print(result58.trim());

  // Example 59: Complex filter combinations
  print('\n=== Example 59: Complex filter combinations ===');
  var template59 = env.fromString('{{ users|selectattr("active")|map(attribute="name")|sort|list }}');
  var result59 = await template59.renderAsync({
    'users': [
      {'name': 'Charlie', 'active': true},
      {'name': 'Alice', 'active': true},
      {'name': 'Bob', 'active': false},
    ],
  });
  print(result59.trim());

  // Example 60: Async data in nested structures
  print('\n=== Example 60: Async data in nested structures ===');
  Future<List<Map<String, dynamic>>> getUsers() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return [
      {'name': 'Alice', 'age': 25, 'active': true},
      {'name': 'Bob', 'age': 30, 'active': false},
    ];
  }

  var template60 = env.fromString('''
{% for user in users %}
    {% if user.active %}
        {{ user.name }} ({{ user.age }})
    {% endif %}
{% endfor %}
''');
  var result60 = await template60.renderAsync({
    'users': getUsers(),
  });
  print(result60.trim());

  // Example 61: Filter with async input
  print('\n=== Example 61: Filter with async input ===');
  Future<String> getAsyncString() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return 'hello world';
  }

  var template61 = env.fromString('{{ text|upper|title }}');
  var result61 = await template61.renderAsync({
    'text': getAsyncString(),
  });
  print(result61.trim());

  // Example 62: Multiple async operations
  print('\n=== Example 62: Multiple async operations ===');
  Future<String> getName() async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return 'Alice';
  }

  Future<int> getAge() async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    return 25;
  }

  var template62 = env.fromString('{{ name }} is {{ age }} years old');
  var result62 = await template62.renderAsync({
    'name': getName(),
    'age': getAge(),
  });
  print(result62.trim());

  // Example 63: Tests in conditions
  print('\n=== Example 63: Tests in conditions ===');
  var template63 = env.fromString('''
{% if value is defined %}Value is defined{% endif %}
{% if value is number %}Value is a number{% endif %}
{% if value is string %}Value is a string{% endif %}
{% if value is even %}Value is even{% endif %}
{% if value is odd %}Value is odd{% endif %}
''');
  var result63 = await template63.renderAsync({
    'value': 42,
  });
  print(result63.trim());

  // Example 64: Complex expression with async
  print('\n=== Example 64: Complex expression with async ===');
  Future<int> getX() async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return 10;
  }

  Future<int> getY() async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return 5;
  }

  var template64 = env.fromString('Result: {{ x + y * 2 }}');
  var result64 = await template64.renderAsync({
    'x': getX(),
    'y': getY(),
  });
  print(result64.trim());

  // Example 65: Namespace usage
  print('\n=== Example 65: Namespace usage ===');
  var template65 = env.fromString('''
{% set ns = namespace() %}
{% set ns.count = 0 %}
{% for i in range(5) %}
    {% set ns.count = ns.count + 1 %}
{% endfor %}
Count: {{ ns.count }}
''');
  var result65 = await template65.renderAsync();
  print(result65.trim());

  if (errors.isNotEmpty) {
    print('\nErrors encountered:');
    errors.forEach(print);
  } else {
    print('\n=== All examples completed successfully! ===');
  }
}

Future<String> fetchData() async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return 'Data fetched successfully';
}
