import 'package:jinja/debug.dart';
import 'package:jinja/jinja.dart';

/// Simple programmatic example of debug functionality
void main() async {
  var env = Environment();

  var templateSource = '''Hello 1
{% for VARIABLE_1 in [1,2] %}
  {{dealership.inventory | tojson}}
{% endfor %}
Hello 2''';

  var template = env.fromString(templateSource);

  var debugController = DebugController();
  debugController.enabled = true;

  var breakpointCount = 0;

  // Set up debug controller with breakpoint handler
  debugController.onBreakpoint = (info) async {
    breakpointCount++;
    print('\n--- Breakpoint #$breakpointCount ---');
    print('Line: ${info.lineNumber}');
    print('Type: ${info.nodeType}');
    print('Variables: ${info.variables}');
    print('Output so far: "${info.outputSoFar}"');
    print('Current output: "${info.currentOutput}"');

    // Execution continues automatically after this handler completes.
  };

  // debugController.addBreakpoint(line: 1); // Before loop
  // debugController.addBreakpoint(line: 2); // For loop statement
  // debugController.addBreakpoint(line: 3); // Inside loop
  // debugController.addBreakpoint(line: 4); // After loop

  print('Starting debug render...\n');

  await template.renderDebug(
    data: {
      'dealership': {
        'name': 'AutoWorld',
        'location': {'city': 'Gyumri', 'country': 'Armenia'},
        'inventory': [
          {
            'id': 1,
            'make': 'Toyota',
            'model': 'Camry',
            'year': 2021,
            'features': ['Bluetooth', 'Backup Camera', 'Cruise Control'],
            'specs': {'engine': '2.5L', 'transmission': 'Automatic', 'fuelType': 'Gasoline'}
          },
          {
            'id': 2,
            'make': 'Tesla',
            'model': 'Model 3',
            'year': 2023,
            'features': ['Autopilot', 'Electric', 'Touchscreen'],
            'specs': {'engine': 'Electric', 'transmission': 'Single-speed', 'fuelType': 'Electric'}
          }
        ],
        'openHours': {'mon-fri': '9:00-18:00', 'sat': '10:00-15:00', 'sun': 'Closed'}
      }
    },
    debugController: debugController,
  );

  print('\nTotal breakpoints hit: $breakpointCount');
}
