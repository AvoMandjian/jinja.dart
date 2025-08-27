import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/debug_template.dart';

void main() async {
  print('Testing Dynamic Loop Body Line Detection\n');

  // Test 1: Simple loop
  await testSimpleLoop();

  // Test 2: Nested loops
  await testNestedLoops();

  // Test 3: Loop with multiple statements
  await testComplexLoop();
}

Future<void> testSimpleLoop() async {
  print('=' * 60);
  print('Test 1: Simple Loop');
  print('=' * 60);

  var template = '''Start
{% for i in range(3) %}
  Item {{ i }}
{% endfor %}
End''';

  await runDebugTest(template, {
    'range': (int start, [int? stop, int step = 1]) =>
        stop == null ? Iterable<int>.generate(start) : Iterable<int>.generate((stop - start) ~/ step, (i) => start + i * step)
  }, [
    3
  ]); // Breakpoint on line 3 (Item {{ i }})
}

Future<void> testNestedLoops() async {
  print('\n${'=' * 60}');
  print('Test 2: Nested Loops');
  print('=' * 60);

  var template = '''Start
{% for i in range(2) %}
  Outer {{ i }}
  {% for j in range(2) %}
    Inner {{ i }},{{ j }}
  {% endfor %}
{% endfor %}
End''';

  await runDebugTest(template, {
    'range': (int start, [int? stop, int step = 1]) =>
        stop == null ? Iterable<int>.generate(start) : Iterable<int>.generate((stop - start) ~/ step, (i) => start + i * step)
  }, [
    3,
    5
  ]); // Breakpoints on lines 3 and 5
}

Future<void> testComplexLoop() async {
  print('\n${'=' * 60}');
  print('Test 3: Complex Loop with Assignments');
  print('=' * 60);

  var template = '''{% set total = 0 %}
{% for item in items %}
  {% set total = total + item %}
  Value: {{ item }}
  Running total: {{ total }}
{% endfor %}
Final: {{ total }}''';

  await runDebugTest(template, {
    'items': [10, 20, 30],
    'total': 0,
  }, [
    4,
    5,
    7
  ]); // Breakpoints on Value, Running total, and Final
}

Future<void> runDebugTest(String template, Map<String, Object?> data, List<int> breakpointLines) async {
  // Show template with line numbers
  print('\nTemplate with line numbers:');
  var lines = template.split('\n');
  for (int i = 0; i < lines.length; i++) {
    print('  Line ${i + 1}: ${lines[i]}');
  }

  // Create environment and debug controller
  var env = Environment();
  var debugController = DebugController();
  debugController.enabled = true;

  // Add line breakpoints
  for (var line in breakpointLines) {
    debugController.addBreakpoint(line: line);
    print('Added breakpoint at line $line');
  }

  var breakpointCount = 0;
  var lineHits = <int, int>{};

  debugController.onBreakpoint = (info) async {
    breakpointCount++;
    lineHits[info.lineNumber] = (lineHits[info.lineNumber] ?? 0) + 1;

    // Show only loop variables
    var loopVars = <String, Object?>{};
    for (var entry in info.variables.entries) {
      if (entry.key == 'i' || entry.key == 'j' || entry.key == 'item' || entry.key == 'total') {
        loopVars[entry.key] = entry.value;
      }
    }

    print('\nBreakpoint #$breakpointCount:');
    print('  Line: ${info.lineNumber}');
    print('  Type: ${info.nodeType}');
    if (loopVars.isNotEmpty) {
      print('  Loop vars: $loopVars');
    }
  };

  // Parse and render
  var parsedTemplate = env.fromString(template);

  print('\n--- Starting debug render ---');
  await parsedTemplate.renderDebug(
    data,
    debugController: debugController,
  );

  print('\n--- Debug Summary ---');
  print('Total breakpoints hit: $breakpointCount');
  print('Line hit counts:');
  for (var entry in lineHits.entries) {
    print('  Line ${entry.key}: hit ${entry.value} time(s)');
  }
}
