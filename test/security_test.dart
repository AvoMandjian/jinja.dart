@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

void main() {
  group('Security & Vulnerability Prevention', () {
    final env = Environment();

    group('Lexer ReDoS Prevention', () {
      // ReDoS tests need to run fast and complete linearly.
      // We will check multiple payload sizes and use a strict Timeout.
      test(
        'Highly nested, unbalanced strings',
        () {
          for (final size in [10, 100, 1000, 10000]) {
            final payload = '{{ "${'a' * size}';
            expect(
              () => env.fromString(payload),
              throwsA(isA<TemplateSyntaxError>()),
            );
          }
        },
        timeout: const Timeout(Duration(seconds: 2)),
      );

      test(
        'Unclosed raw blocks',
        () {
          for (final size in [10, 100, 1000, 10000]) {
            final payload = '{% raw %}${'a' * size}';
            expect(
              () => env.fromString(payload),
              throwsA(
                isException,
              ), // The lexer throws a general Exception for unclosed raw blocks currently
            );
          }
        },
        timeout: const Timeout(Duration(seconds: 2)),
      );

      test(
        'Unbalanced expressions',
        () {
          for (final size in [10, 50, 100, 500]) {
            final payload = '{{ ${'(' * size}1';
            expect(
              () => env.fromString(payload),
              throwsA(isA<TemplateSyntaxError>()),
            );
          }
        },
        timeout: const Timeout(Duration(seconds: 2)),
      );
    });

    group('Parser Stack Overflow Prevention', () {
      test(
        'Deeply nested {% if %} blocks do not crash the isolate',
        () {
          // We will try deep nesting. A good parser should enforce a depth limit
          // and throw TemplateSyntaxError rather than letting the Dart VM throw a StackOverflowError.
          final depths = [50, 100, 200, 500];

          for (final depth in depths) {
            final buffer = StringBuffer();
            for (var i = 0; i < depth; i++) {
              buffer.write('{% if true %}');
            }
            buffer.write(' inner ');
            for (var i = 0; i < depth; i++) {
              buffer.write('{% endif %}');
            }
            final payload = buffer.toString();

            try {
              env.fromString(payload);
            } on StackOverflowError {
              // This is the critical failure scenario. The test should explicitly fail.
              fail(
                'Parser threw a StackOverflowError at depth $depth! No depth limit enforced.',
              );
            } catch (e) {
              // If it throws TemplateSyntaxError or succeeds without crashing, it's safe.
              // jinja.dart might just successfully parse it if the call stack allows it,
              // but we ensure it doesn't crash via StackOverflowError.
            }
          }
        },
        timeout: const Timeout(Duration(seconds: 5)),
      );
    });
  });
}
