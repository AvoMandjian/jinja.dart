import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/debug_template.dart';
import 'package:jinja/src/debug/debug_controller.dart';
import 'package:test/test.dart';

void main() {
  test('DebugTemplate coverage with templateSource', () async {
    final env = Environment();
    final template = env.fromString('original');
    final controller = DebugController()..enabled = true;

    final result = await template.renderDebug(
      {},
      debugController: controller,
      templateSource: 'new source',
    );
    expect(result, equals('new source'));
  });
}
