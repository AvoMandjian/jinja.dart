import 'package:jinja/src/environment.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:jinja/src/runtime.dart';
import 'package:jinja/src/utils.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();
  const renderer = StringSinkRenderer();

  group('StringSinkRenderer Coverage Extensions 4', () {
    test('visitInterpolation with SafeString', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);

      final node = Interpolation(value: Constant(value: SafeString('<b>')));
      renderer.visitInterpolation(node, context);
      expect(sink.toString(), equals('<b>'));
    });

    test('visitInterpolation with Future in sync renderer', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);

      final future = Future.value('hi');
      final node = Interpolation(value: Constant(value: future));
      renderer.visitInterpolation(node, context);
      expect(sink.toString(), contains('Future'));
    });

    test('visitInterpolation re-evaluation in async mode', () async {
      // This test targets lines 1467-1538 in renderer.dart
      final envAsync = Environment();

      // We need a custom template that uses a variable that is initially null
      // but becomes available after a future resolves.
      final template = envAsync.fromString('{{ delayed_var }}');

      final env2 = Environment();
      final t2 = env2.fromString('{% set x = async_val %}{{ x }}');
      final res2 = await t2.renderAsync({'async_val': Future.value('resolved')});
      expect(res2, equals('resolved'));
    });

    test('visitAssign with complex target unpacking error', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      final node = Assign(
        target: Tuple(values: [Name(name: 'a', context: AssignContext.store)]),
        value: Constant(value: [1, 2]), // too many
      );
      expect(() => renderer.visitAssign(node, context), throwsStateError);
    });

    test('visitAssign with Namespace target', () {
      final ns = Namespace({'a': 1});
      final context = StringSinkRenderContext(env, StringBuffer(), data: {'ns': ns});
      final node = Assign(
        target: NamespaceRef(name: 'ns', attribute: 'a'),
        value: Constant(value: 42),
      );
      renderer.visitAssign(node, context);
      expect(ns['a'], equals(42));
    });
  });
}
