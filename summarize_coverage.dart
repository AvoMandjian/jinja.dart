import 'dart:io';

class CoverageSummary {
  int total = 0;
  int hit = 0;
}

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('coverage/lcov.info not found');
    return;
  }

  final lines = file.readAsLinesSync();
  var totalLines = 0;
  var hitLines = 0;
  String? currentFile;
  final summaries = <String, CoverageSummary>{};

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      summaries.putIfAbsent(currentFile, () => CoverageSummary());
    } else if (line.startsWith('LF:')) {
      final val = int.parse(line.substring(3));
      totalLines += val;
      if (currentFile != null) {
        summaries[currentFile]!.total += val;
      }
    } else if (line.startsWith('LH:')) {
      final val = int.parse(line.substring(3));
      hitLines += val;
      if (currentFile != null) {
        summaries[currentFile]!.hit += val;
      }
    }
  }

  print('Total coverage: $hitLines / $totalLines (${(hitLines / totalLines * 100).toStringAsFixed(2)}%)');
  print('\nFile coverage:');
  final sortedPaths = summaries.keys.toList()..sort();
  for (final path in sortedPaths) {
    final summary = summaries[path]!;
    final pct = (summary.hit / summary.total * 100).toStringAsFixed(2);
    print('${path.padRight(40)}: ${summary.hit} / ${summary.total} ($pct%)');
  }
}
