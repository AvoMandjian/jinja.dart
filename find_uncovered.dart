import 'dart:io';

void findUncoveredLines(String targetFile) async {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('coverage/lcov.info not found');
    return;
  }

  final lines = await file.readAsLines();
  bool inTargetFile = false;
  final uncoveredLines = <int>[];

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      inTargetFile = line.endsWith(targetFile);
    } else if (inTargetFile && line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      if (parts.length == 2 && int.parse(parts[1]) == 0) {
        uncoveredLines.add(int.parse(parts[0]));
      }
    } else if (line == 'end_of_record') {
      if (inTargetFile) break;
    }
  }

  if (uncoveredLines.isEmpty) {
    print('No uncovered lines found in $targetFile');
    return;
  }

  print('Uncovered lines in $targetFile:');

  // Group lines into ranges for easier reading
  List<String> ranges = [];
  if (uncoveredLines.isNotEmpty) {
    int start = uncoveredLines[0];
    int end = start;
    for (int i = 1; i < uncoveredLines.length; i++) {
      if (uncoveredLines[i] == end + 1) {
        end = uncoveredLines[i];
      } else {
        ranges.add(start == end ? '$start' : '$start-$end');
        start = uncoveredLines[i];
        end = start;
      }
    }
    ranges.add(start == end ? '$start' : '$start-$end');
  }
  print(ranges.join(', '));
}

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart find_uncovered.dart <filename>');
    return;
  }
  findUncoveredLines(args[0]);
}
