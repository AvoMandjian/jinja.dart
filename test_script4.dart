import 'dart:io';
import 'package:jinja/src/environment.dart';
import 'package:jinja/src/nodes.dart';

void main() {
  var file = File('example/data_types_test.dart');
  var content = file.readAsStringSync();
  var start = content.indexOf('data_types.jinja\': \'\'\'') + 23;
  var end = content.indexOf('\'\'\',', start);
  var script = content.substring(start, end);
  
  final env = Environment();
  final templateNode = env.parse(script) as TemplateNode;
  final output = templateNode.body as Output;
  for (var i = 0; i < output.nodes.length; i++) {
    var node = output.nodes[i];
    if (node is Macro) {
       if (node.name == 'create_dt_text') {
         for (var child in (node.body as Output).nodes) {
           if (child is Interpolation && child.value is Call) {
             var call = child.value as Call;
             print("Macro " + node.name + " Call " + call.value.toString() + ": args=" + call.calling.arguments.toString());
           }
         }
       }
    }
  }
}
