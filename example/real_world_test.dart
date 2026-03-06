// ignore_for_file: avoid_print

import 'dart:async';

import 'package:jinja/jinja.dart';

import 'get_jinja.dart';

final jinjaScript = '''
{% from 'outer_macro_from_loader' import outer_macro_from_loader %}
{{ outer_macro_from_loader('Avo') }}
''';
final Map<String, dynamic> jinjaData = {};

void main() async {
  try {
    final errors = <String?>[];

    // Setup MapLoader with base templates for inheritance and inclusion
    final loader = MapLoader(
      {
        'inner_macro_from_loader': '''
        {% macro inner_macro_from_loader(value) %} 
          Inner: {{ value }}
        {% endmacro %}''',
        'outer_macro_from_loader': '''
        {% from "inner_macro_from_loader" import inner_macro_from_loader %}
          {% macro outer_macro_from_loader(name) %}
            Outer macro for {{ name }}: 
            {{ inner_macro_from_loader("nested value") }}
          {% endmacro %}''',
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
    var template2 = env.fromString(jinjaScript);
    var result2 = await template2.renderAsync(jinjaData);
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
