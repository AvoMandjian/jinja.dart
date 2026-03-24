@TestOn('vm || chrome')
library;

import 'package:jinja/src/defaults.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/runtime.dart';
import 'package:test/test.dart';

void main() {
  group('getAttribute', () {
    test('Map attributes', () {
      final map = {'a': 1, 'b': 2};
      expect(getAttribute('entries', map), isA<Iterable>());
      expect(getAttribute('keys', map), isA<Iterable>());
      expect(getAttribute('values', map), isA<Iterable>());
      expect(getAttribute('items', map), isA<Function>());
      expect((getAttribute('items', map) as Function)(), isA<Iterable>());
      expect(getAttribute('a', map), equals(1));
    });

    test('List attributes', () {
      final list = [1, 2];
      expect(getAttribute('add', list), isA<Function>());
      expect(
        () => getAttribute('unknown', list),
        throwsA(isA<UndefinedError>()),
      );
    });

    test('Cycler attributes', () {
      final cycler = Cycler(['a', 'b']);
      expect(getAttribute('next', cycler), isA<Function>());
      expect(getAttribute('reset', cycler), isA<Function>());
      expect(getAttribute('current', cycler), equals('a'));
      expect(
        () => getAttribute('unknown', cycler),
        throwsA(isA<UndefinedError>()),
      );
    });

    test('LoopContext attributes', () {
      final loop = LoopContext([1], 0, (d, [dep = 0]) => '');
      loop.iterator.moveNext();
      // loop[attribute] is handled by operator[]
      // But getAttribute calls object[attribute]
      // LoopContext[key] is implemented.
      expect(getAttribute('index', loop), equals(1));
    });
  });

  group('getItem', () {
    test('List item', () {
      final list = [1, 2];
      expect(getItem(0, list), equals(1));
      expect(() => getItem(2, list), throwsA(isA<UndefinedError>()));
      expect(() => getItem('0', list), throwsA(isA<TemplateRuntimeError>()));
    });

    test('MapEntry item', () {
      const entry = MapEntry('a', 1);
      expect(getItem(0, entry), equals('a'));
      expect(getItem(1, entry), equals(1));
      expect(() => getItem(2, entry), throwsA(isA<UndefinedError>()));
    });

    test('Unsupported type', () {
      expect(() => getItem('a', 42), throwsA(isA<TemplateRuntimeError>()));
    });
  });

  group('Additional core tests for coverage', () {
    test('getAttribute unknown cycler attribute', () {
      final cycler = Cycler([1]);
      expect(() => getAttribute('bad', cycler), throwsA(isA<UndefinedError>()));
    });

    test('getItem on null', () {
      expect(() => getItem('a', null), throwsA(isA<UndefinedError>()));
    });

    test('Cycler empty', () {
      final cycler = Cycler([]);
      expect(cycler.current, isNull);
      expect(cycler.next(), isNull);
    });

    test('lipsum html false', () {
      final text = lipsum(n: 1, html: false);
      expect(text, isNot(contains('<p>')));
    });

    test('zip multiple', () {
      final z = zip([1, 2], [3, 4], [5, 6], [7, 8], [9, 10]);
      expect(z.toList(), [
        [1, 3, 5, 7, 9],
        [2, 4, 6, 8, 10],
      ]);
    });

    test('now', () {
      final d = now();
      expect(d, isA<DateTime>());
    });

    test('dict edge cases', () {
      expect(
        dict([
          [const MapEntry('a', 1)],
        ]),
        {'a': 1},
      );
      expect(
        () => dict([
          [123],
        ]),
        throwsA(isA<TemplateRuntimeError>()),
      );
      expect(() => dict([456]), throwsA(isA<TemplateRuntimeError>()));
    });
  });
}
