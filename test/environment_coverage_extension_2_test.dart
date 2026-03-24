import 'dart:async';

import 'package:jinja/src/environment.dart';
import 'package:jinja/src/renderer.dart';
import 'package:jinja/src/runtime.dart';
import 'package:test/test.dart';

void main() {
  group('Template and Environment Coverage Extensions 2', () {
    test('Template factory without environment', () {
      final t = Template('Hello {{ name }}');
      expect(t.render({'name': 'World'}), equals('Hello World'));
    });

    test('Template.renderTo', () {
      final env = Environment();
      final t = env.fromString('hi');
      final sink = StringBuffer();
      t.renderTo(sink);
      expect(sink.toString(), equals('hi'));
    });

    test('Template.renderToAsync', () async {
      final env = Environment();
      final t = env.fromString('hi');
      final sink = StringBuffer();
      await t.renderToAsync(sink);
      expect(sink.toString(), equals('hi'));
    });

    test('Environment.wrapFinalizer with invalid function', () {
      // Pass a function with 3 arguments - wrapFinalizer doesn't handle this
      expect(() => Environment.wrapFinalizer((a, b, c) => null),
          throwsA(isA<TypeError>()));
    });

    test('AsyncRenderContext.write', () {
      final env = Environment();
      final sink = StringBuffer();
      final context = AsyncRenderContext(env, sink);
      context.write('data');
      expect(sink.toString(), equals('data'));
    });

    test('Environment.wrapFinalizer with Future result', () {
      final env = Environment();
      final context = StringSinkRenderContext(env, StringBuffer());

      // ContextFinalizer returning Future
      final wrapped =
          Environment.wrapFinalizer((Context c, Object? v) => Future.value(v));
      expect(wrapped(context, 'x'), isA<Future>());

      // EnvironmentFinalizer returning Future
      final wrapped2 = Environment.wrapFinalizer(
          (Environment e, Object? v) => Future.value(v));
      expect(wrapped2(context, 'y'), isA<Future>());

      // Finalizer returning Future
      final wrapped3 =
          Environment.wrapFinalizer((Object? v) => Future.value(v));
      expect(wrapped3(context, 'z'), isA<Future>());
    });

    test('Environment.wrapFinalizer passing Future input', () {
      final env = Environment();
      final context = StringSinkRenderContext(env, StringBuffer());
      final future = Future.value('x');

      final wrapped = Environment.wrapFinalizer((Object? v) => '[$v]');
      // If input is Future, it should pass through without calling finalizer
      expect(wrapped(context, future), equals(future));
    });
  });
}
