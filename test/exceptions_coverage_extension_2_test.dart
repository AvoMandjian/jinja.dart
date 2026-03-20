import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/nodes.dart';
import 'package:test/test.dart';

void main() {
  group('Jinja Exceptions Coverage Extensions', () {
    test('TemplateNotFound toString', () {
      final err1 = TemplateNotFound(name: 'a.html', searchPaths: ['/tmp', '/var']);
      final str1 = err1.toString();
      expect(str1, contains('Template name: \'a.html\''));
      expect(str1, contains('Searched paths:'));
      expect(str1, contains('- /tmp'));

      final err2 = TemplateNotFound(message: 'custom msg');
      expect(err2.toString(), contains('TemplateNotFound: custom msg'));
    });

    test('TemplatesNotFound toString', () {
      final err1 = TemplatesNotFound(names: ['a.html', 'b.html']);
      expect(err1.toString(), contains('none of the templates given were found: a.html, b.html'));

      final err2 = TemplatesNotFound(message: 'fail');
      expect(err2.toString(), equals('TemplatesNotFound: fail'));

      final err3 = TemplatesNotFound();
      expect(err3.toString(), equals('TemplatesNotFound'));
    });

    test('TemplateSyntaxError toString', () {
      final err1 = TemplateSyntaxError('msg', path: 'a.html', line: 1, column: 2);
      final str1 = err1.toString();
      expect(str1, contains("file 'a.html'"));
      expect(str1, contains('line 1, column 2'));

      final err2 = TemplateSyntaxError('msg', templatePath: 'b.html', node: Name(name: 'x', line: 10));
      final str2 = err2.toString();
      expect(str2, contains("file 'b.html'"));
      expect(str2, contains('line 10'));
    });

    test('UndefinedError toString', () {
      final err = UndefinedError('msg', variableNameValue: 'foo', similarNamesValue: ['food', 'fool']);
      final str = err.toString();
      expect(str, contains('Variable: \'foo\''));
      expect(str, contains('Similar variables found: food, fool'));
    });

    test('TemplateErrorWrapper toString', () {
      final original = Exception('orig');
      final wrapper = TemplateErrorWrapper(original, message: 'wrapped msg');
      final str = wrapper.toString();
      expect(str, contains('TemplateErrorWrapper: _Exception - wrapped msg'));
      expect(str, contains('Original Error: Exception: orig'));
    });

    test('TemplateErrorWrapper with TemplateError original', () {
      final original = TemplateRuntimeError('inner');
      final wrapper = TemplateErrorWrapper(original);
      expect(wrapper.message, equals('inner'));
    });
  });
}
