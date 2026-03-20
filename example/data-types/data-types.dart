// ignore_for_file: avoid_print

import 'dart:async';

import 'package:jinja/jinja.dart';

import '../get_jinja.dart';

final jinjaScript = r'''
{% import "native_types.jinja" as native %}

{% macro title_view(s) -%}
    {{ s | title }}
{%- endmacro %}

{% macro round_view(n) -%}
    {{ n | round(2) }}
{%- endmacro %}

{% macro switch_view(b) -%}
    {{ "True" if b else "False" }}
{%- endmacro %}

{% macro decode_view(s) -%}
    {{ s | frombase64 }}
{%- endmacro %}

[
{{ native.dt_text("test string", title_view, ui_widget="single_line_text", property_label="Font Name", property_id="font_name")}},
{{ native.dt_number(1000.252, round_view, ui_widget="number_input", ge=0) }},
{{ native.dt_boolean(1, ui_widget="switch") }},
{{ native.dt_datetime("2026-10-10 10:10:10") }},
{{ native.dt_datetime(datetime.fromisoformat("2026-10-10 10:10:10")) }},
{{ native.dt_date("2026-10-10 10:10:10") }},
{{ native.dt_time("2026-10-10 10:10:10") }},
{{ native.dt_uuid(UUID("065d4098-8c9e-4ec1-8348-9a6beaf6a135")) }},
{{ native.dt_base64("SGVsbG8gV29ybGQ=", decode_view) }},
{{ native.dt_money(amount=1000, currency_id="USD", currency_symb="$") }},
{{ native.dt_list([1, 2, 3], param={"macro": native.dt_number}) }},
{{ native.dt_object({"a": 1, "b": 2, "c": 3}, a={"macro": native.dt_number}, b={"macro": native.dt_text}, ui_widget="complex_object")}}
]
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
        'views.jinja': r'''{# Macros implementing different views (text representation for stored data). #}

{#
-------------------------------------------------------------------------------
General Views
-------------------------------------------------------------------------------
#}

{# Return default string representation for an object. #}
{% macro plain_view(v) -%}
    {{ v }}
{%- endmacro %}

{# Return null regardless of the input. #}
{% macro empty_view(_) -%}
{%- endmacro %}

{#
-------------------------------------------------------------------------------
String Views
-------------------------------------------------------------------------------
#}

{# Return title representation for a string. #}
{% macro title_view(s) -%}
    {{ s | title }}
{%- endmacro %}

{#
-------------------------------------------------------------------------------
Number Views
-------------------------------------------------------------------------------
#}

{# Return default string representation for a number (2 decimals, with commas). #}
{% macro number_view(n) -%}
    {{ "{:,.2f}".format(n) }}
{%- endmacro %}

{#
-------------------------------------------------------------------------------
Boolean Views
-------------------------------------------------------------------------------
#}

{# Return default string representation for a boolean (On/Off). #}
{% macro boolean_view(b) -%}
    {{ "On" if b else "Off" }}
{%- endmacro %}

{#
-------------------------------------------------------------------------------
Money Views
-------------------------------------------------------------------------------
#}

{# Return default string representation for money. #}
{% macro money_view(v) -%}
    {{ v.currency_symb }}{{ "{:,.2f}".format(v.amount) }}
{%- endmacro %}
''',
        'native_types.jinja': r'''
{# Data type macros implementing native data types (basic and compound). #}

{% import "views.jinja" as views %}

{#
-------------------------------------------------------------------------------
Helpers
-------------------------------------------------------------------------------
#}

{# Raise AssertionError if value is none or undefined. #}
{% macro _isdefined(name, cls, value) %}
    {% do check(not (value is none or value is undefined or (value is string and not value)),
        "Required value `" ~ name ~ "` of `" ~ cls ~ "` is none or undefined") %}
{% endmacro %}

{# Raise AssertionError if value is not an instance of a given type. #}
{% macro _isinstance(value, type) %}
    {% if type == "text" %}
        {% do check(value is string, "Not a `text`: " ~ value) %}
    {% elif type == "number"  %}
        {% do check(value is not boolean and value is number, "Not a `number`: " ~ value) %}
    {% elif type == "boolean" %}
        {% do check(value is boolean, "Not a `boolean`: " ~ value) %}
    {% else %}
        {% do check(false, "Invalid type: " ~ type) %}
    {% endif %}
{% endmacro %}

{# Raise AssertionError if value is not a valid identifier. #}
{% macro _isident(value) %}
    {% if value is not none and value is defined %}
        {% do check(value | match("[a-zA-Z_]+[a-zA-Z0-9_]*"), "Not a valid identifier: " ~ value) %}
    {% endif %}
{% endmacro %}

{# Convert value into an object of a given type or raise AssertionError. #}
{%- macro _convert(value, type, strict) -%}
    {%- if strict -%}
        {% do _isinstance(value, type) %}
        {{ value | tojson }}
    {%- else -%}
        {%- if type == "text" -%}
            "{{ value | string }}"
        {%- elif type == "number" -%}
            {% if (value | float) == (value | int) %}
                {{ value | int }}
            {% else %}
                {{ value | float }}
            {% endif %}
        {%- elif type == "boolean" -%}
            {{ value | bool | tojson }}
        {%- else -%}
            {% do check(false, "Invalid type: " ~ type) %}
        {%- endif -%}
    {%- endif -%}
{%- endmacro -%}

{# Deduce value based on given arguments or raise AssertionError.#}
{%- macro _populate(value, type, strict, optional, default) -%}
    {%- if value is undefined or value is none -%}
        {%- if default -%}
            {{ _convert(default, type, strict) }}
        {%- elif optional -%}
            null
        {%- else -%}
            {% do check(false, "Required value is undefined") %}
        {%- endif %}
    {%- else -%}
        {{- _convert(value, type, strict) -}}
    {%- endif %}
{%- endmacro -%}

{# Return first defined object (auxiliary). #}
{% macro _fallback(fst, sec) -%}
    {{ fst if fst is not none and fst is defined else sec }}
{%- endmacro %}

{#
-------------------------------------------------------------------------------
Components
-------------------------------------------------------------------------------
#}

{# Reusable fields for data objects. #}
{% macro _preamble(uid, ui_widget, property_label, property_id) -%}
    "id": "{{  _fallback(uid, uuid()) }}",

    {%- if ui_widget is not none -%}
        {%- do _isident(ui_widget) -%}
        "ui_widget": "{{ ui_widget }}",
    {%- endif -%}

    {%- if property_label is not none -%}
        "property_label": "{{ property_label }}",
    {%- endif -%}

    {%- if property_id is not none -%}
        {%- do _isident(property_id) -%}
        "property_id": "{{ property_id }}",
    {%- endif -%}
{%- endmacro %}

{# Render value text field if value is defined. #}
{% macro _value_text(value, view) -%}
    {% if value %}
        {% set out = view(value) %}
        {% if out %}
            , "value_text": "{{ out }}"
        {% endif %}
    {% endif %}
{%- endmacro  %}

{# Create a raw text data object. #}
{% macro _raw_text(value, view, data_type, 
                   ui_widget=none, property_label=none, property_id=none,
                   strict=false, optional=false, default=none, uid=none,
                   min_length=none, max_length=none, pattern=none) %}
    {# vars #}
    {% set value = _populate(value, "text", strict, optional, default) | fromjson %}
    {% set length = value | length %}

    {# min length #}
    {% if min_length is not none %}
        {% do check(length >= min_length,
           "Failed `min_length` check for: '" ~ value ~ "', min_length: " ~ min_length) %}
    {% endif %}

    {# max length #}
    {% if max_length is not none %}
        {% do check(length <= max_length,
           "Failed `max_length` check for ': " ~ value ~ "', max_length: " ~ max_length) %}
    {% endif %}

    {# pattern #}
    {% if pattern is not none %}
        {% do check(value | match(pattern),
           "Failed `pattern` check for: '" ~ value ~ "' , pattern: " ~ pattern) %}
    {% endif %}

    {# output #}
    {
        {{ _preamble(uid, ui_widget, property_label, property_id) }}
        "data_type": "{{ data_type }}",
        "data": {
            "value": {{ value | tojson }}
            {{ _value_text(value, view) }}
        }
    }
{% endmacro %}

{#
-------------------------------------------------------------------------------
Basic Types
-------------------------------------------------------------------------------
#}

{#
Create a text.

Args:
    value: Raw input data.
	view: View which converts stored data into text representation for UI.
	ui_widget: Name of the corresponding UI widget.
	property_label: Property label for Designer.
	property_id: Property ID for Designer.
	strict: If true, prohibit auto type conversions.
	optional: If true, input data is not mandatory (can be null or undefined).
	default: Default in case of input data is null or undefined.
	uid: Unique identifier for data object.
	min_length: Min length of string.
	max_length: Max length of string.
	pattern: Regex that should be used for input data validation.
#}
{% macro dt_text(value, view=views.plain_view,
                 ui_widget=none, property_label=none, property_id=none,
                 strict=false, optional=false, default=none, uid=none,
                 min_length=none, max_length=none, pattern=none) -%}
    {{- _raw_text(value, view, "dt_text",
                  ui_widget, property_label, property_id,
                  strict, optional, default, uid,
                  min_length, max_length, pattern) -}}
{%- endmacro %}


{#
Create a datetime.

Args:
    value: Raw input data.
	view: View which converts stored data into text representation for UI.
	ui_widget: Name of the corresponding UI widget.
	property_label: Property label for Designer.
	property_id: Property ID for Designer.
	strict: If true, prohibit auto type conversions.
	optional: If true, input data is not mandatory (can be null or undefined).
	default: Default in case of input data is null or undefined.
	uid: Unique identifier for data object.
#}
{% macro dt_datetime(value, view=views.plain_view,
                     ui_widget=none, property_label=none, property_id=none,
                     strict=false, optional=false, default=none, uid=none) -%}
    {# vars #}
    {% set value = _populate(value, "text", strict, optional, default) | fromjson %}

    {# data #}
    {{- _raw_text(value[:19], view, "dt_datetime",
                  ui_widget, property_label, property_id,
                  strict, optional, default, uid,
                  min_length=none, max_length=none,
                  pattern="\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}") -}}
{%- endmacro %}

{#
Create a date.

Args:
    value: Raw input data.
	view: View which converts stored data into text representation for UI.
	ui_widget: Name of the corresponding UI widget.
	property_label: Property label for Designer.
	property_id: Property ID for Designer.
	strict: If true, prohibit auto type conversions.
	optional: If true, input data is not mandatory (can be null or undefined).
	default: Default in case of input data is null or undefined.
	uid: Unique identifier for data object.
#}
{% macro dt_date(value, view=views.plain_view,
                 ui_widget=none, property_label=none, property_id=none,
                 strict=false, optional=false, default=none, uid=none) -%}
    {# vars #}
    {% set value = _populate(value, "text", strict, optional, default) | fromjson %}

    {# data #}
    {% if value[:19] | match("\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}") -%}
        {{- _raw_text(value[:10], view, "dt_date",
                      ui_widget, property_label, property_id,
                      strict, optional, default, uid,
                      min_length=none, max_length=none, pattern=none) -}}
    {%- else -%}
        {{- _raw_text(value, view, "dt_date",
                      ui_widget, property_label, property_id,
                      strict, optional, default, uid,
                      min_length=none, max_length=none,
                      pattern="\d{4}-\d{2}-\d{2}") -}}
    {%- endif %}
{%- endmacro %}

{#
Create a time.

Args:
    value: Raw input data.
	view: View which converts stored data into text representation for UI.
	ui_widget: Name of the corresponding UI widget.
	property_label: Property label for Designer.
	property_id: Property ID for Designer.
	strict: If true, prohibit auto type conversions.
	optional: If true, input data is not mandatory (can be null or undefined).
	default: Default in case of input data is null or undefined.
	uid: Unique identifier for data object.
#}
{% macro dt_time(value, view=views.plain_view,
                 ui_widget=none, property_label=none, property_id=none,
                 strict=false, optional=false, default=none, uid=none) -%}
    {# variables #}
    {% set value = _populate(value, "text", strict, optional, default) | fromjson %}

    {# data #}
    {% if value[:19] | match("\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}") -%}
        {{- _raw_text(value[11:19], view, "dt_time",
                      ui_widget, property_label, property_id,
                      strict, optional, default, uid,
                      min_length=none, max_length=none, pattern=none) -}}
    {%- else -%}
        {{- _raw_text(value, view, "dt_time",
                      ui_widget, property_label, property_id,
                      strict, optional, default, uid,
                      min_length=none, max_length=none,
                      pattern="\d{2}:\d{2}:\d{2}") -}}
    {%- endif %}
{%- endmacro %}

{#
Create a uuid.

Args:
    value: Raw input data.
	view: View which converts stored data into text representation for UI.
	ui_widget: Name of the corresponding UI widget.
	property_label: Property label for Designer.
	property_id: Property ID for Designer.
	strict: If true, prohibit auto type conversions.
	optional: If true, input data is not mandatory (can be null or undefined).
	default: Default in case of input data is null or undefined.
	uid: Unique identifier for data object.
#}
{% macro dt_uuid(value, view=views.plain_view,
                 ui_widget=none, property_label=none, property_id=none,
                 strict=false, optional=false, default=none, uid=none) -%}
    {{- _raw_text(value, view, "dt_uuid",
                  ui_widget, property_label, property_id,
                  strict, optional, default, uid,
                  min_length=none, max_length=none,
                  pattern="[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}") -}}
{%- endmacro %}

{#
Create base64.

Args:
    value: Raw input data.
	view: View which converts stored data into text representation for UI.
	ui_widget: Name of the corresponding UI widget.
	property_label: Property label for Designer.
	property_id: Property ID for Designer.
	strict: If true, prohibit auto type conversions.
	optional: If true, input data is not mandatory (can be null or undefined).
	default: Default in case of input data is null or undefined.
	uid: Unique identifier for data object.
	min_length: Min length of decoded string.
	max_length: Max length of decoded string.
#}
{% macro dt_base64(value, view=views.empty_view,
                   ui_widget=none, property_label=none, property_id=none,
                   strict=false, optional=false, default=none, uid=none,
                   min_length=none, max_length=none) %}
    {{- _raw_text(value, view, "dt_base64", ui_widget, property_label, property_id,
                  strict, optional, default, uid,
                  min_length, max_length,
                  pattern="(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?") -}}
{% endmacro %}

{#
Create a number.

Args:
    value: Raw input data.
	view: View which converts stored data into text representation for UI.
	ui_widget: Name of the corresponding UI widget.
	property_label: Property label for Designer.
	property_id: Property ID for Designer.
	strict: If true, prohibit auto type conversions.
	optional: If true, input data is not mandatory (can be null or undefined).
	default: Default in case of input data is null or undefined.
	uid: Unique identifier for data object.
    gt: Greater than check.
    ge: Greater or equal check.
    lt: Less than check.
    le: Less or equal check.
    multiple_of: Multiple of check.
    max_digits: Max number of digits (including decimal part).
    decimal_places: Max number of decimal places.
#}
{% macro dt_number(value, view=views.number_view,
                   ui_widget=none, property_label=none, property_id=none,
                   strict=false, optional=false, default=none, uid=none,
                   gt=none, ge=none, lt=none, le=none, multiple_of=none,
                   max_digits=none, decimal_places=none) %}
    {# variables #}
    {% set value = _populate(value, "number", strict, optional, default) | fromjson %}

    {# greater than #}
    {% if gt is not none %}
        {% do check(value > gt, "Not `gt`: ! " ~ value ~ " > " ~ gt) %}
    {% endif %}

    {# greater or equal #}
    {% if ge is not none %}
        {% do check(value >= ge, "Not `ge`: ! " ~ value ~ " >= " ~ ge) %}
    {% endif %}

    {# less than #}
    {% if lt is not none %}
        {% do check(value < lt, "Not `lt`: ! " ~ value ~ " < " ~ lt) %}
    {% endif %}

    {# less or equal #}
    {% if le is not none %}
        {% do check(value <= le, "Not `le`: ! " ~ value ~ " <= " ~ le) %}
    {% endif %}

    {# multiple_of #}
    {% if multiple_of is not none %}
        {% do check(value % multiple_of == 0, "Not `multiple_of`: ! " ~ value ~ " % " ~ multiple_of ~ " == 0") %}
    {% endif %}

    {# max_digits #}
    {% if max_digits is not none %}
        {% set digits = (value|string)|replace('.', '')|replace('-', '')|length %}
        {% do check(digits <= max_digits, "Invalid `max_digits`: " ~ value) %}
    {% endif %}

    {# decimal_places #}
    {% if decimal_places is not none %}
        {% set parts = (value | string).split('.') %}
        {% if parts | length > 1 %}
            {% set decimals = parts[1] | length %}
        {% else %}
            {% set decimals = 0 %}
        {% endif %}
        {% do check(decimals <= decimal_places, "Invalid `decimal_places`: " ~ value) %}
    {% endif %}

    {# output #}
    {
        {{  _preamble(uid, ui_widget, property_label, property_id) }}
        "data_type": "dt_number",
        "data": {
            "value": {{ value | tojson }}
            {{ _value_text(value, view) }}
        }
    }
{% endmacro %}

{#
Create a boolean.

Args:
    value: Raw input data.
	view: View which converts stored data into text representation for UI.
	ui_widget: Name of the corresponding UI widget.
	property_label: Property label for Designer.
	property_id: Property ID for Designer.
	strict: If true, prohibit auto type conversions.
	optional: If true, input data is not mandatory (can be null or undefined).
	default: Default in case of input data is null or undefined.
	uid: Unique identifier for data object.
#}
{% macro dt_boolean(value, view=views.boolean_view,
                    ui_widget=none, property_label=none, property_id=none,
                    strict=false, optional=false, default=none, uid=none) %}
    {# vars #}
    {% set value = _populate(value, "boolean", strict, optional, default) | fromjson %}

    {# output #}
    {
        {{  _preamble(uid, ui_widget, property_label, property_id) }}
        "data_type": "dt_boolean",
        "data": {
            "value": {{ value | tojson }}
            {{ _value_text(value, view) }}
        }
    }
{% endmacro %}

{#
Create a money.

Args:
    value: Raw input data.
	view: View which converts stored data into text representation for UI.
	ui_widget: Name of the corresponding UI widget.
	property_label: Property label for Designer.
	property_id: Property ID for Designer.
	strict: If true, prohibit auto type conversions.
	optional: If true, input data is not mandatory (can be null or undefined).
	default: Default in case of input data is null or undefined.
	uid: Unique identifier for data object.
#}
{% macro dt_money(amount, currency_id, currency_symb, convert_rate=None,
                  view=views.money_view, uid=none, ui_widget=none, property_label=none,
                  property_id=none) -%}
    {# vars #}
    {% set amount = _populate(amount, "number", strict=false, optional=false, default=none) | fromjson %}
    {% set currency_id = _populate(currency_id, "text", strict=false, optional=false, default=none) | fromjson %}
    {% set currency_symb = _populate(currency_symb, "text", strict=false, optional=false, default=none) | fromjson %}
    {% set convert_rate = _populate(convert_rate, "number", strict=false, optional=true) | fromjson %}
    {% set value = {
        "amount": amount,
        "currency_id": currency_id,
        "currency_symb": currency_symb,
        "convert_rate": convert_rate
    } %}

    {# output #}
    {
        {{  _preamble(uid, ui_widget, property_label, property_id) }}
        "data_type": "dt_money",
        "data": {
            "value": {{ value | tojson }}
            {{ _value_text(value, view) }}
        }
    }
{%- endmacro %}

{#
-------------------------------------------------------------------------------
Compound types
-------------------------------------------------------------------------------
#}

{# Create list data by iterating over values. #}
{% macro _list_data(values, param) -%}
    [
    {% for v in values -%}
       {{- materialize(v, param) -}}{% if not loop.last %},{% endif %}
    {%- endfor %}
    ]
{%- endmacro %}

{#
Create a list.

Args:
    value: Iterable with input data.
    param: Dictionary describing storing type.
    data_type: List data type.
    ui_widget: Name of the corresponding UI widget.
	property_label: Property label for Designer.
	property_id: Property ID for Designer.
	uid: Unique identifier for data object.
#}
{% macro dt_list(value, param, data_type=none, view=views.empty_view,
                 ui_widget=none, property_label=none, property_id=none,
                 uid=none) -%}
    {# vars #}
    {% set data = _list_data(value, param) %}

    {# output #}
    {
        {{  _preamble(uid, ui_widget, property_label, property_id) }}
        "data_type": "{{ _fallback(data_type, "dt_list") }}",
        "data": {{ data }}
    }
{%- endmacro %}

{# Create map data by iterating over params. #}
{% macro _object_data(value, params, data_type) -%}
    {
    {% for k, v in params -%}
        {% do _isident(k) %}
        {% do _isdefined(k, data_type, value[k]) %}
        "{{ k }}": {{- materialize(value[k], v) -}}{% if not loop.last %},{% endif %}
    {%- endfor %}
    }
{%- endmacro %}

{#
Create a map.

Args:
    value: Mapping with input data.
    data_type: Map subtype.
    ui_widget: Name of the corresponding UI widget.
	property_label: Property label for Designer.
	property_id: Property ID for Designer.
	uid: Unique identifier for data object.
	**kwargs: Field description.
#}
{% macro dt_object(value, data_type=none, view=views.empty_view,
                   ui_widget=none, property_label=none, property_id=none,
                   uid=none) -%}
    {# vars #}
    {% set data = _object_data(value, kwargs, data_type or 'dt_list') %}

    {# output #}
    {
        {{  _preamble(uid, ui_widget, property_label, property_id) }}
        "data_type": "{{ _fallback(data_type, "dt_object") }}",
        "data": {{ data }}
    }
{%- endmacro %}
''',
        'media_types.jinja': r'''
{% import "native_types.jinja" as native %}

{% set max_image_size = 10485760 %} {# 10Mb #}
{% set image_extensions = ["png", "svg", "webp"] %}

{# Create an image. #}
{% macro dt_image(value) -%}
    {{ native.dt_object(value,
        data_type="dt_image",
        image_type={"macro": native.dt_text, "pattern": image_extensions | join('|')},
        image_content={"macro": native.dt_base64, "max_length": max_image_size},
        image_size={"macro": f.dt_number, "ge": 0},
        secure={"macro": native.dt_boolean, "default": false}) }}
{%- endmacro %}
''',
        'container_types.jinja': r'''
{% import "native_types.jinja" as native %}
{% import "media_types.jinja" as media %}
{% import "views.jinja" as views %}

{# 
-------------------------------------------------------------------------------
Options
-------------------------------------------------------------------------------
#}

{# Create an `option` object containing `icon`, `text`, and `hint` fields #}
{% macro dt_option(value) -%}
    {{ native.dt_object(value,
        data_type="dt_option",
        ui_widget="option_widget",
        icon={"macro": media.dt_image},
        text={"macro": native.dt_text},
        hint={"macro": native.dt_text, "optional": true}) }}
{%- endmacro %}

{# Create a list of `option` objects #}
{% macro dt_options_list(value) -%}
    {{ native.dt_list(value,
        data_type="dt_options_list",
        param={"macro": dt_option}) }}
{%- endmacro %}

{# 
-------------------------------------------------------------------------------
Option groups
-------------------------------------------------------------------------------
#}

{# Create an `option_group` object containing `icon`, `subtitle`, and `content` fields #}
{% macro dt_option_group(value) -%}
    {{ native.dt_object(value,
       data_type="dt_option_group",
       ui_widget="option_group_section",
       icon={"macro": media.dt_image},
       subtitle={"macro": native.dt_text},
       content={"macro": dt_options_list}) }}
{%- endmacro %}

{# Create a list of `option_group` objects #}
{% macro dt_option_groups_list(value) -%}
    {{ native.dt_list(value,
        data_type="dt_option_groups_list",
        param={"macro": dt_option_group}) }}
{%- endmacro %}

{# Create option groups container #}
{% macro dt_option_groups_container(value) -%}
    {{ native.dt_object(value,
        data_type="dt_option_groups_container",
        ui_widget="option_groups_form",
        title={"macro":  native.dt_text, "view": views.title_view, "optional": true},
        groups={"macro": dt_option_groups_list}) }}
{%- endmacro %}
''',
        'container_types_in.jinja': r'''
{% import "container_types.jinja" as containers %}

{# Input #}
{% set tag_groups = {
    "title": "all tags",
    "groups": [
        {
            "icon": {
                "image_type": "png",
                "image_content": "SGVsbG8gV29ybGQ=",
                "image_size": 12345,
                "secure": 0
            },
            "subtitle": "Team",
            "content": [
                {
                    "icon": {
                        "image_type": "png",
                        "image_content": "SGVsbG8gV29ybGQ=",
                        "image_size": "12345",
                        "secure": true
                    },
                    "text": "Domain Expertise Required",
                    "hint": "Deep industry knowledge needed"
                }
            ]
        },
        {
            "icon": {
                "image_type": "png",
                "image_content": "SGVsbG8gV29ybGQ=",
                "image_size": 12345,
                "secure": false
            },
            "subtitle": "Scale",
            "content": [
                {
                    "icon": {
                        "image_type": "png",
                        "image_content": "SGVsbG8gV29ybGQ=",
                        "image_size": 12345,
                        "secure": false
                    },
                    "text": "Venture Scale",
                    "hint": "Could be venture backable"
                },
                {
                    "icon": {
                        "image_type": "png",
                        "image_content": "SGVsbG8gV29ybGQ=",
                        "image_size": 12345,
                        "secure": false
                    },
                    "text": "Quick MVP",
                    "hint": "Can launch MVP quickly"
                }
            ]
        }
    ]
} %}

{# Convert to data types #}
{{ containers.dt_option_groups_container(tag_groups) }}
''',
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
    var template2 = env.fromString(jinjaScript);
    var result2 = await template2.renderAsync(jinjaData);
    print('Result length: ${result2.length}');
    print('--------------------------------------------------------------------------------------------------------------------------------');
    print(result2.replaceAll('\n', ''));
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
