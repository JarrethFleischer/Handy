import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/learn_sign_question.dart';
import 'package:handy/theme/app_colors.dart';

class TrueOrFalseQuestion extends StatefulWidget {
  const TrueOrFalseQuestion({
    required this.videoAsset,
    required this.statement,
    required this.correctAnswer,
    required this.onContinue,
    super.key,
  });

  final String videoAsset;
  final String statement;
  final bool correctAnswer;
  final VoidCallback onContinue;

  @override
  State<TrueOrFalseQuestion> createState() => _TrueOrFalseQuestionState();
}

class _TrueOrFalseQuestionState extends State<TrueOrFalseQuestion> {
  bool? _selectedAnswer;
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
          padding: EdgeInsets.only(top: 16),
          child: _TypePill(label: 'TRUE OR FALSE'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LessonVideo(
              key: ValueKey(widget.videoAsset),
              assetPath: widget.videoAsset,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.blueLight, width: 2),
            ),
            child: Text(
              widget.statement,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _AnswerButton(
                  label: 'True',
                  color: AppColors.correct,
                  isSelected: _selectedAnswer == true,
                  showResult: _hasSubmitted,
                  isCorrectChoice: widget.correctAnswer,
                  onTap: _hasSubmitted
                      ? null
                      : () => setState(() => _selectedAnswer = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AnswerButton(
                  label: 'False',
                  color: AppColors.incorrect,
                  isSelected: _selectedAnswer == false,
                  showResult: _hasSubmitted,
                  isCorrectChoice: !widget.correctAnswer,
                  onTap: _hasSubmitted
                      ? null
                      : () => setState(() => _selectedAnswer = false),
                ),
              ),
            ],
          ),
        ),
        if (_hasSubmitted)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isCorrect ? Icons.check_circle : Icons.cancel,
                  color: _isCorrect ? AppColors.correct : AppColors.incorrect,
                ),
                const SizedBox(width: 8),
                Text(
                  _isCorrect ? 'Correct!' : 'Try again',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isCorrect ? AppColors.correct : AppColors.incorrect,
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
              ? 'Continue'
              : 'Try again',
          onPressed: _selectedAnswer == null ? null : _handleContinue,
        ),
      ],
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blueLight, width: 1.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.blueDark,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.showResult,
    required this.isCorrectChoice,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isSelected;
  final bool showResult;
  final bool isCorrectChoice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final highlight = showResult ? isCorrectChoice : isSelected;

    return Material(
      color: highlight ? color : color.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: highlight
                ? Border.all(color: AppColors.textDark, width: 2)
                : null,
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
