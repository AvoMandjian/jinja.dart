import 'package:jinja/src/environment.dart';
import 'package:jinja/src/runtime.dart';
import 'package:test/test.dart';

class CallableObject {
  Object? call(Object? arg, {Object? named}) {
    return 'called with $arg and $named';
  }
}

// A class that has a call property that is a function
class CallableProperty {
  final Function call;
  CallableProperty(this.call);
}

void main() {
  final env = Environment();

  group('Environment Coverage Extensions 4', () {
    test('callCommon with callable object', () {
      // In environment.dart:437, it uses Function.apply(function as dynamic, ...)
      // This works for function objects (closures) but for classes with call(),
      // you need to pass the .call method if using Function.apply.
      // However, if the code does Function.apply(obj as dynamic),
      // Dart VM might only allow it if obj is a Function.

      // Let's use a closure that mimics a callable object
      String callable(Object? arg, {Object? named}) => 'called with $arg and $named';
      final context = Context(env);
      final result = env.callCommon(callable, ['arg1'], {#named: 'val1'}, context);
      expect(result, equals('called with arg1 and val1'));
    });

    test('callCommon with packed macro call (named args coverage)', () {
      // This aims to cover lines 408-411 and 415-420
      // We need a macro function that accepts (positional, named)
      Object? macroFunc(List<Object?> pos, Map<Object?, Object?> named) {
        return 'pos: $pos, named: $named';
      }

      final context = Context(env);
      // Packed calling convention: positional = [positionalArgsList, namedKwargsMap]
      final result = env.callCommon(
        macroFunc,
        [
          ['p1'],
          {'n1': 'v1'}
        ],
        {#unused: 'should_be_in_macroNamed'}, // This should trigger 409-411
        context,
      );

      expect(result, contains('pos: [p1]'));
      expect(result, contains('n1: v1'));
      expect(result, contains('Symbol("unused"): should_be_in_macroNamed'));
    });

    test('callTest catch block', () {
      final myEnv = Environment();
      // Test that throws non-TemplateError
      myEnv.tests['throwing_test'] = (Object? val) => throw Exception('Generic failure');

      expect(
        () => myEnv.callTest('throwing_test', [123]),
        throwsA(predicate((e) => e.toString().contains('Generic failure'))),
      );
    });

    test('Environment convenience methods', () {
      expect(env.match('foo', 'f.*'), isTrue);
      expect(env.match('bar', 'f.*'), isFalse);

      expect(env.search('foobar', 'ba.'), isTrue);
      expect(env.search('foobar', 'zx.'), isFalse);

      expect(env.subsetOf([1, 2], [1, 2, 3]), isTrue);
      expect(env.subsetOf([1, 4], [1, 2, 3]), isFalse);

      expect(env.supersetOf([1, 2, 3], [1, 2]), isTrue);
      expect(env.supersetOf([1, 2], [1, 2, 3]), isFalse);

      expect(env.version('1.2.3', '1.2.0', '>'), isTrue);
      expect(env.version('1.2.3', '2.0.0', '>'), isFalse);
    });
  });
}
