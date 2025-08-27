import 'package:jinja/jinja.dart';
import 'package:jinja/src/nodes.dart';

void main() {
  var env = Environment();
  
  var templateSource = '''Hello 1
{% for VARIABLE_1 in [1,2,3,4,5] %}
  {{dealership.inventory |tojson}}
{% endfor %}
Hello 2''';

  var ast = env.parse(templateSource);
  
  void printNode(Node node, int depth) {
    var indent = '  ' * depth;
    print('$indent${node.runtimeType} - Line: ${node.line}');
    if (node is Data) {
      var escaped = node.data.replaceAll('\n', '\\n');
      print('$indent  data: "$escaped"');
    }
    if (node is For) {
      print('$indent  target: ${node.target}');
      print('$indent  iterable: ${node.iterable}');
      print('$indent  body:');
      printNode(node.body, depth + 1);
    }
    if (node is Output) {
      for (var child in node.nodes) {
        printNode(child, depth + 1);
      }
    }
    if (node is TemplateNode) {
      printNode(node.body, depth + 1);
    }
  }
  
  print('AST Structure:');
  printNode(ast, 0);
}
