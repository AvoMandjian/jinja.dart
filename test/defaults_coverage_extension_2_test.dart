import 'package:jinja/src/defaults.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/runtime.dart';
import 'package:test/test.dart';

void main() {
  group('defaults.dart Coverage Extensions 2', () {
    test('getAttribute with LoopContext', () {
      final loop = LoopContext([1, 2], 0, (it, [d = 0]) => '');
      loop.iterator.moveNext(); // Move to first element
      expect(getAttribute('index', loop), equals(1));
    });

    test('getAttribute with Namespace', () {
      final ns = Namespace({'a': 1});
      expect(getAttribute('a', ns), equals(1));
    });

    test('getAttribute unknown attribute on List/Cycler', () {
      expect(() => getAttribute('bad', []), throwsA(isA<UndefinedError>()));
      expect(() => getAttribute('bad', Cycler([])),
          throwsA(isA<UndefinedError>()));
    });

    test('dict invalid arguments', () {
      // Not a Map or Iterable
      expect(
          () => dict([42]),
          throwsA(isA<TemplateRuntimeError>().having((e) => e.message,
              'message', contains('must be a map or iterable'))));

      // Iterable containing invalid item (not length 2 list or MapEntry)
      expect(
        () => dict([
          [1, 2, 3],
        ]),
        throwsA(isA<TemplateRuntimeError>().having((e) => e.message, 'message',
            contains('must be a map or iterable of pairs'))),
      );
    });

    test('dict merging multiple maps', () {
      final m1 = {'a': 1};
      final m2 = {'b': 2, 'a': 3};
      expect(dict([m1, m2]), equals({'a': 3, 'b': 2}));
    });

    test('Joiner coverage', () {
      final joiner = makeJoiner();
      expect(joiner(), equals('')); // first call empty
      expect(joiner(), equals(', ')); // subsequent calls separator

      final joinerCustom = makeJoiner(' | ');
      expect(joinerCustom(), equals(''));
      expect(joinerCustom(), equals(' | '));
    });
  });
}
