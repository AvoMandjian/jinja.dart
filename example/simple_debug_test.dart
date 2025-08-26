import 'dart:async';
import 'package:jinja/jinja.dart';
import 'package:jinja/debug.dart';

/// Simple programmatic example of debug functionality
void main() async {
  var env = Environment();

  var templateSource = '''
<p>First Script</p><p>{{subcategory_title}}</p>
<p>Second Script</p><p>{{subcategory_title_2}}</p>
<p>Third Script</p><p>{{subcategory_title_3}}</p>
<p>Fourth Script</p><p>{{subcategory_title_4}}</p>
''';

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
  debugController.addLineBreakpoint(2);

  print('Starting debug render...\n');

  var result = await template.renderDebug(
    data: {
      'subcategory_title': 'Subcategory Title',
      'subcategory_title_2': 'Subcategory Title 2',
      'subcategory_title_3': 'Subcategory Title 3',
      'subcategory_title_4': 'Subcategory Title 4',
    },
    debugController: debugController,
  );

  print('\n--- Final Result ---');
  print(result);
  print('\nTotal breakpoints hit: $breakpointCount');
}
