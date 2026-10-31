import 'package:flutter/material.dart';
import 'package:handy/features/widget/popup.dart';
import 'package:handy/features/widget/sound.dart';
import 'package:handy/services/auth_service.dart';

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
    final total = widget.questions.length;
    final percent = total == 0 ? 0 : _correctCount / total;
    if (percent >= 0.8) {
      playWinSound();
    } else {
      playLoseSound();
    }
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
    try {
      await AuthService.recordStreak();
    } catch (error) {
      debugPrint('Streak activity could not be logged: $error');
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

    return Scaffold(
      backgroundColor: const Color(0xFFF3FAFF),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFDDF1FF), Color(0xFFF3FAFF)],
                ),
              ),
              child: CustomPaint(
                painter: _SubtleDotGridPainter(),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF14181B),
                            width: 1.6,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF14181B),
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _confirmLeave,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF14181B),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF14181B),
                              width: 1.4,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: questionCount == 0
                                  ? 0
                                  : (_currentQuestion + 1) / questionCount,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFFD86B),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '${_currentQuestion + 1}/$questionCount',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF14181B),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
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
        ],
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
    final headline = 'You earned $xpEarned Points!';

    return Scaffold(
      backgroundColor: const Color(0xFFF3FAFF),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFDDF1FF), Color(0xFFF3FAFF)],
                ),
              ),
              child: CustomPaint(
                painter: _SubtleDotGridPainter(),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                children: [
                  const Text(
                    'Lesson Complete! 🎉',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF14181B),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF14181B),
                        width: 2.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF14181B),
                          offset: Offset(0, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF00E676),
                            fontSize: 54,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF14181B),
                              width: 1.4,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : correct / total,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF00E676),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF14181B),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF00E676),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$correct of $total correct',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color(0xFF14181B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
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
                            color: Color(0xFF14181B),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // FIXED: Flat info banner for "Nice work!" (No chunky shadow, flat clean border)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD86B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF14181B),
                        width: 1.6,
                      ),
                    ),
                    child: Text(
                      note,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF14181B),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14181B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(
                            color: Color(0xFF14181B),
                            width: 1.8,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onTryAgain,
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF57636C),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtleDotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22A2F2).withOpacity(0.10)
      ..style = PaintingStyle.fill;

    const spacing = 26.0;
    const radius = 1.6;

    for (double x = 14; x < size.width; x += spacing) {
      for (double y = 14; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}