import 'dart:io';
import 'package:jinja/src/environment.dart';
import 'package:jinja/src/nodes.dart';

void traverse(Node node) {
  if (node is Calling) {
    if (node.arguments.isNotEmpty && node.arguments[0] is Array) {
      print("Found Calling with Array argument!");
      for (var a in node.arguments) {
        print("  arg: " + a.runtimeType.toString());
      }
    }
  }
  
  if (node is Output) {
    for (var child in node.nodes) traverse(child);
  } else if (node is Interpolation) {
    traverse(node.value);
  } else if (node is Call) {
    traverse(node.value);
    traverse(node.calling);
  } else if (node is TemplateNode) {
    traverse(node.body);
  } else if (node is Macro) {
    traverse(node.body);
  }
}

void main() {
  var file = File('example/data_types_test.dart');
  var content = file.readAsStringSync();
  var start = content.indexOf('final jinjaScript = \'\'\'') + 23;
  var end = content.indexOf('\'\'\';', start);
  var script = content.substring(start, end);
  
  final env = Environment();
  final templateNode = env.parse(script) as TemplateNode;
  traverse(templateNode);
  
  var start2 = content.indexOf('data_types.jinja\': \'\'\'') + 23;
  var end2 = content.indexOf('\'\'\',', start2);
  var script2 = content.substring(start2, end2);
  final templateNode2 = env.parse(script2) as TemplateNode;
  traverse(templateNode2);
}
