@TestOn('vm || chrome')
library;

import 'package:jinja/src/environment.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/runtime.dart';
import 'package:jinja/src/defaults.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();

  group('Context', () {
    test('derived', () {
      final context = Context(env, data: {'a': 1});
      final derived = context.derived(data: {'b': 2});
      expect(derived.context['b'], equals(2));
      expect(
        derived.parent,
        isEmpty,
      ); // Base Context.derived just passes this.parent
    });

    test('has', () {
      final context = Context(env, data: {'a': 1});
      expect(context.has('a'), isTrue);
      expect(context.has('b'), isFalse);
    });

    test('call LoopContext error', () {
      final context = Context(env);
      final loop = LoopContext([1, 2, 3], 0, (data, [depth = 0]) => '');
      expect(
        () => context.call(loop, null, []),
        throwsA(
          isA<TemplateRuntimeError>().having(
            (e) => e.message,
            'message',
            contains('requires an iterable argument'),
          ),
        ),
      );
    });

    test('call error wrapping', () {
      final context = Context(env);
      // Function throwing non-TemplateError should be wrapped
      expect(
        () => context.call(() => throw Exception('test'), null),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });

    test('resolveAsync with Future', () async {
      final context = Context(env, data: {'a': Future.value(42)});
      final result = await context.resolveAsync('a');
      expect(result, equals(42));
    });

    test('resolveAsync with non-Future', () async {
      final context = Context(env, data: {'a': 10});
      final result = await context.resolveAsync('a');
      expect(result, equals(10));
    });

    test('resolve error wrapping', () {
      // Mock an object that throws on toString to trigger the catch block in log
      final context = Context(env, data: {'bad': _ThrowingObject()});
      expect(context.resolve('bad'), isA<_ThrowingObject>());
    });
  });

  group('LoopContext', () {
    test('properties', () {
      final loop = LoopContext([1, 2, 3], 0, (data, [depth = 0]) => '');
      final it = loop.iterator;
      it.moveNext();
      expect(loop.index, equals(1));
      expect(loop.first, isTrue);
      expect(loop.last, isFalse);
      expect(loop.revindex, equals(3));

      it.moveNext();
      expect(loop.index, equals(2));
      expect(loop.first, isFalse);
      expect(loop.last, isFalse);

      it.moveNext();
      expect(loop.index, equals(3));
      expect(loop.first, isFalse);
      expect(loop.last, isTrue);
    });

    test('cycle', () {
      final loop = LoopContext([1, 2, 3], 0, (data, [depth = 0]) => '');
      final it = loop.iterator;
      it.moveNext();
      expect(loop.cycle(['a', 'b']), equals('a'));
      it.moveNext();
      expect(loop.cycle(['a', 'b']), equals('b'));
      it.moveNext();
      expect(loop.cycle(['a', 'b']), equals('a'));
    });
  });

  group('Cycler', () {
    test('cycling', () {
      final cycler = Cycler(['a', 'b', 'c']);
      expect(cycler.current, equals('a'));
      expect(cycler.next(), equals('a'));
      expect(cycler.current, equals('b'));
      expect(cycler.next(), equals('b'));
      expect(cycler.next(), equals('c'));
      expect(cycler.next(), equals('a'));
    });
  });
}

class _ThrowingObject {
  @override
  String toString() => throw Exception('toString failed');
}
