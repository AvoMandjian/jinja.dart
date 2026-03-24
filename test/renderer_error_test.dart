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
  group('Renderer specific error paths', () {
    test('error wrapper in condition', () {
      final envThrow = Environment(
          getAttribute: (attr, obj, {node, source}) =>
              throw Exception('error'));
      final t = envThrow.fromString('{% if obj.foo %}A{% endif %}');
      expect(() => t.render({'obj': _ThrowingObj()}),
          throwsA(isA<TemplateErrorWrapper>()));
    });

    test('error wrapper in concat', () {
      final envThrow = Environment(
          getAttribute: (attr, obj, {node, source}) =>
              throw Exception('error'));
      final t = envThrow.fromString('{{ "a" ~ obj.foo }}');
      expect(() => t.render({'obj': _ThrowingObj()}),
          throwsA(isA<TemplateErrorWrapper>()));
    });

    test('error wrapper in dict', () {
      final envThrow = Environment(
          getAttribute: (attr, obj, {node, source}) =>
              throw Exception('error'));
      final t = envThrow.fromString('{{ {"k": obj.foo} }}');
      expect(() => t.render({'obj': _ThrowingObj()}),
          throwsA(isA<TemplateErrorWrapper>()));
    });

    test('error wrapper in tuple', () {
      final envThrow = Environment(
          getAttribute: (attr, obj, {node, source}) =>
              throw Exception('error'));
      final t = envThrow.fromString('{{ (obj.foo,) }}');
      expect(() => t.render({'obj': _ThrowingObj()}),
          throwsA(isA<TemplateErrorWrapper>()));
    });

    test('error wrapper in name resolution', () {
      final envThrow =
          Environment(undefined: (name, [tmpl]) => throw Exception('error'));
      final t = envThrow.fromString('{% set y = unknown %}{{ y }}');
      expect(() => t.render(), throwsA(isA<TemplateErrorWrapper>()));
    });

    test('error wrapper in for loop', () {
      final envThrow = Environment();
      final t = envThrow.fromString('{% for x in bad %}{{ x }}{% endfor %}');
      expect(() => t.render({'bad': _ThrowingObj()}),
          throwsA(isA<TemplateErrorWrapper>()));
    });
  });
}
