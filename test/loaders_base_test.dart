@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

class DummyLoader extends Loader {
  @override
  Template load(Environment environment, String path,
      {Map<String, Object?>? globals}) {
    return environment.fromString('dummy');
  }
}

class NoSourceLoader extends Loader {
  @override
  bool get hasSourceAccess => false;

  @override
  Template load(Environment environment, String path,
      {Map<String, Object?>? globals}) {
    return environment.fromString('dummy');
  }
}

void main() {
  group('Loader base class', () {
    test('hasSourceAccess defaults to true', () {
      final loader = DummyLoader();
      expect(loader.hasSourceAccess, isTrue);
    });

    test('globals defaults to null', () {
      final loader = DummyLoader();
      expect(loader.globals, isNull);
    });

    test(
        'getSource throws TemplateNotFound if hasSourceAccess is true but no override',
        () {
      final loader = DummyLoader();
      expect(
          () => loader.getSource('missing'), throwsA(isA<TemplateNotFound>()));
    });

    test('getSource throws UnsupportedError if hasSourceAccess is false', () {
      final loader = NoSourceLoader();
      expect(() => loader.getSource('missing'), throwsUnsupportedError);
    });

    test('listTemplates throws UnsupportedError by default', () {
      final loader = DummyLoader();
      expect(() => loader.listTemplates(), throwsUnsupportedError);
    });
  });

  group('MapLoader', () {
    test('hasSourceAccess is false', () {
      final loader = MapLoader({'a': 'b'}, globalJinjaData: {});
      expect(loader.hasSourceAccess, isFalse);
    });

    test('globals returns globalJinjaData', () {
      final data = {'key': 'val'};
      final loader = MapLoader({}, globalJinjaData: data);
      expect(loader.globals, equals(data));
    });

    test('listTemplates returns keys', () {
      final loader = MapLoader({'a': '1', 'b': '2'}, globalJinjaData: {});
      expect(loader.listTemplates(), equals(['a', 'b']));
    });
  });
}
