@TestOn('vm || chrome')
library;

import 'package:jinja/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('boolean', () {
    test('Map is handled correctly', () {
      expect(boolean({}), isFalse);
      expect(boolean({'key': 'value'}), isTrue);
    });
  });

  group('identity', () {
    test('returns the same value', () {
      expect(identity(42), equals(42));
      expect(identity('foo'), equals('foo'));
      expect(identity(null), isNull);
    });
  });

  group('iterate', () {
    test('Map is handled correctly', () {
      expect(iterate({'a': 1, 'b': 2}), equals(['a', 'b']));
    });
  });

  group('range', () {
    test('negative step', () {
      expect(range(5, 0, -1), equals([5, 4, 3, 2, 1, 0]));
    });

    test('step 0 throws error', () {
      expect(() => range(0, 5, 0).toList(), throwsArgumentError);
    });
  });

  group('pair', () {
    test('converts MapEntry to pair', () {
      expect(pair(const MapEntry('key', 'value')), equals(['key', 'value']));
    });
  });

  group('list', () {
    test('null returns empty list', () {
      expect(list(null), isEmpty);
    });
  });

  group('capitalize', () {
    test('handles empty and single char', () {
      expect(capitalize(''), equals(''));
      expect(capitalize('a'), equals('A'));
      expect(capitalize('A'), equals('A'));
    });
  });

  group('stripTags', () {
    test('removes tags and normalizes whitespace', () {
      expect(stripTags('  <p>foo</p>  bar  '), equals('foo bar'));
    });
  });

  group('sum', () {
    test('adds numbers', () {
      expect(sum(1, 2), equals(3));
    });
  });

  group('htmlSafeJsonEncode', () {
    test('escapes HTML unsafe chars in JSON', () {
      final data = {'tag': '<script>', 'amp': '&', 'quot': "'"};
      final encoded = htmlSafeJsonEncode(data);
      expect(encoded, contains('\\u003cscript\\u003e'));
      expect(encoded, contains('\\u0026'));
      expect(encoded, contains('\\u0027'));
    });
  });
}
