import 'dart:async';
import 'package:jinja/jinja.dart';
import 'package:jinja/debug.dart';

/// Simple programmatic example of debug functionality
void main() async {
  var env = Environment();

  var templateSource = '''{% set name = "World" %}
Hello {{ name }}!
{% for i in range(3) %}
  Item {{ i }}
{% endfor %}
''';

  print('Template source:');
  var lines = templateSource.split('\n');
  for (var i = 0; i < lines.length; i++) {
    print('Line ${i + 1}: ${lines[i]}');
  }
  print('');

  var template = env.fromString(templateSource);

  var debugController = DebugController();
  debugController.enabled = true;

  // Add breakpoints for specific node types
  // debugController.addNodeBreakpoint('Interpolation');
  // // debugController.addNodeBreakpoint('For');

  var breakpointCount = 0;

  // Set up debug controller with breakpoint handler
  debugController.onBreakpoint = (info) async {
    breakpointCount++;
    print('\n--- Breakpoint #$breakpointCount ---');
    print('Line: ${info.lineNumber}');
    print('Type: ${info.nodeType}');
    print('Variables: ${info.variables}');
    print('Output so far: "${info.outputSoFar}"');

    // Continue execution
    return DebugAction.continueExecution;
  };

  // Enable line breakpoints on line 2 and line 4
  debugController.addLineBreakpoint(2); // Hello {{ name }} line
  debugController.addLineBreakpoint(4); // Item {{ i }} line

  print('Starting debug render...\n');

  var result = await template.renderDebug(
    data: {},
    debugController: debugController,
  );

  print('\n--- Final Result ---');
  print(result);
  print('\nTotal breakpoints hit: $breakpointCount');
}
