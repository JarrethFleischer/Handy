import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/learn_sign_question.dart';
<<<<<<< Updated upstream
import 'package:handy/theme/app_colors.dart';
=======
import 'package:handy/features/chapters/chapter 1/lesson_flow.dart';
import 'package:handy/features/widget/sound.dart';
>>>>>>> Stashed changes

class VideoMatchPair {
  const VideoMatchPair({required this.videoAsset, required this.label});

  final String videoAsset;
  final String label;
}

class MatchVideoQuiz extends StatefulWidget {
  const MatchVideoQuiz({
    required this.pairs,
    required this.onContinue,
    super.key,
  });

  final List<VideoMatchPair> pairs;
  final VoidCallback onContinue;

  @override
  State<MatchVideoQuiz> createState() => _MatchVideoQuizState();
}

class _MatchVideoQuizState extends State<MatchVideoQuiz> {
  late final List<String?> _answers;
  int _currentVideoIndex = 0;
  bool _hasSubmitted = false;

  bool get _allAnswered => _answers.every((answer) => answer != null);

  bool get _allCorrect {
    for (var index = 0; index < widget.pairs.length; index++) {
      if (_answers[index] != widget.pairs[index].label) {
        return false;
      }
    }
    return true;
  }

  List<String> get _wordChoices =>
      widget.pairs.map((pair) => pair.label).toList().reversed.toList();

  @override
  void initState() {
    super.initState();
    _answers = List<String?>.filled(widget.pairs.length, null);
  }

  void _showVideo(int index) {
    if (index < 0 || index >= widget.pairs.length) {
      return;
    }

    setState(() {
      _currentVideoIndex = index;
    });
  }

  void _chooseWord(String word) {
    if (_hasSubmitted || _answers.contains(word)) {
      return;
    }

    final firstEmptyIndex = _answers.indexWhere((answer) => answer == null);
    if (firstEmptyIndex == -1) {
      return;
    }

    setState(() {
      _answers[firstEmptyIndex] = word;

      final nextEmptyIndex = _answers.indexWhere((answer) => answer == null);
      if (nextEmptyIndex != -1) {
        _currentVideoIndex = nextEmptyIndex;
      }
    });
  }

  void _removeAnswer(int index) {
    if (_hasSubmitted || _answers[index] == null) {
      return;
    }

    setState(() {
      _answers[index] = null;
      _currentVideoIndex = index;
    });
  }

  void _handleContinue() {
    if (!_allAnswered) {
      return;
    }

    if (!_hasSubmitted) {
      setState(() {
        _hasSubmitted = true;
      });
      return;
    }

    if (_allCorrect) {
      widget.onContinue();
    } else {
      setState(() {
        _hasSubmitted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPair = widget.pairs[_currentVideoIndex];

    return Column(
      children: [
        const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 10),
          child: Text(
            'Match the pairs',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF14181B),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
<<<<<<< Updated upstream
                ClipRRect(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: LessonVideo(
                      key: ValueKey(currentPair.videoAsset),
                      assetPath: currentPair.videoAsset,
                      height: 210,
=======
                // Flat video container (no chunky offset shadow)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF14181B), width: 1.8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: LessonVideo(
                        key: ValueKey(
                          currentPair.videoUrl ?? currentPair.videoAsset,
                        ),
                        assetPath: currentPair.videoUrl == null
                            ? currentPair.videoAsset
                            : null,
                        videoUrl: currentPair.videoUrl,
                        height: 190,
                      ),
>>>>>>> Stashed changes
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildVideoNavigation(),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: List.generate(
                          widget.pairs.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildAnswerSlot(index),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        children: _wordChoices
                            .map(
                              (word) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildWordChoice(word),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOut,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation);
            return SlideTransition(position: slide, child: child);
          },
          child: _hasSubmitted && _allCorrect
              ? _AnswerSheet(
                  color: const Color(0xFF00E676),
                  icon: Icons.check_circle_rounded,
                  title: 'Correct!',
                  buttonLabel: 'Continue',
                  onPressed: widget.onContinue,
                )
              : _hasSubmitted
              ? _AnswerSheet(
                  color: const Color(0xFFFF5252),
                  icon: Icons.cancel_rounded,
                  title: 'Incorrect',
                  answerLabel: 'Correct answers:',
                  answer: [
                    for (var i = 0; i < widget.pairs.length; i++)
                      'Video ${i + 1}  →  ${widget.pairs[i].label}',
                  ].join('\n'),
                  buttonLabel: 'Continue',
                  onPressed: widget.onContinue,
                )
              : LessonButton(
                  key: const ValueKey('match-check'),
                  label: 'Check matches',
                  onPressed: _allAnswered ? _handleContinue : null,
                ),
        ),
      ],
    );
  }

  Widget _buildVideoNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentVideoIndex > 0
              ? () => _showVideo(_currentVideoIndex - 1)
              : null,
          icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF14181B)),
        ),
        ...List.generate(
          widget.pairs.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showVideo(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _currentVideoIndex == index
                      ? const Color(0xFF14181B)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF14181B), width: 1.2),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: _currentVideoIndex == index
                        ? Colors.white
                        : const Color(0xFF57636C),
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: _currentVideoIndex < widget.pairs.length - 1
              ? () => _showVideo(_currentVideoIndex + 1)
              : null,
          icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF14181B)),
        ),
      ],
    );
  }

  Widget _buildAnswerSlot(int index) {
    final answer = _answers[index];
    final isCorrect = _hasSubmitted && answer == widget.pairs[index].label;
    final isWrong = _hasSubmitted && answer != widget.pairs[index].label;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _removeAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: answer == null
              ? Colors.white
              : isCorrect
              ? const Color(0xFF00E676).withValues(alpha: 0.18)
              : isWrong
              ? const Color(0xFFFF5252).withValues(alpha: 0.15)
              : const Color(0xFFE0F7FF),
          borderRadius: BorderRadius.circular(12),
          // Flat borders for answer slots (buttons get chunky shadows, slots stay clean)
          border: Border.all(
            color: isCorrect
                ? const Color(0xFF00E676)
                : isWrong
                ? const Color(0xFFFF5252)
                : const Color(0xFF14181B),
            width: 1.6,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                answer ?? 'Drop slot',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: answer == null
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF14181B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (answer != null && !_hasSubmitted)
              const Icon(Icons.close_rounded, color: Color(0xFF14181B), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWordChoice(String word) {
    final isUsed = _answers.contains(word);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isUsed ? 0.4 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _hasSubmitted || isUsed ? null : () => _chooseWord(word),
          borderRadius: BorderRadius.circular(12),
          // Interactive button card style with chunky shadow
          child: Container(
            width: double.infinity,
            height: 52,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF14181B), width: 1.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF14181B),
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              word,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF14181B),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
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
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.4,
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
                  side: const BorderSide(
                    color: Color(0xFF14181B),
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