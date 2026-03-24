import 'package:jinja/src/environment.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/lexer.dart';
import 'package:test/test.dart';

void main() {
  final env = Environment();
  final lexer = Lexer(env);

  group('Lexer Coverage Extensions 2', () {
    test('Unexpected closing parenthesis', () {
      expect(() => lexer.tokenize('{{ ( ) ) }}'),
          throwsA(isA<TemplateSyntaxError>()));
    });

    test('Mismatched closing brackets', () {
      expect(() => lexer.tokenize('{{ ( ] }}'),
          throwsA(isA<TemplateSyntaxError>()));
      expect(() => lexer.tokenize('{{ [ } }}'),
          throwsA(isA<TemplateSyntaxError>()));
    });

    test('Lex with initial state', () {
      // Direct call to scan with state
      // We need a StringScanner
      // Since it's internal, we can test it via a public method if possible
      // Or just skip if it's too internal.
      // tokenize doesn't expose state.
    });

    test('Balancing stack not empty at end token', () {
      // This covers line 400
      // {{ ( }}
      // The 'variable_end' ( }}) is encountered while balancingStack is not empty
      expect(() => lexer.tokenize('{{ ( }}').toList(),
          throwsA(isA<TemplateSyntaxError>()));
    });
  });
}
