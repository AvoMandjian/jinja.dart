import 'dart:async';

import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncRenderer Coverage Extensions', () {
    final env = Environment();

    test('visitAssign with complex target', () async {
      final t = env.fromString('{% set a, b = [async_val, 2] %}{{ a }}{{ b }}');
      final result = await t.renderAsync({'async_val': Future.value(1)});
      expect(result, equals('12'));
    });

    test('visitFor with Map', () async {
      final t =
          env.fromString('{% for k, v in map %}{{ k }}:{{ v }}{% endfor %}');
      final result = await t.renderAsync({
        'map': {'a': 1, 'b': 2},
      });
      expect(result, equals('a:1b:2'));
    });

    test('visitFor with test condition (async)', () async {
      final t = env
          .fromString('{% for x in [1, 2, 3] if x > 1 %}{{ x }}{% endfor %}');
      final result = await t.renderAsync();
      expect(result, equals('23'));
    });

    test('visitFor with empty iterable and orElse (async)', () async {
      final t =
          env.fromString('{% for x in [] %}body{% else %}empty{% endfor %}');
      final result = await t.renderAsync();
      expect(result, equals('empty'));
    });

    test('visitImport (async)', () async {
      final envImport = Environment(
        loader: MapLoader(
          {
            'lib.html': '{% macro m() %}from lib{% endmacro %}',
          },
          globalJinjaData: {},
        ),
      );
      final t =
          envImport.fromString('{% import "lib.html" as lib %}{{ lib.m() }}');
      final result = await t.renderAsync();
      expect(result, equals('from lib'));
    });

    test('visitMacro (async)', () async {
      final t =
          env.fromString('{% macro m(x) %}{{ x }}{% endmacro %}{{ m("hi") }}');
      final result = await t.renderAsync();
      expect(result, equals('hi'));
    });

    test('visitTryCatch (async)', () async {
      final envTry = Environment(
        globals: {
          'fail': () => throw Exception('error'),
        },
      );
      final t = envTry
          .fromString('{% try %}{{ fail() }}{% catch e %}{{ e }}{% endtry %}');
      final result = await t.renderAsync();
      expect(result, contains('Exception: error'));
    });

    test('visitWith (async)', () async {
      final t = env.fromString('{% with a=1, b=2 %}{{ a + b }}{% endwith %}');
      final result = await t.renderAsync();
      expect(result, equals('3'));
    });

    test('visitSlice (async)', () async {
      // slice is just a wrapper around base renderer in AsyncRenderer
      final t = env.fromString('{{ "abcde"[1:3] }}');
      final result = await t.renderAsync();
      expect(result, equals('bc'));
    });
  });
}
