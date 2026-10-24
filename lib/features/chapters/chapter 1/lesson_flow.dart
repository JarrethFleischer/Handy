import 'package:flutter/material.dart';
import 'package:handy/services/auth_service.dart';
import 'package:handy/features/widget/popup.dart';
import 'package:handy/theme/app_colors.dart';

typedef LessonContinue = void Function(bool correct, {bool awardsPoints});

class LessonFlow extends StatefulWidget {
  const LessonFlow({required this.questions, this.awardsXp = true, super.key});

  final List<Widget Function(LessonContinue onContinue)> questions;
  final bool awardsXp;

  @override
  State<LessonFlow> createState() => _LessonFlowState();
}

class _LessonFlowState extends State<LessonFlow> {
  int _currentQuestion = 0;
  int _correctCount = 0;
  int _xpEarned = 0;
  bool _showComplete = false;

  static const int _pointsPerQuiz = 50;

  Future<void> _confirmLeave() async {
    final shouldLeave = await showLeaveLessonDialog(context);
    if (shouldLeave && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _nextQuestion(bool correct, {bool awardsPoints = false}) async {
    if (correct) _correctCount++;
    if (correct && awardsPoints && widget.awardsXp) {
      _xpEarned += _pointsPerQuiz;
    }
    if (_currentQuestion < widget.questions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _showComplete = true);
  }

  Future<void> _finishLesson() async {
    if (_xpEarned > 0) {
      try {
        await AuthService.addXp(_xpEarned);
      } on AuthException {
        // The lesson still finishes if the points request fails.
      }
    }
    if (!mounted) return;
    final total = widget.questions.length;
    final score = total == 0 ? 0.0 : _correctCount / total;
    Navigator.pop(context, score);
  }

  void _tryAgain() {
    setState(() {
      _currentQuestion = 0;
      _correctCount = 0;
      _xpEarned = 0;
      _showComplete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionCount = widget.questions.length;
    if (_showComplete) {
      return _LessonCompletePage(
        correct: _correctCount,
        total: questionCount,
        xpEarned: _xpEarned,
        onContinue: _finishLesson,
        onTryAgain: _tryAgain,
      );
    }
    if (questionCount == 0) {
      return Scaffold(
        backgroundColor: AppColors.grayLight,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: _confirmLeave,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.close,
                  color: AppColors.textDark,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.grayLight,
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 48,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: _confirmLeave,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textDark,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: (_currentQuestion + 1) / questionCount,
                              minHeight: 10,
                              backgroundColor: AppColors.gray,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.blueDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(
                          '${_currentQuestion + 1}/$questionCount',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.08, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: widget.questions[_currentQuestion](_nextQuestion),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonCompletePage extends StatelessWidget {
  const _LessonCompletePage({
    required this.correct,
    required this.total,
    required this.xpEarned,
    required this.onContinue,
    required this.onTryAgain,
  });

  final int correct;
  final int total;
  final int xpEarned;
  final VoidCallback onContinue;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((correct / total) * 100).round();
    final note = percent == 100
        ? 'Nailed it!'
        : percent >= 50
        ? 'Nice work!'
        : 'Keep practicing!';
    final headline = 'You earned $xpEarned Points';

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          child: Column(
            children: [
              const Text(
                'Lesson Complete',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.blueDark,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD7E8FF)),
                ),
                child: Column(
                  children: [
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.correct,
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : correct / total,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFE4E4E4),
                        color: AppColors.correct,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.correct.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.correct,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$correct of $total correct',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.correct,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      headline,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.blueDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD7E8FF)),
                ),
                child: Text(
                  note,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF14304A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blueDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: onTryAgain,
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF6B7280),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
