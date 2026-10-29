import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/learn_sign_question.dart';
import 'package:handy/features/chapters/chapter 1/lesson_flow.dart';
import 'package:handy/features/widget/sound.dart';

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
          padding: const EdgeInsetsDirectional.fromSTEB(0, 14, 0, 0),
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF14181B),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
        // Flat video card (no chunky offset shadow)
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 16),
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: widget.options.map(_buildOption).toList(),
            ),
          ),
        ),
        if (_hasSubmitted && _isCorrect)
          _AnswerSheet(
            color: const Color(0xFF00E676),
            icon: Icons.check_circle_rounded,
            title: 'Correct!',
            buttonLabel: 'Next question',
            onPressed: () => widget.onContinue(!_missed, awardsPoints: true),
          )
        else if (_hasSubmitted)
          _AnswerSheet(
            color: const Color(0xFFFF5252),
            icon: Icons.cancel_rounded,
            title: 'Incorrect',
            answerLabel: 'Correct answer:',
            answer: widget.correctAnswer,
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

    Color backgroundColor = Colors.white;
    Color borderColor = const Color(0xFF14181B);

    if (!_hasSubmitted && isSelected) {
      backgroundColor = const Color(0xFFE0F7FF);
    } else if (_hasSubmitted && isSelected && isCorrectOption) {
      borderColor = const Color(0xFF00A86B);
    } else if (_hasSubmitted && isSelected) {
      borderColor = const Color(0xFFFF5252);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _hasSubmitted
              ? null
              : () {
                  setState(() {
                    _selectedAnswer = option;
                  });
                },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          // Interactive Button Style: Solid border with chunky bottom shadow
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 1.8),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF14181B),
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF14181B), // Explicit dark ink text
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
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
    this.answerLabel,
    this.answer,
  });

  final String? answerLabel;
  final String? answer;
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
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(
          top: BorderSide(color: Color(0xFF14181B), width: 2.0),
          left: BorderSide(color: Color(0xFF14181B), width: 2.0),
          right: BorderSide(color: Color(0xFF14181B), width: 2.0),
        ),
        boxShadow: const [
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
                  side: BorderSide(
                    color: const Color(0xFF14181B),
                    width: 1.8,
                  ),
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