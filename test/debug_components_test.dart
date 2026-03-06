@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/debug_renderer.dart';
import 'package:jinja/src/debug/evaluator.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:test/test.dart';

void main() {
  group('DebugRenderer & Evaluator', () {
    test('Evaluator correctness on conditional breakpoint node', () {
      final env = Environment();
      final context = StringSinkRenderContext(env, StringBuffer(), data: {'isAdmin': true});
      const evaluator = ExpressionEvaluator();

      final node = Compare(
        value: Name(name: 'isAdmin'),
        operands: [(CompareOperator.equal, Constant(value: true))],
      );

      final result = evaluator.visitCompare(node, context);
      expect(result, isTrue);
    });

    test('Evaluator throws on non-expression node', () {
      final env = Environment();
      final context = StringSinkRenderContext(env, StringBuffer());
      const evaluator = ExpressionEvaluator();

      // For is a statement, not an expression, so evaluator should throw unsupported
      final node = For(
        target: Name(name: 'x'),
        iterable: Array(values: []),
        body: TemplateNode(body: Data()),
      );
      expect(() => evaluator.visitFor(node, context), throwsUnsupportedError);
    });

    test('DebugRenderer captures BreakpointInfo and line numbers', () {
      final env = Environment();
      final controller = DebugController()..enabled = true;
      // We set a breakpoint on line 2
      controller.addBreakpoint(line: 2);

      final renderer = DebugRenderer();
      final buffer = StringBuffer();
      final context = DebugRenderContext(
        env,
        buffer,
        debugController: controller,
        data: {'counter': 42},
      );

      final node = Interpolation(value: Constant(value: 1), line: 2);

      // Visiting should hit the breakpoint and log it in history
      renderer.visitInterpolation(node, context);

      expect(controller.history, isNotEmpty);
      final breakpointInfo = controller.history.first;
      expect(breakpointInfo.lineNumber, equals(2));
      expect(breakpointInfo.variables['counter'], equals(42));
      expect(breakpointInfo.nodeType, equals('Interpolation'));
    });
  });
}
