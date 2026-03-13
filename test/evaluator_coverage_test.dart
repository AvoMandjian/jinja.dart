@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/evaluator.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:test/test.dart';

void main() {
  group('ExpressionEvaluator coverage', () {
    final env = Environment();
    final context = StringSinkRenderContext(env, StringBuffer());
    const evaluator = ExpressionEvaluator();

    test('visitCompare covers all operators', () {
      final baseNode = Compare(
        value: Constant(value: 2),
        operands: [],
      );

      bool evaluateOp(CompareOperator op, Object left, Object right) {
        final node = Compare(
          value: Constant(value: left),
          operands: [(op, Constant(value: right))],
        );
        return evaluator.visitCompare(node, context);
      }

      expect(evaluateOp(CompareOperator.equal, 2, 2), isTrue);
      expect(evaluateOp(CompareOperator.notEqual, 2, 3), isTrue);
      expect(evaluateOp(CompareOperator.lessThan, 2, 3), isTrue);
      expect(evaluateOp(CompareOperator.lessThanOrEqual, 2, 2), isTrue);
      expect(evaluateOp(CompareOperator.greaterThan, 3, 2), isTrue);
      expect(evaluateOp(CompareOperator.greaterThanOrEqual, 2, 2), isTrue);
      expect(evaluateOp(CompareOperator.contains, 2, [1, 2, 3]), isTrue);
      expect(evaluateOp(CompareOperator.notContains, 4, [1, 2, 3]), isTrue);

      // early return false
      expect(evaluateOp(CompareOperator.equal, 1, 2), isFalse);
    });

    test('visitAttribute and visitItem', () {
      final dataCtx = StringSinkRenderContext(env, StringBuffer(), data: {
        'map': {'k': 'v'}
      });
      final attrNode = Attribute(value: Name(name: 'map'), attribute: 'k');
      expect(evaluator.visitAttribute(attrNode, dataCtx), equals('v'));

      final itemNode = Item(value: Name(name: 'map'), key: Constant(value: 'k'));
      expect(evaluator.visitItem(itemNode, dataCtx), equals('v'));
    });

    test('Unsupported statements throw UnsupportedError', () {
      final unsupportedNodes = <Node>[
        Assign(target: Name(name: 'x'), value: Constant(value: 1)),
        AssignBlock(target: Name(name: 'x'), body: TemplateNode(body: Data())),
        AutoEscape(enable: true, body: TemplateNode(body: Data())),
        Block(name: 'b', scoped: false, required: false, body: TemplateNode(body: Data())),
        Break(),
        CallBlock(name: 'c', call: Call(value: Name(name: 'f')), body: TemplateNode(body: Data())),
        Continue(),
        Data(),
        Debug(),
        Do(value: Constant(value: 1)),
        Extends(template: Constant(value: 't')),
        FilterBlock(filters: [Filter(name: 'f')], body: TemplateNode(body: Data())),
        For(target: Name(name: 'x'), iterable: Array(values: []), body: TemplateNode(body: Data())),
        FromImport(template: Constant(value: 't'), names: []),
        If(test: Constant(value: true), body: TemplateNode(body: Data())),
        Import(template: Constant(value: 't'), target: 't'),
        Include(template: Constant(value: 't')),
        Interpolation(value: Constant(value: 1)),
        Macro(name: 'm', body: TemplateNode(body: Data())),
        Output(),
        TemplateNode(body: Data()),
        Trans(body: Data()),
        TryCatch(body: TemplateNode(body: Data()), catchBody: TemplateNode(body: Data())),
        With(targets: [], values: [], body: TemplateNode(body: Data())),
      ];

      for (var node in unsupportedNodes) {
        expect(() => node.accept(evaluator, context), throwsUnsupportedError);
      }
    });

    test('Unimplemented expressions throw UnimplementedError', () {
      final unimplementedNodes = <Node>[
        Array(values: []),
        Call(value: Name(name: 'f')),
        Calling(),
        Concat(values: []),
        Condition(test: Constant(value: true), trueValue: Constant(value: 1), falseValue: Constant(value: 0)),
        Dict(pairs: []),
        Filter(name: 'f'),
        Logical(operator: LogicalOperator.and, left: Constant(value: true), right: Constant(value: true)),
        NamespaceRef(name: 'n', attribute: 'a'),
        Scalar(operator: ScalarOperator.plus, left: Constant(value: 1), right: Constant(value: 1)),
        Slice(value: Name(name: 'v'), start: Constant(value: 0)),
        Test(name: 't'),
        Tuple(values: []),
        Unary(operator: UnaryOperator.not, value: Constant(value: true)),
      ];

      for (var node in unimplementedNodes) {
        expect(() => node.accept(evaluator, context), throwsUnimplementedError);
      }
    });
  });
}
