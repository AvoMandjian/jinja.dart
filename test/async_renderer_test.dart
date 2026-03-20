@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

class _ThrowingObj {
  dynamic get foo {
    throw Exception('foo getter failed');
  }
}

void main() {
  group('Async renderer specific paths', () {
    test('async macro args missing', () async {
      final env = Environment();
      final t = env.fromString('{% macro m() %}A{% endmacro %}{{ m(1) }}');
      await expectLater(
        () => t.renderAsync(),
        throwsA(isA<TemplateRuntimeError>()),
      );
    });

    test('async import contextual', () async {
      final env = Environment(
        loader: MapLoader({
          'macro.html': '{% macro m(x) %}{{ x }}{% endmacro %}',
        }, globalJinjaData: {},),
      );
      final t = env.fromString('{% import "macro.html" as m with context %}{{ m.m(1) }}');
      final out = await t.renderAsync({});
      expect(out, equals('1'));
    });

    test('async block required throws', () async {
      final env = Environment();
      final base = env.fromString('{% block req required %}{% endblock %}');
      await expectLater(
        () => base.renderAsync(),
        throwsA(isA<TemplateRuntimeError>()),
      );
    });

    test('async for loop with break and continue', () async {
      final env = Environment();
      final t = env.fromString('{% for x in [1, 2, 3, 4] %}{% if x == 2 %}{% continue %}{% endif %}{% if x == 4 %}{% break %}{% endif %}{{ x }}{% endfor %}');
      final out = await t.renderAsync();
      expect(out, equals('13'));
    });
  });

  group('More async renderer paths', () {
    test('async include missing', () async {
      final env = Environment(loader: MapLoader({}, globalJinjaData: {}));
      final t = env.fromString('{% include "missing.html" ignore missing %}');
      final out = await t.renderAsync();
      expect(out, equals(''));
    });

    test('async error wrapping in interpolation', () async {
      final envThrowing = Environment(getAttribute: (attr, obj, {node, source}) => throw Exception('error'));
      final t = envThrowing.fromString('{{ bad.foo }}');
      await expectLater(() => t.renderAsync({'bad': _ThrowingObj()}), throwsA(isA<TemplateErrorWrapper>()));
    });
    
    test('async error wrapping in for loop body', () async {
      final envThrowing = Environment(getAttribute: (attr, obj, {node, source}) => throw Exception('error'));
      final t = envThrowing.fromString('{% for x in [bad] %}{{ x.foo }}{% endfor %}');
      await expectLater(() => t.renderAsync({'bad': _ThrowingObj()}), throwsA(isA<TemplateErrorWrapper>()));
    });

    test('async autoescape enable/disable', () async {
      final env = Environment();
      final t = env.fromString('{% autoescape true %}{{ "<" }}{% endautoescape %}{% autoescape false %}{{ "<" }}{% endautoescape %}');
      final out = await t.renderAsync();
      expect(out, equals('&lt;<'));
    });

    test('async do block', () async {
      final env = Environment();
      final t = env.fromString('{% do [1].add(2) %}');
      final out = await t.renderAsync();
      expect(out, equals(''));
    });
    
    test('async template error wrap', () async {
      final envThrowing = Environment(undefined: (name, [tmpl]) => throw Exception('error'));
      final t = envThrowing.fromString('{{ missing }}');
      await expectLater(() => t.renderAsync(), throwsA(isA<TemplateErrorWrapper>()));
    });
  });

  group('Async specific error throwers', () {
    test('async TemplateRuntimeError for Missing Block', () async {
      final env = Environment();
      final t = env.fromString('{{ super() }}');
      await expectLater(() => t.renderAsync(), throwsA(isA<TemplateRuntimeError>()));
    });
    
    test('async filter throws TemplateRuntimeError on invalid filter', () async {
      final env = Environment();
      final t = env.fromString('{{ "a"|bad_filter }}');
      await expectLater(() => t.renderAsync(), throwsA(isA<TemplateRuntimeError>()));
    });

    test('async macro args count mismatch', () async {
      final env = Environment();
      final t = env.fromString('{% macro foo(a, b) %}{% endmacro %}{{ foo(1, 2, 3) }}');
      await expectLater(() => t.renderAsync(), throwsA(isA<TemplateRuntimeError>()));
    });
  });

  group('Async specific tricky edge cases', () {
    test('async missing Name triggers checkFuture logic', () async {
      final env = Environment();
      // 'unknown' is missing, triggers checkFuture waiting logic 
      final t = env.fromString('{{ unknown }}');
      final out = await t.renderAsync();
      expect(out, equals(''));
    });

    test('async assignment wait path', () async {
      final env = Environment(globals: {'f': Future.value(42)});
      final t = env.fromString('{% set x = f %}{{ x }}');
      final out = await t.renderAsync();
      expect(out, equals('42'));
    });

    test('async macro passed as value and called', () async {
      final env = Environment(trimBlocks: true);
      final t = env.fromString('''
{% macro view(x) %}{{ x }}{% endmacro %}
{% macro use_view(v) %}{{ v('test string') }}{% endmacro %}
{{ use_view(view) }}''');
      final out = await t.renderAsync();
      expect(out, equals('test string'));
    });
  });
}
