import 'dart:async';
import 'package:jinja/src/debug/debug_controller.dart';
import 'package:jinja/src/debug/debug_renderer.dart';
import 'package:jinja/src/environment.dart';
import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/renderer.dart';

/// Extension to add debug capabilities to Template
extension DebugTemplate on Template {
  /// Render template with debugging support
  Future<String> renderDebug(
    Map<String, Object?>? data, {
    required DebugController debugController,
    String? templateSource,
  }) async {
    var buffer = StringBuffer();
    await renderDebugTo(buffer, data, 
      debugController: debugController,
      templateSource: templateSource);
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

    // Keep trying to render until successful or stopped
    while (true) {
      try {
        // Reset context for restart
        context = DebugRenderContext(
          environment,
          sink,
          debugController: debugController,
          template: path,
          parent: globals,
          data: data,
        );
        
        // If template source provided (for restart with new template)
        if (templateSource != null) {
          final newTemplate = environment.fromString(templateSource);
          await _renderBodyAsync(newTemplate.body, context);
        } else {
          await _renderBodyAsync(body, context);
        }
        
        // Successfully completed
        break;
      } on RestartException {
        // Clear the buffer and restart
        if (sink is StringBuffer) {
          sink.clear();
        }
        debugController.reset();
        // Continue the loop to restart
      }
    }
  }
  
  /// Async rendering to handle breakpoints
  Future<void> _renderBodyAsync(
    TemplateNode node,
    DebugRenderContext context,
  ) async {
    const renderer = DebugRenderer();
    
    // We need to make the visitor pattern async-aware
    // For now, we'll use a synchronous approach with periodic checks
    node.accept(renderer, context);
    
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
