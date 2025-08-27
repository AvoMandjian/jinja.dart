import 'dart:async';
import 'dart:async';
import 'package:jinja/src/debug/async_debug_renderer.dart';
import 'package:jinja/src/debug/debug_controller.dart';
import 'package:jinja/src/debug/debug_renderer.dart';
import 'package:jinja/src/environment.dart';

/// Extension to add debug rendering to Template
extension DebugTemplateExtension on Template {
  /// Render template with debug support
  Future<String> renderDebug({
    Map<String, Object?>? data,
    required DebugController debugController,
    Function()? getUpdatedTemplate,
  }) async {
    var buffer = StringBuffer();
    await renderDebugTo(
      buffer,
      data: data,
      debugController: debugController,
      getUpdatedTemplate: getUpdatedTemplate,
    );
    return buffer.toString();
  }

  /// Render template to sink with debug support
  Future<void> renderDebugTo(
    StringSink sink, {
    Map<String, Object?>? data,
    required DebugController debugController,
    Function()? getUpdatedTemplate,
  }) async {
    // Get potentially updated template
    Template templateToRender = this;
      if (getUpdatedTemplate != null) {
        var updated = getUpdatedTemplate();
        if (updated is Template) {
          templateToRender = updated;
        } else if (updated is String) {
          templateToRender = environment.fromString(updated);
        }
      }

      // Create debug context
      var context = DebugRenderContext(
        environment,
        sink,
        debugController: debugController,
        template: path,
        parent: globals,
        data: data,
      );

      // Render with async debug renderer
      final debugRenderer = AsyncDebugRenderer();
      await templateToRender.body.accept(debugRenderer, context);
  }
}

/// Extension to Environment for creating debug-enabled templates
extension DebugEnvironmentExtension on Environment {
  /// Create a template from string with debug support
  Template fromStringDebug(String source) {
    return fromString(source);
  }

  /// Get a template with debug support
  Template getTemplateDebug(String name) {
    return getTemplate(name);
  }
}
