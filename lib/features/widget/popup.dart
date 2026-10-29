import 'package:flutter/material.dart';
import 'package:handy/features/feedback/feedback_screen.dart';

const Color _ink = Color(0xFF14181B);
const Color _muted = Color(0xFF57636C);
const Color _yellow = Color(0xFFFFD86B);
const Color _danger = Color(0xFFFF5252);

Future<bool> showLeaveLessonDialog(BuildContext context) {
  return showHandyConfirmDialog(
    context: context,
    title: 'Do you want to leave?',
    message: 'Your current lesson progress will be lost.',
    cancelLabel: 'Stay',
    confirmLabel: 'Leave',
  );
}

Future<bool> showDeleteAccountDialog(BuildContext context) {
  return showHandyConfirmDialog(
    context: context,
    title: 'Are you sure?',
    message: 'This will permanently remove your account.',
    confirmLabel: 'Delete',
    destructive: true,
  );
}

Future<bool> showResetProgressDialog(BuildContext context) {
  return showHandyConfirmDialog(
    context: context,
    title: 'Reset progress?',
    message: 'All chapter and lesson progress will be reset.',
    confirmLabel: 'Reset',
    destructive: true,
  );
}

Future<bool> showHandyConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelLabel = 'Cancel',
  required String confirmLabel,
  bool destructive = false,
  bool barrierDismissible = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      return HandyDialog(
        title: title,
        message: message,
        actions: [
          HandyDialogButton(
            label: cancelLabel,
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          const SizedBox(width: 12),
          HandyDialogButton(
            label: confirmLabel,
            filled: true,
            destructive: destructive,
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

Future<bool> showSignResultDialog(
  BuildContext context, {
  required bool correct,
  required String sign,
  int xpEarned = 0,
}) async {
  final headline = correct ? 'Correct!' : 'Try again';
  final message = correct
      ? 'Amazing job, you\'ve earned $xpEarned XP'
      : 'Not quite';

  final accepted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return HandyDialog(
        title: headline,
        titleColor: correct ? const Color(0xFF00A86B) : _danger,
        message: message,
        actions: [
          HandyDialogButton(
            label: correct ? 'Back to Quiz' : 'Try again',
            filled: true,
            expand: true,
            onPressed: () => Navigator.pop(dialogContext, correct),
          ),
        ],
        footer: correct
            ? null
            : TextButton(
                onPressed: () async {
                  final skipped = await showSkipPracticeDialog(dialogContext);
                  if (skipped && dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                },
                child: const Text(
                  'I did it right',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
      );
    },
  );

  return accepted ?? false;
}

Future<bool> showSkipPracticeDialog(BuildContext context) async {
  final skipped = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return HandyDialog(
        title: 'Did you do it right?',
        message: 'Skip the practice if you think the AI is incorrect.',
        actions: [
          HandyDialogButton(
            label: 'Back to Quiz',
            filled: true,
            expand: true,
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
        footer: TextButton(
          onPressed: () => FeedbackScreen.show(dialogContext),
          child: const Text(
            'Send us feedback!',
            style: TextStyle(
              fontFamily: 'Inter',
              color: _ink,
              fontSize: 14,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    },
  );

  return skipped ?? false;
}

class HandyDialog extends StatelessWidget {
  const HandyDialog({
    required this.title,
    required this.message,
    required this.actions,
    this.titleColor = _ink,
    this.footer,
    super.key,
  });

  final String title;
  final Color titleColor;
  final String message;
  final List<Widget> actions;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _ink, width: 1.8),
          boxShadow: const [
            BoxShadow(color: _ink, offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                color: titleColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: _muted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            Row(children: actions),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}

class HandyDialogButton extends StatelessWidget {
  const HandyDialogButton({
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.destructive = false,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final bool destructive;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final background = !filled
        ? Colors.white
        : destructive
        ? _danger
        : _yellow;
    final foreground = filled && destructive ? Colors.white : _ink;

    final button = SizedBox(
      height: 46,
      width: expand ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: _ink, width: 1.6),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );

    if (expand) return Expanded(child: button);
    return Expanded(child: button);
  }
}
