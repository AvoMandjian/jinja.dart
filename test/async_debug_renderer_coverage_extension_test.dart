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
      final context = DebugRenderContext(env, sink, debugController: controller);

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
      final context = DebugRenderContext(env, sink, debugController: controller);

      final node = For(
        target: Name(name: 'i', context: AssignContext.store),
        iterable: Constant(value: [1, 2, 3, 4]),
        test: Compare(value: Name(name: 'i'), operands: [(CompareOperator.greaterThan, Constant(value: 2))]),
        body: Interpolation(value: Name(name: 'i')),
      );

      await renderer.visitFor(node, context);
      expect(sink.toString(), equals('34'));
    });

    test('visitFor with Future iterable', () async {
      final controller = DebugController()..enabled = true;
      final renderer = AsyncDebugRenderer();
      final sink = StringBuffer();
      final context = DebugRenderContext(env, sink, debugController: controller);

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
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);

      // Should not throw, but ignore the error as per implementation
      await renderer.visitData(Data(data: 'foo', line: 1), context);
    });

    test('visitFor with BreakException', () async {
      final controller = DebugController()..enabled = true;
      final renderer = AsyncDebugRenderer();
      final sink = StringBuffer();
      final context = DebugRenderContext(env, sink, debugController: controller);

      final node = For(
        target: Name(name: 'i', context: AssignContext.store),
        iterable: Constant(value: [1, 2, 3]),
        body: If(
          test: Compare(value: Name(name: 'i'), operands: [(CompareOperator.equal, Constant(value: 2))]),
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
      final context = DebugRenderContext(env, sink, debugController: controller);

      final node = For(
        target: Name(name: 'i', context: AssignContext.store),
        iterable: Constant(value: [1, 2, 3]),
        body: If(
          test: Compare(value: Name(name: 'i'), operands: [(CompareOperator.equal, Constant(value: 2))]),
          body: Continue(),
          orElse: Interpolation(value: Name(name: 'i')),
        ),
      );

      await renderer.visitFor(node, context);
      expect(sink.toString(), equals('13'));
    });
  });
}
