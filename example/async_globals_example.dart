import 'dart:async';
import 'package:jinja/jinja.dart';

void main() async {
  // Example 1: Simple async global
  print('=== Example 1: Simple async global ===');
  var template1 = Template('Hello {{ name }}!');
  
  // Create a Future that resolves to a name
  Future<String> getName() async {
    await Future<void>.delayed(Duration(milliseconds: 100));
    return 'World';
  }
  
  var result1 = await template1.renderAsync({'name': getName()});
  print(result1); // Should print: Hello World!
  
  // Example 2: Multiple async globals
  print('\n=== Example 2: Multiple async globals ===');
  var template2 = Template('{{ greeting }} {{ name }}!');
  
  Future<String> getGreeting() async {
    await Future<void>.delayed(Duration(milliseconds: 50));
    return 'Hello';
  }
  
  var result2 = await template2.renderAsync({
    'greeting': getGreeting(),
    'name': getName(),
  });
  print(result2); // Should print: Hello World!
  
  // Example 3: Mix of sync and async globals
  print('\n=== Example 3: Mix of sync and async globals ===');
  var template3 = Template('{{ sync_var }} and {{ async_var }}');
  
  Future<String> getAsyncValue() async {
    await Future<void>.delayed(Duration(milliseconds: 75));
    return 'async value';
  }
  
  var result3 = await template3.renderAsync({
    'sync_var': 'sync value',
    'async_var': getAsyncValue(),
  });
  print(result3); // Should print: sync value and async value
  
  // Example 4: Using environment globals
  print('\n=== Example 4: Using environment globals ===');
  
  Future<String> getUsername() async {
    await Future<void>.delayed(Duration(milliseconds: 100));
    return 'Alice';
  }
  
  var env = Environment(
    globals: {
      'app_name': 'My App',
      'user': getUsername(),
    },
  );
  
  var template4 = env.fromString('Welcome to {{ app_name }}, {{ user }}!');
  var result4 = await template4.renderAsync();
  print(result4); // Should print: Welcome to My App, Alice!
  
  print('\n=== All examples completed successfully! ===');
}
