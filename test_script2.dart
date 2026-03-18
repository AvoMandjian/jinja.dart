import 'package:jinja/src/environment.dart';
import 'package:jinja/src/nodes.dart';

void main() {
  final jinjaScript = '''
{% import "data_types.jinja" as types %}

{% macro title_view(s) %}
    {{ s | title }}
{% endmacro %}

{{ types.create_dt_text("test string", title_view, ui_widget="single_line_text", property_label="Font Name", property_id="font_name")}}
''';
  final env = Environment();
  final templateNode = env.parse(jinjaScript) as TemplateNode;
  final output = templateNode.body as Output;
  final interp = output.nodes.last as Interpolation;
  final call = interp.value as Call;
  print("args: ${call.calling.arguments}");
}
