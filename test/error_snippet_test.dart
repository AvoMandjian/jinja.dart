import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

void main() {
  test('TemplateRuntimeError includes surrounding script', () {
    final env = Environment();
    final source = '''
Hello, {{ user }}!
Your age is {{ user.age() }}.
Goodbye!
''';
    final template = env.fromString(source);

    try {
      template.render({
        'user': {'name': 'Alice'},
      });
      fail('Should have thrown TemplateRuntimeError');
    } catch (e) {
      expect(e, isA<TemplateRuntimeError>());
      final error = e as TemplateRuntimeError;

      print('Error message: ${error.message}');
      print(
        'Location: ${error.templatePath}, line ${error.node?.line}, column ${error.node?.column}',
      );
      print('Context Snippet:\n${error.contextSnippet}');

      expect(error.contextSnippet, contains('Your age is {{ user.age() }}.'));
      expect(error.contextSnippet, contains('^')); // Caret
    }
  });

  test('UndefinedError in getAttribute includes surrounding script', () {
    final env = Environment();
    final source = '''
{% set obj = null %}
Value: {{ obj.something }}
''';
    final template = env.fromString(source);

    try {
      template.render();
      fail('Should have thrown UndefinedError');
    } catch (e) {
      expect(e, isA<UndefinedError>());
      final error = e as UndefinedError;

      print('Error message: ${error.message}');
      print('Context Snippet:\n${error.contextSnippet}');

      expect(error.contextSnippet, contains('Value: {{ obj.something }}'));
      expect(error.contextSnippet, contains('^'));
    }
  });

  test('UndefinedError in visitName includes surrounding script', () {
    final env = Environment(
      undefined: (name, [template]) {
        throw UndefinedError('Variable `$name` is undefined.');
      },
    );
    final source = '''
Line 1
Line 2: {{ non_existent_var }}
Line 3
''';
    final template = env.fromString(source);

    try {
      // We need a non-strict undefined handler or it might throw earlier?
      // Default undefined returns null/throws.
      template.render();
      fail('Should have thrown UndefinedError');
    } catch (e) {
      // If it throws UndefinedError from resolve() or undefined()
      expect(e, isA<UndefinedError>());
      final error = e as UndefinedError;

      print('Error message: ${error.message}');
      print('Context Snippet:\n${error.contextSnippet}');

      expect(error.contextSnippet, contains('Line 2: {{ non_existent_var }}'));
      expect(error.contextSnippet, contains('^'));
    }
  });
}
