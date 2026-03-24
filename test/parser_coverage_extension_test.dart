import 'package:jinja/src/environment.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();

  group('Parser Coverage Extensions', () {
    test('parseFrom with context', () {
      final template =
          env.fromString("{% from 'template' import macro with context %}");
      expect(template, isNotNull);
    });

    test('parseFrom without context', () {
      final template =
          env.fromString("{% from 'template' import macro without context %}");
      expect(template, isNotNull);
    });

    test('parseImport with context', () {
      final template =
          env.fromString("{% import 'template' as t with context %}");
      expect(template, isNotNull);
    });

    test('parseImport without context', () {
      final template =
          env.fromString("{% import 'template' as t without context %}");
      expect(template, isNotNull);
    });

    test('parseFrom multiple imports with alias', () {
      final template =
          env.fromString("{% from 'template' import macro1 as m1, macro2 %}");
      expect(template, isNotNull);
    });

    test('parseTryCatch with catch block', () {
      final template = env.fromString('''
{% try %}
  {{ fail_me }}
{% catch e %}
  Caught: {{ e }}
{% endtry %}
''');
      expect(template, isNotNull);
    });

    test('parseWith multiple assignments', () {
      final template =
          env.fromString('{% with a=1, b=2 %}{{ a }}{{ b }}{% endwith %}');
      expect(template, isNotNull);
    });

    test('parseCallBlock with arguments', () {
      final template = env.fromString('''
{% macro test() %}{{ caller(1) }}{% endmacro %}
{% call(x) test() %}{{ x }}{% endcall %}
''');
      expect(template, isNotNull);
    });
  });
}
