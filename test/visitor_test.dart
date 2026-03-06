@TestOn('vm || chrome')
library;

import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/visitor.dart';
import 'package:test/test.dart';

void main() {
  const visitor = ThrowingVisitor<void, void>();

  group('ThrowingVisitor', () {
    test('all methods throw UnimplementedError', () {
      expect(() => visitor.visitArray(const Array(values: []), null),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitAttribute(
              const Attribute(value: Name(name: 'a'), attribute: 'b'), null,),
          throwsUnimplementedError,);
      expect(() => visitor.visitCall(const Call(value: Name(name: 'f')), null),
          throwsUnimplementedError,);
      expect(() => visitor.visitCalling(const Calling(), null),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitCompare(
              const Compare(value: Constant(value: 1)), null,),
          throwsUnimplementedError,);
      expect(() => visitor.visitConcat(const Concat(values: []), null),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitCondition(
              const Condition(
                  test: Constant(value: true), trueValue: Constant(value: 1),),
              null,),
          throwsUnimplementedError,);
      expect(() => visitor.visitConstant(const Constant(value: 1), null),
          throwsUnimplementedError,);
      expect(() => visitor.visitDict(const Dict(pairs: []), null),
          throwsUnimplementedError,);
      expect(() => visitor.visitFilter(const Filter(name: 'f'), null),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitItem(
              const Item(value: Name(name: 'a'), key: Constant(value: 1)),
              null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitLogical(
              const Logical(
                  operator: LogicalOperator.and,
                  left: Constant(value: true),
                  right: Constant(value: true),),
              null,),
          throwsUnimplementedError,);
      expect(() => visitor.visitName(const Name(name: 'a'), null),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitNamespaceRef(
              const NamespaceRef(name: 'a', attribute: 'b'), null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitScalar(
              const Scalar(
                  operator: ScalarOperator.plus,
                  left: Constant(value: 1),
                  right: Constant(value: 1),),
              null,),
          throwsUnimplementedError,);
      expect(() => visitor.visitTest(const Test(name: 'f'), null),
          throwsUnimplementedError,);
      expect(() => visitor.visitTuple(const Tuple(values: []), null),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitUnary(
              const Unary(
                  operator: UnaryOperator.not, value: Constant(value: true),),
              null,),
          throwsUnimplementedError,);

      expect(
          () => visitor.visitAssign(
              const Assign(target: Name(name: 'a'), value: Constant(value: 1)),
              null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitAssignBlock(
              AssignBlock(target: const Name(name: 'a'), body: const Data()),
              null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitAutoEscape(
              const AutoEscape(enable: true, body: Data()), null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitBlock(
              const Block(
                  name: 'a', scoped: false, required: false, body: Data(),),
              null,),
          throwsUnimplementedError,);
      expect(() => visitor.visitBreak(const Break(), null),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitCallBlock(
              CallBlock(
                  name: 'a',
                  call: const Call(value: Name(name: 'f')),
                  body: const Data(),),
              null,),
          throwsUnimplementedError,);
      expect(() => visitor.visitContinue(const Continue(), null),
          throwsUnimplementedError,);
      expect(() => visitor.visitData(const Data(), null),
          throwsUnimplementedError,);
      expect(() => visitor.visitDebug(const Debug(), null),
          throwsUnimplementedError,);
      expect(() => visitor.visitDo(Do(value: const Constant(value: 1)), null),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitExtends(
              const Extends(template: Constant(value: '')), null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitFilterBlock(
              const FilterBlock(filters: [], body: Data()), null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitFor(
              For(
                  target: const Name(name: 'a'),
                  iterable: const Name(name: 'b'),
                  body: const Data(),),
              null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitFromImport(
              const FromImport(template: Constant(value: ''), names: []), null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitIf(
              const If(test: Constant(value: true), body: Data()), null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitImport(
              const Import(template: Constant(value: ''), target: ''), null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitInclude(
              const Include(template: Constant(value: '')), null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitInterpolation(
              const Interpolation(value: Constant(value: 1)), null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitMacro(Macro(name: 'a', body: const Data()), null),
          throwsUnimplementedError,);
      expect(() => visitor.visitOutput(const Output(), null),
          throwsUnimplementedError,);
      expect(
          () =>
              visitor.visitTemplateNode(TemplateNode(body: const Data()), null),
          throwsUnimplementedError,);
      expect(() => visitor.visitTrans(Trans(body: const Data()), null),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitTryCatch(
              TryCatch(body: const Data(), catchBody: const Data()), null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitWith(
              const With(targets: [], values: [], body: Data()), null,),
          throwsUnimplementedError,);
      expect(
          () => visitor.visitSlice(
              const Slice(value: Name(name: 'a'), start: Constant(value: 0)),
              null,),
          throwsUnimplementedError,);
    });
  });
}
