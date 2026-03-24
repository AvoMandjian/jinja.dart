import 'package:jinja/src/environment.dart';
import 'package:jinja/src/loaders.dart';
import 'package:jinja/src/nodes.dart';
import 'package:test/test.dart';

void main() {
  group('Environment Coverage Extensions 3', () {
    test('modifiers in fromString', () {
      final env = Environment(
        modifiers: [
          (node) => node is TemplateNode
              ? TemplateNode(body: Data(data: 'modified'))
              : node,
        ],
      );
      final t = env.fromString('original');
      expect(t.render(), equals('modified'));
    });

    test('autoReload in getTemplate', () {
      final loader = MapLoader({'a.html': 'initial'}, globalJinjaData: {});
      final env = Environment(loader: loader);

      // Load initially
      expect(env.getTemplate('a.html').render(), equals('initial'));

      // Change loader content
      loader.sources['a.html'] = 'changed';
      // With autoReload=true, it should reload
      expect(env.getTemplate('a.html').render(), equals('changed'));

      final envNoReload = Environment(loader: loader, autoReload: false);
      expect(envNoReload.getTemplate('a.html').render(), equals('changed'));
      loader.sources['a.html'] = 'initial again';
      // With autoReload=false, it should use cached version
      expect(envNoReload.getTemplate('a.html').render(), equals('changed'));
    });

    test('lex and scan', () {
      final env = Environment();
      final tokens = env.lex('{{ x }}');
      expect(tokens, isNotEmpty);

      final node = env.scan(tokens);
      expect(node, isA<Node>());
    });

    test('selectTemplate with Template object', () {
      final env = Environment();
      final t1 = env.fromString('T1');
      expect(env.selectTemplate([t1]), equals(t1));
    });
  });
}
