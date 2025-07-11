part of 'lexer.dart';

const Map<String, String> tokenDescriptions = <String, String>{
  'add': '+',
  'sub': '-',
  'div': '/',
  'floordiv': '//',
  'mul': '*',
  'mod': '%',
  'pow': '**',
  'tilde': '~',
  'lbracket': '[',
  'rbracket': ']',
  'lparen': '(',
  'rparen': ')',
  'lbrace': '{',
  'rbrace': '}',
  'eq': '==',
  'ne': '!=',
  'gt': '>',
  'gteq': '>=',
  'lt': '<',
  'lteq': '<=',
  'assign': '=',
  'dot': '.',
  'colon': ':',
  'pipe': '|',
  'comma': ',',
  'semicolon': ';',
  'comment_start': 'start of comment',
  'comment_end': 'end of comment',
  'comment': 'comment',
  'linecomment': 'comment',
  'block_start': 'start of statement block',
  'block_end': 'end of statement block',
  'variable_start': 'start of print statement',
  'variable_end': 'end of print statement',
  'linestatement_start': 'start of line statement',
  'linestatement_end': 'end of line statement',
  'data': 'template data / text',
  'eof': 'end of template',
};

String describeTokenType(String type) {
  return tokenDescriptions[type] ?? type;
}

String describeToken(Token token) {
  if (token.type == 'name') {
    return token.value;
  }

  return describeTokenType(token.type);
}

String describeExpression((String, String?) expression) {
  var (type, value) = expression;

  if (type == 'name' && value != null) {
    return value;
  }

  return describeTokenType(type);
}

abstract final class Token {
  static const Map<String, String> common = <String, String>{
    'add': '+',
    'assign': '=',
    'colon': ':',
    'comma': ',',
    'div': '/',
    'dot': '.',
    'eq': '==',
    'eof': '',
    'floordiv': '//',
    'gt': '>',
    'gteq': '>=',
    'initial': '',
    'lbrace': '{',
    'lbracket': '[',
    'lparen': '(',
    'lt': '<',
    'lteq': '<=',
    'mod': '%',
    'mul': '*',
    'ne': '!=',
    'pipe': '|',
    'pow': '**',
    'rbrace': '}',
    'rbracket': ']',
    'rparen': ')',
    'semicolon': ';',
    'sub': '-',
    'tilde': '~',
  };

  const factory Token(int line, int column, String type, String value) =
      ValueToken;

  const factory Token.simple(int line, int column, String type) = SimpleToken;

  @override
  int get hashCode {
    return type.hashCode ^ line ^ column ^ value.hashCode;
  }

  int get line;
  int get column;

  int get length;

  String get type;

  String get value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Token &&
        type == other.type &&
        line == other.line &&
        column == other.column &&
        value == other.value;
  }

  Token change({int? line, int? column, String? type, String? value});

  bool test(String type, [String? value]);

  bool testAny(Iterable<(String, String?)> expressions);
}

/// Helper to extract a context snippet with a caret for error display.
String errorContextSnippet(String source, int line, int column,
    {int contextLines = 1}) {
  var lines = source.split('\n');
  var buffer = StringBuffer();
  if (lines.isEmpty) {
    return '';
  }
  // Clamp line and column to valid ranges
  var safeLine = line.clamp(1, lines.length);
  var start = (safeLine - contextLines - 1).clamp(0, lines.length - 1);
  var end = (safeLine + contextLines - 1).clamp(0, lines.length - 1);
  for (int i = start; i <= end; i++) {
    buffer.writeln('${i + 1}: ${lines[i]}');
    if (i == safeLine - 1 && column > 0) {
      var caretPos = column - 1;
      var safeCaret = caretPos.clamp(0, lines[i].length);
      buffer.writeln('    ${' ' * safeCaret}^');
    }
  }
  return buffer.toString();
}

abstract final class BaseToken implements Token {
  const BaseToken();

  @override
  int get length {
    return value.length;
  }

  @override
  Token change({int? line, int? column, String? type, String? value}) {
    line ??= this.line;
    column ??= this.column;
    value ??= this.value;

    if (type != null && Token.common.containsKey(type)) {
      return Token.simple(line, column, type);
    }

    return Token(line, column, type ?? this.type, value);
  }

  @override
  bool test(String type, [String? value]) {
    if (value == null) {
      return type == this.type;
    }

    return type == this.type && value == this.value;
  }

  @override
  bool testAny(Iterable<(String, String?)> expressions) {
    for (var (type, value) in expressions) {
      if (test(type, value)) {
        return true;
      }
    }

    return false;
  }
}

final class SimpleToken extends BaseToken {
  const SimpleToken(this.line, this.column, this.type);

  @override
  final int line;

  @override
  final int column;

  @override
  final String type;

  @override
  String get value {
    return Token.common[type] ?? '';
  }
}

final class ValueToken extends BaseToken {
  const ValueToken(this.line, this.column, this.type, this.value);

  @override
  final int line;

  @override
  final int column;

  @override
  final String type;

  @override
  final String value;
}
