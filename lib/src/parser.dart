import 'package:textwrap/textwrap.dart';

import 'environment.dart';
import 'exceptions.dart';
import 'lexer.dart';
import 'nodes.dart';
import 'reader.dart';

final class Parser {
  Parser(this.environment, this.templateSource, {this.path})
      : endTokensStack = <List<(String, String?)>>[],
        tagStack = <String>[],
        blocks = <String>{};

  final Environment environment;

  /// The full template source for context snippets.
  final String templateSource;

  final String? path;

  final List<List<(String, String?)>> endTokensStack;

  final List<String> tagStack;

  final Set<String> blocks;

  Extends? extendsNode;

  Never fail(String message, {required int? line, required int? column}) {
    // Generate suggestions based on common syntax errors
    final suggestions = <String>[];

    // Common syntax error patterns
    if (message.toLowerCase().contains('unexpected end')) {
      suggestions.add('Check if all tags are properly closed');
      suggestions.add('Verify {% endfor %}, {% endif %}, {% endblock %} tags match opening tags');
    } else if (message.toLowerCase().contains('unknown tag')) {
      suggestions.add('Check if the tag name is spelled correctly');
      suggestions.add('Verify all tag names are valid Jinja tags');
      if (tagStack.isNotEmpty) {
        suggestions.add('Currently inside: ${tagStack.join(" -> ")}');
      }
    } else if (message.toLowerCase().contains('nesting')) {
      suggestions.add('Check tag nesting order');
      suggestions.add('Ensure opening and closing tags match');
    } else {
      suggestions.add('Check the template syntax at the indicated line and column');
      suggestions.add('Verify all tags are properly closed');
      suggestions.add('Check for typos in tag names');
    }

    throw TemplateSyntaxError(
      message,
      line: line,
      column: column,
      path: path,
      contextSnippet: (line != null && column != null) ? errorContextSnippet(templateSource, line, column) : null,
      suggestions: suggestions,
    );
  }

  Never failUnknownTagEof(
    String? name,
    List<List<(String, String?)>> endTokensStack, [
    int? line,
    int? column,
  ]) {
    var expected = <String>[];
    String? currentlyLooking;

    for (var tokens in endTokensStack) {
      expected.addAll(tokens.map<String>(describeExpression));
    }

    if (endTokensStack.isNotEmpty) {
      currentlyLooking = endTokensStack.last.map<String>((token) => "'${describeExpression(token)}'").join(' or ');
    }

    var messages = <String>[];

    if (name == null) {
      messages.add('Unexpected end of template.');
    } else {
      messages.add("Encountered unknown tag '$name'.");
    }

    if (currentlyLooking != null) {
      if (name != null && expected.contains(name)) {
        messages
          ..add('You probably made a nesting mistake.')
          ..add(
            'Jinja is expecting this tag, but currently looking for $currentlyLooking.',
          );
      } else {
        messages.add(
          'Jinja was looking for the following tags: $currentlyLooking.',
        );
      }
    }

    if (tagStack.isNotEmpty) {
      messages.add(
        "The innermost block that needs to be closed is '${tagStack.last}'.",
      );
    }

    fail(messages.join(' '), line: line, column: column);
  }

  Never failUnknownTag(String name, [int? line, int? column]) {
    failUnknownTagEof(name, endTokensStack, line, column);
  }

  Never failEof(List<(String, String?)> endTokens, [int? line, int? column]) {
    var stack = endTokensStack.toList();
    stack.add(endTokens);
    failUnknownTagEof(null, stack, line, column);
  }

  bool isTupleEnd(
    TokenReader reader, [
    List<(String, String?)>? extraEndRules,
  ]) {
    return switch (reader.current.type) {
      'variable_end' || 'block_end' || 'rparen' => true,
      _ => extraEndRules != null && extraEndRules.isNotEmpty ? reader.current.testAny(extraEndRules) : false,
    };
  }

  Node parseStatement(TokenReader reader) {
    var token = reader.current;

    if (!token.test('name')) {
      fail('Tag name expected', line: token.line, column: token.column);
    }

    tagStack.add(token.value);

    var popTag = true;

    try {
      switch (token.value) {
        case 'set':
          return parseSet(reader);

        case 'for':
          return parseFor(reader);

        case 'if':
          return parseIf(reader);

        case 'with':
          return parseWith(reader);

        case 'block':
          return parseBlock(reader);

        case 'extends':
          return parseExtends(reader);

        case 'include':
          return parseInclude(reader);

        case 'import':
          return parseImport(reader);

        case 'from':
          return parseFrom(reader);

        case 'call':
          return parseCallBlock(reader);

        case 'filter':
          return parseFilterBlock(reader);

        case 'macro':
          return parseMacro(reader);

        case 'do':
          return parseDo(reader);

        case 'try':
          return parseTryCatch(reader);

        case 'autoescape':
          return parseAutoEscape(reader);

        case 'break':
          return parseBreak(reader);

        case 'continue':
          return parseContinue(reader);

        case 'debug':
          return parseDebug(reader);

        case 'trans':
          return parseTrans(reader);

        default:
          tagStack.removeLast();
          popTag = false;
          failUnknownTag(token.value, token.line, token.column);
      }
    } finally {
      if (popTag) {
        tagStack.removeLast();
      }
    }
  }

