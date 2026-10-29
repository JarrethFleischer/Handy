import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

/// Draws MediaPipe's 21 hand landmarks over the camera preview.
class HandLandmarkPainter extends CustomPainter {
  const HandLandmarkPainter({
    required this.hands,
    required this.previewSize,
    required this.lensDirection,
    required this.sensorOrientation,
  });

  final List<Hand> hands;
  final Size previewSize;
  final CameraLensDirection lensDirection;
  final int sensorOrientation;

  static const List<List<int>> _connections = [
    [0, 1],
    [1, 2],
    [2, 3],
    [3, 4],
    [0, 5],
    [5, 6],
    [6, 7],
    [7, 8],
    [5, 9],
    [9, 10],
    [10, 11],
    [11, 12],
    [9, 13],
    [13, 14],
    [14, 15],
    [15, 16],
    [13, 17],
    [0, 17],
    [17, 18],
    [18, 19],
    [19, 20],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (hands.isEmpty || previewSize.height == 0) {
      return;
    }

    final scale = size.width / previewSize.height;
    final pointPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 8 / scale
      ..strokeCap = StrokeCap.round;
    final linePaint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 4 / scale;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(sensorOrientation * math.pi / 180);
    if (lensDirection == CameraLensDirection.front) {
      canvas.scale(-1, 1);
      canvas.rotate(math.pi);
    }
    canvas.scale(scale);

    for (final hand in hands) {
      for (final connection in _connections) {
        if (connection[0] >= hand.landmarks.length ||
            connection[1] >= hand.landmarks.length) {
          continue;
        }
        final start = hand.landmarks[connection[0]];
        final end = hand.landmarks[connection[1]];
        canvas.drawLine(
          Offset(
            (start.x - 0.5) * previewSize.width,
            (start.y - 0.5) * previewSize.height,
          ),
          Offset(
            (end.x - 0.5) * previewSize.width,
            (end.y - 0.5) * previewSize.height,
          ),
          linePaint,
        );
      }
      for (final landmark in hand.landmarks) {
        canvas.drawCircle(
          Offset(
            (landmark.x - 0.5) * previewSize.width,
            (landmark.y - 0.5) * previewSize.height,
          ),
          8 / scale,
          pointPaint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HandLandmarkPainter oldDelegate) {
    return oldDelegate.hands != hands ||
        oldDelegate.previewSize != previewSize ||
        oldDelegate.lensDirection != lensDirection ||
        oldDelegate.sensorOrientation != sensorOrientation;
  }
}
