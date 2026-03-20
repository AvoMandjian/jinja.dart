import 'package:jinja/src/exceptions.dart';
import 'package:test/test.dart';

class ThrowingToString {
  @override
  String toString() {
    throw Exception('toString failure');
  }
}

void main() {
  group('TemplateError Coverage Extensions 3', () {
    test('TemplateError.toString with many features', () {
      // Test both TemplateRuntimeError (uses base toString) and TemplateSyntaxError (has its own)
      final errors = [
        TemplateRuntimeError(
          'Runtime message',
          operationValue: 'Some operation',
          suggestionsValue: ['Suggestion 1', 'Suggestion 2'],
          contextSnapshotValue: {
            'throwing': ThrowingToString(),
            'long': 'a' * 60,
            for (var i = 0; i < 12; i++) 'var$i': 'value$i',
          },
          callStackValue: List.generate(12, (i) => 'frame$i'),
          stackTraceValue: StackTrace.fromString('line1\nline2\nline3\nline4\nline5\nline6\nline7\nline8\nline9\nline10\nline11\nline12'),
        ),
        TemplateSyntaxError(
          'Syntax message',
          path: 'template.j2',
          line: 1,
          column: 5,
          operation: 'Parsing something',
          suggestions: ['Syntax suggestion'],
          contextSnapshot: {
            'var1': 'val1',
            for (var i = 0; i < 12; i++) 'svar$i': 'svalue$i',
          },
          callStack: ['frame1'],
          stackTrace: StackTrace.fromString('line1\nline2\nline3\nline4\nline5\nline6\nline7\nline8\nline9\nline10\nline11\nline12'),
        ),
      ];

      for (final error in errors) {
        final str = error.toString();
        expect(str, contains(error is TemplateSyntaxError ? 'Syntax message' : 'Runtime message'));
        expect(str, contains('Operation:'));
        expect(str, contains('Suggestions:'));
        expect(str, contains('Context:'));
        expect(str, contains('Stack Trace:'));

        if (error is TemplateSyntaxError) {
          expect(str, contains('file \'template.j2\''));
          expect(str, contains('line 1, column 5'));
        }
      }
    });

    test('TemplateAssertionError.toString', () {
      final error = TemplateAssertionError(
        'Assertion failed',
        operationValue: 'Testing assertion',
      );
      expect(error.toString(), contains('Assertion failed'));
      expect(error.toString(), contains('Operation: Testing assertion'));
    });

    test('UndefinedError.toString variations', () {
      // Trigger line 531: baseString doesn't start with UndefinedError:
      // This happens if message is null
      final error = UndefinedError(
        null,
        variableNameValue: 'v',
        similarNamesValue: ['s'],
      );
      final str = error.toString();
      expect(str, startsWith('UndefinedError'));
      expect(str, contains('Variable: \'v\''));
      expect(str, contains('Similar variables found: s'));
    });

    test('TemplateErrorWrapper.toString variations', () {
      // Trigger line 587: baseString doesn't start with TemplateErrorWrapper:
      // This happens if message is null
      final error = TemplateErrorWrapper(
        Exception('Original'),
      );
      final str = error.toString();
      expect(str, startsWith('TemplateErrorWrapper: _Exception'));
      expect(str, contains('Original Error: Exception: Original'));
    });
  });
}
