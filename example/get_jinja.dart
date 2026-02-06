import 'dart:convert';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:jinja/jinja.dart';
import 'package:jinja/src/runtime.dart';
import 'package:json_path/json_path.dart';
import 'package:path/path.dart' as p;
import 'package:textwrap/textwrap.dart';
import 'package:uuid/uuid.dart';

import 'async_globals_example.dart';

// Mock BuildContext for standalone usage
class MockBuildContext {}

enum LogType {
  info,
  warning,
  error,
}

// Mock UtilFunctions for standalone usage
class UtilFunctions {
  UtilFunctions._();
  static void appLog(dynamic message, {dynamic logType}) {}
  static String formatDate(String date) => date;
  static double getScreenWidth(dynamic context) => 1024.0;
  static double getScreenHeight(dynamic context) => 768.0;
  static String getPlainTextFromHtml(String html) => html;
  static dynamic changeObjectToMap(dynamic obj) => obj as Map<String, dynamic>;
  static String jsonEncodeMethod(dynamic obj) => json.encode(obj);
  static bool isBase64(String value) => RegExp(r'^[a-zA-Z0-9+/]*={0,2}$').hasMatch(value);
  static String encodeToBase64(String? value) => base64.encode(utf8.encode(value ?? ''));
  static String decodeFromBase64(String value) => utf8.decode(base64.decode(value));
}

// Mock JinjaGoogleTranslateService for standalone usage
class JinjaGoogleTranslateService {
  JinjaGoogleTranslateService._();
  static Future<String> translateText(
    String value,
    String to,
    String apiKey,
    String from,
  ) async {
    return 'Translated: $value';
  }
}

String convertPythonToDartDateFormat(String format) {
  // Simple conversion, can be expanded.
  return format.replaceAll('%Y', 'yyyy').replaceAll('%m', 'MM').replaceAll('%d', 'dd');
}

class GetJinja {
  GetJinja._();

  /// Sync wrapper for translate that immediately returns a Future
  static Object translateSync(
    String value,
    String? sourceLanguage,
    String? targetLanguage,
  ) {
    return JinjaGoogleTranslateService.translateText(
      value,
      targetLanguage ?? 'en',
      'mock-api-key',
      sourceLanguage ?? 'auto',
    );
  }

