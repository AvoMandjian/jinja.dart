// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:jinja/jinja.dart';

import '../get_jinja.dart';

final Map<String, dynamic> jinjaData = {
  'data': {
    'payload': {
      'extra_data_payload': 'extra_data_payload',
      'cell_value': 'scripts_list_add_new_slideover',
      'form_id': 'output_doc_jframe_scripts_list',
      'type': 'jform',
      'page_id': null,
      'table_name': 'content',
      'column_name': 'content_id',
      'open_slideover': true,
      'widget_data_id': 'add_new_slide_over_data',
      'content_id': 'slideover.jinja',
      'is_macro': true,
      'title': 'CREATE SCRIPT',
      'block_view_mode': {
        'mode': 'column_mode',
      },
      'parent_id': 'scripts_list_add_new_slideover',
      'content_type': 'content_type_block_controls',
    },
    'settings': {
      'extra_data_settings': 'extra_data_settings',
    },
    'properties': {},
    'slideover_data_types': {
      'title': '',
      'description': '',
      'script_type': {
        'label': 'Script Type',
        'toggle': {
          'values': [
            'script',
            'server',
          ],
          'selected': '',
        },
      },
      'output_type': {
        'label': 'Output Type',
        'toggle': {
          'values': [
            'html',
            'json',
          ],
          'selected': null,
        },
      },
    },
    'controls': [
      {
        'data': {
          'data_type': 'dt_text',
          'ui_widget': 'input_text_single_line',
          'widget_id': 'text',
          'property_label': null,
          'property_id': 'add_new_slide_over_control_title_property',
          'data': {
            'value': null,
          },
        },
        'properties': {
          'show_label': {
            'property_label': 'Show label text',
            'property_id': 'show_label',
            'data_type': 'dt_boolean',
            'ui_widget': 'switch',
            'data': {
              'value': 1,
              'value_text': null,
            },
          },
          'label_text': {
            'data_type': 'dt_text',
            'ui_widget': 'input_text_single_line',
            'property_label': 'Label text',
            'property_id': 'label_text',
            'data': {
              'value': 'Title',
              'value_text': 'Tilte',
            },
          },
          'label_style': {
            'property_id': 'label_style',
            'property_label': 'Label Text Style',
            'data_type': 'dt_text_styles',
            'ui_widget': 'text_styles',
            'data': {
              'value': 'body',
              'value_text': 'body',
              'value_metadata': {
                'font_family': {
                  'property_id': 'font_family',
                  'property_label': 'Font Family',
                  'data_type': 'dt_single_select',
                  'ui_widget': 'single_select_dropdown',
                  'data': {
                    'value': null,
                    'value_text': null,
                  },
                },
                'font_size': {
                  'property_id': 'font_size',
                  'property_label': 'Font Size',
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'data': {
                    'value': 16,
                    'value_text': 16,
                  },
                },
                'font_weight': {
                  'property_id': 'font_weight',
                  'property_label': 'Font Weight',
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'data': {
                    'value': 400,
                    'value_text': 400,
                  },
                },
                'text_color': {
                  'property_id': 'text_color',
                  'property_label': 'Text Color',
                  'data_type': 'dt_system_colors',
                  'ui_widget': 'system_colors',
                  'data': {
                    'value': 'neutral_dark',
                    'value_text': 'neutral_dark',
                  },
                },
                'text_align': {
                  'property_id': 'text_align',
                  'property_label': 'Text Align',
                  'data_type': 'dt_single_select',
                  'ui_widget': 'single_select_segmented_button',
                  'data': {
                    'value': 'center',
                    'value_text': 'center',
                  },
                },
                'text_decoration_color': {
                  'property_id': 'text_decoration_color',
                  'property_label': 'Decoration Color',
                  'data_type': 'dt_system_colors',
                  'ui_widget': 'system_colors',
                  'data': {
                    'value': null,
                    'value_text': null,
                  },
                },
                'text_decoration_style': {
                  'property_id': 'text_decoration_style',
                  'property_label': 'Decoration Style',
                  'data_type': 'dt_single_select',
                  'ui_widget': 'single_select_dropdown',
                  'data': {
                    'value': null,
                    'value_text': null,
                  },
                },
                'text_decoration_line': {
                  'property_id': 'text_decoration_line',
                  'property_label': 'Decoration Line',
                  'data_type': 'dt_single_select',
                  'ui_widget': 'single_select_dropdown',
                  'data': {
                    'value': null,
                    'value_text': null,
                  },
                },
                'font_style': {
                  'property_id': 'font_style',
                  'property_label': 'Font Style',
                  'data_type': 'dt_single_select',
                  'ui_widget': 'single_select_dropdown',
                  'data': {
                    'value': null,
                    'value_text': null,
                  },
                },
                'letter_spacing': {
                  'property_id': 'letter_spacing',
                  'property_label': 'Letter Spacing',
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'data': {
                    'value': 0,
                    'value_text': 0,
                  },
                },
                'line_height': {
                  'property_id': 'line_height',
                  'property_label': 'Line Height',
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'data': {
                    'value': 1.5,
                    'value_text': 1.5,
                  },
                },
              },
            },
          },
          'style': {
            'fill_color': {
              'property_label': 'Fill color',
              'property_id': 'fill_color',
              'data_type': 'dt_system_colors',
              'ui_widget': 'system_colors',
              'data': {
                'value': 'neutral_white',
                'value_text': 'neutral_white',
              },
            },
            'hover_color': {
              'property_label': 'Hover color',
              'property_id': 'hover_color',
              'data_type': 'dt_system_colors',
              'ui_widget': 'system_colors',
              'data': {
                'value': 'transparent',
                'value_text': 'transparent',
              },
            },
            'cursor_color': {
              'property_label': 'Cursor color',
              'property_id': 'cursor_color',
              'data_type': 'dt_system_colors',
              'ui_widget': 'system_colors',
              'data': {
                'value': 'primary',
                'value_text': 'primary',
              },
            },
          },
          'enabled_border': {
            'data_type': 'dt_border',
            'ui_widget': 'border',
            'property_label': 'Border',
            'property_id': 'enabled_border',
            'data': {
              'value': 1,
              'value_text': null,
              'value_metadata': {
                'border_color': {
                  'data_type': 'dt_system_colors',
                  'ui_widget': 'system_colors',
                  'property_label': 'Border color',
                  'property_id': 'border_color',
                  'data': {
                    'value': 'neutral_lighter',
                    'value_text': 'neutral_lighter',
                  },
                },
                'border_width': {
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'property_label': 'Border width',
                  'property_id': 'border_width',
                  'data': {
                    'value': 1,
                    'value_text': 1,
                  },
                },
                'border_radius': {
                  'data_type': 'dt_radius',
                  'ui_widget': 'radius',
                  'property_id': 'border_radius',
                  'property_label': 'Border radius',
                  'data': {
                    'value': 10,
                    'value_text': 10.0,
                    'value_metadata': {
                      'top_left': {
                        'property_id': 'top_left',
                        'property_label': 'Top-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'top_right': {
                        'property_id': 'top_right',
                        'property_label': 'Top-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_left': {
                        'property_id': 'bottom_left',
                        'property_label': 'Bottom-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_right': {
                        'property_id': 'bottom_right',
                        'property_label': 'Bottom-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          'focused_border': {
            'data_type': 'dt_border',
            'ui_widget': 'border',
            'property_label': 'Focused border',
            'property_id': 'focused_border',
            'data': {
              'value': 1,
              'value_text': null,
              'value_metadata': {
                'border_color': {
                  'data_type': 'dt_system_colors',
                  'ui_widget': 'system_colors',
                  'property_label': 'Border color',
                  'property_id': 'border_color',
                  'data': {
                    'value': 'primary',
                    'value_text': 'primary',
                  },
                },
                'border_width': {
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'property_label': 'Border width',
                  'property_id': 'border_width',
                  'data': {
                    'value': 1,
                    'value_text': 1,
                  },
                },
                'border_radius': {
                  'data_type': 'dt_radius',
                  'ui_widget': 'radius',
                  'property_id': 'border_radius',
                  'property_label': 'Border radius',
                  'data': {
                    'value': 10,
                    'value_text': 10.0,
                    'value_metadata': {
                      'top_left': {
                        'property_id': 'top_left',
                        'property_label': 'Top-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'top_right': {
                        'property_id': 'top_right',
                        'property_label': 'Top-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_left': {
                        'property_id': 'bottom_left',
                        'property_label': 'Bottom-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_right': {
                        'property_id': 'bottom_right',
                        'property_label': 'Bottom-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          'disabled_border': {
            'data_type': 'dt_border',
            'ui_widget': 'border',
            'property_label': 'Disabled border',
            'property_id': 'disabled_border',
            'data': {
              'value': 1,
              'value_text': null,
              'value_metadata': {
                'border_color': {
                  'data_type': 'dt_system_colors',
                  'ui_widget': 'system_colors',
                  'property_label': 'Border color',
                  'property_id': 'border_color',
                  'data': {
                    'value': 'neutral_lighter',
                    'value_text': 'neutral_lighter',
                  },
                },
                'border_width': {
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'property_label': 'Border width',
                  'property_id': 'border_width',
                  'data': {
                    'value': 1,
                    'value_text': 1,
                  },
                },
                'border_radius': {
                  'data_type': 'dt_radius',
                  'ui_widget': 'radius',
                  'property_id': 'border_radius',
                  'property_label': 'Border radius',
                  'data': {
                    'value': 10,
                    'value_text': 10.0,
                    'value_metadata': {
                      'top_left': {
                        'property_id': 'top_left',
                        'property_label': 'Top-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'top_right': {
                        'property_id': 'top_right',
                        'property_label': 'Top-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_left': {
                        'property_id': 'bottom_left',
                        'property_label': 'Bottom-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_right': {
                        'property_id': 'bottom_right',
                        'property_label': 'Bottom-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          'error_border': {
            'property_label': 'Error Border',
            'property_id': 'error_border',
            'data_type': 'dt_border',
            'ui_widget': 'border',
            'data': {
              'value': 1,
              'value_text': null,
              'value_metadata': {
                'border_color': {
                  'property_label': 'Border Color',
                  'property_id': 'border_color',
                  'data_type': 'dt_system_colors',
                  'ui_widget': 'system_colors',
                  'data': {
                    'value': 'secondary',
                    'value_text': 'secondary',
                  },
                },
                'border_width': {
                  'property_label': 'Border Width',
                  'property_id': 'border_width',
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'data': {
                    'value': 1,
                    'value_text': 1,
                  },
                },
                'border_radius': {
                  'data_type': 'dt_radius',
                  'ui_widget': 'radius',
                  'property_id': 'border_radius',
                  'property_label': 'Border radius',
                  'data': {
                    'value': 10,
                    'value_text': 10.0,
                    'value_metadata': {
                      'top_left': {
                        'property_id': 'top_left',
                        'property_label': 'Top-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'top_right': {
                        'property_id': 'top_right',
                        'property_label': 'Top-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_left': {
                        'property_id': 'bottom_left',
                        'property_label': 'Bottom-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_right': {
                        'property_id': 'bottom_right',
                        'property_label': 'Bottom-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
      {
        'data': {
          'data_type': 'text',
          'ui_widget': 'input_text_single_line',
          'property_id': 'add_new_slide_over_control_description_property',
          'data': {
            'value': null,
          },
        },
        'properties': {
          'show_label': {
            'property_label': 'Show label text',
            'property_id': 'show_label',
            'data_type': 'dt_boolean',
            'ui_widget': 'switch',
            'data': {
              'value': 1,
              'value_text': null,
            },
          },
          'label_text': {
            'data_type': 'dt_text',
            'ui_widget': 'input_text_single_line',
            'property_label': 'Label text',
            'property_id': 'label_text',
            'data': {
              'value': 'description',
              'value_text': 'Description',
            },
          },
          'label_style': {
            'property_id': 'label_style',
            'property_label': 'Label Text Style',
            'data_type': 'dt_text_styles',
            'ui_widget': 'text_styles',
            'data': {
              'value': 'body',
              'value_text': 'body',
              'value_metadata': {
                'font_family': {
                  'property_id': 'font_family',
                  'property_label': 'Font Family',
                  'data_type': 'dt_single_select',
                  'ui_widget': 'single_select_dropdown',
                  'data': {
                    'value': null,
                    'value_text': null,
                  },
                },
                'font_size': {
                  'property_id': 'font_size',
                  'property_label': 'Font Size',
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'data': {
                    'value': 16,
                    'value_text': 16,
                  },
                },
                'font_weight': {
                  'property_id': 'font_weight',
                  'property_label': 'Font Weight',
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'data': {
                    'value': 400,
                    'value_text': 400,
                  },
                },
                'text_color': {
                  'property_id': 'text_color',
                  'property_label': 'Text Color',
                  'data_type': 'dt_system_colors',
                  'ui_widget': 'system_colors',
                  'data': {
                    'value': 'neutral_dark',
                    'value_text': 'neutral_dark',
                  },
                },
                'text_align': {
                  'property_id': 'text_align',
                  'property_label': 'Text Align',
                  'data_type': 'dt_single_select',
                  'ui_widget': 'single_select_segmented_button',
                  'data': {
                    'value': 'center',
                    'value_text': 'center',
                  },
                },
                'text_decoration_color': {
                  'property_id': 'text_decoration_color',
                  'property_label': 'Decoration Color',
                  'data_type': 'dt_system_colors',
                  'ui_widget': 'system_colors',
                  'data': {
                    'value': null,
                    'value_text': null,
                  },
                },
                'text_decoration_style': {
                  'property_id': 'text_decoration_style',
                  'property_label': 'Decoration Style',
                  'data_type': 'dt_single_select',
                  'ui_widget': 'single_select_dropdown',
                  'data': {
                    'value': null,
                    'value_text': null,
                  },
                },
                'text_decoration_line': {
                  'property_id': 'text_decoration_line',
                  'property_label': 'Decoration Line',
                  'data_type': 'dt_single_select',
                  'ui_widget': 'single_select_dropdown',
                  'data': {
                    'value': null,
                    'value_text': null,
                  },
                },
                'font_style': {
                  'property_id': 'font_style',
                  'property_label': 'Font Style',
                  'data_type': 'dt_single_select',
                  'ui_widget': 'single_select_dropdown',
                  'data': {
                    'value': null,
                    'value_text': null,
                  },
                },
                'letter_spacing': {
                  'property_id': 'letter_spacing',
                  'property_label': 'Letter Spacing',
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'data': {
                    'value': 0,
                    'value_text': 0,
                  },
                },
                'line_height': {
                  'property_id': 'line_height',
                  'property_label': 'Line Height',
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'data': {
                    'value': 1.5,
                    'value_text': 1.5,
                  },
                },
              },
            },
          },
          'style': {
            'fill_color': {
              'property_label': 'Fill color',
              'property_id': 'fill_color',
              'data_type': 'dt_system_colors',
              'ui_widget': 'system_colors',
              'data': {
                'value': 'neutral_white',
                'value_text': 'neutral_white',
              },
            },
            'hover_color': {
              'property_label': 'Hover color',
              'property_id': 'hover_color',
              'data_type': 'dt_system_colors',
              'ui_widget': 'system_colors',
              'data': {
                'value': 'transparent',
                'value_text': 'transparent',
              },
            },
            'cursor_color': {
              'property_label': 'Cursor color',
              'property_id': 'cursor_color',
              'data_type': 'dt_system_colors',
              'ui_widget': 'system_colors',
              'data': {
                'value': 'primary',
                'value_text': 'primary',
              },
            },
          },
          'enabled_border': {
            'data_type': 'dt_border',
            'ui_widget': 'border',
            'property_label': 'Border',
            'property_id': 'enabled_border',
            'data': {
              'value': 1,
              'value_text': null,
              'value_metadata': {
                'border_color': {
                  'data_type': 'dt_system_colors',
                  'ui_widget': 'system_colors',
                  'property_label': 'Border color',
                  'property_id': 'border_color',
                  'data': {
                    'value': 'neutral_lighter',
                    'value_text': 'neutral_lighter',
                  },
                },
                'border_width': {
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'property_label': 'Border width',
                  'property_id': 'border_width',
                  'data': {
                    'value': 1,
                    'value_text': 1,
                  },
                },
                'border_radius': {
                  'data_type': 'dt_radius',
                  'ui_widget': 'radius',
                  'property_id': 'border_radius',
                  'property_label': 'Border radius',
                  'data': {
                    'value': 10,
                    'value_text': 10.0,
                    'value_metadata': {
                      'top_left': {
                        'property_id': 'top_left',
                        'property_label': 'Top-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'top_right': {
                        'property_id': 'top_right',
                        'property_label': 'Top-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_left': {
                        'property_id': 'bottom_left',
                        'property_label': 'Bottom-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_right': {
                        'property_id': 'bottom_right',
                        'property_label': 'Bottom-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          'focused_border': {
            'data_type': 'dt_border',
            'ui_widget': 'border',
            'property_label': 'Focused border',
            'property_id': 'focused_border',
            'data': {
              'value': 1,
              'value_text': null,
              'value_metadata': {
                'border_color': {
                  'data_type': 'dt_system_colors',
                  'ui_widget': 'system_colors',
                  'property_label': 'Border color',
                  'property_id': 'border_color',
                  'data': {
                    'value': 'primary',
                    'value_text': 'primary',
                  },
                },
                'border_width': {
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'property_label': 'Border width',
                  'property_id': 'border_width',
                  'data': {
                    'value': 1,
                    'value_text': 1,
                  },
                },
                'border_radius': {
                  'data_type': 'dt_radius',
                  'ui_widget': 'radius',
                  'property_id': 'border_radius',
                  'property_label': 'Border radius',
                  'data': {
                    'value': 10,
                    'value_text': 10.0,
                    'value_metadata': {
                      'top_left': {
                        'property_id': 'top_left',
                        'property_label': 'Top-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'top_right': {
                        'property_id': 'top_right',
                        'property_label': 'Top-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_left': {
                        'property_id': 'bottom_left',
                        'property_label': 'Bottom-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_right': {
                        'property_id': 'bottom_right',
                        'property_label': 'Bottom-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          'disabled_border': {
            'data_type': 'dt_border',
            'ui_widget': 'border',
            'property_label': 'Disabled border',
            'property_id': 'disabled_border',
            'data': {
              'value': 1,
              'value_text': null,
              'value_metadata': {
                'border_color': {
                  'data_type': 'dt_system_colors',
                  'ui_widget': 'system_colors',
                  'property_label': 'Border color',
                  'property_id': 'border_color',
                  'data': {
                    'value': 'neutral_lighter',
                    'value_text': 'neutral_lighter',
                  },
                },
                'border_width': {
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'property_label': 'Border width',
                  'property_id': 'border_width',
                  'data': {
                    'value': 1,
                    'value_text': 1,
                  },
                },
                'border_radius': {
                  'data_type': 'dt_radius',
                  'ui_widget': 'radius',
                  'property_id': 'border_radius',
                  'property_label': 'Border radius',
                  'data': {
                    'value': 10,
                    'value_text': 10.0,
                    'value_metadata': {
                      'top_left': {
                        'property_id': 'top_left',
                        'property_label': 'Top-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'top_right': {
                        'property_id': 'top_right',
                        'property_label': 'Top-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_left': {
                        'property_id': 'bottom_left',
                        'property_label': 'Bottom-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_right': {
                        'property_id': 'bottom_right',
                        'property_label': 'Bottom-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          'error_border': {
            'property_label': 'Error Border',
            'property_id': 'error_border',
            'data_type': 'dt_border',
            'ui_widget': 'border',
            'data': {
              'value': 1,
              'value_text': null,
              'value_metadata': {
                'border_color': {
                  'property_label': 'Border Color',
                  'property_id': 'border_color',
                  'data_type': 'dt_system_colors',
                  'ui_widget': 'system_colors',
                  'data': {
                    'value': 'secondary',
                    'value_text': 'secondary',
                  },
                },
                'border_width': {
                  'property_label': 'Border Width',
                  'property_id': 'border_width',
                  'data_type': 'dt_number',
                  'ui_widget': 'input_text_number',
                  'data': {
                    'value': 1,
                    'value_text': 1,
                  },
                },
                'border_radius': {
                  'data_type': 'dt_radius',
                  'ui_widget': 'radius',
                  'property_id': 'border_radius',
                  'property_label': 'Border radius',
                  'data': {
                    'value': 10,
                    'value_text': 10.0,
                    'value_metadata': {
                      'top_left': {
                        'property_id': 'top_left',
                        'property_label': 'Top-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'top_right': {
                        'property_id': 'top_right',
                        'property_label': 'Top-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_left': {
                        'property_id': 'bottom_left',
                        'property_label': 'Bottom-left border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                      'bottom_right': {
                        'property_id': 'bottom_right',
                        'property_label': 'Bottom-right border',
                        'data_type': 'dt_number',
                        'ui_widget': 'input_text_number',
                        'data': {
                          'value': 10,
                          'value_text': 10.0,
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
      {
        'data': {
          'ui_widget': 'custom_container',
          'data': {
            'value': [
              {
                'data_type': 'dt_text',
                'ui_widget': 'text_single_line',
                'property_label': null,
                'property_id': 'add_new_slide_over_control_toggle_script_type_text_single_line_script_type_property',
                'data': {
                  'value': 'script_type',
                  'value_text': 'Script Type',
                },
              },
              {
                'data_type': 'toggle',
                'ui_widget': 'single_select_segmented_button',
                'property_label': null,
                'property_id': 'add_new_slide_over_control_toggle_script_type_text_single_select_segmented_button_property',
                'type': 'toggle',
                'data': {
                  'value': [
                    {
                      'data': {
                        'value': 'script',
                        'value_text': 'SCRIPT',
                      },
                      'property_settings': {
                        'type': {
                          'value': 'text',
                        },
                      },
                    },
                    {
                      'data': {
                        'value': 'server',
                        'value_text': 'SERVER',
                      },
                      'property_settings': {
                        'type': {
                          'value': 'text',
                        },
                      },
                    }
                  ],
                },
              }
            ],
          },
        },
        'properties': null,
      },
      {
        'data': {
          'ui_widget': 'custom_container',
          'data': {
            'value': [
              {
                'data_type': 'dt_text',
                'ui_widget': 'text_single_line',
                'property_label': null,
                'property_id': 'add_new_slide_over_control_toggle_output_type_text_single_line_script_type_property',
                'data': {
                  'value': 'output_type',
                  'value_text': 'Output Type',
                },
              },
              {
                'data_type': 'toggle',
                'ui_widget': 'single_select_segmented_button',
                'type': 'toggle',
                'property_id': 'add_new_slide_over_control_toggle_output_type_text_single_select_segmented_button_property',
                'data': {
                  'value': [
                    {
                      'data': {
                        'value': 'json',
                        'value_text': 'JSON',
                      },
                      'property_settings': {
                        'type': {
                          'value': 'text',
                        },
                      },
                    },
                    {
                      'data': {
                        'value': 'html',
                        'value_text': 'HTML',
                      },
                      'property_settings': {
                        'type': {
                          'value': 'text',
                        },
                      },
                    }
                  ],
                },
              }
            ],
          },
        },
        'properties': null,
      }
    ],
  },
  'macro_toggle_data': {
    'id': '4d8a9708-21ae-4e75-adc9-4925bb461483',
    'property_id': 'add_new_slide_over_output_type_property_toggle',
    'data': {
      'values': {
        'id': '4d8a9708-21ae-4e75-adc9-4925bb461483',
        'data_type': 'dt_list',
        'data': [
          {
            'id': '25b8a684-6dbc-475c-8d50-b926ab92e348',
            'property_label': 'Output Type',
            'property_id': 'add_new_slide_over_output_type_property_toggle',
            'data_type': 'dt_text',
            'data': {'value': 'html', 'value_text': 'html'},
          },
          {
            'id': 'f54a4d15-96f7-4284-b647-b19a755ccb6d',
            'property_label': 'Output Type',
            'property_id': 'add_new_slide_over_output_type_property_toggle',
            'data_type': 'dt_text',
            'data': {'value': 'json', 'value_text': 'json'},
          },
        ],
      },
      'selected': {
        'id': 'edc176af-b20a-4347-964d-13f00373e6a5',
        'data_type': 'dt_text',
        'data': {'value': 'html', 'value_text': 'html'},
      },
    },
  },
};

void main() async {
  try {
    final errors = <String?>[];
    final nativeTypesIn = await File('data-types/examples/native_types_in.jinja').readAsString();
    final slideoverIn = await File('data-types/examples/slideover_in.jinja').readAsString();
    final containerTypesIn = await File('data-types/examples/container_types_in.jinja').readAsString();
    final viewsTemplate = await File('data-types/jinja/views.jinja').readAsString();
    final nativeTypesTemplate = await File(
      'data-types/jinja/native_types.jinja',
    ).readAsString();
    final mediaTypesTemplate = await File(
      'data-types/jinja/media_types.jinja',
    ).readAsString();
    final containerTypesTemplate = await File(
      'data-types/jinja/container_types.jinja',
    ).readAsString();
    final slideoverTemplate = await File(
      'data-types/jinja/slideover.jinja',
    ).readAsString();
    final macroToggleTemplate = await File(
      'example/data_types/macro_toggle.jinja',
    ).readAsString();
    final customJinjaScript = '''
{% import "slideover.jinja" as slideover %}
{% set slideover_data = slideover.dt_slideover_object(data.slideover_data_types) %}
{{ slideover_data }}
''';
    final toggleExecutionScript = '''
{% import "macro_toggle.jinja" as toggle %}
{{ toggle.macro_toggle(macro_toggle_data, {}) }}
''';
    // Setup MapLoader with base templates for inheritance and inclusion
    final loader = MapLoader(
      {
        'views.jinja': viewsTemplate,
        'slideover.jinja': slideoverTemplate,
        'native_types.jinja': nativeTypesTemplate,
        'media_types.jinja': mediaTypesTemplate,
        'container_types.jinja': containerTypesTemplate,
        'macro_toggle.jinja': macroToggleTemplate,
      },
      globalJinjaData: jinjaData,
    );

    final env = GetJinja.environment(
      MockBuildContext(),
      loader,
      //   enableJinjaDebugLogging: true,
      valueListenableJinjaError: (error) {
        print('Jinja Error: $error');
        errors.add(error);
      },
      callbackToParentProject: ({required payload}) async {
        await Future<void>.delayed(const Duration(seconds: 2));

        if (payload['action'] == 'run_data_source' && payload['data_source_id'] == 'get_properties_by_widget_property_id') {
          return {
            'values': {
              'id': '4d8a9708-21ae-4e75-adc9-4925bb461483',
              'data_type': 'dt_list',
              'data': [
                {
                  'id': '25b8a684-6dbc-475c-8d50-b926ab92e348',
                  'property_label': 'Output Type',
                  'property_id': 'add_new_slide_over_output_type_property_toggle',
                  'data_type': 'dt_text',
                  'data': {'value': 'html', 'value_text': 'html'},
                },
                {
                  'id': 'f54a4d15-96f7-4284-b647-b19a755ccb6d',
                  'property_label': 'Output Type',
                  'property_id': 'add_new_slide_over_output_type_property_toggle',
                  'data_type': 'dt_text',
                  'data': {'value': 'json', 'value_text': 'json'},
                },
              ],
            },
            'selected': {
              'id': 'edc176af-b20a-4347-964d-13f00373e6a5',
              'data_type': 'dt_text',
              'data': {'value': 'html', 'value_text': 'html'},
            },
          };
        }

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
    // // Example 1: native_types_in.jinja
    // print('\n=== Example 1: native_types_in.jinja ===');
    // final template4 = env.fromString(nativeTypesIn);
    // final result4 = await template4.renderAsync(jinjaData);
    // print('Result length: ${result4.length}');
    // print(
    //   '--------------------------------------------------------------------------------------------------------------------------------',
    // );
    // print(result4.replaceAll('\n', ''));
    // print(
    //   '--------------------------------------------------------------------------------------------------------------------------------',
    // );
    // Example 2: slideover_in.jinja
    // print('\n=== Example 2: slideover_in.jinja ===');
    // final template5 = env.fromString(slideoverIn);
    // final result5 = await template5.renderAsync(jinjaData);
    // print('Result length: ${result5.length}');
    // print(
    //   '--------------------------------------------------------------------------------------------------------------------------------',
    // );
    // print(result5.replaceAll('\n', ''));
    // print(
    //   '--------------------------------------------------------------------------------------------------------------------------------',
    // );
    // // Example 3: container_types_in.jinja
    // print('\n=== Example 3: container_types_in.jinja ===');
    // final template6 = env.fromString(containerTypesIn);
    // final result6 = await template6.renderAsync(jinjaData);
    // print('Result length: ${result6.length}');
    // print(
    //   '--------------------------------------------------------------------------------------------------------------------------------',
    // );
    // print(result6.replaceAll('\n', ''));
    // print(
    //   '--------------------------------------------------------------------------------------------------------------------------------',
    // );
    // // Example 4: views.jinja
    // print('\n=== Example 4: views.jinja ===');
    // final template7 = env.fromString(viewsTemplate);
    // final result7 = await template7.renderAsync(jinjaData);
    // print('Result length: ${result7.length}');
    // print(
    //   '--------------------------------------------------------------------------------------------------------------------------------',
    // );
    // print(result7.replaceAll('\n', ''));
    // print(
    //   '--------------------------------------------------------------------------------------------------------------------------------',
    // );
    // Example 5: custom_jinja_script.jinja
    // print('\n=== Example 5: custom_jinja_script.jinja ===');
    // final template8 = env.fromString(customJinjaScript);
    // final result8 = await template8.renderAsync(jinjaData);
    // print('Result length: ${result8.length}');
    // print(
    //   '--------------------------------------------------------------------------------------------------------------------------------',
    // );
    // print(result8.replaceAll('\n', ''));
    // print(
    //   '--------------------------------------------------------------------------------------------------------------------------------',
    // );

    // Example 6: macro_toggle.jinja
    print('\n=== Example 6: macro_toggle.jinja ===');
    final template9 = env.fromString(toggleExecutionScript);
    final result9 = await template9.renderAsync(jinjaData);
    print('Result length: ${result9.length}');
    // print(
    //   '--------------------------------------------------------------------------------------------------------------------------------',
    // );
    // print(result9.replaceAll('\n', ''));
    // print(
    //   '--------------------------------------------------------------------------------------------------------------------------------',
    // );
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
