import 'dart:async';

import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

void main() {
  group('Integrated Async Rendering Coverage', () {
    test('visitInterpolation re-evaluation with assignment Future', () async {
      final env = Environment();
      // We want to test the case where a variable is initially null but
      // set by a preceding async assignment.
      // Template: {% set x = async_val %}{{ x }}
      final t = env.fromString('{% set x = async_val %}{{ x }}');

      // The way AsyncRenderer.render works:
      // 1. It creates _AsyncCollectingSink.
      // 2. It calls _syncRenderer.visitTemplateNode.
      // 3. StringSinkRenderer.visitAssign sees async_val is a Future.
      // 4. It calls sink.writeAssignmentFuture(assignmentFuture).
      // 5. StringSinkRenderer.visitInterpolation sees x is null (initially).
      // 6. It sees context.sink is _AsyncCollectingSink.
      // 7. It creates a checkFuture that calls sink.waitForAllFutures().
      // 8. It writes checkFuture to the sink.

      final result = await t.renderAsync({'async_val': Future.delayed(Duration(milliseconds: 10), () => 'resolved')});
      expect(result, equals('resolved'));
    });

    test('visitFor async re-evaluation of iterable', () async {
      final env = Environment();
      // Similar to above but for the iterable in a for loop
      final t = env.fromString('{% set items = async_items %}{% for i in items %}{{ i }}{% endfor %}');

      final result = await t.renderAsync({
        'async_items': Future.delayed(Duration(milliseconds: 10), () => [1, 2, 3]),
      });
      expect(result, equals('123'));
    });

    test('_AsyncCollectingSink error handling in getResolvedContent', () async {
      final env = Environment();
      final t = env.fromString('{{ async_fail }}');

      final future = Future.error(Exception('async failure'));
      // We expect TemplateErrorWrapper
      expect(t.renderAsync({'async_fail': future}), throwsA(isA<TemplateErrorWrapper>()));
    });

    test('visitAssign with Future error', () async {
      final env = Environment();
      final t = env.fromString('{% set x = async_fail %}{{ x }}');

      final future = Future.error(Exception('assign failure'));
      expect(t.renderAsync({'async_fail': future}), throwsA(isA<TemplateErrorWrapper>()));
    });
  });
}
