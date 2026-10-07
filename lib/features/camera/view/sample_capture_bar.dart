import 'package:flutter/material.dart';

/// Label field plus buttons that log a still pose or a one-second motion.
class SampleCaptureBar extends StatelessWidget {
  const SampleCaptureBar({
    super.key,
    required this.labelController,
    required this.sampleCount,
    required this.gestureCount,
    required this.isBusy,
    required this.statusLabel,
    required this.onCapture,
    required this.onRecordGesture,
    required this.onExport,
  });

  final TextEditingController labelController;
  final int sampleCount;
  final int gestureCount;
  final bool isBusy;
  final String? statusLabel;
  final VoidCallback onCapture;
  final VoidCallback onRecordGesture;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final hasSamples = sampleCount > 0 || gestureCount > 0;
    return ColoredBox(
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: labelController,
                    enabled: !isBusy,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Sign label',
                      hintText: 'A',
                      labelStyle: TextStyle(color: Colors.white70),
                      hintStyle: TextStyle(color: Colors.white38),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$sampleCount poses\n$gestureCount motions',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                IconButton(
                  tooltip: 'Export CSV',
                  onPressed: hasSamples ? onExport : null,
                  icon: const Icon(Icons.ios_share),
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isBusy ? null : onCapture,
                    icon: const Icon(Icons.add),
                    label: const Text('Capture sample'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: isBusy ? null : onRecordGesture,
                    icon: Icon(
                      isBusy ? Icons.fiber_manual_record : Icons.motion_photos_on_outlined,
                    ),
                    label: Text(statusLabel ?? 'Record gesture'),
                    style: FilledButton.styleFrom(
                      backgroundColor: isBusy ? Colors.red.shade800 : null,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
