import 'dart:async';

import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/async_debug_renderer.dart';
import 'package:jinja/src/debug/debug_renderer.dart';
import 'package:jinja/src/nodes.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();

  group('AsyncDebugRenderer Coverage Extensions', () {
    test('visitFor with orElse (empty iterable)', () async {
      final controller = DebugController()..enabled = true;
      final renderer = AsyncDebugRenderer();
      final sink = StringBuffer();
      final context =
          DebugRenderContext(env, sink, debugController: controller);

      final node = For(
        target: Name(name: 'i', context: AssignContext.store),
        iterable: Constant(value: []),
        body: Data(data: 'body'),
        orElse: Data(data: 'else'),
      );

      await renderer.visitFor(node, context);
      expect(sink.toString(), equals('else'));
    });

    test('visitFor with test condition', () async {
      final controller = DebugController()..enabled = true;
      final renderer = AsyncDebugRenderer();
      final sink = StringBuffer();
      final context =
          DebugRenderContext(env, sink, debugController: controller);

      final node = For(
        target: Name(name: 'i', context: AssignContext.store),
        iterable: Constant(value: [1, 2, 3, 4]),
        test: Compare(
            value: Name(name: 'i'),
            operands: [(CompareOperator.greaterThan, Constant(value: 2))]),
        body: Interpolation(value: Name(name: 'i')),
      );

      await renderer.visitFor(node, context);
      expect(sink.toString(), equals('34'));
    });

    test('visitFor with Future iterable', () async {
      final controller = DebugController()..enabled = true;
      final renderer = AsyncDebugRenderer();
      final sink = StringBuffer();
      final context =
          DebugRenderContext(env, sink, debugController: controller);

      final futureIterable = Future.value([1, 2]);
      final node = For(
        target: Name(name: 'i', context: AssignContext.store),
        iterable: Constant(value: futureIterable),
        body: Interpolation(value: Name(name: 'i')),
      );

      await renderer.visitFor(node, context);
      // The Future is awaited by the renderer
      expect(sink.toString(), equals('12'));
    });

    test('_checkBreakpoint with condition error', () async {
      final controller = DebugController()..enabled = true;
      // Add breakpoint with invalid condition
      controller.addBreakpoint(line: 1, condition: 'invalid +++ syntax');

      final renderer = AsyncDebugRenderer();
      final context =
          DebugRenderContext(env, StringBuffer(), debugController: controller);

      // Should not throw, but ignore the error as per implementation
      await renderer.visitData(Data(data: 'foo', line: 1), context);
    });

    test('visitFor with BreakException', () async {
      final controller = DebugController()..enabled = true;
      final renderer = AsyncDebugRenderer();
      final sink = StringBuffer();
      final context =
          DebugRenderContext(env, sink, debugController: controller);

      final node = For(
        target: Name(name: 'i', context: AssignContext.store),
        iterable: Constant(value: [1, 2, 3]),
        body: If(
          test: Compare(
              value: Name(name: 'i'),
              operands: [(CompareOperator.equal, Constant(value: 2))]),
          body: Break(),
          orElse: Interpolation(value: Name(name: 'i')),
        ),
      );

      await renderer.visitFor(node, context);
      expect(sink.toString(), equals('1'));
    });

    test('visitFor with ContinueException', () async {
      final controller = DebugController()..enabled = true;
      final renderer = AsyncDebugRenderer();
      final sink = StringBuffer();
      final context =
          DebugRenderContext(env, sink, debugController: controller);

      final node = For(
        target: Name(name: 'i', context: AssignContext.store),
        iterable: Constant(value: [1, 2, 3]),
        body: If(
          test: Compare(
              value: Name(name: 'i'),
              operands: [(CompareOperator.equal, Constant(value: 2))]),
          body: Continue(),
          orElse: Interpolation(value: Name(name: 'i')),
        ),
      );

      await renderer.visitFor(node, context);
      expect(sink.toString(), equals('13'));
    });

    test('_checkBreakpoint with conditional breakpoint', () async {
      final controller = DebugController()..enabled = true;
      // Hit condition
      controller.addBreakpoint(line: 1, condition: 'x == 1');
      // Miss condition
      controller.addBreakpoint(line: 2, condition: 'x == 2');

      final renderer = AsyncDebugRenderer();
      final sink = StringBuffer();
      final context = DebugRenderContext(env, sink,
          debugController: controller, data: {'x': 1});

      var hit1 = false;
      var hit2 = false;
      controller.onBreakpoint = (info) async {
        if (info.lineNumber == 1) hit1 = true;
        if (info.lineNumber == 2) hit2 = true;
        return DebugAction.continue_;
      };

      await renderer.visitData(Data(data: 'a', line: 1), context);
      await renderer.visitData(Data(data: 'b', line: 2), context);

      expect(hit1, isTrue);
      expect(hit2, isFalse);
    });

    test('visitIf true and false branches', () async {
      final controller = DebugController()..enabled = true;
      final renderer = AsyncDebugRenderer();
      final sink = StringBuffer();
      final context =
          DebugRenderContext(env, sink, debugController: controller);

      // True branch
      final nodeTrue = If(
          test: Constant(value: true),
          body: Data(data: 'yes'),
          orElse: Data(data: 'no'));
      await renderer.visitIf(nodeTrue, context);
      expect(sink.toString(), equals('yes'));

      // False branch
      sink.clear();
      final nodeFalse = If(
          test: Constant(value: false),
          body: Data(data: 'yes'),
          orElse: Data(data: 'no'));
      await renderer.visitIf(nodeFalse, context);
      expect(sink.toString(), equals('no'));
    });

    test('visitMacro in debug mode', () async {
      final controller = DebugController()..enabled = true;
      final renderer = AsyncDebugRenderer();
      final sink = StringBuffer();
      final context =
          DebugRenderContext(env, sink, debugController: controller);

      final node = Macro(
        name: 'm',
        positional: [Name(name: 'x', context: AssignContext.store)],
        named: [],
        body: Interpolation(value: Name(name: 'x')),
      );

      await renderer.visitMacro(node, context);
      final macro = context.resolve('m') as Function;
      final result = await macro(['hi'], {});
      expect(result.toString(), equals('hi'));
    });

    test('visitCallBlock in debug mode', () async {
      final controller = DebugController()..enabled = true;
      final renderer = AsyncDebugRenderer();
      final sink = StringBuffer();
      final context = DebugRenderContext(
        env,
        sink,
        debugController: controller,
        data: {
          'caller_user': (List positional, Map named) {
            final caller = named['caller'] as Function;
            // In sync mode, caller() might return a Future if it is an async macro,
            // but here we are in StringSinkRenderer.visitCallBlock which is sync.
            final content = caller([], {});
            return 'CALLER: $content';
          },
        },
      );

      final node = CallBlock(
        name: 'caller',
        call: Call(
            value: Name(name: 'caller_user'),
            calling:
                Calling(arguments: [Constant(value: []), Constant(value: {})])),
        body: Data(data: 'inside'),
      );

      await renderer.visitCallBlock(node, context);
      expect(sink.toString(), contains('CALLER: inside'));
    });
  });
}
