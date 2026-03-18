import 'package:jinja/src/environment.dart';
import 'package:jinja/src/nodes.dart';

void main() {
  final env = Environment();
  final templateNode = env.parse('{{ types.create_dt_text("test string", title_view, ui_widget="single_line_text") }}') as TemplateNode;
  final call = ((templateNode.body as Output).nodes.first as Interpolation).value as Call;
  print("args length: \${call.calling.arguments.length}");
}
