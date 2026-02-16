@TestOn('vm')
library;

import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

void main() {
  var env = Environment();

  group('TryCatch', () {
    test('no error', () {
      var tmpl = env.fromString('{% try %}{{ 1 / 2 }}{% catch %}{% endtry %}');
      expect(tmpl.render(), equals('0.5'));
    });

    test('catch', () {
      var tmpl = env.fromString('''
          {%- try -%}
            {{ x.y }}
          {%- catch -%}
            error occurred
          {%- endtry %}''');
      expect(tmpl.render(), equals('error occurred'));
    });

    test('catch error', () {
      var tmpl = env.fromString('''
          {%- try -%}
            {{ x.y }}
          {%- catch error -%}
            {{ error | runtimetype }}
          {%- endtry %}''');
      expect(tmpl.render(), equals('UndefinedError'));
    });
  });
}
