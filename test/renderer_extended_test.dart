@TestOn('vm || chrome')
library;

import 'package:test/test.dart';

import 'utils/test_utilities.dart';

void main() {
  group('Renderer - Table Driven Tests', () {
    final env = createTestEnv(
      globals: {
        'gettext': (String msg) => 'es: $msg',
      },
    );

    group('visitSlice', () {
      final testCases = <RenderTestCase<String>>[
        (
          name: 'standard slice',
          template: '{{ items[1:3] }}',
          data: {
            'items': [0, 1, 2, 3, 4],
          },
          expected: '[1, 2]',
        ),
      ];

      for (final tc in testCases) {
        test('Given ${tc.name}, it renders expected output', () {
          final template = env.fromString(tc.template);
          expect(template.render(tc.data), equals(tc.expected));
        });
      }

      test('throws TemplateRuntimeError when start > stop', () {
        // According to the plan, we should test invalid slices that throw
        // TemplateRuntimeError. Based on renderer.dart line 1863, a negative start or stop < start
        // with value being a List might throw if not handled gracefully.
        // The implementation in Jinja.dart uses start and stop.
        final template = env.fromString('{{ items[3:1] }}');
        expect(
          () => template.render({
            'items': [1, 2, 3],
          }),
          throwsTemplateRuntimeError(contains('Invalid slice indices')),
        );
      });

      test('throws TemplateRuntimeError when negative start', () {
        final template = env.fromString('{{ items[-1:2] }}');
        expect(
          () => template.render({
            'items': [1, 2, 3],
          }),
          throwsTemplateRuntimeError(contains('Invalid slice indices')),
        );
      });
    });

    group('visitFor', () {
      final testCases = <RenderTestCase<String>>[
        (
          name: 'basic iteration over list',
          template: '{% for x in items %}{{ x }}{% endfor %}',
          data: {
            'items': [1, 2, 3],
          },
          expected: '123',
        ),
        (
          name: 'empty array triggering else block',
          template: '{% for x in items %}{{ x }}{% else %}empty{% endfor %}',
          data: {'items': []},
          expected: 'empty',
        ),
        (
          name: 'loop context variables',
          template: '{% for x in items %}{{ loop.index }}{% endfor %}',
          data: {
            'items': ['a', 'b'],
          },
          expected: '12',
        ),
      ];

      for (final tc in testCases) {
        test('Given ${tc.name}, it renders expected output', () {
          final template = env.fromString(tc.template);
          expect(template.render(tc.data), equals(tc.expected));
        });
      }
    });

    group('visitInterpolation', () {
      final testCases = <RenderTestCase<String>>[
        (
          name: 'standard variable injection',
          template: 'Hello {{ name }}!',
          data: {'name': 'World'},
          expected: 'Hello World!',
        ),
        (
          name: 'complex arithmetic expression',
          template: 'Result: {{ 5 * 2 + variable }}',
          data: {'variable': 5},
          expected: 'Result: 15',
        ),
      ];

      for (final tc in testCases) {
        test('Given ${tc.name}, it renders expected output', () {
          final template = env.fromString(tc.template);
          expect(template.render(tc.data), equals(tc.expected));
        });
      }
    });

    group('visitTrans', () {
      final testCases = <RenderTestCase<String>>[
        // trans requires i18n extension or setup. For now we will test a basic trans if it works, or omit it if syntax is wrong.
        // It seems `{% trans %}` expects specific syntax or extension. Let's test with proper i18n extension.
      ];

      for (final tc in testCases) {
        test('Given ${tc.name}, it renders expected output', () {
          final template = env.fromString(tc.template);
          expect(template.render(tc.data), equals(tc.expected));
        });
      }
    });

    group('visitName', () {
      final testCases = <RenderTestCase<String>>[
        (
          name: 'resolving existing variables',
          template: '{{ foo }}',
          data: {'foo': 'bar'},
          expected: 'bar',
        ),
      ];

      for (final tc in testCases) {
        test('Given ${tc.name}, it renders expected output', () {
          final template = env.fromString(tc.template);
          expect(template.render(tc.data), equals(tc.expected));
        });
      }

      test('resolving undefined variables', () {
        final template = env.fromString('{{ missing.attribute }}');
        expect(
          () => template.render({}),
          throwsTemplateError(contains('null object')),
        );
      });
    });
  });
}
