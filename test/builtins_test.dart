@TestOn('vm')
library;

import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

void main() {
  var env = Environment();

  group('Core Filters', () {
    test('urlencode', () {
      var tmpl = env.fromString('{{ "foo bar"|urlencode }}');
      expect(tmpl.render(), equals('foo+bar'));
      tmpl = env.fromString('{{ {"a": "1", "b": 2}|urlencode }}');
      expect(tmpl.render(), equals('a=1&b=2'));
    });

    test('xmlattr', () {
      var tmpl = env.fromString('{{ {"class": "my&class"}|xmlattr }}');
      expect(tmpl.render(), equals(' class="my&amp;class"'));
    });

    test('sort', () {
      var tmpl = env.fromString('{{ [3, 1, 2]|sort|join(",") }}');
      expect(tmpl.render(), equals('1,2,3'));
      tmpl = env.fromString('{{ [3, 1, 2]|sort(reverse=true)|join(",") }}');
      expect(tmpl.render(), equals('3,2,1'));
      // Sort by attribute
      var data = {
        'users': [
          {'name': 'bob', 'age': 20},
          {'name': 'alice', 'age': 30},
        ],
      };
      tmpl = env.fromString('{{ users|sort(attribute="name")|map(attribute="name")|join(",") }}');
      expect(tmpl.render(data), equals('alice,bob'));
    });

    test('unique', () {
      var tmpl = env.fromString('{{ [1, 2, 1, 3]|unique|join(",") }}');
      expect(tmpl.render(), equals('1,2,3'));
    });

    test('min/max', () {
      var tmpl = env.fromString('{{ [1, 2, 3]|min }}');
      expect(tmpl.render(), equals('1'));
      tmpl = env.fromString('{{ [1, 2, 3]|max }}');
      expect(tmpl.render(), equals('3'));
    });

    test('intersect/difference', () {
      var tmpl = env.fromString('{{ [1, 2, 3]|intersect([2, 3, 4])|sort|join(",") }}');
      expect(tmpl.render(), equals('2,3'));
      tmpl = env.fromString('{{ [1, 2, 3]|difference([2, 3, 4])|sort|join(",") }}');
      expect(tmpl.render(), equals('1'));
    });
  });

  group('Utility Filters', () {
    test('slugify', () {
      var tmpl = env.fromString('{{ "Hello World!"|slugify }}');
      expect(tmpl.render(), equals('hello-world'));
    });

    test('urlize', () {
      var tmpl = env.fromString('{{ "Check https://google.com"|urlize }}');
      expect(tmpl.render(), equals('Check <a href="https://google.com">https://google.com</a>'));
    });

    test('indent', () {
      var tmpl = env.fromString('{{ "foo\nbar"|indent(2) }}');
      expect(tmpl.render(), equals('foo\n  bar'));
      tmpl = env.fromString('{{ "foo\nbar"|indent(2, true) }}');
      expect(tmpl.render(), equals('  foo\n  bar'));
    });

    test('quote', () {
      var tmpl = env.fromString('{{ "foo"|quote }}');
      expect(tmpl.render(), equals('"foo"'));
    });

    test('increment', () {
      var tmpl = env.fromString('{{ 1|increment }}');
      expect(tmpl.render(), equals('2'));
    });

    test('round', () {
      var tmpl = env.fromString('{{ 4.51|round }}');
      expect(tmpl.render(), equals('5'));
      tmpl = env.fromString('{{ 4.51|round(1, "floor") }}');
      expect(tmpl.render(), equals('4.5'));
    });
  });

  group('Functional Filters', () {
    test('groupby', () {
      var data = {
        'items': [
          {'type': 'a', 'val': 1},
          {'type': 'b', 'val': 2},
          {'type': 'a', 'val': 3},
        ],
      };
      var tmpl = env
          .fromString('{% for key, list in items|groupby("type")|dictsort %}{{ key }}:{{ list|map(attribute="val")|join(",") }};{% endfor %}');
      expect(tmpl.render(data), equals('a:1,3;b:2;'));
    });

    test('select/reject', () {
      var tmpl = env.fromString('{{ [1, 2, 3, 4]|select("odd")|join(",") }}');
      expect(tmpl.render(), equals('1,3'));
      tmpl = env.fromString('{{ [1, 2, 3, 4]|reject("odd")|join(",") }}');
      expect(tmpl.render(), equals('2,4'));
    });

    test('selectattr', () {
      var data = {
        'users': [
          {'name': 'bob', 'active': true},
          {'name': 'alice', 'active': false},
        ],
      };
      // selectattr default test is 'defined', and false is defined.
      // Use 'true' test to filter by boolean truthiness.
      var tmpl = env.fromString('{{ users|selectattr("active", "true")|map(attribute="name")|join(",") }}');
      expect(tmpl.render(data), equals('bob'));
    });
  });

  group('Globals', () {
    test('cycler', () async {
      var tmpl = env.fromString('{% set c = cycler("a", "b") %}{{ c.next() }}{{ c.next() }}{{ c.next() }}');
      // Using .next() explicitly as .next property is not supported directly in Jinja syntax without () call usually,
      // but in Python/Jinja2 `cycler` object has a `next()` method.
      // Our implementation supports getAttribute('next') which returns the method.
      // However, the test output showed `[Error: Exception: The function c is null at []]` previously,
      // which implies `c.next` was resolved but `c.next()` failed or `c` itself was problematic.
      // Actually, cycler in defaults.dart returns a Cycler object.
      // In environment.dart getAttribute needs to handle Cycler.
      expect(await tmpl.renderAsync(), equals('aba'));
    });

    test('joiner', () async {
      var tmpl = env.fromString('{% set sep = joiner("|") %}{{ sep() }}a{{ sep() }}b{{ sep() }}c');
      // Joiner is a callable object.
      // Previous error: `Invalid callable: Instance of 'Joiner'`
      // We fixed this in Context.call by checking for .call method dynamically.
      expect(await tmpl.renderAsync(), equals('a|b|c'));
    });

    test('lipsum', () async {
      var tmpl = env.fromString('{{ lipsum(n=1, html=false, min=2, max=2) }}');
      var res = await tmpl.renderAsync();
      expect(res.split(' ').length, greaterThanOrEqualTo(2));
      expect(res.contains('<p>'), isFalse);
    });

    test('zip', () async {
      var tmpl = env.fromString('{% for a, b in zip([1, 2], ["a", "b"]) %}{{ a }}{{ b }}{% endfor %}');
      expect(await tmpl.renderAsync(), equals('1a2b'));
    });
  });

  group('Tests', () {
    test('match', () {
      var tmpl = env.fromString('{{ "foo" is match("^f") }}');
      expect(tmpl.render(), equals('true'));
      tmpl = env.fromString('{{ "bar" is match("^f") }}');
      expect(tmpl.render(), equals('false'));
    });

    test('version', () {
      var tmpl = env.fromString('{{ "1.2.0" is version("1.0.0", ">") }}');
      expect(tmpl.render(), equals('true'));
      tmpl = env.fromString('{{ "1.0.0" is version("1.2.0", "<") }}');
      expect(tmpl.render(), equals('true'));
      tmpl = env.fromString('{{ "1.0.0" is version("1.0.0", "==") }}');
      expect(tmpl.render(), equals('true'));
    });

    test('subsetof', () {
      var tmpl = env.fromString('{{ [1, 2] is subsetof([1, 2, 3]) }}');
      expect(tmpl.render(), equals('true'));
    });
  });

  group('Regex Filters', () {
    test('regex_replace', () {
      var tmpl = env.fromString('{{ "Hello World"|regex_replace("World", "Universe") }}');
      expect(tmpl.render(), equals('Hello Universe'));
    });

    test('regex_search', () {
      var tmpl = env.fromString('{{ "Hello World 123"|regex_search("\\d+") }}');
      expect(tmpl.render(), equals('123'));
    });

    test('regex_findall', () {
      var tmpl = env.fromString('{{ "abc 123 def 456"|regex_findall("\\d+")|join(",") }}');
      expect(tmpl.render(), equals('123,456'));
    });
  });

  group('Encoding', () {
    test('base64', () {
      var tmpl = env.fromString('{{ "foo"|base64encode }}');
      expect(tmpl.render(), equals('Zm9v'));
      tmpl = env.fromString('{{ "Zm9v"|base64decode }}');
      expect(tmpl.render(), equals('foo'));
    });

    test('fromjson', () {
      var tmpl = env.fromString('{{ \'{"a": 1}\'|fromjson|tojson }}');
      expect(tmpl.render(), equals('{"a":1}'));
    });
  });
}
