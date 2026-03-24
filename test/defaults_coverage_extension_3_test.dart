import 'package:jinja/src/defaults.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/runtime.dart';
import 'package:test/test.dart';

void main() {
  group('defaults.dart Coverage Extensions 3', () {
    test('getItem with MapEntry', () {
      final entry = MapEntry('key', 'value');
      expect(getItem(0, entry), equals('key'));
      expect(getItem(1, entry), equals('value'));
      expect(
        () => getItem(2, entry),
        throwsA(isA<UndefinedError>().having((e) => e.message, 'message',
            contains('MapEntry index must be 0 or 1'))),
      );
    });

    test('getItem with LoopContext and Namespace', () {
      final loop = LoopContext([1], 0, (it, [d = 0]) => '');
      // LoopContext[key] expects String key
      expect(loop['length'], equals(1));
      expect(getItem('length', loop), equals(1));

      final ns = Namespace({'a': 1});
      expect(getItem('a', ns), equals(1));
    });

    test('getItem unsupported type error', () {
      expect(
        () => getItem('key', 42),
        throwsA(isA<TemplateRuntimeError>().having((e) => e.message, 'message',
            contains('Cannot access item on object of type `int`'))),
      );
    });

    test('Cycler methods', () {
      final cycler = Cycler(['a', 'b']);
      expect(cycler.current, equals('a'));
      expect(cycler(), equals('a')); // call() returns current and moves next
      expect(cycler.current, equals('b'));
      expect(
          cycler.next(), equals('b')); // next() returns current and moves next
      expect(cycler.current, equals('a'));

      cycler.reset();
      expect(cycler.current, equals('a'));

      expect(cycler.toString(), contains('Cycler'));
    });

    test('Empty Cycler', () {
      final cycler = Cycler([]);
      expect(cycler.current, isNull);
      expect(cycler.next(), isNull);
      expect(cycler(), isNull);
    });

    test('makeCycler', () {
      final cycler = makeCycler(1, 2);
      expect(cycler.values, equals([1, 2]));
    });
  });
}
