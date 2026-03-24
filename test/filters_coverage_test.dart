@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:jinja/src/filters.dart';
import 'package:test/test.dart';

void main() {
  group('Filters 90% path coverage', () {
    final env = Environment();

    test('missing doSum logic', () {
      // test empty and non-empty paths
      expect(doSum(env, [1.0, 2.0]), 3.0);
      expect(doSum(env, []), 0);
    });

    test('missing string logic', () {
      expect(doCapitalize('abc'), 'Abc');
    });
  });
}
