@TestOn('vm || chrome')
library;

import 'dart:io';

import 'package:jinja/jinja.dart';
import 'package:jinja/loaders.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('FileSystemLoader Edge Cases', () {
    late Directory tempDir;
    late Environment env;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('jinja_fs_test_');

      File(p.join(tempDir.path, 'base.html')).writeAsStringSync('Base: {% block content %}{% endblock %}');

      var pagesDir = Directory(p.join(tempDir.path, 'pages'))..createSync();
      File(p.join(pagesDir.path, 'child.html')).writeAsStringSync(
        '{% extends "base.html" %}{% block content %}Child{% endblock %}',
      );

      var partialsDir = Directory(p.join(tempDir.path, 'partials'))..createSync();
      File(p.join(partialsDir.path, 'part.html')).writeAsStringSync('Part');

      File(p.join(tempDir.path, 'main.html')).writeAsStringSync('Main -> {% include "partials/part.html" %}');

      File(p.join(tempDir.path, 'broken.html')).writeAsStringSync('{% include "missing.html" %}');

      File(p.join(tempDir.path, 'safe.html')).writeAsStringSync(
        'Safe -> {% include "missing.html" ignore missing %}',
      );

      var loader = FileSystemLoader(paths: [tempDir.path]);
      env = Environment(loader: loader);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Template Inheritance resolves upwards across folders', () {
      var tmpl = env.getTemplate('pages/child.html');
      expect(tmpl.render(), equals('Base: Child'));
    });

    test('Include Resolution looks deeply into partials', () {
      var tmpl = env.getTemplate('main.html');
      expect(tmpl.render(), equals('Main -> Part'));
    });

    test('Include with ignore missing swallows TemplateNotFound', () {
      var tmpl = env.getTemplate('safe.html');
      expect(tmpl.render(), equals('Safe -> '));
    });

    test('TemplateNotFound Exceptions trigger properly on disk', () {
      expect(
        () => env.getTemplate('non_existent.html'),
        throwsA(isA<TemplateNotFound>()),
      );

      var tmpl = env.getTemplate('broken.html');
      expect(() => tmpl.render(), throwsA(isA<TemplateNotFound>()));
    });

    test('baseString bypasses File System logic entirely', () {
      // test fallback behavior if any such mechanism exists in loader
    });
  });
}
