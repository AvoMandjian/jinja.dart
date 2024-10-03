import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:jinja/jinja.dart';
import 'package:json_path/json_path.dart';

Map<String, dynamic> dataToPassToJinja = {'variable_1': 'the output is encoded to base64'};

void main() {
  var loader = MapLoader({
    'first_script__1__00': '{{variable_1 | b64encode}}',
  });
  var env = Environment(
    globals: <String, Object?>{
      'jsonPath': (Map<Object?, Object?> json, String query) {
        try {
          var jsonQuery = JsonPath('\$$query');
          var response = jsonQuery.read(json);
          var value = response.map((e) => e).first.value;
          return value;
        } catch (e) {
          return {
            'error': e.toString(),
            'query': query,
          };
        }
      }
    },
    loader: loader,
    leftStripBlocks: true,
    trimBlocks: true,
    filters: {
      'b64encode': (String value) {
        try {
          return base64.encode(utf8.encode(value));
        } catch (e) {
          return value;
        }
      },
      'b64decode': (String value) {
        try {
          return utf8.decode(base64.decode(value));
        } catch (e) {
          return value;
        }
      },
      'sub_string': (String value, int start, int end) {
        try {
          return value.substring(start, end);
        } catch (e) {
          return e.toString();
        }
      },
      'to_string': (dynamic value) {
        return value.toString();
      },
      'split': ([String? a, String? b]) {
        return a?.split(b ?? '');
      },
      'date_format': (String value, String dateFormat) {
        var inputFormat = DateFormat(dateFormat).format(DateTime.parse(value));
        return inputFormat;
      },
      'replace_each': (
        String value,
        String from,
        String to, [
        int? count,
      ]) {
        if (count == null) {
          for (var element in from.split('').toList()) {
            value = value.replaceAll(element, to);
          }
        } else {
          var start = value.indexOf(from);
          var n = 0;

          while (n < count && start != -1 && start < value.length) {
            var start = value.indexOf(from);
            value = value.replaceRange(start, start + from.length, to);
            start = value.indexOf(from, start + to.length);
            n += 1;
          }
        }

        return value;
      },
      'regex_replace': (
        String value,
        String from,
        String to,
      ) {
        RegExp regex = RegExp(from);

        var decodedString = value.replaceAll(regex, to);

        return decodedString;
      },
    },
  );
  Template templateOfJinja = env.fromString('''{% block first_script__1__00 %}
  {% include "first_script__1__00" %}
{% endblock first_script__1__00 %}
''');
  String responseFromJinja = templateOfJinja.render(dataToPassToJinja);

  print(responseFromJinja);
}

// ignore_for_file: avoid_print
