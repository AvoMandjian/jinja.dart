import 'dart:async';

import 'package:jinja/jinja.dart';

import 'get_jinja.dart';

void main() async {
  final errors = <String?>[];
  final env = GetJinja.environment(
    MockBuildContext(),
    MapLoader({}),
    valueListenableJinjaError: (error) {
      print('Jinja Error: $error');
      errors.add(error);
    },
  );

  // Example 1: Simple async global
  print('=== Example 1: Simple async global ===');
  var template1 = env.fromString(
    """{# Build the tree structure and then group the root items. #} {% set tree = jframe_menu_data | buildTree %} {% set root_groups = tree | groupby('group_id') %} { "widget_type":"jform", "widget_id": "jinja_carousel_slider_jform", "workflows": { "navigate_to_tab":{ "workflow_actions": [ { "set_page": { {% raw %} "page_id": "{{ page_id }}", {% endraw %} {% raw %} "clear_data": "{% if clear_data is defined %} {{ clear_data }} {% else %} false {% endif %}", {% endraw %} "column_id": "column_2", "properties": { "header_visible": 1, "footer_visible": 1, {% raw %} "cell_value": "{{ page_id }}", {% endraw %} "table_name": "ide_widgets", "column_name": "widget_id", {% raw %} "widget_id": "{{ page_id }}_jform" {% endraw %} } } } ] }, "navigate_to_agents_list":{ "workflow_actions": [ { "set_page": { "page_id": "agents_list", "column_id": "column_2", "properties": { "header_visible": 0, "cell_value": "agents_list", "table_name": "ide_widgets", "column_name": "widget_id", "widget_id": "agents_list_jform" } } } ] }, "navigate_to_agent_jform":{ "workflow_actions": [ { "set_page": { "page_id": "agent_jform", "column_id": "column_2", "properties": { "header_visible": 0, "cell_value": "agent_jform", "table_name": "ide_widgets", "column_name": "widget_id", "widget_id": "agent_jform_widget" } } } ] }, "navigate_to_designer_page":{ "workflow_actions": [ { "set_page": { "page_id": "designer_page", "column_id": "column_2", "properties": { "header_visible": 0, "cell_value": "designer_page", "table_name": "ide_widgets", "column_name": "widget_id", "widget_id": "designer_page_jform" } } } ] }, "open_add_new_slideover":{ "workflow_actions": [ { "get_data_from_db":{ "properties": { "cell_value": "scripts_list_add_new_slideover", "table_name": "ide_widgets", "column_name": "widget_id", "open_slideover": true } } } ] }, "save_script_workflow":{ "workflow_actions": [ { "get_data_from_db":{ "properties": { "cell_value": "save_script_workflow", "table_name": "data_sources", "column_name": "data_source_id" } } } ] }, "navigate_to_scripts_list":{ "workflow_actions": [ { "set_page": { "page_id": "scripts_list", "column_id": "column_2", "properties": { "header_visible": 0, "cell_value": "scripts_list", "table_name": "ide_widgets", "column_name": "widget_id", "widget_id": "jinja_carousel_scripts_listslider", "clear_data": true } } } ] }, "navigate_to_carousel_slider": { "workflow_actions": [ { "set_page": { "page_id": "home_page", "column_id": "column_2", "properties": { "header_visible": 0 } } } ] }, "navigate_to_jinja_code_editor":{ "workflow_actions": [ { "set_page": { "page_id": "code_editor", "column_id": "column_2", "properties": { {% raw %} "jinja_script_id": "{{ jinja_script_id }}", {% endraw %} "cell_value": "code_editor", "table_name": "ide_widgets", "column_name": "widget_id", "widget_id": "code_editor", "clear_data": true } } }, { "set_header": { "page_id": "code_editor_header", "column_id": "header_column", "properties": { "cell_value": "code_editor_header", "table_name": "ide_widgets", "column_name": "widget_id", "widget_id": "code_editor_header" } } }, { "set_footer": { "page_id": "code_editor_footer", "column_id": "footer_column", "properties": { "cell_value": "code_editor_footer", "table_name": "ide_widgets", "column_name": "widget_id", "widget_id": "code_editor_footer" } } } ] } }, "events": {}, "layout": { "layout_type_id": "data", "header": { "page_id": "header_page", "visible": 0 }, "footer": { "visible": 0 }, "body": { "default_container_id": "home_container", "containers": { "home_container": { "rows": [ { "row_id": "", "columns": [ { "column_id": "column_1", "page_id": "menu_page", "properties": { "width": 80 } }, { "column_id": "column_2", "page_id": "home_page", "properties": { "flex": 3, "padding": { "left": 65 } } } ] } ] } } } }, "pages": { "header_page": { "rows": [ { "row_id": "header_row", "columns": [ { "column_id": "header_column", "widgets": [ { "style": { "add_button": false }, "title": "Value Lists", "widget_id": "form_header", "menu_option": { "title": "Options", "widgets": [], "widget_id": "options_menu", "widget_type": "options_menu" }, "widget_type": "list_header", "navigation_title": "Value Lists" } ] } ] } ] }, "menu_page": { "page_id": "menu_page", "rows": [ { "row_id": "", "columns": [ { "column_id": "1", "widgets": [ { "groups": [ {% for group in root_groups %} [ {% for item in group.list %} {{ item | tojson }} {% if not loop.last %},{% endif %} {% endfor %} ] {% if not loop.last %},{% endif %} {% endfor %} ], "logo_url": "", "user_name": "Name Surname", "widget_id": "uuid", "recordset_action": "read_all_data", "widget_type": "menu", "user_image_url": "", "drawer_open_icon": { "unicode": "0xf0c9", "font_family": "FontAwesomeSolid", "font_package": "font_awesome_flutter", "icon_color": "dark" }, "menu_title_color": "darkest", "drawer_close_icon": { "unicode": "0xf00d", "font_family": "FontAwesomeSolid", "font_package": "font_awesome_flutter", "icon_color": "primary" }, "bg_color_primary": "white", "bg_color_secondary": "white", "submenu_title_color": "white", "selected_index": 0, "only_icon": false, "search_field_tooltip": "Search", "sub_menu_selected_item_color": "primary", "sub_menu_selected_item_background_color": "error", "drawer_background_color": "white", "unselected_item_color": "primary", "selected_item_color": "background", "show_search": false, "workflows": { "on_click_container_2": { "jinja_script_id": "", "workflow_actions": [ { "set_page": { "page_id": "page_id_63", "column_id": "column_2" } } ] } } } ] } ] } ] }, "home_page": { "page_id": "home_page", "rows": [ { "row_id": "", "columns": [ { "column_id": "1", "widgets": [ { "workflows": { "on_click_container_3": { "jinja_script_id": "", "workflow_actions": [ { "set_page": { "page_id": "page_id_30", "column_id": "column_3" } } ] } }, "widget_id": "jinja_carousel_slider", "widget_type": "carousel_slider", "cross_axis_count": 2, "main_axis_count": 1, "grid_content": true, "title": "Title 1", "title_padding": { "left": 10, "bottom": 10 }, "data": [ { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "Cjxib2R5IHN0eWxlPSd3aWR0aDoxMDAlOyBtYXJnaW46IDA7IHBhZGRpbmc6IDAnPgogICAgPGRpdiB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyA+Cjxpbmt3ZWxsPiAgICAKICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiA8dGQgY3VzdG9tLXdpZHRoPScxMDAlJyB2YWxpZ249J3RvcCc+CjxkaXYgc3R5bGU9JyBtYXJnaW4tYm90dG9tOiA1cHg7IGZvbnQtd2VpZ2h0OiA2MDAnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGNvbG9yPSdwcmltYXJ5JyBzaXplPSdzbWFsbCc+R0VUIFNUQVJURUQ8L2Rpdj4gIAo8ZGl2IHN0eWxlPSdmb250LXNpemU6IDIwcHg7IGZvbnQtd2VpZ2h0OiBib2xkOyBtYXJnaW4tYm90dG9tOiA1cHgnICB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgPkNvZGUgZmFzdGVyIHdpdGggWGNvZGUgZXh0ZW5zaW9uczwvZGl2PiAKPGRpdiBzdHlsZT0nZm9udC1zaXplOiAxOHB4OyBtYXJnaW4tYm90dG9tOiA1cHgnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGNvbG9yPSdsaWdodCc+RW5oYW5jZSB5b3VyIGNvZGluZyBjYXBhYmlsaXRpZXMuPC9kaXY+IAogICAgPC90ZD4gICAgICAgCiAgICA8L3RyPgo8dHI+CiA8dGQgPgogICAgIDxjdXN0b20taW1hZ2Ugc3JjPSdodHRwczovL21pcm8ubWVkaXVtLmNvbS92Mi9yZXNpemU6Zml0OjE0MDAvMSp2TUhSaUFZR2h3QnItQWJmM0hUaGZRLmpwZWcnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGJvcmRlci1yYWRpdXM9JzEwJy8+CiAgICA8L3RkPgo8L3RyPiAgICAKICAgIDwvdGFibGU+CiAgICA8L2Rpdj4KPGlua3dlbGw+ICAgCjwvYm9keT4=", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false }, { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "Cjxib2R5IHN0eWxlPSd3aWR0aDoxMDAlOyBtYXJnaW46IDA7IHBhZGRpbmc6IDAnPgogICAgPGRpdiB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyA+Cjxpbmt3ZWxsPiAgICAKICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiA8dGQgY3VzdG9tLXdpZHRoPScxMDAlJyB2YWxpZ249J3RvcCc+CjxkaXYgc3R5bGU9JyBtYXJnaW4tYm90dG9tOiA1cHg7IGZvbnQtd2VpZ2h0OiA2MDAnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGNvbG9yPSdwcmltYXJ5JyBzaXplPSdzbWFsbCc+R0VUIFNUQVJURUQ8L2Rpdj4gIAo8ZGl2IHN0eWxlPSdmb250LXNpemU6IDIwcHg7IGZvbnQtd2VpZ2h0OiBib2xkOyBtYXJnaW4tYm90dG9tOiA1cHgnICB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgPkNvZGUgZmFzdGVyIHdpdGggWGNvZGUgZXh0ZW5zaW9uczwvZGl2PiAKPGRpdiBzdHlsZT0nZm9udC1zaXplOiAxOHB4OyBtYXJnaW4tYm90dG9tOiA1cHgnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGNvbG9yPSdsaWdodCc+RW5oYW5jZSB5b3VyIGNvZGluZyBjYXBhYmlsaXRpZXMuPC9kaXY+IAogICAgPC90ZD4gICAgICAgCiAgICA8L3RyPgo8dHI+CiA8dGQgPgogICAgIDxjdXN0b20taW1hZ2Ugc3JjPSdodHRwczovL21pcm8ubWVkaXVtLmNvbS92Mi9yZXNpemU6Zml0OjE0MDAvMSp2TUhSaUFZR2h3QnItQWJmM0hUaGZRLmpwZWcnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGJvcmRlci1yYWRpdXM9JzEwJy8+CiAgICA8L3RkPgo8L3RyPiAgICAKICAgIDwvdGFibGU+CiAgICA8L2Rpdj4KPGlua3dlbGw+ICAgCjwvYm9keT4=", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false }, { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "Cjxib2R5IHN0eWxlPSd3aWR0aDoxMDAlOyBtYXJnaW46IDA7IHBhZGRpbmc6IDAnPgogICAgPGRpdiB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyA+Cjxpbmt3ZWxsPiAgICAKICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiA8dGQgY3VzdG9tLXdpZHRoPScxMDAlJyB2YWxpZ249J3RvcCc+CjxkaXYgc3R5bGU9JyBtYXJnaW4tYm90dG9tOiA1cHg7IGZvbnQtd2VpZ2h0OiA2MDAnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGNvbG9yPSdwcmltYXJ5JyBzaXplPSdzbWFsbCc+R0VUIFNUQVJURUQ8L2Rpdj4gIAo8ZGl2IHN0eWxlPSdmb250LXNpemU6IDIwcHg7IGZvbnQtd2VpZ2h0OiBib2xkOyBtYXJnaW4tYm90dG9tOiA1cHgnICB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgPkNvZGUgZmFzdGVyIHdpdGggWGNvZGUgZXh0ZW5zaW9uczwvZGl2PiAKPGRpdiBzdHlsZT0nZm9udC1zaXplOiAxOHB4OyBtYXJnaW4tYm90dG9tOiA1cHgnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGNvbG9yPSdsaWdodCc+RW5oYW5jZSB5b3VyIGNvZGluZyBjYXBhYmlsaXRpZXMuPC9kaXY+IAogICAgPC90ZD4gICAgICAgCiAgICA8L3RyPgo8dHI+CiA8dGQgPgogICAgIDxjdXN0b20taW1hZ2Ugc3JjPSdodHRwczovL21pcm8ubWVkaXVtLmNvbS92Mi9yZXNpemU6Zml0OjE0MDAvMSp2TUhSaUFZR2h3QnItQWJmM0hUaGZRLmpwZWcnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGJvcmRlci1yYWRpdXM9JzEwJy8+CiAgICA8L3RkPgo8L3RyPiAgICAKICAgIDwvdGFibGU+CiAgICA8L2Rpdj4KPGlua3dlbGw+ICAgCjwvYm9keT4=", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false }, { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "Cjxib2R5IHN0eWxlPSd3aWR0aDoxMDAlOyBtYXJnaW46IDA7IHBhZGRpbmc6IDAnPgogICAgPGRpdiB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyA+Cjxpbmt3ZWxsPiAgICAKICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiA8dGQgY3VzdG9tLXdpZHRoPScxMDAlJyB2YWxpZ249J3RvcCc+CjxkaXYgc3R5bGU9JyBtYXJnaW4tYm90dG9tOiA1cHg7IGZvbnQtd2VpZ2h0OiA2MDAnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGNvbG9yPSdwcmltYXJ5JyBzaXplPSdzbWFsbCc+R0VUIFNUQVJURUQ8L2Rpdj4gIAo8ZGl2IHN0eWxlPSdmb250LXNpemU6IDIwcHg7IGZvbnQtd2VpZ2h0OiBib2xkOyBtYXJnaW4tYm90dG9tOiA1cHgnICB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgPkNvZGUgZmFzdGVyIHdpdGggWGNvZGUgZXh0ZW5zaW9uczwvZGl2PiAKPGRpdiBzdHlsZT0nZm9udC1zaXplOiAxOHB4OyBtYXJnaW4tYm90dG9tOiA1cHgnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGNvbG9yPSdsaWdodCc+RW5oYW5jZSB5b3VyIGNvZGluZyBjYXBhYmlsaXRpZXMuPC9kaXY+IAogICAgPC90ZD4gICAgICAgCiAgICA8L3RyPgo8dHI+CiA8dGQgPgogICAgIDxjdXN0b20taW1hZ2Ugc3JjPSdodHRwczovL21pcm8ubWVkaXVtLmNvbS92Mi9yZXNpemU6Zml0OjE0MDAvMSp2TUhSaUFZR2h3QnItQWJmM0hUaGZRLmpwZWcnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGJvcmRlci1yYWRpdXM9JzEwJy8+CiAgICA8L3RkPgo8L3RyPiAgICAKICAgIDwvdGFibGU+CiAgICA8L2Rpdj4KPGlua3dlbGw+ICAgCjwvYm9keT4=", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false } ] }, { "workflows": { "on_click_container_3": { "jinja_script_id": "", "workflow_actions": [ { "set_page": { "page_id": "page_id_30", "column_id": "column_3" } } ] } }, "widget_id": "jinja_carousel_slider", "widget_type": "carousel_slider", "cross_axis_count": 3, "main_axis_count": 3, "options": { "height": 500, "aspect_ratio": 0.1 }, "grid_content": true, "title_padding": { "left": 10, "top": 20, "bottom": 20 }, "arrow_right_icon_padding": { "left": 100 }, "title": "Title 2", "data": [ { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "PGJvZHkgc3R5bGU9J3dpZHRoOjEwMCU7IG1hcmdpbjogMDsgcGFkZGluZzogMCc+CiAgICA8ZGl2IHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnID4KICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiAgICA8dGQgY3VzdG9tLXdpZHRoPScyMCUnID4KICAgICA8Y3VzdG9tLWltYWdlIHNyYz0nYXNzZXRzL2ltYWdlcy93aWRnZXRzL0J1dHRvbi5wbmcnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIHdpZHRoPSc4MCcgaGVpZ2h0PSc4MCcgYm9yZGVyLXJhZGl1cz0nODAnIHVzZV9sb2NhbF9pbWFnZT0nMScgLz4KICAgIDwvdGQ+CiA8dGQgY3VzdG9tLXdpZHRoPSc1MCUnIHZhbGlnbj0ndG9wJz4KPGRpdiBzdHlsZT0nZm9udC1zaXplOiAyMnB4OyBmb250LXdlaWdodDogYm9sZCcgIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnICA+QnV0dG9uPC9kaXY+IAo8ZGl2IHN0eWxlPSdjb2xvcjogIzYxNjE2MScgdXNlX2N1c3RvbV9kcF9zdHlsZT0ndHJ1ZScgZm9udD0ndGl0bGVfMic+RGVzY3JpcHRpb248L2Rpdj4gCgogICAgPC90ZD4gICAgCiAgICAgPHRkIGN1c3RvbS13aWR0aD0nMzAlJyBhbGlnbj0nZW5kJyA+CiAgICAgICAgICAgICAgICAgICAgPGlua3dlbGw+CiAgICAgICAgICAgICAgICAgICAgICAgIDxkaXYgdXNlX2N1c3RvbV9kcF9zdHlsZT0ndHJ1ZScgIGJhY2tncm91bmRfY29sb3I9J2xpZ2h0ZXInIGNvbG9yPSdwcmltYXJ5JyBzdHlsZT0nd2lkdGg6IDc1JTsgdGV4dC1hbGlnbjogY2VudGVyOyBwYWRkaW5nOiA1cHg7ICBib3JkZXItcmFkaXVzOiA1MHB4OyBmb250LXdlaWdodDogYm9sZDsgZm9udC1zaXplOiAxOHB4Jz5HZXQ8L2Rpdj4KICAgICAgICAgICAgICAgICAgICA8L2lua3dlbGw+ICAgICAKICAgICAgICAgICAgICA8ZGl2ICBzdHlsZT0nY29sb3I6ICM2MTYxNjE7IGZvbnQtc2l6ZTogMTVweDsgbWFyZ2luLXRvcDogNXB4Jz4KSW4tQXBwIFB1cmNoYXNlcyAgICAgICAgICAgICAgCjwvZGl2PiAgICAgICAgICAgICAgICAgICAgCiAgICA8L3RkPgogICAgPC90cj4KICAgIDwvdGFibGU+CiAgICA8L2Rpdj4KPC9ib2R5Pg==", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false }, { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "PGJvZHkgc3R5bGU9J3dpZHRoOjEwMCU7IG1hcmdpbjogMDsgcGFkZGluZzogMCc+CiAgICA8ZGl2IHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnID4KICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiAgICA8dGQgY3VzdG9tLXdpZHRoPScyMCUnID4KICAgICA8Y3VzdG9tLWltYWdlIHNyYz0naHR0cHM6Ly9pbWFnZS53aW51ZGYuY29tL3YyL2ltYWdlMS9kMlZoZEdobGNpNWhZbk4wY21GamRITXVibWxqWlY5cFkyOXVYekUyT0RVM05UY3dNRGxmTURjMi9pY29uLnBuZz93PTE4NCZmYWtldXJsPTEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIHdpZHRoPSc4MCcgaGVpZ2h0PSc4MCcgYm9yZGVyLXJhZGl1cz0nODAnIC8+CiAgICA8L3RkPgogPHRkIGN1c3RvbS13aWR0aD0nNTAlJyB2YWxpZ249J3RvcCc+CjxkaXYgc3R5bGU9J2ZvbnQtc2l6ZTogMjJweDsgZm9udC13ZWlnaHQ6IGJvbGQnICB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgPk1lcmN1cnkgV2VhdGhlcjwvZGl2PiAKPGRpdiBzdHlsZT0nY29sb3I6ICM2MTYxNjEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGZvbnQ9J3RpdGxlXzInPkxvY2FsIEZvcmVjYXN0cyAmIExpdmUgV2lkZ2V0czwvZGl2PiAKCiAgICA8L3RkPiAgICAKICAgICA8dGQgY3VzdG9tLXdpZHRoPSczMCUnIGFsaWduPSdlbmQnID4KICAgICAgICAgICAgICAgICAgICA8aW5rd2VsbD4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgYmFja2dyb3VuZF9jb2xvcj0nbGlnaHRlcicgY29sb3I9J3ByaW1hcnknIHN0eWxlPSd3aWR0aDogNzUlOyB0ZXh0LWFsaWduOiBjZW50ZXI7IHBhZGRpbmc6IDVweDsgIGJvcmRlci1yYWRpdXM6IDUwcHg7IGZvbnQtd2VpZ2h0OiBib2xkOyBmb250LXNpemU6IDE4cHgnPkdldDwvZGl2PgogICAgICAgICAgICAgICAgICAgIDwvaW5rd2VsbD4gICAgIAogICAgICAgICAgICAgIDxkaXYgIHN0eWxlPSdjb2xvcjogIzYxNjE2MTsgZm9udC1zaXplOiAxNXB4OyBtYXJnaW4tdG9wOiA1cHgnPgpJbi1BcHAgUHVyY2hhc2VzICAgICAgICAgICAgICAKPC9kaXY+ICAgICAgICAgICAgICAgICAgICAKICAgIDwvdGQ+CiAgICA8L3RyPgogICAgPC90YWJsZT4KICAgIDwvZGl2Pgo8L2JvZHk+", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false }, { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "PGJvZHkgc3R5bGU9J3dpZHRoOjEwMCU7IG1hcmdpbjogMDsgcGFkZGluZzogMCc+CiAgICA8ZGl2IHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnID4KICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiAgICA8dGQgY3VzdG9tLXdpZHRoPScyMCUnID4KICAgICA8Y3VzdG9tLWltYWdlIHNyYz0naHR0cHM6Ly9pbWFnZS53aW51ZGYuY29tL3YyL2ltYWdlMS9kMlZoZEdobGNpNWhZbk4wY21GamRITXVibWxqWlY5cFkyOXVYekUyT0RVM05UY3dNRGxmTURjMi9pY29uLnBuZz93PTE4NCZmYWtldXJsPTEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIHdpZHRoPSc4MCcgaGVpZ2h0PSc4MCcgYm9yZGVyLXJhZGl1cz0nODAnIC8+CiAgICA8L3RkPgogPHRkIGN1c3RvbS13aWR0aD0nNTAlJyB2YWxpZ249J3RvcCc+CjxkaXYgc3R5bGU9J2ZvbnQtc2l6ZTogMjJweDsgZm9udC13ZWlnaHQ6IGJvbGQnICB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgPk1lcmN1cnkgV2VhdGhlcjwvZGl2PiAKPGRpdiBzdHlsZT0nY29sb3I6ICM2MTYxNjEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGZvbnQ9J3RpdGxlXzInPkxvY2FsIEZvcmVjYXN0cyAmIExpdmUgV2lkZ2V0czwvZGl2PiAKCiAgICA8L3RkPiAgICAKICAgICA8dGQgY3VzdG9tLXdpZHRoPSczMCUnIGFsaWduPSdlbmQnID4KICAgICAgICAgICAgICAgICAgICA8aW5rd2VsbD4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgYmFja2dyb3VuZF9jb2xvcj0nbGlnaHRlcicgY29sb3I9J3ByaW1hcnknIHN0eWxlPSd3aWR0aDogNzUlOyB0ZXh0LWFsaWduOiBjZW50ZXI7IHBhZGRpbmc6IDVweDsgIGJvcmRlci1yYWRpdXM6IDUwcHg7IGZvbnQtd2VpZ2h0OiBib2xkOyBmb250LXNpemU6IDE4cHgnPkdldDwvZGl2PgogICAgICAgICAgICAgICAgICAgIDwvaW5rd2VsbD4gICAgIAogICAgICAgICAgICAgIDxkaXYgIHN0eWxlPSdjb2xvcjogIzYxNjE2MTsgZm9udC1zaXplOiAxNXB4OyBtYXJnaW4tdG9wOiA1cHgnPgpJbi1BcHAgUHVyY2hhc2VzICAgICAgICAgICAgICAKPC9kaXY+ICAgICAgICAgICAgICAgICAgICAKICAgIDwvdGQ+CiAgICA8L3RyPgogICAgPC90YWJsZT4KICAgIDwvZGl2Pgo8L2JvZHk+", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false }, { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "PGJvZHkgc3R5bGU9J3dpZHRoOjEwMCU7IG1hcmdpbjogMDsgcGFkZGluZzogMCc+CiAgICA8ZGl2IHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnID4KICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiAgICA8dGQgY3VzdG9tLXdpZHRoPScyMCUnID4KICAgICA8Y3VzdG9tLWltYWdlIHNyYz0naHR0cHM6Ly9pbWFnZS53aW51ZGYuY29tL3YyL2ltYWdlMS9kMlZoZEdobGNpNWhZbk4wY21GamRITXVibWxqWlY5cFkyOXVYekUyT0RVM05UY3dNRGxmTURjMi9pY29uLnBuZz93PTE4NCZmYWtldXJsPTEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIHdpZHRoPSc4MCcgaGVpZ2h0PSc4MCcgYm9yZGVyLXJhZGl1cz0nODAnIC8+CiAgICA8L3RkPgogPHRkIGN1c3RvbS13aWR0aD0nNTAlJyB2YWxpZ249J3RvcCc+CjxkaXYgc3R5bGU9J2ZvbnQtc2l6ZTogMjJweDsgZm9udC13ZWlnaHQ6IGJvbGQnICB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgPk1lcmN1cnkgV2VhdGhlcjwvZGl2PiAKPGRpdiBzdHlsZT0nY29sb3I6ICM2MTYxNjEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGZvbnQ9J3RpdGxlXzInPkxvY2FsIEZvcmVjYXN0cyAmIExpdmUgV2lkZ2V0czwvZGl2PiAKCiAgICA8L3RkPiAgICAKICAgICA8dGQgY3VzdG9tLXdpZHRoPSczMCUnIGFsaWduPSdlbmQnID4KICAgICAgICAgICAgICAgICAgICA8aW5rd2VsbD4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgYmFja2dyb3VuZF9jb2xvcj0nbGlnaHRlcicgY29sb3I9J3ByaW1hcnknIHN0eWxlPSd3aWR0aDogNzUlOyB0ZXh0LWFsaWduOiBjZW50ZXI7IHBhZGRpbmc6IDVweDsgIGJvcmRlci1yYWRpdXM6IDUwcHg7IGZvbnQtd2VpZ2h0OiBib2xkOyBmb250LXNpemU6IDE4cHgnPkdldDwvZGl2PgogICAgICAgICAgICAgICAgICAgIDwvaW5rd2VsbD4gICAgIAogICAgICAgICAgICAgIDxkaXYgIHN0eWxlPSdjb2xvcjogIzYxNjE2MTsgZm9udC1zaXplOiAxNXB4OyBtYXJnaW4tdG9wOiA1cHgnPgpJbi1BcHAgUHVyY2hhc2VzICAgICAgICAgICAgICAKPC9kaXY+ICAgICAgICAgICAgICAgICAgICAKICAgIDwvdGQ+CiAgICA8L3RyPgogICAgPC90YWJsZT4KICAgIDwvZGl2Pgo8L2JvZHk+", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false }, { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "PGJvZHkgc3R5bGU9J3dpZHRoOjEwMCU7IG1hcmdpbjogMDsgcGFkZGluZzogMCc+CiAgICA8ZGl2IHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnID4KICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiAgICA8dGQgY3VzdG9tLXdpZHRoPScyMCUnID4KICAgICA8Y3VzdG9tLWltYWdlIHNyYz0naHR0cHM6Ly9pbWFnZS53aW51ZGYuY29tL3YyL2ltYWdlMS9kMlZoZEdobGNpNWhZbk4wY21GamRITXVibWxqWlY5cFkyOXVYekUyT0RVM05UY3dNRGxmTURjMi9pY29uLnBuZz93PTE4NCZmYWtldXJsPTEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIHdpZHRoPSc4MCcgaGVpZ2h0PSc4MCcgYm9yZGVyLXJhZGl1cz0nODAnIC8+CiAgICA8L3RkPgogPHRkIGN1c3RvbS13aWR0aD0nNTAlJyB2YWxpZ249J3RvcCc+CjxkaXYgc3R5bGU9J2ZvbnQtc2l6ZTogMjJweDsgZm9udC13ZWlnaHQ6IGJvbGQnICB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgPk1lcmN1cnkgV2VhdGhlcjwvZGl2PiAKPGRpdiBzdHlsZT0nY29sb3I6ICM2MTYxNjEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGZvbnQ9J3RpdGxlXzInPkxvY2FsIEZvcmVjYXN0cyAmIExpdmUgV2lkZ2V0czwvZGl2PiAKCiAgICA8L3RkPiAgICAKICAgICA8dGQgY3VzdG9tLXdpZHRoPSczMCUnIGFsaWduPSdlbmQnID4KICAgICAgICAgICAgICAgICAgICA8aW5rd2VsbD4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgYmFja2dyb3VuZF9jb2xvcj0nbGlnaHRlcicgY29sb3I9J3ByaW1hcnknIHN0eWxlPSd3aWR0aDogNzUlOyB0ZXh0LWFsaWduOiBjZW50ZXI7IHBhZGRpbmc6IDVweDsgIGJvcmRlci1yYWRpdXM6IDUwcHg7IGZvbnQtd2VpZ2h0OiBib2xkOyBmb250LXNpemU6IDE4cHgnPkdldDwvZGl2PgogICAgICAgICAgICAgICAgICAgIDwvaW5rd2VsbD4gICAgIAogICAgICAgICAgICAgIDxkaXYgIHN0eWxlPSdjb2xvcjogIzYxNjE2MTsgZm9udC1zaXplOiAxNXB4OyBtYXJnaW4tdG9wOiA1cHgnPgpJbi1BcHAgUHVyY2hhc2VzICAgICAgICAgICAgICAKPC9kaXY+ICAgICAgICAgICAgICAgICAgICAKICAgIDwvdGQ+CiAgICA8L3RyPgogICAgPC90YWJsZT4KICAgIDwvZGl2Pgo8L2JvZHk+", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false }, { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "PGJvZHkgc3R5bGU9J3dpZHRoOjEwMCU7IG1hcmdpbjogMDsgcGFkZGluZzogMCc+CiAgICA8ZGl2IHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnID4KICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiAgICA8dGQgY3VzdG9tLXdpZHRoPScyMCUnID4KICAgICA8Y3VzdG9tLWltYWdlIHNyYz0naHR0cHM6Ly9pbWFnZS53aW51ZGYuY29tL3YyL2ltYWdlMS9kMlZoZEdobGNpNWhZbk4wY21GamRITXVibWxqWlY5cFkyOXVYekUyT0RVM05UY3dNRGxmTURjMi9pY29uLnBuZz93PTE4NCZmYWtldXJsPTEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIHdpZHRoPSc4MCcgaGVpZ2h0PSc4MCcgYm9yZGVyLXJhZGl1cz0nODAnIC8+CiAgICA8L3RkPgogPHRkIGN1c3RvbS13aWR0aD0nNTAlJyB2YWxpZ249J3RvcCc+CjxkaXYgc3R5bGU9J2ZvbnQtc2l6ZTogMjJweDsgZm9udC13ZWlnaHQ6IGJvbGQnICB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgPk1lcmN1cnkgV2VhdGhlcjwvZGl2PiAKPGRpdiBzdHlsZT0nY29sb3I6ICM2MTYxNjEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGZvbnQ9J3RpdGxlXzInPkxvY2FsIEZvcmVjYXN0cyAmIExpdmUgV2lkZ2V0czwvZGl2PiAKCiAgICA8L3RkPiAgICAKICAgICA8dGQgY3VzdG9tLXdpZHRoPSczMCUnIGFsaWduPSdlbmQnID4KICAgICAgICAgICAgICAgICAgICA8aW5rd2VsbD4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgYmFja2dyb3VuZF9jb2xvcj0nbGlnaHRlcicgY29sb3I9J3ByaW1hcnknIHN0eWxlPSd3aWR0aDogNzUlOyB0ZXh0LWFsaWduOiBjZW50ZXI7IHBhZGRpbmc6IDVweDsgIGJvcmRlci1yYWRpdXM6IDUwcHg7IGZvbnQtd2VpZ2h0OiBib2xkOyBmb250LXNpemU6IDE4cHgnPkdldDwvZGl2PgogICAgICAgICAgICAgICAgICAgIDwvaW5rd2VsbD4gICAgIAogICAgICAgICAgICAgIDxkaXYgIHN0eWxlPSdjb2xvcjogIzYxNjE2MTsgZm9udC1zaXplOiAxNXB4OyBtYXJnaW4tdG9wOiA1cHgnPgpJbi1BcHAgUHVyY2hhc2VzICAgICAgICAgICAgICAKPC9kaXY+ICAgICAgICAgICAgICAgICAgICAKICAgIDwvdGQ+CiAgICA8L3RyPgogICAgPC90YWJsZT4KICAgIDwvZGl2Pgo8L2JvZHk+", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false }, { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "PGJvZHkgc3R5bGU9J3dpZHRoOjEwMCU7IG1hcmdpbjogMDsgcGFkZGluZzogMCc+CiAgICA8ZGl2IHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnID4KICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiAgICA8dGQgY3VzdG9tLXdpZHRoPScyMCUnID4KICAgICA8Y3VzdG9tLWltYWdlIHNyYz0naHR0cHM6Ly9pbWFnZS53aW51ZGYuY29tL3YyL2ltYWdlMS9kMlZoZEdobGNpNWhZbk4wY21GamRITXVibWxqWlY5cFkyOXVYekUyT0RVM05UY3dNRGxmTURjMi9pY29uLnBuZz93PTE4NCZmYWtldXJsPTEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIHdpZHRoPSc4MCcgaGVpZ2h0PSc4MCcgYm9yZGVyLXJhZGl1cz0nODAnIC8+CiAgICA8L3RkPgogPHRkIGN1c3RvbS13aWR0aD0nNTAlJyB2YWxpZ249J3RvcCc+CjxkaXYgc3R5bGU9J2ZvbnQtc2l6ZTogMjJweDsgZm9udC13ZWlnaHQ6IGJvbGQnICB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgPk1lcmN1cnkgV2VhdGhlcjwvZGl2PiAKPGRpdiBzdHlsZT0nY29sb3I6ICM2MTYxNjEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGZvbnQ9J3RpdGxlXzInPkxvY2FsIEZvcmVjYXN0cyAmIExpdmUgV2lkZ2V0czwvZGl2PiAKCiAgICA8L3RkPiAgICAKICAgICA8dGQgY3VzdG9tLXdpZHRoPSczMCUnIGFsaWduPSdlbmQnID4KICAgICAgICAgICAgICAgICAgICA8aW5rd2VsbD4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgYmFja2dyb3VuZF9jb2xvcj0nbGlnaHRlcicgY29sb3I9J3ByaW1hcnknIHN0eWxlPSd3aWR0aDogNzUlOyB0ZXh0LWFsaWduOiBjZW50ZXI7IHBhZGRpbmc6IDVweDsgIGJvcmRlci1yYWRpdXM6IDUwcHg7IGZvbnQtd2VpZ2h0OiBib2xkOyBmb250LXNpemU6IDE4cHgnPkdldDwvZGl2PgogICAgICAgICAgICAgICAgICAgIDwvaW5rd2VsbD4gICAgIAogICAgICAgICAgICAgIDxkaXYgIHN0eWxlPSdjb2xvcjogIzYxNjE2MTsgZm9udC1zaXplOiAxNXB4OyBtYXJnaW4tdG9wOiA1cHgnPgpJbi1BcHAgUHVyY2hhc2VzICAgICAgICAgICAgICAKPC9kaXY+ICAgICAgICAgICAgICAgICAgICAKICAgIDwvdGQ+CiAgICA8L3RyPgogICAgPC90YWJsZT4KICAgIDwvZGl2Pgo8L2JvZHk+", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false }, { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "PGJvZHkgc3R5bGU9J3dpZHRoOjEwMCU7IG1hcmdpbjogMDsgcGFkZGluZzogMCc+CiAgICA8ZGl2IHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnID4KICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiAgICA8dGQgY3VzdG9tLXdpZHRoPScyMCUnID4KICAgICA8Y3VzdG9tLWltYWdlIHNyYz0naHR0cHM6Ly9pbWFnZS53aW51ZGYuY29tL3YyL2ltYWdlMS9kMlZoZEdobGNpNWhZbk4wY21GamRITXVibWxqWlY5cFkyOXVYekUyT0RVM05UY3dNRGxmTURjMi9pY29uLnBuZz93PTE4NCZmYWtldXJsPTEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIHdpZHRoPSc4MCcgaGVpZ2h0PSc4MCcgYm9yZGVyLXJhZGl1cz0nODAnIC8+CiAgICA8L3RkPgogPHRkIGN1c3RvbS13aWR0aD0nNTAlJyB2YWxpZ249J3RvcCc+CjxkaXYgc3R5bGU9J2ZvbnQtc2l6ZTogMjJweDsgZm9udC13ZWlnaHQ6IGJvbGQnICB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgPk1lcmN1cnkgV2VhdGhlcjwvZGl2PiAKPGRpdiBzdHlsZT0nY29sb3I6ICM2MTYxNjEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGZvbnQ9J3RpdGxlXzInPkxvY2FsIEZvcmVjYXN0cyAmIExpdmUgV2lkZ2V0czwvZGl2PiAKCiAgICA8L3RkPiAgICAKICAgICA8dGQgY3VzdG9tLXdpZHRoPSczMCUnIGFsaWduPSdlbmQnID4KICAgICAgICAgICAgICAgICAgICA8aW5rd2VsbD4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgYmFja2dyb3VuZF9jb2xvcj0nbGlnaHRlcicgY29sb3I9J3ByaW1hcnknIHN0eWxlPSd3aWR0aDogNzUlOyB0ZXh0LWFsaWduOiBjZW50ZXI7IHBhZGRpbmc6IDVweDsgIGJvcmRlci1yYWRpdXM6IDUwcHg7IGZvbnQtd2VpZ2h0OiBib2xkOyBmb250LXNpemU6IDE4cHgnPkdldDwvZGl2PgogICAgICAgICAgICAgICAgICAgIDwvaW5rd2VsbD4gICAgIAogICAgICAgICAgICAgIDxkaXYgIHN0eWxlPSdjb2xvcjogIzYxNjE2MTsgZm9udC1zaXplOiAxNXB4OyBtYXJnaW4tdG9wOiA1cHgnPgpJbi1BcHAgUHVyY2hhc2VzICAgICAgICAgICAgICAKPC9kaXY+ICAgICAgICAgICAgICAgICAgICAKICAgIDwvdGQ+CiAgICA8L3RyPgogICAgPC90YWJsZT4KICAgIDwvZGl2Pgo8L2JvZHk+", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false }, { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "PGJvZHkgc3R5bGU9J3dpZHRoOjEwMCU7IG1hcmdpbjogMDsgcGFkZGluZzogMCc+CiAgICA8ZGl2IHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnID4KICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiAgICA8dGQgY3VzdG9tLXdpZHRoPScyMCUnID4KICAgICA8Y3VzdG9tLWltYWdlIHNyYz0naHR0cHM6Ly9pbWFnZS53aW51ZGYuY29tL3YyL2ltYWdlMS9kMlZoZEdobGNpNWhZbk4wY21GamRITXVibWxqWlY5cFkyOXVYekUyT0RVM05UY3dNRGxmTURjMi9pY29uLnBuZz93PTE4NCZmYWtldXJsPTEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIHdpZHRoPSc4MCcgaGVpZ2h0PSc4MCcgYm9yZGVyLXJhZGl1cz0nODAnIC8+CiAgICA8L3RkPgogPHRkIGN1c3RvbS13aWR0aD0nNTAlJyB2YWxpZ249J3RvcCc+CjxkaXYgc3R5bGU9J2ZvbnQtc2l6ZTogMjJweDsgZm9udC13ZWlnaHQ6IGJvbGQnICB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgPk1lcmN1cnkgV2VhdGhlcjwvZGl2PiAKPGRpdiBzdHlsZT0nY29sb3I6ICM2MTYxNjEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGZvbnQ9J3RpdGxlXzInPkxvY2FsIEZvcmVjYXN0cyAmIExpdmUgV2lkZ2V0czwvZGl2PiAKCiAgICA8L3RkPiAgICAKICAgICA8dGQgY3VzdG9tLXdpZHRoPSczMCUnIGFsaWduPSdlbmQnID4KICAgICAgICAgICAgICAgICAgICA8aW5rd2VsbD4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgYmFja2dyb3VuZF9jb2xvcj0nbGlnaHRlcicgY29sb3I9J3ByaW1hcnknIHN0eWxlPSd3aWR0aDogNzUlOyB0ZXh0LWFsaWduOiBjZW50ZXI7IHBhZGRpbmc6IDVweDsgIGJvcmRlci1yYWRpdXM6IDUwcHg7IGZvbnQtd2VpZ2h0OiBib2xkOyBmb250LXNpemU6IDE4cHgnPkdldDwvZGl2PgogICAgICAgICAgICAgICAgICAgIDwvaW5rd2VsbD4gICAgIAogICAgICAgICAgICAgIDxkaXYgIHN0eWxlPSdjb2xvcjogIzYxNjE2MTsgZm9udC1zaXplOiAxNXB4OyBtYXJnaW4tdG9wOiA1cHgnPgpJbi1BcHAgUHVyY2hhc2VzICAgICAgICAgICAgICAKPC9kaXY+ICAgICAgICAgICAgICAgICAgICAKICAgIDwvdGQ+CiAgICA8L3RyPgogICAgPC90YWJsZT4KICAgIDwvZGl2Pgo8L2JvZHk+", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false }, { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "PGJvZHkgc3R5bGU9J3dpZHRoOjEwMCU7IG1hcmdpbjogMDsgcGFkZGluZzogMCc+CiAgICA8ZGl2IHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnID4KICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiAgICA8dGQgY3VzdG9tLXdpZHRoPScyMCUnID4KICAgICA8Y3VzdG9tLWltYWdlIHNyYz0naHR0cHM6Ly9pbWFnZS53aW51ZGYuY29tL3YyL2ltYWdlMS9kMlZoZEdobGNpNWhZbk4wY21GamRITXVibWxqWlY5cFkyOXVYekUyT0RVM05UY3dNRGxmTURjMi9pY29uLnBuZz93PTE4NCZmYWtldXJsPTEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIHdpZHRoPSc4MCcgaGVpZ2h0PSc4MCcgYm9yZGVyLXJhZGl1cz0nODAnIC8+CiAgICA8L3RkPgogPHRkIGN1c3RvbS13aWR0aD0nNTAlJyB2YWxpZ249J3RvcCc+CjxkaXYgc3R5bGU9J2ZvbnQtc2l6ZTogMjJweDsgZm9udC13ZWlnaHQ6IGJvbGQnICB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgPk1lcmN1cnkgV2VhdGhlcjwvZGl2PiAKPGRpdiBzdHlsZT0nY29sb3I6ICM2MTYxNjEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGZvbnQ9J3RpdGxlXzInPkxvY2FsIEZvcmVjYXN0cyAmIExpdmUgV2lkZ2V0czwvZGl2PiAKCiAgICA8L3RkPiAgICAKICAgICA8dGQgY3VzdG9tLXdpZHRoPSczMCUnIGFsaWduPSdlbmQnID4KICAgICAgICAgICAgICAgICAgICA8aW5rd2VsbD4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgYmFja2dyb3VuZF9jb2xvcj0nbGlnaHRlcicgY29sb3I9J3ByaW1hcnknIHN0eWxlPSd3aWR0aDogNzUlOyB0ZXh0LWFsaWduOiBjZW50ZXI7IHBhZGRpbmc6IDVweDsgIGJvcmRlci1yYWRpdXM6IDUwcHg7IGZvbnQtd2VpZ2h0OiBib2xkOyBmb250LXNpemU6IDE4cHgnPkdldDwvZGl2PgogICAgICAgICAgICAgICAgICAgIDwvaW5rd2VsbD4gICAgIAogICAgICAgICAgICAgIDxkaXYgIHN0eWxlPSdjb2xvcjogIzYxNjE2MTsgZm9udC1zaXplOiAxNXB4OyBtYXJnaW4tdG9wOiA1cHgnPgpJbi1BcHAgUHVyY2hhc2VzICAgICAgICAgICAgICAKPC9kaXY+ICAgICAgICAgICAgICAgICAgICAKICAgIDwvdGQ+CiAgICA8L3RyPgogICAgPC90YWJsZT4KICAgIDwvZGl2Pgo8L2JvZHk+", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false }, { "widget_type": "jinja_html", "widget_id": "product", "on_tap_html": false, "html": "PGJvZHkgc3R5bGU9J3dpZHRoOjEwMCU7IG1hcmdpbjogMDsgcGFkZGluZzogMCc+CiAgICA8ZGl2IHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnID4KICAgIDx0YWJsZSBjbGFzcz0ndGFibGUnIHN0eWxlPScgbWFyZ2luOjBweDsgcGFkZGluZzogMHB4OyAnIGN1c3RvbS13aWR0aD0nMTAwJSc+CiAgICA8dHI+CiAgICA8dGQgY3VzdG9tLXdpZHRoPScyMCUnID4KICAgICA8Y3VzdG9tLWltYWdlIHNyYz0naHR0cHM6Ly9pbWFnZS53aW51ZGYuY29tL3YyL2ltYWdlMS9kMlZoZEdobGNpNWhZbk4wY21GamRITXVibWxqWlY5cFkyOXVYekUyT0RVM05UY3dNRGxmTURjMi9pY29uLnBuZz93PTE4NCZmYWtldXJsPTEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIHdpZHRoPSc4MCcgaGVpZ2h0PSc4MCcgYm9yZGVyLXJhZGl1cz0nODAnIC8+CiAgICA8L3RkPgogPHRkIGN1c3RvbS13aWR0aD0nNTAlJyB2YWxpZ249J3RvcCc+CjxkaXYgc3R5bGU9J2ZvbnQtc2l6ZTogMjJweDsgZm9udC13ZWlnaHQ6IGJvbGQnICB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgPk1lcmN1cnkgV2VhdGhlcjwvZGl2PiAKPGRpdiBzdHlsZT0nY29sb3I6ICM2MTYxNjEnIHVzZV9jdXN0b21fZHBfc3R5bGU9J3RydWUnIGZvbnQ9J3RpdGxlXzInPkxvY2FsIEZvcmVjYXN0cyAmIExpdmUgV2lkZ2V0czwvZGl2PiAKCiAgICA8L3RkPiAgICAKICAgICA8dGQgY3VzdG9tLXdpZHRoPSczMCUnIGFsaWduPSdlbmQnID4KICAgICAgICAgICAgICAgICAgICA8aW5rd2VsbD4KICAgICAgICAgICAgICAgICAgICAgICAgPGRpdiB1c2VfY3VzdG9tX2RwX3N0eWxlPSd0cnVlJyAgYmFja2dyb3VuZF9jb2xvcj0nbGlnaHRlcicgY29sb3I9J3ByaW1hcnknIHN0eWxlPSd3aWR0aDogNzUlOyB0ZXh0LWFsaWduOiBjZW50ZXI7IHBhZGRpbmc6IDVweDsgIGJvcmRlci1yYWRpdXM6IDUwcHg7IGZvbnQtd2VpZ2h0OiBib2xkOyBmb250LXNpemU6IDE4cHgnPkdldDwvZGl2PgogICAgICAgICAgICAgICAgICAgIDwvaW5rd2VsbD4gICAgIAogICAgICAgICAgICAgIDxkaXYgIHN0eWxlPSdjb2xvcjogIzYxNjE2MTsgZm9udC1zaXplOiAxNXB4OyBtYXJnaW4tdG9wOiA1cHgnPgpJbi1BcHAgUHVyY2hhc2VzICAgICAgICAgICAgICAKPC9kaXY+ICAgICAgICAgICAgICAgICAgICAKICAgIDwvdGQ+CiAgICA8L3RyPgogICAgPC90YWJsZT4KICAgIDwvZGl2Pgo8L2JvZHk+", "animation": false, "meta_data": { "value": "Welcome Title", "widget_id": "title", "style": { "font_size": "26", "font_weight": "900", "background_image": "https://media.istockphoto.com/id/814423752/photo/eye-of-model-with-colorful-art-make-up-close-up.jpg?s=612x612&w=0&k=20&c=l15OdMWjgCKycMMShP8UK94ELVlEGvt7GmB_esHWPYE=" } }, "suffix_icon_visible": false } ] } ] } ] } ] } }, "data": {} }""",
  );

  // Create a Future that resolves to a name
  Future<String> getName() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return 'World';
  }

  var result1 = await template1.renderAsync({
    'jframe_menu_data': [
      {
        'id': 'discover',
        'group_id': null,
        'parent_id': '0',
        'content_data': {
          'data': {
            'page': 'builder',
            'action': 'recordset_navigate',
            'depth_level': 0,
            'recordset_id': 'Discover',
          },
          'icon': {
            'unicode': 'f14e',
            'font_family': 'FontAwesomeSolid',
            'font_package': 'font_awesome_flutter',
          },
          'title': 'Discover',
          'value': 'Discover',
          'trailing': false,
          'list_of_sub_recordset': [
            'Discover',
          ],
        },
        'jframe_id': 'jframe_script_editor',
      },
      {
        'id': 'scripts',
        'group_id': null,
        'parent_id': '0',
        'content_data': {
          'data': {
            'page': 'recordset_list',
            'action': 'recordset_navigate',
            'depth_level': 0,
            'recordset_id': 'Scripts',
          },
          'icon': {
            'unicode': '0xf121',
            'font_family': 'FontAwesomeSolid',
            'font_package': 'font_awesome_flutter',
          },
          'title': 'Scripts',
          'value': 'Scripts',
          'children': [],
          'trailing': false,
          'meta_data': {
            'confirmation': {
              'icon': '',
              'type': 'confirmation_error',
              'resend': false,
              'message': 'This function is coming soon.',
              'list_of_buttons': [
                {
                  'text': 'OK',
                  'value': false,
                }
              ],
            },
          },
          'list_of_sub_recordset': [
            'Scripts',
          ],
        },
        'jframe_id': 'jframe_script_editor',
      },
      {
        'id': 'agents',
        'group_id': null,
        'parent_id': '0',
        'content_data': {
          'data': {
            'page': 'recordset_list',
            'action': 'recordset_navigate',
            'depth_level': 0,
            'recordset_id': 'Agents',
          },
          'icon': {
            'unicode': 'f4fb',
            'font_family': 'FontAwesomeSolid',
            'font_package': 'font_awesome_flutter',
          },
          'title': 'Agents',
          'value': 'Agents',
          'meta_data': {
            'do_action': 'global_action',
            'read_format': 'UI',
            'recordset_id': 'Agents',
          },
          'widget_id': 'Agents_add',
          'trailing_on_tap': true,
          'recordset_action': 'new_Agents_add',
          'list_of_sub_recordset': [
            'Agents',
          ],
        },
        'jframe_id': 'jframe_script_editor',
      },
      {
        'id': 'server_1',
        'group_id': null,
        'parent_id': '1',
        'content_data': {
          'data': {
            'depth_level': 0,
            'recordset_id': 'builder',
          },
          'icon': {
            'unicode': 'f111',
            'font_family': 'FontAwesomeSolid',
            'font_package': 'font_awesome_flutter',
          },
          'title': 'Server 1',
          'value': 'Server 1',
          'one_column': true,
          'children': [],
          'trailing': false,
          'list_of_sub_recordset': [
            'builder',
            'html-form-builder',
            'moodboard-form-builder',
            'dashboard',
            'web_widgets',
            'jinja',
            'admin_ui',
          ],
        },
        'jframe_id': 'jframe_script_editor',
      },
      {
        'id': 'server_1_agents',
        'group_id': null,
        'parent_id': 'server_1',
        'content_data': {
          'data': {
            'depth_level': 0,
            'recordset_id': 'Agents',
          },
          'icon': {
            'unicode': 'f111',
            'font_family': 'FontAwesomeSolid',
            'font_package': 'font_awesome_flutter',
          },
          'title': 'Server 1 Agents',
          'value': 'Server 1 Agents',
          'one_column': true,
          'children': [],
          'trailing': false,
          'list_of_sub_recordset': [
            'builder',
            'html-form-builder',
            'moodboard-form-builder',
            'dashboard',
            'web_widgets',
            'jinja',
            'admin_ui',
          ],
        },
        'jframe_id': 'jframe_script_editor',
      },
      {
        'id': 'designers_branding',
        'group_id': null,
        'parent_id': 'server_1_designers',
        'content_data': {
          'data': {
            'depth_level': 0,
            'recordset_id': 'Designers_branding',
          },
          'icon': {
            'unicode': 'f111',
            'font_family': 'FontAwesomeSolid',
            'font_package': 'font_awesome_flutter',
          },
          'title': 'Server 1 Designers Branding',
          'value': 'Server 1 Designers Branding',
          'one_column': true,
          'children': [],
          'trailing': false,
          'list_of_sub_recordset': [
            'builder',
            'html-form-builder',
            'moodboard-form-builder',
            'dashboard',
            'web_widgets',
            'jinja',
            'admin_ui',
          ],
        },
        'jframe_id': 'jframe_script_editor',
      },
      {
        'id': 'server_1_designers',
        'group_id': null,
        'parent_id': 'server_1',
        'content_data': {
          'data': {
            'depth_level': 0,
            'recordset_id': 'Designers',
          },
          'icon': {
            'unicode': 'f111',
            'font_family': 'FontAwesomeSolid',
            'font_package': 'font_awesome_flutter',
          },
          'title': 'Server 1 Designers',
          'value': 'Server 1 Designers',
          'one_column': true,
          'children': [],
          'trailing': false,
          'list_of_sub_recordset': [
            'builder',
            'html-form-builder',
            'moodboard-form-builder',
            'dashboard',
            'web_widgets',
            'jinja',
            'admin_ui',
          ],
        },
        'jframe_id': 'jframe_script_editor',
      },
      {
        'id': 'server_1_designers',
        'group_id': null,
        'parent_id': 'server_1',
        'content_data': {
          'data': {
            'depth_level': 0,
            'recordset_id': 'Designers',
          },
          'icon': {
            'unicode': 'f111',
            'font_family': 'FontAwesomeSolid',
            'font_package': 'font_awesome_flutter',
          },
          'title': 'Server 1 Designers',
          'value': 'Server 1 Designers',
          'one_column': true,
          'children': [],
          'trailing': false,
          'list_of_sub_recordset': [
            'builder',
            'html-form-builder',
            'moodboard-form-builder',
            'dashboard',
            'web_widgets',
            'jinja',
            'admin_ui',
          ],
        },
        'jframe_id': 'jframe_script_editor',
      },
      {
        'id': 'server_2',
        'group_id': null,
        'parent_id': '1',
        'content_data': {
          'data': {
            'depth_level': 0,
            'recordset_id': 'builder',
          },
          'icon': {
            'unicode': 'f111',
            'font_family': 'FontAwesomeSolid',
            'font_package': 'font_awesome_flutter',
          },
          'title': 'Server 2',
          'value': 'Server 2',
          'one_column': true,
          'children': [],
          'trailing': false,
          'list_of_sub_recordset': [
            'builder',
            'html-form-builder',
            'moodboard-form-builder',
            'dashboard',
            'web_widgets',
            'jinja',
            'admin_ui',
          ],
        },
        'jframe_id': 'jframe_script_editor',
      },
      {
        'id': 'add_server',
        'group_id': null,
        'parent_id': '1',
        'content_data': {
          'data': {
            'depth_level': 0,
            'recordset_id': 'builder',
          },
          'icon': {
            'unicode': 'f055',
            'font_family': 'FontAwesomeSolid',
            'font_package': 'font_awesome_flutter',
          },
          'title': 'Add Server',
          'value': 'Add Server',
          'one_column': true,
          'children': [],
          'trailing': false,
          'list_of_sub_recordset': [
            'builder',
            'html-form-builder',
            'moodboard-form-builder',
            'dashboard',
            'web_widgets',
            'jinja',
            'admin_ui',
          ],
        },
        'jframe_id': 'jframe_script_editor',
      }
    ],
  });
  print(result1); // Should print: Hello World!

  // Example 2: Multiple async globals
  print('\n=== Example 2: Multiple async globals ===');
  var template2 = env.fromString('{{ greeting }} {{ name }}!');

  Future<String> getGreeting() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return 'Hello';
  }

  var result2 = await template2.renderAsync({
    'greeting': getGreeting(),
    'name': getName(),
  });
  print(result2); // Should print: Hello World!

  // Example 3: Mix of sync and async globals
  print('\n=== Example 3: Mix of sync and async globals ===');
  var template3 = env.fromString('{{ sync_var }} and {{ async_var }}');

  Future<String> getAsyncValue() async {
    await Future<void>.delayed(const Duration(milliseconds: 75));
    return 'async value';
  }

  var result3 = await template3.renderAsync({
    'sync_var': 'sync value',
    'async_var': getAsyncValue(),
  });
  print(result3); // Should print: sync value and async value

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
}
