# Async Globals Support

The jinja.dart library now supports asynchronous global variables. This allows you to use `Future` values as template globals, which will be automatically awaited before rendering.

## Usage

Use the `renderAsync()` or `renderToAsync()` methods instead of `render()` or `renderTo()`:

```dart
import 'package:jinja/jinja.dart';

void main() async {
  // Example: Fetching data from an async source
  Future<String> fetchUsername() async {
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 100));
    return 'Alice';
  }

  var template = Template('Hello {{ username }}!');
  
  // Pass the Future directly - it will be awaited automatically
  var result = await template.renderAsync({
    'username': fetchUsername(),
  });
  
  print(result); // Output: Hello Alice!
}
```

## Features

- **Automatic Future Resolution**: Any `Future` values in globals or data will be automatically awaited before rendering
- **Mix Sync and Async**: You can mix synchronous and asynchronous values in the same template
- **Environment Globals**: Works with both template data and environment-level globals
- **Full Template Support**: Async globals work with all template features (loops, conditionals, filters, etc.)

## Examples

### Multiple Async Globals

```dart
var template = Template('{{ greeting }}, {{ name }}!');

Future<String> getGreeting() async {
  await Future.delayed(Duration(milliseconds: 50));
  return 'Hello';
}

Future<String> getName() async {
  await Future.delayed(Duration(milliseconds: 100));
  return 'World';
}

var result = await template.renderAsync({
  'greeting': getGreeting(),
  'name': getName(),
});

print(result); // Output: Hello, World!
```

### Environment-Level Async Globals

```dart
Future<String> getAppVersion() async {
  // Fetch from config or API
  return '1.0.0';
}

var env = Environment(
  globals: {
    'app_name': 'My App',
    'version': getAppVersion(), // Future value
  },
);

var template = env.fromString('{{ app_name }} v{{ version }}');
var result = await template.renderAsync();

print(result); // Output: My App v1.0.0
```

### Async Globals with Complex Objects

```dart
Future<Map<String, Object?>> fetchUserData() async {
  await Future.delayed(Duration(milliseconds: 100));
  return {
    'name': 'Bob',
    'email': 'bob@example.com',
    'age': 30,
  };
}

var template = Template('''
User: {{ user.name }}
Email: {{ user.email }}
Age: {{ user.age }}
''');

var result = await template.renderAsync({
  'user': fetchUserData(),
});
```

## Notes

- The synchronous `render()` and `renderTo()` methods continue to work as before
- If you don't have any async globals, you can still use the regular synchronous methods
- All `Future` values are awaited in parallel before rendering begins
