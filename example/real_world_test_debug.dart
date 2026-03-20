// ignore_for_file: avoid_print

import 'dart:async';

import 'package:jinja/debug.dart';
import 'package:jinja/jinja.dart';

import 'get_jinja.dart';

final jinjaScript = '''
{
  "widget_type": "container",
  "content": {
    "title": "{{ title }}",
    "items": [
      {% for item in items %}
      {
        "name": "{{ item.name }}",
        "value": {{ item.value }}
      }{% if not loop.last %},{% endif %}
      {% endfor %}
    ]
  }
}
''';
final Map<String, dynamic> jinjaData = {
  'title': 'Test Widget',
  'items': [
    {
      'name': 'Item 1',
      'value': 10,
    },
    {
      'name': 'Item 2',
      'value': 20,
    }
  ],
};

void main() async {
  try {
    final errors = <String?>[];

    // Setup MapLoader with base templates for inheritance and inclusion
    final loader = MapLoader(
      {
        'macro_property': '''{% macro macro_property(id, label, type, widget, value, value_text=none) %}
{
    "property_id": "{{ id }}",
    "property_label": "{{ label }}",
    "data_type": "{{ type }}",
    "ui_widget": "{{ widget }}",
    "data": {
        "value": {% if value is string %}"{{ value }}"{% else %}{{ value }}{% endif %}{% if value_text is not none %},
        "value_text": "{{ value_text }}"{% endif %}
    }
}
{% endmacro %}

{% macro macro_padding(left=0, right=0, top=0, bottom=0) %}
{
    "left": {{ macro_property("left", "Left", "number", "number", left) }},
    "right": {{ macro_property("right", "Right", "number", "number", right) }},
    "top": {{ macro_property("top", "Top", "number", "number", top) }},
    "bottom": {{ macro_property("bottom", "Bottom", "number", "number", bottom) }}
}
{% endmacro %}

{% macro macro_border_radius(global_value=10, top_left=10, top_right=10, bottom_left=10, bottom_right=10) %}
{
    "data": {
        "value": {{ global_value }}
    },
    "top_left": {{ macro_property("top_left", "Top-left border", "input_text_number", "input_text_number", top_left) }},
    "top_right": {{ macro_property("top_right", "Top-right border", "input_text_number", "input_text_number", top_right) }},
    "bottom_left": {{ macro_property("bottom_left", "Bottom-left border", "input_text_number", "input_text_number", bottom_left) }},
    "bottom_right": {{ macro_property("bottom_right", "Bottom-right border", "input_text_number", "input_text_number", bottom_right) }}
}
{% endmacro %}

{% macro macro_text_style(text_style_value="body", text_style_value_text="Body", text_color_value="neutral_white", text_color_value_text="neutral_white") %}
{
    "text_color": {{ macro_property("text_color", "Text Color", "color", "color_picker", text_color_value, text_color_value_text) }},
    "data": {
        "value": "{{ text_style_value }}",
        "value_text": "{{ text_style_value_text }}"
    },
    "property_id": "text_style",
    "property_label": "Default Text Style",
    "data_type": "text_styles",
    "ui_widget": "text_styles"
}
{% endmacro %}

{% macro macro_icon(property_id="leading_icon", property_label="Leading Icon", value="", value_text="", mode_value="network", icon_color_value="neutral_white", icon_color_value_text="neutral_white") %}
{
    "property_id": "{{ property_id }}",
    "property_label": "{{ property_label }}",
    "data_type": "icon",
    "ui_widget": "icon",
    "data": {
        "value": "{{ value }}",
        "value_text": "{{ value_text }}"
    },
    "mode": {
        "data": {
            "value": "{{ mode_value }}"
        }
    },
    "icon_color": {{ macro_property("icon_color", "Icon Color", "color", "color_picker", icon_color_value, icon_color_value_text) }}
}
{% endmacro %}

{% macro macro_font_awesome_icon(id, unicode, size=16) %}
{
  "id": "{{ id }}",
  "type": "icon",
  "value": {
    "unicode": { "value": "{{ unicode }}" },
    "icon_size": { "value": {{ size }} },
    "font_family": { "value": "FontAwesomeSolid" },
    "font_package": { "value": "font_awesome_flutter" }
  }
}
{% endmacro %}
''',
      },
      globalJinjaData: jinjaData,
    );

    final env = GetJinja.environment(
      MockBuildContext(),
      loader,
      enableJinjaDebugLogging: true,
      valueListenableJinjaError: (error) {
        print('Jinja Error: $error');
        errors.add(error);
      },
      callbackToParentProject: ({required payload}) async {
        await Future<void>.delayed(const Duration(seconds: 2));
        return {
          'workflows': ['register_free'],
          'jinja_data': {
            'username': 'avo123123@avo.com',
            'password': 'avo@avo.com',
            'email': 'avo123123@avo.com',
            'first_name': 'avo@avo.com',
            'last_name': 'avo@avo.com',
          },
          'workflow_continue': null,
          'client_name': 'jinja-hq',
          'agent_name': 'main',
          'workflow_results': {
            'register_free': {
              'signup_user': {'message': 'User created successfully'},
              'workflow_log_id': '40032e5c-0706-452c-946e-87689bf2c609',
            },
          },
        };
      },
      // enableJinjaDebugLogging: true,
    );
    // example 2: real world example
    print('\n=== Example 2: Real world example ===');
    final debugController = DebugController()..enabled = true;
    debugController.breakOnLoopIteration = true;
    debugController.addBreakpoint(line: 16);
    debugController.addBreakpoint(line: 17);
    debugController.addBreakpoint(line: 18);
    debugController.addBreakpoint(line: 19);
    debugController.addBreakpoint(line: 20);
    debugController.addBreakpoint(line: 21);
    debugController.addBreakpoint(line: 8);
    debugController.onBreakpoint = (info) async {
      print('--- BREAKPOINT HIT ---');
      print('Line: ${info.lineNumber}');
      print('Node type: ${info.nodeType}');
      if (info.nodeName != null) print('Node name: ${info.nodeName}');
      print('Variables:');
      info.variables.forEach((key, value) {
        if (key == 'loop' || key == 'item' || key == 'title' || key == 'items') {
          print('  $key: $value (type: ${value.runtimeType})');
        }
      });
      print('Current Output: ${info.currentOutput}');
      print('----------------------');
      return DebugAction.continue_;
    };
    var template2 = env.fromString(jinjaScript);
    var result2 = await template2.renderDebug(data: jinjaData, debugController: debugController);
    print('Result length: ${result2.length}');
    print('--------------------------------------------------------------------------------------------------------------------------------');
    print(result2);
    print('--------------------------------------------------------------------------------------------------------------------------------');
  } catch (e, stack) {
    print('\n!!! UNHANDLED EXCEPTION !!!');
    print(e);
    print(stack);
  }
}

Future<String> fetchData() async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return 'Data fetched successfully';
}
