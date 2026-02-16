@TestOn('vm')
library;

import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/async_debug_renderer.dart';
import 'package:jinja/src/debug/debug_controller.dart';
import 'package:jinja/src/debug/debug_renderer.dart';
import 'package:jinja/src/nodes.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();
  late DebugController controller;
  late AsyncDebugRenderer renderer;

  setUp(() {
    controller = DebugController()..enabled = true;
    renderer = AsyncDebugRenderer();
  });

  group('AsyncDebugRenderer', () {
    test('visitArray', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      const node = Array(values: [Constant(value: 1)]);
      final result = await renderer.visitArray(node, context);
      expect(result, equals([1]));
    });

    test('visitDict', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      const node = Dict(pairs: [(key: Constant(value: 'a'), value: Constant(value: 1))]);
      final result = await renderer.visitDict(node, context);
      expect(result, equals({'a': 1}));
    });

    test('visitCall', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller, data: {'f': (x) => x + 1});
      final node = Call(value: const Name(name: 'f'), calling: const Calling(arguments: [Constant(value: 1)]));
      final result = await renderer.visitCall(node, context);
      expect(result, equals(2));
    });

    test('visitCompare', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      const node = Compare(value: Constant(value: 1), operands: [(CompareOperator.equal, Constant(value: 1))]);
      final result = await renderer.visitCompare(node, context);
      expect(result, isTrue);
    });

    test('visitCondition', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      const node = Condition(test: Constant(value: true), trueValue: Constant(value: 1), falseValue: Constant(value: 2));
      final result = await renderer.visitCondition(node, context);
      expect(result, equals(1));
    });

    test('visitFilter', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      final node = Filter(name: 'upper', calling: const Calling(arguments: [Constant(value: 'a')]));
      final result = await renderer.visitFilter(node, context);
      expect(result, equals('A'));
    });

    test('visitTest', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      final node = Test(name: 'defined', calling: const Calling(arguments: [Constant(value: 1)]));
      final result = await renderer.visitTest(node, context);
      expect(result, isTrue);
    });

    test('visitAssign', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      const node = Assign(target: Name.store(name: 'a'), value: Constant(value: 1));
      await renderer.visitAssign(node, context);
      expect(context.context['a'], equals(1));
    });

    test('visitFor', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      final node = For(
        target: const Name.store(name: 'x'),
        iterable: const Array(values: [Constant(value: 1)]),
        body: const Data(data: 'foo'),
      );
      await renderer.visitFor(node, context);
      expect(context.sink.toString(), equals('foo'));
    });

    test('visitIf', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      const node = If(test: Constant(value: true), body: Data(data: 'yes'));
      await renderer.visitIf(node, context);
      expect(context.sink.toString(), equals('yes'));
    });

    test('visitInterpolation', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      const node = Interpolation(value: Constant(value: 'foo'));
      await renderer.visitInterpolation(node, context);
      expect(context.sink.toString(), equals('foo'));
    });

    test('visitOutput', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      const node = Output(nodes: [Data(data: 'a'), Data(data: 'b')]);
      await renderer.visitOutput(node, context);
      expect(context.sink.toString(), equals('ab'));
    });

    test('visitWith', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      const node = With(targets: [Name.store(name: 'x')], values: [Constant(value: 1)], body: Data(data: 'foo'));
      await renderer.visitWith(node, context);
      expect(context.sink.toString(), equals('foo'));
    });

    test('visitTrans', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      final node = Trans(body: const Data(data: 'foo'));
      await renderer.visitTrans(node, context);
      expect(context.sink.toString(), equals('foo'));
    });

    test('visitTryCatch', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      final node = TryCatch(body: const Data(data: 'foo'), catchBody: const Data(data: 'bar'));
      await renderer.visitTryCatch(node, context);
      expect(context.sink.toString(), equals('foo'));
    });

    test('visitSlice', () async {
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      const node = Slice(value: Constant(value: [1, 2, 3]), start: Constant(value: 0), stop: Constant(value: 2));
      final result = await renderer.visitSlice(node, context);
      expect(result, equals([1, 2]));
    });
  });
}