  Node parseStatements(
    TokenReader reader,
    List<(String, String?)> endTokens, [
    bool dropNeedle = false,
  ]) {
    reader.skipIf('colon');
    reader.expect('block_end');

    var nodes = subParse(reader, endTokens: endTokens);

    if (reader.current.test('eof')) {
      failEof(endTokens, reader.current.line, reader.current.column);
    }

    if (dropNeedle) {
      reader.next();
    }

    if (nodes.isEmpty) {
      return Data();
    }

    if (nodes.length == 1) {
      return nodes[0];
    }

    return Output(nodes: nodes);
  }

  Statement parseSet(TokenReader reader) {
    const endSet = <(String, String?)>[('name', 'endset')];

    reader.expect('name', 'set');

    var target = parseAssignNameSpace(reader);

    if (reader.current.test('comma')) {
      var targets = <Expression>[target];

      while (reader.skipIf('comma')) {
        if (reader.current.test('assign') || reader.current.test('block_end')) {
          break;
        }

        targets.add(parseAssignNameSpace(reader));
      }

      target = Tuple(values: targets);
    }

    if (reader.skipIf('assign')) {
      var expression = parseTuple(reader);
      return Assign(target: target, value: expression);
    }

    var filters = parseFilters(reader);
    var body = parseStatements(reader, endSet, true);
    return AssignBlock(target: target, filters: filters, body: body);
  }

  For parseFor(TokenReader reader) {
    const endIn = <(String, String?)>[('name', 'in')];
    const endFor = <(String, String?)>[('name', 'endfor')];
    const endForElse = <(String, String?)>[
      ('name', 'endfor'),
      ('name', 'else'),
    ];

    var forToken = reader.expect('name', 'for');
    var forLine = forToken.line;

    var target = parseAssignTarget(reader, extraEndRules: endIn);

    if (target case Name(name: 'loop')) {
      fail(
        "Can't assign to special loop variable in for-loop target.",
        line: reader.current.line,
        column: reader.current.column,
      );
    }

    reader.expect('name', 'in');

    var iterable = parseTuple(reader, withCondition: false);
    Expression? test;

    if (reader.skipIf('name', 'if')) {
      test = parseExpression(reader);
    }

    var recursive = reader.skipIf('name', 'recursive');
    var body = parseStatements(reader, endForElse);
    Node? orElse;
    var current = reader.next();

    if (current.test('name', 'else')) {
      orElse = parseStatements(reader, endFor, true);
      current = reader.current;
    }

    return For(
      target: target,
      iterable: iterable,
      body: body,
      orElse: orElse,
      test: test,
      recursive: recursive,
      endLine: current.line,
      line: forLine,
    );
  }

  If parseIf(TokenReader reader) {
    const endIf = <(String, String?)>[('name', 'endif')];
    const endIfElseEndIf = <(String, String?)>[
      ('name', 'elif'),
      ('name', 'else'),
      ('name', 'endif'),
    ];

    reader.expect('name', 'if');

    var test = parseExpression(reader, false);
    var body = parseStatements(reader, endIfElseEndIf);
    var root = If(test: test, body: body);
    var ifNodes = <If>[root];
    Token tag;

    while (true) {
      tag = reader.next();

      if (tag.test('name', 'elif')) {
        var test = parseTuple(reader, withCondition: false);
        var body = parseStatements(reader, endIfElseEndIf);
        var elif = If(test: test, body: body);
        ifNodes.add(elif);
        continue;
      }

      break;
    }

    Node? orElse;

    if (tag.test('name', 'else')) {
      orElse = parseStatements(reader, endIf, true);
    }

    var node = ifNodes.last.copyWith(orElse: orElse);

    for (var ifNode in ifNodes.reversed.skip(1)) {
      node = ifNode.copyWith(orElse: node);
    }

    return node;
  }

