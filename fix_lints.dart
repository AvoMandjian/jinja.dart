import 'dart:io';

void main() {
  final file = File('test/runtime_test.dart');
  final lines = file.readAsLinesSync();
  final newLines = lines.where((l) => !l.contains("import 'package:jinja/src/nodes.dart';")).toList();
  file.writeAsStringSync(newLines.join('\n') + '\n');
}
