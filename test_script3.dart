import 'dart:io';
import 'package:jinja/src/environment.dart';
import 'package:jinja/src/nodes.dart';

void main() {
  var file = File('example/data_types_test.dart');
  var content = file.readAsStringSync();
  var start = content.indexOf('final jinjaScript = \'\'\'') + 23;
  var end = content.indexOf('\'\'\';', start);
  var script = content.substring(start, end);
  
  final env = Environment();
  final templateNode = env.parse(script) as TemplateNode;
  final output = templateNode.body as Output;
  for (var i = 0; i < output.nodes.length; i++) {
    var node = output.nodes[i];
    if (node is Interpolation) {
       var call = node.value as Call;
       print("Interpolation " + i.toString() + ": args=" + call.calling.arguments.toString());
    }
  }
}
