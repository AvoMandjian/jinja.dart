import 'package:jinja/src/environment.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/loaders.dart';
import 'package:jinja/src/renderer.dart';
import 'package:jinja/src/runtime.dart';
import 'package:jinja/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('Environment Coverage Extensions', () {
    test('newLine validation', () {
      expect(() => Environment(), returnsNormally);
      expect(() => Environment(newLine: '\r'), returnsNormally);
      expect(() => Environment(newLine: '\r\n'), returnsNormally);
      expect(() => Environment(newLine: ' '), throwsArgumentError);
    });

    test('getTemplate and listTemplates without loader', () {
      final env = Environment();
      expect(
          () => env.getTemplate('foo'),
          throwsA(isA<TemplateRuntimeError>().having(
              (e) => e.message,
              'message',
              contains('No loader for this environment specified'))));
      expect(() => env.listTemplates(), throwsStateError);
    });

    test('selectTemplate', () {
      final env =
          Environment(loader: MapLoader({'a.html': 'A'}, globalJinjaData: {}));

      // Empty list
      expect(
          () => env.selectTemplate([]),
          throwsA(isA<TemplatesNotFound>()
              .having((e) => e.message, 'message', contains('empty list'))));

      // Selection by String
      expect(env.selectTemplate(['missing.html', 'a.html']).path,
          equals('a.html'));

      // Selection by Template object
      final tmpl = env.fromString('B');
      expect(env.selectTemplate(['missing.html', tmpl]), equals(tmpl));

      // All missing
      expect(() => env.selectTemplate(['missing1.html', 'missing2.html']),
          throwsA(isA<TemplatesNotFound>()));
    });

    test('DefaultJinjaLogger', () {
      const logger = DefaultJinjaLogger();
      // These call log() from dart:developer, we just verify they don't crash in test environment
      expect(() => logger.debug('test'), returnsNormally);
      expect(() => logger.info('test'), returnsNormally);
      expect(() => logger.warn('test'), returnsNormally);
      expect(() => logger.error('test', 'err', StackTrace.current),
          returnsNormally);
    });

    test('wrapFinalizer with different types', () {
      final env = Environment();
      final context = StringSinkRenderContext(env, StringBuffer());

      // ContextFinalizer
      Object? cf(Context c, Object? v) => '[$v]';
      final wrappedCf = Environment.wrapFinalizer(cf);
      expect(wrappedCf(context, 'x'), equals('[x]'));

      // EnvironmentFinalizer
      Object? ef(Environment e, Object? v) => '{$v}';
      final wrappedEf = Environment.wrapFinalizer(ef);
      expect(wrappedEf(context, 'y'), equals('{y}'));

      // Finalizer
      Object? f(Object? v) => '<$v>';
      final wrappedF = Environment.wrapFinalizer(f);
      expect(wrappedF(context, 'z'), equals('<z>'));
    });

    test('passContext and passEnvironment', () {
      Object func() => 'hi';
      expect(passContext(func), isA<ContextFilter>());
      expect(passEnvironment(func), isA<EnvFilter>());
    });
  });
}
