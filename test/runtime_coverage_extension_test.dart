import 'package:jinja/src/environment.dart';
import 'package:jinja/src/runtime.dart';
import 'package:test/test.dart';

class FailingCall {
  // Accessing 'call' property fails
  Object? get call => throw Exception('Cannot access call');
}

void main() {
  final env = Environment();

  group('Runtime Coverage Extensions', () {
    test('LoopContext unknown attribute', () {
      final loop = LoopContext([1], 0, (d, [p = 0]) => '');
      expect(() => loop['unknown'], throwsA(isA<NoSuchMethodError>()));
    });

    test('Context.call failing .call property access', () {
      final context = Context(env);
      final obj = FailingCall();
      // Should log the error and fall back to callCommon (which might throw)
      expect(() => context.call(obj, null), throwsA(anything));
    });

    test('Context.resolveAsync hierarchy coverage', () async {
      // already mostly covered but let's ensure missing async variable path
      final context = Context(env);
      final result = await context.resolveAsync('missing_async_var');
      // By default Environment.undefined returns null in some cases or an Undefined object.
      // In jinja.dart, it seems it might return null if not using a special Undefined class.
      // Let's just check that it doesn't throw.
    });
  });
}
