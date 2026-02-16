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
      expect(getAttribute('a', map), equals(1));
    });

    test('List attributes', () {
      final list = [1, 2];
      expect(getAttribute('add', list), isA<Function>());
      expect(() => getAttribute('unknown', list), throwsA(isA<UndefinedError>()));
    });

    test('Cycler attributes', () {
      final cycler = Cycler(['a', 'b']);
      expect(getAttribute('next', cycler), isA<Function>());
      expect(getAttribute('reset', cycler), isA<Function>());
      expect(getAttribute('current', cycler), equals('a'));
      expect(() => getAttribute('unknown', cycler), throwsA(isA<UndefinedError>()));
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
}
