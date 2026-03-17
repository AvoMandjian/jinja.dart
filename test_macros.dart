import 'package:jinja/jinja.dart';

void main() {
  var env = Environment();
  var tmpl = env.fromString('''
{% if true %}
  {% macro test_macro() %}hello{% endmacro %}
{% endif %}
  ''');
  print(tmpl.body.macros.map((m) => m.name).toList());
}
