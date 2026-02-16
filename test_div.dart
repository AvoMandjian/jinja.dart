import 'package:jinja/jinja.dart';

void main() {
  try {
    print(Environment().fromString('{{ null.something }}').render());
  } catch (e) {
    print('Caught: ${e.runtimeType}');
  }
}
