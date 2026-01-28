import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/debug_controller.dart';
import 'package:jinja/src/debug/debug_environment.dart';
import 'package:test/test.dart';

void main() {
  group('Debug Actions', () {
    late Environment env;
    late DebugController controller;

    setUp(() {
      env = Environment();
      controller = DebugController()..enabled = true;
    });

    test('stop action', () async {
      var template = env.fromString('Hello\n{{ name }}\nEnd');
      controller.addBreakpoint(line: 2);
      var hit = false;

      controller.onBreakpoint = (info) {
        hit = true;
        return Future.value(DebugAction.stop);
      };

      var result = await template.renderDebug(data: {'name': 'World'}, debugController: controller);
      expect(hit, isTrue);
      expect(result, isNot(contains('End')));
    });

    test('step over action', () async {
      var template = env.fromString('{{ a }}\n{{ b }}\n{{ c }}');
      controller.addBreakpoint(line: 1);
      var steps = <int>[];

      controller.onBreakpoint = (info) {
        steps.add(info.lineNumber);
        return Future.value(DebugAction.stepOver);
      };

      await template.renderDebug(data: {'a': 1, 'b': 2, 'c': 3}, debugController: controller);
      // Remove duplicates as stepping might stop multiple times on same line (e.g. Data and Interpolation)
      var uniqueSteps = steps.toSet().toList()..sort();
      expect(uniqueSteps, orderedEquals([1, 2, 3]));
    });

    test('step in and step out actions', () async {
      var template = env.fromString('{% for i in [1] %}\n{{ i }}\n{% endfor %}');
      controller.addBreakpoint(line: 1);
      var steps = <int>[];

      controller.onBreakpoint = (info) {
        steps.add(info.lineNumber);
        return Future.value(DebugAction.stepIn);
      };

      await template.renderDebug(data: {}, debugController: controller);
      var uniqueSteps = steps.toSet().toList()..sort();
      expect(uniqueSteps, orderedEquals([1, 2]));
    });
  });
}
