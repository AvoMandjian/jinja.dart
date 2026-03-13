@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/debug_renderer.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:jinja/src/runtime.dart';
import 'package:test/test.dart';

void main() {
  group('DebugRenderContext', () {
    final env = Environment();

    test('derived creates context with new output buffer', () {
      final controller = DebugController();
      final ctx = DebugRenderContext(env, StringBuffer(), debugController: controller);
      ctx.write('hello');

      final derived = ctx.derived();
      expect(derived, isA<DebugRenderContext>());
      expect(derived.outputSoFar, equals('hello'));
    });

    test('getAllVariables extracts namespace context', () {
      final controller = DebugController();
      final ns = Namespace({'inner': 'value'});

      // We pass a function to verify it gets filtered out
      void func() {}

      final ctx = DebugRenderContext(
        env,
        StringBuffer(),
        debugController: controller,
        data: {'ns': ns, 'f': func, 'normal': 42},
      );

      final vars = ctx.getAllVariables();
      expect(vars['inner'], equals('value')); // Namespace extracted
      expect(vars['normal'], equals(42));
      expect(vars.containsKey('f'), isFalse); // Function filtered out
      expect(vars.containsKey('ns'), isFalse); // The namespace itself is spread
    });
  });

  group('DebugRenderer visitors and conditions', () {
    final env = Environment();

    test('Conditional breakpoint hits when true', () async {
      final controller = DebugController()..enabled = true;
      controller.addBreakpoint(line: 2, condition: 'x == 1');

      final renderer = DebugRenderer();
      final context = DebugRenderContext(
        env,
        StringBuffer(),
        debugController: controller,
        data: {'x': 1},
      );

      final node = Interpolation(value: Constant(value: 1), line: 2);
      await renderer.visitInterpolation(node, context);

      expect(controller.history, isNotEmpty);
      expect(controller.history.first.lineNumber, equals(2));
    });

    test('Conditional breakpoint skipped when false', () async {
      final controller = DebugController()..enabled = true;
      controller.addBreakpoint(line: 2, condition: 'x == 2');

      final renderer = DebugRenderer();
      final context = DebugRenderContext(
        env,
        StringBuffer(),
        debugController: controller,
        data: {'x': 1},
      );

      final node = Interpolation(value: Constant(value: 1), line: 2);
      await renderer.visitInterpolation(node, context);

      expect(controller.history, isEmpty);
    });

    test('Conditional breakpoint with syntax error is ignored', () async {
      final controller = DebugController()..enabled = true;
      controller.addBreakpoint(line: 2, condition: '{% invalid %syntax %}');

      final renderer = DebugRenderer();
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);

      final node = Interpolation(value: Constant(value: 1), line: 2);
      await renderer.visitInterpolation(node, context);

      // Ignores error and does not break
      expect(controller.history, isEmpty);
    });

    test('visitData hits breakpoint', () async {
      final controller = DebugController()..enabled = true;
      controller.addBreakpoint(line: 1);
      final renderer = DebugRenderer();
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      await renderer.visitData(Data(data: 'test', line: 1), context);
      expect(controller.history, isNotEmpty);
    });

    test('visitFor hits breakpoint', () async {
      final controller = DebugController()..enabled = true;
      controller.addBreakpoint(line: 1);
      final renderer = DebugRenderer();
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      final node = For(
        target: Name(name: 'x'),
        iterable: Array(values: []),
        body: TemplateNode(body: Data()),
        line: 1,
      );

      try {
        await renderer.visitFor(node, context);
      } catch (_) {}
      expect(controller.history, isNotEmpty);
    });

    test('visitIf hits breakpoint', () async {
      final controller = DebugController()..enabled = true;
      controller.addBreakpoint(line: 0);
      final renderer = DebugRenderer();
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      final node = If(test: Constant(value: true), body: TemplateNode(body: Data()));
      try {
        await renderer.visitIf(node, context);
      } catch (_) {}
      expect(controller.history, isNotEmpty);
    });

    test('visitAutoEscape hits breakpoint', () async {
      final controller = DebugController()..enabled = true;
      controller.addBreakpoint(line: 0);
      final renderer = DebugRenderer();
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      final node = AutoEscape(enable: true, body: TemplateNode(body: Data()));
      try {
        await renderer.visitAutoEscape(node, context);
      } catch (_) {}
      expect(controller.history, isNotEmpty);
    });

    test('visitAssign hits breakpoint', () async {
      final controller = DebugController()..enabled = true;
      controller.addBreakpoint(line: 0);
      final renderer = DebugRenderer();
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      final node = Assign(target: Name(name: 'x'), value: Constant(value: 1));
      try {
        await renderer.visitAssign(node, context);
      } catch (_) {}
      expect(controller.history, isNotEmpty);
    });

    test('visitBlock hits breakpoint', () async {
      final controller = DebugController()..enabled = true;
      controller.addBreakpoint(line: 0);
      final renderer = DebugRenderer();
      final context = DebugRenderContext(env, StringBuffer(), debugController: controller);
      final node = Block(name: 'b', scoped: false, required: false, body: TemplateNode(body: Data()));
      try {
        await renderer.visitBlock(node, context);
      } catch (_) {}
      expect(controller.history, isNotEmpty);
    });

    test('non-debug context skips breakpoints', () async {
      final controller = DebugController()..enabled = true;
      controller.addBreakpoint(line: 1);
      final renderer = DebugRenderer();

      // Standard StringSinkRenderContext instead of DebugRenderContext
      final context = StringSinkRenderContext(env, StringBuffer());
      final node = Data(data: 'test', line: 1);

      await renderer.visitData(node, context);
      expect(controller.history, isEmpty);
    });
  });
}
