// ignore_for_file: avoid_print

import 'package:jinja/jinja.dart';
import 'package:jinja/src/error_logger.dart';

void main() {
  try {
    // ========== ENHANCED ERROR MESSAGES (NO ERRORLOGGER) ==========

    // Example 1: Enhanced Error Messages (No ErrorLogger)
    print('\n=== Example 1: Enhanced Error Messages (No ErrorLogger) ===');
    var env1 = Environment();
    var template1 = env1.fromString('{{ user.name }}', path: 'example.html');

    try {
      template1.render({'user': null});
    } catch (e) {
      print('Enhanced error includes context, location, and suggestions:');
      print(e.toString());
    }

    // Example 2: Undefined Variable Error
    print('\n=== Example 2: Undefined Variable Error ===');
    var env2 = Environment();
    var template2 = env2.fromString('{{ userName }}', path: 'example.html');

    try {
      template2.render({
        'user_name': 'Alice',
        'users': ['Bob'],
      });
    } catch (e) {
      print('Error shows similar variable names and suggestions:');
      print(e.toString());
    }

    // Example 3: Attribute Access on Null
    print('\n=== Example 3: Attribute Access on Null ===');
    var env3 = Environment();
    var template3 = env3.fromString('{{ user.name }}', path: 'example.html');

    try {
      template3.render({
        'user': null,
        'users': ['Alice', 'Bob'],
      });
    } catch (e) {
      print('Error includes null check suggestions:');
      print(e.toString());
    }

    // Example 4: Filter Not Found Error
    print('\n=== Example 4: Filter Not Found Error ===');
    var env4 = Environment();
    var template4 =
        env4.fromString('{{ text|uppercase }}', path: 'example.html');

    try {
      template4.render({'text': 'hello'});
    } catch (e) {
      print('Error shows similar filter names (should suggest "upper"):');
      print(e.toString());
    }

    // Example 5: Syntax Error
    print('\n=== Example 5: Syntax Error ===');
    var env5 = Environment();

    try {
      env5.fromString('{% if condition %}', path: 'example.html');
    } catch (e) {
      print('Syntax error includes context snippet and suggestions:');
      print(e.toString());
    }

    // ========== ERRORLOGGER WITH DIFFERENT LOG LEVELS ==========

    // Example 6: ErrorLogger with Error Level
    print('\n=== Example 6: ErrorLogger with Error Level ===');
    var errorLogger6 = ErrorLogger();
    var env6 = Environment();

    var template6 =
        env6.fromString('{{ undefinedVariable }}', path: 'example.html');
    try {
      template6.render({'otherVar': 'value'});
    } catch (e) {
      print('Error occurred, manually logging with ErrorLogger:');
      errorLogger6.logError(
        'Template rendering failed',
        error: e,
        context: {'template': 'example.html', 'variable': 'undefinedVariable'},
      );
    }

    // Example 7: ErrorLogger with Warning Level
    print('\n=== Example 7: ErrorLogger with Warning Level ===');
    var errorLogger7 = ErrorLogger(level: LogLevel.warning);
    errorLogger7.logWarning(
      'Deprecated filter usage detected',
      context: {'filter': 'oldFilter', 'recommended': 'newFilter'},
    );
    print('Warning logged (warning level enabled)');

    // Example 8: ErrorLogger with Info Level
    print('\n=== Example 8: ErrorLogger with Info Level ===');
    var errorLogger8 = ErrorLogger(level: LogLevel.info);
    errorLogger8.logInfo(
      'Template rendered successfully',
      context: {'template': 'example.html', 'renderTime': '50ms'},
    );
    print('Info logged (info level enabled)');

    // Example 9: ErrorLogger with Debug Level
    print('\n=== Example 9: ErrorLogger with Debug Level ===');
    var errorLogger9 = ErrorLogger(level: LogLevel.debug);
    errorLogger9.logDebug(
      'Variable resolution details',
      context: {'variable': 'user', 'value': 'Alice', 'source': 'context'},
    );
    print('Debug logged (debug level enabled)');

    // Example 10: ErrorLogger Disabled (None Level)
    print('\n=== Example 10: ErrorLogger Disabled (None Level) ===');
    var errorLogger10 = ErrorLogger(level: LogLevel.none);
    var env10 = Environment();
    var template10 =
        env10.fromString('{{ undefinedVar }}', path: 'example.html');

    try {
      template10.render({});
    } catch (e) {
      print('Error occurred but ErrorLogger is disabled:');
      errorLogger10.logError('This should not be logged', error: e);
      print('ErrorLogger did not log (level is none)');
      print('But error is still thrown: ${e.runtimeType}');
    }

    // ========== MANUAL ERROR LOGGING ==========

    // Example 11: Manual Error Logging with Context
    print('\n=== Example 11: Manual Error Logging with Context ===');
    var errorLogger11 = ErrorLogger();
    var env11 = Environment();
    var template11 = env11.fromString('{{ user.name }}', path: 'example.html');

    try {
      template11.render({'user': null});
    } catch (e, stackTrace) {
      errorLogger11.logError(
        'Failed to render template',
        error: e,
        context: {
          'template': 'example.html',
          'user': null,
          'availableVariables': ['users', 'userList'],
        },
        stackTrace: stackTrace,
      );
      print('Error logged with full context and stack trace');
    }

    // Example 12: Manual Warning Logging
    print('\n=== Example 12: Manual Warning Logging ===');
    var errorLogger12 = ErrorLogger(level: LogLevel.warning);
    errorLogger12.logWarning(
      'Using deprecated template syntax',
      context: {
        'template': 'legacy.html',
        'line': 5,
        'deprecated': '{% oldtag %}',
        'recommended': '{% newtag %}',
      },
    );
    print('Warning logged with context');

    // ========== SENSITIVE DATA SANITIZATION ==========

    // Example 13: Sensitive Data Sanitization
    print('\n=== Example 13: Sensitive Data Sanitization ===');
    var env13 = Environment();
    var template13 = env13.fromString('{{ user.name }}', path: 'example.html');

    try {
      template13.render({
        'user': null,
        'password': 'secret123',
        'api_key': 'key12345',
        'auth_token': 'token123',
        'secret': 'mysecret',
      });
    } catch (e) {
      print(
          'Error context excludes sensitive data (password, api_key, auth_token, secret):');
      final errorStr = e.toString();
      // Check that sensitive data is not in error message
      if (!errorStr.contains('secret123') &&
          !errorStr.contains('key12345') &&
          !errorStr.contains('token123') &&
          !errorStr.contains('mysecret')) {
        print('✓ Sensitive data successfully excluded from error context');
      } else {
        print('⚠ Sensitive data may be present in error context');
      }
      print('Error message (first 500 chars):');
      print(errorStr.length > 500
          ? '${errorStr.substring(0, 500)}...'
          : errorStr);
    }

    // ========== ERRORS IN MACROS AND INCLUDES ==========

    // Example 14: Error in Macro
    print('\n=== Example 14: Error in Macro ===');
    var loader14 = MapLoader(
      {
        'macros.html': '''
{% macro render_user(user) %}
  <div>{{ user.name }} - {{ user.age }}</div>
{% endmacro %}
''',
      },
      globalJinjaData: {},
    );
    var env14 = Environment(loader: loader14);
    var template14 = env14.fromString(
      '''
{% import "macros.html" as macros %}
{{ macros.render_user(undefinedUser) }}
''',
      path: 'main.html',
    );

    try {
      template14.render({'otherVar': 'value'});
    } catch (e) {
      print('Error in macro includes call stack information:');
      print(e.toString());
    }

    // Example 15: Error in Include
    print('\n=== Example 15: Error in Include ===');
    var loader15 = MapLoader(
      {
        'partial.html': '{{ undefinedVariable }}',
      },
      globalJinjaData: {},
    );
    var env15 = Environment(loader: loader15);
    var template15 = env15.fromString(
      '''
<div>
  <h1>Main Template</h1>
  {% include "partial.html" %}
</div>
''',
      path: 'main.html',
    );

    try {
      template15.render({'mainVar': 'value'});
    } catch (e) {
      print('Error in included template shows call stack:');
      print(e.toString());
    }

    // ========== COMPREHENSIVE ERROR LOGGING EXAMPLE ==========

    // Example 16: Comprehensive Error Logging Setup
    print('\n=== Example 16: Comprehensive Error Logging Setup ===');
    var comprehensiveLogger = ErrorLogger(level: LogLevel.debug);
    var env16 = Environment();
    var template16 = env16.fromString(
      '''
{% if user %}
  {{ user.name|upper }}
{% else %}
  No user found
{% endif %}
''',
      path: 'comprehensive.html',
    );

    try {
      // This should work fine
      var result16 = template16.render({
        'user': {'name': 'Alice'},
      });
      print('Successful render: $result16');

      comprehensiveLogger.logInfo(
        'Template rendered successfully',
        context: {
          'template': 'comprehensive.html',
          'resultLength': result16.length
        },
      );
    } catch (e, stackTrace) {
      comprehensiveLogger.logError(
        'Template rendering failed',
        error: e,
        context: {
          'template': 'comprehensive.html',
          'contextKeys': ['user'],
        },
        stackTrace: stackTrace,
      );
      print('Error logged with comprehensive logger');
    }

    print('\n=== All error logging examples completed successfully! ===');
  } catch (e, stackTrace) {
    print('\n!!! UNHANDLED EXCEPTION !!!');
    print(e);
    print(stackTrace);
  }
}
