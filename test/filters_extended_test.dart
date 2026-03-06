@TestOn('vm || chrome')
library;

import 'dart:math' as math;

import 'package:jinja/jinja.dart';
import 'package:jinja/src/filters.dart';
import 'package:jinja/src/utils.dart' as utils;
import 'package:test/test.dart';

void main() {
  group('Filters - Table Driven Tests', () {
    group('doFromJson', () {
      final tests = <(String, dynamic, dynamic)>[
        (
          '{"a": 1, "b": [2, 3]}',
          {
            'a': 1,
            'b': [2, 3],
          },
          null
        ),
        ('42', 42, null),
        ('true', true, null),
        ('"string"', 'string', null),
        ('null', null, null),
        (
          '{"a": {"b": {"c": [{"d": 1}]}}}',
          {
            'a': {
              'b': {
                'c': [
                  {'d': 1},
                ],
              },
            },
          },
          null
        ),
        ('{a: 1}', null, isA<FormatException>()),
        ('{"a": 1,}', null, isA<FormatException>()),
        ('', null, isA<FormatException>()),
      ];

      for (final tc in tests) {
        test('Given ${tc.$1}, it returns ${tc.$2} or throws ${tc.$3}', () {
          if (tc.$3 != null) {
            expect(() => doFromJson(tc.$1), throwsA(tc.$3));
          } else {
            final result = doFromJson(tc.$1);
            expect(result, equals(tc.$2));
          }
        });
      }
    });

    group('doRandom', () {
      final seededEnv = Environment(random: math.Random(42));

      final tests = <(dynamic, dynamic)>[
        ([1, 2, 3, 4], [1, 2, 3, 4]),
        ({'a': 'apple', 'b': 'banana'}, ['apple', 'banana']),
        ('string', ['s', 't', 'r', 'i', 'n', 'g']),
        (<String>{'set1', 'set2'}, ['set1', 'set2']),
        ([99], [99]),
        ([], null),
        ({}, null),
        (null, null),
      ];

      for (final tc in tests) {
        test('Given ${tc.$1}, it returns one of ${tc.$2}', () {
          final result = doRandom(seededEnv, tc.$1);
          if (tc.$2 == null) {
            expect(result, isNull);
          } else {
            expect(tc.$2, contains(result));
          }
        });
      }
    });

    group('doSafe', () {
      final tests = <(dynamic, String)>[
        ('<b>bold</b>', '<b>bold</b>'),
        (42, '42'),
        (null, ''),
      ];

      for (final tc in tests) {
        test('Given ${tc.$1}, it returns SafeString(${tc.$2})', () {
          final result = doSafe(tc.$1);
          expect(result, isA<utils.SafeString>());
          expect(result.toString(), equals(tc.$2));
        });
      }

      test('Idempotency check: passing an existing SafeString returns the same instance', () {
        final alreadySafe = utils.SafeString('<div></div>');
        final resultDoubleSafe = doSafe(alreadySafe);
        expect(identical(alreadySafe, resultDoubleSafe), isTrue);
      });
    });

    group('doItem', () {
      final env = Environment();

      final tests = <(dynamic, Object, dynamic, Matcher?)>[
        ({'a': 1}, 'a', 1, null),
        ({'a': 1}, 'b', null, null), // Missing key -> null
        (['a', 'b', 'c'], 1, 'b', null),
        (['a', 'b', 'c'], 5, null, isA<UndefinedError>()),
        (['a', 'b', 'c'], -1, null, isA<UndefinedError>()),
        (['a', 'b', 'c'], 'string_key', null, isA<TemplateRuntimeError>()),
        (const MapEntry('k', 'v'), 0, 'k', null),
        (const MapEntry('k', 'v'), 1, 'v', null),
        (const MapEntry('k', 'v'), 2, null, isA<UndefinedError>()),
        (null, 'key', null, isA<UndefinedError>()),
      ];

      for (final tc in tests) {
        test('Given base ${tc.$1} and key ${tc.$2}', () {
          if (tc.$4 != null) {
            expect(() => doItem(env, tc.$1, tc.$2), throwsA(tc.$4));
          } else {
            final result = doItem(env, tc.$1, tc.$2);
            expect(result, equals(tc.$3));
          }
        });
      }
    });
  });
}
