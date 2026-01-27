import '../nodes.dart';
import '../renderer.dart';
import '../visitor.dart';

class ExpressionEvaluator extends Visitor<StringSinkRenderContext, Object?> {
  const ExpressionEvaluator();

  @override
  Object? visitConstant(Constant node, StringSinkRenderContext context) {
    return node.value;
  }

  @override
  Object? visitName(Name node, StringSinkRenderContext context) {
    return context.resolve(node.name);
  }

  @override
  Object? visitAttribute(Attribute node, StringSinkRenderContext context) {
    var value = node.value.accept(this, context);
    return context.attribute(node.attribute, value, node);
  }

  @override
  Object? visitItem(Item node, StringSinkRenderContext context) {
    var key = node.key.accept(this, context);
    var value = node.value.accept(this, context);
    return context.item(key, value, node);
  }

  @override
  bool visitCompare(Compare node, StringSinkRenderContext context) {
    var left = node.value.accept(this, context);
    for (var (operator, value) in node.operands) {
      var right = value.accept(this, context);
      var result = switch (operator) {
        CompareOperator.equal => left == right,
        CompareOperator.notEqual => left != right,
        CompareOperator.lessThan => (left as Comparable).compareTo(right) < 0,
        CompareOperator.lessThanOrEqual => (left as Comparable).compareTo(right) <= 0,
        CompareOperator.greaterThan => (left as Comparable).compareTo(right) > 0,
        CompareOperator.greaterThanOrEqual => (left as Comparable).compareTo(right) >= 0,
        CompareOperator.contains => (right as Iterable).contains(left),
        CompareOperator.notContains => !(right as Iterable).contains(left),
      };
      if (!result) {
        return false;
      }
      left = right;
    }
    return true;
  }

  @override
  void visitAssign(Assign node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate assignments in a breakpoint condition.');
  }

  @override
  void visitAssignBlock(AssignBlock node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate assignments in a breakpoint condition.');
  }

  @override
  void visitAutoEscape(AutoEscape node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate autoescape blocks in a breakpoint condition.');
  }

  @override
  void visitBlock(Block node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate blocks in a breakpoint condition.');
  }

  @override
  void visitBreak(Break node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate break statements in a breakpoint condition.');
  }

  @override
  void visitCallBlock(CallBlock node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate call blocks in a breakpoint condition.');
  }

  @override
  void visitContinue(Continue node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate continue statements in a breakpoint condition.');
  }

  @override
  void visitData(Data node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate data nodes in a breakpoint condition.');
  }

  @override
  void visitDebug(Debug node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate debug statements in a breakpoint condition.');
  }

  @override
  void visitDo(Do node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate do statements in a breakpoint condition.');
  }

  @override
  void visitExtends(Extends node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate extends statements in a breakpoint condition.');
  }

  @override
  void visitFilterBlock(FilterBlock node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate filter blocks in a breakpoint condition.');
  }

  @override
  void visitFor(For node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate for loops in a breakpoint condition.');
  }

  @override
  void visitFromImport(FromImport node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate imports in a breakpoint condition.');
  }

  @override
  void visitIf(If node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate if statements in a breakpoint condition.');
  }

  @override
  void visitImport(Import node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate imports in a breakpoint condition.');
  }

  @override
  void visitInclude(Include node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate includes in a breakpoint condition.');
  }

  @override
  void visitInterpolation(Interpolation node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate interpolations in a breakpoint condition.');
  }

  @override
  void visitMacro(Macro node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate macros in a breakpoint condition.');
  }

  @override
  void visitOutput(Output node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate outputs in a breakpoint condition.');
  }

  @override
  void visitTemplateNode(TemplateNode node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate template nodes in a breakpoint condition.');
  }

  @override
  void visitTrans(Trans node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate trans blocks in a breakpoint condition.');
  }

  @override
  void visitTryCatch(TryCatch node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate try/catch blocks in a breakpoint condition.');
  }

  @override
  void visitWith(With node, StringSinkRenderContext context) {
    throw UnsupportedError('Cannot evaluate with statements in a breakpoint condition.');
  }

  @override
  Object? visitArray(Array node, StringSinkRenderContext context) {
    throw UnimplementedError();
  }

  @override
  Object? visitCall(Call node, StringSinkRenderContext context) {
    throw UnimplementedError();
  }

  @override
  Object? visitCalling(Calling node, StringSinkRenderContext context) {
    throw UnimplementedError();
  }

  @override
  Object? visitConcat(Concat node, StringSinkRenderContext context) {
    throw UnimplementedError();
  }

  @override
  Object? visitCondition(Condition node, StringSinkRenderContext context) {
    throw UnimplementedError();
  }

  @override
  Object? visitDict(Dict node, StringSinkRenderContext context) {
    throw UnimplementedError();
  }

  @override
  Object? visitFilter(Filter node, StringSinkRenderContext context) {
    throw UnimplementedError();
  }

  @override
  Object? visitLogical(Logical node, StringSinkRenderContext context) {
    throw UnimplementedError();
  }

  @override
  Object? visitNamespaceRef(NamespaceRef node, StringSinkRenderContext context) {
    throw UnimplementedError();
  }

  @override
  Object? visitScalar(Scalar node, StringSinkRenderContext context) {
    throw UnimplementedError();
  }

  @override
  Object? visitSlice(Slice node, StringSinkRenderContext context) {
    throw UnimplementedError();
  }

  @override
  Object? visitTest(Test node, StringSinkRenderContext context) {
    throw UnimplementedError();
  }

  @override
  Object? visitTuple(Tuple node, StringSinkRenderContext context) {
    throw UnimplementedError();
  }

  @override
  Object? visitUnary(Unary node, StringSinkRenderContext context) {
    throw UnimplementedError();
  }
}
