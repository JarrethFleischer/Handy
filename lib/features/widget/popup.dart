import 'package:flutter/material.dart';
import 'package:handy/theme/app_colors.dart';

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
                      foregroundColor: AppColors.blueDark,
                      side: const BorderSide(color: AppColors.blueDark),
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
                      backgroundColor: AppColors.blueDark,
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

Future<bool> showDeleteAccountDialog(BuildContext context) async {
  final shouldDelete = await showDialog<bool>(
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
          'Are u sure?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF14181B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'This will permanently remove your account.',
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
                      foregroundColor: AppColors.blueDark,
                      side: const BorderSide(color: AppColors.blueDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
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
                      backgroundColor: AppColors.incorrect,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );

  return shouldDelete ?? false;
}

Future<bool> showResetProgressDialog(BuildContext context) async {
  final shouldReset = await showDialog<bool>(
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
          'Reset progress?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF14181B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'All chapter and lesson progress will be reset',
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
                      foregroundColor: AppColors.blueDark,
                      side: const BorderSide(color: AppColors.blueDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
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
                      backgroundColor: AppColors.incorrect,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );

  return shouldReset ?? false;
}

Future<void> showSignResultDialog(
  BuildContext context, {
  required bool correct,
  required String sign,
  int xpEarned = 0,
}) {
  final headline = correct ? 'Correct!' : 'Try again';
  final message = correct
      ? 'Amazing job, you\'ve earned $xpEarned XP'
      : 'Not quite';

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              headline,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                color: correct ? AppColors.correct : AppColors.incorrect,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF2B2B2B),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blueDark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  correct ? 'Back to Quiz' : 'Try again',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
