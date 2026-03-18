import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/debug_environment.dart';

void main() async {
  var env = Environment();

  var templateSource = '''
<h1>{{ title }}</h1>
{% for item in items %}
<p>{{ item.name }}: {{ item.value }}</p>
{% endfor %}
''';

  var data = {
    'title': 'My List',
    'items': [
      {'name': 'Item 1', 'value': 10},
      {'name': 'Item 2', 'value': 20},
    ],
  };

  var debugController = DebugController();
  debugController.enabled = true;

  // Add breakpoints on all lines
  for (int i = 1; i <= 10; i++) {
    debugController.addBreakpoint(line: i);
  }

  debugController.onBreakpoint = (info) async {
    print('\nBreakpoint at line ${info.lineNumber}');
    print('  Node Type: ${info.nodeType}');
    print('  Node Name: ${info.nodeName}');
    print('  Node Data: ${info.nodeData}');
  };

  try {
    var result = await env.fromString(templateSource).renderDebug(
      data: data,
      debugController: debugController,
    );

    print('\n\nRendered:\n$result');
    print('\nHistory: ${debugController.history.length} breakpoints hit');
  } catch (e) {
    print('Error: $e');
  }
}
