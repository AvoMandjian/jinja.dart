import 'package:jinja/jinja.dart';

void main() {
  var env = Environment();

  print("Testing simple ternary operator:");

  try {
    // Test basic ternary syntax
    var template1 = env.fromString('{{ variable ? "TRUE" : "FALSE" }}');
    print('Template created successfully: {{ variable ? "TRUE" : "FALSE" }}');
    print('Result with null: ${template1.render()}');
    print('Result with true: ${template1.render({'variable': true})}');
    print('Result with false: ${template1.render({'variable': false})}');
  } catch (e) {
    print('Error with basic ternary: $e');
  }

  try {
    // Test with numbers
    var template2 = env.fromString('{{ score > 60 ? "Pass" : "Fail" }}');
    print(
        '\nTemplate created successfully: {{ score > 60 ? "Pass" : "Fail" }}');
    print('Result with score=70: ${template2.render({'score': 70})}');
    print('Result with score=45: ${template2.render({'score': 45})}');
  } catch (e) {
    print('Error with expression ternary: $e');
  }
}
