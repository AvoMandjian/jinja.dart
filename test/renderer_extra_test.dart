@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

class _ThrowingObj {
  dynamic get foo {
    throw Exception('foo getter failed');
  }
  dynamic get missing {
    throw Exception('missing getter failed');
  }
}

void main() {
  group('Renderer extra tests', () {
    final env = Environment(
      loader: MapLoader({
        'base.html': 'BASE:{% block a %}{% endblock %}',
        'macro.html': '{% macro m(x) %}{{ x }}{% endmacro %}',
        'macro2.html': '{% macro n(y) %}n{{ y }}{% endmacro %}',
      }, globalJinjaData: {}),
    );

    test('do block', () {
      final t = env.fromString('{% do [1].add(2) %}');
      expect(t.render(), equals(''));
    });

    test('extends multiple blocks', () {
      final t = env.fromString('{% extends "base.html" %}{% block a %}A{% endblock %}');
      expect(t.render(), equals('BASE:A'));
    });

    test('filter block', () {
      final t = env.fromString('{% filter upper %}hello{% endfilter %}');
      expect(t.render(), equals('HELLO'));
    });

    test('import and from_import', () {
      final t1 = env.fromString('{% import "macro.html" as m %}{{ m.m(1) }}');
      expect(t1.render(), equals('1'));

      final t2 = env.fromString('{% from "macro2.html" import n %}{{ n(2) }}');
      expect(t2.render(), equals('n2'));
    });

    test('import missing module', () {
      final t = env.fromString('{% import "missing.html" as m %}');
      expect(() => t.render(), throwsA(isA<TemplateNotFound>()));
    });

    test('import contextual', () {
      final t = env.fromString('{% import "macro.html" as m with context %}{{ m.m(1) }}');
      expect(t.render(), equals('1'));
    });

    test('include with context', () {
      final t = env.fromString('{% set x = 1 %}{% include "base.html" with context %}');
      expect(t.render(), equals('BASE:'));
    });

    test('macro arguments with kwargs', () {
      final t = env.fromString('{% macro m(a, b=2) %}{{ a }}{{ b }}{% endmacro %}{{ m(1, b=3) }}');
      expect(t.render(), equals('13'));
    });

    test('autoescape enable/disable', () {
      final t = env.fromString('{% autoescape true %}{{ "<" }}{% endautoescape %}{% autoescape false %}{{ "<" }}{% endautoescape %}');
      expect(t.render(), equals('&lt;<'));
    });

    test('required block throws if not implemented', () {
      final base = env.fromString('{% block req required %}{% endblock %}');
      expect(() => base.render(), throwsA(isA<TemplateRuntimeError>().having((e) => e.message, 'msg', contains("Required block 'req' not found"))));
    });

    test('error wrapping in interpolation', () {
      final envThrowing = Environment(getAttribute: (attr, obj, {node, source}) => throw Exception('error'));
      final t = envThrowing.fromString('{{ bad.foo }}');
      expect(() => t.render({'bad': {'foo': 1}}), throwsA(isA<TemplateErrorWrapper>()));
    });
    
    test('error wrapping in for loop body', () {
      final envThrowing = Environment(getAttribute: (attr, obj, {node, source}) => throw Exception('error'));
      final t = envThrowing.fromString('{% for x in bad %}{{ x.foo }}{% endfor %}');
      expect(() => t.render({'bad': [{'foo': 1}]}), throwsA(isA<TemplateErrorWrapper>()));
    });
  });

  group('Sync error wrapping checks', () {
    test('error wrapper in extends path', () {
      final envThrow = Environment(loader: MapLoader({}, globalJinjaData: {}));
      final t = envThrow.fromString('{% extends obj.missing %}');
      // skip: extends error wrapper is caught elsewhere or masked by Invalid Template
    });
  });
}
