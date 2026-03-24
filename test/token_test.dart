import 'package:jinja/src/lexer.dart'
    show
        Token,
        ValueToken,
        SimpleToken,
        describeTokenType,
        describeToken,
        describeExpression;
import 'package:test/test.dart';

void main() {
  group('describeTokenType', () {
    test('returns description for known type', () {
      expect(describeTokenType('add'), '+');
    });

    test('falls back to original type for unknown', () {
      expect(describeTokenType('unknown_type'), 'unknown_type');
    });
  });

  group('describeToken', () {
    test('returns value for name tokens', () {
      const token = ValueToken(1, 2, 'name', 'foo');
      expect(describeToken(token), 'foo');
    });

    test('uses type description for non-name tokens', () {
      const token = SimpleToken(1, 2, 'add');
      expect(describeToken(token), '+');
    });
  });

  group('describeExpression', () {
    test('returns value for name expressions with value', () {
      expect(describeExpression(('name', 'foo')), 'foo');
    });

    test('falls back to describeTokenType otherwise', () {
      expect(describeExpression(('add', null)), '+');
    });
  });

  group('Token equality and hashCode', () {
    test('tokens with same fields are equal and share hashCode', () {
      const t1 = ValueToken(1, 2, 'name', 'foo');
      const t2 = ValueToken(1, 2, 'name', 'foo');

      expect(t1, equals(t2));
      expect(t1.hashCode, equals(t2.hashCode));
    });

    test('tokens with different fields are not equal', () {
      const t1 = ValueToken(1, 2, 'name', 'foo');
      const t2 = ValueToken(1, 2, 'name', 'bar');

      expect(t1 == t2, isFalse);
    });
  });

  group('BaseToken change / test / testAny', () {
    test('change respects Token.common mapping when type changes', () {
      const original = ValueToken(1, 2, 'name', 'x');

      final changed = original.change(type: 'add');
      expect(changed, isA<SimpleToken>());
      expect(changed.type, 'add');
      expect(changed.value, '+');
    });

    test('change preserves fields when not provided', () {
      const original = ValueToken(1, 2, 'name', 'x');

      final changed = original.change();
      expect(changed.type, original.type);
      expect(changed.line, original.line);
      expect(changed.column, original.column);
      expect(changed.value, original.value);
    });

    test('length returns value length', () {
      const token = ValueToken(1, 2, 'name', 'abcd');
      expect(token.length, 4);
    });

    test('test matches on type only when value omitted', () {
      const token = ValueToken(1, 2, 'name', 'foo');
      expect(token.test('name'), isTrue);
      expect(token.test('other'), isFalse);
    });

    test('test matches on type and value when provided', () {
      const token = ValueToken(1, 2, 'name', 'foo');
      expect(token.test('name', 'foo'), isTrue);
      expect(token.test('name', 'bar'), isFalse);
    });

    test('testAny returns true when any expression matches', () {
      const token = ValueToken(1, 2, 'name', 'foo');

      final expressions = <(String, String?)>[
        ('add', null),
        ('name', 'foo'),
      ];

      expect(token.testAny(expressions), isTrue);
      expect(token.testAny(<(String, String?)>[('add', null)]), isFalse);
    });
  });

  group('SimpleToken', () {
    test('value resolves from Token.common', () {
      const token = SimpleToken(1, 2, 'add');
      expect(token.value, '+');
    });

    test('value falls back to empty string for unknown type', () {
      const token = SimpleToken(1, 2, 'unknown_type');
      expect(token.value, '');
    });
  });
}
