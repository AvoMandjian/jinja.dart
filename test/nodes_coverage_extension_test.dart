import 'package:jinja/src/nodes.dart';
import 'package:test/test.dart';

void main() {
  group('Nodes toJson and toSource coverage', () {
    test('Expression nodes', () {
      final nodes = [
        const Name(name: 'x'),
        const Constant(value: 42),
        const Tuple(values: [Constant(value: 1)]),
        const Array(values: [Constant(value: 1)]),
        const Dict(pairs: [(key: Constant(value: 'a'), value: Constant(value: 1))]),
        const Condition(test: Constant(value: true), trueValue: Constant(value: 1), falseValue: Constant(value: 0)),
        const Calling(arguments: [Constant(value: 1)], keywords: [(key: 'k', value: Constant(value: 1))]),
        const Call(value: Name(name: 'f')),
        const Filter(name: 'upper'),
        const Test(name: 'defined'),
        const Item(value: Name(name: 'a'), key: Constant(value: 0)),
        const Attribute(value: Name(name: 'a'), attribute: 'b'),
        const Concat(values: [Constant(value: 'a'), Constant(value: 'b')]),
        const Compare(value: Constant(value: 1), operands: [(CompareOperator.equal, Constant(value: 1))]),
        const Unary(operator: UnaryOperator.not, value: Constant(value: true)),
        const Scalar(operator: ScalarOperator.plus, left: Constant(value: 1), right: Constant(value: 2)),
        const Logical(operator: LogicalOperator.and, left: Constant(value: true), right: Constant(value: true)),
      ];

      for (var node in nodes) {
        expect(node.toJson(), isA<Map<String, Object?>>());
        expect(node.toSource(), isA<String>());
        // copyWith check
        final copy = node.copyWith();
        expect(copy.runtimeType, equals(node.runtimeType));
      }
    });

    test('Statement nodes', () {
      final nodes = [
        const Extends(template: Constant(value: 'base.html')),
        For(target: const Name(name: 'i', context: AssignContext.store), iterable: const Constant(value: []), body: const Data()),
        If(test: const Constant(value: true), body: const Data(), orElse: const Data()),
        const Macro(name: 'm', body: Data()),
        CallBlock(call: const Call(value: Name(name: 'f')), body: const Data(), name: 'caller'),
        FilterBlock(filters: [], body: const Data()),
        With(targets: [], values: [], body: const Data()),
        const Block(name: 'b', scoped: false, required: false, body: Data()),
        Include(template: const Constant(value: 'i.html')),
        const Import(template: Constant(value: 'm.html'), target: 'm'),
        const FromImport(template: Constant(value: 'm.html'), names: [('a', 'b')]),
        Do(value: const Constant(value: 1)),
        TryCatch(body: const Data(), catchBody: const Data()),
        Assign(target: const Name(name: 'x', context: AssignContext.store), value: const Constant(value: 1)),
        const AutoEscape(enable: true, body: Data()),
        AssignBlock(target: const Name(name: 'x', context: AssignContext.store), body: const Data()),
        const Break(),
        const Continue(),
        const Debug(),
        Trans(body: const Data()),
      ];

      for (var node in nodes) {
        expect(node.toJson(), isA<Map<String, Object?>>());
        expect(node.toSource(), isA<String>());
        final copy = node.copyWith();
        expect(copy.runtimeType, equals(node.runtimeType));
      }
    });

    test('TemplateNode toJson and toSource', () {
      final node = TemplateNode(body: const Data(data: 'hi'));
      expect(node.toJson(), isA<Map<String, Object?>>());
      expect(node.toSource(), equals('hi'));
    });
  });
}
