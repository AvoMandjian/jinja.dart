// ignore_for_file: avoid_print

import 'dart:async';

import 'package:jinja/jinja.dart';

import 'get_jinja.dart';

final jinjaScript = """{
  'widget_type': 'jform',
  'widget_id': 'jinja_carousel_slider_jform',
  'workflows': {
      'navigate_to_data_sources': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'json_schema_set_page_in',
          'json_out_schema_id': 'json_schema_set_page_out',
          'set_page': {
            'page_id': 'jframe_data_bridge',
            'column_id': 'column_2',
            'properties': {
              'header_visible': 0,
              'footer_visible': 0,
              'clear_data': true,
              'cell_value': 'jframe_data_bridge',
              'table_name': 'data_bridge.content',
              'column_name': 'content_id',
              'widget_id': 'jframe_data_bridge',
            },
          },
        }
      ],
    },
    'profile':{
      'workflow_actions': [
        {
          'json_in_schema_id': 'json_schema_set_page_in',
          'json_out_schema_id': 'json_schema_set_page_out',
          'set_page': {
            'page_id': 'profile_page',
            'column_id': 'column_2',
            'properties': {
              'data_source_id': 'get_user_data_from_db',
              'widget_id': 'profile_page_jform',
            },
          },
        }
      ],
    },
    'delete_script_workflow': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'show_confirmation_dialog_json_in_schema',
          'json_out_schema_id': 'show_confirmation_dialog_json_out_schema',
          'show_confirmation_dialog': {
            'properties': {
              'title': 'Delete Script',
              'message': 'Are you sure you want to delete this script?',
              'list_of_buttons': [
                {
                  'text': 'Cancel',
                  'value': false,
                },
                {
                  'text': 'Delete',
                  'value': true,
                }
              ],
          },
        },
        },
        {
          'json_in_schema_id': 'delete_data_from_db_json_in_schema',
          'json_out_schema_id': 'delete_data_from_db_json_out_schema',
          'delete_data_from_db': {
            'properties': {
              {% raw %}
              'parent_id': "{{ get(jinja_script_by_id,'parent_id') }}",
              'jinja_script_id': '{{ jinja_script_id }}'
              {% endraw %},
            },
          },
        }
      ],
    },
    'navigate_to_inplay_app_form': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'json_schema_set_page_in',
          'json_out_schema_id': 'json_schema_set_page_out',
          'set_page': {
            'page_id': 'inplay_app_form',
            'column_id': 'column_2',
            'properties': {
              'header_visible': 0,
              'footer_visible': 0,
              'clear_data': true,
              'cell_value': 'inplay_app_form',
              'table_name': 'ide_widgets',
              'column_name': 'widget_id',
              'widget_id': 'inplay_app_form_jform',
            },
          },
        }
      ],
    },
    'go_to_home_page':{
      'workflow_actions': [
        {
          'json_in_schema_id': 'json_schema_set_page_in',
          'json_out_schema_id': 'json_schema_set_page_out',
          'set_page': {
            'page_id': 'home_page',
            'column_id': 'column_2',
            'properties': {
              'header_visible': 0,
              'footer_visible': 0,
              'clear_data': true,
              'cell_value': 'home_page',
              'table_name': 'ide_widgets',
              'column_name': 'widget_id',
              'widget_id': 'scripts_list_jform',
            },
          },
        }
      ],
    },
    'publish_script_workflow': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'get_data_from_db_json_in_schema',
          'json_out_schema_id': 'get_data_from_db_json_out_schema',
          'save_data_to_db': {
            'properties': {
              {% raw %}
              'database_url': '{{ database_url }}',
              'table_name': '{{ table_name }}',
              'column_name': '{{ column_name }}',
              'cell_value': '{{ cell_value }}',
              'column_to_save_to': '{{ column_to_save_to }}',
              'value_to_save': "{{ get(code_editor,'left_side_code') }}"
              {% endraw %},
            },
          },
        },
        {
          'json_in_schema_id': 'get_data_from_db_json_in_schema',
          'json_out_schema_id': 'get_data_from_db_json_out_schema',
          'upload_db': {
            'properties': {
              {% raw %}
              'database_url': '{{ database_url }}'
              {% endraw %},
            },
          },
        }
      ],
    },
    'navigate_to_app_translate_page': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'get_data_from_db_json_in_schema',
          'json_out_schema_id': 'get_data_from_db_json_out_schema',
          'get_data_from_db': {
            'properties': {
              {% raw %}
              'database_url': '{{ database_url }}',
              'table_name': '{{ table_name }}',
              'column_name': '{{ column_name }}',
              'cell_value': '{{ cell_value }}'
              {% endraw %},
            },
          },
        },
        {
          'json_in_schema_id': 'json_schema_set_page_in',
          'json_out_schema_id': 'json_schema_set_page_out',
          'set_header': {
            'page_id': 'code_editor_header',
            'column_id': 'header_column',
            'properties': {
              'cell_value': 'code_editor_header',
              'table_name': 'ide_widgets',
              'column_name': 'widget_id',
              'widget_id': 'code_editor_header',
            },
          },
        },
        {
          'json_in_schema_id': 'json_schema_set_page_in',
          'json_out_schema_id': 'json_schema_set_page_out',
          'set_page': {
            'page_id': 'code_editor',
            'column_id': 'column_2',
            'properties': {
              {% raw %}
              'jinja_script': '{{ jinja_script }}',
              'database_url': '{{ database_url }}',
              {% endraw %}
              'cell_value': 'translate_app',
              'table_name': 'ide_widgets',
              'column_name': 'widget_id',
              'widget_id': 'code_editor',
              'clear_data': true,
              'header_visible': 1,
            },
          },
        }
      ],
    },
    'navigate_to_scripts_list': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'json_schema_set_page_in',
          'json_out_schema_id': 'json_schema_set_page_out',
          'set_page': {
            'page_id': 'home_page',
            'column_id': 'column_2',
            'properties': {
              'header_visible': 0,
              'footer_visible': 0,
              'clear_data': true,
              'cell_value': 'home_page',
              'table_name': 'ide_widgets',
              'column_name': 'widget_id',
              'widget_id': 'scripts_list_jform',
            },
          },
        }
      ],
    },
    'navigate_to_tab': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'json_schema_set_page_in',
          'json_out_schema_id': 'json_schema_set_page_out',
          'set_page': {
            {% raw %}
            'page_id': '{{ page_id }}',
            'clear_data': '{% if clear_data is defined %} {{ clear_data }} {% else %} false {% endif %}',
            {% endraw %}
            'column_id': 'column_2',
            'properties': {
              'header_visible': 0,
              'footer_visible': 0,
              'clear_data': true,
              {% raw %}
              'cell_value': '{{ page_id }}',
              'widget_id': '{{ page_id }}_jform',
              {% endraw %}
              'table_name': 'ide_widgets',
              'column_name': 'widget_id',
            },
          },
        }
      ],
    },
    'navigate_to_discover_agents_list': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'json_schema_set_page_in',
          'json_out_schema_id': 'json_schema_set_page_out',
          'set_page': {
            'page_id': 'agents_list',
            'column_id': 'column_2',
            'properties': {
              'header_visible': 0,
              'footer_visible': 0,
              'clear_data': true,
              'cell_value': 'agents_list',
              'table_name': 'ide_widgets',
              'column_name': 'widget_id',
              'widget_id': 'agents_list_jform',
            },
          },
        }
      ],
    },
    'navigate_to_agent_jform': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'json_schema_set_page_in',
          'json_out_schema_id': 'json_schema_set_page_out',
          'set_page': {
            'page_id': 'agent_jform',
            'column_id': 'column_2',
            'properties': {
              'header_visible': 0,
              'cell_value': 'agent_jform',
              'table_name': 'ide_widgets',
              'column_name': 'widget_id',
              'widget_id': 'agent_jform_widget',
            },
          },
        }
      ],
    },
    'navigate_to_designer_page': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'json_schema_set_page_in',
          'json_out_schema_id': 'json_schema_set_page_out',
          'set_page': {
            'page_id': 'designer_page',
            'column_id': 'column_2',
            'properties': {
              'header_visible': 0,
              'cell_value': 'designer_page',
              'table_name': 'ide_widgets',
              'column_name': 'widget_id',
              'widget_id': 'designer_page_jform',
            },
          },
        }
      ],
    },
    'open_add_new_slideover': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'get_data_from_db_json_in_schema',
          'json_out_schema_id': 'get_data_from_db_json_out_schema',
          'get_data_from_db': {
            'properties': {
              'cell_value': 'scripts_list_add_new_slideover',
              'table_name': 'ide_widgets',
              'column_name': 'widget_id',
              'open_slideover': true,
            },
          },
        }
      ],
    },
    'save_script_workflow': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'get_data_from_db_json_in_schema',
          'json_out_schema_id': 'get_data_from_db_json_out_schema',
          'get_data_from_db': {
            'properties': {
              'cell_value': 'save_script_workflow',
              'table_name': 'data_sources',
              'column_name': 'data_source_id',
            },
          },
        }
      ],
    },
    'navigate_to_scripts_list_2': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'json_schema_set_page_in',
          'json_out_schema_id': 'json_schema_set_page_out',
          'set_page': {
            'page_id': 'home_page',
            'column_id': 'column_2',
            'properties': {
              'header_visible': 0,
              'cell_value': 'home_page',
              'table_name': 'ide_widgets',
              'column_name': 'widget_id',
              'widget_id': 'jinja_carousel_scripts_listslider',
              'clear_data': true,
            },
          },
        }
      ],
    },
    'navigate_to_carousel_slider': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'json_schema_set_page_in',
          'json_out_schema_id': 'json_schema_set_page_out',
          'set_page': {
            'page_id': 'home_page',
            'column_id': 'column_2',
            'properties': {
              'header_visible': 0,
            },
          },
        }
      ],
    },
    'navigate_to_jinja_code_editor': {
      'workflow_actions': [
        {
          'json_in_schema_id': 'json_schema_set_page_in',
          'json_out_schema_id': 'json_schema_set_page_out',
          'set_page': {
            'page_id': 'code_editor',
            'column_id': 'column_2',
            'properties': {
              {% raw %}
              'jinja_script_id': '{{ jinja_script_id }}',
              'output_type': '{{ output_type }}',
              {% endraw %}
              'cell_value': 'code_editor',
              'table_name': 'ide_widgets',
              'column_name': 'widget_id',
              'widget_id': 'code_editor',
              'clear_data': true,
            },
          },
        }
      ],
    },
  },
  'events': {},
  'layout': {
    'layout_type_id': 'data',
    'header': {
      'page_id': 'header_page',
      'visible': 0,
    },
    'footer': {
      'visible': 0,
    },
    'body': {
      'default_container_id': 'home_container',
      'containers': {
        'home_container': {
          'rows': [
            {
              'row_id': '',
              'columns': [
                {
                  'column_id': 'column_1',
                  'page_id': 'menu_page',
                  'properties': {
                    'width': 80,
                  },
                },
                {
                  'column_id': 'column_2',
                  'page_id': 'home_page',
                  'properties': {
                    'flex': 3,
                    'padding': {
                      'left': {
                        'value': 65,
                      },
                    },
                  },
                }
              ],
            }
          ],
        },
      },
    },
  },
  'pages': {
    'header_page': {},
    'menu_page': {
      'page_id': 'menu_page',
      'rows': [
        {
          'row_id': '',
          'columns': [
            {
              'column_id': '1',
              'widgets': [
                {
                   {{ get_widget_by_id('ide_main_menu') }},
                }
              ],
            }
          ],
        }
      ],
    },
    'home_page': {
      'page_id': 'scripts_list',
      'rows': [
        {
          'row_id': '',
          'columns': [
            {
              'column_id': '1',
              'widgets': [
                {
                  'header': {
                        'widget_id': 'uuid',
                        'widget_type': 'detail_header',
                        'property_settings': {
                            'height': {'value': 50},
                            'data': {},
                            'mode': {
                            'value': 'custom',
                            },
                            'widget_list': [
                              {
                                'type': 'text',
                                'widget': {
                                  'property_settings':{
                                    'padding': {
                                      'left': {
                                        'value': 20,
                                      },
                                      'right': {
                                        'value': 20,
                                      },
                                    },
                                  },
                                'widget_id': 'title',
                                'text': 'JINJA LIST',
                                'text_color': 'neutral_darkest',
                                'style': 'title_large',
                                },
                            },
                            {
                                'type': 'vertical_divider',
                                'widget': {
                                    'width': 1.0,
                                    'color': 'neutral_darkest',
                                    'indent': 8,
                                    'end_indent': 8,
                                },
                            },
                            {
                                'type': 'text',
                                'widget': {
                                    'property_settings':{
                                    'padding': {
                                      'left': {
                                        'value': 20,
                                      },
                                    },
                                  },
                                'widget_id': 'number_of_scripts',
                                'text': '{{ get_jinja_scripts_count }}',
                                'text_color': 'neutral_darkest',
                                'style': 'title_large',
                                },
                            },
                            {
                                'type': 'spacer',
                            },
                            {
                                'type': 'button',
                                'widget': {
                                'widget_id': 'build_button',
                                    'events': {
                                    'on_pressed': {
                                    'workflow_id': 'open_add_new_slideover',
                                    'properties': {},
                                    },
                                },
                                'widget_type': 'button',
                                'property_settings': {
                                    'text': {
                                    'value': 'Add Script',
                                    },
                                    'is_html': {
                                    'value': 0,
                                    },
                                    'disabled': {
                                    'value': 0,
                                    },
                                    'align': {
                                    'value': 'center',
                                    },
                                    'is_valid': {
                                    'value': 1,
                                    },
                                    'text_color': {
                                    'value': 'neutral_white',
                                    },
                                    'hover_color': {
                                    'value': 'transparent',
                                    },
                                    'border_color': {
                                    'value': 'transparent',
                                    },
                                    'background_color': {
                                    'value': 'error',
                                    },
                                    'border_radius': {
                                    'value': 8,
                                    },
                                    'icon_spacing': {
                                    'value': 8,
                                    },
                                    'icon_padding': {
                                    'value': 5,
                                    },
                                    'text_align': {
                                    'value': 'center',
                                    },
                                    'leading_icon': {
                                    'widget_id': {
                                        'value': 'flutter_svg',
                                    },
                                    'widget_type': {
                                        'value': 'flutter_svg',
                                    },
                                    'mode': {
                                        'value': 'network',
                                    },
                                    'icon_color': {
                                        'value': 'neutral_white',
                                    },
                                    'data': {
                                        'value': 'https://files.svgcdn.io/uil/rocket.svg',
                                    },
                                    },
                                },
                                },
                            }
                            ],
                        },
                        },
                    'search': {
                      'events': {
                        'on_submit': {
                        'workflow_id': 'script_search',
                      }, 
                      },
                      'widget_id': 'search',
                      'field_width': 297,
                      'widget_type': 'search',
                      'initial_text': 'Search',
                      'pre_built_list': false,
                    },
                    'advanced_filter': {
                      'style': {
                        'title': 'Advanced Filter',
                        'button_text': 'Clear All',
                        'button_width': 100,
                        'button_heigth': 35,
                      },
                      'toggle': {
                        'size': 40,
                        'style': {
                          'vertical': false,
                          'has_border': false,
                          'border_color': 'primary',
                          'border_radius': {
                            'top_left': 0,
                            'bottom_left': 0,
                          },
                          'selected_fill_color': 'primary',
                          'selected_item_color': 'neutral_white',
                          'selected_border_color': 'primary',
                          'unselected_fill_color': 'primary',
                          'unselected_item_color': 'neutral_white',
                        },
                        'stacked': true,
                        'widget_list': [
                          {
                            'id': '1',
                            'type': 'icon',
                            'value': {
                              'unicode': {
                                'value': '0xf1de',
                              },
                              'icon_size': {
                                'value': 16,
                              },
                              'font_family': {
                                'value': 'FontAwesomeSolid',
                              },
                              'font_package': {
                                'value': 'font_awesome_flutter',
                              },
                            },
                          },
                          {
                            'id': '2',
                            'type': 'icon',
                            'value': {
                              'unicode': {
                                'value': '0xf053',
                              },
                              'icon_size': {
                                'value': 16,
                              },
                              'font_family': {
                                'value': 'FontAwesomeSolid',
                              },
                              'font_package': {
                                'value': 'font_awesome_flutter',
                              },
                            },
                          }
                        ],
                        'current_index': 0,
                      },
                      'actions': {
                        'get_advanced_filter_ui': {
                          'action': 'recordset_get_advanced_filter',
                          'meta_data': {
                            'app_cache_id': 'item_advanced_filters',
                          },
                        },
                      },
                      'widget_id': 'scripts_adv_filter',
                      'widget_list': [
                        {
                          'type': 'date_picker',
                          'widget': {
                            'data': {
                              'value': '',
                              'value_text': '',
                            },
                            'label': 'Created Date',
                            'show_action_buttons': false,
                            'validators': [
                              {
                                'message': 'Invalid date',
                                'validation': 'pattern',
                              }
                            ],
                            'view_mode': 'edit',
                            'widget_id': 'created_at',
                            'date_picker_size': 300,
                            'widget_type': 'date_picker',
                          },
                        },
                        {
                          'type': 'dropdown',
                          'widget': {
                            'data': {},
                            'type': 'single_select',
                            'title': 'Created By',
                            'widget_id': 'created_by',
                            'chip_style': {},
                            'widget_type': 'dropdown',
                            'show_buttons': false,
                            'dropdown_list': {
                              'data': [],
                              'style': {
                                'row_height': 40,
                                'header_row_height': 0,
                                'grid_lines_visibility': 'none',
                                'header_grid_lines_visibility': 'none',
                              },
                              'columns': [
                                {
                                  'type': 'text',
                                  'column_id': 'list',
                                },
                                {
                                  'type': 'dropdown_icon',
                                  'width': 40,
                                  'column_id': 'dropdown_icon_id',
                                  'icon_size': 14,
                                  'icon_color': 'primary',
                                  'column_name': '',
                                  'icon_unicode': '0xf00c',
                                  'row_alignment': 'end',
                                }
                              ],
                              'expanded': true,
                              'widget_id': 'created_by_list',
                              'widget_type': 'list_data_grid',
                              'query_search': false,
                              'enable_header': true,
                              'recordset_auto_load': true,
                            },
                          },
                        },
                        {
                          'type': 'dropdown',
                          'widget': {
                            'data': {},
                            'type': 'single_select',
                            'title': 'Type',
                            'widget_id': 'script_type',
                            'chip_style': {},
                            'widget_type': 'dropdown',
                            'show_buttons': false,
                            'dropdown_list': {
                              'data': [],
                              'style': {
                                'row_height': 40,
                                'header_row_height': 0,
                                'grid_lines_visibility': 'none',
                                'header_grid_lines_visibility': 'none',
                              },
                              'columns': [
                                {
                                  'type': 'text',
                                  'column_id': 'list',
                                },
                                {
                                  'type': 'dropdown_icon',
                                  'width': 40,
                                  'column_id': 'dropdown_icon_id',
                                  'icon_size': 14,
                                  'icon_color': 'primary',
                                  'column_name': '',
                                  'icon_unicode': '0xf00c',
                                  'row_alignment': 'end',
                                }
                              ],
                              'expanded': true,
                              'widget_id': 'script_type_list',
                              'widget_type': 'list_data_grid',
                              'query_search': false,
                              'enable_header': true,
                              'recordset_auto_load': true,
                            },
                          },
                        }
                      ],
                      'widget_type': 'advanced_filter',
                    },
                  'list_view': {
                    'data': {{ get(jinja_scripts_list, 'scripts_list_data') | tojson }},
                    'style': {
                      'row_height': 58,
                      'header_row_height': 40,
                    },
                    'columns': [
                      {
                        'type': 'text',
                        'column_id': 'script_id',
                        'column_name': 'ID',
                        'allow_sorting': false,
                      },
                      {
                        'type': 'text',
                        'column_id': 'script_title',
                        'column_name': 'Title',
                        'allow_sorting': false,
                      },
                      {
                        'type': 'text',
                        'column_id': 'output_type',
                        'column_name': 'Output Type',
                        'allow_sorting': false,
                      },
                      {
                        'type': 'text',
                        'column_id': 'updated_at',
                        'column_name': 'Updated At',
                        'allow_sorting': true,
                      }
                    ],
                    'widget_id': 'scripts',
                    'widget_type': 'list_data_grid',
                    'global_row_height': true,
                    'mouse_cursor': true,
                    'recordset_auto_load': true,
                  },
                  'widget_id': 'scripts_list',
                  'widget_type': 'power_list',
                  'padding_menu': {
                    'top': 5,
                    'left': 0,
                    'right': 0,
                    'bottom': 0,
                  },
                }
              ],
            }
          ],
        }
      ],
    },
  },
  'data': {},
}""";
final jinjaData = {
  'jinja_scripts_list': {
    'scripts_list_data': [
      {
        'script_id': {
          'value': {
            'text': '5c61aa50-d001-487b-8c12-5b2380bdedd4',
          },
        },
        'script_title': {
          'value': {
            'text': 'No Title',
          },
        },
        'output_type': {
          'value': {
            'text': 'html',
          },
        },
        'updated_at': {
          'value': {
            'text': '-',
          },
        },
        'events': {
          'on_click': {
            'workflow_id': 'navigate_to_jinja_code_editor',
            'properties': {
              'jinja_script_id': '5c61aa50-d001-487b-8c12-5b2380bdedd4',
            },
          },
        },
        'description': 'Test HTML Test HTML Test HTML',
        'jinja_data':
            'ewogICAgInJlZnVuZF9pdGVtcyI6ICAgWwogICAgICB7CiAgICAgICAgIml0ZW1fcXR5IjogMiwKICAgICAgICAiaXRlbV9jb2RlIjogIlNLVS1BUEwtSVAxNS1DQVNFLUJMSyIsCiAgICAgICAgIml0ZW1faW1hZ2UiOiAiaHR0cHM6Ly9jZG4uZXhhbXBsZS5jb20vaW1hZ2VzL2lwaG9uZTE1LWNhc2UtYmxhY2sucG5nIiwKICAgICAgICAicXR5X2NyZWRpdGVkIjogMSwKICAgICAgICAiaXRlbV9jb3N0X3RleHQiOiAiJDE4LjAwIiwKICAgICAgICAiaXRlbV9wcmljZV90ZXh0IjogIiQyNC45OSIsCiAgICAgICAgInRyYW5zYWN0aW9uX2l0ZW1faWQiOiAiVEktOTgzNDcyMSIsCiAgICAgICAgInRyYW5zYWN0aW9uX2l0ZW1fdGl0bGUiOiAiaVBob25lIDE1IFByb3RlY3RpdmUgQ2FzZSDigJMgQmxhY2siLAogICAgICAgICJyZW1haW5pbmdfcXR5X3RvX2NyZWRpdCI6IDEKICAgICAgfSwKICAgICAgewogICAgICAgICJpdGVtX3F0eSI6IDIsCiAgICAgICAgIml0ZW1fY29kZSI6ICJTS1UtQVBMLUlQMTUtQ0FTRS1CTEsiLAogICAgICAgICJpdGVtX2ltYWdlIjogImh0dHBzOi8vY2RuLmV4YW1wbGUuY29tL2ltYWdlcy9pcGhvbmUxNS1jYXNlLWJsYWNrLnBuZyIsCiAgICAgICAgInF0eV9jcmVkaXRlZCI6IDEsCiAgICAgICAgIml0ZW1fY29zdF90ZXh0IjogIiQxOC4wMCIsCiAgICAgICAgIml0ZW1fcHJpY2VfdGV4dCI6ICIkMjQuOTkiLAogICAgICAgICJ0cmFuc2FjdGlvbl9pdGVtX2lkIjogIlRJLTk4MzQ3MjEiLAogICAgICAgICJ0cmFuc2FjdGlvbl9pdGVtX3RpdGxlIjogImlQaG9uZSAxNSBQcm90ZWN0aXZlIENhc2Ug4oCTIEJsYWNrIiwKICAgICAgICAicmVtYWluaW5nX3F0eV90b19jcmVkaXQiOiAxCiAgICAgIH0KICAgIF0sCiAgICAidHJhbnNhY3Rpb25faWQiOiAiVFgtNTg3MjM0ODkiLAogICAgInRyYW5zYWN0aW9uX2NvZGUiOiAiT1JELTIwMjUtMDAxOTIzIiwKICAgICJ0cmFuc2FjdGlvbl9kYXRlX3RleHQiOiAiMjAyNS0wMi0xNCAxNjoyMzoxMCIKICB9',
        'jinja_script':
            'eyUgaWYgcmVmdW5kX2l0ZW1zICV9CiAgICB7JSBmb3IgaXRlbSBpbiByZWZ1bmRfaXRlbXMgJX0KPGJvZHk+CiAgICA8ZGl2IGNsYXNzPSdjb250YWluZXInIHN0eWxlPSdwYWRkaW5nOiA1cHg7IGJvcmRlci1yYWRpdXM6IDEwcHgnPgoKICAgICAgICA8dGFibGUgY2xhc3M9J3RhYmxlJyBzdHlsZT0nbWFyZ2luLWxlZnQ6M3B4O3dpZHRoOiAxMDAlJyBjdXN0b20td2lkdGg9JzEwMCUnPgogICAgICAgICAgICA8dGJvZHk+CiAgICAgICAgICAgICAgICA8dHI+CiAgICAgICAgICAgICAgICAgICAgPHRkIHZhbGlnbj0ndG9wJz4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiBhbGlnbj0nbGVmdCcgc3R5bGU9J2ZvbnQtc2l6ZTogMTZweDsnPgogICAgICAgICAgICAgICAgICAgICAgICAgICAge3tpdGVtLml0ZW1fY29kZX19CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8c3BhbiBzdHlsZT0nZGlzcGxheTogaW5saW5lLWJsb2NrOyBtYXJnaW4tbGVmdDogMTJweCc+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAge3tpdGVtLnRyYW5zYWN0aW9uX2l0ZW1fdGl0bGUgfCBiNjRkZWNvZGV9fQogICAgICAgICAgICAgICAgICAgICAgICAgICAgPC9zcGFuPgogICAgICAgICAgICAgICAgICAgICAgICA8L2Rpdj4KICAgICAgICAgICAgICAgICAgICA8L3RkPgogICAgICAgICAgICAgICAgPC90cj4KCiAgICAgICAgICAgICAgICA8dHI+CiAgICAgICAgICAgICAgICAgICAgPHRkIHZhbGlnbj0ndG9wJz4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiBhbGlnbj0nbGVmdCcgc3R5bGU9J2ZvbnQtc2l6ZTogMTRweDsnPgogICAgICAgICAgICAgICAgICAgICAgICAgICAge3t0cmFuc2FjdGlvbl9jb2RlfX0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxzcGFuIHN0eWxlPSdkaXNwbGF5OiBpbmxpbmUtYmxvY2s7IG1hcmdpbi1sZWZ0OiA4cHgnPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHt7dHJhbnNhY3Rpb25fZGF0ZV90ZXh0fX0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwvc3Bhbj4KICAgICAgICAgICAgICAgICAgICAgICAgPC9kaXY+CiAgICAgICAgICAgICAgICAgICAgPC90ZD4KICAgICAgICAgICAgICAgIDwvdHI+CiAgICAgICAgICAgIDwvdGJvZHk+CiAgICAgICAgPC90YWJsZT4KCiAgICAgICAgPHRhYmxlIGNsYXNzPSd0YWJsZScgc3R5bGU9J21hcmdpbi1sZWZ0OjNweDsgcGFkZGluZy1ib3R0b206NXB4OyB3aWR0aDogMTAwJScgY3VzdG9tLXdpZHRoPScxMDAlJz4KICAgICAgICAgICAgPHRib2R5PgoKICAgICAgICAgICAgICAgIDx0cj4KICAgICAgICAgICAgICAgICAgICA8dGQgcm93c3Bhbj0nNCcgYWxpZ249J2xlZnQnIHZhbGlnbj0ndG9wJz4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiBhbGlnbj0nbGVmdCc+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8Y3VzdG9tLWltYWdlIHNyYz0ne3tpdGVtLml0ZW1faW1hZ2V9fScgd2lkdGg9JzcwJyBoZWlnaHQ9JzcwJyBhbGlnbj0ndG9wJyB2YWxpZ249J3RvcCcgLz4KICAgICAgICAgICAgICAgICAgICAgICAgPC9kaXY+CiAgICAgICAgICAgICAgICAgICAgPC90ZD4KCiAgICAgICAgICAgICAgICAgICAgPHRkIGN1c3RvbS13aWR0aD0nMTglJyB2YWxpZ249J3RvcCc+CiAgICAgICAgICAgICAgICAgICAgICAgIDxkaXYgYWxpZ249J3JpZ2h0JyBzdHlsZT0nZm9udC1zaXplOiAxNHB4OyBjb2xvcjojM0Y0MDQ5Oyc+SXRlbSBRdHk8L2Rpdj4KICAgICAgICAgICAgICAgICAgICA8L3RkPgoKICAgICAgICAgICAgICAgICAgICA8dGQgY3VzdG9tLXdpZHRoPScyOCUnIHZhbGlnbj0ndG9wJz4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiBhbGlnbj0ncmlnaHQnIHN0eWxlPSdmb250LXNpemU6IDE0cHg7Y29sb3I6IzNGNDA0OTsnPlF0eSBQcmV2LiBDcmVkaXRlZDwvZGl2PgogICAgICAgICAgICAgICAgICAgIDwvdGQ+CgogICAgICAgICAgICAgICAgICAgIDx0ZCBjdXN0b20td2lkdGg9JzI3JScgdmFsaWduPSd0b3AnPgogICAgICAgICAgICAgICAgICAgICAgICA8ZGl2IGFsaWduPSdyaWdodCcgc3R5bGU9J2ZvbnQtc2l6ZTogMTRweDtjb2xvcjojM0Y0MDQ5Oyc+UXVhbnRpdHk8L2Rpdj4KICAgICAgICAgICAgICAgICAgICA8L3RkPgoKICAgICAgICAgICAgICAgICAgICA8dGQgY3VzdG9tLXdpZHRoPScyNyUnIHZhbGlnbj0ndG9wJz4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiBhbGlnbj0ncmlnaHQnIHN0eWxlPSdmb250LXNpemU6IDE0cHg7Y29sb3I6IzNGNDA0OTsnPkNyZWRpdCBFYWNoPC9kaXY+CiAgICAgICAgICAgICAgICAgICAgPC90ZD4KICAgICAgICAgICAgICAgIDwvdHI+CgogICAgICAgICAgICAgICAgPHRyPgogICAgICAgICAgICAgICAgICAgIDx0ZCBjdXN0b20td2lkdGg9JzE4JScgdmFsaWduPSd0b3AnPgogICAgICAgICAgICAgICAgICAgICAgICA8ZGl2IGFsaWduPSdyaWdodCcgc3R5bGU9J2ZvbnQtc2l6ZTogMTRweDsnPnt7aXRlbS5pdGVtX3F0eX19PC9kaXY+CiAgICAgICAgICAgICAgICAgICAgPC90ZD4KCiAgICAgICAgICAgICAgICAgICAgPHRkIGN1c3RvbS13aWR0aD0nMjglJyB2YWxpZ249J3RvcCc+CiAgICAgICAgICAgICAgICAgICAgICAgIDxkaXYgYWxpZ249J3JpZ2h0JyBzdHlsZT0nZm9udC1zaXplOiAxNHB4Oyc+e3tpdGVtLnF0eV9jcmVkaXRlZH19PC9kaXY+CiAgICAgICAgICAgICAgICAgICAgPC90ZD4KCiAgICAgICAgICAgICAgICAgICAgPHRkIGN1c3RvbS13aWR0aD0nMjclJyB2YWxpZ249J3RvcCcgYWxpZ249J3JpZ2h0Jz4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiBhbGlnbj0ncmlnaHQnIGN1c3RvbS13aWR0aD0nMTAwJScgaGVpZ2h0PSc1MCcgc3R5bGU9J2Rpc3BsYXk6IGZsZXg7IGp1c3RpZnktY29udGVudDogZmxleC1lbmQ7Jz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxkaXYgYWxpZ249J3JpZ2h0JyBzdHlsZT0nZm9udC1zaXplOiAxNHB4OycgY3VzdG9tLXdpZHRoPSc2MCUnIGhlaWdodD0nNTAnPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx0ZXh0ZmllbGQKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgZm9ybWF0dGVyPSdmb3JtYXRfZGVjaW1hbCcKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdmFsaWRhdGlvbj0nbWF4JwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBtYXg9J3t7aXRlbS5yZW1haW5pbmdfcXR5X3RvX2NyZWRpdH19JwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB2YWxpZGF0aW9uX21lc3NhZ2U9JyN7e2l0ZW0uaXRlbV9jb2RlfX06IHt7cmVtYWluaW5nX3F0eV90b19jcmVkaXR9fSBpdGVtcyBjYW4gYmUgcmVmdW5kZWQuIFBsZWFzZSBhZGp1c3QgdGhlIGVudGVyZWQgcXR5LicKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgcmVxdWlyZWRfdmFsaWRhdGlvbl9tZXNzYWdlPScje3tpdGVtLml0ZW1fY29kZX19OiBUaGUgUXVhbnRpdHkgZmllbGQgaXMgcmVxdWlyZWQnCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHdpZGdldF9pZD0ncXR5X3RvX2NyZWRpdCcKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgYWxpZ249J3JpZ2h0JwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBmb3JtYXR0ZXI9J2Zvcm1hdF9kZWNpbWFsJwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgID48L3RleHRmaWVsZD4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwvZGl2PgogICAgICAgICAgICAgICAgICAgICAgICA8L2Rpdj4KICAgICAgICAgICAgICAgICAgICA8L3RkPgoKICAgICAgICAgICAgICAgICAgICA8dGQgY3VzdG9tLXdpZHRoPScyNyUnIHZhbGlnbj0ndG9wJyBhbGlnbj0ncmlnaHQnPgogICAgICAgICAgICAgICAgICAgICAgICA8ZGl2IGFsaWduPSdyaWdodCcgY3VzdG9tLXdpZHRoPScxMDAlJyBzdHlsZT0nZGlzcGxheTogZmxleDsganVzdGlmeS1jb250ZW50OiBmbGV4LWVuZDsnPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiBhbGlnbj0ncmlnaHQnIHN0eWxlPSdmb250LXNpemU6IDE0cHg7JyBjdXN0b20td2lkdGg9JzYwJSc+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHRleHRmaWVsZAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBmb3JtYXR0ZXI9J3ByaWNpbmcnCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHZhbGlkYXRpb249J21heCcKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgbWF4PSd7e2l0ZW0uaXRlbV9wcmljZV90ZXh0fX0nCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHZhbGlkYXRpb25fbWVzc2FnZT0nI3t7aXRlbS5pdGVtX2NvZGV9fTogVGhlIGl0ZW0gd2FzIHNvbGQgZm9yIHt7aXRlbS5pdGVtX3ByaWNlX3RleHR9fSBhbmQgeW91IGhhdmUgZW50ZXJlZCBhIGhpZ2hlciBjcmVkaXQgcHJpY2UuIFBsZWFzZSBhZGp1c3QgdGhlIGNyZWRpdCBwcmljZS4nCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHJlcXVpcmVkX3ZhbGlkYXRpb25fbWVzc2FnZT0nI3t7aXRlbS5pdGVtX2NvZGV9fTogVGhlIFByaWNlIGZpZWxkIGlzIHJlcXVpcmVkJwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB3aWRnZXRfaWQ9J2NyZWRpdF9lYWNoJwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBhbGlnbj0ncmlnaHQnCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPjwvdGV4dGZpZWxkPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPC9kaXY+CiAgICAgICAgICAgICAgICAgICAgICAgIDwvZGl2PgogICAgICAgICAgICAgICAgICAgIDwvdGQ+CiAgICAgICAgICAgICAgICA8L3RyPgoKICAgICAgICAgICAgICAgIDx0cj4KICAgICAgICAgICAgICAgICAgICA8dGQgY3VzdG9tLXdpZHRoPScxOCUnIHZhbGlnbj0ndG9wJz4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiBhbGlnbj0ncmlnaHQnIHN0eWxlPSdmb250LXNpemU6IDE0cHg7Y29sb3I6IzNGNDA0OTsnPkl0ZW0gUHJpY2U8L2Rpdj4KICAgICAgICAgICAgICAgICAgICA8L3RkPgoKICAgICAgICAgICAgICAgICAgICA8dGQgY3VzdG9tLXdpZHRoPScyOCUnIHZhbGlnbj0ndG9wJz4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiBhbGlnbj0ncmlnaHQnIHN0eWxlPSdmb250LXNpemU6IDE0cHg7Y29sb3I6IzNGNDA0OTsnPlF0eSBSZW0uIHRvIENyZWRpdDwvZGl2PgogICAgICAgICAgICAgICAgICAgIDwvdGQ+CgogICAgICAgICAgICAgICAgICAgIDx0ZCBjdXN0b20td2lkdGg9JzI3JScgdmFsaWduPSd0b3AnPgogICAgICAgICAgICAgICAgICAgICAgICA8ZGl2IGFsaWduPSdyaWdodCcgc3R5bGU9J2ZvbnQtc2l6ZTogMTRweDtjb2xvcjojM0Y0MDQ5Oyc+UmVzdG9jayBJdGVtPC9kaXY+CiAgICAgICAgICAgICAgICAgICAgPC90ZD4KCiAgICAgICAgICAgICAgICAgICAgPHRkIGN1c3RvbS13aWR0aD0nMjclJyB2YWxpZ249J3RvcCc+CiAgICAgICAgICAgICAgICAgICAgICAgIDxkaXYgYWxpZ249J3JpZ2h0JyBzdHlsZT0nZm9udC1zaXplOiAxNHB4Oyc+VG90YWwgQ3JlZGl0PC9kaXY+CiAgICAgICAgICAgICAgICAgICAgPC90ZD4KICAgICAgICAgICAgICAgIDwvdHI+CgogICAgICAgICAgICAgICAgPHRyPgogICAgICAgICAgICAgICAgICAgIDx0ZCBjdXN0b20td2lkdGg9JzE4JScgdmFsaWduPSd0b3AnPgogICAgICAgICAgICAgICAgICAgICAgICA8ZGl2IGFsaWduPSdyaWdodCcgc3R5bGU9J2ZvbnQtc2l6ZTogMTRweDsnPnt7aXRlbS5pdGVtX3ByaWNlX3RleHR9fTwvZGl2PgogICAgICAgICAgICAgICAgICAgIDwvdGQ+CgogICAgICAgICAgICAgICAgICAgIDx0ZCBjdXN0b20td2lkdGg9JzI4JScgdmFsaWduPSd0b3AnPgogICAgICAgICAgICAgICAgICAgICAgICA8ZGl2IGFsaWduPSdyaWdodCcgc3R5bGU9J2ZvbnQtc2l6ZTogMTRweDsnPnt7aXRlbS5yZW1haW5pbmdfcXR5X3RvX2NyZWRpdH19PC9kaXY+CiAgICAgICAgICAgICAgICAgICAgPC90ZD4KCiAgICAgICAgICAgICAgICAgICAgPHRkIGN1c3RvbS13aWR0aD0nMjclJyB2YWxpZ249J3RvcCcgYWxpZ249J3JpZ2h0Jz4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiBhbGlnbj0ncmlnaHQnIGN1c3RvbS13aWR0aD0nMTAwJScgc3R5bGU9J2Rpc3BsYXk6IGZsZXg7IGp1c3RpZnktY29udGVudDogZmxleC1lbmQ7Jz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxkaXYgYWxpZ249J3JpZ2h0JyBzdHlsZT0nZm9udC1zaXplOiAxNHB4Oyc+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHN3aXRjaCB3aWRnZXRfaWQ9J3Jlc3RvY2tfaXRlbScgZWRpdGFibGU9JzEnIGFsaWduPSdyaWdodCc+PC9zd2l0Y2g+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L2Rpdj4KICAgICAgICAgICAgICAgICAgICAgICAgPC9kaXY+CiAgICAgICAgICAgICAgICAgICAgPC90ZD4KCiAgICAgICAgICAgICAgICAgICAgPHRkIGN1c3RvbS13aWR0aD0nMjclJyB2YWxpZ249J3RvcCc+CiAgICAgICAgICAgICAgICAgICAgICAgIDxkaXYgYWxpZ249J3JpZ2h0JyBzdHlsZT0nZm9udC1zaXplOiAxNHB4Oyc+PC9kaXY+CiAgICAgICAgICAgICAgICAgICAgPC90ZD4KICAgICAgICAgICAgICAgIDwvdHI+CgogICAgICAgICAgICA8L3Rib2R5PgogICAgICAgIDwvdGFibGU+CgogICAgPC9kaXY+CjwvYm9keT4KCnslIGlmIG5vdCBsb29wLmxhc3QgJX0sIHslIGVuZGlmICV9CiAgICB7JSBlbmRmb3IgJX0KeyUgZW5kaWYgJX0=',
      },
      {
        'script_id': {
          'value': {
            'text': '6682033f-2ac3-4f75-9179-b95c0c48813e',
          },
        },
        'script_title': {
          'value': {
            'text': 'No Title',
          },
        },
        'output_type': {
          'value': {
            'text': 'json',
          },
        },
        'updated_at': {
          'value': {
            'text': '-',
          },
        },
        'events': {
          'on_click': {
            'workflow_id': 'navigate_to_jinja_code_editor',
            'properties': {
              'jinja_script_id': '6682033f-2ac3-4f75-9179-b95c0c48813e',
            },
          },
        },
        'description':
            'Test Json Test Json Test Json Test JsonTest Json Test Json Test Json Test JsonTest Json Test Json Test Json Test JsonTest Json Test Json Test Json Test Json',
        'json_data':
            'ewogICAgImVuZF95ZWFyIjogIjIwMzAiLAogICAgImxhc3RfbmFtZSI6ICJTbWl0aGQgIiwKICAgICJzb3J0X25hbWUiOiAiU21pdGhkLCBCZW4gIiwKICAgICJmaXJzdF9uYW1lIjogIkJlbiAiLAogICAgIm1ha2VyX25hbWUiOiAiQmVuICBTbWl0aGQiLAogICAgIm1ha2VyX3RhZ3MiOiBbCiAgICAgICAgewogICAgICAgICAgICAiaWQiOiAibWFrZXJfZmVtYWxlIiwKICAgICAgICAgICAgInNlbGVjdGVkIjogZmFsc2UsCiAgICAgICAgICAgICJ2YWx1ZV90ZXh0IjogIkZlbWFsZSIKICAgICAgICB9CiAgICBdLAogICAgIm1ha2VyX3R5cGUiOiBbCiAgICAgICAgewogICAgICAgICAgICAiaWQiOiAiZ2xhc3NtYWtlciIsCiAgICAgICAgICAgICJzZWxlY3RlZCI6IGZhbHNlLAogICAgICAgICAgICAidmFsdWVfdGV4dCI6ICJHbGFzc21ha2VyIgogICAgICAgIH0sCiAgICAgICAgewogICAgICAgICAgICAiaWQiOiAiYnJhbmQiLAogICAgICAgICAgICAic2VsZWN0ZWQiOiBmYWxzZSwKICAgICAgICAgICAgInZhbHVlX3RleHQiOiAiQnJhbmQiCiAgICAgICAgfSwKICAgICAgICB7CiAgICAgICAgICAgICJpZCI6ICJob3VzZSIsCiAgICAgICAgICAgICJzZWxlY3RlZCI6IGZhbHNlLAogICAgICAgICAgICAidmFsdWVfdGV4dCI6ICJIb3VzZSIKICAgICAgICB9CiAgICBdLAogICAgInN0YXJ0X3llYXIiOiAiMTk5OCIsCiAgICAiY291bnRyeV9saXN0IjogWwogICAgICAgIHsKICAgICAgICAgICAgImlkIjogIkFGIiwKICAgICAgICAgICAgInNlbGVjdGVkIjogZmFsc2UsCiAgICAgICAgICAgICJ2YWx1ZV90ZXh0IjogIkFmZ2hhbmlzdGFuIgogICAgICAgIH0sCiAgICAgICAgewogICAgICAgICAgICAiaWQiOiAiQUwiLAogICAgICAgICAgICAic2VsZWN0ZWQiOiBmYWxzZSwKICAgICAgICAgICAgInZhbHVlX3RleHQiOiAiQWxiYW5pYSIKICAgICAgICB9CiAgICBdCn0=',
        'jinja_script':
            'ewogICJmbHV0dGVyX2FjdGlvbnMiOiBbCiAgICB7CiAgICAgICJmbHV0dGVyX2FjdGlvbiI6ICJ1cGRhdGVfd2lkZ2V0IiwKICAgICAgInVwZGF0ZV93aWRnZXRzIjogWwogICAgICAgIHsKICAgICAgICAgICJ2YWx1ZSI6IHsKICAgICAgICAgICAgInZhbHVlIjogewogICAgICAgICAgICAgICJjb250ZW50IjogWwogICAgICAgICAgICAgICAgewogICAgICAgICAgICAgICAgICAiZGF0YSI6IHsKICAgICAgICAgICAgICAgICAgICAid2lkZ2V0X2lkIjogIm1ha2VyX3Byb2ZpbGVfdWkiLAogICAgICAgICAgICAgICAgICAgICJyZWNvcmRzZXRfYXV0b19sb2FkIjogZmFsc2UKICAgICAgICAgICAgICAgICAgfSwKICAgICAgICAgICAgICAgICAgImNvbnRyb2xzIjogWwogICAgICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICAgICJ0eXBlIjogIndpZGdldF9ncm91cCIsCiAgICAgICAgICAgICAgICAgICAgICAiY29udHJvbHMiOiBbCiAgICAgICAgICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICAgICAgICAidHlwZSI6ICJ0ZXh0X2ZpZWxkIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAidGl0bGUiOiAiRmlyc3QgTmFtZSIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgIndpZGdldCI6IHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJkYXRhIjogewogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAidmFsdWUiOiAie3tmaXJzdF9uYW1lfX0iCiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgIm1vZGUiOiAidmlldyIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAic3R5bGUiOiB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJsYWJlbF90ZXh0IjogIkZpcnN0IE5hbWUiCiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgIndpZGdldF9pZCI6ICJmaXJzdF9uYW1lIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJhdXRvX2ZvY3VzIjogdHJ1ZSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ3aWRnZXRfdHlwZSI6ICJ0ZXh0X2ZpZWxkX2xhYmVsIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJsYWJlbF92aXNpYmxlIjogdHJ1ZQogICAgICAgICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICAgICAgfSwKICAgICAgICAgICAgICAgICAgICAgICAgewogICAgICAgICAgICAgICAgICAgICAgICAgICJ0eXBlIjogInRleHRfZmllbGQiLAogICAgICAgICAgICAgICAgICAgICAgICAgICJ0aXRsZSI6ICJMYXN0IE5hbWUgb3IgQ29tcGFueSBOYW1lIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAid2lkZ2V0IjogewogICAgICAgICAgICAgICAgICAgICAgICAgICAgImRhdGEiOiB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ2YWx1ZSI6ICJ7e2xhc3RfbmFtZX19IgogICAgICAgICAgICAgICAgICAgICAgICAgICAgfSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJtb2RlIjogInZpZXciLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgInN0eWxlIjogewogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAibGFiZWxfdGV4dCI6ICJMYXN0IE5hbWUgb3IgQ29tcGFueSBOYW1lIgogICAgICAgICAgICAgICAgICAgICAgICAgICAgfSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ3aWRnZXRfaWQiOiAibGFzdF9uYW1lIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ3aWRnZXRfdHlwZSI6ICJ0ZXh0X2ZpZWxkX2xhYmVsIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJsYWJlbF92aXNpYmxlIjogdHJ1ZQogICAgICAgICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICAgICAgfSwKICAgICAgICAgICAgICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgInR5cGUiOiAidGV4dF9maWVsZCIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgInRpdGxlIjogIlNvcnQgTmFtZSIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgIndpZGdldCI6IHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJkYXRhIjogewogICAgICAgICAgICAgICAgInZhbHVlIjogInslIGlmIHNvcnRfbmFtZSAlfXt7c29ydF9uYW1lfX17JWVsc2UlfXt7bGFzdF9uYW1lfX17JSBpZiBmaXJzdF9uYW1lJX0seyVlbmRpZiV9IHt7Zmlyc3RfbmFtZX19eyVlbmRpZiV9IgogICAgICAgICAgICAgICAgICAgICAgICAgICAgfSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJtb2RlIjogInZpZXciLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgInN0eWxlIjogewogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAibGFiZWxfdGV4dCI6ICJTb3J0IE5hbWUiCiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgIndpZGdldF9pZCI6ICJzb3J0X25hbWUiLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgIndpZGdldF90eXBlIjogInRleHRfZmllbGRfbGFiZWwiLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgImxhYmVsX3Zpc2libGUiOiB0cnVlCiAgICAgICAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgICAgICAgICB9XX0sCiAgICAgICAgICAgICAgICAgICAgewogICAgICAgICAgICAgICAgICAgICAgICJ0eXBlIjogIndpZGdldF9ncm91cCIsCiAgICAgICAgICAgICAgICAgICAgICAiY29udHJvbHMiOiBbCiAgICAgICAgICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICAgICAgICAidHlwZSI6ICJ5ZWFyX3BpY2tlciIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgIndpZGdldCI6IHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ3aWRnZXRfaWQiOiAic3RhcnRfeWVhciIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAid2lkZ2V0X3R5cGUiOiAiZGF0ZV95ZWFyX3BpY2tlciIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAibGFiZWwiOiAiU3RhcnQgWWVhciIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAiaWNvbiI6IHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInVuaWNvZGUiOiAiMHhmMTMzIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImljb25fY29sb3IiOiAicHJpbWFyeSIKICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0sCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAidmFsaWRhdG9yIjogWwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInZhbGlkYXRpb24iOiAicGF0dGVybiIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIm1lc3NhZ2UiOiAiSW52YWxpZCBkYXRlIgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICAgICAgICAgICAgICBdLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgImNvbnRhaW5lcl9tb2RlIjogZmFsc2UsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAiaG9yaXpvbnRhbF9sYXlvdXRfbW9kZSI6IGZhbHNlLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgInNpbmdsZV9zZWxlY3QiOiB0cnVlLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgInNob3dfYnV0dG9ucyI6IHRydWUsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAicmVjb3Jkc2V0X2F1dG9fbG9hZCI6IGZhbHNlLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgImRhdGEiOiB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJpbml0aWFsX2RhdGUiOiB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInllYXIiOiAie3tzdGFydF95ZWFyfX0iCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0sCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAidmlld19tb2RlIjogImVkaXQiCiAgICAgICAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgICAgICAgICB9LAogICAgICAgICAgICAgICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgInR5cGUiOiAieWVhcl9waWNrZXIiLAogICAgICAgICAgICAgICAgICAgICAgICAgICJ3aWRnZXQiOiB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAid2lkZ2V0X2lkIjogImVuZF95ZWFyIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ3aWRnZXRfdHlwZSI6ICJkYXRlX3llYXJfcGlja2VyIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJsYWJlbCI6ICJFbmQgWWVhciIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAiaWNvbiI6IHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInVuaWNvZGUiOiAiMHhmMTMzIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImljb25fY29sb3IiOiAicHJpbWFyeSIKICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0sCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAidmFsaWRhdG9yIjogWwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInZhbGlkYXRpb24iOiAicGF0dGVybiIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIm1lc3NhZ2UiOiAiSW52YWxpZCBkYXRlIgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICAgICAgICAgICAgICBdLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgImNvbnRhaW5lcl9tb2RlIjogZmFsc2UsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAiaG9yaXpvbnRhbF9sYXlvdXRfbW9kZSI6IGZhbHNlLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgInNpbmdsZV9zZWxlY3QiOiB0cnVlLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgInNob3dfYnV0dG9ucyI6IHRydWUsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAicmVjb3Jkc2V0X2F1dG9fbG9hZCI6IGZhbHNlLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgImRhdGEiOiB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJpbml0aWFsX2RhdGUiOiB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInllYXIiOiAie3tlbmRfeWVhcn19IgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgInZpZXdfbW9kZSI6ICJlZGl0IgogICAgICAgICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICAgICAgfV19LAogICAgICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICAgInR5cGUiOiAid2lkZ2V0X2dyb3VwIiwKICAgICAgICAgICAgICAgICAgICAgICJjb250cm9scyI6IFsKICAgICAgICAgICAgICAgICAgICAgICAgewogICAgICAgICAgICAgICAgICAgICAgICAgICJ0eXBlIjogImRyb3Bkb3duIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAidGl0bGUiOiAiVHlwZSIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgIndpZGdldCI6IHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJkYXRhIjogewogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiZHJvcGRvd25faXRlbXMiOiBbCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgeyUgaWYgbWFrZXJfdHlwZSBpcyBkZWZpbmVkICV9CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHslIGZvciB0eXBlIGluIG1ha2VyX3R5cGUgJX0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImlkIjogInt7dHlwZS5pZH19IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInZhbHVlX3RleHQiOiJ7e3R5cGUudmFsdWVfdGV4dH19IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJzZWxlY3RlZCI6IHslIGlmIHR5cGUuc2VsZWN0ZWQgaXMgZGVmaW5lZCAlfXt7c2VsZWN0ZWQgfCB0b0Jvb2wgfX17JWVsc2UlfWZhbHNleyVlbmRpZiV9CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAge3sgIiwgIiBpZiBub3QgbG9vcC5sYXN0IGVsc2UgIiIgfX0gIHslIGVuZGZvciAlfQogICAgeyUgZW5kaWYgJX0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgXQogICAgICAgICAgICAgICAgICAgICAgICAgICAgfSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ0eXBlIjogIm11bHRpX3NlbGVjdCIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAidGl0bGUiOiAiTWFrZXIgVHlwZSoiLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgIndpZGdldF9pZCI6ICJtYWtlcl90eXBlIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJjaGlwX3N0eWxlIjoge30sCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAiY2hpcF9tb2RlIjogdHJ1ZSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ3aWRnZXRfdHlwZSI6ICJkcm9wZG93biIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAibWV0YV9kYXRhIjogewogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAic2VhcmNoX2luX2xvY2FsIjogdHJ1ZSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImFwcF9jYWNoZV9pZCI6ICJtYWtlcl90eXBlX2xpc3RfdmlldyIKICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0sCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAidmFsaWRhdG9yIjogewogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAidmFsaWRhdGlvbl9tZXNzYWdlIjogIlRoaXMgZmllbGQgaXMgcmVxdWlyZWQiCiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgInNob3dfYnV0dG9ucyI6IGZhbHNlLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgImRyb3Bkb3duX2xpc3QiOiB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJkYXRhIjogW10sCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJzdHlsZSI6IHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAicm93X2hlaWdodCI6IDQwLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJoZWFkZXJfcm93X2hlaWdodCI6IDAsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImdyaWRfbGluZXNfdmlzaWJpbGl0eSI6ICJub25lIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiaGVhZGVyX2dyaWRfbGluZXNfdmlzaWJpbGl0eSI6ICJub25lIgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICB9LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiY29sdW1ucyI6IFsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAidHlwZSI6ICJ0ZXh0IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJjb2x1bW5faWQiOiAibGlzdCIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiY29sdW1uX25hbWUiOiAiIgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0sCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgewogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInR5cGUiOiAiZHJvcGRvd25faWNvbiIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAid2lkdGgiOiA0MCwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJjb2x1bW5faWQiOiAiZHJvcGRvd25faWNvbl9pZCIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiaWNvbl9zaXplIjogMTQsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiaWNvbl9jb2xvciI6ICJwcmltYXJ5IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJjb2x1bW5fbmFtZSI6ICIiLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImljb25fdW5pY29kZSI6ICIweGYwMGMiLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInJvd19hbGlnbm1lbnQiOiAiZW5kIgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgXSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImV4cGFuZGVkIjogZmFsc2UsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ3aWRnZXRfaWQiOiAibWFrZXJfdHlwZV9saXN0IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIndpZGdldF90eXBlIjogImxpc3RfZGF0YV9ncmlkIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInF1ZXJ5X3NlYXJjaCI6IGZhbHNlLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiZW5hYmxlX2hlYWRlciI6IHRydWUsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJyZWNvcmRzZXRfYWN0aW9uIjogIm1ha2VyX3R5cGVfbGlzdF92aWV3IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInJlY29yZHNldF9hdXRvX2xvYWQiOiB0cnVlCiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgICAgICAgICB9LAogICAgICAgICAgICAgICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgInR5cGUiOiAiZHJvcGRvd24iLAogICAgICAgICAgICAgICAgICAgICAgICAgICJ0aXRsZSI6ICJDb3VudHJ5IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAid2lkZ2V0IjogewogICAgICAgICAgICAgICAgICAgICAgICAgICAgImRhdGEiOiB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJkcm9wZG93bl9pdGVtcyI6IFsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB7JSBpZiBjb3VudHJ5X2xpc3QgaXMgZGVmaW5lZCAlfQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB7JSBmb3IgY291bnRyeSBpbiBjb3VudHJ5X2xpc3QgJX0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImlkIjogInt7Y291bnRyeS5pZH19IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInZhbHVlX3RleHQiOiJ7e2NvdW50cnkudmFsdWVfdGV4dH19IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJzZWxlY3RlZCI6IHslIGlmIGNvdW50cnkuc2VsZWN0ZWQgaXMgZGVmaW5lZCAlfXt7c2VsZWN0ZWQgfCB0b0Jvb2wgfX17JWVsc2UlfWZhbHNleyVlbmRpZiV9CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAge3sgIiwgIiBpZiBub3QgbG9vcC5sYXN0IGVsc2UgIiIgfX0gIHslIGVuZGZvciAlfQp7JSBlbmRpZiAlfQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICBdCiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgInR5cGUiOiAibXVsdGlfc2VsZWN0IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ0aXRsZSI6ICJ7JSBpZiBjb3VudHJ5X2xhYmVsICV9e3tjb3VudHJ5X2xhYmVsfX17JSBlbHNlICV9Q291bnRyeXslIGVuZGlmICV9IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJjaGlwX21vZGUiOiB0cnVlLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgIm1ldGFfZGF0YSI6IHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInNlYXJjaF9pbl9sb2NhbCI6IGZhbHNlCiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgIndpZGdldF9pZCI6ICJtYWtlcl9jb3VudHJ5IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJjaGlwX3N0eWxlIjoge30sCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAid2lkZ2V0X3R5cGUiOiAiZHJvcGRvd24iLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgInNob3dfYnV0dG9ucyI6IGZhbHNlLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgImRyb3Bkb3duX2xpc3QiOiB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJkYXRhIjogW10sCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJzdHlsZSI6IHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAicm93X2hlaWdodCI6IDQwLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJoZWFkZXJfcm93X2hlaWdodCI6IDAsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImdyaWRfbGluZXNfdmlzaWJpbGl0eSI6ICJub25lIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiaGVhZGVyX2dyaWRfbGluZXNfdmlzaWJpbGl0eSI6ICJub25lIgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICB9LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAic2VhcmNoIjogewogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ3aWRnZXRfaWQiOiAiY291bnRyeV9zZWFyY2giLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJmaWVsZF93aWR0aCI6IDI5NywKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAid2lkZ2V0X3R5cGUiOiAic2VhcmNoIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiaW5pdGlhbF90ZXh0IjogIlNlYXJjaCIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInByZV9idWlsdF9saXN0IjogZmFsc2UKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImNvbHVtbnMiOiBbCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgewogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInR5cGUiOiAidGV4dCIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiY29sdW1uX2lkIjogImxpc3QiCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAidHlwZSI6ICJkcm9wZG93bl9pY29uIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ3aWR0aCI6IDQwLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImNvbHVtbl9pZCI6ICJkcm9wZG93bl9pY29uX2lkIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJpY29uX3NpemUiOiAxNCwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJpY29uX2NvbG9yIjogInByaW1hcnkiLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImNvbHVtbl9uYW1lIjogIiIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiaWNvbl91bmljb2RlIjogIjB4ZjAwYyIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAicm93X2FsaWdubWVudCI6ICJlbmQiCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICBdLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiZXhwYW5kZWQiOiB0cnVlLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAid2lkZ2V0X2lkIjogImNvdW50cmllc19saXN0IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIndpZGdldF90eXBlIjogImxpc3RfZGF0YV9ncmlkIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInF1ZXJ5X3NlYXJjaCI6IGZhbHNlLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiZW5hYmxlX2hlYWRlciI6IHRydWUsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJyZWNvcmRzZXRfYWN0aW9uIjogImNvbnRhY3RfY291bnRyeV9saXN0X3ZpZXciLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAic2F2ZV9idXR0b25fY29sb3IiOiAid2hpdGUiLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAicmVjb3Jkc2V0X2F1dG9fbG9hZCI6IHRydWUKICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICAgICAgICB9LAogICAgICAgICAgICAgICAgICAgICAgICAgICJlZGl0X29ubHkiOiB0cnVlCiAgICAgICAgICAgICAgICAgICAgICAgIH0sCiAgICAgICAgICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICAgICAgICAidHlwZSI6ICJkcm9wZG93biIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgInRpdGxlIjogIlRhZ3MiLAogICAgICAgICAgICAgICAgICAgICAgICAgICJ3aWRnZXQiOiB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAiZGF0YSI6IHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImRyb3Bkb3duX2l0ZW1zIjogWwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB7JSBpZiBtYWtlcl90YWdzIGlzIGRlZmluZWQgJX0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgeyUgZm9yIHRhZyBpbiBtYWtlcl90YWdzICV9CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJpZCI6ICJ7e3RhZy5pZH19IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInZhbHVlX3RleHQiOiJ7e3RhZy52YWx1ZV90ZXh0fX0iLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInNlbGVjdGVkIjogeyUgaWYgdGFnLnNlbGVjdGVkIGlzIGRlZmluZWQgJX17e3NlbGVjdGVkIHwgdG9Cb29sIH19eyVlbHNlJX1mYWxzZXslZW5kaWYlfQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHt7ICIsICIgaWYgbm90IGxvb3AubGFzdCBlbHNlICIiIH19ICB7JSBlbmRmb3IgJX17JSBlbmRpZiAlfQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICBdCiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgInR5cGUiOiAibXVsdGlfc2VsZWN0IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ0aXRsZSI6ICJ7JSBpZiB0YWdfbGFiZWwgJX17e3RhZ19sYWJlbH19eyUgZWxzZSAlfVRhZ3N7JSBlbmRpZiAlfSIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAiY2hpcF9tb2RlIjogdHJ1ZSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJtZXRhX2RhdGEiOiB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJzZWFyY2hfaW5fbG9jYWwiOiBmYWxzZQogICAgICAgICAgICAgICAgICAgICAgICAgICAgfSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ3aWRnZXRfaWQiOiAibWFrZXJfdGFncyIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAiY2hpcF9zdHlsZSI6IHt9LAogICAgICAgICAgICAgICAgICAgICAgICAgICAgIndpZGdldF90eXBlIjogImRyb3Bkb3duIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJzaG93X2J1dHRvbnMiOiBmYWxzZSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJkcm9wZG93bl9saXN0IjogewogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiZGF0YSI6IFtdLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAic3R5bGUiOiB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInJvd19oZWlnaHQiOiA0MCwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiaGVhZGVyX3Jvd19oZWlnaHQiOiAwLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJncmlkX2xpbmVzX3Zpc2liaWxpdHkiOiAibm9uZSIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImhlYWRlcl9ncmlkX2xpbmVzX3Zpc2liaWxpdHkiOiAibm9uZSIKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInNlYXJjaCI6IHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAid2lkZ2V0X2lkIjogInRhZ3Nfc2VhcmNoIiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiZmllbGRfd2lkdGgiOiAyOTcsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIndpZGdldF90eXBlIjogInNlYXJjaCIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImluaXRpYWxfdGV4dCI6ICJTZWFyY2giLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJwcmVfYnVpbHRfbGlzdCI6IGZhbHNlCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0sCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJjb2x1bW5zIjogWwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJ0eXBlIjogInRleHQiLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImNvbHVtbl9pZCI6ICJsaXN0IgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0sCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgewogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInR5cGUiOiAiZHJvcGRvd25faWNvbiIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAid2lkdGgiOiA0MCwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJjb2x1bW5faWQiOiAiZHJvcGRvd25faWNvbl9pZCIsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiaWNvbl9zaXplIjogMTQsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAiaWNvbl9jb2xvciI6ICJwcmltYXJ5IiwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJjb2x1bW5fbmFtZSI6ICIiLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImljb25fdW5pY29kZSI6ICIweGYwMGMiLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInJvd19hbGlnbm1lbnQiOiAiZW5kIgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgXSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgImV4cGFuZGVkIjogdHJ1ZSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIndpZGdldF9pZCI6ICJtYWtlcl90YWdzX2xpc3QiLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAid2lkZ2V0X3R5cGUiOiAibGlzdF9kYXRhX2dyaWQiLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAicXVlcnlfc2VhcmNoIjogZmFsc2UsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJlbmFibGVfaGVhZGVyIjogdHJ1ZSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgInJlY29yZHNldF9hY3Rpb24iOiAibWFrZXJfdGFnc19saXN0X3ZpZXciLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAic2F2ZV9idXR0b25fY29sb3IiOiAid2hpdGUiLAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAicmVjb3Jkc2V0X2F1dG9fbG9hZCI6IHRydWUKICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICAgICAgICB9LAogICAgICAgICAgICAgICAgICAgICAgICAgICJlZGl0X29ubHkiOiB0cnVlCiAgICAgICAgICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgICAgICAgIF0KICAgICAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICAgIF0sCiAgICAgICAgICAgICAgICAgICJlZGl0YWJsZSI6IHRydWUsCiAgICAgICAgICAgICAgICAgICJ2aWV3X21vZGUiOiAiZWRpdCIsCiAgICAgICAgICAgICAgICAgICJzZW5kX2ppbmphX2RhdGEiOiB0cnVlLAogICAgICAgICAgICAgICAgICAiYmFja19idXR0b24iOiB7fSwKICAgICAgICAgICAgICAgICAgIndpZGdldF9pZCI6ICJtYWtlcl9wcm9maWxlX3VpIiwKICAgICAgICAgICAgICAgICAgInRpdGxlX3RleHQiOiAiTUFLRVIgUFJPRklMRSIsCiAgICAgICAgICAgICAgICAgICJzYXZlX2FjdGlvbiI6ICJtYWtlcl9wcm9maWxlX3NhdmUiLAogICAgICAgICAgICAgICAgICAid2lkZ2V0X3R5cGUiOiAiYmxvY2siLAogICAgICAgICAgICAgICAgICAiYmxvY2tfdmlld19tb2RlIjogewogICAgICAgICAgICAgICAgICAgICJtb2RlIjogImNvbHVtbl9tb2RlIgogICAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgXQogICAgICAgICAgICB9LAogICAgICAgICAgICAiYWN0aW9uIjogIk9QRU5fU0xJREVPVVQiCiAgICAgICAgICB9LAogICAgICAgICAgIndpZGdldF9pZCI6ICJtYWtlcl9wcm9maWxlX2RldGFpbHMiCiAgICAgICAgfQogICAgICBdCiAgICB9CiAgXQp9',
      }
    ],
  },
  'jinja_scripts_count': 2,
};

