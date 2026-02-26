// ignore_for_file: avoid_print

import 'dart:async';

import 'package:jinja/jinja.dart';
import 'package:jinja/src/debug/debug_template.dart';

import 'get_jinja.dart';

final jinjaScript = '''{# Build the tree structure and then group the root items. #}
{% set left_side_code = get(jinja_script_by_id,'jinja_script') %}

{
  "widget_type": "jform",
  "widget_id": "code_editor_jframe",
  "workflows": {},
  "events": {},
  "layout": {
    "layout_type_id": "data",
    "header": {
      "page_id": "header_page",
      "visible": 1
    },
    "footer": {
      "visible": 0
    },
    "body": {
      "default_container_id": "home_container",
      "containers": {
        "home_container": {
          "rows": [
            {
              "row_id": "",
              "columns": [
                {
                  "column_id": "column_2",
                  "page_id": "home_page",
                  "properties": {
                    "flex": 3
                  }
                }
              ]
            }
          ]
        }
      }
    }
  },
  "pages": {
    "header_page": {
      "rows": [
        {
          "row_id": "header_row",
          "columns": [
            {
              "column_id": "header_column",
              "widgets": [
                  {% set header_jinja_data = {"my_app":"my_app", "show_save_button": true,"add_button_text":"Save","header_title":"Code Editor"} %}
                  {{ render_widget_by_id("macro_header", { "value" : header_jinja_data }) }}
              ]
            }
          ]
        }
      ]
    },
    "home_page": {
      "page_id": "home_page",
      "rows": [
        {
          "row_id": "",
          "columns": [
            {
              "column_id": "1",
              "widgets": [
                {
                  "widget_id": "code_editor",
                  "widget_type": "code_editor",
                  "property_settings_suggestion_description": {
                    "style": {
                      "background_color": {
                        "value": "background_regular"
                      },
                      "border_color": {
                        "value": "border_regular"
                      },
                      "border_radius": {
                        "value": 0.0
                      },
                      "border_width": {
                        "value": 0.0
                      },
                      "border_style": {
                        "value": "solid"
                      }
                    },
                    "padding": {
                      "top": {
                        "value": 0.0
                      },
                      "bottom": {
                        "value": 0.0
                      },
                      "left": {
                        "value": 0.0
                      },
                      "right": {
                        "value": 0.0
                      }
                    }
                  },
                  "property_settings_suggestions": {
                    "style": {
                      "background_color": {
                        "value": "background_regular"
                      },
                      "border_color": {
                        "value": "border_regular"
                      },
                      "border_radius": {
                        "value": 0.0
                      },
                      "border_width": {
                        "value": 0.0
                      },
                      "border_style": {
                        "value": "solid"
                      }
                    },
                    "padding": {
                      "top": {
                        "value": 0.0
                      },
                      "bottom": {
                        "value": 0.0
                      },
                      "left": {
                        "value": 0.0
                      },
                      "right": {
                        "value": 0.0
                      }
                    }
                  },
                  "workflows": {
                    "on_click_container_2": {
                      "jinja_script_id": "",
                      "workflow_actions": [
                        {
                          "set_page": {
                            "page_id": "page_id_63",
                            "column_id": "column_2"
                          }
                        }
                      ]
                    }
                  },
                  "code_theme": "custom_theme_name",
                  "custom_theme": {
                    "custom_theme_name": {}
                  },
                  "meta_data": {},
                  "widget_actions": {
                    "open_drawer": {
                      "action": "open_drawer",
                      "meta_data": {}
                    },
                    "get_code_editor_data": {
                      "action": "get_code_editor_data",
                      "meta_data": {}
                    },
                    "get_video_data": {
                      "action": "get_video_data",
                      "meta_data": {}
                    }
                  },
                  "data": {
                    "recordset_auto_load": false,
                    "video_data": {},
                    "error": "<p>No problems have been detected in the workspace.</p>",
                    "right_side_code_editor_id": "code_editor_right_side",
                    "left_side_code_editor_id": "code_editor_left_side",
                    "selected_code_text": "",
                    "selected_code_line_range_start": 0,
                    "selected_code_line_range_end": 0,
                    "jinja_references": [],
                    "pre_defined_prompts": [],
                    "right_side_code": "",
                    "left_side_code": "{{ left_side_code.data.text if left_side_code.data else '' }}",
                    "external_api": {},
                    "jinja_data": {}
                  },
                  "widget_ui": {
                    "slideover": {
                      "widget_id": "data_binding",
                      "widget_type": "json_editor",
                      "background_color": "white",
                      "widget_actions": {
                        "get_json_editor_data": {
                          "action": "get_json_editor_data",
                          "meta_data": {}
                        }
                      },
                      "external_api": {
                        "url": "https://fapidev.seekunique.co/rose-uniacke/do-action",
                        "method": "POST",
                        "headers": {
                          "Content-Type": "application/json",
                          "Authorization": "Bearer 01c7fbb2-5b49-11f0-bfc0-56253a93288f"
                        },
                        "payload": {
                          "do_action": "app_user_menu",
                          "data": {
                            "user_id": "1fca67a3-f583-11ee-99b0-06dafc9073f9",
                            "app_version": "1.2.0+127"
                          }
                        }
                      },
                      "recordset_auto_load": true
                    },
                    "right_side": {
                      "set_right_side_collapse_button_icon": {
                        "height": {
                          "value": 15.0
                        },
                        "width": {
                          "value": 15.0
                        },
                        "tooltip_message": {
                          "value": "Collapse All"
                        },
                        "mode": {
                          "value": "network"
                        },
                        "icon_selected_color": "error",
                        "data": {
                          "value": "https://files.svgcdn.io/mynaui/x-circle.svg"
                        }
                      },
                      "open_in_browser_button_icon": {
                        "height": {
                          "value": 15.0
                        },
                        "width": {
                          "value": 15.0
                        },
                        "tooltip_message": {
                          "value": "Open in Browser"
                        },
                        "mode": {
                          "value": "network"
                        },
                        "icon_selected_color": "error",
                        "data": {
                          "value": "https://files.svgcdn.io/octicon/browser.svg"
                        }
                      },
                      "copy_to_clipboard_button_icon": {
                        "height": {
                          "value": 15.0
                        },
                        "width": {
                          "value": 15.0
                        },
                        "tooltip_message": {
                          "value": "Copy to Clipboard"
                        },
                        "mode": {
                          "value": "network"
                        },
                        "icon_selected_color": "error",
                        "data": {
                          "value": "https://files.svgcdn.io/radix-icons/copy.svg"
                        }
                      },
                      "expand_button_icon": {
                        "height": {
                          "value": 15.0
                        },
                        "width": {
                          "value": 15.0
                        },
                        "tooltip_message": {
                          "value": "Expand Code"
                        },
                        "mode": {
                          "value": "network"
                        },
                        "icon_selected_color": "error",
                        "data": {
                          "value": "https://files.svgcdn.io/prime/expand.svg"
                        }
                      },
                      "tab_bar_widget": {
                        "initial_index": 0,
                        "show_alternate_color_icon_indexs": [],
                        "error_tab_index": 3,
                        "debug_tab_index": 2,
                        "property_settings": {
                          "styles": {
                            "border_color": {
                              "value": "neutral_white"
                            },
                            "background_color": {
                              "value": "neutral_white"
                            },
                            "hover_color": {
                              "value": "neutral_white"
                            },
                            "selected_color": {
                              "value": "neutral_white"
                            },
                            "text_style": {
                              "value": "body"
                            },
                            "unselected_text_color": {
                              "value": "transparent"
                            },
                            "selected_text_color": {
                              "value": "transparent"
                            },
                            "icon_color": {
                              "value": "primary"
                            },
                            "icon_background_color": {
                              "value": "transparent"
                            },
                            "is_indicator_line": {
                              "value": 0.0
                            },
                            "is_border_enabled": {
                              "value": 0.0
                            },
                            "indicator_color": {
                              "value": "transparent"
                            }
                          }
                        },
                        "tabs": [
                          {
                            "data": {
                              "icon_selected_color": "error",
                              "tooltip": "Preview",
                              "icon_data": {
                                "widget_id": {
                                  "value": "flutter_svg"
                                },
                                "widget_type": {
                                  "value": "flutter_svg"
                                },
                                "mode": {
                                  "value": "network"
                                },
                                "data": {
                                  "value": "https://files.svgcdn.io/uit/laptop.svg"
                                }
                              }
                            }
                          },
                          {
                            "data": {
                              "icon_selected_color": "error",
                              "tooltip": "AI",
                              "icon_data": {
                                "widget_id": {
                                  "value": "flutter_svg"
                                },
                                "widget_type": {
                                  "value": "flutter_svg"
                                },
                                "mode": {
                                  "value": "network"
                                },
                                "data": {
                                  "value": "https://files.svgcdn.io/solar/magic-stick-3-broken.svg"
                                }
                              }
                            }
                          },
                          {
                            "data": {
                              "icon_selected_color": "error",
                              "tooltip": "Code",
                              "icon_data": {
                                "widget_id": {
                                  "value": "flutter_svg"
                                },
                                "widget_type": {
                                  "value": "flutter_svg"
                                },
                                "mode": {
                                  "value": "network"
                                },
                                "data": {
                                  "value": "https://files.svgcdn.io/si-glyph/code.svg"
                                }
                              }
                            }
                          },
                          {
                            "data": {
                              "icon_selected_color": "error",
                              "tooltip": "Debug",
                              "icon_data": {
                                "widget_id": {
                                  "value": "flutter_svg"
                                },
                                "widget_type": {
                                  "value": "flutter_svg"
                                },
                                "mode": {
                                  "value": "network"
                                },
                                "data": {
                                  "value": "https://files.svgcdn.io/codicon/bug.svg"
                                }
                              }
                            }
                          },
                          {
                            "data": {
                              "icon_selected_color": "error",
                              "tooltip": "Error",
                              "icon_data": {
                                "widget_id": {
                                  "value": "flutter_svg"
                                },
                                "widget_type": {
                                  "value": "flutter_svg"
                                },
                                "mode": {
                                  "value": "network"
                                },
                                "data": {
                                  "value": "https://files.svgcdn.io/heroicons-outline/exclamation.svg"
                                }
                              }
                            }
                          },
                          {
                            "data": {
                              "icon_selected_color": "error",
                              "tooltip": "Help",
                              "icon_data": {
                                "widget_id": {
                                  "value": "flutter_svg"
                                },
                                "widget_type": {
                                  "value": "flutter_svg"
                                },
                                "mode": {
                                  "value": "network"
                                },
                                "data": {
                                  "value": "https://files.svgcdn.io/qlementine-icons/question-24.svg"
                                }
                              }
                            }
                          }
                        ]
                      },
                      "pages": [
                        {
                          "widget_id": "device_preview_widget_id",
                          "widget_type": "device_preview",
                          "isFlutterHtml": "false",
                          "outputDataType": "jframe",
                          "jframe_widget": {}
                        },
                        {
                          "widget_id": "jinja_ai_text",
                          "widget_type": "jinja_ai_text",
                          "widget_mode": "edit",
                          "view_type": "default",
                          "show_input_field": true,
                          "show_output_field": true,
                          "show_submit_button": true,
                          "input_placeholder": "Enter your text here...",
                          "output_placeholder": "AI response will appear here...",
                          "button_text": "Submit",
                          "model": "qwen3-coder:30b",
                          "collection_name": "queue",
                          "widgets": {
                            "agent_dropdown": {
                              "widget_id": "uid",
                              "widget_type": "dropdown",
                              "mode": "edit",
                              "data": {
                                "id": "html",
                                "value_text": "HTML"
                              },
                              "property_settings": {
                                "single_dropdown_items": [
                                  {
                                    "id": "chat",
                                    "value_text": "Chat",
                                    "disabled": false,
                                    "is_checked": false,
                                    "value_text_hex_color": "#e19e7c",
                                    "prefix_icon": {
                                      "unicode": "0xe66c",
                                      "icon_color": "dark",
                                      "hex_color": "#e19e7c",
                                      "icon_size": 18
                                    }
                                  },
                                  {
                                    "id": "vibe",
                                    "value_text": "Vibe",
                                    "disabled": false,
                                    "is_checked": false,
                                    "value_text_hex_color": "#e19e7c",
                                    "prefix_icon": {
                                      "unicode": "0xe66c",
                                      "icon_color": "dark",
                                      "hex_color": "#e19e7c",
                                      "icon_size": 18
                                    }
                                  }
                                ]
                              }
                            }
                          },
                          "metadata": {
                            "description": "AI Text Processing Widget",
                            "version": "1.0.0",
                            "author": "Flutter Team"
                          }
                        },
                        {
                          "widget_id": "code_editor_right_side",
                          "widget_type": "code_editor",
                          "show_theme_dropdown": false,
                          "show_language_dropdown": false,
                          "is_read_only": true,
                          "add_path_button": {}
                        },
                        {
                          "widget_id": "html_widget",
                          "is_debug": true,
                          "widget_type": "html_widget",
                          "jinja_script_debug_view": "PGRpdiBzdHlsZT0iZm9udC1mYW1pbHk6IC1hcHBsZS1zeXN0ZW0sIEJsaW5rTWFjU3lzdGVtRm9udCwgJ1NlZ29lIFVJJywgUm9ib3RvLCBIZWx2ZXRpY2EsIEFyaWFsLCBzYW5zLXNlcmlmOyBjb2xvcjogIzMzMzsgYmFja2dyb3VuZC1jb2xvcjogI2Y5ZjlmOTsgcGFkZGluZzogMTZweDsgYm9yZGVyLXJhZGl1czogOHB4OyBib3gtc2hhZG93OiAwIDRweCAxMnB4IHJnYmEoMCwwLDAsMC4wNSk7Ij4KICA8ZGl2IHN0eWxlPSJmb250LXNpemU6IDE4cHg7IGZvbnQtd2VpZ2h0OiA2MDA7IGNvbG9yOiAjMTExOyBtYXJnaW4tYm90dG9tOiAxNnB4OyBib3JkZXItYm90dG9tOiAxcHggc29saWQgI2VlZTsgcGFkZGluZy1ib3R0b206IDhweDsiPgogICAgRGVidWcg4oCTIExpbmUge3tsaW5lTnVtYmVyfX0KICA8L2Rpdj4KCiAgPHRhYmxlIHN0eWxlPSJib3JkZXItY29sbGFwc2U6IGNvbGxhcHNlOyB3aWR0aDogMTAwJTsgYm9yZGVyLXJhZGl1czogOHB4OyBvdmVyZmxvdzogaGlkZGVuOyI+CiAgICA8dHIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmMGYwZjA7Ij4KICAgICAgPHRoIHN0eWxlPSJib3JkZXI6IDFweCBzb2xpZCAjZTBlMGUwOyBwYWRkaW5nOiAxMnB4OyB0ZXh0LWFsaWduOiBsZWZ0OyBmb250LXdlaWdodDogNjAwOyBjb2xvcjogIzU1NTsgd2lkdGg6IDE1MHB4OyI+Tm9kZSBUeXBlOjwvdGg+CiAgICAgIDx0ZCBzdHlsZT0iYm9yZGVyOiAxcHggc29saWQgI2UwZTBlMDsgcGFkZGluZzogMTJweDsiPjxzcGFuIHN0eWxlPSJmb250LWZhbWlseTogJ0NvdXJpZXIgTmV3JywgQ291cmllciwgbW9ub3NwYWNlOyBiYWNrZ3JvdW5kLWNvbG9yOiAjZTdlN2U3OyBwYWRkaW5nOiAycHggNnB4OyBib3JkZXItcmFkaXVzOiA0cHg7IGZvbnQtc2l6ZTogMTRweDsiPnt7bm9kZVR5cGV9fTwvc3Bhbj48L3RkPgogICAgPC90cj4KICAgIDx0ciBzdHlsZT0iYmFja2dyb3VuZC1jb2xvcjogI2ZmZmZmZjsiPgogICAgICA8dGggc3R5bGU9ImJvcmRlcjogMXB4IHNvbGlkICNlMGUwZTA7IHBhZGRpbmc6IDEycHg7IHRleHQtYWxpZ246IGxlZnQ7IGZvbnQtd2VpZ2h0OiA2MDA7IGNvbG9yOiAjNTU1OyI+Tm9kZSBOYW1lOjwvdGg+CiAgICAgIDx0ZCBzdHlsZT0iYm9yZGVyOiAxcHggc29saWQgI2UwZTBlMDsgcGFkZGluZzogMTJweDsiPjxzcGFuIHN0eWxlPSJmb250LWZhbWlseTogJ0NvdXJpZXIgTmV3JywgQ291cmllciwgbW9ub3NwYWNlOyBiYWNrZ3JvdW5kLWNvbG9yOiAjZTdlN2U3OyBwYWRkaW5nOiAycHggNnB4OyBib3JkZXItcmFkaXVzOiA0cHg7IGZvbnQtc2l6ZTogMTRweDsiPnt7bm9kZU5hbWV9fTwvc3Bhbj48L3RkPgogICAgPC90cj4KICAgIDx0ciBzdHlsZT0iYmFja2dyb3VuZC1jb2xvcjogI2YwZjBmMDsiPgogICAgICA8dGggc3R5bGU9ImJvcmRlcjogMXB4IHNvbGlkICNlMGUwZTA7IHBhZGRpbmc6IDEycHg7IHRleHQtYWxpZ246IGxlZnQ7IGZvbnQtd2VpZ2h0OiA2MDA7IGNvbG9yOiAjNTU1OyI+TGluZSBOdW1iZXI6PC90aD4KICAgICAgPHRkIHN0eWxlPSJib3JkZXI6IDFweCBzb2xpZCAjZTBlMGUwOyBwYWRkaW5nOiAxMnB4OyI+PHNwYW4gc3R5bGU9ImZvbnQtZmFtaWx5OiAnQ291cmllciBOZXcnLCBDb3VyaWVyLCBtb25vc3BhY2U7IGJhY2tncm91bmQtY29sb3I6ICNlN2U3ZTc7IHBhZGRpbmc6IDJweCA2cHg7IGJvcmRlci1yYWRpdXM6IDRweDsgZm9udC1zaXplOiAxNHB4OyI+e3tsaW5lTnVtYmVyfX08L3NwYW4+PC90ZD4KICAgIDwvdHI+CiAgICA8dHIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmZmZmY7Ij4KICAgICAgPHRoIHN0eWxlPSJib3JkZXI6IDFweCBzb2xpZCAjZTBlMGUwOyBwYWRkaW5nOiAxMnB4OyB0ZXh0LWFsaWduOiBsZWZ0OyBmb250LXdlaWdodDogNjAwOyBjb2xvcjogIzU1NTsiPk91dHB1dCBTbyBGYXI6PC90aD4KICAgICAgPHRkIHN0eWxlPSJib3JkZXI6IDFweCBzb2xpZCAjZTBlMGUwOyBwYWRkaW5nOiAxMnB4OyBmb250LWZhbWlseTogJ0NvdXJpZXIgTmV3JywgQ291cmllciwgbW9ub3NwYWNlOyBmb250LXNpemU6IDE0cHg7Ij57e291dHB1dFNvRmFyfX08L3RkPgogICAgPC90cj4KICAgIDx0ciBzdHlsZT0iYmFja2dyb3VuZC1jb2xvcjogI2YwZjBmMDsiPgogICAgICA8dGggc3R5bGU9ImJvcmRlcjogMXB4IHNvbGlkICNlMGUwZTA7IHBhZGRpbmc6IDEycHg7IHRleHQtYWxpZ246IGxlZnQ7IGZvbnQtd2VpZ2h0OiA2MDA7IGNvbG9yOiAjNTU1OyI+Q3VycmVudCBPdXRwdXQ6PC90aD4KICAgICAgPHRkIHN0eWxlPSJib3JkZXI6IDFweCBzb2xpZCAjZTBlMGUwOyBwYWRkaW5nOiAxMnB4OyBmb250LWZhbWlseTogJ0NvdXJpZXIgTmV3JywgQ291cmllciwgbW9ub3NwYWNlOyBmb250LXNpemU6IDE0cHg7Ij57e2N1cnJlbnRPdXRwdXR9fTwvdGQ+CiAgICA8L3RyPgogICAgPHRyIHN0eWxlPSJiYWNrZ3JvdW5kLWNvbG9yOiAjZmZmZmZmOyI+CiAgICAgIDx0aCBzdHlsZT0iYm9yZGVyOiAxcHggc29saWQgI2UwZTBlMDsgcGFkZGluZzogMTJweDsgdGV4dC1hbGlnbjogbGVmdDsgZm9udC13ZWlnaHQ6IDYwMDsgY29sb3I6ICM1NTU7Ij5Ob2RlIERhdGE6PC90aD4KICAgICAgPHRkIHN0eWxlPSJib3JkZXI6IDFweCBzb2xpZCAjZTBlMGUwOyBwYWRkaW5nOiAxMnB4OyBmb250LWZhbWlseTogJ0NvdXJpZXIgTmV3JywgQ291cmllciwgbW9ub3NwYWNlOyBmb250LXNpemU6IDE0cHg7Ij57e25vZGVEYXRhfX08L3RkPgogICAgPC90cj4KICAgIDx0ciBzdHlsZT0iYmFja2dyb3VuZC1jb2xvcjogI2YwZjBmMDsiPgogICAgICA8dGggc3R5bGU9ImJvcmRlcjogMXB4IHNvbGlkICNlMGUwZTA7IHBhZGRpbmc6IDEycHg7IHRleHQtYWxpZ246IGxlZnQ7IGZvbnQtd2VpZ2h0OiA2MDA7IGNvbG9yOiAjNTU1OyI+TG9jYWwgdmFyaWFibGVzOjwvdGg+CiAgICAgIDx0ZCBzdHlsZT0iYm9yZGVyOiAxcHggc29saWQgI2UwZTBlMDsgcGFkZGluZzogMDsiPgogICAgICAgIDx0YWJsZSBzdHlsZT0iYm9yZGVyLWNvbGxhcHNlOiBjb2xsYXBzZTsgd2lkdGg6IDEwMCU7Ij4KICAgICAgICAgIHslIGZvciBrZXksIHZhbHVlIGluIHZhcmlhYmxlcyAlfQogICAgICAgICAgICA8dHIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmYWZhZmE7Ij4KICAgICAgICAgICAgICA8dGggY29sc3Bhbj0iMiIgc3R5bGU9ImJvcmRlcjogMXB4IHNvbGlkICNlMGUwZTA7IHBhZGRpbmc6IDEwcHg7IHRleHQtYWxpZ246IGxlZnQ7IGZvbnQtd2VpZ2h0OiA2MDA7IGNvbG9yOiAjMzMzOyBiYWNrZ3JvdW5kLWNvbG9yOiAjZTllOWU5OyI+e3trZXl9fTwvdGg+CiAgICAgICAgICAgIDwvdHI+CiAgICAgICAgICAgIDx0ciBzdHlsZT0iYmFja2dyb3VuZC1jb2xvcjogI2ZmZmZmZjsiPgogICAgICAgICAgICAgIDx0ZCBjb2xzcGFuPSIyIiBzdHlsZT0iYm9yZGVyOiAxcHggc29saWQgI2UwZTBlMDsgcGFkZGluZzogMTBweDsiPgogICAgICAgICAgICAgICAgPGpzb24tZWRpdG9yPnt7dmFsdWUgfCB0b2pzb259fTwvanNvbi1lZGl0b3I+CiAgICAgICAgICAgICAgPC90ZD4KICAgICAgICAgICAgPC90cj4KICAgICAgICAgIHslIGVuZGZvciAlfQogICAgICAgIDwvdGFibGU+CiAgICAgIDwvdGQ+CiAgICA8L3RyPgogIDwvdGFibGU+CjwvZGl2Pg==",
                          "loading": false
                        },
                        {
                          "widget_id": "errors",
                          "is_error": true,
                          "widget_type": "html_widget",
                          "on_tap_html": false,
                          "show_chevron_button": false,
                          "padding": {
                            "left": {
                              "value": 8.0
                            },
                            "right": {
                              "value": 8.0
                            },
                            "bottom": {
                              "value": 8.0
                            },
                            "top": {
                              "value": 8.0
                            }
                          },
                          "loading": false
                        },
                        {
                          "widget_id": "help_widget_id",
                          "widget_type": "help_widget"
                        }
                      ]
                    },
                    "left_side": {
                      "output_type": "jframe",
                      "set_right_side_collapse_button_icon": {
                        "height": {
                          "value": 15.0
                        },
                        "width": {
                          "value": 15.0
                        },
                        "tooltip_message": {
                          "value": "Collapse"
                        },
                        "mode": {
                          "value": "network"
                        },
                        "icon_selected_color": "error",
                        "data": {
                          "value": "https://files.svgcdn.io/sidekickicons/sidebar-left.svg"
                        }
                      },
                      "expand_button_icon": {
                        "height": {
                          "value": 15.0
                        },
                        "width": {
                          "value": 15.0
                        },
                        "tooltip_message": {
                          "value": "Expand Code"
                        },
                        "mode": {
                          "value": "network"
                        },
                        "icon_selected_color": "error",
                        "data": {
                          "value": "https://files.svgcdn.io/prime/expand.svg"
                        }
                      },
                      "build_script_button_icon": {
                        "height": {
                          "value": 15.0
                        },
                        "width": {
                          "value": 15.0
                        },
                        "tooltip_message": {
                          "value": "Build Script"
                        },
                        "mode": {
                          "value": "network"
                        },
                        "icon_selected_color": "error",
                        "data": {
                          "value": "https://files.svgcdn.io/uit/rocket.svg"
                        }
                      },
                      "add_data_button_icon": {
                        "height": {
                          "value": 15.0
                        },
                        "width": {
                          "value": 15.0
                        },
                        "tooltip_message": {
                          "value": "Add Data"
                        },
                        "mode": {
                          "value": "network"
                        },
                        "icon_selected_color": "error",
                        "data": {
                          "value": "https://files.svgcdn.io/lineicons/webhooks.svg"
                        }
                      },
                      "show_start_script_button": false,
                      "tab_bar_widget": {
                        "property_settings": {
                          "styles": {
                            "border_color": {
                              "value": "neutral_white"
                            },
                            "background_color": {
                              "value": "neutral_white"
                            },
                            "hover_color": {
                              "value": "neutral_white"
                            },
                            "selected_color": {
                              "value": "neutral_white"
                            },
                            "text_style": {
                              "value": "body"
                            },
                            "unselected_text_color": {
                              "value": "transparent"
                            },
                            "selected_text_color": {
                              "value": "transparent"
                            },
                            "icon_color": {
                              "value": "primary"
                            },
                            "icon_background_color": {
                              "value": "transparent"
                            },
                            "is_indicator_line": {
                              "value": 0.0
                            },
                            "is_border_enabled": {
                              "value": 0.0
                            },
                            "indicator_color": {
                              "value": "transparent"
                            }
                          }
                        },
                        "initial_index": 0,
                        "tabs": [
                          {
                            "data": {
                              "icon_selected_color": "error",
                              "tooltip": "Code Editor",
                              "icon_data": {
                                "widget_id": {
                                  "value": "flutter_svg"
                                },
                                "widget_type": {
                                  "value": "flutter_svg"
                                },
                                "mode": {
                                  "value": "network"
                                },
                                "data": {
                                  "value": "https://files.svgcdn.io/si-glyph/code.svg"
                                }
                              }
                            }
                          },
                          {
                            "data": {
                              "icon_selected_color": "error",
                              "tooltip": "Data",
                              "icon_data": {
                                "widget_id": {
                                  "value": "flutter_svg"
                                },
                                "widget_type": {
                                  "value": "flutter_svg"
                                },
                                "mode": {
                                  "value": "network"
                                },
                                "data": {
                                  "value": "https://files.svgcdn.io/octicon/database-24.svg"
                                }
                              }
                            }
                          }
                        ]
                      },
                      "sub_page_id": "",
                      "sub_pages": [
                        {
                          "widget_id": "api",
                          "widget_type": "jinja_api_manager",
                          "widget_mode": "edit",
                          "width": 1400,
                          "height": 800,
                          "collections": [
                            {
                              "id": "1",
                              "name": "HTTPBin Test API",
                              "is_expanded": true,
                              "variables": {
                                "baseUrl": "https://httpbin.org",
                                "apiVersion": "v1"
                              },
                              "headers": {
                                "Content-Type": "application/json",
                                "Accept": "application/json"
                              },
                              "requests": [
                                {
                                  "id": "req1",
                                  "name": "Test POST Request",
                                  "method": "POST",
                                  "url": "https://httpbin.org/post",
                                  "headers": {
                                    "Custom-Header": "MyApp/1.0"
                                  },
                                  "params": {
                                    "search": "testing",
                                    "limit": "5"
                                  },
                                  "cookies": {
                                    "session": "abc123",
                                    "theme": "dark"
                                  },
                                  "auth": {
                                    "type": "apiKey",
                                    "key_name": "X-Api-Key",
                                    "key_value": "my-secret-key",
                                    "in_": "header"
                                  },
                                  "json": {
                                    "message": "Hello from FastAPI proxy",
                                    "array": [
                                      1,
                                      2,
                                      3
                                    ],
                                    "nested": {
                                      "a": "b"
                                    }
                                  },
                                  "timeout": 10,
                                  "verify": true
                                },
                                {
                                  "id": "req2",
                                  "name": "Get Request",
                                  "method": "GET",
                                  "url": "{{baseUrl}}/get",
                                  "headers": {},
                                  "params": {
                                    "test": "value"
                                  }
                                }
                              ]
                            },
                            {
                              "id": "2",
                              "name": "DummyJSON API",
                              "is_expanded": false,
                              "variables": {
                                "baseUrl": "https://dummyjson.com"
                              },
                              "headers": {
                                "Content-Type": "application/json"
                              },
                              "requests": [
                                {
                                  "id": "req3",
                                  "name": "Get All Users",
                                  "method": "GET",
                                  "url": "{{baseUrl}}/users",
                                  "headers": {},
                                  "params": {}
                                },
                                {
                                  "id": "req4",
                                  "name": "Search Users",
                                  "method": "GET",
                                  "url": "{{baseUrl}}/users/search",
                                  "headers": {},
                                  "params": {
                                    "q": "John"
                                  }
                                }
                              ]
                            }
                          ],
                          "selected_collection_id": "1",
                          "selected_request_id": "req1",
                          "button": {
                            "text": "Send",
                            "background_color": "primary",
                            "text_color": "white",
                            "border_radius": 4
                          },
                          "text_field": {
                            "border_color": "lighter",
                            "fill_color": "white"
                          },
                          "dropdown": {
                            "background_color": "white",
                            "border_color": "lighter"
                          }
                        },
                        {
                          "widget_id": "data_source",
                          "widget_type": "data_source"
                        },
                        {
                          "widget_id": "natural_language_editor",
                          "widget_type": "natural_language_editor"
                        },
                        {
                          "widget_id": "drag_and_drop_editor",
                          "widget_type": "drag_and_drop_editor"
                        }
                      ],
                      "pages": [
                        {
                          "widget_id": "code_editor_left_side",
                          "widget_type": "code_editor",
                          "show_theme_dropdown": true,
                          "show_language_dropdown": false,
                          "custom_suggestion_jinja_flutter_html": {
                            "widget_id": "html_widget",
                            "widget_type": "html_widget",
                            "html": "",
                            "description": "",
                            "loading": false
                          },
                          "list_of_custom_suggestions": [
                            {
                              "label": "Example Variables from backend",
                              "replaced_on_click": "{{ example_variable }}",
                              "triggered_at": "aaa",
                              "description": "THIS IS A JINJA DESCRIPTION EXAMPLE"
                            },
                            {
                              "label": "Example Variables from backend",
                              "replaced_on_click": "{{ example_variable_2 }}",
                              "triggered_at": "aaa",
                              "description": "THIS IS A JINJA DESCRIPTION EXAMPLE"
                            }
                          ],
                          "language_dropdown_json": {
                            "widget_id": "uid",
                            "widget_type": "dropdown",
                            "mode": "edit",
                            "data": {
                              "id": "html",
                              "value_text": "HTML"
                            },
                            "property_settings": {
                              "single_dropdown_items": [
                                {
                                  "id": "html",
                                  "value_text": "HTML",
                                  "disabled": false,
                                  "is_checked": true,
                                  "value_text_hex_color": "#e19e7c"
                                },
                                {
                                  "id": "json",
                                  "value_text": "JSON",
                                  "is_checked": false
                                },
                                {
                                  "id": "sql",
                                  "value_text": "SQL",
                                  "is_checked": false
                                }
                              ]
                            }
                          },
                          "add_path_button": {}
                        },
                        {
                          "widget_id": "jinja_json_editor_widget_id",
                          "editor_dropdown_json": {
                            "widget_id": "uid",
                            "widget_type": "dropdown",
                            "mode": "edit",
                            "data": {
                              "value": "text",
                              "value_text": "Text"
                            },
                            "property_settings": {
                              "width": {
                                "value": 15.0
                              },
                              "height": {
                                "value": 32.0
                              },
                              "single_dropdown_items": [
                                {
                                  "value": "text",
                                  "value_text": "Text"
                                },
                                {
                                  "value": "tree",
                                  "value_text": "Tree"
                                }
                              ]
                            }
                          },
                          "widget_type": "json_editor",
                          "widget_mode": "edit",
                          "data": {
                            "value": {}
                          },
                          "disabled": false,
                          "border_color": "grey",
                          "padding": {
                            "left": {
                              "value": 8.0
                            },
                            "right": {
                              "value": 8.0
                            },
                            "bottom": {
                              "value": 8.0
                            },
                            "top": {
                              "value": 8.0
                            }
                          },
                          "on_load": null,
                          "on_json_changed": null,
                          "copy_button_icon_model": {
                            "height": {
                              "value": 15.0
                            },
                            "width": {
                              "value": 15.0
                            },
                            "mode": {
                              "value": "network"
                            },
                            "data": {
                              "value": "https://files.svgcdn.io/proicons/copy.svg"
                            }
                          },
                          "format_button_icon_model": {
                            "height": {
                              "value": 15.0
                            },
                            "width": {
                              "value": 15.0
                            },
                            "mode": {
                              "value": "network"
                            },
                            "data": {
                              "value": "https://files.svgcdn.io/clarity/align-left-text-line.svg"
                            }
                          },
                          "next_button_icon_model": {
                            "height": {
                              "value": 15.0
                            },
                            "width": {
                              "value": 15.0
                            },
                            "mode": {
                              "value": "network"
                            },
                            "icon_selected_color": "error",
                            "data": {
                              "value": "https://files.svgcdn.io/hugeicons/next.svg"
                            }
                          },
                          "previous_button_icon_model": {
                            "height": {
                              "value": 15.0
                            },
                            "width": {
                              "value": 15.0
                            },
                            "mode": {
                              "value": "network"
                            },
                            "icon_selected_color": "error",
                            "data": {
                              "value": "https://files.svgcdn.io/hugeicons/previous.svg"
                            }
                          },
                          "expand_all_button_icon_model": {
                            "height": {
                              "value": 15.0
                            },
                            "width": {
                              "value": 15.0
                            },
                            "mode": {
                              "value": "network"
                            },
                            "icon_selected_color": "error",
                            "data": {
                              "value": "https://files.svgcdn.io/iwwa/expand.svg"
                            }
                          },
                          "collapse_all_button_icon_model": {
                            "height": {
                              "value": 15.0
                            },
                            "width": {
                              "value": 15.0
                            },
                            "mode": {
                              "value": "network"
                            },
                            "icon_selected_color": "error",
                            "data": {
                              "value": "https://files.svgcdn.io/iconoir/collapse.svg"
                            }
                          },
                          "show_collapse_all_button": true,
                          "show_expand_all_button": true,
                          "show_copy_button": true,
                          "show_format_button": true
                        }
                      ]
                    }
                  }
                }
              ]
            }
          ]
        }
      ]
    }
  },
  "data": {}
}
''';
final jinjaData = {
  'jinja_script_id': '5c61aa50-d001-487b-8c12-5b2380bdedd4',
  'output_type': '',
  'cell_value': 'code_editor',
  'table_name': 'content',
  'column_name': 'content_id',
  'widget_id': 'code_editor',
  'clear_data': true,
  'page_id': 'code_editor',
  'jinja_script_by_id': {
    'jinja_script': {
      'data': {
        'text':
            'e3sKICBydW5fZGF0YV9zb3VyY2UoJ2dldF9jb3VudCcsIHsnY29udGVudF90eXBlJzonY29udGVudF90eXBlX2ppbmphX3NjcmlwdCd9KQp9fQoKCnt7CiAgcnVuX2RhdGFfc291cmNlKCdnZXRfY291bnQnKQp9fQoKe3sKICAgIHJ1bl9kYXRhX3NvdXJjZSgnc3RvcmVfc2luZ2xlX2FwcF9sYXlvdXQnLCB7J2NhdGVnb3J5X2lkJzondG9wX2ZyZWVfYXBwcyd9ICkKfX0KCnt7CiAgICBydW5fZGF0YV9zb3VyY2UoJ2dldF9yYWRpb19hcHBfamZyYW1lJykKfX0KClRISVMgSVMgVEhFIERBVEEKe3sgZGF0YSB9fQpUSElTIElTIFRIRSBEQVRB',
        'column_id': 'jinja_script',
      },
      'ui_widget': {
        'ui_widget_id': 'list_row_text',
      },
    },
    'jinja_data': {
      'output_type': 'html',
    },
    'parent_id': null,
  },
  'jinja_ide_ai_agents': [
    {
      'id': '1',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Input',
        'description': 'Schema for input to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user, used for tracking and personalization.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message. This is the primary input from the user.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session, used to maintain context.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format, used for logging and ordering.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {
            'description': 'An open-ended object for any additional metadata.',
            'type': 'object',
          },
          'selected': {
            'description':
                'Any text or code selected by the user for context. This can be used to provide additional information for the query.',
            'type': 'string',
          },
          'history': {
            'description': 'A list of color updates.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'agent': {
                  'description': "The user's message.",
                  'type': 'string',
                },
                'user': {
                  'description': "The agent's message",
                  'type': 'string',
                },
              },
              'required': [
                'agent',
                'user',
              ],
            },
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Output',
        'description': 'Schema for output to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the chat-IN.json schema #} {# into a clean, human-readable prompt for a Large Language Model (LLM). #} {# It prioritizes the user's query and any selected text for context, #} {# while omitting irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Conversational Partner Purpose: You are to engage in a helpful dialogue with the user. Your task is to discuss project ideas, answer any questions they have, and provide clear and concise explanations and documentation especially pertaining to Jinja. You should be direct and responsive, acting as a knowledgeable guide throughout the project.  {# Display conversation history if available #} {% if history %} **Conversation History:** {% for message in history %} You: {{- message.content.agent }} Me: {{- message.content.user }} {% endif %} {% endfor %} --- {% endif %}  {# The main query from the user. #} {{ query }}  {# Check if the user has selected any text for additional context. #} {% if selected %} The user has the following text selected and may refer to it in their message: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to provide temporal context for the query. #} {# This can be useful for time-sensitive questions. #} Timestamp: {{ timestamp }}",
      'agent_id': 'chat',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '2',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Architect LLM Input',
        'description': 'Schema for input to the Architect LLM for general chitchat and Q&A.',
        'long_description':
            'The Architect LLM is used for longer term task planning.  It is aimed at creating a long term step by step plan for a larger task.  It outputs an array of task descriptions.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {},
          'files': {
            'description': 'An array of files to include in the context.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'description': 'The name of the file.',
                  'type': 'string',
                },
                'filepath': {
                  'description': 'The path to the file on the server.',
                  'type': 'string',
                },
              },
              'required': [
                'name',
                'filepath',
              ],
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Output',
        'description': 'Schema for output to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the chat-IN.json schema #} {# into a clean, human-readable prompt for a Large Language Model (LLM). #} {# It prioritizes the user's query and any selected text for context, #} {# while omitting irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Conversational Partner Purpose: You are to engage in a helpful dialogue with the user. Your task is to discuss project ideas, answer any questions they have, and provide clear and concise explanations and documentation especially pertaining to Jinja. You should be direct and responsive, acting as a knowledgeable guide throughout the project.  {# Display conversation history if available #} {%- if history -%} **Conversation History:** {%- for message in history -%} **{{ message.role | capitalize }}**: {% if message.role == 'assistant' %}{{- message.content.response }}{% else %}{{- message.content }}{% endif %} {%- endfor -%} --- {%- endif -%}  {# The main query from the user. #} {{ query }}  {# Check if the user has selected any text for additional context. #} {% if selected %} The user has the following text selected and may refer to it in their message: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to provide temporal context for the query. #} {# This can be useful for time-sensitive questions. #} Timestamp: {{ timestamp }}",
      'agent_id': 'architect',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '3',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Archivist LLM Input',
        'description': 'Schema for input to the Archivist LLM for creating long term memories.',
        'long_description':
            "This is a very simple endpoint to just add to long-term memory.  It formulates the user's input (including optional files and selected text/code), for long term storage and returns a message on success.",
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {},
          'files': {
            'description': 'An array of files to include in the context.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'description': 'The name of the file.',
                  'type': 'string',
                },
                'filepath': {
                  'description': 'The path to the file on the server.',
                  'type': 'string',
                },
              },
              'required': [
                'name',
                'filepath',
              ],
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Output',
        'description': 'Schema for output to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the chat-IN.json schema #} {# into a clean, human-readable prompt for a Large Language Model (LLM). #} {# It prioritizes the user's query and any selected text for context, #} {# while omitting irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Conversational Partner Purpose: You are to engage in a helpful dialogue with the user. Your task is to discuss project ideas, answer any questions they have, and provide clear and concise explanations and documentation especially pertaining to Jinja. You should be direct and responsive, acting as a knowledgeable guide throughout the project.  {# Display conversation history if available #} {%- if history -%} **Conversation History:** {%- for message in history -%} **{{ message.role | capitalize }}**: {% if message.role == 'assistant' %}{{- message.content.response }}{% else %}{{- message.content }}{% endif %} {%- endfor -%} --- {%- endif -%}  {# The main query from the user. #} {{ query }}  {# Check if the user has selected any text for additional context. #} {% if selected %} The user has the following text selected and may refer to it in their message: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to provide temporal context for the query. #} {# This can be useful for time-sensitive questions. #} Timestamp: {{ timestamp }}",
      'agent_id': 'archivist',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '4',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Artist LLM Input',
        'description': 'Schema for input to the Artist LLM for generating color palettes.',
        'long_description':
            'The Artist LLM generates color palettes based on user queries. It can optionally take an existing color palette as context to modify.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {
            'description': 'An open-ended object for any additional metadata.',
            'type': 'object',
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
          'task_id': {
            'description': 'The task from the Architect to work on',
            'type': 'string',
          },
          'color_palette': {
            'description': 'An optional array representing the current color palette, loaded from color_palette.json.',
            'type': 'array',
            'items': {
              'type': 'object',
            },
          },
          'history': {
            'description': 'A list of color updates.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'agent': {
                  'description': "The user's message.",
                  'type': 'string',
                },
                'user': {
                  'description': "The agent's message",
                  'type': 'string',
                },
              },
              'required': [
                'agent',
                'user',
              ],
            },
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Artist LLM Output',
        'description': "Schema for the Artist LLM's color palette generation.",
        'type': 'object',
        'properties': {
          'name': {
            'description': 'The name of the agent responding.',
            'type': 'string',
          },
          'response': {
            'description': 'A user-facing, conversational reply.',
            'type': 'string',
          },
          'edits': {
            'description': 'A list of color updates.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'widget_id': {
                  'description': 'The ID of the UI widget to apply the color to.',
                  'type': 'string',
                  'enum': [
                    'primary',
                    'primaryforeground',
                    'primaryhover',
                    'secondary',
                    'secondaryforeground',
                    'tertiary',
                    'tertiaryforeground',
                    'accent',
                    'accentforeground',
                    'success',
                    'error',
                    'warning',
                    'info',
                    'textprimary',
                    'textsecondary',
                    'muted',
                    'mutedforeground',
                    'background',
                    'border',
                    'input',
                    'ring',
                    'card',
                    'cardforeground',
                    'popover',
                    'popoverforeground',
                  ],
                },
                'dark': {
                  'description': 'The hex color code for the widget in dark mode.',
                  'type': 'string',
                  'pattern': '^#[0-9a-fA-F]+',
                },
                'light': {
                  'description': 'The hex color code for the widget in light mode.',
                  'type': 'string',
                  'pattern': '^#[0-9a-fA-F]+',
                },
              },
              'required': [
                'widget_id',
                'dark',
                'light',
              ],
            },
          },
        },
        'required': [
          'name',
          'response',
          'edits',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the artist-IN.json schema #} {# into a detailed prompt for the Artist LLM. #} You are an expert color theorist and designer. {{ name }} Agent Role: Color Palette Generator Purpose: You are responsible for generating a color palette based on the user's request. Your output must be a single JSON object.  Do not make the dark themes too dark or the light themes too light. When making a dark theme ensure that the background is not pure black, it should still have a slight tint of some color the user asks for.  {# Display conversation history if available #} {% if history %} **Conversation History:** {% for message in history %} You: {{- message.content.agent }} Me: {{- message.content.user }} {% endif %} {% endfor %} --- {% endif %}  **Available Colors Schema for `edits`:** You can only change colors that are defined in the following schema. You must use the `widget_id` from this schema.  - primary  - primaryforeground  - primaryhover  - secondary  - secondaryforeground  - tertiary  - tertiaryforeground  - accent  - accentforeground  - success  - error  - warning  - info  - textprimary  - textsecondary  - muted  - mutedforeground  - background  - border  - input  - ring  - card  - cardforeground  - popover  - popoverforeground  {% if color_palette %} **Current Color Palette:** Here is the existing color palette. Use this as a baseline for your changes. {% for widget in color_palette %} - **{{ widget.widget_id }}**:   {% for prop in widget.properties %}   - `{{ prop.property_id }}`: `{{ prop.value }}`   {% endfor %} {% endfor %} {% endif %}  **User Request:** {{ query }}  Timestamp: {{ timestamp }}  --- Based on the user's request, generate the complete JSON output now. Do not include any other text or explanation.",
      'agent_id': 'artist',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '5',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Builder LLM Input',
        'description': 'Schema for input the Builder LLM for quick vibe coding',
        'long_description':
            'The Builder LLM is used for rapid development and vibe coding.  It will take in a user request, and respond with an array of proposed changes and explanations for each.  The Builder is used to carry out the plans of the Architect',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {},
          'files': {
            'description': 'An array of files to include in the context.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'description': 'The name of the file.',
                  'type': 'string',
                },
                'filepath': {
                  'description': 'The path to the file on the server.',
                  'type': 'string',
                },
              },
              'required': [
                'name',
                'filepath',
              ],
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
          'task_id': {
            'description': 'The task from the Architect to work on',
            'type': 'string',
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
          'files',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Output',
        'description': 'Schema for output to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the chat-IN.json schema #} {# into a clean, human-readable prompt for a Large Language Model (LLM). #} {# It prioritizes the user's query and any selected text for context, #} {# while omitting irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Conversational Partner Purpose: You are to engage in a helpful dialogue with the user. Your task is to discuss project ideas, answer any questions they have, and provide clear and concise explanations and documentation especially pertaining to Jinja. You should be direct and responsive, acting as a knowledgeable guide throughout the project.  {# Display conversation history if available #} {%- if history -%} **Conversation History:** {%- for message in history -%} **{{ message.role | capitalize }}**: {% if message.role == 'assistant' %}{{- message.content.response }}{% else %}{{- message.content }}{% endif %} {%- endfor -%} --- {%- endif -%}  {# The main query from the user. #} {{ query }}  {# Check if the user has selected any text for additional context. #} {% if selected %} The user has the following text selected and may refer to it in their message: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to provide temporal context for the query. #} {# This can be useful for time-sensitive questions. #} Timestamp: {{ timestamp }}",
      'agent_id': 'builder',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '6',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Archivist LLM Input',
        'description': 'Schema for input to the Archivist LLM for creating long term memories.',
        'long_description':
            "This is a very simple endpoint to just add to long-term memory.  It formulates the user's input (including optional files and selected text/code), for long term storage and returns a message on success.",
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {
            'description': 'An open-ended object for any additional metadata.',
            'type': 'object',
          },
          'files': {
            'description': 'An array of files to include in the context.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'description':
                      "The name of the LLM. This should be a human-readable identifier for the agent responding, for example, 'Vibe Agent'. Its purpose is to clearly attribute the source of the response.",
                  'type': 'string',
                },
                'filepath': {
                  'description': 'The path to the file on the server.',
                  'type': 'string',
                },
                'file_contents': {
                  'description': 'The contents of the file',
                  'type': 'string',
                },
              },
              'required': [
                'name',
                'filepath',
                'file_contents',
              ],
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
          'history': {
            'description': 'A list of color updates.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'agent': {
                  'description': "The user's message.",
                  'type': 'string',
                },
                'user': {
                  'description': "The agent's message",
                  'type': 'string',
                },
              },
              'required': [
                'agent',
                'user',
              ],
            },
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Archivist LLM Output',
        'description': 'Schema for output from the Archivist LLM for creating long term memories.',
        'long_description':
            "This is a very simple endpoint to just add to long-term memory.  It formulates the user's input (including optional files and selected text/code), for long term storage and returns a message on success.",
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the context-IN.json schema #} {# into a structured prompt for the Archivist LLM, which is responsible for creating long-term memories. #} {# The template captures the user's query, any selected text, and associated files to form a comprehensive memory. #} {# It excludes transient data like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Data Pre-processor Purpose: Your primary job is to efficiently scan incoming, unstructured data and extract the most relevant information. You should then reformat this data into a structured and easily digestible format for other LLMs and for long-term memory. You must identify key entities, relationships, and concepts, and present them in a clear, organized way. The user will be able to individually reject or accept each of your edits so do not be timid, as long as they are small and digestible.  {# Display conversation history if available #} {% if history %} **Conversation History:** {% for message in history %} You: {{- message.content.agent }} Me: {{- message.content.user }} {% endif %} {% endfor %} --- {% endif %}  {# The core text or query from the user that needs to be remembered. #} {{ query }}  {# If the user had text selected, include it as part of the memory's context. #} {% if selected %} The user had the following text selected: --- {{ selected }} --- {% endif %}  {# If files were associated with this memory, list them. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to record when this memory was created. #} Timestamp: {{ timestamp }}",
      'agent_id': 'context',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '7',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Debugger LLM Input',
        'description': 'Schema for input to the Debugger LLM for general chitchat and Q&A.',
        'long_description':
            'The Debugger LLM is the most complex.  It takes in files, selected code/text, and a unique bug_id.  The bug_id will be needed to track harder bugs that require multiple sessions to resolve.  Bugs will be added to a database.  It will return optional edits, like the Builder.  More significantly it will return a list of hypotheses and attempts which it will use to reason, problem solve, and most importantly prevent backtracking.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {},
          'bug_id': {
            'description': 'The unique identifier for the bug.',
            'type': 'string',
          },
          'files': {
            'description': 'An array of files to include in the context.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'description': 'The name of the file.',
                  'type': 'string',
                },
                'filepath': {
                  'description': 'The path to the file on the server.',
                  'type': 'string',
                },
              },
              'required': [
                'name',
                'filepath',
              ],
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
          'bug_id',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Output',
        'description': 'Schema for output to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "\"\"\"{# This Jinja template formats a JSON object matching the chat-IN.json schema #} {# into a clean, human-readable prompt for a Large Language Model (LLM). #} {# It prioritizes the user's query and any selected text for context, #} {# while omitting irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Conversational Partner Purpose: You are to engage in a helpful dialogue with the user. Your task is to discuss project ideas, answer any questions they have, and provide clear and concise explanations and documentation especially pertaining to Jinja. You should be direct and responsive, acting as a knowledgeable guide throughout the project.  {# Display conversation history if available #} {%- if history -%} **Conversation History:** {%- for message in history -%} **{{ message.role | capitalize }}**: {% if message.role == 'assistant' %}{{- message.content.response }}{% else %}{{- message.content }}{% endif %} {%- endfor -%} --- {%- endif -%}  {# The main query from the user. #} {{ query }}  {# Check if the user has selected any text for additional context. #} {% if selected %} The user has the following text selected and may refer to it in their message: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to provide temporal context for the query. #} {# This can be useful for time-sensitive questions. #} Timestamp: {{ timestamp }} \"\"\"",
      'agent_id': 'debugger',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '8',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Input',
        'description': 'Schema for input to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'image': {
            'description': 'Image url',
            'type': 'string',
          },
        },
        'required': [
          'model',
          'image',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Output',
        'description': 'Schema for output to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the chat-IN.json schema #} {# into a clean, human-readable prompt for a Large Language Model (LLM). #} {# It prioritizes the user's query and any selected text for context, #} {# while omitting irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Conversational Partner Purpose: You are to engage in a helpful dialogue with the user. Your task is to discuss project ideas, answer any questions they have, and provide clear and concise explanations and documentation especially pertaining to Jinja. You should be direct and responsive, acting as a knowledgeable guide throughout the project.  {# Display conversation history if available #} {%- if history -%} **Conversation History:** {%- for message in history -%} **{{ message.role | capitalize }}**: {% if message.role == 'assistant' %}{{- message.content.response }}{% else %}{{- message.content }}{% endif %} {%- endfor -%} --- {%- endif -%}  {# The main query from the user. #} {{ query }}  {# Check if the user has selected any text for additional context. #} {% if selected %} The user has the following text selected and may refer to it in their message: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to provide temporal context for the query. #} {# This can be useful for time-sensitive questions. #} Timestamp: {{ timestamp }}",
      'agent_id': 'photographer',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '9',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Proofreader LLM Input',
        'description': 'Schema for input to the Proofreader LLM for code review',
        'long_description':
            'The Proofreader LLM is used as a simpler form of the Builder.  It implicitly will always examine only the currently open file, and try to suggest more minimal, best-practice and stylistic changes.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'file': {
            'name': {
              'description': 'The name of the file.',
              'type': 'string',
            },
            'filepath': {
              'description': 'The path to the file on the server.',
              'type': 'string',
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
          'history': {
            'description': 'A list of color updates.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'agent': {
                  'description': "The user's message.",
                  'type': 'string',
                },
                'user': {
                  'description': "The agent's message",
                  'type': 'string',
                },
              },
              'required': [
                'agent',
                'user',
              ],
            },
          },
        },
        'required': [
          'user_id',
          'session_id',
          'timestamp',
          'model',
          'agent_id',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Proofreader LLM Output',
        'description': 'Schema for output to the Proofreader LLM for code review',
        'long_description':
            'The Proofreader LLM is used as a simpler form of the Builder.  It implicitly will always examine only the currently open file, and try to suggest more minimal, best-practice and stylistic changes.',
        'type': 'object',
        'properties': {
          'response': {
            'description': "The LLM's text response to the user's query.",
            'type': 'string',
          },
          'edits': {
            'description': 'A list of objects detailing edits made to files.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'edit_id': {
                  'type': 'string',
                  'description': 'Unique identifier for the edit',
                },
                'file_path': {
                  'type': 'string',
                  'description': 'The path to the file where the replacement occurred.',
                },
                'old_string': {
                  'type': 'string',
                  'description': 'The string that was replaced.',
                },
                'new_string': {
                  'type': 'string',
                  'description': 'The string that replaced the old string.',
                },
                'justification': {
                  'type': 'string',
                  'description': 'An explanation of the decision.',
                },
              },
              'required': [
                'edit_id',
                'file_path',
                'old_string',
                'new_string',
              ],
            },
          },
        },
        'required': [
          'response',
          'edits',
        ],
      },
      'jinja_template':
          '{# This Jinja template formats a JSON object matching the proofreader-IN.json schema #} {# into a prompt for the Proofreader LLM, which specializes in code review. #} {# The prompt is designed to be concise, focusing on the file to be reviewed and any selected text. #} {# It omits irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Code Reviewer Purpose: Your job is to perform a detailed code review on the selected files. You will read through the code and make minimal, non-structural changes. Your goal is to simplify the code, ensure it adheres to best practices, and improve formatting for best practices without altering its core functionality. The user will be able to individually reject or accept each of your edits so do not be timid, as long as they are small and digestible.  {# Display conversation history if available #} {% if history %} **Conversation History:** {% for message in history %} You: {{- message.content.agent }} Me: {{- message.content.user }} {% endif %} {% endfor %} --- {% endif %}  Please review the following file for style, best practices, and potential improvements.  {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {% if selected %} The user has highlighted the following section for specific attention: --- {{ selected }} --- {% endif %}  {# The timestamp provides context for when the review was requested. #} Timestamp: {{ timestamp }}',
      'agent_id': 'proofreader',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '10',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Secretary LLM Input',
        'description': 'Schema for input to the Secretary LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {},
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Output',
        'description': 'Schema for output to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the chat-IN.json schema #} {# into a clean, human-readable prompt for a Large Language Model (LLM). #} {# It prioritizes the user's query and any selected text for context, #} {# while omitting irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Conversational Partner Purpose: You are to engage in a helpful dialogue with the user. Your task is to discuss project ideas, answer any questions they have, and provide clear and concise explanations and documentation especially pertaining to Jinja. You should be direct and responsive, acting as a knowledgeable guide throughout the project.  {# Display conversation history if available #} {%- if history -%} **Conversation History:** {%- for message in history -%} **{{ message.role | capitalize }}**: {% if message.role == 'assistant' %}{{- message.content.response }}{% else %}{{- message.content }}{% endif %} {%- endfor -%} --- {%- endif -%}  {# The main query from the user. #} {{ query }}  {# Check if the user has selected any text for additional context. #} {% if selected %} The user has the following text selected and may refer to it in their message: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to provide temporal context for the query. #} {# This can be useful for time-sensitive questions. #} Timestamp: {{ timestamp }}",
      'agent_id': 'secretary',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '11',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Solver LLM Input',
        'description': 'Schema for input to the Solver LLM for general chitchat and Q&A.',
        'long_description':
            'The Solver LLM is the most complex.  It takes in files, selected code/text, and a unique bug_id.  The bug_id will be needed to track harder bugs that require multiple sessions to resolve.  Bugs will be added to a database.  It will return optional edits, like the Builder.  More significantly it will return a list of hypotheses and attempts which it will use to reason, problem solve, and most importantly prevent backtracking.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'error_messages': {
            'description': 'An array of relevant error messages.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'text': {
                  'description': 'The text of the error message.',
                  'type': 'string',
                },
                'source': {
                  'description': 'The program and file which triggered the error',
                  'type': 'string',
                },
              },
              'required': [
                'text',
                'source',
              ],
            },
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {
            'description': 'An open-ended object for any additional metadata.',
            'type': 'object',
          },
          'bug_id': {
            'description': 'The unique identifier for the bug.',
            'type': 'string',
          },
          'files': {
            'description': 'An array of files to include in the context.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'description':
                      "The name of the LLM. This should be a human-readable identifier for the agent responding, for example, 'Vibe Agent'. Its purpose is to clearly attribute the source of the response.",
                  'type': 'string',
                },
                'filepath': {
                  'description': 'The path to the file on the server.',
                  'type': 'string',
                },
                'file_contents': {
                  'description': 'The contents of the file',
                  'type': 'string',
                },
              },
              'required': [
                'name',
                'filepath',
                'file_contents',
              ],
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
          'history': {
            'description': 'A list of color updates.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'agent': {
                  'description': "The user's message.",
                  'type': 'string',
                },
                'user': {
                  'description': "The agent's message",
                  'type': 'string',
                },
              },
              'required': [
                'agent',
                'user',
              ],
            },
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
          'bug_id',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Solver LLM Output',
        'description': 'Schema for output to the Solver LLM for general chitchat and Q&A.',
        'long_description':
            'The Solver LLM is the most complex.  It takes in files, selected code/text, and a unique bug_id.  The bug_id will be needed to track harder bugs that require multiple sessions to resolve.  Bugs will be added to a database.  It will return optional edits, like the Builder.  More significantly it will return a list of hypotheses and attempts which it will use to reason, problem solve, and most importantly prevent backtracking.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
          'edits': {
            'description':
                'A list of objects detailing edits made to files. This array contains machine-readable instructions for applying changes to the codebase, allowing for automated file modifications.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'file_path': {
                  'type': 'string',
                  'description':
                      'The full, absolute path to the file where the replacement occurred. This must be an exact path to ensure the correct file is targeted for modification.',
                },
                'old_string': {
                  'type': 'string',
                  'description':
                      'The exact, literal string that was replaced. To ensure a successful patch, this must match the target text precisely, including all whitespace, indentation, and newlines.',
                },
                'new_string': {
                  'type': 'string',
                  'description':
                      'The exact, literal string that replaced the old string. This is the new content that will be written into the file.',
                },
                'justification': {
                  'type': 'string',
                  'description':
                      "A developer-facing explanation of the decision. This field should clarify why the change was made, linking it back to the original user request or the agent's reasoning process.",
                },
              },
              'required': [
                'file_path',
                'old_string',
                'new_string',
              ],
            },
          },
          'hypotheses': {
            'description': "A list of hypotheses for the bug's cause that have failed.",
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'description': {
                  'type': 'string',
                  'description': 'The description of the attempt.',
                },
                'success': {
                  'type': [
                    'boolean',
                    'null',
                  ],
                  'description': 'If it was shown true or false.  If it is null, it has not been verified either way.',
                },
              },
              'required': [
                'description',
                'success',
              ],
            },
          },
          'attempts': {
            'description': 'A list of attempts to fix the bug that have failed.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'attempt_id': {
                  'type': 'string',
                  'description': 'Unique identifier for the attempt',
                },
                'edits': {
                  'description':
                      'A list of objects detailing edits made to files. This array contains machine-readable instructions for applying changes to the codebase, allowing for automated file modifications.',
                  'type': 'array',
                  'items': {
                    'type': 'object',
                    'properties': {
                      'edit_id': {
                        'type': 'string',
                        'description':
                            'A unique identifier for the edit, used for tracking and logging purposes. This can be a timestamp, a hash, or any other unique string.',
                      },
                    },
                    'required': [
                      'edit_id',
                    ],
                  },
                },
                'description': {
                  'type': 'string',
                  'description': 'The description of the attempt.',
                },
              },
              'required': [
                'description',
              ],
            },
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the solver-IN.json schema #} {# into a comprehensive prompt for the Solver LLM. The Solver LLM is designed for complex bug resolution. #} {# This prompt provides all necessary context for the LLM to diagnose, hypothesize, and propose solutions. #} {# It emphasizes tracking the bug via a bug_id and systematically listing all relevant information. #} {# Transient metadata like user_id and session_id are omitted to keep the prompt focused. #} You are an expert Jinja developer. {{ name }} Agent Role: Debugging Specialist Purpose: You are a highly advanced problem-solver. Your job is to diagnose and fix complex programming problems. You will be provided with extensive information, including debug logs, error messages, and relevant source code. You must analyze this data to pinpoint the root cause of the problem and provide a comprehensive solution and explanation. Move slowly and methodically and create alternative hypotheses at each step, testing and disproving them carefully to diagnose the problem. Your task is to analyze the following bug report, generate hypotheses, and propose solutions. You must track your reasoning and attempts to avoid backtracking. The user will be able to individually reject or accept each of your edits so do not be timid, as long as they are small and digestible.  {# Display conversation history if available #} {% if history %} **Conversation History:** {% for message in history %} You: {{- message.content.agent }} Me: {{- message.content.user }} {% endif %} {% endfor %} --- {% endif %}  Bug ID: {{ bug_id }} Timestamp: {{ timestamp }}  --- **User's Description of the Problem:** {{ query }} ---  {% if error_messages %} **Observed Error Messages:** {% for error in error_messages %} - Source: {{ error.source }}   Message: {{ error.text }} {% endfor %} --- {% endif %}  {% if selected %} **User-Selected Context:** The user has highlighted the following code or text: --- {{ selected }} --- {% endif %}  {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  Based on the information provided, please return: 1.  A list of hypotheses about the root cause of the bug. 2.  A list of attempts or experiments to test these hypotheses. 3.  (Optional) A list of proposed code edits to fix the bug.",
      'agent_id': 'solver',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '12',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Spec LLM Input',
        'description': 'Schema for input to the Spec LLM for general chitchat and Q&A.',
        'long_description':
            'The Spec LLM is used for longer term task planning.  It is aimed at creating a long term step by step plan for a larger task.  It outputs an array of task descriptions.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {
            'description': 'An open-ended object for any additional metadata.',
            'type': 'object',
          },
          'files': {
            'description': 'An array of files to include in the context.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'description':
                      "The name of the LLM. This should be a human-readable identifier for the agent responding, for example, 'Vibe Agent'. Its purpose is to clearly attribute the source of the response.",
                  'type': 'string',
                },
                'filepath': {
                  'description': 'The path to the file on the server.',
                  'type': 'string',
                },
                'file_contents': {
                  'description': 'The contents of the file',
                  'type': 'string',
                },
              },
              'required': [
                'name',
                'filepath',
                'file_contents',
              ],
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
          'history': {
            'description': 'A list of color updates.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'agent': {
                  'description': "The user's message.",
                  'type': 'string',
                },
                'user': {
                  'description': "The agent's message",
                  'type': 'string',
                },
              },
              'required': [
                'agent',
                'user',
              ],
            },
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Spec LLM Output',
        'description': 'Schema for output to the Spec LLM for general chitchat and Q&A.',
        'long_description':
            'The Spec LLM is used for longer term task planning.  It is aimed at creating a long term step by step plan for a larger task.  It outputs an array of task descriptions.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
          'tasklist': {
            'description': 'An ordered list of planned tasks.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'title': {
                  'description': 'The title of the task',
                  'type': 'string',
                },
                'description': {
                  'description': 'The description of the attempt.',
                  'type': 'string',
                },
                'is_complete': {
                  'description': 'Has the task been completed',
                  'type': 'boolean',
                },
              },
              'required': [
                'title',
                'description',
                'is_complete',
              ],
            },
          },
        },
        'required': [
          'name',
          'response',
          'tasklist',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the spec-IN.json schema #} {# into a prompt for the Spec LLM, which is designed for long-term task planning. #} {# The goal is to provide all necessary context for the LLM to generate a step-by-step plan. #} {# It omits irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Task Planner Purpose: Your job is to create a detailed, multi-step task specification. You will take a high-level request and break it down into a clear, logical plan. Your output should outline the sequence of sub-tasks, and the required inputs and expected outputs for each step of the process. The output should be an array of task descriptions.  {# Display conversation history if available #} {% if history %} **Conversation History:** {% for message in history %} You: {{- message.content.agent }} Me: {{- message.content.user }} {% endif %} {% endfor %} --- {% endif %}  User's request: --- {{ query }} ---  {% if selected %} The user has provided the following selected text for additional context: --- {{ selected }} --- {% endif %}  {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# The timestamp provides context for when the planning request was made. #} Timestamp: {{ timestamp }}",
      'agent_id': 'spec',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '13',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Vibe LLM Output',
        'description': 'Schema for output to the Vibe LLM for quick vibe coding',
        'long_description':
            'The Vibe LLM is used for rapid development and vibe coding.  It will take in a user request, and respond with an array of proposed changes and explanations for each.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                "The name of the LLM. This should be a human-readable identifier for the agent responding, for example, 'Vibe Agent'. Its purpose is to clearly attribute the source of the response.",
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
          'edits': {
            'description':
                'A list of objects detailing edits made to files. This array contains machine-readable instructions for applying changes to the codebase, allowing for automated file modifications.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'edit_id': {
                  'type': 'string',
                  'description':
                      'A unique identifier for the edit, used for tracking and logging purposes. This can be a timestamp, a hash, or any other unique string.',
                },
                'file_path': {
                  'type': 'string',
                  'description':
                      'The full, absolute path to the file where the replacement occurred. This must be an exact path to ensure the correct file is targeted for modification.',
                },
                'old_string': {
                  'type': 'string',
                  'description':
                      'The exact, literal string that was replaced. To ensure a successful patch, this must match the target text precisely, including all whitespace, indentation, and newlines.',
                },
                'new_string': {
                  'type': 'string',
                  'description':
                      'The exact, literal string that replaced the old string. This is the new content that will be written into the file.',
                },
                'justification': {
                  'type': 'string',
                  'description':
                      "A developer-facing explanation of the decision. This field should clarify why the change was made, linking it back to the original user request or the agent's reasoning process.",
                },
              },
              'required': [
                'file_path',
                'old_string',
                'new_string',
              ],
            },
          },
        },
        'required': [
          'name',
          'response',
          'edits',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-04/schema#',
        'type': 'object',
        'required': [
          'name',
          'response',
          'edits',
        ],
        'properties': {
          'name': {
            'type': 'string',
          },
          'response': {
            'type': 'string',
          },
          'metadata': {
            'type': 'object',
          },
          'edits': {
            'type': 'array',
            'items': [
              {
                'type': 'object',
                'required': [
                  'file_path',
                  'old_string',
                  'new_string',
                ],
                'properties': {
                  'file_path': {
                    'type': 'string',
                  },
                  'old_string': {
                    'type': 'string',
                  },
                  'new_string': {
                    'type': 'string',
                  },
                },
              }
            ],
          },
        },
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the vibe-IN.json schema #} {# into a detailed prompt for the Vibe LLM, which is used for rapid coding tasks. #} {# It focuses on the user's query, task context, selected code, and relevant files, #} {# while omitting metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Incremental Developer Purpose: You are responsible for building up the user's application. You must move slowly and deliberately, making only small changes based on the user's requests. You will not make aggressive or major modifications. If you need clarification on a request, you should always ask the user for more information before proceeding.  Only ask for clarification, do not ask for permission. The user will be able to individually reject or accept each of your edits so do not be timid, as long as they are small and digestible.  {# Display conversation history if available #} {% if history %} **Conversation History:** {% for message in history %} You: {{- message.content.agent }} Me: {{- message.content.user }} {% endif %} {% endfor %} --- {% endif %}  {# The main query or instruction from the user. #} {{ query }}  {# The specific task ID provided by the Architect, giving context to the request. #} {% if task_id %} Task ID: {{ task_id }} {% endif %}  {# Any code or text the user has selected in their editor. #} {% if selected %} The user has the following text selected: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Timestamp for temporal context. #} Timestamp: {{ timestamp }}",
      'agent_id': 'vibe',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    }
  ],
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
      enableJinjaDebugLogging: true,
      valueListenableJinjaError: (error) {
        print('Jinja Error: $error');
        errors.add(error);
      },
      callbackToParentProject: ({required payload}) async {
        await Future<void>.delayed(const Duration(seconds: 2));
        return {'mock_data': 'test_data'};
      },
    );
    // example 2: real world example
    print('\n=== Example 2: Real world example ===');
    var template2 = env.fromString(jinjaScript);
    var debugController = DebugController()..enabled = true;

    // Add breakpoints at key lines in the template
    debugController.addBreakpoint(line: 2); // Where left_side_code is set
    debugController.addBreakpoint(line: 49); // Where header_jinja_data is set
    debugController.addBreakpoint(line: 50); // Where macro_header is called

    // Set up breakpoint handler
    var breakpointCount = 0;
    debugController.onBreakpoint = (info) async {
      breakpointCount++;
      print('\n${"=" * 80}');
      print('🔴 BREAKPOINT #$breakpointCount HIT!');
      print('=' * 80);
      print('📍 Line Number: ${info.lineNumber}');
      print('📦 Node Type: ${info.nodeType}');
      if (info.nodeName != null) {
        print('🏷️  Node Name: ${info.nodeName}');
      }

      print('\n📊 Variables in scope:');
      var varCount = 0;
      info.variables.forEach((key, value) {
        varCount++;
        var valueStr = value.toString();
        if (valueStr.length > 100) {
          valueStr = '${valueStr.substring(0, 100)}... (truncated)';
        }
        print('  $varCount. $key = $valueStr');
      });

      print('\n📝 Output so far (first 500 chars):');
      print('─' * 80);
      var outputPreview = info.outputSoFar.length > 500
          ? '${info.outputSoFar.substring(0, 500)}... (truncated, total: ${info.outputSoFar.length} chars)'
          : info.outputSoFar;
      print(outputPreview);
      print('─' * 80);
      print('Continuing execution...\n');
    };

    print('Breakpoints set at lines: 2, 49, 50');
    print('Starting debug render...\n');

    // Debug: Print template source with line numbers to verify breakpoint lines
    var templateLines = jinjaScript.split('\n');
    print('Template preview (first 55 lines):');
    for (var i = 0; i < templateLines.length && i < 55; i++) {
      var marker = (i + 1 == 2 || i + 1 == 49 || i + 1 == 50) ? ' <-- BREAKPOINT' : '';
      print('${(i + 1).toString().padLeft(3)}: ${templateLines[i]}$marker');
    }
    print('');

    var result2 = await template2.renderDebug(jinjaData, debugController: debugController);

    print('\n${"=" * 80}');
    print('✅ Debug render complete!');
    print('Total breakpoints hit: $breakpointCount');
    if (debugController.history.isNotEmpty) {
      print('\nBreakpoint history:');
      for (var i = 0; i < debugController.history.length; i++) {
        var bp = debugController.history[i];
        print('  ${i + 1}. Line ${bp.lineNumber}: ${bp.nodeType}');
      }
    }
    print('=' * 80);
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
