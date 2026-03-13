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

  group('Context.call advanced', () {
    test('rethrows TemplateError without wrapping', () {
      final env = Environment();
      final context = Context(env);

      expect(
        () => context.call(
          () => throw TemplateRuntimeError('boom'),
          null,
        ),
        throwsA(isA<TemplateRuntimeError>()),
      );
    });

    test('throws TemplateRuntimeError when called on null object', () {
      final env = Environment();
      final context = Context(env);

      expect(
        () => context.call(null, null, [1]),
        throwsA(isA<TemplateRuntimeError>()),
      );
    });

    test('logs and falls back when .call getter throws', () {
      final env = Environment(
        enableJinjaDebugLogging: true,
        logger: _ThrowingLogger(),
      );
      final context = Context(env);

      expect(
        () => context.call(_BadCallable(), null),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });
  });

  group('Context.has hierarchy', () {
    test('checks parent and loader.globals', () {
      final env = Environment(
        loader: MapLoader(
          const <String, String>{},
          globalJinjaData: <String, Object?>{'from_loader': 1},
        ),
      );
      final context = Context(
        env,
        parent: <String, Object?>{'from_parent': 1},
      );

      expect(context.has('from_parent'), isTrue);
      expect(context.has('from_loader'), isTrue);
      expect(context.has('missing'), isFalse);
    });
  });

  group('Context.resolveAsync hierarchy', () {
    test('resolves Future in parent', () async {
      final env = Environment();
      final context = Context(
        env,
        parent: <String, Object?>{'p': Future<int>.value(10)},
      );

      final result = await context.resolveAsync('p');
      expect(result, equals(10));
    });

    test('resolves Future in loader.globals', () async {
      final env = Environment(
        loader: MapLoader(
          const <String, String>{},
          globalJinjaData: <String, Object?>{
            'g': Future<int>.value(42),
          },
        ),
      );
      final context = Context(env);

      final result = await context.resolveAsync('g');
      expect(result, equals(42));
    });

    test('falls back to undefined for missing async variable', () async {
      final env = Environment();
      final context = Context(env);

      final result = await context.resolveAsync('missing_async');
      expect(result, isNull);
    });
  });

  group('Context get/set/remove/undefined', () {
    test('get and set manipulate context map', () {
      final env = Environment();
      final context = Context(env, data: <String, Object?>{'a': 1});

      expect(context.get('a'), equals(1));
      context.set('b', 2);
      expect(context.get('b'), equals(2));
    });

    test('remove returns true only when key existed', () {
      final env = Environment();
      final context = Context(env, data: <String, Object?>{'a': 1});

      expect(context.remove('a'), isTrue);
      expect(context.remove('a'), isFalse);
    });

    test('undefined delegates to environment.undefined', () {
      final env = Environment();
      final context = Context(env);

      expect(context.undefined('missing'), isNull);
    });
  });

  group('Context.attribute and item error wrapping', () {
    test('wraps non-TemplateError from getAttribute', () {
      final env = Environment(
        getAttribute: (
          String attribute,
          Object? object, {
          Object? node,
          String? source,
        }) {
          throw Exception('attr failure');
        },
      );
      final context = Context(env);

      expect(
        () => context.attribute('x', Object(), null),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });

    test('wraps non-TemplateError from getItem', () {
      final env = Environment(
        getItem: (
          Object? key,
          Object? object, {
          Object? node,
          String? source,
        }) {
          throw Exception('item failure');
        },
      );
      final context = Context(env);

      expect(
        () => context.item('key', <String, Object?>{}, null),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });
  });

  group('Context.filter and test error wrapping', () {
    test('wraps non-TemplateError from callFilter', () {
      final env = _FilterThrowingEnvironment();
      final context = Context(env);

      expect(
        () => context.filter('any'),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });

    test('wraps non-TemplateError from callTest', () {
      final env = _TestThrowingEnvironment();
      final context = Context(env);

      expect(
        () => context.test('any'),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });
  });

  group('LoopContext extended', () {
    test('properties and operator[] access', () {
      final loop = LoopContext(
        <Object?>['x', 'y', 'y'],
        0,
        (_, [depth = 0]) => 'depth $depth',
      );

      final it = loop.iterator;
      // First element
      it.moveNext();
      expect(loop['length'], equals(3));
      expect(loop['index0'], equals(0));
      expect(loop['index'], equals(1));
      expect(loop['first'], isTrue);
      expect(loop['last'], isFalse);
      expect(loop['next'], equals('y'));
      expect(loop['prev'], isNull);

      final loopCall = loop['call'] as String Function(Object?);
      final loopCycle = loop['cycle'] as Object? Function(Iterable<Object?>);
      final loopChanged = loop['changed'] as bool Function(Object?);

      expect(loopCall('data'), equals('depth 1'));
      expect(loopCycle(<Object?>['a', 'b']), equals('a'));
      expect(loopChanged('x'), isTrue);

      // Second element
      it.moveNext();
      expect(loop['first'], isFalse);
      expect(loop['prev'], equals('x'));
      expect(loop['next'], equals('y'));
      expect(loopChanged('x'), isFalse);

      // Third element
      it.moveNext();
      expect(loop['last'], isTrue);
      expect(loop['next'], isNull);
    });

    test('cycle throws on empty iterable', () {
      final loop = LoopContext(<Object?>['x'], 0, (_, [depth = 0]) => '');
      final it = loop.iterator;
      it.moveNext();

      expect(
        () => loop.cycle(const <Object?>[]),
        throwsA(isA<TypeError>()),
      );
    });

    test('changed returns true on first element and when value differs', () {
      final loop = LoopContext(<Object?>['a', 'b'], 0, (_, [depth = 0]) => '');
      final it = loop.iterator;

      it.moveNext();
      expect(loop.changed('a'), isTrue);

      it.moveNext();
      expect(loop.changed('b'), isTrue);
    });
  });

  group('Namespace.factory', () {
    test('merges list of maps', () {
      final ns = Namespace.factory(<Object?>[
        <String, Object?>{'a': 1},
        <String, Object?>{'b': 2},
      ]);

      expect(ns['a'], equals(1));
      expect(ns['b'], equals(2));
    });

    test('throws TypeError for non-map entries', () {
      expect(
        () => Namespace.factory(<Object?>['not-a-map']),
        throwsA(isA<TypeError>()),
      );
    });
  });
}

class _BadCallable {
  int get call {
    throw Exception('call getter failed');
  }
}

class _ThrowingLogger implements JinjaLogger {
  @override
  void debug(String message) {
    throw Exception('logger debug failed');
  }

  @override
  void info(String message) {
    throw Exception('logger info failed');
  }

  @override
  void warn(String message) {
    throw Exception('logger warn failed');
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    throw Exception('logger error failed');
  }
}

base class _FilterThrowingEnvironment extends Environment {
  _FilterThrowingEnvironment() : super();

  @override
  dynamic callFilter(
    String name,
    List<Object?> positional, [
    Map<Symbol, Object?> named = const <Symbol, Object?>{},
    Context? context,
  ]) {
    throw Exception('filter failure');
  }
}

base class _TestThrowingEnvironment extends Environment {
  _TestThrowingEnvironment() : super();

  @override
  dynamic callTest(
    String name,
    List<Object?> positional, [
    Map<Symbol, Object?> named = const <Symbol, Object?>{},
    Context? context,
  ]) {
    throw Exception('test failure');
  }
}
