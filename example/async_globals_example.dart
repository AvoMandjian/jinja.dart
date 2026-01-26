import 'dart:async';

import 'package:jinja/jinja.dart';

import 'get_jinja.dart';

void main() async {
  final errors = <String?>[];
  final env = GetJinja.environment(
    MockBuildContext(),
    MapLoader({}),
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
}

Future<String> fetchData() async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return 'Data fetched successfully';
}
