import 'dart:async';

import 'dart:async';

import 'dart:async';

import 'package:jinja/src/debug/async_debug_renderer.dart';
import 'package:jinja/src/debug/debug_controller.dart';
import 'package:jinja/src/debug/debug_renderer.dart';
import 'package:jinja/src/environment.dart';
import 'package:jinja/src/nodes.dart';

/// Extension to add debug capabilities to Template
extension DebugTemplate on Template {
  /// Render template with debugging support
  Future<String> renderDebug(
    Map<String, Object?>? data, {
    required DebugController debugController,
    String? templateSource,
  }) async {
    var buffer = StringBuffer();
    await renderDebugTo(buffer, data, debugController: debugController, templateSource: templateSource);
    return buffer.toString();
  }

  /// Render template to a sink with debugging support
  Future<void> renderDebugTo(
    StringSink sink,
    Map<String, Object?>? data, {
    required DebugController debugController,
    String? templateSource,
  }) async {
    var context = DebugRenderContext(
      environment,
      sink,
      debugController: debugController,
      template: path,
      parent: globals,
      data: data,
    );

    try {
      // If template source provided (for restart with new template)
      if (templateSource != null) {
        var newTemplate = environment.fromString(templateSource);
        await _renderBodyAsync(newTemplate.body, context);
      } else {
        await _renderBodyAsync(body, context);
      }
    } on StopException {
      // Stop execution
    }
  }

  /// Async rendering to handle breakpoints
  Future<void> _renderBodyAsync(
    TemplateNode node,
    DebugRenderContext context,
  ) async {
    final renderer = AsyncDebugRenderer();
    await node.accept(renderer, context);

    // Check if we should stop
    if (context.shouldStop) {
      throw StopException();
    }
  }
}

/// Exception thrown when execution should stop
class StopException implements Exception {
  const StopException();
}
