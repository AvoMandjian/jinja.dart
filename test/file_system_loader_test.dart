@TestOn('vm')
library;

import 'dart:convert';

import 'package:jinja/jinja.dart';
import 'package:jinja/loaders.dart';
import 'package:test/test.dart';

void main() {
  var paths = <String>['test/res/templates'];

  group('FileSystemLoader', () {
    test('paths', () {
      var loader = FileSystemLoader(paths: paths);
      var env = Environment(loader: loader);
      var tmpl = env.getTemplate('test.html');
      expect(tmpl.render().trim(), equals('BAR'));
      tmpl = env.getTemplate('foo/test.html');
      expect(tmpl.render().trim(), equals('FOO'));
    });

    test('utf8', () {
      var loader = FileSystemLoader(
        paths: paths,
        extensions: <String>{'txt'},
      );
      var env = Environment(loader: loader);
      var tmpl = env.getTemplate('mojibake.txt');
      expect(tmpl.render().trim(), equals('文字化け'));
    });

    test('iso-8859-1', () {
      var loader = FileSystemLoader(
        paths: paths,
        extensions: <String>{'txt'},
        encoding: latin1,
      );
      var env = Environment(loader: loader);
      var tmpl = env.getTemplate('mojibake.txt');
      expect(
        tmpl.render().trim(),
        equals('æ\x96\x87\xe5\xad\x97\xe5\x8c\x96\xe3\x81\x91'),
      );
    });

    test('listTemplates', () {
      var loader = FileSystemLoader(paths: paths, extensions: {'html', 'txt'});
      var templates = loader.listTemplates();
      expect(templates, containsAll(['foo/test.html', 'test.html', 'mojibake.txt']));
    });

    test('TemplateNotFound', () {
      var loader = FileSystemLoader(paths: paths);
      expect(() => loader.getSource('non_existent.html'), throwsA(isA<TemplateNotFound>()));
    });

    test('baseString', () {
      var loader = FileSystemLoader(baseString: 'BASE');
      var env = Environment(loader: loader);
      var tmpl = env.getTemplate('anything.html');
      expect(tmpl.render(), equals('BASE'));
    });
  });
}
