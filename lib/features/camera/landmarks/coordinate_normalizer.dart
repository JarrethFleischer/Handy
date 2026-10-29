import 'dart:math' as math;

import 'package:handy/features/camera/landmarks/landmark_extractor.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

/// Wrist landmark used as the origin for relative translation.
const int wristIndex = 0;

/// Middle-finger MCP landmark used as the fixed scale segment.
const int middleFingerMcpIndex = 9;

/// MediaPipe Hands always reports 21 landmarks.
const int landmarkCount = 21;

/// Flattened feature length: 21 landmarks × (x, y, z).
const int normalizedFeatureCount = landmarkCount * 3;

/// One training sample: 63 normalized coordinates, ready to append to a CSV.
class NormalizedHandSample {
  const NormalizedHandSample(this.values);

  /// Flat row: `[x0, y0, z0, x1, y1, z1, ..., x20, y20, z20]`.
  final List<double> values;

  /// CSV header matching [values], without a label column.
  static String get csvHeader {
    final columns = <String>[];
    for (var index = 0; index < landmarkCount; index++) {
      columns
        ..add('x$index')
        ..add('y$index')
        ..add('z$index');
    }
    return columns.join(',');
  }

  /// One CSV data row. Pass [label] to prefix a class such as `A`.
  String toCsvRow({String? label}) {
    final coordinates = values
        .map((value) => value.toStringAsFixed(6))
        .join(',');
    if (label == null || label.isEmpty) {
      return coordinates;
    }
    return '$label,$coordinates';
  }
}

/// Centers the hand on the wrist, scales it, and flattens it to 63 numbers.
///
/// Returns null when the hand does not have 21 landmarks, or when the
/// wrist-to-middle-MCP distance is too small to use as a scale.
NormalizedHandSample? normalizeHandCoordinates(
  List<ExtractedLandmark> landmarks,
) {
  if (landmarks.length < landmarkCount) {
    return null;
  }

  final wrist = landmarks[wristIndex];
  final shifted = List<({double x, double y, double z})>.generate(
    landmarkCount,
    (index) {
      final point = landmarks[index];
      return (x: point.x - wrist.x, y: point.y - wrist.y, z: point.z - wrist.z);
    },
  );

  final middleMcp = shifted[middleFingerMcpIndex];
  final scale = math.sqrt(
    middleMcp.x * middleMcp.x +
        middleMcp.y * middleMcp.y +
        middleMcp.z * middleMcp.z,
  );
  if (scale < 1e-6) {
    return null;
  }

  final flat = List<double>.filled(normalizedFeatureCount, 0);
  for (var index = 0; index < landmarkCount; index++) {
    final point = shifted[index];
    flat[index * 3] = point.x / scale;
    flat[index * 3 + 1] = point.y / scale;
    flat[index * 3 + 2] = point.z / scale;
  }
  return NormalizedHandSample(flat);
}

/// Normalizes one detected hand into a 63-value CSV sample.
NormalizedHandSample? normalizeHand(Hand hand) {
  return normalizeHandCoordinates(extractLandmarks(hand));
}
