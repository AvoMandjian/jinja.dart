import 'package:jinja/src/environment.dart';
import 'package:jinja/src/filters.dart';
import 'package:jinja/src/runtime.dart';
import 'package:jinja/src/exceptions.dart';
import 'package:jinja/src/utils.dart' as utils;
import 'package:test/test.dart';

void main() {
  final env = Environment();

  group('Filters Coverage Extensions 2', () {
    test('doReplaceEach with count', () {
      // doReplaceEach treats 'from' as a single string when count is provided
      // which is different from when count is null (where it treats each char)
      // This is the current behavior in lib/src/filters.dart:121-128
      expect(doReplaceEach('hello hello', 'lo', 'lp', 1), equals('hellp hello'));
      expect(doReplaceEach('hello hello', 'lo', 'lp', 2), equals('hellp hellp'));
    });

    test('doRegexReplace dead code access', () {
      // Just to cover the lines 134-141 if they are reachable somehow
      // though they aren't in the filters map.
      // ignore: deprecated_member_use_from_same_package
      expect(doRegexReplace('foo-123-bar', '\\d+', '#'), equals('foo-#-bar'));
    });

    test('doSelect with non-existent test', () {
      final context = Context(env);
      expect(
        () => doSelect(context, [1, 2, 3], 'non_existent_test'),
        throwsA(isA<TemplateRuntimeError>()),
      );
    });

    test('doSelect with test as ContextFilter', () {
      final myEnv = Environment();
      myEnv.tests['is_context_filter'] = utils.ContextFilter((Context c, Object? val) => val == 42);
      
      final context = Context(myEnv);
      final result = doSelect(context, [41, 42, 43], 'is_context_filter');
      expect(result, equals([42]));
    });

    test('doSelect with test as EnvFilter', () {
      final myEnv = Environment();
      myEnv.tests['is_env_filter'] = utils.EnvFilter((Environment e, Object? val) => val == 42);
      
      final context = Context(myEnv);
      final result = doSelect(context, [41, 42, 43], 'is_env_filter');
      expect(result, equals([42]));
    });

    test('doSelect with invalid test type', () {
      final myEnv = Environment();
      // Using a type that is not Function, ContextFilter, or EnvFilter
      myEnv.tests['invalid_test'] = 42; 
      
      final context = Context(myEnv);
      expect(
        () => doSelect(context, [1, 2, 3], 'invalid_test'),
        throwsA(isA<TemplateRuntimeError>()),
      );
    });

    test('doReject with non-existent test', () {
      final context = Context(env);
      expect(
        () => doReject(context, [1, 2, 3], 'non_existent_test'),
        throwsA(isA<TemplateRuntimeError>()),
      );
    });

    test('doReject with test as ContextFilter', () {
      final myEnv = Environment();
      myEnv.tests['is_context_filter'] = utils.ContextFilter((Context c, Object? val) => val == 42);
      
      final context = Context(myEnv);
      final result = doReject(context, [41, 42, 43], 'is_context_filter');
      expect(result, equals([41, 43]));
    });

    test('doReject with test as EnvFilter', () {
      final myEnv = Environment();
      myEnv.tests['is_env_filter'] = utils.EnvFilter((Environment e, Object? val) => val == 42);
      
      final context = Context(myEnv);
      final result = doReject(context, [41, 42, 43], 'is_env_filter');
      expect(result, equals([41, 43]));
    });

    test('doMap with Attribute/Item string', () {
      final myEnv = Environment();
      final context = Context(myEnv);
      final data = [{'name': 'a'}, {'name': 'b'}];
      
      // doMap(context, values, positional, named)
      final result = doMap(context, data, [], {'attribute': 'name'}).toList();
      expect(result, equals(['a', 'b']));
    });

    test('doMap with nested Attribute/Item string', () {
      final myEnv = Environment();
      final context = Context(myEnv);
      final data = [{'user': {'name': 'a'}}, {'user': {'name': 'b'}}];
      
      final result = doMap(context, data, [], {'attribute': 'user.name'}).toList();
      expect(result, equals(['a', 'b']));
    });
  });
}
