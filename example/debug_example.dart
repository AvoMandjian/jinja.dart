import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/debug_environment.dart';

void main() async {
  // Create environment
  var env = Environment();

  // Initial template
  var templateSource = '''
<h1>Debug Example</h1>
{% set counter = 0 %}

<ul>
{% for item in items %}
  {% set counter = counter + 1 %}
  <li>{{ counter }}. {{ item.name }} - Price: \${{ item.price }}</li>
{% endfor %}
</ul>

{% if show_total %}
<p>Total items: {{ counter }}</p>
{% endif %}

<p>User: {{ user }}</p>
''';

  // Data for template
  var data = {
    'items': [
      {'name': 'Apple', 'price': 1.5},
      {'name': 'Banana', 'price': 0.8},
      {'name': 'Orange', 'price': 2.0},
    ],
    'show_total': true,
    'user': 'John Doe',
  };

  // Create debug controller
  var debugController = DebugController();
  debugController.enabled = true;

  // Add line breakpoints
  debugController.addBreakpoint(line: 2);
  debugController.addBreakpoint(line: 4);
  debugController.addBreakpoint(line: 8);

  // Variable to track current template (for restart with changes)
  String currentTemplateSource = templateSource;

  // Set up breakpoint handler
  debugController.onBreakpoint = (info) async {
    print('\n${"=" * 60}');
    print('BREAKPOINT HIT!');
    print('=' * 60);
    print('Node Type: ${info.nodeType}');
    print('Line: ${info.lineNumber}');
    if (info.nodeName != null) {
      print('Node Name: ${info.nodeName}');
    }
    print('\nVariables in scope:');
    info.variables.forEach((key, value) {
      print('  $key: $value');
    });
    print('\nOutput so far:');
    print('─' * 40);
    print(info.outputSoFar);
    print('─' * 40);

    // Ask user what to do
    // print('\nWhat would you like to do?');
    // print('  [c] Continue');
    // print('  [s] Stop');
    // print('  [r] Restart (you can edit template first)');
    // print('  [d] Disable this breakpoint type');
    // print('  [a] Disable all breakpoints and continue');

    // stdout.write('Your choice: ');
    // var choice = stdin.readLineSync()?.toLowerCase() ?? 'c';

    // switch (choice) {
    //   case 's':
    //     print('Stopping execution...');
    //     return DebugAction.stop;

    //   case 'r':
    //     print('\nWould you like to modify the template before restart? (y/n): ');
    //     var modify = stdin.readLineSync()?.toLowerCase() == 'y';

    //     if (modify) {
    //       print('Enter new template (type END on a new line to finish):');
    //       var lines = <String>[];
    //       String? line;
    //       while ((line = stdin.readLineSync()) != 'END') {
    //         if (line != null) lines.add(line);
    //       }
    //       currentTemplateSource = lines.join('\n');
    //       print('Template updated!');
    //     }

    //     print('Restarting with ${modify ? "new" : "current"} template...');
    //     return DebugAction.restart;

    //   case 'd':
    //     debugController.removeNodeBreakpoint(info.nodeType);
    //     print('Disabled breakpoint for ${info.nodeType}');
    //     return DebugAction.continueExecution;

    //   case 'a':
    //     debugController.enabled = false;
    //     print('All breakpoints disabled');
    //     return DebugAction.continueExecution;

    //   case 'c':
    //   default:
    //     return DebugAction.continueExecution;
    // }
  };

  print('Starting Jinja Debug Example');
  print('=' * 60);
  print('Template:');
  print(templateSource);
  print('=' * 60);
  print('Data:');
  data.forEach((key, value) {
    print('  $key: $value');
  });
  print('=' * 60);
  print('Breakpoints set for: For, Interpolation, Assign');
  print('Starting rendering...\n');

  try {
    // Render with debug support
    var result = await env.fromString(currentTemplateSource).renderDebug(
          data: data,
          debugController: debugController,
          getUpdatedTemplate: () => currentTemplateSource,
        );

    print('\n${"=" * 60}');
    print('FINAL RESULT:');
    print('=' * 60);
    print(result);
    print('=' * 60);

    // Show debug history
    if (debugController.history.isNotEmpty) {
      print('\nDebug History (${debugController.history.length} breakpoints hit):');
      for (var i = 0; i < debugController.history.length; i++) {
        var bp = debugController.history[i];
        print('  ${i + 1}. Line ${bp.lineNumber}: ${bp.nodeType} ${bp.nodeName ?? ""}');
      }
    }
  } catch (e) {
    print('\nError during rendering: $e');
  }
}
