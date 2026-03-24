import 'package:jinja/src/environment.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();
  const renderer = StringSinkRenderer();

  group('StringSinkRenderer Coverage Extensions 2', () {
    group('visitTrans', () {
      test('singular with gettext', () {
        final sink = StringBuffer();
        final context = StringSinkRenderContext(
          env,
          sink,
          data: {
            'gettext': (msg) => 'TR: $msg',
          },
        );

        final node = Trans(body: Data(data: 'Hello'));
        renderer.visitTrans(node, context);
        expect(sink.toString(), equals('TR: Hello'));
      });

      test('singular with context (pgettext)', () {
        final sink = StringBuffer();
        final context = StringSinkRenderContext(
          env,
          sink,
          data: {
            'pgettext': (ctx, msg) => '[$ctx] $msg',
          },
        );

        final node = Trans(body: Data(data: 'Hello'), context: 'ui');
        renderer.visitTrans(node, context);
        expect(sink.toString(), equals('[ui] Hello'));
      });

      test('plural with ngettext', () {
        final sink = StringBuffer();
        final context = StringSinkRenderContext(
          env,
          sink,
          data: {
            'ngettext': (s, p, c) => c == 1 ? s : p,
          },
        );

        // Count 1
        final node1 = Trans(
            body: Data(data: 'one'),
            plural: Data(data: 'many'),
            count: Constant(value: 1));
        renderer.visitTrans(node1, context);
        expect(sink.toString(), equals('one'));

        // Count 2
        sink.clear();
        final node2 = Trans(
            body: Data(data: 'one'),
            plural: Data(data: 'many'),
            count: Constant(value: 2));
        renderer.visitTrans(node2, context);
        expect(sink.toString(), equals('many'));
      });

      test('plural with context (npgettext)', () {
        final sink = StringBuffer();
        final context = StringSinkRenderContext(
          env,
          sink,
          data: {
            'npgettext': (ctx, s, p, c) => '($ctx) ${c == 1 ? s : p}',
          },
        );

        final node = Trans(
            body: Data(data: 'one'),
            plural: Data(data: 'many'),
            count: Constant(value: 2),
            context: 'shop');
        renderer.visitTrans(node, context);
        expect(sink.toString(), equals('(shop) many'));
      });

      test('trimming', () {
        final sink = StringBuffer();
        final context = StringSinkRenderContext(env, sink);

        final node =
            Trans(body: Data(data: '  Hello  \n  World  '), trimmed: true);
        renderer.visitTrans(node, context);
        expect(sink.toString(), equals('Hello World'));
      });
    });

    test('visitTryCatch', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);

      // Catch and store exception
      final node = TryCatch(
        body: Call(value: Name(name: 'fail')),
        exception: Name(name: 'err', context: AssignContext.store),
        catchBody: Interpolation(value: Name(name: 'err')),
      );

      final envFail =
          Environment(globals: {'fail': () => throw Exception('failed')});
      final contextFail =
          StringSinkRenderContext(envFail, sink, parent: envFail.globals);

      renderer.visitTryCatch(node, contextFail);
      expect(sink.toString(), contains('failed'));
    });

    test('visitSlice String python semantics', () {
      final context = StringSinkRenderContext(env, StringBuffer());

      // Basic
      expect(
          renderer.visitSlice(
              Slice(
                  value: Constant(value: 'abcde'),
                  start: Constant(value: 1),
                  stop: Constant(value: 3)),
              context),
          equals('bc'));
      // Negative start
      expect(
          renderer.visitSlice(
              Slice(
                  value: Constant(value: 'abcde'), start: Constant(value: -2)),
              context),
          equals('de'));
      // Out of bounds stop
      expect(
          renderer.visitSlice(
              Slice(
                  value: Constant(value: 'abcde'),
                  start: Constant(value: 0),
                  stop: Constant(value: 10)),
              context),
          equals('abcde'));
      // Stop before start
      expect(
          renderer.visitSlice(
              Slice(
                  value: Constant(value: 'abcde'),
                  start: Constant(value: 3),
                  stop: Constant(value: 1)),
              context),
          equals(''));
    });

    test('visitSlice List errors', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      final list = [1, 2, 3];

      // Out of bounds start
      expect(
          () => renderer.visitSlice(
              Slice(value: Constant(value: list), start: Constant(value: 5)),
              context),
          throwsA(isA<TemplateRuntimeError>()));
      // Invalid index combination
      expect(
          () => renderer.visitSlice(
              Slice(
                  value: Constant(value: list),
                  start: Constant(value: 2),
                  stop: Constant(value: 1)),
              context),
          throwsA(isA<TemplateRuntimeError>()));
      // Not a list or string
      expect(
          () => renderer.visitSlice(
              Slice(value: Constant(value: 42), start: Constant(value: 0)),
              context),
          throwsA(isA<TemplateRuntimeError>()));
    });

    test('visitWith', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);

      final node = With(
        targets: [
          Name(name: 'a', context: AssignContext.store),
          Name(name: 'b', context: AssignContext.store)
        ],
        values: [Constant(value: 1), Constant(value: 2)],
        body: Interpolation(
            value: Scalar(
                operator: ScalarOperator.plus,
                left: Name(name: 'a'),
                right: Name(name: 'b'))),
      );

      renderer.visitWith(node, context);
      expect(sink.toString(), equals('3'));
    });
  });
}
