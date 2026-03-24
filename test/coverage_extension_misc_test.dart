import 'dart:async';

import 'package:jinja/jinja.dart';
import 'package:jinja/src/defaults.dart';
import 'package:jinja/src/renderer.dart';
import 'package:jinja/src/runtime.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();

  group('_AsyncCollectingSink Coverage Extensions', () {
    test('writeAll and writeln', () async {
      final t = env.fromString('{{ items | join("|") }}');
      final result = await t.renderAsync({
        'items': ['a', 'b']
      });
      expect(result, equals('a|b'));
    });

    test('waitForAllFutures', () async {
      final t = env.fromString('{% set x = async_val %}{{ x }}');
      final result =
          await t.renderAsync({'async_val': Future.value('resolved')});
      expect(result, equals('resolved'));
    });
  });

  group('Environment Coverage Extensions 4', () {
    test('listTemplates', () {
      final loader = MapLoader({'a': 'A'}, globalJinjaData: {});
      final envWithLoader = Environment(loader: loader);
      expect(envWithLoader.listTemplates(), equals(['a']));
    });

    test('EnvironmentFinalizer in wrapFinalizer', () {
      final env2 = Environment();
      final context = StringSinkRenderContext(env2, StringBuffer());
      final wrapped =
          Environment.wrapFinalizer((Environment e, Object? v) => '[$v]');
      expect(wrapped(context, 'x'), equals('[x]'));
    });
  });

  group('defaults.dart Coverage Extensions 4', () {
    test('String.format with grouping', () {
      // grouping is triggered by comma in spec
      final formatter = getAttribute('format', '{:,.2f}') as Function;
      expect(formatter(1234567.89), equals('1,234,567.89'));
    });

    test('LoopContext and Namespace in getItem/getAttribute', () {
      final loop = LoopContext([1], 0, (it, [d = 0]) => '');
      loop.iterator.moveNext();

      // getAttribute
      expect(getAttribute('index', loop), equals(1));

      // getItem
      expect(getItem('index', loop), equals(1));

      final ns = Namespace({'a': 1});
      expect(getAttribute('a', ns), equals(1));
      expect(getItem('a', ns), equals(1));
    });
  });
}
