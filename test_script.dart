import 'package:jinja/src/environment.dart';
import 'package:jinja/src/nodes.dart';

void main() {
  final env = Environment();
  final templateNode = env.parse('{{ _raw_text(value, view, "dt_text", ui_widget, property_label, property_id, strict, optional, default, uid, min_length, max_length, pattern) }}') as TemplateNode;
  final output = templateNode.body as Output;
  final interp = output.nodes.first as Interpolation;
  final call = interp.value as Call;
  print("args length: ${call.calling.arguments.length}");
  print("kwargs length: ${call.calling.keywords.length}");
}
