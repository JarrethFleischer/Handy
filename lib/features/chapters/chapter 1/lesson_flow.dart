import 'package:flutter/material.dart';
import 'package:handy/features/widget/popup.dart';
import 'package:handy/theme/app_colors.dart';

class LessonFlow extends StatefulWidget {
  const LessonFlow({required this.questions, super.key});

  final List<Widget Function(VoidCallback onContinue)> questions;

  @override
  State<LessonFlow> createState() => _LessonFlowState();
}

class _LessonFlowState extends State<LessonFlow> {
  int _currentQuestion = 0;

  Future<void> _confirmLeave() async {
    final shouldLeave = await showLeaveLessonDialog(context);
    if (shouldLeave && mounted) {
      Navigator.pop(context);
    }
  }

  void _nextQuestion() {
    if (_currentQuestion < widget.questions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Lesson completed!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final questionCount = widget.questions.length;
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
