import 'package:intl/intl.dart';
import 'package:jinja/jinja.dart';

Map<String, dynamic> dataToPassToJinja = {
  'subcategory_title': 'Su',
};

void main() {
  var env = Environment(
    globals: <String, Object?>{
      'now': () {
        var dt = DateTime.now().toLocal();
        var hour = dt.hour.toString().padLeft(2, '0');
        var minute = dt.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      },
    },
    loader: MapLoader({
      'first_script__1__00': '<p>First Script</p><p>{{subcategory_title | sub_string(0,3)}}</p>',
    }),
    leftStripBlocks: true,
    trimBlocks: true,
    filters: {
      'sub_string': (String value, int start, int end) {
        try {
          return value.substring(start, end);
        } catch (e) {
          return value;
        }
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