  With parseWith(TokenReader reader) {
    const endWith = <(String, String?)>[('name', 'endwith')];

    reader.expect('name', 'with');

    var targets = <Expression>[];
    var values = <Expression>[];

    while (!reader.current.test('block_end')) {
      if (targets.isNotEmpty) {
        reader.expect('comma');
      }

      var target = parseAssignTarget(reader, context: AssignContext.parameter);
      targets.add(target);
      reader.expect('assign');
      values.add(parseExpression(reader));
    }

    var body = parseStatements(reader, endWith, true);
    return With(targets: targets, values: values, body: body);
  }

  Block parseBlock(TokenReader reader) {
    const endBlock = <(String, String?)>[('name', 'endblock')];

    var token = reader.next();
    var name = reader.expect('name');

    if (!blocks.add(name.value)) {
      fail(
        "Block '${name.value}' defined twice.",
        line: reader.current.line,
        column: reader.current.column,
      );
    }

    var scoped = reader.skipIf('name', 'scoped');

    if (reader.current.test('sub')) {
      fail(
        'Use an underscore instead.',
        line: reader.current.line,
        column: reader.current.column,
      );
    }

    var required = reader.skipIf('name', 'required');
    var body = parseStatements(reader, endBlock, true);

    if (required && (body is! Data || !body.isLeaf)) {
      fail(
        'Required blocks can only contain comments or whitespace.',
        line: token.line,
        column: token.column,
      );
    }

    var maybeName = reader.current;

    if (maybeName.test('name')) {
      if (maybeName.value != name.value) {
        fail(
          "'${name.value}' expected, got ${maybeName.value}.",
          line: maybeName.line,
          column: maybeName.column,
        );
      }

      reader.next();
    }

    return Block(
      name: name.value,
      scoped: scoped,
      required: required,
      body: body,
    );
  }

  Extends parseExtends(TokenReader reader) {
    var token = reader.expect('name', 'extends');

    if (extendsNode != null) {
      fail('Extended multiple times.', line: token.line, column: token.column);
    }

    var template = parseExpression(reader);
    var node = Extends(template: template);
    extendsNode = node;
    return node;
  }

  bool parseImportContext(
    TokenReader reader, [
    bool defaultValue = true,
  ]) {
    const keywords = <(String, String?)>[
      ('name', 'with'),
      ('name', 'without'),
    ];

    var withContext = defaultValue;

    if (reader.current.testAny(keywords) && reader.look().test('name', 'context')) {
      withContext = reader.current.value == 'with';
      reader.skip(2);
    }

    return withContext;
  }

  Include parseInclude(TokenReader reader) {
    reader.expect('name', 'include');

    var template = parseExpression(reader);
    var ignoreMissing = reader.current.test('name', 'ignore') && reader.look().test('name', 'missing');

    if (ignoreMissing) {
      reader.skip(2);
    }

    var withContext = parseImportContext(reader);
    return Include(
      template: template,
      ignoreMissing: ignoreMissing,
      withContext: withContext,
    );
  }

  Import parseImport(TokenReader reader) {
    reader.expect('name', 'import');

    var template = parseExpression(reader);

    reader.expect('name', 'as');

    var target = parseAssignName(reader);
    var withContext = parseImportContext(reader, false);
    return Import(
      template: template,
      target: target.name,
      withContext: withContext,
    );
  }

  FromImport parseFrom(TokenReader reader) {
    reader.expect('name', 'from');

    var template = parseExpression(reader);

    reader.expect('name', 'import');

    var names = <(String, String?)>[]; // target & alias
    var withContext = false;

    bool parseContext() {
      if (reader.current.value case 'with' || 'without' when reader.look().test('name', 'context')) {
        withContext = reader.current.value == 'with';
        reader.skip(2);
        return true;
      } else {
        return false;
      }
    }

    while (true) {
      if (names.isNotEmpty) {
        reader.expect('comma');
      }

      if (reader.current.type == 'name') {
        if (parseContext()) {
          break;
        }

        var token = reader.current;
        var target = parseAssignTarget(reader, withTuple: false);

        if (target is! Name) {
          fail(
            "Can't assign to $target.",
            line: token.line,
            column: token.column,
          );
        }

        if (target.name.startsWith('_')) {
          fail(
            'Names starting with an underline can not be imported.',
            line: token.line,
            column: token.column,
          );
        }

        if (reader.skipIf('name', 'as')) {
          var alias = parseAssignName(reader);
          names.add((target.name, alias.name));
        } else {
          names.add((target.name, null));
        }

        if (parseContext() || reader.current.type != 'comma') {
          break;
        }
      } else {
        reader.expect('name');
      }
    }

    return FromImport(
      template: template,
      names: names,
      withContext: withContext,
    );
  }

