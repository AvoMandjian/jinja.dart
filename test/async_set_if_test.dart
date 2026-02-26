import 'dart:async';

import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

void main() {
  group('Async set with if', () {
    test('async set assignment is visible in subsequent if', () async {
      final template = Template(
        '{% set result = get_data() %}'
        '{% if result and result.value %}OK{% endif %}',
      );

      Future<Map<String, Object?>> getData() async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return <String, Object?>{'value': true};
      }

      final output = await template.renderAsync(<String, Object?>{
        'get_data': getData,
      });

      expect(output, equals('OK'));
    });
  });
}

