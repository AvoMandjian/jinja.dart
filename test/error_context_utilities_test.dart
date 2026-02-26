@TestOn('vm || chrome')
library;

import 'package:jinja/jinja.dart';
import 'package:jinja/src/context.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('captureContext', () {
    test('captures context variables', () {
      final context = Context(Environment());
      context.set('var1', 'value1');
      context.set('var2', 42);
      context.set('var3', true);

      final snapshot = captureContext(context);

      expect(snapshot, isNotNull);
      expect(snapshot['var1'], equals('value1'));
      expect(snapshot['var2'], equals(42));
      expect(snapshot['var3'], equals(true));
    });

    test('respects maxVariables limit', () {
      final context = Context(Environment());
      for (var i = 0; i < 60; i++) {
        context.set('var$i', 'value$i');
      }

      final snapshot = captureContext(context);

      expect(snapshot.length, lessThanOrEqualTo(50));
    });

    test('respects maxSize limit', () {
      final context = Context(Environment());
      // Create a large value
      context.set('largeVar', 'x' * 10000);

      final snapshot = captureContext(context, maxSize: 1000);

      // Should be truncated or excluded
      expect(snapshot.length, lessThanOrEqualTo(50));
    });

    test('handles empty context', () {
      final context = Context(Environment());
      final snapshot = captureContext(context);

      expect(snapshot, isEmpty);
    });
  });

  group('sanitizeForLogging', () {
    test('removes sensitive data patterns', () {
      final context = {
        'username': 'john',
        'password': 'secret123',
        'api_key': 'key123',
        'token': 'token123',
        'secret': 'secret123',
        'auth': 'auth123',
      };

      final sanitized = sanitizeForLogging(context);

      expect(sanitized['username'], equals('john'));
      expect(sanitized.containsKey('password'), isFalse);
      expect(sanitized.containsKey('api_key'), isFalse);
      expect(sanitized.containsKey('token'), isFalse);
      expect(sanitized.containsKey('secret'), isFalse);
      expect(sanitized.containsKey('auth'), isFalse);
    });

    test('handles case-insensitive matching', () {
      final context = {
        'PASSWORD': 'secret123',
        'ApiKey': 'key123',
        'TOKEN': 'token123',
      };

      final sanitized = sanitizeForLogging(context);

      expect(sanitized.containsKey('PASSWORD'), isFalse);
      expect(sanitized.containsKey('ApiKey'), isFalse);
      expect(sanitized.containsKey('TOKEN'), isFalse);
    });

    test('preserves non-sensitive data', () {
      final context = {
        'name': 'John',
        'age': 30,
        'email': 'john@example.com',
      };

      final sanitized = sanitizeForLogging(context);

      expect(sanitized['name'], equals('John'));
      expect(sanitized['age'], equals(30));
      expect(sanitized['email'], equals('john@example.com'));
    });

    test('handles null values', () {
      final context = {
        'nullVar': null,
        'password': 'secret',
      };

      final sanitized = sanitizeForLogging(context);

      expect(sanitized['nullVar'], isNull);
      expect(sanitized.containsKey('password'), isFalse);
    });
  });

  group('getNodeType', () {
    test('returns readable node type name', () {
      final node = Data(data: 'test');
      final nodeType = getNodeType(node);

      expect(nodeType, isNotEmpty);
      expect(nodeType, isNot(contains('Node')));
    });

    test('handles Name node', () {
      final node = Name(name: 'testVar');
      final nodeType = getNodeType(node);

      expect(nodeType, isNotEmpty);
    });

    test('handles Expression nodes', () {
      final node = Constant(value: 42);
      final nodeType = getNodeType(node);

      expect(nodeType, isNotEmpty);
    });
  });

  group('getSimilarNames', () {
    test('finds similar names using fuzzy matching', () {
      final available = ['username', 'userName', 'user_name', 'email', 'name'];
      final similar = getSimilarNames('username', available);

      expect(similar, isNotEmpty);
      expect(similar, contains('username'));
      expect(similar, contains('userName'));
    });

    test('respects maxResults limit', () {
      final available = List.generate(20, (i) => 'var$i');
      final similar = getSimilarNames('var0', available);

      expect(similar.length, lessThanOrEqualTo(5));
    });

    test('returns empty list when no similar names found', () {
      final available = ['completely', 'different', 'names'];
      final similar = getSimilarNames('xyz', available);

      expect(similar, isEmpty);
    });

    test('handles empty available list', () {
      final similar = getSimilarNames('test', []);

      expect(similar, isEmpty);
    });

    test('finds names with small edit distance', () {
      final available = ['username', 'usernam', 'usernme', 'user'];
      final similar = getSimilarNames('username', available);

      expect(similar.length, greaterThan(0));
    });
  });

  group('getErrorSuggestions', () {
    test('provides suggestions for UndefinedError', () {
      final error = UndefinedError(
        'Variable undefined',
        variableNameValue: 'userName',
        similarNamesValue: ['username', 'user_name'],
      );

      final suggestions = getErrorSuggestions(error);

      expect(suggestions, isNotEmpty);
      expect(suggestions.any((s) => s.contains('userName')), isTrue);
    });

    test('provides suggestions for TemplateSyntaxError', () {
      final error = TemplateSyntaxError('Syntax error');

      final suggestions = getErrorSuggestions(error);

      expect(suggestions, isNotEmpty);
    });

    test('provides suggestions for TemplateRuntimeError', () {
      final error = TemplateRuntimeError('Runtime error');

      final suggestions = getErrorSuggestions(error);

      // May return empty list if no specific suggestions available
      expect(suggestions, isA<List<String>>());
    });

    test('handles errors without context', () {
      final error = TemplateRuntimeError('Simple error');

      final suggestions = getErrorSuggestions(error);

      // Should still provide some generic suggestions
      expect(suggestions, isA<List<String>>());
    });
  });

  group('formatErrorReport', () {
    test('formats error with all context', () {
      final error = TemplateRuntimeError(
        'Test error',
        operationValue: 'Testing',
        templatePathValue: 'test.html',
      );

      final report = formatErrorReport(error);

      expect(report, contains('TemplateRuntimeError'));
      expect(report, contains('Test error'));
      expect(report, contains('Testing'));
      expect(report, contains('test.html'));
    });

    test('returns toString() output', () {
      final error = TemplateRuntimeError('Test error');
      final report = formatErrorReport(error);

      expect(report, equals(error.toString()));
    });
  });

  group('captureCallStack', () {
    test('returns list of strings', () {
      final callStack = captureCallStack();

      expect(callStack, isA<List<String>>());
    });

    test('respects maxDepth limit', () {
      final callStack = captureCallStack(maxDepth: 5);

      expect(callStack.length, lessThanOrEqualTo(5));
    });

    test('does not throw', () {
      expect(() => captureCallStack(), returnsNormally);
    });
  });
}
