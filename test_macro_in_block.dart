import 'package:jinja/jinja.dart';

void main() {
  var env = Environment(loader: MapLoader({'macro_property': '{% block myblock %}{% macro macro_padding() %}hi{% endmacro %}{% endblock %}'}, globalJinjaData: {}));
  var tmpl = env.fromString('{% from "macro_property" import macro_padding %}{{ macro_padding() }}');
  print('Template rendered: ${tmpl.render()}');
}
