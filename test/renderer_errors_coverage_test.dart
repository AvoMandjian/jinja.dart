import 'package:jinja/src/environment.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:jinja/src/visitor.dart';
import 'package:test/test.dart';

final class ThrowingNode extends Expression {
  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    throw Exception('direct error');
  }

  @override
  ThrowingNode copyWith() => ThrowingNode();

  @override
  Map<String, Object?> toJson() => {};

  @override
  String toSource() => '';
}

void main() {
  final env = Environment();
  const renderer = StringSinkRenderer();

  group('Renderer Error Paths Coverage', () {
    test('visitName with typo suggestions', () {
      // Use undefined handler that throws non-TemplateError to trigger the catch block in visitName
      final envWithErr = Environment(
        undefined: (name, [tmpl]) => throw Exception('undefined'),
        globals: {'user_name': 'admin'},
      );
      final context = StringSinkRenderContext(envWithErr, StringBuffer(), parent: envWithErr.globals);
      final node = Name(name: 'user_nme');

      expect(
        () => renderer.visitName(node, context),
        throwsA(isA<TemplateErrorWrapper>().having((e) => e.suggestions, 'suggestions', contains('Did you mean one of these? user_name'))),
      );
    });

    test('visitExtends error wrapping', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      final node = Extends(template: ThrowingNode());

      expect(
        () => renderer.visitExtends(node, context),
        throwsA(isA<TemplateErrorWrapper>().having((e) => e.message, 'message', contains('Error extending template'))),
      );
    });

    test('visitFor error wrapping in render', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      // Force a non-TemplateError inside render by passing a non-iterable that fails list(iterable)
      // Actually list(iterable) throws TypeError if not iterable.
      final node = For(
        target: Name(name: 'i', context: AssignContext.store),
        iterable: Constant(value: 42),
        body: Data(),
      );

      expect(
        () => renderer.visitFor(node, context),
        throwsA(isA<TemplateErrorWrapper>().having((e) => e.message, 'message', contains('Error processing for loop iterable'))),
      );
    });

    test('visitFor error in outer catch', () {
      final context = StringSinkRenderContext(env, StringBuffer());
      final node = For(
        target: Name(name: 'i', context: AssignContext.store),
        iterable: ThrowingNode(),
        body: Data(),
      );

      expect(
        () => renderer.visitFor(node, context),
        throwsA(isA<TemplateErrorWrapper>().having((e) => e.message, 'message', contains('Error rendering for loop'))),
      );
    });

    test('visitFor error in loop body wrapping', () {
      // We need to trigger an error *inside* the loop body accept call
      final context = StringSinkRenderContext(env, StringBuffer());
      final node = For(
        target: Name(name: 'i', context: AssignContext.store),
        iterable: Constant(value: [1]),
        body: ThrowingNode(),
      );

      expect(
        () => renderer.visitFor(node, context),
        throwsA(isA<TemplateErrorWrapper>().having((e) => e.message, 'message', contains('Error in for loop body'))),
      );
    });
  });
}
