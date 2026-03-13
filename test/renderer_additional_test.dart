@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

void main() {
  group('Renderer additional tests', () {
    final env = Environment(loader: MapLoader({'b': 'c'}, globalJinjaData: {}));

    test('macro arguments count mismatch throws', () {
      final t = env.fromString('{% macro m() %}x{% endmacro %}{{ m(1) }}');
      expect(
        () => t.render(),
        throwsA(isA<TemplateRuntimeError>().having((e) => e.message, 'message', contains('expected arguments count: 0'))),
      );
    });

    test('extends accepts Template instance directly', () {
      final base = env.fromString('base: {% block content %}{% endblock %}');
      // For extends with a direct template, we need to pass it dynamically via context since syntax expects string.
      // But extends tag parses string or variable.
      final t = env.fromString('{% extends base_tpl %}{% block content %}override{% endblock %}');
      expect(t.render({'base_tpl': base}), equals('base: override'));
    });

    test('extends with invalid type throws', () {
      final t = env.fromString('{% extends 42 %}');
      expect(
        () => t.render(),
        throwsA(isA<TemplateRuntimeError>().having((e) => e.message, 'message', contains('Invalid template value: int'))),
      );
    });

    test('break and continue in for loop', () {
      final t = env.fromString('{% for x in [1, 2, 3, 4] %}{% if x == 2 %}{% continue %}{% endif %}{% if x == 4 %}{% break %}{% endif %}{{ x }}{% endfor %}');
      expect(t.render(), equals('13'));
    });

    test('include ignore missing', () {
      final t = env.fromString('{% include "missing.html" ignore missing %}');
      expect(t.render(), equals(''));
    });

    test('missing Name fallback and error wrapping', () {
      final envWithError = Environment(undefined: (String name, [String? tpl]) {
        throw Exception('Custom undefined error for $name');
      });
      final t = envWithError.fromString('{{ unknown }}');
      expect(
        () => t.render(),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });

    test('Async macro and with Context setup', () async {
      // Testing withContext block
      final t = env.fromString('{% with x = 1 %}{{ x }}{% endwith %}');
      expect(t.render(), equals('1'));
    });
  });
}
