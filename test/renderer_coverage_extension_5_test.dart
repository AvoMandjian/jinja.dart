import 'package:jinja/src/environment.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:jinja/src/runtime.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:test/test.dart';

base class FailingRenderContext extends StringSinkRenderContext {
  FailingRenderContext(
    Environment environment,
    StringSink sink, {
    super.data,
  }) : super(environment, sink);

  @override
  Object? resolve(String name) {
    if (name == 'fail_me') {
      throw Exception('Synthetic failure for testing error handling');
    }
    return super.resolve(name);
  }
}

void main() {
  final env = Environment();
  const renderer = StringSinkRenderer();

  group('StringSinkRenderer Coverage Extensions 5', () {
    test('visitName catch generic exception', () {
      final sink = StringBuffer();
      final context = FailingRenderContext(env, sink);

      final node = Name(name: 'fail_me', context: AssignContext.load);
      
      // visitVariable (654-696)
      expect(
        () => renderer.visitName(node, context),
        throwsA(isA<TemplateErrorWrapper>()),
      );
    });

    test('visitFor with Future iterable in async context', () async {
      final envAsync = Environment();
      final template = envAsync.fromString('{% for i in future_list %}{{ i }}{% endfor %}');
      
      final future = Future.delayed(Duration(milliseconds: 10), () => [1, 2, 3]);
      final result = await template.renderAsync({'future_list': future});
      expect(result, equals('123'));
    });

    test('visitFor with null iterable and Attribute extraction', () async {
      // This aims to cover lines 1142-1158 in renderer.dart
      final envAsync = Environment();
      final template = envAsync.fromString('{% for i in obj.missing %}{{ i }}{% endfor %}');
      
      // obj is present, but obj.missing is null
      final result = await template.renderAsync({'obj': {'some': 'data'}});
      expect(result, equals(''));
    });

    test('visitFor with Attribute value not a Name', () async {
      // This aims to cover lines 1151-1158
      final envAsync = Environment();
      // (range(0)).missing - range(0) is a Call, not a Name
      // We use a Map to avoid UndefinedError from getAttribute on List
      final template = envAsync.fromString('{% for i in (dict()).missing %}{{ i }}{% endfor %}');
      
      final result = await template.renderAsync();
      expect(result, equals(''));
    });

    test('visitAssign with Future value', () async {
      // Create a context with _AsyncCollectingSink (internal to renderer.dart)
      // but we can just use the template.renderAsync which should use it.
      final env = Environment();
      final template = env.fromString('{% set x = async_val %}{{ x }}');
      final result = await template.renderAsync({'async_val': Future.value('resolved')});
      expect(result, equals('resolved'));
    });

    test('visitFor with Future iterable (sync renderer fallback)', () {
      final sink = StringBuffer();
      final context = StringSinkRenderContext(env, sink);
      final node = For(
        target: Name(name: 'i', context: AssignContext.store),
        iterable: Constant(value: Future.value([1, 2])),
        body: Output(nodes: [Name(name: 'i', context: AssignContext.load)]),
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
  });
}
