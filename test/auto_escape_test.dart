@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

void main() {
  group('Auto Escape', () {
    test('default behavior (disabled)', () {
      var env = Environment();
      var tmpl = env.fromString('{{ value }}');
      expect(tmpl.render({'value': '<b>hello</b>'}), equals('<b>hello</b>'));
    });

    test('enabled globally', () {
      var env = Environment(autoEscape: true);
      var tmpl = env.fromString('{{ value }}');
      expect(
        tmpl.render({'value': '<b>hello</b>'}),
        equals('&lt;b&gt;hello&lt;/b&gt;'),
      );
    });

    test('safe filter', () {
      var env = Environment(autoEscape: true);
      var tmpl = env.fromString('{{ value|safe }}');
      expect(tmpl.render({'value': '<b>hello</b>'}), equals('<b>hello</b>'));
    });

    test('safe filter with non-string', () {
      var env = Environment(autoEscape: true);
      var tmpl = env.fromString('{{ value|safe }}');
      expect(tmpl.render({'value': 42}), equals('42'));
    });

    test('safe filter wrapper check', () {
      var env = Environment(autoEscape: true);
      // double safe should still be safe
      var tmpl = env.fromString('{{ value|safe|safe }}');
      expect(tmpl.render({'value': '<b>hello</b>'}), equals('<b>hello</b>'));
    });

    test('autoescape tag enable', () {
      var env = Environment();
      var tmpl = env.fromString('''
        {{ value }}
        {% autoescape true %}
          {{ value }}
        {% endautoescape %}
      ''');
      expect(
        tmpl.render({'value': '<b>'}).replaceAll(RegExp(r'\s+'), ''),
        equals('<b>&lt;b&gt;'),
      );
    });

    test('autoescape tag disable', () {
      var env = Environment(autoEscape: true);
      var tmpl = env.fromString('''
        {{ value }}
        {% autoescape false %}
          {{ value }}
        {% endautoescape %}
      ''');
      expect(
        tmpl.render({'value': '<b>'}).replaceAll(RegExp(r'\s+'), ''),
        equals('&lt;b&gt;<b>'),
      );
    });

    test('nested autoescape tags', () {
      var env = Environment(autoEscape: true);
      var tmpl = env.fromString('''
        {{ value }}
        {% autoescape false %}
          {{ value }}
          {% autoescape true %}
            {{ value }}
          {% endautoescape %}
          {{ value }}
        {% endautoescape %}
        {{ value }}
      ''');

      var result = tmpl.render({'value': '<'});
      // remove whitespace for easier comparison
      expect(
        result.replaceAll(RegExp(r'\s+'), ''),
        equals('&lt;<&lt;<&lt;'),
      );
    });

    test('macro with autoescape', () {
      // Macros in Jinja2 usually respect the autoescape setting of where they are defined,
      // but in this implementation they respect the call site because we pass context derived.
      //
      // In the test:
      // 1. First call `{{ m(value) }}` is outside `{% autoescape false %}` block.
      //    Global `autoEscape: true`. So `{{ v }}` inside macro escapes. Result: `&lt;`
      // 2. Second call `{{ m(value) }}` is inside `{% autoescape false %}` block.
      //    The macro execution context is derived from definition context (autoEscape: true).
      //    So `{{ v }}` inside macro escapes. Result: `&lt;`
      //
      //    However, because of the change in `getMacroFunction` to return `SafeString`,
      //    the result of the macro call is marked as safe.
      //
      //    Call 1: `{{ m(value) }}`. Context `autoEscape: true`.
      //    Macro result: `SafeString("&lt;")`.
      //    Interpolation: sees SafeString, prints raw: `&lt;`.
      //
      //    Call 2: `{{ m(value) }}`. Context `autoEscape: false`.
      //    Macro result: `SafeString("&lt;")` (because definition context was autoEscape: true).
      //    Interpolation: sees SafeString (or autoEscape false), prints raw: `&lt;`.
      //
      // Expected total: `&lt;&lt;`
      //
      // This confirms that macros are indeed respecting their DEFINITION context for escaping,
      // and my fix prevented double-escaping for the first case, but it also means
      // that even in `autoescape false` block, the macro still escapes its content because it was defined in `autoEscape: true`.
      // This is consistent with Jinja2 behavior where macros capture their environment.

      var env = Environment(autoEscape: true);
      var tmpl = env.fromString('''
        {% macro m(v) %}{{ v }}{% endmacro %}
        {{ m(value) }}
        {% autoescape false %}
          {{ m(value) }}
        {% endautoescape %}
      ''');

      var result = tmpl.render({'value': '<'});
      expect(
        result.replaceAll(RegExp(r'\s+'), ''),
        equals('&lt;&lt;'),
      );
    });
  });
}
