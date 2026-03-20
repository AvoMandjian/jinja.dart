import 'package:jinja/src/defaults.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/runtime.dart';
import 'package:jinja/src/utils.dart' as utils;
import 'package:test/test.dart';

void main() {
  group('defaults.dart Coverage Extensions', () {
    group('getAttribute', () {
      test('null object throws UndefinedError', () {
        expect(
          () => getAttribute('attr', null),
          throwsA(isA<UndefinedError>().having((e) => e.message, 'message', contains('Cannot access attribute `attr` on a null object.'))),
        );
      });

      test('Map entries, keys, values', () {
        final map = {'a': 1, 'b': 2};
        expect((getAttribute('entries', map) as Iterable).toList(), hasLength(2));
        expect((getAttribute('keys', map) as Iterable).toList(), containsAll(['a', 'b']));
        expect((getAttribute('values', map) as Iterable).toList(), containsAll([1, 2]));
        expect(getAttribute('a', map), equals(1));
        expect(getAttribute('missing', map), isNull);
      });

      test('List attributes', () {
        final list = [1, 2];
        expect(getAttribute('add', list), equals(list.add));
        expect(
          () => getAttribute('missing', list),
          throwsA(isA<UndefinedError>().having((e) => e.message, 'message', contains('List does not have attribute `missing`'))),
        );
      });

      test('Cycler attributes', () {
        final cycler = Cycler([1, 2]);
        expect(getAttribute('next', cycler), equals(cycler.next));
        expect(getAttribute('reset', cycler), equals(cycler.reset));
        expect(getAttribute('current', cycler), equals(cycler.current));
        expect(
          () => getAttribute('missing', cycler),
          throwsA(isA<UndefinedError>().having((e) => e.message, 'message', contains('Cycler does not have attribute `missing`'))),
        );
      });

      test('String.format (Python-like)', () {
        // Handle {:,.2f}
        final format1 = getAttribute('format', '{:,.2f}') as Function;
        expect(format1(1000.5), equals('1,000.50'));
        expect(format1('1,000.5'), equals('1,000.50'));

        // Handle {:.0f}
        final format2 = getAttribute('format', '{:.0f}') as Function;
        expect(format2(123.456), equals('123'));

        // Handle {:f} (default precision 6)
        final format3 = getAttribute('format', '{:f}') as Function;
        expect(format3(1.2), equals('1.200000'));

        // Invalid specs
        expect(getAttribute('format', 'not a spec'), isNull);
        expect(getAttribute('format', '{:d}'), isNull); // only f handled

        // Formatter with invalid value
        expect(format1(null), isNull);
        expect(format1('not a number'), isNull);
      });
    });

    group('getItem', () {
      test('null object throws UndefinedError', () {
        expect(
          () => getItem('key', null),
          throwsA(isA<UndefinedError>().having((e) => e.message, 'message', contains('Cannot access item `key` on a null object.'))),
        );
      });

      test('Map item access', () {
        final map = {'a': 1};
        expect(getItem('a', map), equals(1));
        expect(getItem('missing', map), isNull);
      });

      test('List item access', () {
        final list = [10, 20];
        expect(getItem(0, list), equals(10));
        expect(getItem(1, list), equals(20));
        expect(
          () => getItem(2, list),
          throwsA(isA<UndefinedError>().having((e) => e.message, 'message', contains('Index `2` is out of bounds'))),
        );
        expect(
          () => getItem('not an int', list),
          throwsA(isA<TemplateRuntimeError>().having((e) => e.message, 'message', contains('List index must be an integer'))),
        );
      });

      test('MapEntry item access', () {
        final entry = MapEntry('k', 'v');
        expect(getItem(0, entry), equals('k'));
        expect(getItem(1, entry), equals('v'));
        expect(
          () => getItem(2, entry),
          throwsA(isA<UndefinedError>().having((e) => e.message, 'message', contains('MapEntry index must be 0 or 1'))),
        );
      });

      test('Namespace item access', () {
        final ns = Namespace({'a': 1});
        expect(getItem('a', ns), equals(1));
        expect(getItem('missing', ns), isNull);
      });
    });

    group('Builtin functions', () {
      test('dict', () {
        expect(
            dict([
              {'a': 1}
            ]),
            equals({'a': 1}));
        expect(
            dict([
              [
                ['a', 1]
              ]
            ]),
            equals({'a': 1}));
      });

      test('list', () {
        expect(utils.list('abc'), equals(['a', 'b', 'c']));
        expect(utils.list([1, 2]), equals([1, 2]));
        expect(utils.list({'a': 1}), equals(['a']));
      });

      test('range', () {
        expect(utils.range(5).toList(), equals([0, 1, 2, 3, 4]));
        expect(utils.range(1, 5).toList(), equals([1, 2, 3, 4]));
        expect(utils.range(1, 5, 2).toList(), equals([1, 3]));
      });

      test('zip', () {
        final result = zip([1, 2], ['a', 'b']);
        expect(
            result.toList(),
            equals([
              [1, 'a'],
              [2, 'b']
            ]));
      });

      test('lipsum', () {
        final result = lipsum();
        expect(result, isNotEmpty);
        expect(result, contains('Lorem ipsum'));
      });
    });
  });
}
