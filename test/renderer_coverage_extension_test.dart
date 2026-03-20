import 'package:jinja/src/environment.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/loaders.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();
  const renderer = StringSinkRenderer();

  group('StringSinkRenderer Coverage Extensions', () {
    test('visitCompare all operators', () {
      final context = StringSinkRenderContext(env, StringBuffer());

      // Equal
      expect(
          renderer.visitCompare(Compare(value: Constant(value: 1), operands: [(CompareOperator.equal, Constant(value: 1))]), context), isTrue);
      // Not Equal
      expect(renderer.visitCompare(Compare(value: Constant(value: 1), operands: [(CompareOperator.notEqual, Constant(value: 2))]), context),
          isTrue);
      // Less Than
      expect(renderer.visitCompare(Compare(value: Constant(value: 1), operands: [(CompareOperator.lessThan, Constant(value: 2))]), context),
          isTrue);
      // Less Than Or Equal
      expect(
          renderer.visitCompare(Compare(value: Constant(value: 1), operands: [(CompareOperator.lessThanOrEqual, Constant(value: 1))]), context),
          isTrue);
      // Greater Than
      expect(renderer.visitCompare(Compare(value: Constant(value: 2), operands: [(CompareOperator.greaterThan, Constant(value: 1))]), context),
          isTrue);
      // Greater Than Or Equal
      expect(
          renderer.visitCompare(
              Compare(value: Constant(value: 2), operands: [(CompareOperator.greaterThanOrEqual, Constant(value: 2))]), context),
          isTrue);
      // Contains
      expect(
          renderer.visitCompare(
              Compare(value: Constant(value: 1), operands: [
                (CompareOperator.contains, Constant(value: [1, 2]))
              ]),
              context),
          isTrue);
      // Not Contains
      expect(
          renderer.visitCompare(
              Compare(value: Constant(value: 3), operands: [
                (CompareOperator.notContains, Constant(value: [1, 2]))
              ]),
              context),
          isTrue);

      // Chain
      expect(
        renderer.visitCompare(
          Compare(
            value: Constant(value: 1),
            operands: [
              (CompareOperator.lessThan, Constant(value: 2)),
              (CompareOperator.lessThan, Constant(value: 3)),
            ],
          ),
          context,
        ),
        isTrue,
      );

      // Fail chain
      expect(
        renderer.visitCompare(
          Compare(
            value: Constant(value: 1),
            operands: [
              (CompareOperator.lessThan, Constant(value: 2)),
              (CompareOperator.greaterThan, Constant(value: 3)),
            ],
          ),
          context,
        ),
        isFalse,
      );
    });

    test('visitLogical and/or with short-circuiting', () {
      final context = StringSinkRenderContext(env, StringBuffer());

      // OR short-circuit
      expect(renderer.visitLogical(Logical(operator: LogicalOperator.or, left: Constant(value: true), right: Constant(value: false)), context),
          isTrue);
      // OR both
      expect(renderer.visitLogical(Logical(operator: LogicalOperator.or, left: Constant(value: false), right: Constant(value: true)), context),
          isTrue);

      // AND short-circuit
      expect(renderer.visitLogical(Logical(operator: LogicalOperator.and, left: Constant(value: false), right: Constant(value: true)), context),
          isFalse);
      // AND both
      expect(renderer.visitLogical(Logical(operator: LogicalOperator.and, left: Constant(value: true), right: Constant(value: true)), context),
          isTrue);
    });

    test('visitScalar all operators', () {
      final context = StringSinkRenderContext(env, StringBuffer());

      expect(
          renderer.visitScalar(Scalar(operator: ScalarOperator.plus, left: Constant(value: 1), right: Constant(value: 2)), context), equals(3));
      expect(
          renderer.visitScalar(Scalar(operator: ScalarOperator.minus, left: Constant(value: 3), right: Constant(value: 1)), context), equals(2));
      expect(renderer.visitScalar(Scalar(operator: ScalarOperator.multiple, left: Constant(value: 2), right: Constant(value: 3)), context),
          equals(6));
      expect(renderer.visitScalar(Scalar(operator: ScalarOperator.division, left: Constant(value: 6), right: Constant(value: 2)), context),
          equals(3.0));
      expect(renderer.visitScalar(Scalar(operator: ScalarOperator.floorDivision, left: Constant(value: 7), right: Constant(value: 2)), context),
          equals(3));
      expect(renderer.visitScalar(Scalar(operator: ScalarOperator.module, left: Constant(value: 7), right: Constant(value: 3)), context),
          equals(1));
      expect(
          renderer.visitScalar(Scalar(operator: ScalarOperator.power, left: Constant(value: 2), right: Constant(value: 3)), context), equals(8));
    });

    test('visitUnary all operators', () {
      final context = StringSinkRenderContext(env, StringBuffer());

      expect(renderer.visitUnary(Unary(operator: UnaryOperator.plus, value: Constant(value: 1)), context), equals(1));
      expect(renderer.visitUnary(Unary(operator: UnaryOperator.minus, value: Constant(value: 1)), context), equals(-1));
      expect(renderer.visitUnary(Unary(operator: UnaryOperator.not, value: Constant(value: false)), context), isTrue);
    });

    test('visitAssignBlock with filters', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);

      // With filter
      final nodeWithFilter = AssignBlock(
        target: Name(name: 'x', context: AssignContext.store),
        filters: [Filter(name: 'upper', calling: Calling(arguments: [], keywords: []))],
        body: Data(data: 'abc'),
      );
      renderer.visitAssignBlock(nodeWithFilter, context);
      expect(context.context['x'], equals('ABC'));

      // Without filters
      final nodeWithoutFilter = AssignBlock(
        target: Name(name: 'y', context: AssignContext.store),
        filters: [],
        body: Data(data: 'def'),
      );
      renderer.visitAssignBlock(nodeWithoutFilter, context);
      expect(context.context['y'], equals('def'));
    });

    test('visitAutoEscape', () {
      final sink = StringBuffer();
      final envWithEscape = Environment(autoEscape: true);
      final context = StringSinkRenderContext(envWithEscape, sink);

      final node = AutoEscape(
        enable: false,
        body: Interpolation(value: Constant(value: '<b>')),
      );
      renderer.visitAutoEscape(node, context);
      expect(sink.toString(), equals('<b>')); // Not escaped because autoEscape was disabled by block
    });

    test('visitDebug', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink, data: {'a': 1, 'b': 2});

      renderer.visitDebug(Debug(), context);
      expect(sink.toString(), contains('Context:'));
      expect(sink.toString(), contains('a: 1'));
      expect(sink.toString(), contains('b: 2'));
    });

    test('visitCondition (ternary)', () {
      final context = StringSinkRenderContext(env, StringBuffer());

      // True case
      final nodeTrue = Condition(test: Constant(value: true), trueValue: Constant(value: 'yes'), falseValue: Constant(value: 'no'));
      expect(renderer.visitCondition(nodeTrue, context), equals('yes'));

      // False case
      final nodeFalse = Condition(test: Constant(value: false), trueValue: Constant(value: 'yes'), falseValue: Constant(value: 'no'));
      expect(renderer.visitCondition(nodeFalse, context), equals('no'));

      // False case without falseValue
      final nodeNoFalse = Condition(test: Constant(value: false), trueValue: Constant(value: 'yes'));
      expect(renderer.visitCondition(nodeNoFalse, context), isNull);
    });

    test('visitInclude ignoreMissing', () {
      final sink = StringBuffer();
      final envMissing = Environment(loader: MapLoader({}, globalJinjaData: {}));
      final context = StringSinkRenderContext(envMissing, sink);

      final node = Include(template: Constant(value: 'missing.html'), ignoreMissing: true);
      expect(() => renderer.visitInclude(node, context), returnsNormally);

      final nodeFatal = Include(template: Constant(value: 'missing.html'));
      expect(() => renderer.visitInclude(nodeFatal, context), throwsA(isA<TemplateNotFound>()));
    });
  });
}
