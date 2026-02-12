// ignore_for_file: avoid_print

import 'dart:async';

import 'package:jinja/jinja.dart';

import 'get_jinja.dart';

final jinjaScript = '''
{
    "groups": [
      [
     {% for menu in menu_data.list_data %}
        {
          "data": {
            "page": "",
            "depth_level": 0
          },
          "icon": {
            "height": {
              "value": 15
            },
            "width": {
              "value": 15
            },
            "mode": {
              "value": "network"
            },
            "data": {
              "value": "{% if menu.data and  menu.data.icon%}{{menu.data.icon}}{%endif%}"
            }
          },
          "title": "{% if  menu.data and  menu.data.value_text %}{{menu.data.value_text}}{%endif%}",
          "value": "{% if  menu.data and menu.data.value %}{{ menu.data.value}}{%endif%}",
          "trailing": "{% if  menu.data and  menu.data.show_add_icon == 1 %}true{%else%}false{%endif%}"
        }
     {% if not loop.last %},{%endif%}{%endfor%}
      ]
    ],
    "user_name": "Name Surname",
    "widget_id": "ide_main_menu",
    "recordset_action": "read_all_data",
    "widget_type": "menu",
    "drawer_icon_background_color": "background_regular",
    "opened_menu_height": 50,
    "closed_menu_height": 50,
    "user_image_url": "",
    "logo": {
      "mode": "network",
      "data": {
        "value": "https://jinja-app-media.s3.us-east-2.amazonaws.com/logo.png"
      },
      "icon_color": "dark"
    },
    "menu_top_icon": {
      "padding": {
        "bottom": {
          "value": 17
        },
        "left": {
          "value": 6
        },
        "right": {
          "value": 10
        },
        "top": {
          "value": 17
        }
      },
      "mode": "network",
      "data": {
        "value": "https://jinja-app-media.s3.us-east-2.amazonaws.com/logo.svg"
      }
    },
    "drawer_open_icon": {
      "padding": {
        "bottom": {
          "value": 17
        },
        "left": {
          "value": 6
        },
        "right": {
          "value": 10
        },
        "top": {
          "value": 17
        }
      },
      "mode": "network",
      "data": {
        "value": "https://files.svgcdn.io/humbleicons/bars.svg"
      },
      "icon_color": "dark"
    },
    "menu_title_color": "darkest",
    "drawer_close_icon": {
      "padding": {
        "bottom": {
          "value": 17
        },
        "left": {
          "value": 6
        },
        "right": {
          "value": 10
        },
        "top": {
          "value": 17
        }
      },
      "mode": "network",
      "data": {
        "value": "https://files.svgcdn.io/pajamas/close.svg"
      },
      "icon_color": "dark"
    },
    "bg_color_primary": "neutral_white",
    "bg_color_secondary": "neutral_white",
    "submenu_title_color": "primary",
    "title": "JINJA",
    "selected_index": 0,
    "only_icon": false,
    "search_field_tooltip": "Search",
    "sub_menu_selected_item_color": "neutral_darkest",
    "sub_menu_selected_item_background_color": "error",
    "drawer_background_color": "neutral_white",
    "background_color": "background_regular",
    "unselected_item_color": "neutral_darkest",
    "selected_item_color": "neutral_darkest",
    "show_search": false
  }
''';
final jinjaData = {
  'menu_data': {
    'list_data': [
      {
        'content_id': 'ide_main_menu_my_apps',
        'parent_id': null,
        'data_type': 'menu_item',
        'ui_widget': 'menu_item',
        'property_label': '',
        'property_id': 'menu_item',
        'data': {
          'value': 'my_apps',
          'value_text': 'My Apps',
          'parent_id': '',
          'icon': 'https://files.svgcdn.io/proicons/apps.svg',
          'show_add_icon': 1,
          'add_icon': '',
          'metadata': {},
          'events': {
            'on_click': {
              'workflow_id': '',
            },
          },
        },
      },
      {
        'content_id': 'ide_main_menu_my_scripts',
        'parent_id': null,
        'data_type': 'menu_item',
        'ui_widget': 'menu_item',
        'property_label': '',
        'property_id': 'menu_item',
        'data': {
          'value': 'my_scripts',
          'value_text': 'My Scripts',
          'parent_id': '',
          'icon': 'https://files.svgcdn.io/ps/code.svg',
          'show_add_icon': 1,
          'add_icon': '',
          'metadata': {},
          'events': {
            'on_click': {
              'workflow_id': '',
            },
          },
        },
      },
      {
        'content_id': 'ide_main_menu_discover',
        'parent_id': null,
        'data_type': 'menu_item',
        'ui_widget': 'menu_item',
        'property_label': '',
        'property_id': 'menu_item',
        'data': {
          'value': 'discover',
          'value_text': 'Discover',
          'parent_id': '',
          'icon': 'https://files.svgcdn.io/carbon/explore.svg',
          'show_add_icon': 1,
          'add_icon': '',
          'metadata': {},
          'events': {
            'on_click': {
              'workflow_id': '',
            },
          },
        },
      }
    ],
  },
};

void main() async {
  try {
    final errors = <String?>[];

    // Setup MapLoader with base templates for inheritance and inclusion
    final loader = MapLoader(
      {},
      globalJinjaData: jinjaData,
    );

    final env = GetJinja.environment(
      MockBuildContext(),
      loader,
      valueListenableJinjaError: (error) {
        print('Jinja Error: $error');
        errors.add(error);
      },
      callbackToParentProject: ({required payload}) async {
        await Future<void>.delayed(const Duration(seconds: 2));
        print('Mock callbackToParentProject called with: $payload');
        return {'mock_data': 'test_data'};
      },
    );
    // example 2: real world example
    print('\n=== Example 2: Real world example ===');
    var template2 = env.fromString(jinjaScript);
    var result2 = await template2.renderAsync(jinjaData);
    print(result2);
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
