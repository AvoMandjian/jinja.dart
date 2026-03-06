import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

/// Test record definition for standardized table-driven tests
typedef RenderTestCase<T> = ({
  String name,
  String template,
  Map<String, Object?> data,
  T expected,
});

/// Reusable immutable test environment suitable for tests
/// that do not mutate globals or loaders.
final Environment sharedTestEnv = Environment();

/// Creates a fresh test environment, useful for tests that need to
/// mutate the loader, globals, or filters, avoiding cross-test pollution.
Environment createTestEnv({
  Map<String, Object?>? globals,
  Map<String, Function>? filters,
  Loader? loader,
}) {
  final env = Environment(
    globals: globals ?? {},
    loader: loader,
  );
  if (filters != null) {
    env.filters.addAll(filters);
  }
  return env;
}

/// A lightweight top-level matcher for verifying TemplateError messages.
/// [messagePattern] can be a Pattern or a Matcher (e.g. `contains('...')`).
Matcher throwsTemplateError(dynamic messagePattern) => throwsA(
      isA<TemplateError>().having(
        (e) => e.message,
        'message',
        wrapMatcher(messagePattern),
      ),
    );

/// A lightweight top-level matcher for verifying TemplateRuntimeError messages specifically.
Matcher throwsTemplateRuntimeError(dynamic messagePattern) => throwsA(
      isA<TemplateRuntimeError>().having(
        (e) => e.message,
        'message',
        wrapMatcher(messagePattern),
      ),
    );

/// A lightweight top-level matcher for verifying TemplateSyntaxError messages specifically.
Matcher throwsTemplateSyntaxError(dynamic messagePattern) => throwsA(
      isA<TemplateSyntaxError>().having(
        (e) => e.message,
        'message',
        wrapMatcher(messagePattern),
      ),
    );
