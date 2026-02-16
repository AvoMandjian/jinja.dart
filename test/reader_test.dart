@TestOn('vm || chrome')
library;

import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/lexer.dart';
import 'package:jinja/src/reader.dart';
import 'package:test/test.dart';

void main() {
  group('TokenReader', () {
    test('expect at EOF throws correct error', () {
      final tokens = [
        const Token.simple(1, 1, 'block_begin'),
      ];
      final reader = TokenReader(tokens);
      reader.next(); // consume block_begin
      expect(reader.current.type, equals('eof'));
      expect(() => reader.expect('block_end'),
          throwsA(isA<TemplateSyntaxError>().having((e) => e.message, 'message', contains('Unexpected end of template'))));
    });

    test('expect with wrong token throws correct error', () {
      final tokens = [
        const Token(1, 1, 'name', 'foo'),
      ];
      final reader = TokenReader(tokens);
      expect(() => reader.expect('block_begin'),
          throwsA(isA<TemplateSyntaxError>().having((e) => e.message, 'message', contains('Expected token block_begin'))));
    });

    test('push and look', () {
      final tokens = [
        const Token(1, 1, 'name', 'foo'),
        const Token(1, 5, 'name', 'bar'),
      ];
      final reader = TokenReader(tokens);
      final foo = reader.current;
      final bar = reader.look();
      expect(bar.value, equals('bar'));
      expect(reader.current, equals(foo));

      reader.next();
      expect(reader.current, equals(bar));
    });

    test('skip', () {
      final tokens = [
        const Token(1, 1, 'name', 't1'),
        const Token(1, 5, 'name', 't2'),
        const Token(1, 9, 'name', 't3'),
      ];
      final reader = TokenReader(tokens);
      reader.skip(2);
      expect(reader.current.value, equals('t3'));
    });

    test('nextIf and skipIf', () {
      final tokens = [
        const Token(1, 1, 'name', 'foo'),
        const Token(1, 5, 'name', 'bar'),
      ];
      final reader = TokenReader(tokens);
      expect(reader.nextIf('name', 'baz'), isNull);
      expect(reader.current.value, equals('foo'));

      final foo = reader.nextIf('name', 'foo');
      expect(foo?.value, equals('foo'));
      expect(reader.current.value, equals('bar'));

      expect(reader.skipIf('name', 'baz'), isFalse);
      expect(reader.skipIf('name', 'bar'), isTrue);
      expect(reader.current.type, equals('eof'));
    });
  });
}
