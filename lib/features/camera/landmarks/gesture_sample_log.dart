import 'dart:io';

import 'package:handy/features/camera/landmarks/coordinate_normalizer.dart';
import 'package:path_provider/path_provider.dart';

/// Every saved motion is resampled to this many frames.
const int gestureFrameCount = 30;

/// How long one gesture performance is recorded.
const Duration gestureRecordDuration = Duration(milliseconds: 1500);

/// Trims or pads a recorded motion so every sample has [targetLength] frames.
List<List<double>> normalizeSequenceLength(
  List<List<double>> frames,
  int targetLength,
) {
  if (frames.isEmpty || frames.length == targetLength) {
    return frames;
  }
  if (frames.length > targetLength) {
    final step = frames.length / targetLength;
    return List<List<double>>.generate(
      targetLength,
      (index) => frames[(index * step).floor()],
      growable: false,
    );
  }

  final padded = List<List<double>>.from(frames);
  final lastFrame = frames.last;
  while (padded.length < targetLength) {
    padded.add(lastFrame);
  }
  return padded;
}

/// Appends one full gesture (30 frames × 63 landmarks) to a CSV file.
class GestureSampleLog {
  GestureSampleLog._(this.file, this.count);

  final File file;
  int count;

  Future<void> _writes = Future<void>.value();

  static String get csvHeader {
    final columns = <String>[];
    for (var frame = 0; frame < gestureFrameCount; frame++) {
      for (var joint = 0; joint < landmarkCount; joint++) {
        columns
          ..add('f${frame}_x$joint')
          ..add('f${frame}_y$joint')
          ..add('f${frame}_z$joint');
      }
    }
    return columns.join(',');
  }

  static Future<GestureSampleLog> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/gesture_samples.csv');
    if (!await file.exists() || await file.length() == 0) {
      await file.writeAsString('label,$csvHeader\n');
      return GestureSampleLog._(file, 0);
    }

    final lines = await file.readAsLines();
    final dataRows = lines.where((line) => line.trim().isNotEmpty).length;
    final hasHeader = lines.isNotEmpty && lines.first.startsWith('label,');
    return GestureSampleLog._(file, hasHeader ? dataRows - 1 : dataRows);
  }

  /// Writes one gesture. Returns false when no frames were captured.
  Future<bool> append(String label, List<List<double>> frames) async {
    if (frames.isEmpty) {
      return false;
    }

    final normalized = normalizeSequenceLength(frames, gestureFrameCount);
    final flatValues = normalized
        .expand((frame) => frame)
        .map((value) => value.toStringAsFixed(6))
        .join(',');
    final row = '${_escapeCsv(label.trim())},$flatValues\n';
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
