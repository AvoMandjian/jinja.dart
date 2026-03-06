@TestOn('vm || chrome')
library;

import 'dart:async';

import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

void main() {
  group('Async Template Rendering Edge Cases', () {
    test('Eager context resolution error', () async {
      final env = Environment();
      final template = env.fromString('{{ async_var }}');

      await expectLater(
        template.renderAsync({
          'async_var': Future<String>.delayed(
            Duration.zero,
            () => throw Exception('context resolution error'),
          ),
        }),
        throwsA(
          isA<TemplateErrorWrapper>().having(
            (e) => e.toString(),
            'message',
            contains('context resolution error'),
          ),
        ),
      );
    });

    test('Capturing futures in _AsyncCollectingSink (extends fallback)', () async {
      final env = Environment(
        loader: MapLoader(
          {
            'base.html': 'Base: {% block content %}{% endblock %}',
          },
          globalJinjaData: {},
        ),
      );
      final template = env.fromString(
        '{% extends "base.html" %}{% block content %}{{ async_throw() }}{% endblock %}',
      );

      await expectLater(
        template.renderAsync({
          'async_throw': () => Future.delayed(
                const Duration(milliseconds: 10),
                () => throw Exception('sink error'),
              ),
        }),
        throwsA(
          isA<TemplateErrorWrapper>().having(
            (e) => e.toString(),
            'message',
            contains('sink error'),
          ),
        ),
      );
    });

    test('Async set assignment resolving to an error', () async {
      final env = Environment();
      final template = env.fromString('{% set x = async_val %}{{ x }}');

      await expectLater(
        template.renderAsync({
          'async_val': Future<String>.error(Exception('assignment error')),
        }),
        throwsA(
          isA<TemplateErrorWrapper>().having(
            (e) => e.toString(),
            'message',
            contains('assignment error'),
          ),
        ),
      );
    });
  });
}
