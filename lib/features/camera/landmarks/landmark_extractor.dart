import 'package:hand_landmarker/hand_landmarker.dart';

/// MediaPipe Hands joint indices and labels (21 landmarks).
class HandJoint {
  static const names = <String>[
    'Wrist',
    'Thumb CMC',
    'Thumb MCP',
    'Thumb IP',
    'Thumb Tip',
    'Index MCP',
    'Index PIP',
    'Index DIP',
    'Index Tip',
    'Middle MCP',
    'Middle PIP',
    'Middle DIP',
    'Middle Tip',
    'Ring MCP',
    'Ring PIP',
    'Ring DIP',
    'Ring Tip',
    'Pinky MCP',
    'Pinky PIP',
    'Pinky DIP',
    'Pinky Tip',
  ];
}

/// One extracted landmark with index, name, and (x, y, z).
class ExtractedLandmark {
  const ExtractedLandmark({
    required this.index,
    required this.name,
    required this.x,
    required this.y,
    required this.z,
  });

  final int index;
  final String name;
  final double x;
  final double y;
  final double z;

  String get formatted =>
      '[$index] $name  x=${x.toStringAsFixed(3)}  '
      'y=${y.toStringAsFixed(3)}  z=${z.toStringAsFixed(3)}';
}

/// Extracts all 21 joint coordinates from a detected [Hand].
List<ExtractedLandmark> extractLandmarks(Hand hand) {
  final landmarks = hand.landmarks;
  final count = landmarks.length < HandJoint.names.length
      ? landmarks.length
      : HandJoint.names.length;

  return List<ExtractedLandmark>.generate(count, (index) {
    final point = landmarks[index];
    return ExtractedLandmark(
      index: index,
      name: HandJoint.names[index],
      x: point.x,
      y: point.y,
      z: point.z,
    );
  });
}

/// Extracts landmarks for every detected hand in the frame.
List<List<ExtractedLandmark>> extractLandmarksFromHands(List<Hand> hands) {
  return hands.map(extractLandmarks).toList(growable: false);
}