void main() async {
  try {
    final errors = <String?>[];

    // Setup MapLoader with base templates for inheritance and inclusion
    final loader = MapLoader({
      'base.html': '''
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}Default Title{% endblock %}</title>
</head>
<body>
    <header>{% block header %}Default Header{% endblock %}</header>
    <main>{% block content %}{% endblock %}</main>
    <footer>{% block footer %}Default Footer{% endblock %}</footer>
</body>
</html>
''',
      'macros.html': '''
{% macro render_user(user) %}
<div class="user">
    <h3>{{ user.name }}</h3>
    <p>Age: {{ user.age }}</p>
</div>
{% endmacro %}

{% macro render_product(product) %}
<div class="product">
    <h4>{{ product.name }}</h4>
    <p>Price: \${{ product.price }}</p>
</div>
{% endmacro %}

{% macro async_data_display(data) %}
<div class="data">
    {{ data }}
</div>
{% endmacro %}
''',
      'partial.html': '''
<div class="partial">
    <p>This is a partial template included via include.</p>
    <p>Current time: {{ now() }}</p>
</div>
''',
    });

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

    // example 3: real world example
    print('\n=== Example 3: Real world example ===');
    var template3 = env.fromString(jinjaScript);
    var result3 = await template3.renderAsync(jinjaData);
    print(result3.contains('instance')); // Should print: [1,2,3]

    // Example 4: Using environment globals
    print('\n=== Example 4: Using environment globals ===');

    Future<String> getUsername() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return 'Alice';
    }

    var template4 = env.fromString('Welcome to {{ app_name }}, {{ user }}!');
    var result4 = await template4.renderAsync({
      'app_name': 'My App',
      'user': getUsername(),
    });
    print(result4); // Should print: Welcome to My App, Alice!

    // Example 5: Async global in a loop
    print('\n=== Example 5: Async global in a loop ===');
    var template5 = env.fromString(
      '''
<ul>
{% for item in items %}
  <li>{{ item }}</li>
{% endfor %}
</ul>
''',
    );

    Future<String> fetchItem(int i) async {
      await Future<void>.delayed(Duration(milliseconds: 20 * i));
      return 'Item $i';
    }

    var result5 = await template5.renderAsync({
      'items': [fetchItem(1), fetchItem(2), fetchItem(3)],
    });
    print(result5.trim());

    // Example 6: Async global with a filter
    print('\n=== Example 6: Async global with a filter ===');
    var template6 = env.fromString('{{ name|upper }}');

    Future<String> getFilterName() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return 'filtered';
    }

    var result6 = await template6.renderAsync({'name': getFilterName()});
    print(result6); // Should print: FILTERED

    // Example 7: Nested async data structure
    print('\n=== Example 7: Nested async data structure ===');
    var template7 = env.fromString('User: {{ user.name }}, Age: {{ user.age }}');

    Future<Map<String, dynamic>> getUser() async {
      await Future<void>.delayed(const Duration(milliseconds: 60));
      return {'name': 'Bob', 'age': 30};
    }

    var result7 = await template7.renderAsync({'user': getUser()});
    print(result7); // Should print: User: Bob, Age: 30

    // Example 8: Synchronous global function with renderAsync
    print('\n=== Example 8: Synchronous global function with renderAsync ===');
    var template8 = env.fromString('{{- greet() -}}');

    String getSyncGreeting() {
      return 'Hi there';
    }

    var result8 = await template8.renderAsync({'greet': getSyncGreeting});
    print(result8); // Should print: Hi there

    // Example 9: Synchronous filter with renderAsync
    print('\n=== Example 9: Synchronous filter with renderAsync ===');
    var envWithFilter = Environment(
      filters: {...env.filters, 'reverse': (value) => value.toString().split('').reversed.join()},
      globals: env.globals,
      loader: env.loader,
    );
    var template9 = envWithFilter.fromString('{{ "hello"|reverse }}');
    var result9 = await template9.renderAsync();
    print(result9); // Should print: olleh

    // Example 10: Synchronous complex object with renderAsync
    print('\n=== Example 10: Synchronous complex object with renderAsync ===');
    var template10 = env.fromString('Product: {{ product.name }} - \${{ product.price }}');
    var product = {
      'name': 'Laptop',
      'price': 1200,
    };
    var result10 = await template10.renderAsync({'product': product});
    print(result10); // Should print: Product: Laptop - $1200

    if (errors.isNotEmpty) {
      print('\nErrors encountered:');
      errors.forEach(print);
    } else {
      print('\n=== All examples completed successfully! ===');
    }

    // Example 11: Async global in a loop
    print('\n=== Example 11: Async global in a loop ===');
    var template11 = env.fromString('{% for item in items %}{{ item }}{% endfor %}');
    var result11 = await template11.renderAsync({
      'items': [fetchItem(1), fetchItem(2), fetchItem(3)],
    });
    print(result11.trim());

    // Example 12: Async function for calling API with http
    print('\n=== Example 12: Async function for calling API with http');
    var template12 = env.fromString('{{ data }}');
    var result12 = await template12.renderAsync({
      'data': await fetchData(),
    });
    print(result12.trim());

    // Example 13: Async function for calling API with http
    print('\n=== Example 13: Async function for calling API with http');
    var template13 = env.fromString('{{ data }}');
    var result13 = await template13.renderAsync({
      'data': await fetchData(),
    });
    print(result13.trim());

    // Example 14: Async global in a filter
    print('\n=== Example 14: Async global in a filter ===');
    var template14 = env.fromString('{{ data|fetchDataFilter }}');
    var result14 = await template14.renderAsync();
    print(result14.trim());

    // Example 15: Async global in a global function
    print('\n=== Example 15: Async global in a global function ===');
    var template15 = env.fromString('{{ fetchDataGlobal() }}');
    var result15 = await template15.renderAsync();
    print(result15.trim());

    // ========== BUILT-IN GLOBALS DEMONSTRATION ==========

    // Example 16: Cycler global
    print('\n=== Example 16: Cycler global ===');
    var template16 = env.fromString('{% for i in range(5) %}{{ cycler("red", "blue", "green") }}{% endfor %}');
    var result16 = await template16.renderAsync();
    print(result16.trim());

    // Example 17: Joiner global
    print('\n=== Example 17: Joiner global ===');
    var template17 = env.fromString('{% set j = joiner(", ") %}{% for item in ["a", "b", "c"] %}{{ j() }}{{ item }}{% endfor %}');
    var result17 = await template17.renderAsync();
    print(result17.trim());

    // Example 18: Range global
    print('\n=== Example 18: Range global ===');
    var template18 = env.fromString('{% for i in range(1, 6) %}{{ i }}{% endfor %}');
    var result18 = await template18.renderAsync();
    print(result18.trim());

    // Example 19: Dict global
    print('\n=== Example 19: Dict global ===');
    var template19 = env.fromString('{{ dict(a=1, b=2, c=3) }}');
    var result19 = await template19.renderAsync();
    print(result19.trim());

    // Example 20: List global
    print('\n=== Example 20: List global ===');
    var template20 = env.fromString('{{ list("hello") }}');
    var result20 = await template20.renderAsync();
    print(result20.trim());

    // Example 21: Zip global
    print('\n=== Example 21: Zip global ===');
    var template21 = env.fromString('{% for pair in zip([1, 2, 3], ["a", "b", "c"]) %}{{ pair }}{% endfor %}');
    var result21 = await template21.renderAsync();
    print(result21.trim());

    // Example 22: Now global
    print('\n=== Example 22: Now global ===');
    var template22 = env.fromString('Current time: {{ now() }}');
    var result22 = await template22.renderAsync();
    print(result22.trim());

    // ========== COMPLEX FILTERS DEMONSTRATION ==========

    // Example 23: Map filter
    print('\n=== Example 23: Map filter ===');
    var template23 = env.fromString('{{ users|map(attribute="name")|list }}');
    var result23 = await template23.renderAsync({
      'users': [
        {'name': 'Alice', 'age': 25},
        {'name': 'Bob', 'age': 30},
        {'name': 'Charlie', 'age': 35},
      ],
    });
    print(result23.trim());

    // Example 24: Select filter
    print('\n=== Example 24: Select filter ===');
    var template24 = env.fromString('{{ users|select("defined")|list }}');
    var result24 = await template24.renderAsync({
      'users': [
        {'name': 'Alice', 'active': true},
        {'name': 'Bob', 'active': false},
        {'name': 'Charlie', 'active': true},
      ],
    });
    print(result24.trim());

    // Example 25: Reject filter
    print('\n=== Example 25: Reject filter ===');
    var template25 = env.fromString('{{ users|reject("defined")|list }}');
    var result25 = await template25.renderAsync({
      'users': [
        {'name': 'Alice', 'active': true},
        {'name': 'Bob', 'active': false},
        {'name': 'Charlie', 'active': true},
      ],
    });
    print(result25.trim());

    // Example 26: Groupby filter
    print('\n=== Example 26: Groupby filter ===');
    var template26 =
        env.fromString('{% for group in users|groupby("age") %}{{ group.key }}: {{ group.list|map(attribute="name")|list }}{% endfor %}');
    var result26 = await template26.renderAsync({
      'users': [
        {'name': 'Alice', 'age': 25},
        {'name': 'Bob', 'age': 30},
        {'name': 'Charlie', 'age': 25},
      ],
    });
    print(result26.trim());

    // Example 27: Sum filter
    print('\n=== Example 27: Sum filter ===');
    var template27 = env.fromString('Total: {{ numbers|sum }}');
    var result27 = await template27.renderAsync({
      'numbers': [1, 2, 3, 4, 5],
    });
    print(result27.trim());

    // Example 28: Sort filter
    print('\n=== Example 28: Sort filter ===');
    var template28 = env.fromString('{{ numbers|sort|list }}');
    var result28 = await template28.renderAsync({
      'numbers': [3, 1, 4, 1, 5],
    });
    print(result28.trim());

    // Example 29: Unique filter
    print('\n=== Example 29: Unique filter ===');
    var template29 = env.fromString('{{ numbers|unique|list }}');
    var result29 = await template29.renderAsync({
      'numbers': [1, 2, 2, 3, 3, 3],
    });
    print(result29.trim());

    // Example 30: Batch filter
    print('\n=== Example 30: Batch filter ===');
    var template30 = env.fromString('{% for batch in numbers|batch(3) %}{{ batch|list }}{% endfor %}');
    var result30 = await template30.renderAsync({
      'numbers': [1, 2, 3, 4, 5, 6, 7],
    });
    print(result30.trim());

    // Example 31: Slice filter
    print('\n=== Example 31: Slice filter ===');
    var template31 = env.fromString('{{ numbers|slice(3)|list }}');
    var result31 = await template31.renderAsync({
      'numbers': [1, 2, 3, 4, 5, 6, 7, 8, 9],
    });
    print(result31.trim());

    // Example 32: Selectattr filter
    print('\n=== Example 32: Selectattr filter ===');
    var template32 = env.fromString('{{ users|selectattr("active")|list }}');
    var result32 = await template32.renderAsync({
      'users': [
        {'name': 'Alice', 'active': true},
        {'name': 'Bob', 'active': false},
        {'name': 'Charlie', 'active': true},
      ],
    });
    print(result32.trim());

    // Example 33: Rejectattr filter
    print('\n=== Example 33: Rejectattr filter ===');
    var template33 = env.fromString('{{ users|rejectattr("active")|list }}');
    var result33 = await template33.renderAsync({
      'users': [
        {'name': 'Alice', 'active': true},
        {'name': 'Bob', 'active': false},
        {'name': 'Charlie', 'active': true},
      ],
    });
    print(result33.trim());

    // ========== CONTROL STRUCTURES DEMONSTRATION ==========

    // Example 34: Async if condition
    print('\n=== Example 34: Async if condition ===');
    Future<bool> checkCondition() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return true;
    }

    var template34 = env.fromString('{% if condition %}Condition is true{% else %}Condition is false{% endif %}');
    var result34 = await template34.renderAsync({
      'condition': checkCondition(),
    });
    print(result34.trim());

    // Example 35: Async for loop with else
    print('\n=== Example 35: Async for loop with else ===');
    Future<List<String>> getItems() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return ['item1', 'item2', 'item3'];
    }

    var template35 = env.fromString('{% for item in items %}{{ item }}{% else %}No items{% endfor %}');
    var result35 = await template35.renderAsync({
      'items': getItems(),
    });
    print(result35.trim());

    // Example 36: With statement
    print('\n=== Example 36: With statement ===');
    var template36 = env.fromString('{% with user = {"name": "Alice", "age": 25} %}{{ user.name }} is {{ user.age }} years old{% endwith %}');
    var result36 = await template36.renderAsync();
    print(result36.trim());

    // Example 37: Set statement
    print('\n=== Example 37: Set statement ===');
    var template37 = env.fromString('{% set name = "Bob" %}{{ name }}');
    var result37 = await template37.renderAsync();
    print(result37.trim());

    // Example 38: Set block
    print('\n=== Example 38: Set block ===');
    var template38 = env.fromString('{% set content %}<div>Hello World</div>{% endset %}{{ content }}');
    var result38 = await template38.renderAsync();
    print(result38.trim());

    // Example 39: For loop with loop variables
    print('\n=== Example 39: For loop with loop variables ===');
    var template39 = env.fromString('{% for item in items %}{{ loop.index }}: {{ item }}{% endfor %}');
    var result39 = await template39.renderAsync({
      'items': ['a', 'b', 'c'],
    });
    print(result39.trim());

    // ========== MACROS DEMONSTRATION ==========

    // Example 40: Define and use macro
    print('\n=== Example 40: Define and use macro ===');
    var template40 = env.fromString('''
{% macro greet(name) %}
Hello, {{ name }}!
{% endmacro %}
{{ greet("Alice") }}
{{ greet("Bob") }}
''');
    var result40 = await template40.renderAsync();
    print(result40.trim());

    // Example 41: Macro with default arguments
    print('\n=== Example 41: Macro with default arguments ===');
    var template41 = env.fromString('''
{% macro greet(name, greeting="Hi") %}
{{ greeting }}, {{ name }}!
{% endmacro %}
{{ greet("Alice") }}
{{ greet("Bob", "Hello") }}
''');
    var result41 = await template41.renderAsync();
    print(result41.trim());

    // Example 42: Macro with async data
    print('\n=== Example 42: Macro with async data ===');
    Future<Map<String, dynamic>> getUserData() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return {'name': 'Charlie', 'age': 30};
    }

    var template42 = env.fromString('''
{% macro display_user(user) %}
User: {{ user.name }}, Age: {{ user.age }}
{% endmacro %}
{{ display_user(user) }}
''');
    var result42 = await template42.renderAsync({
      'user': getUserData(),
    });
    print(result42.trim());

    // Example 43: Call block
    print('\n=== Example 43: Call block ===');
    var template43 = env.fromString('''
{% macro render_card(title) %}
<div class="card">
    <h2>{{ title }}</h2>
    {{ caller() }}
</div>
{% endmacro %}
{% call render_card("My Card") %}
    <p>This is the card content</p>
{% endcall %}
''');
    var result43 = await template43.renderAsync();
    print(result43.trim());

    // ========== INHERITANCE & INCLUSION DEMONSTRATION ==========

    // Example 44: Extends and blocks
    print('\n=== Example 44: Extends and blocks ===');
    var template44 = env.fromString('''
{% extends "base.html" %}
{% block title %}Custom Title{% endblock %}
{% block content %}
<h1>Custom Content</h1>
<p>This is custom content from child template.</p>
{% endblock %}
''');
    var result44 = await template44.renderAsync();
    print(result44.trim());

    // Example 45: Include
    print('\n=== Example 45: Include ===');
    var template45 = env.fromString('''
<div>
    <h1>Main Template</h1>
    {% include "partial.html" %}
</div>
''');
    var result45 = await template45.renderAsync();
    print(result45.trim());

    // Example 46: Import macros
    print('\n=== Example 46: Import macros ===');
    var template46 = env.fromString('''
{% import "macros.html" as macros %}
{{ macros.render_user({"name": "Alice", "age": 25}) }}
{{ macros.render_product({"name": "Laptop", "price": 1200}) }}
''');
    var result46 = await template46.renderAsync();
    print(result46.trim());

    // Example 47: From import
    print('\n=== Example 47: From import ===');
    var template47 = env.fromString('''
{% from "macros.html" import render_user %}
{{ render_user({"name": "Bob", "age": 30}) }}
''');
    var result47 = await template47.renderAsync();
    print(result47.trim());

    // ========== ERROR HANDLING & UTILITY STATEMENTS ==========

    // Example 48: Try catch
    print('\n=== Example 48: Try catch ===');
    var template48 = env.fromString('''
{% try %}
    {{ undefined_variable }}
{% catch %}
    Error: Variable is undefined
{% endtry %}
''');
    var result48 = await template48.renderAsync();
    print(result48.trim());

    // Example 49: Do statement
    print('\n=== Example 49: Do statement ===');
    var template49 = env.fromString('''
{% set items = [] %}
{% do items.add("item1") %}
{% do items.add("item2") %}
Items: {{ items|list }}
''');
    var result49 = await template49.renderAsync();
    print(result49.trim());

    // Example 50: Break in loop
    print('\n=== Example 50: Break in loop ===');
    var template50 = env.fromString('''
{% for i in range(10) %}
    {% if i == 5 %}{% break %}{% endif %}
    {{ i }}
{% endfor %}
''');
    var result50 = await template50.renderAsync();
    print(result50.trim());

    // Example 51: Continue in loop
    print('\n=== Example 51: Continue in loop ===');
    var template51 = env.fromString('''
{% for i in range(5) %}
    {% if i == 2 %}{% continue %}{% endif %}
    {{ i }}
{% endfor %}
''');
    var result51 = await template51.renderAsync();
    print(result51.trim());

    // ========== CUSTOM GLOBALS DEMONSTRATION ==========

    // Example 52: get_widget_by_id
    print('\n=== Example 52: get_widget_by_id ===');
    var template52 = env.fromString('{{ get_widget_by_id("widget123") }}');
    var result52 = await template52.renderAsync();
    print(result52.trim());

    // Example 53: callback
    print('\n=== Example 53: callback ===');
    var template53 = env.fromString('{{ callback("callback_id", {"key": "value"}) }}');
    var result53 = await template53.renderAsync();
    print(result53.trim());

    // Example 54: return function
    print('\n=== Example 54: return function ===');
    var template54 = env.fromString('{{ return([1, 2, 3]) }}');
    var result54 = await template54.renderAsync();
    print(result54.trim());

    // Example 55: is_equal with async
    print('\n=== Example 55: is_equal with async ===');
    Future<int> getValue() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return 42;
    }

    var template55 = env.fromString('{% if is_equal(value, 42) %}Equal{% else %}Not equal{% endif %}');
    var result55 = await template55.renderAsync({
      'value': getValue(),
    });
    print(result55.trim());

    // Example 56: translate
    print('\n=== Example 56: translate ===');
    var template56 = env.fromString('{{ translate("Hello", "en", "fr") }}');
    var result56 = await template56.renderAsync();
    print(result56.trim());

    // Example 57: uuid
    print('\n=== Example 57: uuid ===');
    var template57 = env.fromString('{{ uuid() }}');
    var result57 = await template57.renderAsync();
    print(result57.trim());

    // Example 58: get_current_date
    print('\n=== Example 58: get_current_date ===');
    var template58 = env.fromString('{{ get_current_date() }}');
    var result58 = await template58.renderAsync();
    print(result58.trim());

    // Example 59: Complex filter combinations
    print('\n=== Example 59: Complex filter combinations ===');
    var template59 = env.fromString('{{ users|selectattr("active")|map(attribute="name")|list|sort|list }}');
    var result59 = await template59.renderAsync({
      'users': [
        {'name': 'Charlie', 'active': true},
        {'name': 'Alice', 'active': true},
        {'name': 'Bob', 'active': false},
      ],
    });
    print(result59.trim());

    // Example 60: Async data in nested structures
    print('\n=== Example 60: Async data in nested structures ===');
    Future<List<Map<String, dynamic>>> getUsers() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return [
        {'name': 'Alice', 'age': 25, 'active': true},
        {'name': 'Bob', 'age': 30, 'active': false},
      ];
    }

    var template60 = env.fromString('''
{% for user in users %}
    {% if user.active %}
        {{ user.name }} ({{ user.age }})
    {% endif %}
{% endfor %}
''');
    var result60 = await template60.renderAsync({
      'users': getUsers(),
    });
    print(result60.trim());

    // Example 61: Filter with async input
    print('\n=== Example 61: Filter with async input ===');
    Future<String> getAsyncString() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return 'hello world';
    }

    var template61 = env.fromString('{{ text|upper|title }}');
    var result61 = await template61.renderAsync({
      'text': getAsyncString(),
    });
    print(result61.trim());

    // Example 62: Multiple async operations
    print('\n=== Example 62: Multiple async operations ===');
    Future<String> getName() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return 'Alice';
    }

    Future<int> getAge() async {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      return 25;
    }

    var template62 = env.fromString('{{ name }} is {{ age }} years old');
    var result62 = await template62.renderAsync({
      'name': getName(),
      'age': getAge(),
    });
    print(result62.trim());

    // Example 63: Tests in conditions
    print('\n=== Example 63: Tests in conditions ===');
    var template63 = env.fromString('''
{% if value is defined %}Value is defined{% endif %}
{% if value is number %}Value is a number{% endif %}
{% if value is string %}Value is a string{% endif %}
{% if value is even %}Value is even{% endif %}
{% if value is odd %}Value is odd{% endif %}
''');
    var result63 = await template63.renderAsync({
      'value': 42,
    });
    print(result63.trim());

    // Example 64: Complex expression with async
    print('\n=== Example 64: Complex expression with async ===');
    Future<int> getX() async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return 10;
    }

    Future<int> getY() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return 5;
    }

    var template64 = env.fromString('Result: {{ x + y * 2 }}');
    var result64 = await template64.renderAsync({
      'x': getX(),
      'y': getY(),
    });
    print(result64.trim());

    // Example 65: Namespace usage
    print('\n=== Example 65: Namespace usage ===');
    var template65 = env.fromString('''
{% set ns = namespace() %}
{% set ns.count = 0 %}
{% for i in range(5) %}
    {% set ns.count = ns.count + 1 %}
{% endfor %}
Count: {{ ns.count }}
''');
    var result65 = await template65.renderAsync();
    print(result65.trim());

    // Example 66: Filter block
    print('\n=== Example 66: Filter block ===');
    var template66 = env.fromString('''
{% filter upper %}
    hello world
{% endfilter %}
''');
    var result66 = await template66.renderAsync();
    print(result66.trim());

    // Example 67: Autoescape
    print('\n=== Example 67: Autoescape ===');
    var template67 = env.fromString('''
{% autoescape true %}
    {{ "<b>Safe</b>" }}
{% endautoescape %}
{% autoescape false %}
    {{ "<b>Unsafe</b>" }}
{% endautoescape %}
''');
    var result67 = await template67.renderAsync();
    print(result67.trim());

    // Example 68: Recursive for loop
    print('\n=== Example 68: Recursive for loop ===');
    var template68 = env.fromString('''
{% for item in items recursive %}
    {{ item.name }}
    {% if item.children %}
        <ul>{{ loop(item.children) }}</ul>
    {% endif %}
{% endfor %}
''');
    var result68 = await template68.renderAsync({
      'items': [
        {
          'name': 'Root',
          'children': [
            {'name': 'Child 1'},
            {
              'name': 'Child 2',
              'children': [
                {'name': 'Grandchild 1'},
              ],
            }
          ],
        }
      ],
    });
    print(result68.trim());

    // Example 69: Raw block
    print('\n=== Example 69: Raw block ===');
    var template69 = env.fromString('''
{% raw %}
    {{ variable }}
    {% if condition %}
{% endraw %}
''');
    var result69 = await template69.renderAsync();
    print(result69.trim());

    // Example 70: Operators (Power and Concat)
    print('\n=== Example 70: Operators ===');
    var template70 = env.fromString('{{ 2 ** 3 }} ~ {{ "hello" ~ " " ~ "world" }}');
    var result70 = await template70.renderAsync();
    print(result70.trim());

    // Example 71: More tests
    print('\n=== Example 71: More tests ===');
    var template71 = env.fromString('''
{{ 10 is divisibleby 2 }}
{{ [1, 2] is iterable }}
{{ {"a": 1} is mapping }}
{{ none is none }}
''');
    var result71 = await template71.renderAsync();
    print(result71.trim());

    // Example 72: Inline If (Ternary Operator)
    print('\n=== Example 72: Inline If (Ternary) ===');
    var template72 = env.fromString('{{ "Yes" if true else "No" }} | {{ "Yes" if false else "No" }}');
    var result72 = await template72.renderAsync();
    print(result72.trim());

    // Example 73: Membership Operators
    print('\n=== Example 73: Membership Operators ===');
    var template73 = env.fromString('{{ 1 in [1, 2, 3] }} | {{ 4 not in [1, 2, 3] }}');
    var result73 = await template73.renderAsync();
    print(result73.trim());

    // Example 74: Debug statement
    print('\n=== Example 74: Debug statement ===');
    // Debug usually prints to stdout/console directly
    var template74 = env.fromString('{% debug %}');
    await template74.renderAsync();

    // Example 75: Tuple Unpacking
    print('\n=== Example 75: Tuple Unpacking ===');
    var template75 = env.fromString('''
{% set a, b = [10, 20] %}
a: {{ a }}, b: {{ b }}
{% for x, y in points %}
  Point: {{ x }}, {{ y }}
{% endfor %}
''');
    var result75 = await template75.renderAsync({
      'points': [
        [1, 2],
        [3, 4],
        [5, 6],
      ],
    });
    print(result75.trim());

    // Example 76: Macro varargs and kwargs
    print('\n=== Example 76: Macro varargs and kwargs ===');
    // Note: support for varargs/kwargs syntax depends on parser, but accessing them if passed is standard
    var template76 = env.fromString('''
{% macro dump_extras() -%}
  Args: {{ varargs|list }}
  Kwargs: {{ kwargs|dictsort }}
{%- endmacro %}
{{ dump_extras(1, 2, a=3, b=4) }}
''');
    var result76 = await template76.renderAsync();
    print(result76.trim());

    // Example 77: Complex Logic
    print('\n=== Example 77: Complex Logic ===');
    var template77 = env.fromString('{{ (true and false) or (true and true) }}');
    var result77 = await template77.renderAsync();
    print(result77.trim());

    // Example 78: Inheritance with super()
    print('\n=== Example 78: Inheritance with super() ===');
    var template78 = env.fromString('''
{% extends "base.html" %}
{% block header %}
    {{ super() }} - Extended
{% endblock %}
''');
    var result78 = await template78.renderAsync();
    print(result78.trim());

    // Example 79: Jinja Comments and Math
    print('\n=== Example 79: Jinja Comments and Math ===');
    var template79 = env.fromString('''
{# This is a comment and will not be rendered #}
Modulo: {{ 10 % 3 }}
Floor Division: {{ 10 // 3 }}
''');
    var result79 = await template79.renderAsync();
    print(result79.trim());

    // Example 80: Loop Cycle
    print('\n=== Example 80: Loop Cycle ===');
    var template80 = env.fromString('''
{% for i in range(4) %}
    {{ i }} is {{ loop.cycle('even', 'odd') }}
{% endfor %}
''');
    var result80 = await template80.renderAsync();
    print(result80.trim());

    // Example 81: Dynamic Inheritance
    print('\n=== Example 81: Dynamic Inheritance ===');
    var template81 = env.fromString('''
{% extends layout %}
{% block title %}Dynamic Page{% endblock %}
{% block content %}Page content with dynamic parent{% endblock %}
''');
    var result81 = await template81.renderAsync({'layout': 'base.html'});
    print(result81.trim());

    // Example 82: Recursive Macro
    print('\n=== Example 82: Recursive Macro ===');
    // Note: Recursive macros work if they return expressions.
    // For outputting text recursively, standard Jinja2 often hits recursion limits or requires buffering.
    // In Jinja.dart, basic recursion like this works for values if supported by expression evaluator.
    // Actually, macros return string output. Let's try a simple render recursion.
    var template82b = env.fromString('''
{% macro walk_tree(item) -%}
    {{ item.name }}
    {%- if item.children -%}
        <ul>
        {%- for child in item.children -%}
            <li>{{ walk_tree(child) }}</li>
        {%- endfor -%}
        </ul>
    {%- endif -%}
{%- endmacro %}
{{ walk_tree(root) }}
''');
    var result82 = await template82b.renderAsync({
      'root': {
        'name': 'Root',
        'children': [
          {'name': 'A'},
          {
            'name': 'B',
            'children': [
              {'name': 'B1'},
            ],
          },
        ],
      },
    });
    print(result82.trim());

    // Example 83: Self Block Access
    print('\n=== Example 83: Self Block Access ===');
    var template83 = env.fromString('''
{% block warning %}
    WARNING: {{ message }}
{% endblock %}

<div class="alert">
    {{ self.warning() }}
</div>
<div class="footer-warning">
    {{ self.warning() }}
</div>
''');
    var result83 = await template83.renderAsync({'message': 'System Failure'});
    print(result83.trim());

    // Example 84: Safe and Escape Filters
    print('\n=== Example 84: Safe and Escape Filters ===');
    var template84 = env.fromString('''
Safe: {{ "<b>Bold</b>"|safe }}
Escaped: {{ "<b>Bold</b>"|e }}
Force Escaped: {{ "<b>Bold</b>"|forceescape }}
''');
    var result84 = await template84.renderAsync();
    print(result84.trim());

    // Example 85: Format Filter
    print('\n=== Example 85: Format Filter ===');
    var template85 = env.fromString('{{ "Hello %s! You have %d new messages."|format("User", 5) }}');
    var result85 = await template85.renderAsync();
    print(result85.trim());

    // Example 86: Macro with Context
    print('\n=== Example 86: Macro with Context ===');
    // By default, imports might not have context, but defined macros do.
    // Here we show a macro accessing a global variable 'app_name'.
    var template86 = env.fromString('''
{% macro footer() %}
    &copy; 2023 {{ app_name }}
{% endmacro %}
{{ footer() }}
''');
    var result86 = await template86.renderAsync({'app_name': 'My Super App'});
    print(result86.trim());

    // Example 87: Include with ignore missing
    print('\n=== Example 87: Include with ignore missing ===');
    var template87 = env.fromString('''
Start
{% include "non_existent_template.html" ignore missing %}
End
''');
    var result87 = await template87.renderAsync();
    print(result87.trim());

    // Example 88: Import with Context
    print('\n=== Example 88: Import with Context ===');
    // We need a template that uses a context variable
    var loaderWithContext = MapLoader({
      'context_macros.html': '''
    {% macro print_user() %}
      User: {{ user_name }}
    {% endmacro %}
    ''',
    });
    var envWithContext = Environment(loader: loaderWithContext);
    var template88 = envWithContext.fromString('''
{% import "context_macros.html" as m with context %}
{{ m.print_user() }}
''');
    // Note: renderAsync is on the template, we need to pass data
    var result88 = await template88.renderAsync({'user_name': 'Admin'});
    print(result88.trim());

    // Example 89: Environment Introspection (Lexing & Parsing)
    print('\n=== Example 89: Environment Introspection ===');
    var source89 = 'Hello {{ name }}!';
    // Lexing: Convert source to tokens
    var tokens = env.lex(source89);
    print('Tokens: ${tokens.map((t) => t.type).join(", ")}');
    // Parsing: Convert source to Abstract Syntax Tree (AST)
    var ast = env.parse(source89);
    print('AST: ${ast.runtimeType}');

    // Example 90: Custom Finalizer
    print('\n=== Example 90: Custom Finalizer ===');
    // Create an environment that prints "N/A" for null values instead of empty string
    var envFinalizer = Environment(
      finalize: (context, value) => value ?? 'N/A',
    );
    var template90 = envFinalizer.fromString('Value: {{ val }}');
    var result90 = await template90.renderAsync({'val': null});
    print(result90.trim());

    // ========== README.md ASYNC EXAMPLES ==========

    // Example 91: Basic Async Rendering (from README.md lines 320-330)
    print('\n=== Example 91: Basic Async Rendering (README.md) ===');
    Future<String> getUserName() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return 'Alice';
    }

    var template91 = env.fromString('Welcome, {{ user }}!');
    var result91 = await template91.renderAsync({
      'user': getUserName(), // Future<String> is automatically awaited
    });
    print(result91); // Output: Welcome, Alice!

    // Example 92: Async Globals (from README.md lines 333-346)
    print('\n=== Example 92: Async Globals (README.md) ===');
    Future<Map<String, dynamic>> getUserFromReadme() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return {'name': 'Bob', 'age': 30};
    }

    var template92 = env.fromString('User: {{ user.name }}, Age: {{ user.age }}');
    var result92 = await template92.renderAsync({'user': getUserFromReadme()});
    print(result92); // Output: User: Bob, Age: 30

    // Example 93: Async Filters and Tests (from README.md lines 348-370)
    print('\n=== Example 93: Async Filters and Tests (README.md) ===');
    var envWithAsyncFilter = Environment(
      filters: {
        'fetch': (value) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return fetchData();
        },
      },
    );

    var template93 = envWithAsyncFilter.fromString('{{ "trigger"|fetch }}');
    var result93 = await template93.renderAsync();
    print(result93); // Output: fetched data

    if (errors.isNotEmpty) {
      print('\nErrors encountered:');
      errors.forEach(print);
    } else {
      print('\n=== All examples completed successfully! ===');
    }
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
