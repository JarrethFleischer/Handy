import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/learn_sign_question.dart';
import 'package:handy/features/chapters/chapter 1/lesson_flow.dart';
import 'package:handy/features/widget/sound.dart';
import 'package:handy/theme/app_colors.dart';

class VideoQuizQuestion extends StatefulWidget {
  const VideoQuizQuestion({
    required this.options,
    required this.correctAnswer,
    required this.onContinue,
    this.videoAsset,
    this.videoUrl,
    this.title = 'What sign is shown?',
    super.key,
  });

  final String? videoAsset;
  final String? videoUrl;
  final String title;
  final List<String> options;
  final String correctAnswer;
  final LessonContinue onContinue;

  @override
  State<VideoQuizQuestion> createState() => _VideoQuizQuestionState();
}

class _VideoQuizQuestionState extends State<VideoQuizQuestion> {
  String? _selectedAnswer;
  bool _hasSubmitted = false;
  bool _missed = false;

  bool get _isCorrect => _selectedAnswer == widget.correctAnswer;

  void _handleContinue() {
    if (_selectedAnswer == null) {
      return;
    }

    if (!_hasSubmitted) {
      if (_isCorrect) {
        playCorrectSound();
      } else {
        playIncorrectSound();
        _missed = true;
      }
      setState(() {
        _hasSubmitted = true;
      });
      return;
    }

    if (_isCorrect) {
      widget.onContinue(!_missed, awardsPoints: true);
    } else {
      setState(() {
        _selectedAnswer = null;
        _hasSubmitted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 20),
          child: ClipRRect(
            child: LessonVideo(
              key: ValueKey(widget.videoUrl ?? widget.videoAsset),
              assetPath: widget.videoUrl == null ? widget.videoAsset : null,
              videoUrl: widget.videoUrl,
            ),
          ),
        ),
        ...widget.options.map(_buildOption),
        const Spacer(),
        if (_hasSubmitted && _isCorrect)
          _AnswerSheet(
            color: AppColors.correct,
            icon: Icons.check_circle,
            title: 'Correct!',
            buttonLabel: 'Next question',
            onPressed: () => widget.onContinue(!_missed, awardsPoints: true),
          )
        else if (_hasSubmitted)
          _AnswerSheet(
            color: AppColors.incorrect,
            icon: Icons.cancel,
            title: 'Incorrect',
            buttonLabel: 'Continue',
            onPressed: () => widget.onContinue(false, awardsPoints: true),
          )
        else
          LessonButton(
            label: 'Continue',
            onPressed: _selectedAnswer == null ? null : _handleContinue,
          ),
      ],
    );
  }

  Widget _buildOption(String option) {
    final isSelected = option == _selectedAnswer;
    final isCorrectOption = option == widget.correctAnswer;

    Color borderColor = AppColors.blueLight;
    Color backgroundColor = Colors.white;

    if (!_hasSubmitted && isSelected) {
      borderColor = AppColors.blueDark;
      backgroundColor = AppColors.blueDark.withValues(alpha: 0.06);
    } else if (_hasSubmitted) {
      if (isCorrectOption && isSelected) {
        borderColor = AppColors.correct;
        backgroundColor = AppColors.correct.withValues(alpha: 0.18);
      } else if (isSelected) {
        borderColor = AppColors.incorrect;
        backgroundColor = AppColors.incorrect.withValues(alpha: 0.12);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _hasSubmitted
              ? null
              : () {
                  setState(() {
                    _selectedAnswer = option;
                  });
                },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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

class _AnswerSheet extends StatelessWidget {
  const _AnswerSheet({
    required this.color,
    required this.icon,
    required this.title,
    required this.buttonLabel,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: color,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