  // TODO(parser): check for duplicate arguments.
  (List<Expression>, List<(Expression, Expression)>) parseSignature(
    TokenReader reader,
  ) {
    var names = <Expression>[];
    var defaults = <Expression>[];

    reader.expect('lparen');

    while (!reader.current.test('rparen')) {
      if (names.isNotEmpty) {
        reader.expect('comma');
      }

      var name = parseAssignName(reader, AssignContext.parameter);

      if (reader.skipIf('assign')) {
        defaults.add(parseExpression(reader));
      } else if (defaults.isNotEmpty) {
        fail(
          'Non-default argument follows default argument.',
          line: reader.current.line,
          column: reader.current.column,
        );
      }

      names.add(name);
    }

    reader.expect('rparen');

    var length = names.length - defaults.length;

    (Expression, Expression) generate(int i) {
      return (names[i + length], defaults[i]);
    }

    return (
      names.sublist(0, length),
      List<(Expression, Expression)>.generate(defaults.length, generate),
    );
  }

  CallBlock parseCallBlock(TokenReader reader) {
    const endCall = <(String, String?)>[('name', 'endcall')];

    var token = reader.expect('name', 'call');

    List<Expression> positional;
    List<(Expression, Expression)> named;

    if (reader.current.test('lparen')) {
      (positional, named) = parseSignature(reader);
    } else {
      positional = const <Expression>[];
      named = const <(Expression, Expression)>[];
    }

    var call = parseExpression(reader);

    if (call is! Call) {
      fail('Expected call.', line: token.line, column: token.column);
    }

    var name = call.value;

    if (name is! Name) {
      fail('Expected call macro name.', line: token.line, column: token.column);
    }

    var body = parseStatements(reader, endCall, true);
    var varargs = false, kwargs = false;

    for (var name in body.findAll<Name>()) {
      switch (name.name) {
        case 'varargs':
          varargs = true;
          break;
        case 'kwargs':
          kwargs = true;
          break;
        default:
      }
    }

    return CallBlock(
      call: call,
      varargs: varargs,
      kwargs: kwargs,
      positional: positional,
      named: named,
      body: body,
      name: name.name,
    );
  }

  FilterBlock parseFilterBlock(TokenReader reader) {
    const endFilter = <(String, String?)>[('name', 'endfilter')];

    reader.expect('name', 'filter');

    var filters = parseFilters(reader, true);
    var body = parseStatements(reader, endFilter, true);
    return FilterBlock(filters: filters, body: body);
  }

  Macro parseMacro(TokenReader reader) {
    const endMacro = <(String, String?)>[('name', 'endmacro')];

    reader.expect('name', 'macro');

    var name = parseAssignName(reader);
    var (positional, named) = parseSignature(reader);
    var body = parseStatements(reader, endMacro, true);

    var varargs = false, kwargs = false, caller = false;

    for (var name in body.findAll<Name>()) {
      switch (name.name) {
        case 'varargs':
          varargs = true;
          break;
        case 'kwargs':
          kwargs = true;
          break;
        case 'caller':
          caller = true;
          break;
        default:
      }
    }

    return Macro(
      name: name.name,
      varargs: varargs,
      kwargs: kwargs,
      caller: caller,
      positional: positional,
      named: named,
      body: body,
    );
  }

  // TODO(parser): add parsePrint

  Name parseAssignName(
    TokenReader reader, [
    AssignContext context = AssignContext.store,
  ]) {
    var name = reader.expect('name');
    return Name(name: name.value, context: context);
  }

  Expression parseAssignNameSpace(TokenReader reader) {
    var line = reader.current.line;

    if (reader.look().test('dot')) {
      var namespace = reader.expect('name');
      reader.expect('dot'); // skip dot

      var attribute = reader.expect('name');
      return NamespaceRef(name: namespace.value, attribute: attribute.value);
    }

    var name = parsePrimary(reader);

    if (name is! Name) {
      fail("Can't assign to $name.", line: line, column: reader.current.column);
    }

    return name.copyWith(context: AssignContext.store);
  }

  Expression parseAssignTarget(
    TokenReader reader, {
    List<(String, String?)>? extraEndRules,
    bool withTuple = true,
    AssignContext context = AssignContext.store,
  }) {
    var line = reader.current.line;
    Expression target;

    if (withTuple) {
      target = parseTuple(
        reader,
        simplified: true,
        extraEndRules: extraEndRules,
      );
    } else {
      target = parsePrimary(reader);
    }

    if (target is Name) {
      return target.copyWith(context: context);
    }

    if (target is Tuple && target.values.any((value) => value is Name)) {
      return target.copyWith(
        values: <Expression>[
          for (var value in target.values.cast<Name>()) value.copyWith(context: context),
        ],
      );
    }

    fail("Can't assign to $target.", line: line, column: reader.current.column);
  }

