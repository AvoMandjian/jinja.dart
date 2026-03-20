import 'package:jinja/src/debug/debug_controller.dart';
import 'package:test/test.dart';

void main() {
  group('DebugController and related classes coverage', () {
    test('Breakpoint equality and hashCode', () {
      final b1 = Breakpoint(line: 10);
      final b2 = Breakpoint(line: 10);

      expect(b1 == b1, isTrue);
      expect(b1 == b2, isFalse); // IDs are different
      expect(b1.hashCode == b1.id.hashCode, isTrue);
    });

    test('BreakpointInfo toJson', () {
      final info = BreakpointInfo(
        nodeType: 'Interpolation',
        variables: {'a': 1},
        outputSoFar: 'start',
        currentOutput: 'mid',
        lineNumber: 5,
        nodeName: 'x',
        nodeData: 'data',
      );

      final json = info.toJson();
      expect(json['nodeType'], equals('Interpolation'));
      expect(json['variables'], equals({'a': 1}));
      expect(json['outputSoFar'], equals('start'));
      expect(json['currentOutput'], equals('mid'));
      expect(json['lineNumber'], equals(5));
      expect(json['nodeName'], equals('x'));
      expect(json['nodeData'], equals('data'));
    });

    test('DebugController breakpoint management', () {
      final controller = DebugController();

      // Add
      final b1 = controller.addBreakpoint(line: 1);
      final b2 = controller.addBreakpoint(line: 1);
      final b3 = controller.addBreakpoint(line: 2);

      expect(controller.getBreakpoints(1), containsAll([b1, b2]));
      expect(controller.getBreakpoints(2), contains(b3));
      expect(controller.getBreakpoints(3), isEmpty);

      // Remove
      controller.removeBreakpoint(b1);
      expect(controller.getBreakpoints(1), equals([b2]));

      controller.removeBreakpoint(b2);
      expect(controller.getBreakpoints(1), isEmpty);

      // Clear
      controller.clearBreakpoints();
      expect(controller.getBreakpoints(2), isEmpty);
    });

    test('DebugController history and reset', () async {
      final controller = DebugController();
      final info = BreakpointInfo(nodeType: 'Data', variables: {}, outputSoFar: '', lineNumber: 1);

      await controller.handleBreakpoint(info);
      expect(controller.history, hasLength(1));
      expect(controller.history.first, equals(info));

      controller.clearHistory();
      expect(controller.history, isEmpty);

      // Reset
      controller.stopped = true;
      controller.stepOverLine = 10;
      await controller.handleBreakpoint(info);

      controller.reset();
      expect(controller.history, isEmpty);
      expect(controller.stopped, isFalse);
      expect(controller.stepOverLine, isNull);
    });

    test('DebugController handleBreakpoint without callback', () async {
      final controller = DebugController();
      final info = BreakpointInfo(nodeType: 'Data', variables: {}, outputSoFar: '', lineNumber: 1);

      final action = await controller.handleBreakpoint(info);
      expect(action, equals(DebugAction.continue_));
    });
  });
}
