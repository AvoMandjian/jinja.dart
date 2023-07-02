import 'package:jinja/src/nodes.dart';

abstract class Visitor<C, R> {
  const Visitor();

  // Expressions

  R visitArray(Array node, C context);

  R visitAttribute(Attribute node, C context);

  R visitCall(Call node, C context);

  R visitCalling(Calling node, C context);

  R visitCompare(Compare node, C context);

  R visitConcat(Concat node, C context);

  R visitCondition(Condition node, C context);

  R visitConstant(Constant node, C context);

  R visitDict(Dict node, C context);

  R visitFilter(Filter node, C context);

  R visitItem(Item node, C context);

  R visitLogical(Logical node, C context);

  R visitName(Name node, C context);

  R visitNamespaceRef(NamespaceRef node, C context);

  R visitScalar(Scalar node, C context);

  R visitTest(Test node, C context);

  R visitTuple(Tuple node, C context);

  R visitUnary(Unary node, C context);

  // Statements

  R visitAssign(Assign node, C context);

  R visitAssignBlock(AssignBlock node, C context);

  R visitAutoEscape(AutoEscape node, C context);

  R visitBlock(Block node, C context);

  R visitCallBlock(CallBlock node, C context);

  R visitData(Data node, C context);

  R visitDo(Do node, C context);

  R visitExtends(Extends node, C context);

  R visitFilterBlock(FilterBlock node, C context);

  R visitFor(For node, C context);

  R visitIf(If node, C context);

  R visitInclude(Include node, C context);

  R visitInterpolation(Interpolation node, C context);

  R visitMacro(Macro node, C context);

  R visitOutput(Output node, C context);

  R visitTemplateNode(TemplateNode node, C context);

  R visitWith(With node, C context);
}

class ThrowingVisitor<C, R> implements Visitor<C, R> {
  const ThrowingVisitor();

  // Expressions

  @override
  R visitArray(Array node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitAttribute(Attribute node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitAutoEscape(AutoEscape node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitCall(Call node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitCalling(Calling node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitCompare(Compare node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitConcat(Concat node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitCondition(Condition node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitConstant(Constant node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitDict(Dict node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitFilter(Filter node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitItem(Item node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitLogical(Logical node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitName(Name node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitNamespaceRef(NamespaceRef node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitScalar(Scalar node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitTest(Test node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitTuple(Tuple node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitUnary(Unary node, C context) {
    throw UnimplementedError('$node');
  }

  // Statements

  @override
  R visitAssign(Assign node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitAssignBlock(AssignBlock node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitBlock(Block node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitCallBlock(CallBlock node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitData(Data node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitDo(Do node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitExtends(Extends node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitFilterBlock(FilterBlock node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitFor(For node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitIf(If node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitInclude(Include node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitInterpolation(Interpolation node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitMacro(Macro node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitOutput(Output node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitTemplateNode(TemplateNode node, C context) {
    throw UnimplementedError('$node');
  }

  @override
  R visitWith(With node, C context) {
    throw UnimplementedError('$node');
  }
}
