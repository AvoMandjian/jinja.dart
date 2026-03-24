import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/async_debug_renderer.dart';
import 'package:jinja/src/debug/debug_renderer.dart';
import 'package:jinja/src/nodes.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncDebugRenderer direct coverage', () {
    final env = Environment(
      loader: MapLoader(
        {
          'a': 'A',
        },
        globalJinjaData: {},
      ),
    );

    test('covers Expression nodes', () async {
      final controller = DebugController()..enabled = true;
      controller.addBreakpoint(line: 1);
      final renderer = AsyncDebugRenderer();
      final context =
          DebugRenderContext(env, StringBuffer(), debugController: controller);

      try {
        await renderer.visitArray(Array(values: [Constant(value: 1)]), context);
      } catch (_) {}
      try {
        await renderer.visitAttribute(
            Attribute(value: Name(name: 'x'), attribute: 'y'), context);
      } catch (_) {}
      try {
        await renderer.visitCall(Call(value: Name(name: 'f')), context);
      } catch (_) {}
      try {
        await renderer.visitCalling(
            Calling(
                arguments: [Constant(value: 1)],
                keywords: [(key: 'k', value: Constant(value: 1))]),
            context);
      } catch (_) {}
      try {
        await renderer.visitCompare(
            Compare(
                value: Constant(value: 1),
                operands: [(CompareOperator.equal, Constant(value: 1))]),
            context);
      } catch (_) {}
      try {
        await renderer.visitConcat(
            Concat(values: [Constant(value: 1)]), context);
      } catch (_) {}
      try {
        await renderer.visitCondition(
          Condition(
              test: Constant(value: false),
              trueValue: Constant(value: 1),
              falseValue: Constant(value: 0)),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitCondition(
            Condition(
                test: Constant(value: false), trueValue: Constant(value: 1)),
            context);
      } catch (_) {}
      try {
        await renderer.visitDict(
            Dict(pairs: [(key: Constant(value: 1), value: Constant(value: 1))]),
            context);
      } catch (_) {}
      try {
        await renderer.visitFilter(Filter(name: 'f'), context);
      } catch (_) {}
      try {
        await renderer.visitItem(
            Item(value: Name(name: 'x'), key: Constant(value: 1)), context);
      } catch (_) {}
      try {
        await renderer.visitLogical(
            Logical(
                operator: LogicalOperator.and,
                left: Constant(value: true),
                right: Constant(value: true)),
            context);
      } catch (_) {}
      try {
        await renderer.visitName(Name(name: 'x'), context);
      } catch (_) {}
      try {
        await renderer.visitNamespaceRef(
            NamespaceRef(name: 'x', attribute: 'y'), context);
      } catch (_) {}

      try {
        await renderer.visitScalar(
            Scalar(
                operator: ScalarOperator.plus,
                left: Constant(value: 1),
                right: Constant(value: 1)),
            context);
      } catch (_) {}
      try {
        await renderer.visitTest(Test(name: 't'), context);
      } catch (_) {}
      try {
        await renderer.visitTuple(Tuple(values: [Constant(value: 1)]), context);
      } catch (_) {}
      try {
        await renderer.visitUnary(
            Unary(operator: UnaryOperator.not, value: Constant(value: true)),
            context);
      } catch (_) {}
    });

    test('covers Statement nodes', () async {
      final controller = DebugController()..enabled = true;
      controller.addBreakpoint(line: 1);
      final renderer = AsyncDebugRenderer();
      final context = DebugRenderContext(
        env,
        StringBuffer(),
        debugController: controller,
      );

      try {
        await renderer.visitAssign(
          Assign(
            target: Tuple(values: []),
            value: Constant(value: 1),
            line: 1,
          ),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitDo(
          Do(value: Call(value: Name(name: 'f'))),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitBlock(
          Block(
            name: 'b',
            scoped: false,
            required: false,
            body: TemplateNode(body: Data()),
          ),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitFilterBlock(
          FilterBlock(
            filters: [Filter(name: 'f')],
            body: TemplateNode(body: Data()),
          ),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitFor(
          For(
            target: Name(name: 'x'),
            iterable: Array(values: []),
            body: TemplateNode(body: Data()),
          ),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitIf(
          If(
            test: Constant(value: true),
            body: TemplateNode(body: Data()),
          ),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitInclude(
          Include(template: Constant(value: 'a')),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitInterpolation(
          Interpolation(value: Constant(value: 1)),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitMacro(
          Macro(name: 'm', body: TemplateNode(body: Data())),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitOutput(
          Output(nodes: [Constant(value: 1)]),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitTemplateNode(
          TemplateNode(body: Data()),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitTrans(
          Trans(body: Data()),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitWith(
          With(
            targets: [Name(name: 'x')],
            values: [Constant(value: 1)],
            body: TemplateNode(body: Data()),
          ),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitExtends(
          Extends(template: Constant(value: 'a')),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitFromImport(
          FromImport(
            template: Constant(value: 'a'),
            names: [('a', 'b')],
          ),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitImport(
          Import(template: Constant(value: 'a'), target: 'b'),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitAssignBlock(
          AssignBlock(
            target: Name(name: 'x'),
            body: TemplateNode(body: Data()),
          ),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitAutoEscape(
          AutoEscape(
            enable: true,
            body: TemplateNode(body: const Data()),
          ),
          context,
        );
      } catch (_) {}
      try {
        await renderer.visitBreak(const Break(), context);
      } catch (_) {}
      try {
        await renderer.visitContinue(const Continue(), context);
      } catch (_) {}
      try {
        await renderer.visitDebug(const Debug(), context);
      } catch (_) {}
    });

    test('_checkBreakpoint logic', () async {
      final controller = DebugController()..enabled = true;
      // condition handles template render
      controller.addBreakpoint(line: 1, condition: 'true');
      // condition syntax error
      controller.addBreakpoint(line: 2, condition: '{% invalid %}');
      // condition false
      controller.addBreakpoint(line: 3, condition: 'false');
      // condition null
      controller.addBreakpoint(line: 4);

      final renderer = AsyncDebugRenderer();
      final context =
          DebugRenderContext(env, StringBuffer(), debugController: controller);

      await renderer.visitData(Data(data: 'd', line: 1), context);
      await renderer.visitData(Data(data: 'd', line: 2), context);
      await renderer.visitData(Data(data: 'd', line: 3), context);
      await renderer.visitData(Data(data: 'd', line: 4), context);

      expect(controller.history.length, equals(2)); // hit line 1 and 4
    });
  });
}
