import 'package:jinja/jinja.dart';

void main() {
  print(Environment().fromString('{{ true }}').render());
}
