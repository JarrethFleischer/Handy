import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/learn_sign_question.dart';
import 'package:handy/theme/app_colors.dart';

class VideoQuizQuestion extends StatefulWidget {
  const VideoQuizQuestion({
    required this.videoAsset,
    required this.options,
    required this.correctAnswer,
    required this.onContinue,
    super.key,
  });

  final String videoAsset;
  final List<String> options;
  final String correctAnswer;
  final VoidCallback onContinue;

  @override
  State<VideoQuizQuestion> createState() => _VideoQuizQuestionState();
}

class _VideoQuizQuestionState extends State<VideoQuizQuestion> {
  String? _selectedAnswer;
  bool _hasSubmitted = false;

  bool get _isCorrect => _selectedAnswer == widget.correctAnswer;

  void _handleContinue() {
    if (_selectedAnswer == null) {
      return;
    }

    if (!_hasSubmitted) {
      setState(() {
        _hasSubmitted = true;
      });
      return;
    }

    if (_isCorrect) {
      widget.onContinue();
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
        const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
          child: Text(
            'What sign is shown?',
            style: TextStyle(
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
              key: ValueKey(widget.videoAsset),
              assetPath: widget.videoAsset,
            ),
          ),
        ),
        ...widget.options.map(_buildOption),
        if (_hasSubmitted)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isCorrect ? Icons.check_circle : Icons.cancel,
                  color: _isCorrect ? AppColors.blueDark : Colors.redAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  _isCorrect ? 'Correct!' : 'Try again',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isCorrect ? AppColors.blueDark : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        const Spacer(),
        LessonButton(
          label: !_hasSubmitted
              ? 'Continue'
              : _isCorrect
              ? 'Finish lesson'
              : 'Try again',
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
    IconData? trailingIcon;

    if (!_hasSubmitted && isSelected) {
      borderColor = AppColors.blueDark;
      backgroundColor = AppColors.blueDark.withValues(alpha: 0.06);
    } else if (_hasSubmitted) {
      if (isCorrectOption) {
        borderColor = AppColors.blueDark;
        backgroundColor = AppColors.blueDark.withValues(alpha: 0.1);
        trailingIcon = Icons.check_circle;
      } else if (isSelected) {
        borderColor = Colors.redAccent;
        backgroundColor = Colors.redAccent.withValues(alpha: 0.1);
        trailingIcon = Icons.cancel;
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
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (trailingIcon != null)
                  Icon(trailingIcon, color: borderColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
