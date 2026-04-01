// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:jinja/jinja.dart';

import '../get_jinja.dart';

void main() async {
  try {
    final errors = <String?>[];
    final nativeTypesIn = await File('data-types/examples/native_types_in.jinja').readAsString();
    final slideoverIn = await File(
      'data-types/examples/app_jinja_ide/slideover_in.jinja',
    ).readAsString();
    final containerTypesIn = await File(
      'data-types/examples/app_jinja_ide/list_in.jinja',
    ).readAsString();
    final headerIn = await File(
      'data-types/examples/app_jinja_ide/header_in.jinja',
    ).readAsString();
    final agentListIn = await File(
      'data-types/examples/app_jinja_ide/agent_list_in.jinja',
    ).readAsString();
    final storeIn = await File(
      'data-types/examples/app_jinja_store/store_in.jinja',
    ).readAsString();
    final cardIn = await File(
      'data-types/examples/html_widgets/card_in.jinja',
    ).readAsString();
    final userSummaryIn = await File(
      'data-types/examples/html_widgets/user_summary_in.jinja',
    ).readAsString();
    final eventsIn = await File(
      'data-types/examples/other/events_in.jinja',
    ).readAsString();
    final nativeTypesOut = await File(
      'data-types/examples/native_types_out.json',
    ).readAsString();
    final slideoverOut = await File(
      'data-types/examples/app_jinja_ide/slideover_out.json',
    ).readAsString();
    final containerTypesOut = await File(
      'data-types/examples/app_jinja_ide/list_out.json',
    ).readAsString();
    final headerOut = await File(
      'data-types/examples/app_jinja_ide/header_out.json',
    ).readAsString();
    final agentListOut = await File(
      'data-types/examples/app_jinja_ide/agent_list_out.json',
    ).readAsString();
    final storeOut = await File(
      'data-types/examples/app_jinja_store/store_out.json',
    ).readAsString();
    final cardOut = await File(
      'data-types/examples/html_widgets/card_out.json',
    ).readAsString();
    final userSummaryOut = await File(
      'data-types/examples/html_widgets/user_summary_in_out.json',
    ).readAsString();
    final eventsOut = await File(
      'data-types/examples/other/events_out.json',
    ).readAsString();
    final slideoverOutFlatten = await File(
      'data-types/examples/app_jinja_ide/slideover_out_flatten.json',
    ).readAsString();
    final containerTypesOutFlatten = await File(
      'data-types/examples/app_jinja_ide/list_out_flatten.json',
    ).readAsString();
    final headerOutFlatten = await File(
      'data-types/examples/app_jinja_ide/header_out_flatten.json',
    ).readAsString();
    final agentListOutFlatten = await File(
      'data-types/examples/app_jinja_ide/agent_list_out_flatten.json',
    ).readAsString();
    final storeOutFlatten = await File(
      'data-types/examples/app_jinja_store/store_out_flatten.json',
    ).readAsString();
    final cardOutFlatten = await File(
      'data-types/examples/html_widgets/card_out_flatten.json',
    ).readAsString();
    final userSummaryOutFlatten = await File(
      'data-types/examples/html_widgets/user_summary_in_out_flatten.json',
    ).readAsString();
    final eventsOutFlatten = await File(
      'data-types/examples/other/events_out_flatten.json',
    ).readAsString();
    final viewsTemplate = await File('data-types/jinja/views.jinja').readAsString();
    final nativeTypesTemplate = await File(
      'data-types/jinja/native_types.jinja',
    ).readAsString();
    final mediaTypesTemplate = await File(
      'data-types/jinja/media_types.jinja',
    ).readAsString();
    final containerTypesTemplate = await File(
      'data-types/jinja/app_jinja_ide/list.jinja',
    ).readAsString();
    final slideoverTemplate = await File(
      'data-types/jinja/app_jinja_ide/slideover.jinja',
    ).readAsString();
    final headerTemplate = await File(
      'data-types/jinja/app_jinja_ide/header.jinja',
    ).readAsString();
    final agentListTemplate = await File(
      'data-types/jinja/app_jinja_ide/agent_list.jinja',
    ).readAsString();
    final listEventsTemplate = await File(
      'data-types/jinja/app_jinja_ide/list_events.jinja',
    ).readAsString();
    final storeTemplate = await File(
      'data-types/jinja/app_jinja_store/store.jinja',
    ).readAsString();
    final cardTemplate = await File(
      'data-types/jinja/html_widgets/card.jinja',
    ).readAsString();
    final userSummaryTemplate = await File(
      'data-types/jinja/html_widgets/user_summary.jinja',
    ).readAsString();
    final eventsTemplate = await File(
      'data-types/jinja/other/events.jinja',
    ).readAsString();
    final macroToggleTemplate = await File(
      'example/data_types/macro_toggle.jinja',
    ).readAsString();

    // Setup MapLoader with base templates for inheritance and inclusion
    final loader = MapLoader(
      {
        'views.jinja': viewsTemplate,
        'slideover.jinja': slideoverTemplate,
        'app_jinja_ide/slideover.jinja': slideoverTemplate,
        'native_types.jinja': nativeTypesTemplate,
        'media_types.jinja': mediaTypesTemplate,
        'container_types.jinja': containerTypesTemplate,
        'app_jinja_ide/list.jinja': containerTypesTemplate,
        'app_jinja_ide/header.jinja': headerTemplate,
        'app_jinja_ide/agent_list.jinja': agentListTemplate,
        'app_jinja_ide/list_events.jinja': listEventsTemplate,
        'app_jinja_store/store.jinja': storeTemplate,
        'html_widgets/card.jinja': cardTemplate,
        'html_widgets/user_summary.jinja': userSummaryTemplate,
        'other/events.jinja': eventsTemplate,
        'macro_toggle.jinja': macroToggleTemplate,
      },
      globalJinjaData: {},
    );
    final env = GetJinja.environment(
      MockBuildContext(),
      loader,
      //   enableJinjaDebugLogging: true,
      valueListenableJinjaError: (error) {
        print('Jinja Error: $error');
        errors.add(error);
      },
      callbackToParentProject: ({required payload}) async {},
      // enableJinjaDebugLogging: true,
    );
    // Example 1: native_types_in.jinja
    print('\n=== Example 1: native_types_in.jinja ===');
    final template4 = env.fromString(nativeTypesIn);
    String resultOfJinjaScript = await template4.renderAsync();
    print('Result length: ${resultOfJinjaScript.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(resultOfJinjaScript.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    jsonDecode(resultOfJinjaScript);
    assertJsonMatchesGolden(
      name: 'native_types_in.jinja',
      actualJson: resultOfJinjaScript,
      expectedJson: nativeTypesOut,
    );
    // Example 2: slideover_in.jinja
    print('\n=== Example 2: slideover_in.jinja ===');
    final template5 = env.fromString(slideoverIn);
    resultOfJinjaScript = await template5.renderAsync();
    print('Result length: ${resultOfJinjaScript.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(resultOfJinjaScript.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    jsonDecode(resultOfJinjaScript);
    assertJsonMatchesGolden(
      name: 'slideover_in.jinja',
      actualJson: resultOfJinjaScript,
      expectedJson: slideoverOut,
    );
    final slideoverFlatten = jsonEncode(
      _flattenDataType(jsonDecode(resultOfJinjaScript)),
    );
    print('Flatten result length: ${slideoverFlatten.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(slideoverFlatten.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    assertJsonMatchesGolden(
      name: 'slideover_out_flatten.json',
      actualJson: slideoverFlatten,
      expectedJson: slideoverOutFlatten,
    );
    // Example 3: container_types_in.jinja
    print('\n=== Example 3: container_types_in.jinja ===');
    final template6 = env.fromString(containerTypesIn);
    resultOfJinjaScript = await template6.renderAsync();
    print('Result length: ${resultOfJinjaScript.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(resultOfJinjaScript.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    jsonDecode(resultOfJinjaScript);
    assertJsonMatchesGolden(
      name: 'container_types_in.jinja',
      actualJson: resultOfJinjaScript,
      expectedJson: containerTypesOut,
    );
    final containerTypesFlatten = jsonEncode(
      _flattenDataType(jsonDecode(resultOfJinjaScript)),
    );
    print('Flatten result length: ${containerTypesFlatten.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(containerTypesFlatten.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    assertJsonMatchesGolden(
      name: 'container_types_out_flatten.json',
      actualJson: containerTypesFlatten,
      expectedJson: containerTypesOutFlatten,
    );
    // Example 4: header_in.jinja
    print('\n=== Example 4: header_in.jinja ===');
    final template7 = env.fromString(headerIn);
    resultOfJinjaScript = await template7.renderAsync();
    print('Result length: ${resultOfJinjaScript.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(resultOfJinjaScript.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    jsonDecode(resultOfJinjaScript);
    assertJsonMatchesGolden(
      name: 'header_in.jinja',
      actualJson: resultOfJinjaScript,
      expectedJson: headerOut,
    );
    final headerFlatten = jsonEncode(
      _flattenDataType(jsonDecode(resultOfJinjaScript)),
    );
    print('Flatten result length: ${headerFlatten.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(headerFlatten.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    assertJsonMatchesGolden(
      name: 'header_out_flatten.json',
      actualJson: headerFlatten,
      expectedJson: headerOutFlatten,
    );
    // Example 5: store_in.jinja
    print('\n=== Example 5: store_in.jinja ===');
    final template8 = env.fromString(storeIn);
    resultOfJinjaScript = await template8.renderAsync();
    print('Result length: ${resultOfJinjaScript.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(resultOfJinjaScript.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    jsonDecode(resultOfJinjaScript);
    assertJsonMatchesGolden(
      name: 'store_in.jinja',
      actualJson: resultOfJinjaScript,
      expectedJson: storeOut,
    );
    final storeFlatten = jsonEncode(
      _flattenDataType(jsonDecode(resultOfJinjaScript)),
    );
    print('Flatten result length: ${storeFlatten.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(storeFlatten.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    assertJsonMatchesGolden(
      name: 'store_out_flatten.json',
      actualJson: storeFlatten,
      expectedJson: storeOutFlatten,
    );
    jsonDecode(resultOfJinjaScript);
    // Example 9: agent_list_in.jinja
    print('\n=== Example 9: agent_list_in.jinja ===');
    final template12 = env.fromString(agentListIn);
    resultOfJinjaScript = await template12.renderAsync();
    print('Result length: ${resultOfJinjaScript.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(resultOfJinjaScript.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    final agentListJson = jsonDecode(resultOfJinjaScript) as Map<String, dynamic>;
    if (agentListJson['data_type'] != 'dt_object') {
      throw StateError('agent_list_in.jinja did not return dt_object');
    }
    assertJsonMatchesGolden(
      name: 'agent_list_in.jinja',
      actualJson: resultOfJinjaScript,
      expectedJson: agentListOut,
    );
    final agentListFlatten = jsonEncode(
      _flattenDataType(jsonDecode(resultOfJinjaScript)),
    );
    print('Flatten result length: ${agentListFlatten.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(agentListFlatten.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    assertJsonMatchesGolden(
      name: 'agent_list_out_flatten.json',
      actualJson: agentListFlatten,
      expectedJson: agentListOutFlatten,
    );
    // Example 10: card_in.jinja
    print('\n=== Example 10: card_in.jinja ===');
    final template13 = env.fromString(cardIn);
    resultOfJinjaScript = await template13.renderAsync();
    print('Result length: ${resultOfJinjaScript.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(resultOfJinjaScript.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    final cardJson = jsonDecode(resultOfJinjaScript) as Map<String, dynamic>;
    if (cardJson['data_type'] != 'dt_object') {
      throw StateError('card_in.jinja did not return dt_object');
    }
    assertJsonMatchesGolden(
      name: 'card_in.jinja',
      actualJson: resultOfJinjaScript,
      expectedJson: cardOut,
    );
    final cardFlatten = jsonEncode(
      _flattenDataType(jsonDecode(resultOfJinjaScript)),
    );
    print('Flatten result length: ${cardFlatten.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(cardFlatten.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    assertJsonMatchesGolden(
      name: 'card_out_flatten.json',
      actualJson: cardFlatten,
      expectedJson: cardOutFlatten,
    );
    // Example 11: user_summary_in.jinja
    print('\n=== Example 11: user_summary_in.jinja ===');
    final template14 = env.fromString(userSummaryIn);
    resultOfJinjaScript = await template14.renderAsync();
    print('Result length: ${resultOfJinjaScript.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(resultOfJinjaScript.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    final userSummaryJson = jsonDecode(resultOfJinjaScript) as Map<String, dynamic>;
    if (userSummaryJson['data_type'] != 'dt_object') {
      throw StateError('user_summary_in.jinja did not return dt_object');
    }
    assertJsonMatchesGolden(
      name: 'user_summary_in.jinja',
      actualJson: resultOfJinjaScript,
      expectedJson: userSummaryOut,
    );
    final userSummaryFlatten = jsonEncode(
      _flattenDataType(jsonDecode(resultOfJinjaScript)),
    );
    print('Flatten result length: ${userSummaryFlatten.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(userSummaryFlatten.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    assertJsonMatchesGolden(
      name: 'user_summary_out_flatten.json',
      actualJson: userSummaryFlatten,
      expectedJson: userSummaryOutFlatten,
    );
    // Example 12: events_in.jinja
    print('\n=== Example 12: events_in.jinja ===');
    final template15 = env.fromString(eventsIn);
    resultOfJinjaScript = await template15.renderAsync();
    print('Result length: ${resultOfJinjaScript.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(resultOfJinjaScript.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    final eventsJson = jsonDecode(resultOfJinjaScript) as Map<String, dynamic>;
    if (eventsJson['data_type'] != 'dt_object') {
      throw StateError('events_in.jinja did not return dt_object');
    }
    assertJsonMatchesGolden(
      name: 'events_in.jinja',
      actualJson: resultOfJinjaScript,
      expectedJson: eventsOut,
    );
    final eventsFlatten = jsonEncode(
      _flattenDataType(jsonDecode(resultOfJinjaScript)),
    );
    print('Flatten result length: ${eventsFlatten.length}');
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    print(eventsFlatten.replaceAll('\n', ''));
    print(
      '--------------------------------------------------------------------------------------------------------------------------------',
    );
    assertJsonMatchesGolden(
      name: 'events_out_flatten.json',
      actualJson: eventsFlatten,
      expectedJson: eventsOutFlatten,
    );
  } catch (e, stack) {
    print('\n!!! UNHANDLED EXCEPTION !!!');
    print(e);
    print(stack);
  }
}

void assertJsonMatchesGolden({
  required String name,
  required String actualJson,
  required String expectedJson,
}) {
  final actualCanonicalObject = _canonicalizeJson(
    jsonDecode(actualJson),
    ignoreKeys: {'id'},
  );
  final expectedCanonicalObject = _canonicalizeJson(
    jsonDecode(expectedJson),
    ignoreKeys: {'id'},
  );
  final actualCanonical = jsonEncode(actualCanonicalObject);
  final expectedCanonical = jsonEncode(expectedCanonicalObject);
  if (actualCanonical != expectedCanonical) {
    final mismatches = <String>[];
    _collectJsonMismatches(
      actual: actualCanonicalObject,
      expected: expectedCanonicalObject,
      path: r'$',
      mismatches: mismatches,
    );
    final preview =
        mismatches.isEmpty ? '(differences found, but no non-ignored path-level mismatch was collected)' : mismatches.take(20).join('\n');
    final extraCount = mismatches.length > 20 ? '\n... and ${mismatches.length - 20} more mismatch(es)' : '';
    throw StateError('Golden mismatch for $name\n$preview$extraCount');
  }
}

dynamic _canonicalizeJson(
  dynamic value, {
  Set<String> ignoreKeys = const {},
}) {
  if (value is Map) {
    final entries = value.entries.where((entry) => !ignoreKeys.contains(entry.key.toString())).toList()
      ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
    return <String, dynamic>{
      for (final entry in entries)
        entry.key.toString(): _canonicalizeJson(
          entry.value,
          ignoreKeys: ignoreKeys,
        ),
    };
  }
  if (value is List) {
    return value.map((item) => _canonicalizeJson(item, ignoreKeys: ignoreKeys)).toList();
  }
  return value;
}

void _collectJsonMismatches({
  required dynamic actual,
  required dynamic expected,
  required String path,
  required List<String> mismatches,
}) {
  if (actual is Map && expected is Map) {
    final allKeys = <String>{
      ...actual.keys.map((k) => k.toString()),
      ...expected.keys.map((k) => k.toString()),
    }.toList()
      ..sort();
    for (final key in allKeys) {
      // Ignore runtime/generated UUID fields.
      if (key == 'id') {
        continue;
      }
      final hasActual = actual.containsKey(key);
      final hasExpected = expected.containsKey(key);
      final nextPath = '$path.$key';
      if (!hasActual) {
        mismatches.add('$nextPath -> missing in actual; expected=${jsonEncode(expected[key])}');
        continue;
      }
      if (!hasExpected) {
        mismatches.add('$nextPath -> extra in actual; actual=${jsonEncode(actual[key])}');
        continue;
      }
      _collectJsonMismatches(
        actual: actual[key],
        expected: expected[key],
        path: nextPath,
        mismatches: mismatches,
      );
    }
    return;
  }

  if (actual is List && expected is List) {
    if (actual.length != expected.length) {
      mismatches.add(
        '$path.length -> actual=${actual.length}, expected=${expected.length}',
      );
    }
    final minLength = actual.length < expected.length ? actual.length : expected.length;
    for (var i = 0; i < minLength; i++) {
      _collectJsonMismatches(
        actual: actual[i],
        expected: expected[i],
        path: '$path[$i]',
        mismatches: mismatches,
      );
    }
    return;
  }

  if (actual != expected) {
    mismatches.add(
      '$path -> actual=${jsonEncode(actual)}, expected=${jsonEncode(expected)}',
    );
  }
}

dynamic _flattenDataType(dynamic dt) {
  if (dt is List) {
    return dt.map(_flattenDataType).toList();
  }
  if (dt is! Map<String, dynamic>) {
    return dt;
  }

  final dataType = dt['data_type'];
  if (dataType == 'dt_object') {
    final data = dt['data'];
    if (data is! Map<String, dynamic>) {
      return <String, dynamic>{};
    }
    return <String, dynamic>{
      for (final entry in data.entries) entry.key: _flattenDataType(entry.value),
    };
  }
  if (dataType == 'dt_events') {
    final data = dt['data'];
    if (data is! Map<String, dynamic>) {
      return <String, dynamic>{};
    }
    return <String, dynamic>{
      for (final entry in data.entries) entry.key: _flattenDataType(entry.value),
    };
  }
  if (dataType == 'dt_event') {
    final properties = dt['properties'];
    return <String, dynamic>{
      'workflow_id': dt['workflow_id'],
      'properties': properties is Map<String, dynamic>
          ? <String, dynamic>{
              for (final entry in properties.entries) entry.key: _flattenDataType(entry.value),
            }
          : <String, dynamic>{},
    };
  }
  if (dataType == 'dt_list') {
    final data = dt['data'];
    if (data is! List) {
      return <dynamic>[];
    }
    return data.map(_flattenDataType).toList();
  }
  if (dataType == 'dt_money') {
    final moneyData = dt['data'];
    if (moneyData is! Map<String, dynamic>) {
      return <String, dynamic>{};
    }
    final metadata = moneyData['value_metadata'];
    final flattened = <String, dynamic>{};
    if (moneyData.containsKey('value')) {
      flattened['amount'] = moneyData['value'];
    }
    if (metadata is Map<String, dynamic>) {
      if (metadata.containsKey('currency_id')) {
        flattened['currency_id'] = metadata['currency_id'];
      }
      if (metadata.containsKey('currency_symb')) {
        flattened['currency_symb'] = metadata['currency_symb'];
      }
      if (metadata.containsKey('convert_rate')) {
        flattened['convert_rate'] = metadata['convert_rate'];
      }
    }
    return flattened;
  }

  final data = dt['data'];
  if (data is Map<String, dynamic>) {
    return data['value'];
  }
  return data;
}

Future<String> fetchData() async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return 'Data fetched successfully';
}
