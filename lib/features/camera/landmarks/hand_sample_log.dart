import 'dart:io';

import 'package:handy/features/camera/landmarks/coordinate_normalizer.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:path_provider/path_provider.dart';

/// Appends normalized hand poses to a CSV file on the device.
class HandSampleLog {
  HandSampleLog._(this.file, this.count);

  final File file;
  int count;

  Future<void> _writes = Future<void>.value();

  static Future<HandSampleLog> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/hand_samples.csv');
    if (!await file.exists() || await file.length() == 0) {
      await file.writeAsString('label,${NormalizedHandSample.csvHeader}\n');
      return HandSampleLog._(file, 0);
    }

    final lines = await file.readAsLines();
    final dataRows = lines.where((line) => line.trim().isNotEmpty).length;
    final hasHeader = lines.isNotEmpty && lines.first.startsWith('label,');
    return HandSampleLog._(file, hasHeader ? dataRows - 1 : dataRows);
  }

  /// Writes one labeled sample. Returns false when the hand cannot be normalized.
  Future<bool> append(String label, Hand hand) async {
    final sample = normalizeHand(hand);
    if (sample == null) {
      return false;
    }

    final row = '${_escapeCsv(label.trim())},${sample.toCsvRow()}\n';
    final done = _writes.then(
      (_) => file.writeAsString(row, mode: FileMode.append),
    );
    _writes = done.then((_) {}, onError: (Object _) {});
    await done;
    count += 1;
    return true;
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
