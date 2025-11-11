import 'dart:async';
import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

void main() {
  group('Async globals', () {
    test('simple async global in data', () async {
      var template = Template('Hello {{ name }}!');
      
      Future<String> getName() async {
        await Future<void>.delayed(Duration(milliseconds: 10));
        return 'World';
      }
      
      var result = await template.renderAsync({'name': getName()});
      expect(result, equals('Hello World!'));
    });

    test('multiple async globals in data', () async {
      var template = Template('{{ greeting }} {{ name }}!');
      
      Future<String> getGreeting() async {
        await Future<void>.delayed(Duration(milliseconds: 5));
        return 'Hello';
      }
      
      Future<String> getName() async {
        await Future<void>.delayed(Duration(milliseconds: 10));
        return 'World';
      }
      
      var result = await template.renderAsync({
        'greeting': getGreeting(),
        'name': getName(),
      });
      expect(result, equals('Hello World!'));
    });

    test('mix of sync and async globals', () async {
      var template = Template('{{ sync_var }} and {{ async_var }}');
      
      Future<String> getAsyncValue() async {
        await Future<void>.delayed(Duration(milliseconds: 10));
        return 'async value';
      }
      
      var result = await template.renderAsync({
        'sync_var': 'sync value',
        'async_var': getAsyncValue(),
      });
      expect(result, equals('sync value and async value'));
    });

    test('async global in environment globals', () async {
      Future<String> getUsername() async {
        await Future<void>.delayed(Duration(milliseconds: 10));
        return 'Alice';
      }
      
      var env = Environment(
        globals: {
          'app_name': 'My App',
          'user': getUsername(),
        },
      );
      
      var template = env.fromString('Welcome to {{ app_name }}, {{ user }}!');
      var result = await template.renderAsync();
      expect(result, equals('Welcome to My App, Alice!'));
    });

    test('async globals with conditionals', () async {
      var template = Template('{% if show %}{{ message }}{% endif %}');
      
      Future<String> getMessage() async {
        await Future<void>.delayed(Duration(milliseconds: 10));
        return 'Hello Async!';
      }
      
      var result = await template.renderAsync({
        'show': true,
        'message': getMessage(),
      });
      expect(result, equals('Hello Async!'));
    });

    test('async globals with loops', () async {
      var template = Template('{% for item in items %}{{ item }}{% endfor %}');
      
      Future<List<String>> getItems() async {
        await Future<void>.delayed(Duration(milliseconds: 10));
        return ['a', 'b', 'c'];
      }
      
      var result = await template.renderAsync({
        'items': getItems(),
      });
      expect(result, equals('abc'));
    });

    test('sync render still works', () {
      var template = Template('Hello {{ name }}!');
      var result = template.render({'name': 'World'});
      expect(result, equals('Hello World!'));
    });

    test('renderToAsync writes to StringSink', () async {
      var template = Template('{{ greeting }} {{ name }}!');
      var buffer = StringBuffer();
      
      Future<String> getGreeting() async {
        await Future<void>.delayed(Duration(milliseconds: 5));
        return 'Hello';
      }
      
      await template.renderToAsync(buffer, {
        'greeting': getGreeting(),
        'name': 'World',
      });
      
      expect(buffer.toString(), equals('Hello World!'));
    });

    test('async global returns null', () async {
      var template = Template('{{ value }}');
      
      Future<String?> getValue() async {
        await Future<void>.delayed(Duration(milliseconds: 10));
        return null;
      }
      
      var result = await template.renderAsync({'value': getValue()});
      expect(result, equals(''));
    });

    test('nested async globals', () async {
      var template = Template('{{ user.name }} is {{ user.age }} years old');
      
      Future<Map<String, Object?>> getUser() async {
        await Future<void>.delayed(Duration(milliseconds: 10));
        return {'name': 'Bob', 'age': 30};
      }
      
      var result = await template.renderAsync({'user': getUser()});
      expect(result, equals('Bob is 30 years old'));
    });
  });
}
