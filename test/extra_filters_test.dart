@TestOn('vm || chrome')
library;

import 'package:jinja/src/filters.dart';
import 'package:test/test.dart';

void main() {
  group('Filters', () {
    test('replace with count', () {
      expect(doReplace('aaaaa', 'a', 'b', 2), equals('bbaaa'));
      expect(doReplace('aaaaa', 'a', 'b', 0), equals('aaaaa'));
      expect(doReplace('aaaaa', 'a', 'b', 10), equals('bbbbb'));
    });

    test('replace without count', () {
      expect(doReplace('aaaaa', 'a', 'b'), equals('bbbbb'));
    });

    test('dictsort validation', () {
      expect(() => doDictSort({}, by: 'invalid'), throwsArgumentError);
    });
  });
}
