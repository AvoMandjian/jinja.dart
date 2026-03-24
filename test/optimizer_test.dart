@TestOn('vm || chrome')
library;

import 'package:jinja/src/environment.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/optimizer.dart';
import 'package:jinja/src/runtime.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();
  const optimizer = Optimizer();

  group('Optimizer', () {
    test('visitAttribute constant folding', () {
      final context = Context(
        env,
        data: {
          'foo': {'bar': 42},
        },
      );
      final node = Attribute(
        value: const Constant(value: {'bar': 42}),
        attribute: 'bar',
      );
      final optimized = optimizer.visitAttribute(node, context);
      expect(optimized, isA<Constant>().having((c) => c.value, 'value', 42));
    });

    test('visitItem constant folding', () {
      final context = Context(env);
      final node = Item(
        value: const Constant(value: {'a': 1}),
        key: const Constant(value: 'a'),
      );
      final optimized = optimizer.visitItem(node, context);
      expect(optimized, isA<Constant>().having((c) => c.value, 'value', 1));
    });

    test('visitConcat constant folding', () {
      final context = Context(env);
      final node = Concat(
        values: [const Constant(value: 'foo'), const Constant(value: 'bar')],
      );
      final optimized = optimizer.visitConcat(node, context);
      expect(
        optimized,
        isA<Constant>().having((c) => c.value, 'value', 'foobar'),
      );
    });

    test('visitDict constant folding for all-constant pairs', () {
      final context = Context(env);
      const node = Dict(
        pairs: <Pair>[
          (key: Constant(value: 'a'), value: Constant(value: 1)),
          (key: Constant(value: 'b'), value: Constant(value: 2)),
        ],
      );

      final optimized = optimizer.visitDict(node, context);

      expect(
        optimized,
        isA<Constant>().having(
          (c) => c.value,
          'value',
          <Object?, Object?>{'a': 1, 'b': 2},
        ),
      );
    });

    test('visitDict does not fold when any pair is non-constant', () {
      final context = Context(env, data: const {'x': 42});
      const node = Dict(
        pairs: <Pair>[
          (key: Constant(value: 'a'), value: Constant(value: 1)),
          (key: Constant(value: 'b'), value: Name(name: 'x')),
        ],
      );

      final optimized = optimizer.visitDict(node, context);

      expect(optimized, isA<Dict>());
    });

    test('visitBlock', () {
      final context = Context(env);
      const node = Block(
        name: 'test',
        scoped: false,
        required: false,
        body: Data(data: 'foo'),
      );
      final optimized = optimizer.visitBlock(node, context);
      expect(optimized, isA<Block>());
    });

    test('visitCallBlock', () {
      final context = Context(env);
      final node = CallBlock(
        name: 'caller',
        call: const Call(value: Name(name: 'test')),
        body: const Data(data: 'foo'),
      );
      final optimized = optimizer.visitCallBlock(node, context);
      expect(optimized, isA<CallBlock>());
    });

    test('visitContinue', () {
      final context = Context(env);
      const node = Continue();
      final optimized = optimizer.visitContinue(node, context);
      expect(optimized, isA<Continue>());
    });

    test('visitDebug', () {
      final context = Context(env);
      const node = Debug();
      final optimized = optimizer.visitDebug(node, context);
      expect(optimized, isA<Debug>());
    });

    test('visitTrans', () {
      final context = Context(env);
      final node = Trans(body: const Data(data: 'foo'));
      final optimized = optimizer.visitTrans(node, context);
      expect(optimized, isA<Trans>());
    });
  });
}
