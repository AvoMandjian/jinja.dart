@TestOn('vm || chrome')
library;

import 'dart:async';
import 'package:jinja/src/environment.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:jinja/src/runtime.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();

  group('RenderContext', () {
    test('assignTargets list unpacking error (too few)', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      expect(() => context.assignTargets(['a', 'b'], [1]), throwsStateError);
    });

    test('assignTargets list unpacking error (too many)', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      expect(() => context.assignTargets(['a'], [1, 2]), throwsStateError);
    });

    test('assignTargets Namespace error', () {
      final context = StringSinkRenderContext(env, StringBuffer(), data: {'ns': 42});
      final nsValue = NamespaceValue('ns', 'item');
      expect(() => context.assignTargets(nsValue, 10), throwsA(isA<TemplateRuntimeError>().having((e) => e.message, 'message', contains('Non-namespace object'))));
    });

    test('assignTargets Invalid target', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      expect(() => context.assignTargets(42, 1), throwsA(isA<TemplateRuntimeError>().having((e) => e.message, 'message', contains('Invalid target'))));
    });

    test('AsyncRenderContext derived', () {
      final context = AsyncRenderContext(env, StringBuffer(), data: {'a': 1});
      final derived = context.derived(data: {'b': 2});
      expect(derived.context['b'], equals(2));
      expect(derived.parent['a'], equals(1));
    });

    test('assignTargets NamespaceValue', () {
      final ns = Namespace({'a': 1});
      final context = StringSinkRenderContext(env, StringBuffer(), data: {'ns': ns});
      final nsValue = NamespaceValue('ns', 'a');
      context.assignTargets(nsValue, 42);
      expect(ns['a'], equals(42));
    });

    test('assignTargets List unpacking', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      context.assignTargets(['a', 'b'], [1, 2]);
      expect(context.context['a'], equals(1));
      expect(context.context['b'], equals(2));
    });
  });

  group('StringSinkRenderer', () {
    const renderer = StringSinkRenderer();

    test('visitArray', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      const node = Array(values: [Constant(value: 1), Constant(value: 2)]);
      final result = renderer.visitArray(node, context);
      expect(result, equals([1, 2]));
    });

    test('visitDict', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      const node = Dict(pairs: [(key: Constant(value: 'a'), value: Constant(value: 1))]);
      final result = renderer.visitDict(node, context);
      expect(result, equals({'a': 1}));
    });

    test('visitConcat', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      const node = Concat(values: [Constant(value: 'a'), Constant(value: 'b')]);
      final result = renderer.visitConcat(node, context);
      expect(result, equals('ab'));
    });

    test('visitCompare', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      const node = Compare(value: Constant(value: 1), operands: [(CompareOperator.equal, Constant(value: 1))]);
      final result = renderer.visitCompare(node, context);
      expect(result, isTrue);
    });

    test('visitCondition', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      const node = Condition(test: Constant(value: true), trueValue: Constant(value: 1), falseValue: Constant(value: 2));
      final result = renderer.visitCondition(node, context);
      expect(result, equals(1));
    });

    test('visitLogical', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      const node = Logical(operator: LogicalOperator.and, left: Constant(value: true), right: Constant(value: false));
      final result = renderer.visitLogical(node, context);
      expect(result, isFalse);
    });

    test('visitUnary', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      const node = Unary(operator: UnaryOperator.not, value: Constant(value: true));
      final result = renderer.visitUnary(node, context);
      expect(result, isFalse);
    });

    group('getDataForTargets', () {
      test('single target', () {
        expect(renderer.getDataForTargets('a', 1), equals({'a': 1}));
      });

      test('multiple targets', () {
        expect(renderer.getDataForTargets(['a', 'b'], [1, 2]), equals({'a': 1, 'b': 2}));
      });

      test('too few values', () {
        expect(() => renderer.getDataForTargets(['a', 'b'], [1]), throwsA(isA<TemplateRuntimeError>().having((e) => e.message, 'message', contains('Not enough values to unpack'))));
      });

      test('too many values', () {
        expect(() => renderer.getDataForTargets(['a'], [1, 2]), throwsA(isA<TemplateRuntimeError>().having((e) => e.message, 'message', contains('Too many values to unpack'))));
      });

      test('invalid target type', () {
        expect(() => renderer.getDataForTargets(42, 1), throwsA(isA<TemplateRuntimeError>().having((e) => e.message, 'message', contains('Invalid target type'))));
      });
    });
  });

  group('AsyncRenderer', () {
    test('render with async global error', () async {
      final env = Environment(globals: {'async_err': Future<int>.delayed(Duration.zero, () => throw Exception('async error'))});
      final renderer = AsyncRenderer();
      final context = AsyncRenderContext(env, StringBuffer(), parent: env.globals);
      final node = TemplateNode(body: const Data(data: 'foo'));
      expect(renderer.render(node, context), throwsA(isA<TemplateErrorWrapper>()));
    });

    test('render with async variable error', () async {
      final env = Environment();
      final renderer = AsyncRenderer();
      final context = AsyncRenderContext(env, StringBuffer(), data: {'async_var': Future<int>.delayed(Duration.zero, () => throw Exception('var error'))});
      final node = TemplateNode(body: const Data(data: 'foo'));
      expect(renderer.render(node, context), throwsA(isA<TemplateErrorWrapper>()));
    });

    test('collecting sink methods', () async {
      final env = Environment();
      // Using |join filter to potentially trigger writeAll if implemented that way
      final template = env.fromString('{% for i in [1, 2] %}{{ i }}{% endfor %}');
      final result = await template.renderAsync();
      expect(result, equals('12'));
    });

    test('visitAssign with Future', () async {
      final env = Environment();
      final template = env.fromString('{% set x = async_val %}{{ x }}');
      final result = await template.renderAsync({'async_val': Future.value('foo')});
      expect(result, equals('foo'));
    });

    test('visitName error wrapping', () {
      final env = Environment(undefined: (name, [tmpl]) => throw Exception('custom error'));
      final renderer = StringSinkRenderer();
      final context = StringSinkRenderContext(env, StringBuffer());
      final node = Name(name: 'missing');

      try {
        renderer.visitName(node, context);
        fail('Should have thrown TemplateErrorWrapper');
      } catch (e) {
        expect(e, isA<TemplateErrorWrapper>());
        expect(e.toString(), contains('custom error'));
      }
    });

    test('visitName rethrows TemplateError', () {
      final env = Environment(undefined: (name, [tmpl]) => throw UndefinedError('rethrow me'));
      final renderer = StringSinkRenderer();
      final context = StringSinkRenderContext(env, StringBuffer());
      final node = Name(name: 'missing');

      try {
        renderer.visitName(node, context);
        fail('Should have thrown UndefinedError');
      } catch (e) {
        expect(e, isA<UndefinedError>());
        expect(e.toString(), contains('rethrow me'));
      }
    });

    test('AsyncRenderer Future error in template', () async {
      final env = Environment();
      // Create a template that uses a Future that throws
      final template = env.fromString('{{ async_error }}');
      expect(template.renderAsync({'async_error': Future.error('error')}), throwsA(isA<TemplateErrorWrapper>()));
    });
  });
}
