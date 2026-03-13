import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/debug_controller.dart';
import 'package:jinja/src/debug/debug_renderer.dart';
import 'package:jinja/src/nodes.dart';

void main() async {
  final env = Environment();
  final controller = DebugController()..enabled = true;
  controller.addBreakpoint(line: 2, condition: '{% invalid %syntax %}');
  
  final renderer = DebugRenderer();
  final context = DebugRenderContext(env, StringBuffer(), debugController: controller);

  final node = Interpolation(value: Constant(value: 1), line: 2);
  await renderer.visitInterpolation(node, context);
  print(controller.history.length);
}