  Do parseDo(TokenReader reader) {
    reader.expect('name', 'do');

    return Do(value: parseTuple(reader));
  }

  Node parseTryCatch(TokenReader reader) {
    const endTry = <(String, String?)>[('name', 'catch')];
    const endTryCatch = <(String, String?)>[('name', 'endtry')];

    reader.expect('name', 'try');

    var body = parseStatements(reader, endTry);
    reader.expect('name', 'catch');

    var token = reader.current;
    Expression? name;

    if (token.test('name')) {
      name = parseAssignTarget(reader, withTuple: false);

      if (name is! Name) {
        fail("Can't assign to $name.", line: token.line, column: token.column);
      }
    }

    var catchBody = parseStatements(reader, endTryCatch);
    reader.expect('name', 'endtry');
    return TryCatch(body: body, exception: name, catchBody: catchBody);
  }

  AutoEscape parseAutoEscape(TokenReader reader) {
    const endAutoEscape = <(String, String?)>[('name', 'endautoescape')];

    reader.expect('name', 'autoescape');

    var enable = reader.expect('name');

    if (enable.value != 'true' && enable.value != 'false') {
      fail(
        "Expected 'true' or 'false'.",
        line: enable.line,
        column: enable.column,
      );
    }

    var body = parseStatements(reader, endAutoEscape, true);
    return AutoEscape(enable: enable.value == 'true', body: body);
  }

  Break parseBreak(TokenReader reader) {
    reader.expect('name', 'break');
    return const Break();
  }

  Continue parseContinue(TokenReader reader) {
    reader.expect('name', 'continue');
    return const Continue();
  }

  Debug parseDebug(TokenReader reader) {
    reader.expect('name', 'debug');
    return const Debug();
  }

  Trans parseTrans(TokenReader reader) {
    reader.expect('name', 'trans');

    var context = reader.nextIf('string')?.value;
    var trimmed = reader.skipIf('name', 'trimmed');

    var count = parseExpression(reader);

    if (count is! Name && count is! Constant) {
      if (context == null && trimmed == false) {
        // Maybe it's a context string that parseExpression consumed as a string literal?
        if (count is Constant && count.value is String) {
          context = count.value as String;
          count = parseExpression(reader);
        }
      }
    }

    var plural = reader.skipIf('name', 'pluralize');
    Expression? pluralCount;

    if (plural) {
      // If pluralize is present, parse the plural count variable if available
      // The parser logic here needs to be flexible as Jinja's trans tag is complex
      // This is a simplified implementation based on common usage
      if (!reader.current.test('block_end')) {
        pluralCount = parseExpression(reader);
      }
    }

    const endTrans = <(String, String?)>[
      ('name', 'pluralize'),
      ('name', 'endtrans'),
    ];

    var body = parseStatements(reader, endTrans);
    Node? pluralBody;

    if (reader.current.test('name', 'pluralize')) {
      reader.next();
      if (!reader.current.test('block_end')) {
        pluralCount = parseExpression(reader);
      }
      pluralBody = parseStatements(reader, <(String, String?)>[('name', 'endtrans')]);
    }

    reader.expect('name', 'endtrans');

    return Trans(
      body: body,
      plural: pluralBody,
      count: pluralCount ?? (count is! Constant ? count : null), // Only use count if it's an expression/variable
      context: context,
      trimmed: trimmed,
    );
  }

  Expression parseExpression(TokenReader reader, [bool withCondition = true]) {
    if (withCondition) {
      return parseCondition(reader);
    }

    return parseOr(reader);
  }

  Expression parseCondition(TokenReader reader, [bool withCondExpr = true]) {
    var value = parseOr(reader);

    while (reader.skipIf('name', 'if')) {
      var condition = parseOr(reader);

      if (reader.skipIf('name', 'else')) {
        var orElse = parseCondition(reader);
        value = Condition(
          test: condition,
          trueValue: value,
          falseValue: orElse,
        );
      } else {
        value = Condition(test: condition, trueValue: value);
      }
    }

    return value;
  }

  Expression parseOr(TokenReader reader) {
    var left = parseAnd(reader);

    while (reader.skipIf('name', 'or')) {
      var right = parseAnd(reader);
      left = Logical(operator: LogicalOperator.or, left: left, right: right);
    }

    return left;
  }

  Expression parseAnd(TokenReader reader) {
    var left = parseNot(reader);

    while (reader.skipIf('name', 'and')) {
      var right = parseNot(reader);
      left = Logical(operator: LogicalOperator.and, left: left, right: right);
    }

    return left;
  }

