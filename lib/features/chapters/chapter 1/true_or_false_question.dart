import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/learn_sign_question.dart';
import 'package:handy/features/chapters/chapter 1/lesson_flow.dart';
import 'package:handy/features/widget/sound.dart';

class TrueOrFalseQuestion extends StatefulWidget {
  const TrueOrFalseQuestion({
    required this.statement,
    required this.correctAnswer,
    required this.onContinue,
    this.videoAsset,
    this.videoUrl,
    super.key,
  });

  final String? videoAsset;
  final String? videoUrl;
  final String statement;
  final bool correctAnswer;
  final LessonContinue onContinue;

  @override
  State<TrueOrFalseQuestion> createState() => _TrueOrFalseQuestionState();
}

class _TrueOrFalseQuestionState extends State<TrueOrFalseQuestion> {
  bool? _selectedAnswer;
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

    widget.onContinue(_isCorrect && !_missed, awardsPoints: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 14),
          child: _TypePill(label: 'TRUE OR FALSE'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF14181B), width: 1.8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: LessonVideo(
                key: ValueKey(widget.videoUrl ?? widget.videoAsset),
                assetPath: widget.videoUrl == null ? widget.videoAsset : null,
                videoUrl: widget.videoUrl,
                height: 190,
              ),
            ),
          ),
        ),
        // Flat statement box (display only, no chunky shadow)
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 54),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF14181B), width: 1.6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              widget.statement,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF14181B),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
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
                  highlightColor: const Color(0xFFD1FAE5), // Light Green
                  selectedColor: const Color(0xFF6EE7B7),
                  textColor: const Color(0xFF065F46),
                  isSelected: _selectedAnswer == true,
                  showResult: _hasSubmitted,
                  isCorrectChoice: widget.correctAnswer,
                  onTap: _hasSubmitted
                      ? null
                      : () => setState(() => _selectedAnswer = true),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _AnswerButton(
                  label: 'False',
                  highlightColor: const Color(0xFFFEE2E2), // Light Red
                  selectedColor: const Color(0xFFFCA5A5),
                  textColor: const Color(0xFF991B1B),
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
        const Spacer(),
        if (_hasSubmitted && _isCorrect)
          _AnswerSheet(
            color: const Color(0xFF00E676),
            icon: Icons.check_circle_rounded,
            title: 'Correct!',
            buttonLabel: 'Next question',
            onPressed: _handleContinue,
          )
        else if (_hasSubmitted)
          _AnswerSheet(
            color: const Color(0xFFFF5252),
            icon: Icons.cancel_rounded,
            title: 'Incorrect',
            answerLabel: 'Correct answer:',
            answer: widget.correctAnswer ? 'True' : 'False',
            buttonLabel: 'Continue',
            onPressed: _handleContinue,
          )
        else
          LessonButton(
            label: 'Continue',
            onPressed: _selectedAnswer == null ? null : _handleContinue,
          ),
      ],
    );
  }
}

/// Bottom result sheet, matching the one in video_quiz_question.dart,
/// plus an optional Duolingo-style "Correct answer" line.
class _AnswerSheet extends StatelessWidget {
  const _AnswerSheet({
    required this.color,
    required this.icon,
    required this.title,
    required this.buttonLabel,
    required this.onPressed,
    this.answerLabel,
    this.answer,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String buttonLabel;
  final VoidCallback onPressed;
  final String? answerLabel;
  final String? answer;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Color(0xFF14181B), width: 2.0),
          left: BorderSide(color: Color(0xFF14181B), width: 2.0),
          right: BorderSide(color: Color(0xFF14181B), width: 2.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF14181B),
            offset: Offset(0, -4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: color,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (answer != null) ...[
            const SizedBox(height: 8),
            Text(
              answerLabel ?? 'Correct answer:',
              style: TextStyle(
                fontFamily: 'Inter',
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              answer!,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF14181B),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFF14181B), width: 1.8),
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

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF14181B), width: 1.6),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF14181B),
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          color: Color(0xFF14181B),
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.highlightColor,
    required this.selectedColor,
    required this.textColor,
    required this.isSelected,
    required this.showResult,
    required this.isCorrectChoice,
    required this.onTap,
  });

  final String label;
  final Color highlightColor;
  final Color selectedColor;
  final Color textColor;
  final bool isSelected;
  final bool showResult;
  final bool isCorrectChoice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final highlight = showResult ? isCorrectChoice : isSelected;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: highlight ? selectedColor : highlightColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF14181B), width: 1.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF14181B),
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}