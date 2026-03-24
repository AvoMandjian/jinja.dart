import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/visitor.dart';
import 'package:test/test.dart';

final class MockNode extends Node {
  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) =>
      throw UnimplementedError();

  @override
  Node copyWith() => throw UnimplementedError();

  @override
  Map<String, Object?> toJson() => {};

  @override
  String toSource() => '';
}

class ThrowingToString {
  @override
  String toString() => throw Exception('oops');
}

void main() {
  group('TemplateError Coverage Extensions', () {
    test('toString with many context variables', () {
      final context = <String, Object?>{};
      for (var i = 0; i < 15; i++) {
        context['var$i'] = i;
      }

      final error = TemplateRuntimeError('msg', contextSnapshotValue: context);
      final str = error.toString();

      expect(str, contains('Context:'));
      expect(str, contains('var0'));
      expect(str, contains('var9'));
      expect(str, contains('... and 5 more variables'));
      expect(str, isNot(contains('var10')));
    });

    test('toString with long variable value', () {
      final longValue = 'a' * 100;
      final error = TemplateRuntimeError('msg',
          contextSnapshotValue: {'long': longValue});
      final str = error.toString();

      expect(str, contains('a' * 50 + '...'));
    });

    test('toString with variable that throws in toString', () {
      final error = TemplateRuntimeError('msg',
          contextSnapshotValue: {'bad': ThrowingToString()});
      final str = error.toString();

      expect(str, contains('ThrowingToString(toString failed:'));
    });

    test('toString with location info (template path + node)', () {
      final node = Name(name: 'x', line: 10, column: 5);
      final error = TemplateRuntimeError('msg',
          nodeValue: node, templatePathValue: 'tmpl.html');
      final str = error.toString();

      expect(
          str, contains('Location: template \'tmpl.html\', line 10, column 5'));
      expect(str, contains('Node: Name'));
    });

    test('toString with location info (node only)', () {
      final node = Name(name: 'x', line: 10, column: 5);
      final error = TemplateRuntimeError('msg', nodeValue: node);
      final str = error.toString();

      expect(str, contains('Location: line 10, column 5'));
    });

    test('toString with many call stack frames', () {
      final frames = List.generate(15, (i) => 'frame$i');
      final error = TemplateRuntimeError('msg', callStackValue: frames);
      final str = error.toString();

      expect(str, contains('Call Stack:'));
      expect(str, contains('1. frame0'));
      expect(str, contains('10. frame9'));
      expect(str, isNot(contains('11. frame10')));
    });

    test('toString with many stack trace frames', () {
      final trace = StackTrace.fromString('line1\n' * 15);
      final error = TemplateRuntimeError('msg', stackTraceValue: trace);
      final str = error.toString();

      expect(str, contains('Stack Trace:'));
      expect(str, contains('line1'));
      expect(str, contains('... and '));
    });

    test('_getNodeType handles various suffixes', () {
      // Expression
      final expr = Constant(value: 1);
      final errorExpr = TemplateRuntimeError('msg', nodeValue: expr);
      expect(errorExpr.toString(), contains('Node: Constant'));

      // Node base - MockNode becomes Mock because "Node" suffix is removed
      final node = MockNode();
      final errorNode = TemplateRuntimeError('msg', nodeValue: node);
      expect(errorNode.toString(), contains('Node: Mock'));
    });

    test('TemplateNotFound searched paths', () {
      final error = TemplateNotFound(name: 'foo', searchPaths: ['a', 'b']);
      expect(error.toString(), contains('TemplateNotFound'));
    });
  });
}
