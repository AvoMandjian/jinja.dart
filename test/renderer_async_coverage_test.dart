import 'package:jinja/src/environment.dart';
import 'package:jinja/src/loaders.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();

  group('AsyncRenderer Coverage Extensions', () {
    test('visitConcat (async)', () async {
      final template = env.fromString('{{ "a" ~ "b" ~ async_val }}');
      final result =
          await template.renderAsync({'async_val': Future.value('c')});
      expect(result, equals('abc'));
    });

    test('visitCondition (async)', () async {
      final template = env.fromString('{{ "yes" if async_bool else "no" }}');
      expect(await template.renderAsync({'async_bool': Future.value(true)}),
          equals('yes'));
      expect(await template.renderAsync({'async_bool': Future.value(false)}),
          equals('no'));
    });

    test('visitDict (async)', () async {
      // Harder to test directly in template as literals are often optimized
      // but we can use a custom node or a complex expression
      final template =
          env.fromString('{% set d = {async_key: async_val} %}{{ d["a"] }}');
      final result = await template.renderAsync({
        'async_key': Future.value('a'),
        'async_val': Future.value(42),
      });
      expect(result, equals('42'));
    });

    test('visitFor with test and orElse (async)', () async {
      final template = env.fromString(
          '{% for i in items if i > 1 %}{{ i }}{% else %}none{% endfor %}');

      // All filtered out
      expect(
          await template.renderAsync({
            'items': [0, 1]
          }),
          equals('none'));
      // Some pass
      expect(
          await template.renderAsync({
            'items': [1, 2, 3]
          }),
          equals('23'));
      // Empty
      expect(await template.renderAsync({'items': []}), equals('none'));
    });

    test('visitTemplateNode super() and self (async)', () async {
      final env2 = Environment(
        loader: MapLoader({
          'parent': '{% block b %}parent{% endblock %}',
          'child':
              '{% extends "parent" %}{% block b %}child {{ super() }}{% endblock %}',
        }, globalJinjaData: {}),
      );
      final template = env2.getTemplate('child');
      final result = await template.renderAsync();
      expect(result.trim(), equals('child parent'));
    });

    test('visitInterpolation async re-evaluation re-finalized', () async {
      // This targets 2706-2792 in renderer.dart
      final template = env.fromString('{% set x = async_val %}{{ x }}');
      // finalized might be null if x is not yet set
      final result =
          await template.renderAsync({'async_val': Future.value('resolved')});
      expect(result, equals('resolved'));
    });

    test('visitLogical short-circuit (async)', () async {
      final template =
          env.fromString('{{ true or async_val }} {{ false and async_val }}');
      final result =
          await template.renderAsync({'async_val': Future.value('not_called')});
      expect(result, equals('true false'));
    });
  });
}
