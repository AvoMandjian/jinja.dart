import 'dart:async';
import 'package:jinja/jinja.dart';
import 'package:jinja/debug.dart';

/// Simple programmatic example of debug functionality
void main() async {
  var env = Environment();

  var template = env.fromString('''
{% set name = "World" %}
Hello {{ name }}!
{% for i in range(3) %}
  Item {{ i }}
{% endfor %}
''');

  var debugController = DebugController();
  debugController.enabled = true;

  // Add breakpoints for specific node types
  debugController.addNodeBreakpoint('Interpolation');
  // debugController.addNodeBreakpoint('For');

  // Note: Line breakpoints are not yet accurately mapped to source lines
  // debugController.addLineBreakpoint(2);

  var breakpointCount = 0;

  // Set up breakpoint handler
  debugController.onBreakpoint = (info) async {
    breakpointCount++;
    print('\n--- Breakpoint #$breakpointCount ---');
    print('Type: ${info.nodeType}');
    print('Variables: ${info.variables}');
    print('Output so far: "${info.outputSoFar}"');

    // Automatically continue after showing info
    return DebugAction.continueExecution;
  };

  // Add range function to environment
  env.globals['range'] = (int n) => List.generate(n, (i) => i);

  print('Starting debug render...\n');

  var result = await template.renderDebug(
    data: {},
    debugController: debugController,
  );

  print('\n--- Final Result ---');
  print(result);
  print('\nTotal breakpoints hit: $breakpointCount');
}
