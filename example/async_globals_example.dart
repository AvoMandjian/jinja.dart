// ignore_for_file: avoid_print

import 'dart:async';

import 'package:jinja/jinja.dart';

import 'get_jinja.dart';

final jinjaScript = """
{% set asdasd = run_data_source('my_apps_list', {}) %}


THIS IS THE DATA:
{{data}}
THIS IS THE DATA:
""";
final jinjaData = {
  'my_apps_list_columns': {
    'list_data': [
      {
        'data_type': 'text',
        'ui_widget': 'list_column',
        'property_label': 'App Label',
        'property_id': 'list_column',
        'data': {
          'value': 'app_label',
          'value_text': 'App Label',
        },
      },
      {
        'data_type': 'text',
        'ui_widget': 'list_column',
        'property_label': 'App Description',
        'property_id': 'list_column',
        'data': {
          'value': 'app_description',
          'value_text': 'App Description',
        },
      },
      {
        'data_type': 'text',
        'ui_widget': 'list_column',
        'property_label': 'App Version',
        'property_id': 'list_column',
        'data': {
          'value': 'app_version',
          'value_text': 'App Version',
        },
      }
    ],
  },
  'my_apps_list': {
    'list_data': [
      {
        'events': {
          'on_click': {
            'workflow_id': 'navigate_to_my_app',
            'properties': {
              'content_id': 'my_app_1',
            },
          },
        },
        'description': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'This is my first awesome app',
            'value': 'description',
          },
        },
        'label': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'My App Label',
            'value': 'label',
          },
        },
        'image': {
          'data_type': 'image',
          'ui_widget': 'image',
          'property_label': 'image',
          'property_id': 'image',
          'data': {
            'value':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text_b64':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
          },
        },
        'app_version': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': '1.0.0+1',
            'value': 'app_version',
          },
        },
      },
      {
        'events': {
          'on_click': {
            'workflow_id': 'navigate_to_my_app',
            'properties': {
              'content_id': 'my_app_1',
            },
          },
        },
        'description': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'This is my first awesome app',
            'value': 'description',
          },
        },
        'label': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'My App Label',
            'value': 'label',
          },
        },
        'image': {
          'data_type': 'image',
          'ui_widget': 'image',
          'property_label': 'image',
          'property_id': 'image',
          'data': {
            'value':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text_b64':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
          },
        },
        'app_version': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': '1.0.0+1',
            'value': 'app_version',
          },
        },
      },
      {
        'events': {
          'on_click': {
            'workflow_id': 'navigate_to_my_app',
            'properties': {
              'content_id': 'my_app_1',
            },
          },
        },
        'description': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'This is my first awesome app',
            'value': 'description',
          },
        },
        'label': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'My App Label',
            'value': 'label',
          },
        },
        'image': {
          'data_type': 'image',
          'ui_widget': 'image',
          'property_label': 'image',
          'property_id': 'image',
          'data': {
            'value':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text_b64':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
          },
        },
        'app_version': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': '1.0.0+1',
            'value': 'app_version',
          },
        },
      },
      {
        'events': {
          'on_click': {
            'workflow_id': 'navigate_to_my_app',
            'properties': {
              'content_id': 'my_app_1',
            },
          },
        },
        'description': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'This is my first awesome app',
            'value': 'description',
          },
        },
        'label': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'My App Label',
            'value': 'label',
          },
        },
        'image': {
          'data_type': 'image',
          'ui_widget': 'image',
          'property_label': 'image',
          'property_id': 'image',
          'data': {
            'value':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text_b64':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
          },
        },
        'app_version': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': '1.0.0+1',
            'value': 'app_version',
          },
        },
      },
      {
        'events': {
          'on_click': {
            'workflow_id': 'navigate_to_my_app',
            'properties': {
              'content_id': 'my_app_1',
            },
          },
        },
        'description': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'This is my first awesome app',
            'value': 'description',
          },
        },
        'label': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'My App Label',
            'value': 'label',
          },
        },
        'image': {
          'data_type': 'image',
          'ui_widget': 'image',
          'property_label': 'image',
          'property_id': 'image',
          'data': {
            'value':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text_b64':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
          },
        },
        'app_version': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': '1.0.0+1',
            'value': 'app_version',
          },
        },
      },
      {
        'events': {
          'on_click': {
            'workflow_id': 'navigate_to_my_app',
            'properties': {
              'content_id': 'my_app_1',
            },
          },
        },
        'description': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'This is my first awesome app',
            'value': 'description',
          },
        },
        'label': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'My App Label',
            'value': 'label',
          },
        },
        'image': {
          'data_type': 'image',
          'ui_widget': 'image',
          'property_label': 'image',
          'property_id': 'image',
          'data': {
            'value':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text_b64':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
          },
        },
        'app_version': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': '1.0.0+1',
            'value': 'app_version',
          },
        },
      },
      {
        'events': {
          'on_click': {
            'workflow_id': 'navigate_to_my_app',
            'properties': {
              'content_id': 'my_app_1',
            },
          },
        },
        'description': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'This is my first awesome app',
            'value': 'description',
          },
        },
        'label': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'My App Label',
            'value': 'label',
          },
        },
        'image': {
          'data_type': 'image',
          'ui_widget': 'image',
          'property_label': 'image',
          'property_id': 'image',
          'data': {
            'value':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text_b64':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
          },
        },
        'app_version': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': '1.0.0+1',
            'value': 'app_version',
          },
        },
      },
      {
        'events': {
          'on_click': {
            'workflow_id': 'navigate_to_my_app',
            'properties': {
              'content_id': 'my_app_2',
            },
          },
        },
        'description': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'This is my SECOND awesome app',
            'value': 'description',
          },
        },
        'label': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': 'My SECOND App Label',
            'value': 'label',
          },
        },
        'image': {
          'data_type': 'image',
          'ui_widget': 'image',
          'property_label': 'image',
          'property_id': 'image',
          'data': {
            'value':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
            'value_text_b64':
                'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
          },
        },
        'app_version': {
          'ui_widget': 'text',
          'data_type': 'text',
          'data': {
            'value_text': '2.3.0+1',
            'value': 'app_version',
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
      {
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
        return {'mock_data': 'test_data'};
      },
    );
    // example 2: real world example
    print('\n=== Example 2: Real world example ===');
    var template2 = env.fromString(jinjaScript);
    var result2 = await template2.renderAsync(jinjaData);
    print(result2);

    // example 3: real world example
    print('\n=== Example 3: Real world example ===');
    var template3 = env.fromString('''
{% set columns_to_show_key = data_source_id_my_columns %}
{% set columns_to_show = get( null ,columns_to_show_key) %}

{{columns_to_show}}

''');
    var result3 = await template3.renderAsync({
      'data_source_id_my_columns': 'my_apps_list_columns',
      'my_apps_list_columns': {
        'list_data': [
          {
            'data_type': 'text',
            'ui_widget': 'list_column',
            'property_label': 'App Label',
            'property_id': 'list_column',
            'data': {
              'value': 'app_label',
              'value_text': 'App Label',
            },
          },
          {
            'data_type': 'text',
            'ui_widget': 'list_column',
            'property_label': 'App Description',
            'property_id': 'list_column',
            'data': {
              'value': 'app_description',
              'value_text': 'App Description',
            },
          },
          {
            'data_type': 'text',
            'ui_widget': 'list_column',
            'property_label': 'App Version',
            'property_id': 'list_column',
            'data': {
              'value': 'app_version',
              'value_text': 'App Version',
            },
          }
        ],
      },
      'my_apps_list': {
        'list_data': [
          {
            'events': {
              'on_click': {
                'workflow_id': 'navigate_to_my_app',
                'properties': {
                  'content_id': 'my_app_1',
                },
              },
            },
            'description': {
              'ui_widget': 'text',
              'data_type': 'text',
              'data': {
                'value_text': 'This is my first awesome app',
                'value': 'description',
              },
            },
            'label': {
              'ui_widget': 'text',
              'data_type': 'text',
              'data': {
                'value_text': 'My App Label',
                'value': 'label',
              },
            },
            'image': {
              'data_type': 'image',
              'ui_widget': 'image',
              'property_label': 'image',
              'property_id': 'image',
              'data': {
                'value':
                    'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
                'value_text':
                    'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
                'value_text_b64':
                    'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
              },
            },
            'app_version': {
              'ui_widget': 'text',
              'data_type': 'text',
              'data': {
                'value_text': '1.0.0+1',
                'value': 'app_version',
              },
            },
          },
          {
            'events': {
              'on_click': {
                'workflow_id': 'navigate_to_my_app',
                'properties': {
                  'content_id': 'my_app_2',
                },
              },
            },
            'description': {
              'ui_widget': 'text',
              'data_type': 'text',
              'data': {
                'value_text': 'This is my SECOND awesome app',
                'value': 'description',
              },
            },
            'label': {
              'ui_widget': 'text',
              'data_type': 'text',
              'data': {
                'value_text': 'My SECOND App Label',
                'value': 'label',
              },
            },
            'image': {
              'data_type': 'image',
              'ui_widget': 'image',
              'property_label': 'image',
              'property_id': 'image',
              'data': {
                'value':
                    'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
                'value_text':
                    'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
                'value_text_b64':
                    'https://cdn.logojoy.com/wp-content/uploads/20220329171728/socail-messenger-app-logo.jpg',
              },
            },
            'app_version': {
              'ui_widget': 'text',
              'data_type': 'text',
              'data': {
                'value_text': '2.3.0+1',
                'value': 'app_version',
              },
            },
          }
        ],
      },
    });
    print(result3);

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
    var template7 =
        env.fromString('User: {{ user.name }}, Age: {{ user.age }}');

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
      filters: {
        ...env.filters,
        'reverse': (value) => value.toString().split('').reversed.join()
      },
      globals: env.globals,
      loader: env.loader,
    );
    var template9 = envWithFilter.fromString('{{ "hello"|reverse }}');
    var result9 = await template9.renderAsync();
    print(result9); // Should print: olleh

    // Example 10: Synchronous complex object with renderAsync
    print('\n=== Example 10: Synchronous complex object with renderAsync ===');
    var template10 =
        env.fromString('Product: {{ product.name }} - \${{ product.price }}');
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
    var template11 =
        env.fromString('{% for item in items %}{{ item }}{% endfor %}');
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
    var template16 = env.fromString(
        '{% for i in range(5) %}{{ cycler("red", "blue", "green") }}{% endfor %}');
    var result16 = await template16.renderAsync();
    print(result16.trim());

    // Example 17: Joiner global
    print('\n=== Example 17: Joiner global ===');
    var template17 = env.fromString(
        '{% set j = joiner(", ") %}{% for item in ["a", "b", "c"] %}{{ j() }}{{ item }}{% endfor %}');
    var result17 = await template17.renderAsync();
    print(result17.trim());

    // Example 18: Range global
    print('\n=== Example 18: Range global ===');
    var template18 =
        env.fromString('{% for i in range(1, 6) %}{{ i }}{% endfor %}');
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
    var template21 = env.fromString(
        '{% for pair in zip([1, 2, 3], ["a", "b", "c"]) %}{{ pair }}{% endfor %}');
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
    var template26 = env.fromString(
        '{% for group in users|groupby("age") %}{{ group.key }}: {{ group.list|map(attribute="name")|list }}{% endfor %}');
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
    var template30 = env.fromString(
        '{% for batch in numbers|batch(3) %}{{ batch|list }}{% endfor %}');
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

    var template34 = env.fromString(
        '{% if condition %}Condition is true{% else %}Condition is false{% endif %}');
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

    var template35 = env.fromString(
        '{% for item in items %}{{ item }}{% else %}No items{% endfor %}');
    var result35 = await template35.renderAsync({
      'items': getItems(),
    });
    print(result35.trim());

    // Example 36: With statement
    print('\n=== Example 36: With statement ===');
    var template36 = env.fromString(
        '{% with user = {"name": "Alice", "age": 25} %}{{ user.name }} is {{ user.age }} years old{% endwith %}');
    var result36 = await template36.renderAsync();
    print(result36.trim());

    // Example 37: Set statement
    print('\n=== Example 37: Set statement ===');
    var template37 = env.fromString('{% set name = "Bob" %}{{ name }}');
    var result37 = await template37.renderAsync();
    print(result37.trim());

    // Example 38: Set block
    print('\n=== Example 38: Set block ===');
    var template38 = env.fromString(
        '{% set content %}<div>Hello World</div>{% endset %}{{ content }}');
    var result38 = await template38.renderAsync();
    print(result38.trim());

    // Example 39: For loop with loop variables
    print('\n=== Example 39: For loop with loop variables ===');
    var template39 = env.fromString(
        '{% for item in items %}{{ loop.index }}: {{ item }}{% endfor %}');
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
    var template53 =
        env.fromString('{{ callback("callback_id", {"key": "value"}) }}');
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

    var template55 = env.fromString(
        '{% if is_equal(value, 42) %}Equal{% else %}Not equal{% endif %}');
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
    var template59 = env.fromString(
        '{{ users|selectattr("active")|map(attribute="name")|list|sort|list }}');
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
    var template70 =
        env.fromString('{{ 2 ** 3 }} ~ {{ "hello" ~ " " ~ "world" }}');
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
    var template72 = env.fromString(
        '{{ "Yes" if true else "No" }} | {{ "Yes" if false else "No" }}');
    var result72 = await template72.renderAsync();
    print(result72.trim());

    // Example 73: Membership Operators
    print('\n=== Example 73: Membership Operators ===');
    var template73 =
        env.fromString('{{ 1 in [1, 2, 3] }} | {{ 4 not in [1, 2, 3] }}');
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
    var template77 =
        env.fromString('{{ (true and false) or (true and true) }}');
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
    var template85 = env.fromString(
        '{{ "Hello %s! You have %d new messages."|format("User", 5) }}');
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
    var loaderWithContext = MapLoader(
      {
        'context_macros.html': '''
    {% macro print_user() %}
      User: {{ user_name }}
    {% endmacro %}
    ''',
      },
      globalJinjaData: jinjaData,
    );
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

    var template92 =
        env.fromString('User: {{ user.name }}, Age: {{ user.age }}');
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

    // Example 94: Async values in loop items
    print('\n=== Example 94: Async values in loop items ===');
    Future<String> asyncLabel(int i) async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return 'Item-$i';
    }

    var template94 = env.fromString('''
{% for item in items %}
{{ item.label }}={{ item.value }}{% if not loop.last %}, {% endif %}
{% endfor %}
''');
    var result94 = await template94.renderAsync({
      'items': [
        {'label': asyncLabel(1), 'value': 10},
        {'label': asyncLabel(2), 'value': 20},
        {'label': asyncLabel(3), 'value': 30},
      ],
    });
    print(result94.trim());

    // Example 95: Async value passed into a macro
    print('\n=== Example 95: Async value in macro ===');
    var template95 = env.fromString('''
{% macro user_card(name, status) -%}
User {{ name }} is {{ status }}
{%- endmacro %}
{{ user_card(name, status) }}
''');
    var result95 = await template95.renderAsync({
      'name': 'Charlie',
      'status': Future<String>.delayed(
        const Duration(milliseconds: 25),
        () => 'online',
      ),
    });
    print(result95.trim());

    // Example 96: Async map used by jsonencode filter
    print('\n=== Example 96: Async object with jsonencode ===');
    Future<Map<String, Object>> getPayload() async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return {
        'ok': true,
        'count': 3,
        'source': 'async',
      };
    }

    var template96 = env.fromString('{{ payload|jsonEncode }}');
    var result96 = await template96.renderAsync({'payload': getPayload()});
    print(result96.trim());

    // Example 97: Macro default argument as async value
    print('\n=== Example 97: Macro default async argument ===');
    var template97 = env.fromString('''
{% macro badge(text="guest", status=default_status) -%}
[{{ text }}:{{ status }}]
{%- endmacro %}
{{ badge("alice") }} {{ badge("bob", "busy") }}
''');
    var result97 = await template97.renderAsync({
      'default_status': Future<String>.delayed(
        const Duration(milliseconds: 30),
        () => 'online',
      ),
    });
    print(result97.trim());

    // Example 98: Nested macros with async arguments
    print('\n=== Example 98: Nested macros with async args ===');
    var template98 = env.fromString('''
{% macro item_row(name, score) -%}
{{ name }}={{ score }}
{%- endmacro %}
{% macro render_user(user_name, user_score) -%}
<li>{{ item_row(user_name, user_score) }}</li>
{%- endmacro %}
<ul>{{ render_user(name, score) }}</ul>
''');
    var result98 = await template98.renderAsync({
      'name': Future<String>.delayed(
        const Duration(milliseconds: 20),
        () => 'dora',
      ),
      'score': Future<int>.delayed(
        const Duration(milliseconds: 25),
        () => 99,
      ),
    });
    print(result98.trim());

    // Example 99: Macro iterating async list items
    print('\n=== Example 99: Macro loop over async list items ===');
    Future<List<Map<String, Object>>> getProductsAsync() async {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      return [
        {'name': 'Phone', 'price': 800},
        {'name': 'Tablet', 'price': 600},
      ];
    }

    var template99 = env.fromString('''
{% macro product_list(products) -%}
{%- for p in products -%}
{{ p.name }}:\${{ p.price }}{% if not loop.last %}, {% endif %}
{%- endfor -%}
{%- endmacro %}
{{ product_list(products) }}
''');
    var result99 =
        await template99.renderAsync({'products': getProductsAsync()});
    print(result99.trim());

    // Example 100: Imported macro with async values
    print('\n=== Example 100: Imported macro with async values ===');
    var loader100 = MapLoader(
      {
        'async_macros.html': '''
{% macro user_line(name, role) -%}
{{ name }}({{ role }})
{%- endmacro %}
''',
      },
      globalJinjaData: jinjaData,
    );
    var env100 = Environment(loader: loader100);
    var template100 = env100.fromString('''
{% from "async_macros.html" import user_line %}
{{ user_line(name, role) }}
''');
    var result100 = await template100.renderAsync({
      'name': Future<String>.delayed(
        const Duration(milliseconds: 15),
        () => 'eva',
      ),
      'role': Future<String>.delayed(
        const Duration(milliseconds: 15),
        () => 'admin',
      ),
    });
    print(result100.trim());

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