  Expression parseNot(TokenReader reader) {
    if (reader.current.test('name', 'not')) {
      reader.next();

      var value = parseNot(reader);
      return Unary(operator: UnaryOperator.not, value: value);
    }

    return parseCompare(reader);
  }

  Expression parseCompare(TokenReader reader) {
    const operators = <(String, String?)>[
      ('eq', null),
      ('ne', null),
      ('lt', null),
      ('lteq', null),
      ('gt', null),
      ('gteq', null),
    ];

    var value = parseMath1(reader);
    var operands = <Operand>[];

    outer:
    while (true) {
      CompareOperator operator;

      if (reader.current.testAny(operators)) {
        var token = reader.current;

        reader.next();

        operator = CompareOperator.parse(token.type);
      } else if (reader.skipIf('name', 'in')) {
        operator = CompareOperator.contains;
      } else if (reader.current.test('name', 'not') && reader.look().test('name', 'in')) {
        reader.skip(2);

        operator = CompareOperator.notContains;
      } else {
        break outer;
      }

      operands.add((operator, parseMath1(reader)));
    }

    if (operands.isEmpty) {
      return value;
    }

    return Compare(value: value, operands: operands);
  }

  Expression parseMath1(TokenReader reader) {
    var left = parseConcat(reader);

    outer:
    while (true) {
      ScalarOperator operator;

      switch (reader.current.type) {
        case 'add':
          reader.next();
          operator = ScalarOperator.plus;
          break;

        case 'sub':
          reader.next();
          operator = ScalarOperator.minus;
          break;

        default:
          break outer;
      }

      var right = parseConcat(reader);
      left = Scalar(operator: operator, left: left, right: right);
    }

    return left;
  }

  Expression parseConcat(TokenReader reader) {
    var values = <Expression>[parseMath2(reader)];

    while (reader.current.test('tilde')) {
      reader.next();

      values.add(parseMath2(reader));
    }

    if (values.length == 1) {
      return values[0];
    }

    return Concat(values: values);
  }

  Expression parseMath2(TokenReader reader) {
    var left = parsePow(reader);

    outer:
    while (true) {
      ScalarOperator operator;

      switch (reader.current.type) {
        case 'mul':
          reader.next();

          operator = ScalarOperator.multiple;
          break;

        case 'div':
          reader.next();

          operator = ScalarOperator.division;
          break;

        case 'floordiv':
          reader.next();

          operator = ScalarOperator.floorDivision;
          break;

        case 'mod':
          reader.next();

          operator = ScalarOperator.module;
          break;

        default:
          break outer;
      }

      var right = parsePow(reader);
      left = Scalar(operator: operator, left: left, right: right);
    }

    return left;
  }

  Expression parsePow(TokenReader reader) {
    var left = parseUnary(reader);

    while (reader.current.test('pow')) {
      reader.next();

      var right = parseUnary(reader);
      left = Scalar(operator: ScalarOperator.power, left: left, right: right);
    }

    return left;
  }

  Expression parseUnary(TokenReader reader, {bool withFilter = true}) {
    Expression value;

    switch (reader.current.type) {
      case 'add':
        reader.next();

        value = parseUnary(reader, withFilter: false);
        value = Unary(operator: UnaryOperator.plus, value: value);
        break;

      case 'sub':
        reader.next();

        value = parseUnary(reader, withFilter: false);
        value = Unary(operator: UnaryOperator.minus, value: value);
        break;

      default:
        value = parsePrimary(reader);
    }

    value = parsePostfix(reader, value);

    if (withFilter) {
      value = parseFilterExpression(reader, value);
    }

    return value;
  }

  Expression parsePrimary(TokenReader reader) {
    var current = reader.current;
    Expression expression;

    switch (current.type) {
      case 'name':
        switch (current.value) {
          case 'false':
            expression = const Constant(value: false);
            break;

          case 'true':
            expression = const Constant(value: true);
            break;

          case 'null':
            expression = const Constant(value: null);
            break;

          default:
            expression = Name(name: current.value);
        }

        reader.next();
        break;

      case 'string':
        var buffer = StringBuffer(current.value);

        reader.next();

        while (reader.current.test('string')) {
          buffer.write(reader.current.value);
          reader.next();
        }

        var value = buffer.toString();
        // TODO(parser): replace all escaped characters
        value = value.replaceAll(r'\\r', '\r').replaceAll(r'\\n', '\n');
        expression = Constant(value: value);
        break;

      case 'integer':
      case 'float':
        expression = Constant(value: num.parse(current.value));

        reader.next();
        break;

      case 'lparen':
        reader.next();

        expression = parseTuple(reader, explicitParentheses: true);

        reader.expect('rparen');
        break;

      case 'lbracket':
        expression = parseList(reader);
        break;

      case 'lbrace':
        expression = parseDict(reader);
        break;

      default:
        fail(
          'Unexpected ${describeToken(current)}.',
          line: current.line,
          column: current.column,
        );
    }

    return expression;
  }

