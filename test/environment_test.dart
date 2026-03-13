@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:jinja/src/runtime.dart';
import 'package:jinja/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('Environment', () {
    test('newLine validation', () {
      expect(() => Environment(), returnsNormally);
      expect(() => Environment(newLine: '\r'), returnsNormally);
      expect(() => Environment(newLine: '\r\n'), returnsNormally);
      expect(() => Environment(newLine: ' '), throwsArgumentError);
    });

    test('hashCode and operator ==', () {
      final env1 = Environment();
      final env2 = Environment();
      final env3 = Environment(blockStart: '[[', blockEnd: ']]');

      expect(env1, equals(env2));
      expect(env1.hashCode, equals(env2.hashCode));
      expect(env1, isNot(equals(env3)));
    });

    test('modifiers and templates addAll', () {
      final env = Environment(
        modifiers: [(node) => node],
        templates: {'test': Template('foo')},
      );
      expect(env.modifiers, hasLength(1));
      expect(env.templates, contains('test'));
    });

    test('convenience methods', () {
      final env = Environment();
      const source = '{{ x }}';

      final tokens = env.lex(source);
      expect(tokens, isNotEmpty);

      final node = env.scan(tokens);
      expect(node, isNotNull);

      final parsed = env.parse(source);
      expect(parsed, isNotNull);
    });

    test('callCommon ContextFilter without context', () {
      final env = Environment();
      final filter = ContextFilter((Context c) => 'ok');
      expect(
        () => env.callCommon(filter, [], {}, null),
        throwsA(
          isA<TemplateRuntimeError>().having(
            (e) => e.message,
            'message',
            contains('without context'),
          ),
        ),
      );
    });

    test('callCommon EnvFilter', () {
      final env = Environment();
      final filter = EnvFilter((Environment e) => e == env);
      expect(env.callCommon(filter, [], {}, null), isTrue);
    });

    test('callCommon Invalid callable', () {
      final env = Environment();
      expect(
        () => env.callCommon(42, [], {}, null),
        throwsA(
          isA<TemplateRuntimeError>().having(
            (e) => e.message,
            'message',
            contains('Invalid callable'),
          ),
        ),
      );
    });

    test('callFilter ContextFilter without context', () {
      final env = Environment(filters: {'ctx': ContextFilter((c) => 'ok')});
      expect(
        () => env.callFilter('ctx', [], {}),
        throwsA(
          isA<TemplateRuntimeError>().having(
            (e) => e.message,
            'message',
            contains('without context'),
          ),
        ),
      );
    });

    test('callFilter async arguments', () async {
      final env = Environment(filters: {'id': (x) => x});
      final result = await env.callFilter('id', [Future.value(42)], {});
      expect(result, equals(42));
    });

    test('callFilter error wrapping', () {
      final env = Environment(filters: {'fail': () => throw Exception('oops')});
      expect(
        () => env.callFilter('fail', [], {}),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });

    test('callTest async arguments', () async {
      final env = Environment();
      // 'defined' test
      final result = await env.callTest('defined', [Future.value(42)], {});
      expect(result, isTrue);
    });

    test('callFilter missing filter throws TemplateRuntimeError', () {
      final env = Environment();
      expect(
        () => env.callFilter('missing', [], {}),
        throwsA(
          isA<TemplateRuntimeError>().having(
            (e) => e.message,
            'message',
            contains("No filter named 'missing'"),
          ),
        ),
      );
    });

    test('callFilter non-function filter throws TemplateRuntimeError', () {
      final env = Environment(filters: {'bad': 42});
      expect(
        () => env.callFilter('bad', [], {}),
        throwsA(
          isA<TemplateRuntimeError>().having(
            (e) => e.message,
            'message',
            contains('is not a function'),
          ),
        ),
      );
    });

    test('callFilter async error wrapping branch', () async {
      final env = Environment(
        filters: {
          'boom': (Object? _) => throw Exception('boom'),
        },
      );
      await expectLater(
        env.callFilter('boom', <Object?>[Future.value(1)], {}),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });

    test('callTest missing test throws TemplateRuntimeError', () {
      final env = Environment();
      expect(
        () => env.callTest('missing', [], {}),
        throwsA(
          isA<TemplateRuntimeError>().having(
            (e) => e.message,
            'message',
            contains("No test named 'missing'"),
          ),
        ),
      );
    });

    test('callTest async error wrapping branch', () async {
      final env = Environment(
        tests: {
          'boom': (Object? _) => throw Exception('boom'),
        },
      );
      await expectLater(
        env.callTest('boom', <Object?>[Future.value(1)], {}),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });

    test('DefaultJinjaLogger methods call dart:developer.log', () {
      const logger = DefaultJinjaLogger();
      // These calls should not throw; we just exercise the paths.
      logger.debug('debug message');
      logger.info('info message');
      logger.warn('warn message');
      logger.error('error message');
    });

    test('debugJinja uses logger when enabled', () {
      final captured = <String>[];
      final logger = _TestLogger(captured);
      final env = Environment(
        enableJinjaDebugLogging: true,
        logger: logger,
      );

      env.debugJinja('hello');
      expect(captured, contains('[DEBUG-JINJA] hello'));
    });

    test('debugJinja is a no-op when disabled', () {
      final captured = <String>[];
      final logger = _TestLogger(captured);
      final env = Environment(
        logger: logger,
      );

      env.debugJinja('ignored');
      expect(captured, isEmpty);
    });
  });
}

class _TestLogger implements JinjaLogger {
  _TestLogger(this.messages);

  final List<String> messages;

  @override
  void debug(String message) {
    messages.add(message);
  }

  @override
  void info(String message) {
    messages.add(message);
  }

  @override
  void warn(String message) {
    messages.add(message);
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    messages.add(message);
  }
}
