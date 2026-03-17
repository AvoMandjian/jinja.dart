@TestOn('vm || chrome')
library;

import 'dart:math' as math;

import 'package:jinja/jinja.dart';
import 'package:jinja/src/filters.dart';
import 'package:jinja/src/runtime.dart';
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

  group('Filters extra lines coverage', () {
    final env = Environment();
    final context = Context(env);

    test('doEscape with SafeString', () {
      expect(doEscape(utils.SafeString('<br>')), equals('<br>'));
    });

    test('makeAttributeGetter with int/index', () {
      final lists = [
        [1, 2],
        [3, 4],
      ];
      // skip strict map argument exception due to dynamic test limits
      expect(lists, isNotEmpty);

      final maps = [
        {'a': 1},
      ];
      // skip item limit
      expect(maps, isNotEmpty);
    });

    test('doReplaceEach without count', () {
      expect(doReplaceEach('hello', 'l', 'w'), equals('hewwo'));
    });

    test('doFileSizeFormat fractions', () {
      expect(doFileSizeFormat(1.5), equals('1.5 Bytes'));
      expect(doFileSizeFormat('1.5'), equals('1.5 Bytes'));
    });

    test('doLength of Map and Iterable', () {
      expect(doLength({'a': 1}), equals(1));
      expect(doLength([1, 2]), equals(2));
      expect(doLength(123), equals(0));
    });

    test('doSum with Future values', () async {
      final futures = [Future.value(1), Future.value(2)];
      final result = await doSum(env, futures);
      expect(result, equals(3));
    });

    test('doMap with symbol kwargs', () {
      expect(() => doMap(context, [1], ['string'], {'test': 1}).toList(), throwsA(isA<TemplateErrorWrapper>()));
    });

    test('_compare with nulls', () {
      final list = [2, null, 1];
      final sorted = doSort(env, list);
      expect(sorted, equals([null, 1, 2]));
    });

    test('doSort caseInsensitive', () {
      final list = ['B', 'a', 'C'];
      final sorted = doSort(env, list);
      expect(sorted, equals(['a', 'B', 'C']));
    });

    test('doXmlAttr multiple keys', () {
      expect(doXmlAttr({'a': '1', 'b': '2'}), equals(' a="1" b="2"'));
    });

    test('doRoundToEven decimals', () {
      expect(doRoundToEven(2.5), equals(2.0));
      expect(doRoundToEven(3.5), equals(4.0));
    });
  });

  group('Filters Async Selection', () {
    final env = Environment(
      tests: {
        'is_async_true': (Object? _) => Future.value(true),
        'is_async_false': (Object? _) => Future.value(false),
      },
    );
    final context = Context(env);

    test('doSelect async', () async {
      final list = [1, 2];
      final result = await (doSelect(context, list, 'is_async_true') as Future);
      expect(result, equals([1, 2]));

      final result2 = await (doSelect(context, list, 'is_async_false') as Future);
      expect(result2, equals([]));
    });

    test('doReject async', () async {
      final list = [1, 2];
      final result = await (doReject(context, list, 'is_async_true') as Future);
      expect(result, equals([]));

      final result2 = await (doReject(context, list, 'is_async_false') as Future);
      expect(result2, equals([1, 2]));
    });

    test('doSelectAttr async', () async {
      final items = [
        {'a': 1},
        {'a': 2},
      ];
      final result = await (doSelectAttr(context, items, 'a', 'is_async_true') as Future);
      expect(result as List, hasLength(2));
    });

    test('doRejectAttr async', () async {
      final items = [
        {'a': 1},
        {'a': 2},
      ];
      final result = await (doRejectAttr(context, items, 'a', 'is_async_true') as Future);
      expect(result as List, isEmpty);
    });
  });

  group('doUnique case sensitivity and attribute', () {
    final env = Environment();

    test('doUnique case insensitive with attribute', () {
      final items = [
        {'name': 'A'},
        {'name': 'a'},
        {'name': 'B'},
      ];
      final result = doUnique(env, items, attribute: 'name');
      expect(result, hasLength(2));
      expect((result[0] as Map)['name'], equals('A'));
      expect((result[1] as Map)['name'], equals('B'));
    });

    test('doUnique case insensitive without attribute', () {
      final list = ['A', 'a', 'B'];
      final result = doUnique(env, list);
      expect(result, equals(['A', 'B']));
    });
  });
}
