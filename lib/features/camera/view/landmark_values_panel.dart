import 'package:handy/features/camera/landmarks/coordinate_normalizer.dart';
import 'package:handy/features/camera/landmarks/landmark_extractor.dart';
import 'package:flutter/material.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

/// Scrollable panel that lists (x, y, z) for all 21 joints each frame.
class LandmarkValuesPanel extends StatelessWidget {
  const LandmarkValuesPanel({super.key, required this.hands});

  final List<Hand> hands;

  @override
  Widget build(BuildContext context) {
    if (hands.isEmpty) {
      return const ColoredBox(
        color: Color(0xFF121212),
        child: Center(
          child: Text(
            'No hand detected — show a hand to extract landmarks.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      );
    }

    final rawHands = extractLandmarksFromHands(hands);

    return ColoredBox(
      color: const Color(0xFF121212),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        itemCount: rawHands.length,
        itemBuilder: (context, handIndex) {
          final sample = normalizeHandCoordinates(rawHands[handIndex]);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6, top: 4),
                child: Text(
                  sample == null
                      ? 'Hand ${handIndex + 1} — could not normalize'
                      : 'Hand ${handIndex + 1} — normalized (${sample.values.length} values)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (sample == null)
                const Text(
                  'Need all 21 joints and a visible middle-finger knuckle.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                )
              else ...[
                for (var index = 0; index < landmarkCount; index++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Text(
                      '[${index.toString().padLeft(2, '0')}] ${HandJoint.names[index]}  '
                      'x=${sample.values[index * 3].toStringAsFixed(3)}  '
                      'y=${sample.values[index * 3 + 1].toStringAsFixed(3)}  '
                      'z=${sample.values[index * 3 + 2].toStringAsFixed(3)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        height: 1.35,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                const Text(
                  'CSV row (63)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  sample.toCsvRow(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    height: 1.35,
                  ),
                ),
              ],
              if (handIndex < rawHands.length - 1) const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
