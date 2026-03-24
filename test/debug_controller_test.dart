import 'package:jinja/src/debug/debug_controller.dart';
import 'package:test/test.dart';

void main() {
  group('DebugController coverage', () {
    test('Breakpoint equality and hashCode', () {
      final bp1 = Breakpoint(line: 1, condition: 'true');
      final bp2 = Breakpoint(line: 1, condition: 'true');

      expect(bp1, equals(bp1));
      expect(bp1, isNot(equals(bp2))); // different ids
      expect(bp1.hashCode, isNot(equals(bp2.hashCode)));
    });

    test('BreakpointInfo toJson', () {
      final info = BreakpointInfo(
        nodeType: 'Node',
        variables: {'a': 1},
        outputSoFar: 'out',
        lineNumber: 10,
        nodeName: 'name',
        nodeData: 'data',
      );
      final json = info.toJson();
      expect(json, {
        'nodeType': 'Node',
        'variables': {'a': 1},
        'outputSoFar': 'out',
        'currentOutput': '',
        'lineNumber': 10,
        'nodeName': 'name',
        'nodeData': 'data',
      });
    });

    test('DebugController methods', () {
      final controller = DebugController();
      controller.addBreakpoint(line: 1);
      expect(controller.getBreakpoints(1), isNotEmpty);

      controller.clearBreakpoints();
      expect(controller.getBreakpoints(1), isEmpty);

      controller.addBreakpoint(line: 2);
      final info = BreakpointInfo(
          nodeType: 'x', variables: {}, outputSoFar: '', lineNumber: 1);
      controller.handleBreakpoint(info);
      expect(controller.history, isNotEmpty);

      controller.clearHistory();
      expect(controller.history, isEmpty);

      controller.handleBreakpoint(info);
      controller.reset();
      expect(controller.history, isEmpty);
    });
  });
}
