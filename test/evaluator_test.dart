@TestOn('vm || chrome')
library;

import 'package:jinja/src/debug/evaluator.dart';
import 'package:jinja/src/environment.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();
  const evaluator = ExpressionEvaluator();

  group('ExpressionEvaluator', () {
    late StringSinkRenderContext context;

    setUp(() {
      context = StringSinkRenderContext(env, StringBuffer(), data: {
        'x': 10,
        'm': {'y': 20}
      });
    });

    test('visitConstant', () {
      expect(evaluator.visitConstant(const Constant(value: 42), context), equals(42));
    });

    test('visitName', () {
      expect(evaluator.visitName(const Name(name: 'x'), context), equals(10));
    });

    test('visitAttribute', () {
      final node = Attribute(value: const Name(name: 'm'), attribute: 'y');
      expect(evaluator.visitAttribute(node, context), equals(20));
    });

    test('visitItem', () {
      final node = Item(value: const Name(name: 'm'), key: const Constant(value: 'y'));
      expect(evaluator.visitItem(node, context), equals(20));
    });

    test('visitCompare', () {
      final node = Compare(
        value: const Name(name: 'x'),
        operands: [(CompareOperator.equal, const Constant(value: 10))],
      );
      expect(evaluator.visitCompare(node, context), isTrue);

      final node2 = Compare(
        value: const Name(name: 'x'),
        operands: [(CompareOperator.lessThan, const Constant(value: 5))],
      );
      expect(evaluator.visitCompare(node2, context), isFalse);
    });

    test('UnsupportedError', () {
      expect(() => evaluator.visitAssign(const Assign(target: Name(name: 'a'), value: Constant(value: 1)), context), throwsUnsupportedError);
      expect(() => evaluator.visitIf(const If(test: Constant(value: true), body: Data(data: 'ok')), context), throwsUnsupportedError);
    });

    test('UnimplementedError', () {
      expect(() => evaluator.visitArray(const Array(values: []), context), throwsUnimplementedError);
    });
  });
}