  static Environment environment(
    dynamic context,
    MapLoader loader, {
    required Function(String? error) valueListenableJinjaError,
    required Future<dynamic> Function({
      required Map<String, dynamic> payload,
    }) callbackToParentProject,
  }) {
    Future<String> fetchWidgetSource(String widgetId, [dynamic jinjaData]) async {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (widgetId == 'macro_list_column') {
        return '''{% macro macro_list_column(col) %}
 {
        "type": "{% if col.metadata and col.metadata.type %}{{col.metadata.type}}{%endif%}",
        "column_id": "{% if col.data and col.data.value %}{{col.data.value}}{%endif%}",
        "column_name": "{% if col.data and col.data.value_text %}{{col.data.value_text}}{%endif%}",
        "allow_sorting": {% if col.metadata and col.metadata.sorting is defined and col.metadata.sorting == 1%}true{%else%}false{%endif%},
{% if col.metadata and col.metadata.width is defined %}
        "width": {{col.metadata.width}},
{%endif%}
         "column_alignement":"{% if col.metadata and col.metadata.column_alignement %}{{col.metadata.column_alignement}}{%endif%}",
         "row_alignement":"{% if col.metadata and col.metadata.row_alignement %}{{col.metadata.row_alignement}}{%endif%}"
      }
{%endmacro%}
''';
      } else if (widgetId == 'macro_list_row') {
        return '''{% macro macro_list_row(my_app) %}
  {% if my_app %}
  {
  {% for key, val in my_app %}
  {% if val.data_type == 'image'%}
      "{{key}}": {
        "value": {
          "image_b64": "{% if val.data and val.data.value_text_b64%}{{val.data.value_text_b64}}{%endif%}",
          "image_url": "{% if val.data and val.data.value_text%}{{val.data.value_text}}{%endif%}",
          "main_image_url": "{% if val.data and val.data.value_text%}{{val.data.value_text}}{%endif%}"
        }
      }
    {% elif val.data_type == 'icon'%}
     "{{key}}": {
                "value": {
                    "unicode": "{% if val.data and val.data.value_text%}{{val.data.value_text}}{%endif%}"
                }
     }
    {%else%}
  
      "{{key}}": {
        "value": {
          "text": "{% if val.data and val.data.value_text%}{{val.data.value_text}}{%endif%}"
        }
      }
   {% endif %}
    }
  {%if not loop.last %},{%endif%}{%endfor%}
  {%endif%}
  {%endmacro%}''';
      }
      final res = await callbackToParentProject(
        payload: {
          'widget_id': widgetId,
          'jinja_data': jinjaData,
        },
      );
      return res?.toString() ?? '';
    }

    return Environment(
      globals: <String, Object?>{
        'return': (dynamic value) {
          return value;
        },
        'render_widget_by_id': passContext((
          Context context,
          String widgetId, [
          Map<Object?, Object?>? data,
        ]) async {
          final source = await fetchWidgetSource(widgetId);
          // Assuming macro name matches widgetId
          final macroName = widgetId;
          final args = data?.keys.map((k) => k.toString()).join(', ') ?? '';
          final call = '{{ $macroName($args) }}';
          final fullSource = '$source\n$call';
          final template = context.environment.fromString(fullSource);
          return template.renderAsync(data?.cast<String, Object?>());
        }),
        'get_widget_by_id': (
          String widgetId, [
          dynamic jinjaData,
        ]) async {
          return fetchWidgetSource(widgetId, jinjaData);
        },

        /// Executes a generic callback via the parent project with an ID and optional payload.
        'callback': (
          String callbackId, [
          dynamic jinjaData,
          dynamic payload,
        ]) async {
          final res = await callbackToParentProject(
            payload: {
              'widget_id': callbackId,
              'jinja_data': jinjaData,
            },
          );
          // print('widget by id result: $res');
          return res ?? {};
        },

        /// Logs a value to the application logs and returns it.
        'print': (dynamic value) {
          UtilFunctions.appLog(
            'printed from jinja script: ${jsonEncode(value)}',
          );
          return value;
        },

        // dbt-compatible globals

        /// Placeholder for dbt `ref` function. Returns the model name as string.
        'ref': (dynamic modelName, [dynamic version]) {
          if (modelName is String) return modelName;
          return '';
        },

        /// Placeholder for dbt `source` function. Returns `source.table` string.
        'source': (String sourceName, String tableName) {
          return '$sourceName.$tableName';
        },

        /// Placeholder for dbt `config` function.
        'config': (dynamic args) {
          return '';
        },

        /// Retrieves a variable from the context or returns default.
        'var': (String varName, [dynamic defaultValue]) {
          return defaultValue ?? varName;
        },

        /// Retrieves an environment variable (placeholder).
        'env_var': (String varName, [dynamic defaultValue]) {
          return defaultValue ?? '';
        },

        /// Logs a message to the application logs (dbt compatible).
        'log': (dynamic message) {
          UtilFunctions.appLog('dbt log: $message');
          return '';
        },

        /// Placeholder for dbt `run_query`.
        'run_query': (String query) {
          UtilFunctions.appLog('dbt run_query (placeholder): $query');
          return [];
        },

        /// Provides access to utility modules like `datetime`.
        'modules': {
          'datetime': {
            'now': () => DateTime.now(),
          },
        },

        /// Checks deep equality between two values, supporting Futures.
        'is_equal': (dynamic value1, dynamic value2) async {
          if (value1 is Future) {
            final value = await value1;
            final result = value == value2;
            return result;
          } else if (value2 is Future) {
            final value = await value2;
            final result = value == value1;
            return result;
          } else {
            final result = value1 == value2;
            return result;
          }
        },

        /// Fetches mock data asynchronously.
        'fetchDataGlobal': () async {
          final result = await fetchData();
          return result;
        },

        /// Translates text using the configured translation service.
        'translate': translateSync,

        /// Generates a v4 UUID.
        'uuid': () {
          final String uniqueId = const Uuid().v4();
          return uniqueId;
        },

        /// Returns the current date formatted as dd/MM/yyyy.
        'get_current_date': () {
          return {
            'value': UtilFunctions.formatDate(
              DateFormat('dd/MM/yyyy').format(DateTime.now()),
            ),
            'value_text': DateFormat('dd/MM/yyyy').format(DateTime.now()),
          };
        },

        /// Generates a list of strings repeated `count` times.
        'generate_list': (int count, [String? values]) {
          try {
            return List.generate(count, (index) => values ?? '');
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Flattens a nested structure of widgets into a single list.
        'get_list_of_widgets': (List? listOfNestedWidgets) {
          try {
            final List<Map<String, dynamic>> widgetsToSend = [];
            void addNestedWidgetsToWidgetsToSend(List? listOfNestedWidgets) {
              for (final element in listOfNestedWidgets ?? []) {
                if (element['widgets'] != null) {
                  widgetsToSend.add(element);
                  addNestedWidgetsToWidgetsToSend(element['widgets']);
                } else {
                  widgetsToSend.add(element);
                }
              }
            }

            addNestedWidgetsToWidgetsToSend(listOfNestedWidgets);
            return widgetsToSend;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Placeholder for getting widget width.
        'getWidgetWidth': () {},

        /// Placeholder for getting widget height.
        'getWidgetHeight': () {},

        /// Gets the screen width from the current context.
        'getScreenWidth': () => UtilFunctions.getScreenWidth(context),

        /// Gets the screen height from the current context.
        'getScreenHeight': () => UtilFunctions.getScreenHeight(context),

        /// Updates a JSON structure with new property values based on IDs or CSS styles.
        'changePropertiesValues': (
          dynamic initialJson,
          dynamic newValues, [
          String? widgetId,
          String? widgetType,
          String? parentWidgetId,
        ]) {
          List<Map<String, dynamic>> updateDataWithProperties(
            List<Map<String, dynamic>> data,
            List<Map<String, dynamic>> propertiesJson,
          ) {
            // Loop through each property in the properties JSON
            for (final property in propertiesJson) {
              final String propertyId = property['property_id'];

              // Loop through each section in data
              for (final section in data) {
                final widgets = section['widgets'] as List<dynamic>;

                // Loop through each widget in the section
                for (final widget in widgets) {
                  final subPropertiesList = widget['sub_properties'];
                  if (subPropertiesList is List<dynamic>) {
                    // Loop through the sub_properties in each widget
                    for (final subProperties in subPropertiesList) {
                      for (final subProperty in subProperties) {
                        subProperty['belongs_to'] = {
                          'widget_id': widgetId,
                          'widget_type': widgetType,
                          'parent_widget_id': parentWidgetId,
                        };
                        // Check if the id matches and update the value
                        if (widget['property_id'] == propertyId && property['value'] != null) {
                          for (final element in (property['value'] as Map<String, dynamic>).keys) {
                            final String key = element;
                            final dynamic value = property['value'][key];
                            if (subProperty['id'] == key) {
                              subProperty['value'] = value;
                              break;
                            } else {
                              subProperty[key] = value;
                            }
                          }
                        }
                      }
                    }
                  } else if (subPropertiesList is Map<String, dynamic>) {
                    subPropertiesList.forEach((key, subPropertiesList) {
                      if (subPropertiesList is List<dynamic>) {
                        for (final subProperties in subPropertiesList) {
                          for (final subProperty in subProperties) {
                            subProperty['belongs_to'] = {
                              'widget_id': widgetId,
                              'widget_type': widgetType,
                              'parent_widget_id': parentWidgetId,
                            };
                            // Check if the id matches and update the value
                            if (widget['css_style'] == key) {
                              if (widget['property_id'] == propertyId && property['value'] != null) {
                                for (final element in (property['value'] as Map<String, dynamic>).keys) {
                                  final String key = element;
                                  final dynamic value = property['value'][key];

                                  if (subProperty['id'] == key) {
                                    subProperty['value'] = value;
                                    break;
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    });
                  }
                }
              }
            }
            return data;
          }

          final listToChange = List<Map<String, dynamic>>.from(initialJson);
          final valuesToChangeTo = List<Map<String, dynamic>>.from(
            newValues,
          );
          final updatedValues = updateDataWithProperties(
            listToChange,
            valuesToChangeTo,
          );

          return updatedValues;
        },

        /// Decodes a JSON string with logging.
        'jsonDecode': (dynamic value) {
          try {
            final valueToSend = jsonDecode(
              value,
              reviver: (key, value) {
                UtilFunctions.appLog('key: $key, value: $value');
                return value;
              },
            );
            return valueToSend;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },

        /// Safely retrieves a value from a nested Map/JSON structure using a key.
        'get': (dynamic json, String key, [dynamic defaultValue = '']) {
          try {
            json ??= loader.globalJinjaData;
            if (json is! Map<Object?, Object?>) {
              UtilFunctions.appLog(
                {
                  'action': 'get error in Jinja',
                  'error': 'json is not a map',
                  'json': json,
                  'key': key,
                  'defaultValue': defaultValue,
                },
                logType: LogType.error,
              );
              return defaultValue;
            }
            // recusively get the value
            Object? getValue(Map<Object?, Object?>? json, String key) {
              if (json == null) {
                return defaultValue;
              }
              if (json.containsKey(key)) {
                return json[key];
              }
              for (final value in json.values) {
                if (value is Map<Object?, Object?>) {
                  final result = getValue(value, key);
                  if (result != null) {
                    return result;
                  }
                }
              }
              return defaultValue;
            }

            final response = getValue(json, key);
            return response;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return defaultValue;
          }
        },

        /// Returns the key if it exists in the JSON structure, otherwise returns default.
        'get_key_if_in_json': (
          dynamic json,
          String key, [
          dynamic defaultValue = '',
        ]) {
          try {
            if (json is! Map<Object?, Object?>) {
              UtilFunctions.appLog(
                {
                  'action': 'get_key_if_in_json error in Jinja',
                  'error': 'json is not a map',
                  'json': json,
                  'key': key,
                  'defaultValue': defaultValue,
                },
                logType: LogType.error,
              );
              return defaultValue;
            }
            // recusively get the value
            Object? getValue(Map<Object?, Object?>? json, String key) {
              if (json == null) {
                return defaultValue;
              }
              if (json.containsKey(key)) {
                return key;
              }
              for (final value in json.values) {
                if (value is Map<Object?, Object?>) {
                  final result = getValue(value, key);
                  if (result != null) {
                    return result;
                  }
                }
              }
              return defaultValue;
            }

            final response = getValue(json, key);
            return response;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return defaultValue;
          }
        },

        /// Executes a JSONPath query on the provided JSON object.
        'jsonPath': (dynamic json, String query) {
          if (json is! Map<Object?, Object?>) {
            UtilFunctions.appLog(
              {
                'action': 'jsonPath error in Jinja',
                'error': 'json is not a map',
                'json': json,
                'query': query,
              },
              logType: LogType.error,
            );
            return query;
          }
          try {
            final jsonQuery = JsonPath(query);
            final jsonPathMatch = jsonQuery.read(json);
            final responseOfQuery = jsonPathMatch.map((e) => e);
            return responseOfQuery.singleOrNull?.value;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return {'error': e.toString(), 'query': query};
          }
        },
      },
      loader: loader,
      filters: {
        /// Fetches data asynchronously (filter version).
        'fetchDataFilter': (dynamic value) async {
          final result = await fetchData();
          return result;
        },

        /// Appends a value to a list, optionally parsing as JSON map.
        'append': (List list, value, [String? type = 'MAP']) {
          try {
            if (value != null) {
              if (type == 'MAP') {
                if (value is String) {
                  list.add(jsonDecode(value));
                } else {
                  list.add(value);
                }
              } else {
                list.add(value);
              }
            }
            return list;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return list;
          }
        },

        // dbt-compatible filters

        /// Converts an object to a JSON string representation.
        'tojson': (dynamic value) {
          try {
            return jsonEncode(value);
          } catch (e) {
            return value.toString();
          }
        },

        /// Parses a JSON string into an object.
        'fromjson': (String? value) {
          try {
            return jsonDecode(value ?? '{}');
          } catch (e) {
            return {};
          }
        },

        /// Converts a value to a boolean using common string representations.
        'as_bool': (dynamic value) {
          if (value == null) return false;
          if (value is bool) return value;
          if (value is num) return value != 0;
          if (value is String) {
            final lower = value.toLowerCase();
            return lower == 'true' || lower == '1' || lower == 'yes' || lower == 'y';
          }
          return false;
        },

        /// AVOM: AI ADDED FILTERS

        /// Decodes a Base64 encoded string.
        'b64decode': (String? value) {
          try {
            return UtilFunctions.decodeFromBase64(value ?? '').toString();
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value ?? '';
          }
        },

        /// Casts a value to a boolean.
        'bool': (dynamic value) {
          try {
            if (value == null) return false;
            if (value is bool) return value;
            if (value is num) return value != 0;
            if (value is String) {
              return value.toLowerCase() == 'true' || value == '1' || value == 'yes' || value == 'y';
            }
            return false;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return false;
          }
        },

        /// Merges two maps together.
        'combine': (Map value, Map combineValue) {
          try {
            return {...value, ...combineValue};
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },

        /// Returns the value if not null, otherwise the default value.
        'default': (dynamic value, dynamic defaultValue) {
          return value ?? defaultValue;
        },

        /// Sorts a map by key or value.
        'dictsort': (Map value, [String? key, bool reverse = false]) {
          try {
            var entries = value.entries.toList();
            if (key != null) {
              entries.sort(
                (a, b) => (a.value?[key] ?? '').toString().compareTo(
                      (b.value?[key] ?? '').toString(),
                    ),
              );
            } else {
              entries.sort(
                (a, b) => a.key.toString().compareTo(b.key.toString()),
              );
            }
            if (reverse) {
              entries = entries.reversed.toList();
            }
            return Map.fromEntries(entries);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },

        /// Formats a number of bytes into a human-readable string (e.g., '10.5 MB').
        'filesizeformat': (dynamic value, [dynamic binary = false]) {
          try {
            final bool isBinary = binary == true || binary == 'true' || binary == '1';
            final numBytes = value is String ? int.tryParse(value) ?? 0 : (value is num ? value.toInt() : 0);
            if (numBytes < 0) return '0 Bytes';

            final units = isBinary
                ? [
                    'Bytes',
                    'KiB',
                    'MiB',
                    'GiB',
                    'TiB',
                    'PiB',
                    'EiB',
                    'ZiB',
                    'YiB',
                  ]
                : ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

            final divisor = isBinary ? 1024 : 1000;
            int unitIndex = 0;
            num size = numBytes.toDouble();

            while (size >= divisor && unitIndex < units.length - 1) {
              size /= divisor;
              unitIndex++;
            }

            return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return '0 Bytes';
          }
        },

        /// Returns the first item of a list.
        'first': (List? value) {
          try {
            return value?.isNotEmpty == true ? value?.first : null;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return null;
          }
        },

        /// Builds a tree structure from a flat list of items containing 'id' and 'parent_id'.
        'buildTree': (List<dynamic> flatList) {
          try {
            if (flatList.isEmpty) {
              return [];
            }

            final Map<dynamic, Map<String, dynamic>> itemsById = {};
            for (var item in flatList) {
              final mapItem = Map<String, dynamic>.from(item);
              if (!mapItem.containsKey('children')) {
                mapItem['children'] = <Map<String, dynamic>>[];
              }
              itemsById[mapItem['id']] = mapItem;
            }

            final List<Map<String, dynamic>> roots = [];
            for (var item in itemsById.values) {
              final parentId = item['parent_id'];
              if (parentId == 0 || !itemsById.containsKey(parentId)) {
                roots.add(item);
              } else {
                final parent = itemsById[parentId];
                if (parent != null) {
                  // Ensure children list exists and add the item
                  (parent['children'] as List).add(item);
                }
              }
            }

            return roots;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Groups a list of objects by a specified attribute.
        'groupby': (List value, String attribute) {
          try {
            final groups = <dynamic, List<Map<String, dynamic>>>{};
            for (final item in value) {
              final itemToAdd = Map<String, dynamic>.from(item);
              if (itemToAdd.containsKey(attribute)) {
                final key = itemToAdd[attribute];
                groups.putIfAbsent(key, () => []).add(itemToAdd);
              }
            }
            return groups.entries.map((e) => {'key': e.key, 'list': e.value}).toList();
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Recursively groups a list of objects by multiple attributes.
        'groupbyMultiple': (List value, List attributes) {
          try {
            if (attributes.isEmpty) {
              return value;
            }

            dynamic groupRecursively(List<dynamic> list, List<dynamic> attrs) {
              if (attrs.isEmpty) {
                return list;
              }

              final currentAttr = attrs.first as String;
              final remainingAttrs = attrs.sublist(1);
              final groups = <dynamic, List<dynamic>>{};

              for (final item in list) {
                if (item is Map<String, dynamic> && item.containsKey(currentAttr)) {
                  final key = item[currentAttr];
                  groups.putIfAbsent(key, () => []).add(item);
                }
              }

              return groups.entries.map((entry) {
                return {
                  'key': entry.key,
                  'list': groupRecursively(entry.value, remainingAttrs),
                };
              }).toList();
            }

            return groupRecursively(value, attributes);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Joins elements of a list into a string with a separator.
        'join': (List? value, [String separator = '']) {
          try {
            return value?.map((e) => e.toString()).join(separator) ?? '';
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return '';
          }
        },

        /// Returns the last item of a list.
        'last': (List? value) {
          try {
            return value?.isNotEmpty == true ? value?.last : null;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return null;
          }
        },

        /// Converts value (list, map, string) to a list.
        'list': (dynamic value) {
          try {
            if (value == null) return [];
            if (value is List) return List.from(value);
            if (value is String) return value.split('');
            if (value is Map) return value.entries.toList();
            return [value];
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Returns the maximum value from a list.
        'max': (List? value) {
          try {
            if (value?.isEmpty ?? true) return null;
            return value?.reduce((a, b) => (a > b) ? a : b);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return null;
          }
        },

        /// Returns the minimum value from a list.
        'min': (List? value) {
          try {
            if (value?.isEmpty ?? true) return null;
            return value?.reduce((a, b) => (a < b) ? a : b);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return null;
          }
        },

        /// Returns a random item from a list.
        'random': (List? value) {
          try {
            if (value?.isEmpty ?? true) return null;
            final random = Random();
            return value?[random.nextInt(value.length)];
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return null;
          }
        },

        'reduce': (List? list, String func, [dynamic start]) {
          if (list == null || list.isEmpty) return start;
          if (func == 'add') {
            return list.fold(start ?? 0, (a, b) => (a as num) + (b as num));
          }
          return start;
        },

        /// Sorts a list, optionally by an attribute and in reverse order.
        'sort': (List? value, [bool reverse = false, String? attribute]) {
          try {
            if (value == null) return [];
            final list = List.from(value);
            list.sort((a, b) {
              if (attribute != null) {
                return a[attribute].toString().compareTo(
                      b[attribute].toString(),
                    );
              }
              return a.toString().compareTo(b.toString());
            });
            return reverse ? list.reversed.toList() : list;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value ?? [];
          }
        },

        /// Returns the sum of values in a list, optionally by attribute.
        'sum': (List? value, [String? attribute, double start = 0]) {
          try {
            if (value == null) return start;
            return value.fold<double>(start, (sum, item) {
              final val = attribute != null ? item[attribute] : item;
              return sum + (double.tryParse(val.toString()) ?? 0);
            });
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return start;
          }
        },

        /// Returns a list of unique items, optionally by attribute.
        'unique': (List? value, [String? attribute]) {
          try {
            if (value == null) return [];
            final seen = <dynamic>{};
            return value.where((item) {
              final key = attribute != null ? item[attribute] : item;
              if (seen.contains(key)) return false;
              seen.add(key);
              return true;
            }).toList();
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value ?? [];
          }
        },

        /// URL-encodes a string.
        'urlencode': (String? value) {
          try {
            return Uri.encodeComponent(value ?? '');
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return '';
          }
        },

        /// URL-decodes a string.
        'urldecode': (String? value) {
          try {
            return Uri.decodeComponent(value ?? '');
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return '';
          }
        },

        /// Converts a value to JSON string with optional indentation.
        'to_json': (dynamic value, [int? indent]) {
          try {
            final encoder = JsonEncoder.withIndent(' ' * (indent ?? 0));
            return encoder.convert(value);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value?.toString() ?? '';
          }
        },

        /// Parses a JSON string.
        'from_json': (String? value) {
          try {
            return jsonDecode(value ?? '{}');
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return {};
          }
        },

        /// Throws an exception if value is null.
        'mandatory': (dynamic value, {String? hint}) {
          if (value == null) {
            throw Exception(hint ?? 'Mandatory value is undefined');
          }
          return value;
        },

        /// Returns one of two values based on a boolean condition.
        'ternary': (
          bool? condition,
          dynamic trueValue, [
          dynamic falseValue,
          dynamic nullValue,
        ]) {
          try {
            if (condition == null) return nullValue ?? falseValue;
            return condition ? trueValue : falseValue;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return null;
          }
        },

        /// Returns the runtime type of the value.
        'type_debug': (dynamic value) => value.runtimeType.toString(),

        /// Converts a map to a list of key-value pair maps.
        'dict2items': (
          Map value, {
          String keyName = 'key',
          String valueName = 'value',
        }) {
          try {
            return value.entries.map((e) => {keyName: e.key, valueName: e.value}).toList();
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Converts a list of key-value pair maps to a map.
        'items2dict': (
          List items, {
          String keyName = 'key',
          String valueName = 'value',
        }) {
          try {
            return Map.fromEntries(
              items.map<MapEntry>((item) {
                if (item is Map) {
                  return MapEntry(
                    item[keyName].toString(),
                    item[valueName],
                  );
                }
                return const MapEntry('', null);
              }).where((e) => e.key.isNotEmpty),
            );
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return {};
          }
        },

        /// Flattens a nested list structure.
        'flatten': (List list, [int levels = 1]) {
          try {
            dynamic result = [];
            void flatten(dynamic l, int level) {
              if (level <= 0) {
                result.add(l);
                return;
              }
              if (l is List) {
                for (var item in l) {
                  flatten(item, level - 1);
                }
              } else {
                result.add(l);
              }
            }

            flatten(list, levels);
            return result;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Computes the Cartesian product of input iterables.
        'product': (List<dynamic> lists) {
          try {
            List<List<dynamic>> result = [[]];
            for (var pool in lists) {
              result = result
                  .expand(
                    (x) => (pool as List).map<List<dynamic>>((y) => [...x, y]),
                  )
                  .toList();
            }
            return result;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Returns successive r-length permutations of elements in the list.
        'permutations': (List items, [int? length]) {
          try {
            length ??= items.length;
            if (length <= 0 || items.isEmpty) return [];
            if (length == 1) return items.map((e) => [e]).toList();

            List<List<dynamic>> result = [];
            for (int i = 0; i < items.length; i++) {
              var first = items[i];
              for (var perm in items.sublist(i + 1)) {
                result.add([
                  first,
                  ...(perm is List ? perm : [perm]),
                ]);
              }
            }
            return result;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Returns r-length subsequences of elements from the input list.
        'combinations': (List items, int length) {
          try {
            if (length <= 0 || items.isEmpty || length > items.length) return [];
            if (length == items.length) return [List<dynamic>.from(items)];
            if (length == 1) return items.map((e) => [e]).toList();

            List<List<dynamic>> result = [];
            for (int i = 0; i <= items.length - length; i++) {
              var first = items[i];
              for (var c in items.sublist(i + 1)) {
                result.add([
                  first,
                  ...(c is List ? c : [c]),
                ]);
              }
            }
            return result;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Aggregates elements from each of the iterables.
        'zip': (List list1, List list2) {
          try {
            var result = [];
            var length = list1.length < list2.length ? list1.length : list2.length;
            for (var i = 0; i < length; i++) {
              result.add([list1[i], list2[i]]);
            }
            return result;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Aggregates elements, filling missing values with `fillvalue`.
        'zip_longest': (List list1, List list2, {dynamic fillvalue}) {
          try {
            var result = [];
            var maxLength = list1.length > list2.length ? list1.length : list2.length;
            for (var i = 0; i < maxLength; i++) {
              var item1 = i < list1.length ? list1[i] : fillvalue;
              var item2 = i < list2.length ? list2[i] : fillvalue;
              result.add([item1, item2]);
            }
            return result;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Generates a v4 UUID.
        'to_uuid': ([String? value]) {
          try {
            return value ?? const Uuid().v4();
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return const Uuid().v4();
          }
        },

        // 'hash': (String value, [String method = 'sha1']) {
        //   try {
        //     var bytes = utf8.encode(value);
        //     Digest digest;
        //     switch (method.toLowerCase()) {
        //       case 'md5':
        //         digest = md5.convert(bytes);
        //         break;
        //       case 'sha256':
        //         digest = sha256.convert(bytes);
        //         break;
        //       case 'sha512':
        //         digest = sha512.convert(bytes);
        //         break;
        //       case 'sha1':
        //       default:
        //         digest = sha1.convert(bytes);
        //     }
        //     return digest.toString();
        //   } catch (e) {
        //     valueListenableJinjaError(e.toString());
        //     return '';
        //   }
        // },

        /// Escapes special characters in a regex string.
        'regex_escape': (String value, [String? regexType]) {
          try {
            if (regexType == 'posix_basic') {
              return value.replaceAllMapped(
                RegExp(r'([\.^$*+?()\[\]{}|])'),
                (match) => '\\${match.group(0)}',
              );
            }
            return RegExp.escape(value);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },

        /// Searches for a regex pattern in a string and returns the first match.
        'regex_search': (
          String value,
          String pattern, [
          bool ignoreCase = false,
          bool multiline = false,
        ]) {
          try {
            var regex = RegExp(
              pattern,
              caseSensitive: !ignoreCase,
              multiLine: multiline,
            );
            var match = regex.firstMatch(value);
            return match?.group(0) ?? '';
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return '';
          }
        },

        /// Finds all non-overlapping matches of a regex pattern in a string.
        'regex_findall': (
          String value,
          String pattern, [
          bool ignoreCase = false,
          bool multiline = false,
        ]) {
          try {
            var regex = RegExp(
              pattern,
              caseSensitive: !ignoreCase,
              multiLine: multiline,
            );
            return regex.allMatches(value).map((m) => m.group(0)).toList();
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// AVOM: AI ADDED FILTERS

        /// Calculates the difference in days between two dates.
        'date_diff_days': (String startDate, String endDate) {
          const dateFormat = DateTime.parse;
          final start = dateFormat(startDate);
          final end = dateFormat(endDate);
          return end.difference(start).inDays;
        },

        /// Merges a JSON string or Map into an existing Map.
        'merge': (Map value, dynamic mergeValue) {
          try {
            if (mergeValue is String) {
              value.addAll(jsonDecode(mergeValue));
            } else {
              value.addAll(mergeValue);
            }
          } catch (e) {
            valueListenableJinjaError(e.toString());
          }
          return value;
        },

        /// Converts a value to its string representation or JSON string.
        'tostring': (dynamic value) {
          try {
            if (value is! String) {
              return jsonEncode(value);
            }
            return value;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },

        /// Flexible JSON conversion: parses string to JSON, or object to JSON object.
        'toJsonF': (dynamic value) {
          try {
            if (value is String) {
              final jsonValue = jsonDecode(value);
              return jsonValue;
            }
            try {
              if (value is Map) {
                return UtilFunctions.changeObjectToMap(value);
              } else if (value is List) {
                return List<Map<String, dynamic>>.from(value);
              } else {
                return jsonDecode(jsonEncode(value));
              }
            } catch (e) {
              valueListenableJinjaError(e.toString());
              return jsonDecode(jsonEncode(value));
            }
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },

        /// Splits a list into chunks of a specified size.
        'chunk': (List? list, int? size) {
          try {
            if (list == null || size == null) return [];
            return [
              for (var i = 0; i < list.length; i += size) list.sublist(i, (i + size).clamp(0, list.length)),
            ];
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Calculates statistics (max, min, sum) for a list of numeric values.
        'calculate_list_stats': (listOfValues, [String? key, String? path]) {
          List values = [];
          if (listOfValues is String) {
            values = jsonDecode(listOfValues);
          } else {
            values = listOfValues;
          }
          if (values.isEmpty) return {'max': null, 'min': null, 'sum': 0.0};

          final List<double> parsedValues = [];
          final Map<double, dynamic> valueMap = {};
          Object? pathValue;

          for (final item in values) {
            double? numValue;

            if (path != null) {
              final jsonQuery = JsonPath(path);
              final jsonPathMatch = jsonQuery.read(item);
              final responseOfQuery = jsonPathMatch.map((e) => e);
              pathValue = responseOfQuery.singleOrNull?.value;
            }
            if (pathValue != null) {
              if (pathValue is Map<String, dynamic> && key != null && (pathValue.containsKey(key))) {
                numValue = double.tryParse(
                  pathValue[key].toString().replaceAll(',', ''),
                );
              } else {
                numValue = double.tryParse(
                  pathValue.toString().replaceAll(',', ''),
                );
              }
            } else if (key != null && item is Map<String, dynamic> && (item.containsKey(key))) {
              numValue = double.tryParse(
                item[key].toString().replaceAll(',', ''),
              );
            } else if (key == null) {
              numValue = double.tryParse(item.toString().replaceAll(',', ''));
            }

            if (numValue != null) {
              parsedValues.add(numValue);
              valueMap[numValue] = item;
            }
          }

          if (parsedValues.isEmpty) return {'max': null, 'min': null, 'sum': 0.0};

          final double maxVal = parsedValues.reduce((a, b) => a > b ? a : b);
          final double minVal = parsedValues.reduce((a, b) => a < b ? a : b);
          final double sumVal = parsedValues.reduce((a, b) => a + b);

          final Map<String, dynamic> returnedMap = {
            'max': valueMap[maxVal] ?? maxVal,
            'min': valueMap[minVal] ?? minVal,
            'sum': sumVal,
          };

          return returnedMap;
        },

        /// Formats a number with a specific format pattern and locale.
        'format_number': (dynamic value, [String? format, String? locale]) {
          try {
            if (value == null) {
              return '0';
            }
            final NumberFormat numberFormat = NumberFormat(format, locale);
            final double parsedValue = double.tryParse(value.toString().replaceAll(',', '')) ?? 0;

            final int decimalPlaces = (format?.split('.').length ?? 0) > 1 ? (format?.split('.').last.length ?? 0) : 0;

            final String zeroValue = '0${decimalPlaces > 0 ? '.${'0' * decimalPlaces}' : ''}';
            final String formattedNumber = parsedValue == 0 ? zeroValue : numberFormat.format(parsedValue);
            return formattedNumber;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },

        /// Returns the length of a list, map, or string.
        'length': (dynamic value) {
          try {
            if (value is List) {
              return value.length;
            } else if (value is Map) {
              return value.length;
            } else {
              return value.toString().length;
            }
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return 0;
          }
        },

        // 'capitalize_letters': (String? value) {
        //   try {
        //     return value?.capitalizeAllWords();
        //   } catch (e) {
        //     valueListenableJinjaError(e.toString());
        //     return value;
        //   }
        // },

        /// Removes HTML tags from a string.
        'get_plain_text_from_html': (String? html) {
          try {
            return UtilFunctions.getPlainTextFromHtml(html ?? '');
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return html;
          }
        },

        /// Extracts filter options from a data map structure.
        'get_filter_map': (Map? data) {
          final result = <String, List<String>>{};
          data?.forEach((key, val) {
            // Check if the value is a valid map and contains the necessary structure
            if (val is Map && val.containsKey('value') && val['value'] is Map && (val['value'] as Map).containsKey('dropdown_items')) {
              final dropdownItems = (val['value']['dropdown_items'] as List).map((item) => item['id'] as String).toList();
              result[key] = dropdownItems;
            }
          });
          result.removeWhere((key, value) => value.isEmpty);
          return result;
        },

        /// Filters a list of maps based on a filter map criteria.
        'filter_map': (List? listOfMap, Map? filter) {
          final List result = [];
          bool isMatch = false;
          for (final map in listOfMap ?? []) {
            isMatch = true;
            filter?.forEach((key, value) {
              if (!value.contains(map[key])) {
                isMatch = false;
              }
            });
            if (isMatch) {
              result.add(map);
            }
          }
          return result;
        },

        /// Converts map entries to a list of key-value maps.
        'get_items_from_map': (Map<String, dynamic>? map) {
          try {
            return (map?.entries ?? []).map((entry) => {'key': entry.key, 'value': entry.value}).toList();
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Sorts a list of maps by multiple keys and optional order.
        'sort_by': (
          List? list,
          dynamic sortingKeys,
          dynamic order, // asc || desc
        ) {
          try {
            list?.sort((a, b) {
              for (final key in sortingKeys) {
                final valueA = a[key] ?? -1; // Treat missing keys as -1
                final valueB = b[key] ?? -1;

                if (valueA != valueB) {
                  // Higher values should come first
                  return valueB.compareTo(valueA);
                }
              }
              return 0; // If all keys are equal, keep the original order
            });
            if (order == 'desc') {
              list = list?.reversed.toList();
            }
            return list;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return list;
          }
        },

        /// Filters a list where multiple attributes match specified values.
        'selectattrmulti': (List list, List keys, List operators, List values) {
          try {
            // Ensure the input lists have the same length
            if (keys.length != values.length || keys.length != operators.length) {
              throw ArgumentError(
                'keys, operators, and values must have the same length.',
              );
            }

            // Filter the list
            final List result = list.where((item) {
              for (int i = 0; i < keys.length; i++) {
                final key = keys[i];
                final op = operators[i];
                final value = values[i];
                final itemValue = item[key];

                if (itemValue == null) {
                  return false; // Does not match if value is null
                }

                bool conditionMet = false;
                try {
                  switch (op) {
                    case '==':
                      conditionMet = (itemValue == value);
                      break;
                    case '!=':
                      conditionMet = (itemValue != value);
                      break;
                    case '>':
                      conditionMet = itemValue > value;
                      break;
                    case '<':
                      conditionMet = itemValue < value;
                      break;
                    case '>=':
                      conditionMet = itemValue >= value;
                      break;
                    case '<=':
                      conditionMet = itemValue <= value;
                      break;
                    default:
                      conditionMet = false;
                      break;
                  }
                } catch (e) {
                  // TypeError on comparison, treat as not a match
                  conditionMet = false;
                }

                if (!conditionMet) {
                  return false; // If any condition is not met, filter out this item
                }
              }

              return true; // All conditions were met
            }).toList();

            return result;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return list;
          }
        },

        /// Returns the first item in a list that matches an operator/value condition.
        'firstWhere': (dynamic list, dynamic key, dynamic operator, dynamic value) {
          try {
            // the function needs to loop through the list, check the key with the operator against the value
            List result = [];
            for (var item in list) {
              if (item[key] == null) {
                continue;
              }
              switch (operator) {
                case '==':
                  if (item[key] == value) {
                    result.add(item);
                  }
                  break;
                case '!=':
                  if (item[key] != value) {
                    result.add(item);
                  }
                  break;
                case '>':
                  if (item[key] > value) {
                    result.add(item);
                  }
                  break;
                case '<':
                  if (item[key] < value) {
                    result.add(item);
                  }
                  break;
                case '>=':
                  if (item[key] >= value) {
                    result.add(item);
                  }
                  break;
                case '<=':
                  if (item[key] <= value) {
                    result.add(item);
                  }
                  break;
                default:
                  break;
              }
            }
            return result.firstOrNull ?? '';
          } catch (e) {
            UtilFunctions.appLog(
              {
                'action': 'selectattr error in Jinja',
                'error': e.toString(),
                'list': list,
                'key': key,
                'operator': operator,
                'value': value,
              },
              logType: LogType.error,
            );
            return list;
          }
        },

        /// Rounds a number to a specified number of decimals.
        'round': (dynamic value, [int? decimals = 2]) {
          if (value is num) {
            return double.parse(value.toStringAsFixed(decimals ?? 2));
          }
          try {
            final parsedValue = double.parse(value.toString());
            return double.parse(parsedValue.toStringAsFixed(decimals ?? 2));
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },

        /// Parses a value to a double.
        'float': (dynamic value) {
          if (value is double) return value;
          try {
            value = value?.toString();
            if (value?.isNotEmpty ?? false) {
              if (value == '-') {
                return -1;
              }
              return double.parse(value.toString().replaceAll(',', ''));
            } else {
              return 0;
            }
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },

        /// Parses a value to an integer.
        'int': (dynamic value) {
          if (value is int) return value;
          try {
            if (value?.toString().isNotEmpty ?? false) {
              if (value == '-') {
                return -1;
              }
              return double.parse(value.toString().replaceAll(',', '')).toInt();
            } else {
              return 0;
            }
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },

        /// Finds the index of an item in a list where the 'by' attribute matches 'id'.
        'indexOfBy': (List? items, String? by, String? id) {
          try {
            return (items ?? []).indexWhere((item) => item[by ?? ''] == id);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return -1;
          }
        },

        /// Returns a slice of a list.
        'sublist': (List? items, int? start, [int? end]) {
          try {
            return (items ?? []).sublist((start ?? 0) + 1, end).toList();
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return items;
          }
        },

        /// Flexible boolean conversion.
        'toBool': (dynamic value) {
          try {
            if (value == '' || value == '0' || value == 0 || value == null || value == 'null' || value == 'false' || value == false) {
              return false;
            } else if (value == '1' || value == 1 || value == 'true' || value == true) {
              return true;
            } else {
              return false;
            }
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return false;
          }
        },

        /// Decodes a JSON string (filter version).
        'jsonDecode': (dynamic value) {
          try {
            return jsonDecode(value);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },

        /// Encodes a value to a JSON string (filter version).
        'jsonEncode': (dynamic value) {
          try {
            return UtilFunctions.jsonEncodeMethod(value);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },

        /// Checks if a string is Base64 encoded.
        'isb64': (String? value) {
          return UtilFunctions.isBase64(value ?? '');
        },

        /// Encodes a string to Base64.
        'b64encode': (String? value) {
          try {
            return UtilFunctions.encodeToBase64(value);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },

        /// Returns a substring of a string.
        'sub_string': (String? value, int? start, int? end) {
          try {
            return value?.substring(start ?? 0, end ?? 0);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return e.toString();
          }
        },

        /// Converts a value to a string.
        'to_string': (dynamic value) {
          try {
            return value.toString();
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return '';
          }
        },

        /// Splits a string by a delimiter.
        'split': ([String? a, String? b]) {
          try {
            return a?.split(b ?? '');
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },

        /// Formats a date string according to a Python or Dart date format.
        'date_format': (
          String? value,
          String? pythonDateFormat, [
          bool? isPythonFormat = false,
        ]) {
          if (value == null || pythonDateFormat == null) {
            return DateTime.now().toString();
          }
          // Convert Python format to Dart format
          final dartFormat = isPythonFormat == true ? convertPythonToDartDateFormat(pythonDateFormat) : pythonDateFormat;
          final inputFormat = DateFormat(
            dartFormat,
          ).format(DateTime.parse(value));
          return inputFormat;
        },

        /// Replaces occurrences of a character or substring in a string.
        'replace_each': (
          String? value,
          String? from,
          String? to, [
          int? count,
        ]) {
          if (count == null) {
            for (final element in from?.split('').toList() ?? []) {
              value = value?.replaceAll(element, to ?? '');
            }
          } else {
            final start = value?.indexOf(from ?? '');
            var n = 0;

            while (n < count && (start ?? 0) != -1 && (start ?? 0) < (value?.length ?? 0)) {
              var start = value?.indexOf(from ?? '');
              value = value?.replaceRange(
                start ?? 0,
                (start ?? 0) + (from?.length ?? 0),
                to ?? '',
              );
              start = value?.indexOf(
                from ?? '',
                (start ?? 0) + (to?.length ?? 0),
              );
              n += 1;
            }
          }

          return value;
        },

        /// Replaces matches of a regex pattern in a string.
        'regex_replace': (String? value, String? from, String? to) {
          try {
            final RegExp regex = RegExp(from ?? '');

            final decodedString = value?.replaceAll(regex, to ?? '');

            return decodedString;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },

        // --- NEW FILTERS IMPLEMENTED FROM JINJA_FILTERS.md ---

        /// Return the absolute value of the argument.
        'abs': (dynamic value) => value is num ? value.abs() : value,

        /// Return true if none of the elements of the iterable are false.
        'all': (List? list) {
          if (list == null) return true;
          return list.every((e) {
            if (e == null || e == false || e == 0 || e == '') return false;
            return true;
          });
        },

        /// Returns true if any item in an iterable is true, otherwise false.
        'any': (List? list) {
          if (list == null) return false;
          return list.any((e) {
            if (e == null || e == false || e == 0 || e == '') return false;
            return true;
          });
        },

        /// Convert a datetime object to a different timezone.
        'as_timezone': (dynamic val, String tz) {
          // Placeholder: Timezone conversion requires 'timezone' package
          return val;
        },

        /// Get an attribute of an object.
        'attr': (dynamic obj, String name) {
          if (obj is Map) return obj[name];
          return null;
        },

        /// Encode a string in base64.
        'base64': (String? value) => UtilFunctions.encodeToBase64(value),

        /// Get the last name of a windows style file path.
        'basename': (String path) => p.basename(path),

        /// Batches items. Returns a list of lists with the given number of items.
        'batch': (List list, int count, [dynamic fill]) {
          List<List> result = [];
          for (var i = 0; i < list.length; i += count) {
            var end = (i + count < list.length) ? i + count : list.length;
            var chunk = list.sublist(i, end);
            if (fill != null && chunk.length < count) {
              chunk.addAll(List.filled(count - chunk.length, fill));
            }
            result.add(chunk);
          }
          return result;
        },

        /// Capitalize a value. The first character will be uppercase, all others lowercase.
        'capitalize': (String? s) {
          if (s == null || s.isEmpty) return '';
          return s[0].toUpperCase() + s.substring(1).toLowerCase();
        },

        /// Centers the value in a field of a given width.
        'center': (String? s, int width, [String fill = ' ']) {
          if (s == null) return '';
          if (s.length >= width) return s;
          int left = (width - s.length) ~/ 2;
          int right = width - s.length - left;
          return (fill * left) + s + (fill * right);
        },

        /// Convert an epoch timestamp to a datetime object.
        'convert_from_epoch': (int? epoch) {
          if (epoch == null) return null;
          return DateTime.fromMillisecondsSinceEpoch(epoch * 1000).toString();
        },

        /// Dump a list of rows to CSV format.
        'csv': (List? rows) {
          if (rows == null) return '';
          return rows.map((row) {
            if (row is List) return row.join(',');
            return row.toString();
          }).join('\n');
        },

        /// Return the number of items in a container.
        'count': (dynamic val, dynamic item) {
          if (val is String) return val.split(item.toString()).length - 1;
          if (val is List) return val.where((e) => e == item).length;
          return 0;
        },

        /// Alias for default. If value is undefined, returns default value.
        'd': (dynamic value, dynamic defaultValue) => value ?? defaultValue,

        /// Add or subtract a number of years, months, weeks, or days from a datetime.
        'datedelta': (
          String? dateStr, {
          int days = 0,
          int hours = 0,
          int minutes = 0,
        }) {
          if (dateStr == null) return null;
          try {
            final date = DateTime.parse(dateStr);
            return date.add(Duration(days: days, hours: hours, minutes: minutes)).toString();
          } catch (e) {
            return dateStr;
          }
        },

        /// Decode a base64-encoded string and return it as a UTF-8 string.
        'decode_base64': (String? value) => UtilFunctions.decodeFromBase64(value ?? ''),

        /// Transforms lists into dictionaries.
        'dict': (dynamic value) {
          if (value is List) {
            try {
              final map = <dynamic, dynamic>{};
              for (var item in value) {
                if (item is List && item.length >= 2) {
                  map[item[0]] = item[1];
                }
              }
              return map;
            } catch (e) {
              return {};
            }
          }
          return {};
        },

        /// Get the directory from a path.
        'dirname': (String path) => p.dirname(path),

        /// Alias for escape. Replace characters with HTML-safe sequences.
        'e': (String? s) => const HtmlEscape().convert(s ?? ''),

        /// Replace characters with HTML-safe sequences.
        'escape': (String? s) => const HtmlEscape().convert(s ?? ''),

        /// Enforce HTML escaping.
        'forceescape': (String? s) => const HtmlEscape().convert(s ?? ''),

        /// Iterate with index and element.
        'enumerate': (List? list) {
          if (list == null) return [];
          return list.asMap().entries.map((e) => [e.key, e.value]).toList();
        },

        /// Apply values to a printf-style format string.
        'format': (
          String? s, [
          dynamic arg1,
          dynamic arg2,
          dynamic arg3,
          dynamic arg4,
        ]) {
          if (s == null) return '';
          String res = s;
          List args = [arg1, arg2, arg3, arg4].where((e) => e != null).toList();
          for (var arg in args) {
            res = res.replaceFirst('{}', arg.toString());
          }
          return res;
        },

        /// Return a string representation of a datetime in a particular format.
        'format_datetime': (String? dateStr, String fmt) {
          if (dateStr == null) return '';
          try {
            final date = DateTime.parse(dateStr);
            final dartFmt = convertPythonToDartDateFormat(fmt);
            return DateFormat(dartFmt).format(date);
          } catch (e) {
            return dateStr;
          }
        },

        /// Deserialize from a JSON-serialized string.
        'from_json_string': (String? value) {
          try {
            return jsonDecode(value ?? '{}');
          } catch (e) {
            return {};
          }
        },

        /// Returns hex representations of bytes objects and UTF-8 strings.
        'hex': (dynamic val) {
          if (val is int) return '0x${val.toRadixString(16)}';
          if (val is String) {
            return val.codeUnits.map((c) => c.toRadixString(16)).join();
          }
          return '';
        },

        /// Return the bytes digest of the HMAC.
        'hmac': (String? str, String? secret) {
          // Placeholder: HMAC requires 'crypto' package
          return str ?? '';
        },

        /// Return a copy of the string with each line indented.
        'indent': (String? s, int width, [bool first = false]) {
          if (s == null) return '';
          final indentStr = ' ' * width;
          final lines = s.split('\n');
          final res = lines.map((l) => '$indentStr$l').join('\n');
          return first ? res : (lines.isNotEmpty ? '${lines.first}\n${lines.sublist(1).map((l) => '$indentStr$l').join('\n')}' : '');
        },

        /// Determines whether or not a string can be converted to a JSON object.
        'is_json': (String? s) {
          if (s == null) return false;
          try {
            jsonDecode(s);
            return true;
          } catch (e) {
            return false;
          }
        },

        /// Checks the type of the object.
        'is_type': (dynamic val, String type) {
          switch (type) {
            case 'int':
              return val is int;
            case 'float':
              return val is double;
            case 'string':
              return val is String;
            case 'bool':
              return val is bool;
            case 'list':
              return val is List;
            case 'map':
              return val is Map;
            default:
              return false;
          }
        },

        /// Return an iterator over the (key, value) items of a mapping.
        'items': (Map? m) => m?.entries.map((e) => [e.key, e.value]).toList() ?? [],

        /// Parse a JSON-serialized string.
        'json': (String? s) {
          try {
            return jsonDecode(s ?? '{}');
          } catch (e) {
            return {};
          }
        },

        /// Serialize value to JSON.
        'json_dump': (dynamic val) => jsonEncode(val),

        /// Deserialize from a JSON-serialized string.
        'json_parse': (String? s) {
          try {
            return jsonDecode(s ?? '{}');
          } catch (e) {
            return {};
          }
        },

        /// Serialize value to JSON.
        'json_stringify': (dynamic val) => jsonEncode(val),

        /// Extracts data from an object value using a JSONPath query.
        'jsonpath_query': (dynamic json, String query) {
          if (json is! Map<String, dynamic>) return null;
          try {
            final jsonQuery = JsonPath(query);
            final jsonPathMatch = jsonQuery.read(json);
            return jsonPathMatch.map((e) => e.value).firstOrNull;
          } catch (e) {
            return null;
          }
        },

        /// Parse a datetime string with a known format.
        'load_datetime': (String? s) {
          if (s == null) return null;
          try {
            return DateTime.parse(s).toString();
          } catch (e) {
            return null;
          }
        },

        /// Convert a value to lowercase.
        'lower': (String? s) => s?.toLowerCase() ?? '',

        /// Parse a CSV string into a list of dicts.
        'parse_csv': (String? csv) {
          if (csv == null) return [];
          final lines = csv.split('\n');
          if (lines.isEmpty) return [];
          final headers = lines.first.split(',');
          final result = <Map<String, String>>[];
          for (var i = 1; i < lines.length; i++) {
            final values = lines[i].split(',');
            if (values.length == headers.length) {
              final row = <String, String>{};
              for (var j = 0; j < headers.length; j++) {
                row[headers[j].trim()] = values[j].trim();
              }
              result.add(row);
            }
          }
          return result;
        },

        /// Parse a datetime string without knowing its format specification.
        'parse_datetime': (String? s) {
          if (s == null) return null;
          try {
            return DateTime.parse(s).toString();
          } catch (e) {
            return null;
          }
        },

        /// Pretty print a variable.
        'pprint': (dynamic val) => const JsonEncoder.withIndent('  ').convert(val),

        /// Determine if a string matches a particular pattern.
        'regex_match': (String? value, String pattern) {
          if (value == null) return false;
          return RegExp(pattern).hasMatch(value);
        },

        /// Find substrings match a pattern and return substring at index.
        'regex_substring': (String? value, String pattern, [int group = 0]) {
          if (value == null) return '';
          final match = RegExp(pattern).firstMatch(value);
          return match?.group(group) ?? '';
        },

        /// Replace occurrences of a substring with a new one.
        'replace': (String? s, String from, String to) => s?.replaceAll(from, to) ?? '',

        /// Reverse the object.
        'reverse': (dynamic val) {
          if (val is List) return val.reversed.toList();
          if (val is String) return val.split('').reversed.join();
          return val;
        },

        /// Mark the value as safe (no escaping).
        'safe': (String? s) => s,

        /// Create a set from an iterable.
        'set': (Iterable? val) => val?.toSet().toList() ?? [],

        /// Slice an iterator and return a list of lists.
        'slice': (List? list, int slices) {
          if (list == null) return [];
          int length = list.length;
          int itemsPerSlice = (length / slices).ceil();
          List<List> res = [];
          for (var i = 0; i < length; i += itemsPerSlice) {
            res.add(list.sublist(i, min(i + itemsPerSlice, length)));
          }
          return res;
        },

        /// Convert an object to a string.
        'string': (dynamic val) => val.toString(),

        /// Strip SGML/XML tags.
        'striptags': (String? s) => s?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '',

        /// Add a duration of time to a datetime.
        'time_delta': (String? dateStr, {int days = 0, int hours = 0}) {
          if (dateStr == null) return null;
          try {
            final date = DateTime.parse(dateStr);
            return date.add(Duration(days: days, hours: hours)).toString();
          } catch (e) {
            return dateStr;
          }
        },

        /// Return a titlecased version of the value.
        'title': (String? s) {
          if (s == null) return '';
          return s
              .split(' ')
              .map(
                (word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '',
              )
              .join(' ');
        },

        /// Transliterate a Unicode object into an ASCII string.
        'to_ascii': (String? s) => s, // Placeholder

        /// Transliterate Unicode to ASCII.
        'unidecode': (String? s) => s, // Placeholder

        /// Returns a fuzzy version of time from seconds.
        'to_human_time_from_seconds': (int? seconds) {
          if (seconds == null) return '';
          final duration = Duration(seconds: seconds);
          return duration.toString().split('.').first;
        },

        /// Serialize value to JSON.
        'to_json_string': (dynamic val) => jsonEncode(val),

        /// Strip leading and trailing whitespace.
        'trim': (String? s) => s?.trim() ?? '',

        /// Return a truncated copy of the string.
        'truncate': (
          String? s,
          int length, [
          bool killwords = false,
          String end = '...',
        ]) {
          if (s == null) return '';
          if (s.length <= length) return s;
          if (killwords) {
            return s.substring(0, length - end.length) + end;
          }
          return s.substring(0, length - end.length) + end;
        },

        /// Create a tuple from an iterable.
        'tuple': (List? l) => l ?? [],

        /// Convert a value to uppercase.
        'upper': (String? s) => s?.toUpperCase() ?? '',

        /// Convert URLs in text into clickable links.
        'urlize': (String? s) {
          if (s == null) return '';
          final urlRegex = RegExp(r'https?://[^\s]+');
          return s.replaceAllMapped(
            urlRegex,
            (match) => '<a href="${match.group(0)}">${match.group(0)}</a>',
          );
        },

        /// Convert None value to magic string.
        'use_none': (dynamic val) => val ?? 'None',

        /// Increment major version.
        'version_bump_major': (String? v) {
          if (v == null) return null;
          final parts = v.split('.');
          if (parts.isNotEmpty) {
            int major = int.tryParse(parts[0]) ?? 0;
            return '${major + 1}.0.0';
          }
          return v;
        },

        /// Increment minor version.
        'version_bump_minor': (String? v) {
          if (v == null) return null;
          final parts = v.split('.');
          if (parts.length >= 2) {
            int minor = int.tryParse(parts[1]) ?? 0;
            return '${parts[0]}.${minor + 1}.0';
          }
          return v;
        },

        /// Increment patch version.
        'version_bump_patch': (String? v) {
          if (v == null) return null;
          final parts = v.split('.');
          if (parts.length >= 3) {
            int patch = int.tryParse(parts[2]) ?? 0;
            return '${parts[0]}.${parts[1]}.${patch + 1}';
          }
          return v;
        },

        /// Compare two version numbers.
        'version_compare': (String? v1, String? v2) {
          return (v1 ?? '').compareTo(v2 ?? '');
        },

        /// Check if version equals pattern.
        'version_equal': (String? v1, String? v2) => v1 == v2,

        /// Check if version is less than pattern.
        'version_less_than': (String? v1, String? v2) => (v1 ?? '').compareTo(v2 ?? '') < 0,

        /// Check if version is greater than pattern.
        'version_more_than': (String? v1, String? v2) => (v1 ?? '').compareTo(v2 ?? '') > 0,

        /// Remove patch version component.
        'version_strip_patch': (String? v) {
          if (v == null) return null;
          final parts = v.split('.');
          if (parts.length >= 2) return '${parts[0]}.${parts[1]}';
          return v;
        },

        /// Count the words in the string.
        'wordcount': (String? s) => s?.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length ?? 0,

        /// Wrap a string to the given width.
        'wordwrap': (String? s, int width) {
          if (s == null) return '';
          return wrap(s, width: width).join('\n');
        },

        /// Wrap text to a specified width with newlines.
        'wrap_text': (String? s, int width) => wrap(s ?? '', width: width).join('\n'),

        /// Create an SGML/XML attribute string from a dict.
        'xmlattr': (Map? m) {
          if (m == null) return '';
          return m.entries.map((e) => '${e.key}="${e.value}"').join(' ');
        },

        /// Serialize to YAML.
        'yaml_dump': (dynamic val) => val.toString(), // Placeholder

        /// Deserialize from a YAML-serialized string.
        'yaml_parse': (String? s) => s, // Placeholder
      },
    );
  }
}
