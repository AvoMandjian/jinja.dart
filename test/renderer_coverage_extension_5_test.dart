import 'package:jinja/src/environment.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:jinja/src/runtime.dart';
import 'package:test/test.dart';

base class FailingRenderContext extends StringSinkRenderContext {
  FailingRenderContext(
    super.environment,
    super.sink, {
    super.data,
  });

  @override
  Object? resolve(String name) {
    if (name == 'fail_me') {
      throw Exception('Synthetic failure for testing error handling');
    }
    return super.resolve(name);
  }
}

class ThrowingSink implements StringSink {
  @override
  void write(Object? obj) => throw Exception('Sink failure');
  @override
  void writeAll(Iterable objects, [String separator = '']) =>
      throw Exception('Sink failure');
  @override
  void writeCharCode(int charCode) => throw Exception('Sink failure');
  @override
  void writeln([Object? obj = '']) => throw Exception('Sink failure');
}

void main() {
  final env = Environment();
  const renderer = StringSinkRenderer();

  group('StringSinkRenderer Coverage Extensions 5', () {
    test('visitOutput catch generic exception', () {
      final sink = ThrowingSink();
      final context = StringSinkRenderContext(env, sink);
      final node = Output(nodes: [Data(data: 'some data')]);

      expect(
        () => renderer.visitOutput(node, context),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });

    test('visitInterpolation catch generic exception', () {
      final sink = ThrowingSink();
      final context = StringSinkRenderContext(env, sink);
      final node = Interpolation(value: Constant(value: 'val'));

      expect(
        () => renderer.visitInterpolation(node, context),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });

    test('visitTemplateNode required block found', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);
      final block = Block(
          name: 'req_block',
          body: Data(data: 'block content'),
          scoped: false,
          required: false);
      final node = TemplateNode(body: Output(nodes: []), blocks: [block]);

      renderer.visitTemplateNode(node, context);

      final self = context.get('self') as Namespace;
      final renderFunc = self['req_block'] as Function;

      renderFunc();
      expect(sink.toString(), contains('block content'));
    });

    test('visitTemplateNode required block not found', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);
      // Mark block as required
      final block = Block(
          name: 'req_block',
          body: Output(nodes: []),
          scoped: false,
          required: true);
      final node = TemplateNode(body: Output(nodes: []), blocks: [block]);

      renderer.visitTemplateNode(node, context);

      // The callback for the required block should throw TemplateRuntimeError
      final callbacks = context.blocks['req_block']!;
      expect(callbacks.length, equals(1));
      expect(() => callbacks[0](context), throwsA(isA<TemplateRuntimeError>()));
    });
    test('visitName catch generic exception', () {
      final sink = StringBuffer();
      final context = FailingRenderContext(env, sink);

      final node = Name(name: 'fail_me');

      // visitVariable (654-696)
      expect(
        () => renderer.visitName(node, context),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });

    test('visitFor async re-evaluation in macro', () async {
      // This aims to cover lines 1163-1227 in renderer.dart via macro execution
      final envAsync = Environment();
      final template = envAsync.fromString('''
{% macro m(async_val) %}
  {% set items = async_val %}
  {% for i in items %}{{ i }}{% endfor %}
{% endmacro %}
{{ m(async_val) }}
''');

      final future =
          Future.delayed(Duration(milliseconds: 10), () => [1, 2, 3]);
      final result = await template.renderAsync({'async_val': future});
      expect(result.trim(), equals('123'));
    });

    test('visitFor with null iterable and Attribute extraction', () async {
      // This aims to cover lines 1142-1158 in renderer.dart
      final envAsync = Environment();
      final template =
          envAsync.fromString('{% for i in obj.missing %}{{ i }}{% endfor %}');

      // obj is present, but obj.missing is null
      final result = await template.renderAsync({
        'obj': {'some': 'data'}
      });
      expect(result, equals(''));
    });

    test('visitFor with Attribute value not a Name', () async {
      // This aims to cover lines 1151-1158
      final envAsync = Environment();
      // (range(0)).missing - range(0) is a Call, not a Name
      // We use a Map to avoid UndefinedError from getAttribute on List
      final template = envAsync
          .fromString('{% for i in (dict()).missing %}{{ i }}{% endfor %}');

      final result = await template.renderAsync();
      expect(result, equals(''));
    });

    test('visitInterpolation async re-evaluation in macro', () async {
      // This aims to cover lines 1473-1479 and 1485-1538 in renderer.dart via macro
      final envAsync = Environment();
      final template = envAsync.fromString('''
{% macro m(async_val) %}
  {% set x = async_val %}
  {{ x | upper }}
{% endmacro %}
{{ m(async_val) }}
''');

      final future =
          Future.delayed(Duration(milliseconds: 10), () => 'resolved');
      final result = await template.renderAsync({'async_val': future});
      expect(result.trim(), equals('RESOLVED'));
    });

    test('visitFor with Future iterable (sync renderer fallback)', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);
      final node = For(
        target: Name(name: 'i', context: AssignContext.store),
        iterable: Constant(value: Future.value([1, 2])),
        body: Output(nodes: [Name(name: 'i')]),
      );

      // Should write the Future to the sink (lines 1126-1131)
      renderer.visitFor(node, context);
      expect(sink.toString(), contains('Future'));
    });

    test('takeNamedValue default/defaultValue edge case', () {
      final env = Environment();
      // Trying to trigger lines 291-301
      // If we have a macro parameter named 'default'
      final template = env.fromString('''
{% macro test(default=42) -%}
{{ default }}
{%- endmacro %}
{{ test(default=7) }}
''');
      expect(template.render().trim(), equals('7'));
    });
    test('visitFromImport with invalid template type', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);
      final node = FromImport(
        template: Constant(value: 42), // Not String or Template
        names: [],
      );
      expect(
          () => renderer.visitFromImport(node, context), throwsArgumentError);
    });

    test('visitImport with invalid template type', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);
      final node = Import(
        template: Constant(value: 42), // Not String or Template
        target: 't',
      );
      expect(() => renderer.visitImport(node, context), throwsArgumentError);
    });
    test('visitTemplateNode super block not found', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);
      // We need a block that calls super() but has no parent block in context.blocks
      final block = Block(
        name: 'b',
        body: Interpolation(value: Call(value: Name(name: 'super'))),
        scoped: false,
        required: false,
      );
      final node = TemplateNode(body: Output(nodes: []), blocks: [block]);

      renderer.visitTemplateNode(node, context);

      // Execute the block callback
      final callbacks = context.blocks['b']!;
      expect(() => callbacks[0](context), throwsA(isA<TemplateRuntimeError>()));
    });

    test('visitTemplateNode catch generic exception', () {
      final sink = ThrowingSink();
      final context = StringSinkRenderContext(env, sink);
      final node =
          TemplateNode(body: Output(nodes: [Data(data: 'd')]), blocks: []);

      expect(
        () => renderer.visitTemplateNode(node, context),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });
    test('visitInclude with invalid template type', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);
      final node = Include(
        template: Constant(value: 42), // Not String, Template, or List
      );
      expect(() => renderer.visitInclude(node, context), throwsArgumentError);
    });

    test('visitSlice String variations', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);

      // Negative index (wraps)
      var node = Slice(
          value: Constant(value: 'abcd'),
          start: Constant(value: -2),
          stop: Constant(value: -1));
      expect(renderer.visitSlice(node, context), equals('c'));

      // Out of bounds (clamps)
      node = Slice(
          value: Constant(value: 'abcd'),
          start: Constant(value: -10),
          stop: Constant(value: 10));
      expect(renderer.visitSlice(node, context), equals('abcd'));

      // stop < start
      node = Slice(
          value: Constant(value: 'abcd'),
          start: Constant(value: 2),
          stop: Constant(value: 1));
      expect(renderer.visitSlice(node, context), equals(''));
    });

    test('visitSlice List error paths', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);

      // Negative start
      var node =
          Slice(value: Constant(value: [1, 2]), start: Constant(value: -1));
      expect(() => renderer.visitSlice(node, context),
          throwsA(isA<TemplateRuntimeError>()));

      // stop < start
      node = Slice(
          value: Constant(value: [1, 2]),
          start: Constant(value: 1),
          stop: Constant(value: 0));
      expect(() => renderer.visitSlice(node, context),
          throwsA(isA<TemplateRuntimeError>()));

      // Out of bounds start
      node = Slice(value: Constant(value: [1, 2]), start: Constant(value: 5));
      expect(() => renderer.visitSlice(node, context),
          throwsA(isA<TemplateRuntimeError>()));
    });

    test('visitSlice invalid object', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);
      final node = Slice(value: Constant(value: 42), start: Constant(value: 0));
      expect(() => renderer.visitSlice(node, context),
          throwsA(isA<TemplateRuntimeError>()));
    });

    test('visitSlice catch generic exception', () {
      final sink = StringBuffer();
      final context = FailingRenderContext(env, sink);
      // Expression that throws in accept
      final node = Slice(value: Name(name: 'fail_me'), start: null);

      expect(() => renderer.visitSlice(node, context),
          throwsA(isA<TemplateErrorWrapper>()));
    });
    test('visitFromImport with Template object', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);
      final template = env.fromString('{% macro m() %}m{% endmacro %}');
      final node = FromImport(
        template: Constant(value: template),
        names: [('m', null)],
      );
      renderer.visitFromImport(node, context);
      final m = context.get('m') as Function;
      expect(m([], {}).toString(), equals('m'));
    });

    test('visitImport with Template object', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);
      final template = env.fromString('{% macro m() %}m{% endmacro %}');
      final node = Import(
        template: Constant(value: template),
        target: 't',
      );
      renderer.visitImport(node, context);
      final t = context.get('t') as Namespace;
      final m = t['m'] as Function;
      expect(m([], {}).toString(), equals('m'));
    });
  });
}
