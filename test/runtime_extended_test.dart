@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:jinja/src/runtime.dart';
import 'package:test/test.dart';

void main() {
  group('Context Behaviors', () {
    test('Context resolves variables in correct hierarchy order', () {
      final env = Environment(globals: {'target': 'from_globals'});
      final context = Context(
        env,
        data: {'target': 'from_context'},
        parent: {'target': 'from_parent', 'other': 'from_parent'},
      );

      expect(context.resolve('target'), equals('from_context'));
      expect(context.resolve('other'), equals('from_parent'));
    });

    test('Context resolves fallback to undefined', () {
      final env = Environment();
      final context = Context(env);
      final result = context.resolve('missing');
      // By default undefined returns null in this engine implementation.
      // Wait, let's verify if undefined returns a wrapper object or just null.
      expect(result, isNull);
    });

    test('Context throws UndefinedError on null access', () {
      final env = Environment();
      final context = Context(env);

      expect(
        () => context.item('key', null, null),
        throwsA(
          isA<UndefinedError>().having(
            (e) => e.operation,
            'operation',
            contains("Accessing item 'key'"),
          ),
        ),
      );
    });

    test('Context map attribute fallback', () {
      final env = Environment();
      final context = Context(env);

      // Accessing a missing attribute on a map in jinja.dart returns null, not throwing.
      expect(
        context.attribute('username', {'userName': 'Alice'}, null),
        isNull,
      );
    });
  });
}
