@TestOn('vm || chrome')
library;

import 'package:jinja/src/error_logger.dart';
import 'package:test/test.dart';

void main() {
  group('ErrorLogger', () {
    test('creates with default log level (error)', () {
      final logger = ErrorLogger();
      expect(logger.level, equals(LogLevel.error));
    });

    test('creates with custom log level', () {
      final logger = ErrorLogger(level: LogLevel.debug);
      expect(logger.level, equals(LogLevel.debug));
    });

    test('setLogLevel updates log level', () {
      final logger = ErrorLogger();
      logger.setLogLevel(LogLevel.warning);
      expect(logger.level, equals(LogLevel.warning));
    });

    group('isEnabled', () {
      test('none level disables all logging', () {
        final logger = ErrorLogger(level: LogLevel.none);
        expect(logger.isEnabled(LogLevel.error), isFalse);
        expect(logger.isEnabled(LogLevel.warning), isFalse);
        expect(logger.isEnabled(LogLevel.info), isFalse);
        expect(logger.isEnabled(LogLevel.debug), isFalse);
      });

      test('error level enables only error logging', () {
        final logger = ErrorLogger();
        expect(logger.isEnabled(LogLevel.error), isTrue);
        expect(logger.isEnabled(LogLevel.warning), isFalse);
        expect(logger.isEnabled(LogLevel.info), isFalse);
        expect(logger.isEnabled(LogLevel.debug), isFalse);
      });

      test('warning level enables error and warning logging', () {
        final logger = ErrorLogger(level: LogLevel.warning);
        expect(logger.isEnabled(LogLevel.error), isTrue);
        expect(logger.isEnabled(LogLevel.warning), isTrue);
        expect(logger.isEnabled(LogLevel.info), isFalse);
        expect(logger.isEnabled(LogLevel.debug), isFalse);
      });

      test('info level enables error, warning, and info logging', () {
        final logger = ErrorLogger(level: LogLevel.info);
        expect(logger.isEnabled(LogLevel.error), isTrue);
        expect(logger.isEnabled(LogLevel.warning), isTrue);
        expect(logger.isEnabled(LogLevel.info), isTrue);
        expect(logger.isEnabled(LogLevel.debug), isFalse);
      });

      test('debug level enables all logging', () {
        final logger = ErrorLogger(level: LogLevel.debug);
        expect(logger.isEnabled(LogLevel.error), isTrue);
        expect(logger.isEnabled(LogLevel.warning), isTrue);
        expect(logger.isEnabled(LogLevel.info), isTrue);
        expect(logger.isEnabled(LogLevel.debug), isTrue);
      });
    });

    group('logError', () {
      test('logs error when level is error or higher', () {
        final logger = ErrorLogger();
        expect(() => logger.logError('Test error'), returnsNormally);
      });

      test('does not log when level is none', () {
        final logger = ErrorLogger(level: LogLevel.none);
        expect(() => logger.logError('Test error'), returnsNormally);
        // Should not throw, just silently ignore
      });

      test('includes error object in log', () {
        final logger = ErrorLogger();
        final error = Exception('Test exception');
        expect(() => logger.logError('Error message', error: error), returnsNormally);
      });

      test('includes context in log', () {
        final logger = ErrorLogger();
        final context = {'key': 'value', 'number': 42};
        expect(() => logger.logError('Error message', context: context), returnsNormally);
      });

      test('includes stack trace in log', () {
        final logger = ErrorLogger();
        final stackTrace = StackTrace.current;
        expect(() => logger.logError('Error message', stackTrace: stackTrace), returnsNormally);
      });
    });

    group('logWarning', () {
      test('logs warning when level is warning or higher', () {
        final logger = ErrorLogger(level: LogLevel.warning);
        expect(() => logger.logWarning('Test warning'), returnsNormally);
      });

      test('does not log when level is error', () {
        final logger = ErrorLogger();
        expect(() => logger.logWarning('Test warning'), returnsNormally);
        // Should not throw, just silently ignore
      });

      test('includes context in log', () {
        final logger = ErrorLogger(level: LogLevel.warning);
        final context = {'key': 'value'};
        expect(() => logger.logWarning('Warning message', context: context), returnsNormally);
      });
    });

    group('logInfo', () {
      test('logs info when level is info or higher', () {
        final logger = ErrorLogger(level: LogLevel.info);
        expect(() => logger.logInfo('Test info'), returnsNormally);
      });

      test('does not log when level is warning', () {
        final logger = ErrorLogger(level: LogLevel.warning);
        expect(() => logger.logInfo('Test info'), returnsNormally);
        // Should not throw, just silently ignore
      });

      test('includes context in log', () {
        final logger = ErrorLogger(level: LogLevel.info);
        final context = {'key': 'value'};
        expect(() => logger.logInfo('Info message', context: context), returnsNormally);
      });
    });

    group('logDebug', () {
      test('logs debug when level is debug', () {
        final logger = ErrorLogger(level: LogLevel.debug);
        expect(() => logger.logDebug('Test debug'), returnsNormally);
      });

      test('does not log when level is info', () {
        final logger = ErrorLogger(level: LogLevel.info);
        expect(() => logger.logDebug('Test debug'), returnsNormally);
        // Should not throw, just silently ignore
      });

      test('includes context in log', () {
        final logger = ErrorLogger(level: LogLevel.debug);
        final context = {'key': 'value'};
        expect(() => logger.logDebug('Debug message', context: context), returnsNormally);
      });
    });

    group('LogLevel enum', () {
      test('has correct values', () {
        expect(LogLevel.values, hasLength(5));
        expect(LogLevel.values, contains(LogLevel.none));
        expect(LogLevel.values, contains(LogLevel.error));
        expect(LogLevel.values, contains(LogLevel.warning));
        expect(LogLevel.values, contains(LogLevel.info));
        expect(LogLevel.values, contains(LogLevel.debug));
      });
    });
  });
}
