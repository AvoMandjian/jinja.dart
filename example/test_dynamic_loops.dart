import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/debug_controller.dart';
import 'package:jinja/src/debug/debug_environment.dart';

void main() async {
  // Test 1: Simple loop
  await testLoop(
    'Test 1: Simple loop',
    '''Start
{% for i in range(2) %}
  Item {{ i }}
{% endfor %}
End''',
    {
      'range': (int start, [int? stop, int step = 1]) =>
          stop == null ? Iterable<int>.generate(start) : Iterable<int>.generate((stop - start) ~/ step, (i) => start + i * step),
    },
  );

  // Test 2: Nested loops
  await testLoop(
    'Test 2: Nested loops',
    '''Start
{% for i in range(2) %}
  Outer {{ i }}
  {% for j in range(2) %}
    Inner {{ i }},{{ j }}
  {% endfor %}
{% endfor %}
End''',
    {
      'range': (int start, [int? stop, int step = 1]) =>
          stop == null ? Iterable<int>.generate(start) : Iterable<int>.generate((stop - start) ~/ step, (i) => start + i * step),
    },
  );

  // Test 3: Loop with multiple statements
  await testLoop(
    'Test 3: Loop with multiple statements',
    '''{% set total = 0 %}
{% for item in items %}
  {% set total = total + item %}
  Value: {{ item }}
  Running total: {{ total }}
{% endfor %}
Final: {{ total }}''',
    {
      'items': [10, 20, 30],
    },
  );
}

Future<void> testLoop(String testName, String templateSource, Map<String, Object?> data) async {
  print('\n${'=' * 60}');
  print(testName);
  print('=' * 60);

  // Show template with line numbers
  print('Template:');
  templateSource.split('\n').forEach(print);

  // Create environment and debug controller
  var env = Environment();
  var debugController = DebugController();
  debugController.enabled = true;

  // Add line breakpoints for lines with interpolations
  debugController.addBreakpoint(line: 1);
  debugController.addBreakpoint(line: 4);

  int breakpointCount = 0;
  debugController.onBreakpoint = (info) async {
    breakpointCount++;
    print('\nBreakpoint #$breakpointCount at Line ${info.lineNumber}');

    // Show current variable values for loop variables
    var loopVars = <String, Object?>{};
    for (var entry in info.variables.entries) {
      if (entry.key == 'i' || entry.key == 'j' || entry.key == 'item' || entry.key == 'total') {
        loopVars[entry.key] = entry.value;
      }
    }
    if (loopVars.isNotEmpty) {
      print('  Loop variables: $loopVars');
    }
    return DebugAction.resume;
  };

  // Parse and render
  var template = env.fromString(
    templateSource.replaceAll(RegExp(r'Line \d+: '), ''),
  );

  await template.renderDebug(
    data: data,
    debugController: debugController,
  );

  print('\nTotal breakpoints hit: $breakpointCount');
}
