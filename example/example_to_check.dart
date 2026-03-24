import 'package:intl/intl.dart';
import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/debug_template.dart';

Map<String, dynamic> dataToPassToJinja = {
  'header_visible': 0,
  'footer_visible': 0,
  'clear_data': true,
  'cell_value': 'scripts_list',
  'table_name': 'ide_widgets',
  'column_name': 'widget_id',
  'widget_id': 'scripts_list_jform',
  'page_id': 'scripts_list',
  'code_editor_jframe_menu_data': [],
  'get_jinja_scripts_list': {
    'scripts_list_data': [
      {
        'script_id': {
          'value': {'text': '21cccedc-2e91-45a0-8662-a3befb2d58c0'},
        },
        'script_title': {
          'value': {'text': 'test'},
        },
        'updated_at': {
          'value': {'text': '2025-11-21 13:49:21'},
        },
        'events': {
          'on_click': {
            'workflow_id': 'navigate_to_jinja_code_editor',
            'properties': {
              'jinja_script_id': '21cccedc-2e91-45a0-8662-a3befb2d58c0'
            },
          },
        },
        'description': 'description',
      }
    ],
  },
};

Future<void> main() async {
  var env = Environment(
    globals: <String, Object?>{
      'get': (Map map, String key) => map[key],
      'now': () {
        var dt = DateTime.now().toLocal();
        var hour = dt.hour.toString().padLeft(2, '0');
        var minute = dt.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      },
    },
    loader: MapLoader(
      {
        'first_script__1__00': '''
{
  "page_id": "scripts_list",
  "rows": [
    {
      "row_id": "",
      "columns": [
        {
          "column_id": "1",
          "widgets": [
            {
              "header": {
                "styles": {},
                "style": {
                  "add_button": true
                },
                "widget_id": "uuid",
                "widget_type": "list_header",
                "loading": false,
                "record": "500",
                "count": "1000",
                "item_title": "ItemTitle",
                "item_value": "ItemValue",
                "placeholder_text": "II",
                "image_url": "https://picsum.photos/id/498/200/400.jpg?hmac=0WiqwcyjwQZWx7RKwywDBxKjPwBHiB6tw_oJrRyruho",
                "image_padding": 8,
                "image_radius": 4,
                "item_name": "ItemName",
                "item_sub_name": "Subname",
                "events": {},
                "add_new_menu_options": [
                  {
                    "title": "Add New Script",
                    "icon": "0xf601",
                    "events": {
                      "on_click": {
                        "workflow_id": "open_add_new_slideover",
                        "properties": {}
                      }
                    }
                  }
                ],
                "menu_option": {
                  "widget_id": "options_menu",
                  "widget_type": "options_menu",
                  "title": "Options",
                  "width": 250,
                  "height": 60,
                  "widgets": [
                    {
                      "type": "small",
                      "widget": {
                        "item_list": [
                          {
                            "id": "print",
                            "icon": "0xf02f"
                          },
                          {
                            "id": "pdv",
                            "icon": "0xf1c1"
                          },
                          {
                            "id": "3",
                            "icon": "0xf004"
                          },
                          {
                            "id": "4",
                            "icon": "0xf004"
                          }
                        ]
                      }
                    },
                    {
                      "type": "divider"
                    },
                    {
                      "type": "profile",
                      "id": "profile",
                      "widget": {
                        "title": "Profile",
                        "subtitle": "subtitle",
                        "icon": "0xf2bb",
                        "image_url": "https://i.pravatar.cc/300"
                      }
                    },
                    {
                      "type": "divider_large"
                    },
                    {
                      "type": "selectable",
                      "id": "1",
                      "widget": {
                        "title": "Select",
                        "icon": "0xf004"
                      }
                    },
                    {
                      "type": "selectable",
                      "id": "2",
                      "widget": {
                        "title": "Connect to remote server",
                        "icon": "0xf004",
                        "color": "error",
                        "icon_color": "error"
                      }
                    },
                    {
                      "type": "divider_large"
                    },
                    {
                      "type": "divider"
                    },
                    {
                      "type": "menu_title",
                      "title": "title"
                    },
                    {
                      "type": "medium",
                      "widget": {
                        "item_list": [
                          {
                            "id": "1",
                            "icon": "0xf004",
                            "title": "1"
                          },
                          {
                            "id": "2",
                            "icon": "0xf004",
                            "title": "2"
                          },
                          {
                            "id": "3",
                            "icon": "0xf004",
                            "title": "3"
                          }
                        ]
                      }
                    },
                    {
                      "type": "divider"
                    },
                    {
                      "type": "divider_large"
                    },
                    {
                      "type": "divider"
                    },
                    {
                      "type": "divider"
                    }
                  ]
                }
              },
              "list_view": {
                "search": {
                  "widget_id": "search",
                  "field_width": 297,
                  "widget_type": "search",
                  "initial_text": "Search",
                  "pre_built_list": false
                },
                "advanced_filter": {
                  "style": {
                    "title": "Advanced Filter",
                    "button_text": "Clear All",
                    "button_width": 100,
                    "button_heigth": 35
                  },
                  "toggle": {
                    "size": 40,
                    "style": {
                      "vertical": false,
                      "has_border": false,
                      "border_color": "primary",
                      "border_radius": {
                        "top_left": 0,
                        "bottom_left": 0
                      },
                      "selected_fill_color": "primary",
                      "selected_item_color": "white",
                      "selected_border_color": "primary",
                      "unselected_fill_color": "primary",
                      "unselected_item_color": "white"
                    },
                    "stacked": true,
                    "widget_list": [
                      {
                        "id": "1",
                        "type": "icon",
                        "value": {
                          "unicode": {
                            "value": "0xf1de"
                          },
                          "icon_size": {
                            "value": 16
                          },
                          "font_family": {
                            "value": "FontAwesomeSolid"
                          },
                          "font_package": {
                            "value": "font_awesome_flutter"
                          }
                        }
                      },
                      {
                        "id": "2",
                        "type": "icon",
                        "value": {
                          "unicode": {
                            "value": "0xf053"
                          },
                          "icon_size": {
                            "value": 16
                          },
                          "font_family": {
                            "value": "FontAwesomeSolid"
                          },
                          "font_package": {
                            "value": "font_awesome_flutter"
                          }
                        }
                      }
                    ],
                    "current_index": 0
                  },
                  "actions": {
                    "get_advanced_filter_ui": {
                      "action": "recordset_get_advanced_filter",
                      "meta_data": {
                        "app_cache_id": "item_advanced_filters"
                      }
                    }
                  },
                  "widget_id": "scripts_adv_filter",
                  "widget_list": [
                    {
                      "type": "date_picker",
                      "widget": {
                        "data": {
                          "value": "",
                          "value_text": ""
                        },
                        "label": "Created Date",
                        "show_action_buttons": false,
                        "validators": [
                          {
                            "message": "Invalid date",
                            "validation": "pattern"
                          }
                        ],
                        "view_mode": "edit",
                        "widget_id": "created_at",
                        "date_picker_size": 300,
                        "widget_type": "date_picker"
                      }
                    },
                    {
                      "type": "dropdown",
                      "widget": {
                        "data": {},
                        "type": "single_select",
                        "title": "Created By",
                        "widget_id": "created_by",
                        "chip_style": {},
                        "widget_type": "dropdown",
                        "show_buttons": false,
                        "dropdown_list": {
                          "data": [],
                          "style": {
                            "row_height": 40,
                            "header_row_height": 0,
                            "grid_lines_visibility": "none",
                            "header_grid_lines_visibility": "none"
                          },
                          "columns": [
                            {
                              "type": "text",
                              "column_id": "list"
                            },
                            {
                              "type": "dropdown_icon",
                              "width": 40,
                              "column_id": "dropdown_icon_id",
                              "icon_size": 14,
                              "icon_color": "primary",
                              "column_name": "",
                              "icon_unicode": "0xf00c",
                              "row_alignment": "end"
                            }
                          ],
                          "expanded": true,
                          "widget_id": "created_by_list",
                          "widget_type": "list_data_grid",
                          "query_search": false,
                          "enable_header": true,
                          "recordset_auto_load": true
                        }
                      }
                    },
                    {
                      "type": "dropdown",
                      "widget": {
                        "data": {},
                        "type": "single_select",
                        "title": "Type",
                        "widget_id": "script_type",
                        "chip_style": {},
                        "widget_type": "dropdown",
                        "show_buttons": false,
                        "dropdown_list": {
                          "data": [],
                          "style": {
                            "row_height": 40,
                            "header_row_height": 0,
                            "grid_lines_visibility": "none",
                            "header_grid_lines_visibility": "none"
                          },
                          "columns": [
                            {
                              "type": "text",
                              "column_id": "list"
                            },
                            {
                              "type": "dropdown_icon",
                              "width": 40,
                              "column_id": "dropdown_icon_id",
                              "icon_size": 14,
                              "icon_color": "primary",
                              "column_name": "",
                              "icon_unicode": "0xf00c",
                              "row_alignment": "end"
                            }
                          ],
                          "expanded": true,
                          "widget_id": "script_type_list",
                          "widget_type": "list_data_grid",
                          "query_search": false,
                          "enable_header": true,
                          "recordset_auto_load": true
                        }
                      }
                    }
                  ],
                  "widget_type": "advanced_filter"
                },
                "data": {{ get(get_jinja_scripts_list,"scripts_list_data") | tojson }},
                "style": {
                  "row_height": 58,
                  "header_row_height": 40
                },
                "columns": [
                  {
                    "type": "text",
                    "column_id": "script_id",
                    "column_name": "ID",
                    "allow_sorting": false
                  },
                  {
                    "type": "text",
                    "column_id": "script_title",
                    "column_name": "Title",
                    "allow_sorting": false
                  },
                  {
                    "type": "text",
                    "column_id": "updated_at",
                    "column_name": "Updated At",
                    "allow_sorting": true
                  }
                ],
                "widget_id": "scripts",
                "widget_type": "list_data_grid",
                "global_row_height": true,
                "mouse_cursor": true,
                "recordset_auto_load": true
              },
              "widget_id": "scripts_list",
              "widget_type": "power_list",
              "padding_menu": {
                "top": 5,
                "left": 0,
                "right": 0,
                "bottom": 0
              }
            }
          ]
        }
      ]
    }
  ]
}''',
      },
      globalJinjaData: {},
    ),
    leftStripBlocks: true,
    trimBlocks: true,
    filters: {
      'sub_string': (String value, int start, int end) {
        try {
          return value.substring(start, end);
        } catch (e) {
          return value;
        }
      },
      'date_format': (String value, String dateFormat) {
        var inputFormat = DateFormat(dateFormat).format(DateTime.parse(value));
        return inputFormat;
      },
      'replace_each': (
        String value,
        String from,
        String to, [
        int? count,
      ]) {
        if (count == null) {
          for (var element in from.split('').toList()) {
            value = value.replaceAll(element, to);
          }
        } else {
          var start = value.indexOf(from);
          var n = 0;

          while (n < count && start != -1 && start < value.length) {
            var start = value.indexOf(from);
            value = value.replaceRange(start, start + from.length, to);
            start = value.indexOf(from, start + to.length);
            n += 1;
          }
        }

        return value;
      },
      'regex_replace': (
        String value,
        String from,
        String to,
      ) {
        RegExp regex = RegExp(from);

        var decodedString = value.replaceAll(regex, to);

        return decodedString;
      },
    },
  );
  Template templateOfJinja = env.fromString('''{% block first_script__1__00 %}
  {% include "first_script__1__00" %}
{% endblock first_script__1__00 %}
''');
  var debugController = DebugController();
  debugController.addBreakpoint(line: 3);
  debugController.enabled = true;

  debugController.onBreakpoint = (info) async {
    // print('Variables: ${info.variables}');
    print('Output: ${info.lineNumber}');
    return DebugAction.continue_;
  };

  await templateOfJinja
      .renderDebug(
        dataToPassToJinja,
        debugController: debugController,
      )
      .then(
        (value) => print('\n\nRESULT OF THE RENDER: \n\n$value'),
      );
}

// ignore_for_file: avoid_print
