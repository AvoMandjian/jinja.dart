import 'package:jinja/jinja.dart';

void main() {
  var env = Environment();

  print("Testing ternary operator ? : as alternative to if-else:");

  // Test basic ternary syntax
  var template1 = env.fromString('{{ variable ? "TRUE" : "FALSE" }}');
  print(
      'Template: {{ variable ? "TRUE" : "FALSE" }} with null -> ${template1.render()}');
  print(
      'Template: {{ variable ? "TRUE" : "FALSE" }} with false -> ${template1.render({
        'variable': false
      })}');
  print(
      'Template: {{ variable ? "TRUE" : "FALSE" }} with true -> ${template1.render({
        'variable': true
      })}');
  print(
      'Template: {{ variable ? "TRUE" : "FALSE" }} with "value" -> ${template1.render({
        'variable': 'value'
      })}');

  // Compare with if-else syntax
  var template2 = env.fromString('{{ "TRUE" if variable else "FALSE" }}');
  print('\nComparing with if-else:');
  print(
      'Template: {{ "TRUE" if variable else "FALSE" }} with null -> ${template2.render()}');
  print(
      'Template: {{ "TRUE" if variable else "FALSE" }} with false -> ${template2.render({
        'variable': false
      })}');
  print(
      'Template: {{ "TRUE" if variable else "FALSE" }} with true -> ${template2.render({
        'variable': true
      })}');
  print(
      'Template: {{ "TRUE" if variable else "FALSE" }} with "value" -> ${template2.render({
        'variable': 'value'
      })}');

  // Test nested ternary
  var template3 =
      env.fromString('{{ a ? b ? "A_AND_B" : "A_NOT_B" : "NOT_A" }}');
  print('\nTesting nested ternary:');
  print(
      'Template: {{ a ? b ? "A_AND_B" : "A_NOT_B" : "NOT_A" }} with both false -> ${template3.render({
        'a': false,
        'b': false
      })}');
  print(
      'Template: {{ a ? b ? "A_AND_B" : "A_NOT_B" : "NOT_A" }} with a=true, b=false -> ${template3.render({
        'a': true,
        'b': false
      })}');
  print(
      'Template: {{ a ? b ? "A_AND_B" : "A_NOT_B" : "NOT_A" }} with both true -> ${template3.render({
        'a': true,
        'b': true
      })}');

  // Test with numbers
  var template4 = env.fromString('{{ score > 60 ? "Pass" : "Fail" }}');
  print('\nTesting with expressions:');
  print(
      'Template: {{ score > 60 ? "Pass" : "Fail" }} with score=70 -> ${template4.render({
        'score': 70
      })}');
  print(
      'Template: {{ score > 60 ? "Pass" : "Fail" }} with score=45 -> ${template4.render({
        'score': 45
      })}');

  print("\nAll tests completed!");
}
