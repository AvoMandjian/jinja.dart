import 'package:jinja/jinja.dart';
import 'package:test/test.dart';

void main() {
  group('Async macro rendering', () {
    test('macros should work with renderAsync', () async {
      final template = Template('''
{%- macro property_field(key, val) -%}
{"key": "{{key}}", "value": "{{val.value}}", "label": "{{val.property_label}}"}
{%- endmacro -%}
[
{%- for key, val in property_settings %}
{{ property_field(key, val) }}{% if not loop.last %},{% endif %}
{%- endfor %}
]
''');

      final data = {
        'property_settings': {
          'height': {
            'value': Future.value('100'),
            'property_label': 'Height',
          },
          'width': {
            'value': Future.value('50'),
            'property_label': 'Width',
          },
        },
      };

      final result = await template.renderAsync(data);

      // Should NOT contain "Instance of '_Future"
      expect(result, isNot(contains('Instance of')));
      expect(result, isNot(contains('Future')));

      // Should contain the actual values
      expect(result, contains('"value": "100"'));
      expect(result, contains('"value": "50"'));
      expect(result, contains('"label": "Height"'));
      expect(result, contains('"label": "Width"'));
    });

    test('nested macro calls with futures', () async {
      final template = Template('''
{%- macro text_field(key, val) -%}
{"type": "text_field", "id": "{{key}}", "value": "{{val.value}}"}
{%- endmacro -%}

{%- macro color_picker(key, val) -%}
{"type": "color_picker", "id": "{{key}}", "color": "{{val.value}}"}
{%- endmacro -%}

{%- macro property_control(key, val) -%}
{%- if key == 'text' -%}
{{ text_field(key, val) }}
{%- elif key == 'color' -%}
{{ color_picker(key, val) }}
{%- endif -%}
{%- endmacro -%}

{"controls": [
{%- for key, val in settings %}
{{ property_control(key, val) }}{% if not loop.last %},{% endif %}
{%- endfor %}
]}
''');

      final data = {
        'settings': {
          'text': {
            'value': Future.value('Button'),
          },
          'color': {
            'value': Future.value('#FF0000'),
          },
        },
      };

      final result = await template.renderAsync(data);

      expect(result, isNot(contains('Instance of')));
      expect(result, contains('"value": "Button"'));
      expect(result, contains('"color": "#FF0000"'));
    });

    test('macro with sync values should still work', () async {
      final template = Template('''
{%- macro field(key, val) -%}
{{key}}: {{val}}
{%- endmacro -%}
{% for k, v in items %}{{ field(k, v) }}
{% endfor %}
''');

      final data = {
        'items': {
          'a': '1',
          'b': '2',
        },
      };

      final result = await template.renderAsync(data);
      expect(result, contains('a: 1'));
      expect(result, contains('b: 2'));
    });

    test('macro with mixed sync and async values', () async {
      final template = Template('''
{%- macro item(name, value, description) -%}
{"name": "{{name}}", "value": "{{value}}", "desc": "{{description}}"}
{%- endmacro -%}
[
{%- for entry in entries %}
{{ item(entry.name, entry.value, entry.desc) }}{% if not loop.last %},{% endif %}
{%- endfor %}
]
''');

      final data = {
        'entries': [
          {
            'name': Future.value('Item 1'),
            'value': 42, // sync value
            'desc': Future.value('First item'),
          },
          {
            'name': 'Item 2', // sync value
            'value': Future.value(99),
            'desc': 'Second item', // sync value
          },
        ],
      };

      final result = await template.renderAsync(data);

      expect(result, isNot(contains('Instance of')));
      expect(result, contains('"name": "Item 1"'));
      expect(result, contains('"value": "42"'));
      expect(result, contains('"desc": "First item"'));
      expect(result, contains('"name": "Item 2"'));
      expect(result, contains('"value": "99"'));
      expect(result, contains('"desc": "Second item"'));
    });
  });
}