  Expression parseTuple(
    TokenReader reader, {
    bool simplified = false,
    bool withCondition = true,
    List<(String, String?)>? extraEndRules,
    bool explicitParentheses = false,
  }) {
    Expression Function(TokenReader) parse;

    if (simplified) {
      parse = parsePrimary;
    } else if (withCondition) {
      parse = parseExpression;
    } else {
      parse = (reader) => parseExpression(reader, false);
    }

    var values = <Expression>[];
    var isTuple = false;

    while (true) {
      if (values.isNotEmpty) {
        reader.expect('comma');
      }

      if (isTupleEnd(reader, extraEndRules)) {
        break;
      }

      values.add(parse(reader));

      if (reader.current.test('comma')) {
        isTuple = true;
      } else {
        break;
      }
    }

    if (!isTuple) {
      if (values.isNotEmpty) {
        return values.first;
      }

      if (!explicitParentheses) {
        var current = reader.current;
        fail(
          'Expected an expression, got ${describeToken(current)}.',
          line: current.line,
          column: current.column,
        );
      }
    }

    return Tuple(values: values);
  }

  Expression parseList(TokenReader reader) {
    reader.expect('lbracket');

    var values = <Expression>[];

    while (!reader.current.test('rbracket')) {
      if (values.isNotEmpty) {
        reader.expect('comma');
      }

      if (reader.current.test('rbracket')) {
        break;
      }

      values.add(parseExpression(reader));
    }

    reader.expect('rbracket');

    return Array(values: values);
  }

  Expression parseDict(TokenReader reader) {
    reader.expect('lbrace');

    var pairs = <Pair>[];

    while (!reader.current.test('rbrace')) {
      if (pairs.isNotEmpty) {
        reader.expect('comma');
      }

      if (reader.current.test('rbrace')) {
        break;
      }

      var key = parseExpression(reader);

      reader.expect('colon');

      var value = parseExpression(reader);
      pairs.add((key: key, value: value));
    }

    reader.expect('rbrace');

    return Dict(pairs: pairs);
  }

  Expression parsePostfix(TokenReader reader, Expression expression) {
    while (true) {
      if (reader.current.test('dot') || reader.current.test('lbracket')) {
        expression = parseSubscript(reader, expression);
      } else if (reader.current.test('lparen')) {
        expression = parseCall(reader, expression);
      } else {
        break;
      }
    }

    return expression;
  }

  // TODO(parser): check if filters and tests exist, else throw TemplateAssertionError
  Expression parseFilterExpression(TokenReader reader, Expression expression) {
    while (true) {
      if (reader.current.test('pipe')) {
        expression = parseFilter(reader, expression);
      } else if (reader.current.test('name', 'is')) {
        expression = parseTest(reader, expression);
      } else if (reader.current.test('lparen')) {
        expression = parseCall(reader, expression);
      } else {
        break;
      }
    }

    return expression;
  }

  Expression parseSubscript(TokenReader reader, Expression value) {
    var token = reader.next();

    if (token.test('dot')) {
      var attributeToken = reader.next();

      if (attributeToken.test('name')) {
        return Attribute(attribute: attributeToken.value, value: value);
      }

      if (!attributeToken.test('integer')) {
        fail(
          'Expected name or number.',
          line: attributeToken.line,
          column: attributeToken.column,
        );
      }

      var key = Constant(value: int.parse(attributeToken.value));
      return Item(key: key, value: value);
    }

    if (token.test('lbracket')) {
      if (reader.nextIf('colon') != null) {
        var stop = parseExpression(reader);
        reader.expect('rbracket');
        return Slice(start: null, stop: stop, value: value);
      }
      var key = parseExpression(reader);
      if (reader.nextIf('colon') != null) {
        if (reader.skipIf('rbracket')) {
          return Slice(start: key, value: value);
        } else {
          var stop = parseExpression(reader);
          reader.expect('rbracket');
          return Slice(start: key, stop: stop, value: value);
        }
      } else {
        reader.expect('rbracket');
        return Item(key: key, value: value);
      }
    }

    fail(
      'Expected subscript expression.',
      line: token.line,
      column: token.column,
    );
  }

