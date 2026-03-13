@TestOn('vm || chrome')
library;

import 'package:jinja/src/nodes.dart';
import 'package:jinja/src/visitor.dart';
import 'package:test/test.dart';

final class _TestExpression extends Expression {
  const _TestExpression();

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    // Never called in these tests.
    throw UnimplementedError();
  }

  @override
  _TestExpression copyWith() {
    return this;
  }

  @override
  Iterable<T> findAll<T extends Node>() sync* {}

  @override
  String toSource() {
    return 'expr';
  }
}

void main() {
  group('Data', () {
    test('literal escapes quotes and newlines', () {
      const data = Data(data: 'a"b\r\nc\nd');
      expect(data.literal, '"a\\"b\\nc\\nd"');
    });

    test('copyWith updates data', () {
      const original = Data(data: 'x');
      final copy = original.copyWith(data: 'y');
      expect(copy.data, 'y');
    });
  });

  group('Expression base', () {
    test('toJson uses Expression class name', () {
      const expr = _TestExpression();
      final json = expr.toJson();
      expect(json['class'], equals('Expression'));
    });
  });

  group('Slice', () {
    test('findAll, toJson and toSource', () {
      const value = Constant(value: 10);
      const start = Constant(value: 1);
      const stop = Constant(value: 3);

      const slice = Slice(value: value, start: start, stop: stop);

      final found = slice.findAll<Constant>().toList();
      expect(found, contains(value));

      final json = slice.toJson();
      expect(json['class'], equals('Slice'));
      expect(json['start'], isNotNull);
      expect(json['stop'], isNotNull);

      expect(slice.toSource(), equals('10[1:3]'));
    });
  });

  group('Interpolation', () {
    test('copyWith, findAll, toJson and toSource', () {
      const value = Constant(value: 1);
      const interpolation = Interpolation(value: value);

      final updated = interpolation.copyWith(
        value: Constant(value: 2),
      );
      expect(updated.value, isA<Constant>());

      final unchanged = interpolation.copyWith();
      expect(unchanged.value, same(value));

      final found = interpolation.findAll<Constant>().toList();
      expect(found, contains(value));

      final json = interpolation.toJson();
      expect(json['class'], equals('Interpolation'));
      expect(json['value'], isNotNull);

      expect(interpolation.toSource(), equals('{{ 1 }}'));
    });
  });

  group('Output', () {
    test('findAll, toJson and toSource', () {
      const first = Data(data: 'Hello');
      const second = Data(data: 'World');

      const output = Output(nodes: <Node>[first, second]);

      final found = output.findAll<Data>().toList();
      expect(found, equals(<Data>[first, second]));

      final json = output.toJson();
      expect(json['class'], equals('Output'));
      expect((json['nodes'] as List).length, equals(2));

      expect(output.toSource(), equals('HelloWorld'));
    });
  });

  group('TemplateNode', () {
    test('copyWith, findAll, toJson and toSource', () {
      const body = Data(data: 'root');

      final block = Block(
        name: 'b',
        scoped: false,
        required: false,
        body: TemplateNode(body: Data(data: 'block')),
      );

      final macro = Macro(
        name: 'm',
        body: TemplateNode(body: Data(data: 'macro')),
      );

      final template = TemplateNode(
        blocks: <Block>[block],
        macros: <Macro>[macro],
        body: body,
      );

      final updated = template.copyWith(
        body: Data(data: 'updated'),
      );
      expect(updated.body, isA<Data>());

      final unchanged = template.copyWith();
      expect(unchanged.body, same(body));

      final found = template.findAll<Data>().toList();
      expect(found, contains(body));

      final json = template.toJson();
      expect(json['class'], equals('TemplateNode'));
      final blocks = json['blocks'] as List;
      final macros = json['macros'] as List;
      expect(blocks, isNotEmpty);
      expect(macros, isNotEmpty);

      expect(template.toSource(), equals('root'));
    });
  });

  group('Extends', () {
    test('toJson and toSource', () {
      const node = Extends(template: Constant(value: 'base.html'));
      expect(node.toJson(), {
        'class': 'Extends',
        'template': {'class': 'Constant', 'value': 'base.html'},
      });
      expect(node.toSource(), "{% extends 'base.html' %}");
    });

    test('copyWith', () {
      const node = Extends(template: Constant(value: 'base.html'));
      final copy = node.copyWith(template: Constant(value: 'other.html'));
      expect(
        copy.template,
        isA<Constant>().having((c) => c.value, 'value', 'other.html'),
      );
    });
  });

  group('For', () {
    test('toJson and toSource', () {
      final node = For(
        target: Name(name: 'item'),
        iterable: Name(name: 'items'),
        body: Data(data: 'foo'),
      );
      expect(node.toJson(), {
        'class': 'For',
        'target': {'class': 'Name', 'name': 'item', 'context': 'load'},
        'iterable': {'class': 'Name', 'name': 'items', 'context': 'load'},
        'body': {'class': 'Data', 'data': 'foo'},
      });
      expect(node.toSource(), '{% for item in items %}');
    });

    test('findAll', () {
      final node = For(
        target: Name(name: 'item'),
        iterable: Name(name: 'items'),
        body: Data(data: 'foo'),
      );
      expect(node.findAll<Name>(), hasLength(2));
      expect(node.findAll<Data>(), hasLength(1));
    });
  });

  group('If', () {
    test('toJson and toSource', () {
      const node = If(
        test: Name(name: 'cond'),
        body: Data(data: 'true'),
        orElse: Data(data: 'false'),
      );
      expect(node.toJson(), {
        'class': 'If',
        'test': {'class': 'Name', 'name': 'cond', 'context': 'load'},
        'body': {'class': 'Data', 'data': 'true'},
        'orElse': {'class': 'Data', 'data': 'false'},
      });
      expect(node.toSource(), '{% if cond %}');
    });
  });

  group('Include', () {
    test('toJson and toSource', () {
      const node = Include(template: Constant(value: 'header.html'));
      expect(node.toJson(), {
        'class': 'Include',
        'template': {'class': 'Constant', 'value': 'header.html'},
        'withContext': true,
      });
      expect(node.toSource(), "{% include 'header.html' %}");
    });
  });

  group('Assign', () {
    test('toJson and toSource', () {
      const node = Assign(
        target: Name(name: 'var'),
        value: Constant(value: 42),
      );
      expect(node.toJson(), {
        'class': 'Assign',
        'target': {'class': 'Name', 'name': 'var', 'context': 'load'},
        'value': {'class': 'Constant', 'value': 42},
      });
      expect(node.toSource(), '{% set var = 42 %}');
    });
  });

  group('AssignBlock', () {
    test('toJson and toSource', () {
      final node = AssignBlock(
        target: Name(name: 'var'),
        body: Data(data: 'foo'),
      );
      expect(node.toJson(), {
        'class': 'AssignBlock',
        'target': {'class': 'Name', 'name': 'var', 'context': 'load'},
        'filters': [],
        'body': {'class': 'Data', 'data': 'foo'},
      });
      expect(node.toSource(), '{% set var %}foo{% endset %}');
    });
  });

  group('Block', () {
    test('toJson and toSource', () {
      const node = Block(
        name: 'title',
        scoped: false,
        required: false,
        body: Data(data: 'foo'),
      );
      expect(node.toJson(), {
        'class': 'Block',
        'name': 'title',
        'body': {'class': 'Data', 'data': 'foo'},
      });
      expect(node.toSource(), '{% block title %}foo{% endblock %}');
    });
  });

  group('CallBlock', () {
    test('toJson and toSource', () {
      final node = CallBlock(
        name: 'caller',
        call: Call(value: Name(name: 'test')),
        body: Data(data: 'foo'),
      );
      expect(node.toJson(), {
        'class': 'CallBlock',
        'call': {
          'class': 'Call',
          'value': {'class': 'Name', 'name': 'test', 'context': 'load'},
          'calling': {'class': 'Calling', 'arguments': [], 'keywords': []},
        },
        'positional': [],
        'named': [],
        'body': {'class': 'Data', 'data': 'foo'},
      });
      expect(node.toSource(), '{% call test() %}foo{% endcall %}');
    });
  });

  group('Do', () {
    test('toJson and toSource', () {
      final node = Do(value: Call(value: Name(name: 'func')));
      expect(node.toJson(), {
        'class': 'Do',
        'value': {
          'class': 'Call',
          'value': {'class': 'Name', 'name': 'func', 'context': 'load'},
          'calling': {'class': 'Calling', 'arguments': [], 'keywords': []},
        },
      });
      expect(node.toSource(), '{% do func() %}');
    });
  });

  group('Macro', () {
    test('toJson and toSource', () {
      const node = Macro(
        name: 'test',
        body: Data(data: 'foo'),
      );
      expect(node.toJson(), {
        'class': 'Macro',
        'name': 'test',
        'positional': [],
        'named': [],
        'caller': false,
        'body': {'class': 'Data', 'data': 'foo'},
      });
      expect(node.toSource(), '{% macro test() %}foo{% endmacro %}');
    });
  });

  group('With', () {
    test('toJson and toSource', () {
      const node = With(
        targets: [Name(name: 'x')],
        values: [Constant(value: 1)],
        body: Data(data: 'foo'),
      );
      expect(node.toJson(), {
        'class': 'With',
        'targets': [
          {'class': 'Name', 'name': 'x', 'context': 'load'},
        ],
        'values': [
          {'class': 'Constant', 'value': 1},
        ],
        'body': {'class': 'Data', 'data': 'foo'},
      });
      expect(node.toSource(), '{% with x = 1 %}foo{% endwith %}');
    });
  });

  group('Array', () {
    test('toJson and toSource', () {
      const node = Array(values: [Constant(value: 1), Constant(value: 2)]);
      expect(node.toJson(), {
        'class': 'Array',
        'values': [
          {'class': 'Constant', 'value': 1},
          {'class': 'Constant', 'value': 2},
        ],
      });
      expect(node.toSource(), '[1, 2]');
    });
  });

  group('Dict', () {
    test('toJson and toSource', () {
      const node = Dict(
        pairs: [(key: Constant(value: 'a'), value: Constant(value: 1))],
      );
      expect(node.toJson(), {
        'class': 'Dict',
        'pairs': [
          {
            'key': {'class': 'Constant', 'value': 'a'},
            'value': {'class': 'Constant', 'value': 1},
          }
        ],
      });
      expect(node.toSource(), "{'a': 1}");
    });
  });

  group('Attribute', () {
    test('toJson and toSource', () {
      const node = Attribute(value: Name(name: 'foo'), attribute: 'bar');
      expect(node.toJson(), {
        'class': 'Attribute',
        'value': {'class': 'Name', 'name': 'foo', 'context': 'load'},
        'attribute': 'bar',
      });
      expect(node.toSource(), 'foo.bar');
    });
  });

  group('Item', () {
    test('toJson and toSource', () {
      const node = Item(value: Name(name: 'foo'), key: Constant(value: 'bar'));
      expect(node.toJson(), {
        'class': 'Item',
        'value': {'class': 'Name', 'name': 'foo', 'context': 'load'},
        'key': {'class': 'Constant', 'value': 'bar'},
      });
      expect(node.toSource(), "foo['bar']");
    });
  });

  group('Filter', () {
    test('toJson and toSource', () {
      const node = Filter(
        name: 'upper',
        calling: Calling(arguments: [Name(name: 'foo')]),
      );
      expect(node.toJson(), {
        'class': 'Filter',
        'name': 'upper',
        'calling': {
          'class': 'Calling',
          'arguments': [
            {'class': 'Name', 'name': 'foo', 'context': 'load'},
          ],
          'keywords': [],
        },
      });
      expect(node.toSource(), 'foo|upper');
    });
  });

  group('Test', () {
    test('toJson and toSource', () {
      const node = Test(
        name: 'defined',
        calling: Calling(arguments: [Name(name: 'foo')]),
      );
      expect(node.toJson(), {
        'class': 'Test',
        'name': 'defined',
        'calling': {
          'class': 'Calling',
          'arguments': [
            {'class': 'Name', 'name': 'foo', 'context': 'load'},
          ],
          'keywords': [],
        },
      });
      expect(node.toSource(), 'foo is defined');
    });
  });

  group('Logical', () {
    test('toJson and toSource', () {
      const node = Logical(
        operator: LogicalOperator.and,
        left: Constant(value: true),
        right: Constant(value: false),
      );
      expect(node.toJson(), {
        'class': 'Logical',
        'operator': 'and',
        'left': {'class': 'Constant', 'value': true},
        'right': {'class': 'Constant', 'value': false},
      });
      expect(node.toSource(), 'true and false');
    });
  });

  group('Scalar', () {
    test('toJson and toSource', () {
      const node = Scalar(
        operator: ScalarOperator.plus,
        left: Constant(value: 1),
        right: Constant(value: 2),
      );
      expect(node.toJson(), {
        'class': 'Scalar',
        'operator': '+',
        'left': {'class': 'Constant', 'value': 1},
        'right': {'class': 'Constant', 'value': 2},
      });
      expect(node.toSource(), '1 + 2');
    });
  });

  group('Unary', () {
    test('toJson and toSource', () {
      const node = Unary(
        operator: UnaryOperator.not,
        value: Constant(value: true),
      );
      expect(node.toJson(), {
        'class': 'Unary',
        'operator': 'not',
        'value': {'class': 'Constant', 'value': true},
      });
      expect(node.toSource(), 'not true');
    });
  });

  group('Compare', () {
    test('toJson and toSource', () {
      const node = Compare(
        value: Constant(value: 1),
        operands: [(CompareOperator.equal, Constant(value: 1))],
      );
      expect(node.toJson(), {
        'class': 'Compare',
        'value': {'class': 'Constant', 'value': 1},
        'operands': [
          {
            'operand': '==',
            'value': {'class': 'Constant', 'value': 1},
          }
        ],
      });
      expect(node.toSource(), '1 == 1');
    });
  });

  group('Concat', () {
    test('toJson and toSource', () {
      const node = Concat(values: [Constant(value: 'a'), Constant(value: 'b')]);
      expect(node.toJson(), {
        'class': 'Concat',
        'values': [
          {'class': 'Constant', 'value': 'a'},
          {'class': 'Constant', 'value': 'b'},
        ],
      });
      expect(node.toSource(), "'a' ~ 'b'");
    });
  });

  group('Condition', () {
    test('toJson and toSource', () {
      const node = Condition(
        test: Name(name: 'cond'),
        trueValue: Constant(value: 1),
        falseValue: Constant(value: 2),
      );
      expect(node.toJson(), {
        'class': 'Condition',
        'test': {'class': 'Name', 'name': 'cond', 'context': 'load'},
        'trueValue': {'class': 'Constant', 'value': 1},
        'falseValue': {'class': 'Constant', 'value': 2},
      });
      expect(node.toSource(), '1 if cond else 2');
    });
  });
}
