import 'package:flutter/material.dart';

Future<bool> showLeaveLessonDialog(BuildContext context) async {
  final shouldLeave = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFFF1F4F8),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFADD8E6)),
        ),
        title: const Text(
          'Do you want to leave?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF14181B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Your current lesson progress will be lost.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF57636C),
            fontSize: 14,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF249689),
                      side: const BorderSide(color: Color(0xFF249689)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Stay'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF249689),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Leave'),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );

  return shouldLeave ?? false;
}
