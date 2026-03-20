import 'dart:io';

void main() async {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('coverage/lcov.info not found');
    return;
  }

  final lines = await file.readAsLines();
  String? currentFile;
  int instrumentedLines = 0;
  int coveredLines = 0;

  print('| File | Coverage % | Covered / Instrumented |');
  print('| --- | --- | --- |');

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      instrumentedLines = 0;
      coveredLines = 0;
    } else if (line.startsWith('DA:')) {
      instrumentedLines++;
      final parts = line.substring(3).split(',');
      if (parts.length == 2 && int.parse(parts[1]) > 0) {
        coveredLines++;
      }
    } else if (line == 'end_of_record') {
      if (currentFile != null && instrumentedLines > 0) {
        final percentage = (coveredLines / instrumentedLines) * 100;
        if (percentage < 100) {
          final relativeFile = currentFile.replaceAll(Directory.current.path + '/', '');
          print('| $relativeFile | ${percentage.toStringAsFixed(1)}% | $coveredLines / $instrumentedLines |');
        }
      }
    }
  }
}
