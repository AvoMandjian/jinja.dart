import 'package:jinja/src/environment.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();
  const renderer = StringSinkRenderer();

  group('Macro Argument Binding Coverage', () {
    test('packed calling convention [args, kwargs]', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);
      final node = Macro(
        name: 'm',
        positional: [Name(name: 'x', context: AssignContext.store)],
        named: [
          (Name(name: 'y', context: AssignContext.store), Constant(value: 2))
        ],
        body: Interpolation(
            value: Scalar(
                operator: ScalarOperator.plus,
                left: Name(name: 'x'),
                right: Name(name: 'y'))),
      );

      final macro = renderer.getMacroFunction(node, context);
      // Call with packed args
      final result = macro(
        [
          [10],
          {Symbol('y'): 5},
        ],
        {},
      );
      expect(result.toString(), equals('15'));
    });

    test('missing required argument', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      final node = Macro(
        name: 'm',
        positional: [Name(name: 'req', context: AssignContext.store)],
        named: [],
        body: Data(),
      );
      final macro = renderer.getMacroFunction(node, context);
      expect(
        () => macro([], {}),
        throwsA(isA<TemplateRuntimeError>().having((e) => e.message, 'message',
            contains('Missing required macro argument "req"'))),
      );
    });

    test('default value from Name (references other keyword param)', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      final node = Macro(
        name: 'm',
        positional: [],
        named: [
          (Name(name: 'a', context: AssignContext.store), Constant(value: 1)),
          (Name(name: 'b', context: AssignContext.store), Name(name: 'a')),
        ],
        body: Interpolation(value: Name(name: 'b')),
      );
      final macro = renderer.getMacroFunction(node, context);
      // b should default to a IF a is in namedArgs
      expect(macro([], {Symbol('a'): 42}).toString(), equals('42'));
    });

    test('varargs', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      final node = Macro(
        name: 'm',
        positional: [Name(name: 'x', context: AssignContext.store)],
        varargs: true,
        named: [],
        body: Interpolation(value: Name(name: 'varargs')),
      );
      final macro = renderer.getMacroFunction(node, context);
      expect(macro([1, 2, 3], {}).toString(), equals('[2, 3]'));
    });

    test('kwargs', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      final node = Macro(
        name: 'm',
        positional: [],
        kwargs: true,
        named: [],
        body: Interpolation(value: Name(name: 'kwargs')),
      );
      final macro = renderer.getMacroFunction(node, context);
      expect(macro([], {Symbol('a'): 1, 'b': 2}).toString(),
          equals('{a: 1, b: 2}'));
    });

    test('too many positional arguments error', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      final node = Macro(
        name: 'm',
        positional: [Name(name: 'x', context: AssignContext.store)],
        named: [],
        body: Data(),
      );
      final macro = renderer.getMacroFunction(node, context);
      expect(
        () => macro([1, 2], {}),
        throwsA(isA<TemplateRuntimeError>().having((e) => e.message, 'message',
            contains('expected arguments count: 1'))),
      );
    });

    test('unexpected keyword argument error', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      final node = Macro(
        name: 'm',
        positional: [],
        named: [],
        body: Data(),
      );
      final macro = renderer.getMacroFunction(node, context);
      expect(
        () => macro([], {Symbol('extra'): 1}),
        throwsA(isA<TemplateRuntimeError>().having(
            (e) => e.message, 'message', contains('remaining.isNotEmpty'))),
      );
    });
  });
}