  Calling parseCalling(TokenReader reader) {
    var token = reader.expect('lparen');
    var arguments = <Expression>[];
    var keywords = <Keyword>[];
    var requireComma = false;

    void ensure(bool ensure) {
      if (!ensure) {
        fail(
          'Invalid syntax for function call expression.',
          line: token.line,
          column: token.column,
        );
      }
    }

    while (!reader.current.test('rparen')) {
      if (requireComma) {
        reader.expect('comma');

        if (reader.current.test('rparen')) {
          break;
        }
      }

      if (reader.current.test('name') && reader.look().test('assign')) {
        var key = reader.current.value;

        reader.skip(2);

        var value = parseExpression(reader);

        if (key == 'default') {
          key = 'defaultValue';
        }

        keywords.add((key: key, value: value));
      } else {
        ensure(keywords.isEmpty);
        arguments.add(parseExpression(reader));
      }

      requireComma = true;
    }

    reader.expect('rparen');

    return Calling(
      arguments: arguments,
      keywords: keywords,
    );
  }

  Call parseCall(TokenReader reader, Expression expression) {
    var calling = parseCalling(reader);
    return Call(value: expression, calling: calling);
  }

  Expression parseFilter(TokenReader reader, Expression expression) {
    var filters = parseFilters(reader);

    for (var filter in filters) {
      expression = filter.copyWith(
        calling: filter.calling.copyWith(
          arguments: <Expression>[expression, ...filter.calling.arguments],
        ),
      );
    }

    return expression;
  }

  List<Filter> parseFilters(TokenReader reader, [bool startInline = false]) {
    var filters = <Filter>[];

    while (reader.current.test('pipe') || startInline) {
      if (!startInline) {
        reader.next();
      }

      var token = reader.expect('name');
      var filter = Filter(name: token.value);

      if (reader.current.test('lparen')) {
        var calling = parseCalling(reader);
        filter = filter.copyWith(calling: calling);
      }

      filters.add(filter);
      startInline = false;
    }

    return filters;
  }

  Expression parseTest(TokenReader reader, Expression expression) {
    const allow = <(String, String?)>[
      ('name', null),
      ('string', null),
      ('integer', null),
      ('float', null),
      ('lbracket', null),
      ('lbrace', null),
    ];
    const deny = <(String, String?)>[
      ('name', 'else'),
      ('name', 'or'),
      ('name', 'and'),
    ];

    reader.expect('name', 'is');

    var negated = false;

    if (reader.current.test('name', 'not')) {
      reader.next();

      negated = true;
    }

    var token = reader.expect('name');
    var current = reader.current;

    Calling calling;

    if (current.test('lparen')) {
      calling = parseCalling(reader);

      var arguments = <Expression>[expression, ...calling.arguments];
      calling = calling.copyWith(arguments: arguments);
    } else if (current.testAny(allow) && !current.testAny(deny)) {
      if (current.test('name', 'is')) {
        fail(
          'You cannot chain multiple tests with is.',
          line: reader.current.line,
          column: reader.current.column,
        );
      }

      var argument = parsePostfix(reader, parsePrimary(reader));
      calling = Calling(arguments: <Expression>[expression, argument]);
    } else {
      calling = Calling(arguments: <Expression>[expression]);
    }

    expression = Test(name: token.value, calling: calling);

    if (negated) {
      expression = Unary(operator: UnaryOperator.not, value: expression);
    }

    return expression;
  }

  Node scan(Iterable<Token> tokens) {
    var reader = TokenReader(tokens);
    var nodes = subParse(reader);
    return Output(nodes: nodes);
  }

  List<Node> subParse(
    TokenReader reader, {
    List<(String, String?)>? endTokens,
  }) {
    var nodes = <Node>[];

    if (endTokens != null) {
      endTokensStack.add(endTokens);
    }

    try {
      while (!reader.current.test('eof')) {
        var token = reader.current;

        switch (token.type) {
          case 'data':
            nodes.add(Data(data: token.value, line: token.line, column: token.column));

            reader.next();
            break;

          case 'variable_start':
            var startToken = token;
            reader.next();

            nodes.add(Interpolation(value: parseTuple(reader), line: startToken.line, column: startToken.column));

            reader.expect('variable_end');
            break;

          case 'block_start':
            reader.next();

            if (endTokens != null && reader.current.testAny(endTokens)) {
              return nodes;
            }

            var node = parseStatement(reader);

            if (extendsNode != null && node is! Block) {
              fill('');
            }

            nodes.add(node);

            reader.expect('block_end');
            break;

          default:
            assert(false, 'Unreachable');
        }
      }
    } finally {
      if (endTokens != null) {
        endTokensStack.removeLast();
      }
    }

    return nodes;
  }

  Node parse(String template) {
    var tokens = environment.lex(template, path: path);
    return TemplateNode(body: scan(tokens));
  }
}
