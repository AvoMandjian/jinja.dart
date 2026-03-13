@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:jinja/src/utils.dart' as utils;
import 'package:test/test.dart';

void main() {
  group('Renderer 90% path coverage', () {
    final env = Environment();

    test('visitTrans direct', () {
      final renderer = StringSinkRenderer();
      final context = StringSinkRenderContext(env, StringBuffer());
      renderer.visitTrans(Trans(body: Data(data: 'a')), context);
      expect(context.sink.toString(), equals('a'));
    });

    test('StringSinkRenderContext coverage', () {
      final ctx = StringSinkRenderContext(env, StringBuffer(), parent: {'a': 1});
      final derived = ctx.derived(withContext: false);
      expect(derived.parent, containsPair('a', 1));

      final derived2 = ctx.derived();
      expect(derived2.parent, containsPair('a', 1));
    });

    test('visitAssign direct error', () {
      final renderer = StringSinkRenderer();
      final context = StringSinkRenderContext(env, StringBuffer());
      // visitAssign calls context.assignTargets. We can make target an unsupported Node.
      expect(() => renderer.visitAssign(Assign(target: Constant(value: 1), value: Constant(value: 2)), context),
          throwsA(isA<TemplateRuntimeError>()));
    });

    test('visitTryCatch with exception caught', () {
      final renderer = StringSinkRenderer();
      final context = StringSinkRenderContext(env, StringBuffer());

      final throwNode = TryCatch(
        body: Extends(template: Constant(value: 1)), // Will throw
        catchBody: Data(data: 'caught'),
      );

      renderer.visitTryCatch(throwNode, context);
      expect(context.sink.toString(), equals('caught'));
    });

    test('visitTryCatch without exception caught', () {
      final renderer = StringSinkRenderer();
      final context = StringSinkRenderContext(env, StringBuffer());

      final successNode = TryCatch(
        body: Data(data: 'body'),
        exception: Name(name: 'err'),
        catchBody: Data(data: 'caught'),
      );

      renderer.visitTryCatch(successNode, context);
      expect(context.sink.toString(), equals('body'));
    });

    test('visitInterpolation with Future and autoescape', () async {
      final envAuto = Environment(autoEscape: true);
      final t = envAuto.fromString('{{ val }}');
      final out = await t.renderAsync({'val': Future.value('<b>')});
      expect(out, equals('&lt;b&gt;'));
    });

    test('visitInterpolation with Future and SafeString', () async {
      final t = env.fromString('{{ val }}');
      final out = await t.renderAsync({'val': Future.value(utils.SafeString('<br>'))});
      expect(out, equals('<br>'));
    });

    test('visitAssign with Future', () async {
      final t = env.fromString('{% set x = f %}{{ x }}');
      final out = await t.renderAsync({'f': Future.value(42)});
      expect(out, equals('42'));
    });

    test('visitAssign with failing Future', () async {
      final t = env.fromString('{% set x = f %}{{ x }}');
      await expectLater(
        () => t.renderAsync({'f': Future.error(Exception('fail'))}),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });
  });
}
