import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:jinja/jinja.dart';
import 'example/get_jinja.dart';

void main() async {
  final helpersTemplate = await File('data-types/jinja/helpers.jinja').readAsString();
  final loader = MapLoader(
    {'helpers.jinja': helpersTemplate},
    globalJinjaData: {},
  );
  
  final env = GetJinja.environment(
    MockBuildContext(),
    loader,
    valueListenableJinjaError: (error) {
      print('Jinja Error: $error');
    },
    callbackToParentProject: ({required payload}) async {},
  );
  
  final flattenTemplate = env.fromString('''
{%- import "helpers.jinja" as helpers -%}
{{ helpers.flatten(data, include_dt_object_id=false) }}
''');

  final slideoverOut = await File('data-types/examples/app_jinja_ide/slideover_out.json').readAsString();
  final data = jsonDecode(slideoverOut);
  final res = await flattenTemplate.renderAsync({'data': data});
  print(res);
}
