import 'package:jinja/jinja.dart';

void main() {
  var env = Environment();

  print("Testing nested ternary operator:");

  try {
    // Test simple nested ternary
    var template = env.fromString('{{ a ? (b ? "AB" : "A") : "NO" }}');
    print('Template created: {{ a ? (b ? "AB" : "A") : "NO" }}');
    print('a=false, b=false: ${template.render({'a': false, 'b': false})}');
    print('a=true, b=false: ${template.render({'a': true, 'b': false})}');
    print('a=true, b=true: ${template.render({'a': true, 'b': true})}');
  } catch (e) {
    print('Error with parenthesized nested ternary: $e');
  }

  try {
    // Test nested ternary without parentheses
    var template = env.fromString('{{ a ? b ? "AB" : "A" : "NO" }}');
    print('\nTemplate created: {{ a ? b ? "AB" : "A" : "NO" }}');
    print('a=false, b=false: ${template.render({'a': false, 'b': false})}');
    print('a=true, b=false: ${template.render({'a': true, 'b': false})}');
    print('a=true, b=true: ${template.render({'a': true, 'b': true})}');
  } catch (e) {
    print('Error with nested ternary: $e');
  }
}
