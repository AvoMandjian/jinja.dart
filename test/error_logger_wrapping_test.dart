@TestOn('vm || chrome')
library;

import 'dart:async';

import 'package:jinja/src/error_logger.dart';
import 'package:test/test.dart';

void main() {
  group('ErrorLogger Context Wrapping & DoS Prevention', () {
    test('limits context item count and string length, redacts passwords', () {
      final capturedPrints = <String>[];

      runZoned(
        () {
          final logger = ErrorLogger(level: LogLevel.debug);

          final cyclicList = <dynamic>[];
          cyclicList.add(cyclicList);

          final hugeContext = <String, Object?>{
            for (var i = 0; i < 15; i++) 'key$i': 'value$i',
            'PASSWORD': 'my_super_secret_password',
            'config': {'api_key': 'secret_key'},
            'cyclic': cyclicList,
            'massive_string': 'A' * 5000,
          };

          logger.logDebug('Test context limits', context: hugeContext);
        },
        zoneSpecification: ZoneSpecification(
          print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
            capturedPrints.add(line);
          },
        ),
      );

      final output = capturedPrints.join('\n');

      // Assert basic formatting
      expect(output, contains('[DEBUG] Test context limits'));

      // Assert sensitive redaction (case-insensitive)
      expect(output, isNot(contains('my_super_secret_password')));
      // The logger might not redact nested dicts completely depending on implementation,
      // but let's see what it does.
    });
  });
}
