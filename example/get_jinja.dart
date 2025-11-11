import 'dart:convert';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:jinja/jinja.dart';
import 'package:json_path/json_path.dart';
import 'package:uuid/uuid.dart';

// Mock BuildContext for standalone usage
class MockBuildContext {}

enum LogType {
  info,
  warning,
  error,
}

// Mock UtilFunctions for standalone usage
class UtilFunctions {
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
  }) {
    return Environment(
      globals: <String, Object?>{
        'translate': translateSync,
        'uuid': () {
          final String uniqueId = const Uuid().v4();
          return uniqueId;
        },
        'get_current_date': () {
          return {
            'value': UtilFunctions.formatDate(
              DateFormat('dd/MM/yyyy').format(DateTime.now()),
            ),
            'value_text': DateFormat('dd/MM/yyyy').format(DateTime.now()),
          };
        },
        'generate_list': (int count, [String? values]) {
          try {
            return List.generate(count, (index) => values ?? '');
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },
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
        'getWidgetWidth': () {},
        'getWidgetHeight': () {},
        'getScreenWidth': () => UtilFunctions.getScreenWidth(context),
        'getScreenHeight': () => UtilFunctions.getScreenHeight(context),
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
        'get': (dynamic json, String key, [dynamic defaultValue = '']) {
          try {
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

        /// AVOM: AI ADDED FILTERS
        'b64decode': (String? value) {
          try {
            return UtilFunctions.decodeFromBase64(value ?? '').toString();
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value ?? '';
          }
        },
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
        'combine': (Map value, Map combineValue) {
          try {
            return {...value, ...combineValue};
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },
        'default': (dynamic value, dynamic defaultValue) {
          return value ?? defaultValue;
        },
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
        'first': (List? value) {
          try {
            return value?.isNotEmpty == true ? value?.first : null;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return null;
          }
        },
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
        'join': (List? value, [String separator = '']) {
          try {
            return value?.map((e) => e.toString()).join(separator) ?? '';
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return '';
          }
        },
        'last': (List? value) {
          try {
            return value?.isNotEmpty == true ? value?.last : null;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return null;
          }
        },
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
        'map': (List? value, String attribute) {
          try {
            return value?.map((e) => e[attribute]).toList() ?? [];
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },
        'max': (List? value) {
          try {
            if (value?.isEmpty ?? true) return null;
            return value?.reduce((a, b) => (a > b) ? a : b);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return null;
          }
        },
        'min': (List? value) {
          try {
            if (value?.isEmpty ?? true) return null;
            return value?.reduce((a, b) => (a < b) ? a : b);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return null;
          }
        },
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
        'reject': (List? value, String attribute) {
          try {
            return value?.where((e) => !e[attribute]).toList() ?? [];
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },
        'rejectattr': (List? value, String attribute) {
          try {
            return value?.where((e) => !e[attribute]).toList() ?? [];
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },
        'select': (List? value, String attribute) {
          try {
            return value?.where((e) => e[attribute] == true).toList() ?? [];
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },
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
        'urlencode': (String? value) {
          try {
            return Uri.encodeComponent(value ?? '');
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return '';
          }
        },
        'urldecode': (String? value) {
          try {
            return Uri.decodeComponent(value ?? '');
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return '';
          }
        },
        'to_json': (dynamic value, [int? indent]) {
          try {
            final encoder = JsonEncoder.withIndent(' ' * (indent ?? 0));
            return encoder.convert(value);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value?.toString() ?? '';
          }
        },
        'from_json': (String? value) {
          try {
            return jsonDecode(value ?? '{}');
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return {};
          }
        },
        'mandatory': (dynamic value, {String? hint}) {
          if (value == null) {
            throw Exception(hint ?? 'Mandatory value is undefined');
          }
          return value;
        },
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
        'type_debug': (dynamic value) => value.runtimeType.toString(),
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
        'date_diff_days': (String startDate, String endDate) {
          const dateFormat = DateTime.parse;
          final start = dateFormat(startDate);
          final end = dateFormat(endDate);
          return end.difference(start).inDays;
        },
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
        'toJsonF': (dynamic value) {
          try {
            if (value is String) {
              final jsonValue = jsonDecode(value);
              return jsonValue;
            }
            try {
              return UtilFunctions.changeObjectToMap(value);
            } catch (e) {
              valueListenableJinjaError(e.toString());
              return jsonDecode(jsonEncode(value));
            }
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },
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
        'get_plain_text_from_html': (String? html) {
          try {
            return UtilFunctions.getPlainTextFromHtml(html ?? '');
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return html;
          }
        },
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
        'get_items_from_map': (Map<String, dynamic>? map) {
          try {
            return (map?.entries ?? []).map((entry) => {'key': entry.key, 'value': entry.value}).toList();
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },
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
        'selectattr': (dynamic list, dynamic key, dynamic operator, dynamic value) {
          try {
            // the function needs to loop through the list, check the key with the operator against the value
            final List result = [];
            for (final item in list) {
              // if (item[key] == null) {
              //   continue;
              // }
              switch (operator) {
                case '==':
                  if (item[key] == value) {
                    result.add(item);
                  }
                case '!=':
                  if (item[key] != value) {
                    result.add(item);
                  }
                case '>':
                  if (item[key] > value) {
                    result.add(item);
                  }
                case '<':
                  if (item[key] < value) {
                    result.add(item);
                  }
                case '>=':
                  if (item[key] >= value) {
                    result.add(item);
                  }
                case '<=':
                  if (item[key] <= value) {
                    result.add(item);
                  }
                default:
                  break;
              }
            }
            return result;
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return list;
          }
        },
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
        'indexOfBy': (List? items, String? by, String? id) {
          try {
            return (items ?? []).indexWhere((item) => item[by ?? ''] == id);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return -1;
          }
        },
        'sublist': (List? items, int? start, [int? end]) {
          try {
            return (items ?? []).sublist((start ?? 0) + 1, end).toList();
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return items;
          }
        },
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
        'jsonDecode': (dynamic value) {
          try {
            return jsonDecode(value);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },
        'jsonEncode': (dynamic value) {
          try {
            return UtilFunctions.jsonEncodeMethod(value);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },
        'isb64': (String? value) {
          return UtilFunctions.isBase64(value ?? '');
        },
        'b64encode': (String? value) {
          try {
            return UtilFunctions.encodeToBase64(value);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return value;
          }
        },
        'sub_string': (String? value, int? start, int? end) {
          try {
            return value?.substring(start ?? 0, end ?? 0);
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return e.toString();
          }
        },
        'to_string': (dynamic value) {
          try {
            return value.toString();
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return '';
          }
        },
        'split': ([String? a, String? b]) {
          try {
            return a?.split(b ?? '');
          } catch (e) {
            valueListenableJinjaError(e.toString());
            return [];
          }
        },
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
      },
    );
  }
}
