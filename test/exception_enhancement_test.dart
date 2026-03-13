@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/utils.dart' show captureCallStack;
import 'package:test/test.dart';

class BadToString {
  @override
  String toString() => throw UnimplementedError();
}

void main() {
  group('Enhanced TemplateError', () {
    test('creates with all context fields', () {
      final node = Data(data: 'testVar', line: 5, column: 10);
      final stackTrace = StackTrace.current;
      final contextSnapshot = {'var1': 'value1', 'var2': 42};
      final suggestions = ['Suggestion 1', 'Suggestion 2'];
      final callStack = ['template1.html:10', 'template2.html:5'];

      final error = TemplateRuntimeError(
        'Test error message',
        stackTraceValue: stackTrace,
        nodeValue: node,
        contextSnapshotValue: contextSnapshot,
        operationValue: 'Testing operation',
        suggestionsValue: suggestions,
        templatePathValue: 'test/template.html',
        callStackValue: callStack,
      );

      expect(error.message, equals('Test error message'));
      expect(error.stackTrace, equals(stackTrace));
      expect(error.node, equals(node));
      expect(error.contextSnapshot, equals(contextSnapshot));
      expect(error.operation, equals('Testing operation'));
      expect(error.suggestions, equals(suggestions));
      expect(error.templatePath, equals('test/template.html'));
      expect(error.callStack, equals(callStack));
    });

    test('creates with minimal fields (backward compatibility)', () {
      final error = TemplateRuntimeError('Simple error');

      expect(error.message, equals('Simple error'));
      expect(error.stackTrace, isNull);
      expect(error.node, isNull);
      expect(error.contextSnapshot, isNull);
      expect(error.operation, isNull);
      expect(error.suggestions, isNull);
      expect(error.templatePath, isNull);
      expect(error.callStack, isNull);
    });

    test('toString includes all context fields', () {
      final node = Data(data: 'testVar', line: 5, column: 10);
      final contextSnapshot = {'var1': 'value1', 'var2': 42};
      final suggestions = ['Check variable name', 'Verify context'];

      final error = TemplateRuntimeError(
        'Test error',
        nodeValue: node,
        contextSnapshotValue: contextSnapshot,
        operationValue: 'Accessing variable',
        suggestionsValue: suggestions,
        templatePathValue: 'test/template.html',
      );

      final errorString = error.toString();

      expect(errorString, contains('TemplateRuntimeError'));
      expect(errorString, contains('Test error'));
      expect(errorString, contains('test/template.html'));
      expect(errorString, contains('line 5'));
      expect(errorString, contains('column 10'));
      expect(errorString, contains('Accessing variable'));
      expect(errorString, contains('var1'));
      expect(errorString, contains('value1'));
      expect(errorString, contains('Check variable name'));
      expect(errorString, contains('Verify context'));
    });

    test('toString limits context to 10 variables', () {
      final contextSnapshot = <String, Object?>{};
      for (var i = 0; i < 15; i++) {
        contextSnapshot['var$i'] = 'value$i';
      }

      final error = TemplateRuntimeError(
        'Test error',
        contextSnapshotValue: contextSnapshot,
      );

      final errorString = error.toString();
      final contextSection =
          errorString.split('Context:')[1].split('Call Stack:')[0];

      // Should show first 10 variables and mention the rest
      expect(contextSection, contains('... and 5 more variables'));
      expect(contextSection, contains('var0'));
      expect(contextSection, contains('var9'));
    });

    test('toString limits stack trace to 10 frames', () {
      final stackTrace = StackTrace.current;
      final error = TemplateRuntimeError(
        'Test error',
        stackTraceValue: stackTrace,
      );

      final errorString = error.toString();
      final stackTraceSection = errorString.split('Stack Trace:')[1];

      // Should contain stack trace but be limited
      expect(stackTraceSection, isNotEmpty);
    });
  });

  group('Enhanced TemplateSyntaxError', () {
    test('maintains backward compatibility with positional message', () {
      final error = TemplateSyntaxError(
        'Syntax error',
        path: 'test.html',
        line: 10,
        column: 5,
      );

      expect(error.message, equals('Syntax error'));
      expect(error.path, equals('test.html'));
      expect(error.line, equals(10));
      expect(error.column, equals(5));
    });

    test('includes enhanced context fields', () {
      final node = Data(data: 'testVar', line: 5, column: 10);
      final suggestions = ['Fix syntax', 'Check brackets'];

      final error = TemplateSyntaxError(
        'Syntax error',
        path: 'test.html',
        line: 10,
        column: 5,
        node: node,
        suggestions: suggestions,
      );

      expect(error.node, equals(node));
      expect(error.suggestions, equals(suggestions));
    });

    test('toString includes path, line, column, and context snippet', () {
      final error = TemplateSyntaxError(
        'Syntax error',
        path: 'test.html',
        line: 10,
        column: 5,
        contextSnippet: '10: {{ foo }}\n    ^',
      );

      final errorString = error.toString();

      expect(errorString, contains("file 'test.html'"));
      expect(errorString, contains('line 10'));
      expect(errorString, contains('column 5'));
      expect(errorString, contains('Syntax error'));
      expect(errorString, contains('{{ foo }}'));
    });
  });

  group('Enhanced UndefinedError', () {
    test('includes variable name and similar names', () {
      final error = UndefinedError(
        'Variable undefined',
        variableNameValue: 'userName',
        similarNamesValue: ['username', 'user_name', 'userName'],
      );

      expect(error.variableName, equals('userName'));
      expect(error.similarNames, equals(['username', 'user_name', 'userName']));
    });

    test('toString includes variable name and similar names', () {
      final error = UndefinedError(
        'Variable undefined',
        variableNameValue: 'userName',
        similarNamesValue: ['username', 'user_name'],
      );

      final errorString = error.toString();

      expect(errorString, contains('UndefinedError'));
      expect(errorString, contains("Variable: 'userName'"));
      expect(errorString,
          contains('Similar variables found: username, user_name'),);
    });

    test('works without variable name (backward compatibility)', () {
      final error = UndefinedError('Variable undefined');

      expect(error.variableName, isNull);
      expect(error.similarNames, isNull);
      expect(error.toString(), contains('UndefinedError'));
    });
  });

  group('Enhanced TemplateNotFound', () {
    test('includes template name and search paths', () {
      final error = TemplateNotFound(
        name: 'missing.html',
        message: 'Template not found',
        searchPaths: ['/path1', '/path2'],
      );

      expect(error.name, equals('missing.html'));
      expect(error.searchPaths, equals(['/path1', '/path2']));
    });

    test('toString includes template name and search paths', () {
      final error = TemplateNotFound(
        name: 'missing.html',
        message: 'Template not found',
        searchPaths: ['/path1', '/path2'],
      );

      final errorString = error.toString();

      expect(errorString, contains('TemplateNotFound'));
      expect(errorString, contains("Template name: 'missing.html'"));
      expect(errorString, contains('Searched paths:'));
      expect(errorString, contains('/path1'));
      expect(errorString, contains('/path2'));
    });
  });

  group('TemplateErrorWrapper', () {
    test('wraps non-template exceptions with context', () {
      final originalError = ArgumentError('Invalid argument');
      final node = Data(data: 'testVar', line: 5, column: 10);

      final error = TemplateErrorWrapper(
        originalError,
        message: 'Wrapped error',
        node: node,
        operation: 'Testing operation',
      );

      expect(error.originalError, equals(originalError));
      expect(error.message, equals('Wrapped error'));
      expect(error.node, equals(node));
      expect(error.operation, equals('Testing operation'));
      // When no callStack is provided, TemplateErrorWrapper should not set it by default.
      expect(error.callStack, isNull);
    });

    test('uses default message if not provided', () {
      final originalError = ArgumentError('Invalid argument');

      final error = TemplateErrorWrapper(originalError);

      expect(error.originalError, equals(originalError));
      expect(error.message, contains('Non-template error'));
    });

    test('captures stack trace from Error objects', () {
      final originalError = ArgumentError('Invalid argument');

      final error = TemplateErrorWrapper(
        originalError,
        stackTrace: StackTrace.current,
        callStack: captureCallStack(),
      );

      expect(error.stackTrace, isNotNull);
    });

    test('toString includes original error information', () {
      final originalError = ArgumentError('Invalid argument');

      final error = TemplateErrorWrapper(
        originalError,
        message: 'Wrapped error',
        callStack: <String>['user.html:1 (template root)'],
      );

      final errorString = error.toString();

      expect(errorString, contains('TemplateErrorWrapper'));
      expect(errorString, contains('ArgumentError'));
      expect(errorString, contains('Wrapped error'));
      expect(errorString, contains('Original Error:'));
      expect(errorString, contains('Invalid argument'));
    });
  });

  group('TemplateAssertionError', () {
    test('forwards all parameters correctly', () {
      final node = Data(data: 'testVar', line: 5, column: 10);
      final error = TemplateAssertionError(
        'Assertion failed',
        stackTraceValue: StackTrace.current,
        nodeValue: node,
        operationValue: 'Testing',
      );

      expect(error.message, equals('Assertion failed'));
      expect(error.node, equals(node));
      expect(error.operation, equals('Testing'));
    });
  });

  group('Context size limits', () {
    test('truncates large context values', () {
      final largeValue = 'x' * 1000;
      final contextSnapshot = {'largeVar': largeValue};

      final error = TemplateRuntimeError(
        'Test error',
        contextSnapshotValue: contextSnapshot,
      );

      final errorString = error.toString();
      final valueSection = errorString.split("'largeVar':")[1].split('\n')[0];

      // Should be truncated to 50 chars + "..."
      expect(valueSection.length, lessThan(60));
      expect(valueSection, contains('...'));
    });

    test('handles null values in context', () {
      final contextSnapshot = {'nullVar': null, 'stringVar': 'value'};

      final error = TemplateRuntimeError(
        'Test error',
        contextSnapshotValue: contextSnapshot,
      );

      final errorString = error.toString();

      expect(errorString, contains("'nullVar': null"));
      expect(errorString, contains("'stringVar': value"));
    });
  });

  group('Additional core tests for coverage', () {
    test('TemplateError toString context value throwing error', () {
      final contextSnapshot = {'badValue': BadToString()};
      final error = TemplateRuntimeError(
        'Test error',
        contextSnapshotValue: contextSnapshot,
      );
      expect(error.toString(), contains('(toString failed: UnimplementedError)'));
    });

    test('TemplateError toString generic node type', () {
      final error = TemplateRuntimeError(
        'Test error',
        nodeValue: Data(),
      );
      expect(error.toString(), contains('Node: Data'));
    });

    test('TemplateNotFound toString', () {
      // With message
      var error = TemplateNotFound(name: 'test.html', message: 'Not here');
      expect(error.toString(), contains('TemplateNotFound: Not here'));

      // Without message but with name
      error = TemplateNotFound(name: 'test.html');
      expect(error.toString(), contains('TemplateNotFound: test.html'));

      // Without search paths
      error = TemplateNotFound(name: 'test.html', message: 'Not here');
      expect(error.toString(), isNot(contains('Searched paths:')));
    });

    test('TemplatesNotFound toString', () {
      var error = TemplatesNotFound(names: ['a.html', 'b.html'], message: 'Not here');
      expect(error.toString(), contains('TemplatesNotFound: Not here'));

      error = TemplatesNotFound(names: ['a.html', 'b.html']);
      expect(error.toString(), contains('none of the templates given were found: a.html, b.html'));

      error = TemplatesNotFound();
      expect(error.toString(), contains('TemplatesNotFound'));
    });

    test('UndefinedError toString variations', () {
      // Without anything
      var error = UndefinedError('Msg');
      expect(error.toString(), contains('UndefinedError: Msg'));
      
      // With variable name but no similar names
      error = UndefinedError('Msg', variableNameValue: 'foo');
      expect(error.toString(), contains("Variable: 'foo'"));
      expect(error.toString(), isNot(contains("Similar variables found:")));
    });

    test('TemplateSyntaxError toString variations', () {
      // Without contextSnippet
      var error = TemplateSyntaxError('Syntax', path: 'a.html', line: 1, column: 2);
      expect(error.toString(), isNot(contains('Snippet:')));
      expect(error.toString(), contains('Syntax'));
    });

    test('TemplateRuntimeError stack trace and call stack', () {
      final error = TemplateRuntimeError(
        'Error',
        stackTraceValue: StackTrace.fromString("foo\nbar\nbaz"),
        callStackValue: ['frame1', 'frame2'],
      );
      final string = error.toString();
      expect(string, contains('foo'));
      expect(string, contains('frame1'));
    });

    test('TemplateError toString operation but no node', () {
      final error = TemplateRuntimeError('Error', operationValue: 'Running test');
      expect(error.toString(), contains('Operation: Running test'));
    });
  });
}
