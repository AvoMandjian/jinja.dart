import 'package:jinja/src/environment.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/loaders.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:jinja/src/runtime.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();
  const renderer = StringSinkRenderer();

  group('StringSinkRenderer Coverage Extensions 3', () {
    test('visitFromImport with alias', () {
      final envImport = Environment(
        loader: MapLoader(
          {
            'lib.html': '{% macro m() %}hi{% endmacro %}',
          },
          globalJinjaData: {},
        ),
      );
      final sink = StringBuffer();
      final context = StringSinkRenderContext(envImport, sink);

      final node = FromImport(
        template: Constant(value: 'lib.html'),
        names: [('m', 'my_m')],
      );

      renderer.visitFromImport(node, context);
      final macro = context.resolve('my_m') as Function;
      expect(macro([], {}).toString(), equals('hi'));
    });

    test('visitFromImport without alias', () {
      final envImport = Environment(
        loader: MapLoader(
          {
            'lib.html': '{% macro m() %}hi{% endmacro %}',
          },
          globalJinjaData: {},
        ),
      );
      final sink = StringBuffer();
      final context = StringSinkRenderContext(envImport, sink);

      final node = FromImport(
        template: Constant(value: 'lib.html'),
        names: [('m', null)],
      );

      renderer.visitFromImport(node, context);
      final macro = context.resolve('m') as Function;
      expect(macro([], {}).toString(), equals('hi'));
    });

    test('visitFromImport error (missing macro)', () {
      final envImport = Environment(
        loader: MapLoader(
          {
            'lib.html': '',
          },
          globalJinjaData: {},
        ),
      );
      final context = StringSinkRenderContext(envImport, StringBuffer());
      final node = FromImport(
          template: Constant(value: 'lib.html'), names: [('missing', null)]);

      renderer.visitFromImport(node, context);
      final macro = context.resolve('missing') as Function;
      expect(() => macro([], {}), throwsA(isA<TemplateRuntimeError>()));
    });

    test('visitImport (synchronous)', () {
      final envImport = Environment(
        loader: MapLoader(
          {
            'lib.html': '{% macro m() %}hi{% endmacro %}',
          },
          globalJinjaData: {},
        ),
      );
      final sink = StringBuffer();
      final context = StringSinkRenderContext(envImport, sink);

      final node = Import(
        template: Constant(value: 'lib.html'),
        target: 'lib',
      );

      renderer.visitImport(node, context);
      final ns = context.resolve('lib') as Namespace;
      final macro = ns['m'] as Function;
      expect(macro([], {}).toString(), equals('hi'));
    });

    test('visitImport with context', () {
      final envImport = Environment(
        loader: MapLoader(
          {
            'lib.html': '{% macro m() %}{{ x }}{% endmacro %}',
          },
          globalJinjaData: {},
        ),
      );
      final sink = StringBuffer();
      final context =
          StringSinkRenderContext(envImport, sink, data: {'x': 'val'});

      final node = Import(
        template: Constant(value: 'lib.html'),
        target: 'lib',
      );

      renderer.visitImport(node, context);
      final ns = context.resolve('lib') as Namespace;
      final macro = ns['m'] as Function;
      expect(macro([], {}).toString(), equals('val'));
    });

    test('visitIf with orElse', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);

      final node = If(
        test: Constant(value: false),
        body: Data(data: 'if'),
        orElse: Data(data: 'else'),
      );

      renderer.visitIf(node, context);
      expect(sink.toString(), equals('else'));
    });

    test('visitInclude with list of paths', () {
      final envInclude = Environment(
        loader: MapLoader(
          {
            'b.html': 'B',
          },
          globalJinjaData: {},
        ),
      );
      final sink = StringBuffer();
      final context = StringSinkRenderContext(envInclude, sink);

      final node = Include(
        template: Constant(value: ['a.html', 'b.html']),
      );

      renderer.visitInclude(node, context);
      expect(sink.toString(), equals('B'));
    });

    test('visitInclude without context', () {
      final envInclude = Environment(
        loader: MapLoader(
          {
            'inc.html': '{{ x }}',
          },
          globalJinjaData: {},
        ),
      );
      final sink = StringBuffer();
      final context =
          StringSinkRenderContext(envInclude, sink, data: {'x': 'secret'});

      final node = Include(
        template: Constant(value: 'inc.html'),
        withContext: false,
      );

      renderer.visitInclude(node, context);
      expect(sink.toString(), equals('')); // x is not available
    });

    test('visitMacro and call', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);

      final node = Macro(
        name: 'm',
        positional: [Name(name: 'x', context: AssignContext.store)],
        named: [],
        body: Interpolation(value: Name(name: 'x')),
      );

      renderer.visitMacro(node, context);
      final macro = context.resolve('m') as Function;
      expect(macro(['hi'], {}).toString(), equals('hi'));
    });

    test('visitCallBlock', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(
        env,
        sink,
        data: {
          'caller_user': (List positional, Map named) {
            final caller = named['caller'] as Function;
            return 'CALLER: ${caller([], {})}';
          },
        },
      );

      final node = CallBlock(
        name: 'caller',
        // Pass positional argument as [List, Map] to satisfy StringSinkRenderer.visitCallBlock line 856
        call: Call(
            value: Name(name: 'caller_user'),
            calling:
                Calling(arguments: [Constant(value: []), Constant(value: {})])),
        body: Data(data: 'inside'),
      );

      renderer.visitCallBlock(node, context);
      expect(sink.toString(), equals('CALLER: inside'));
    });
  });
}
