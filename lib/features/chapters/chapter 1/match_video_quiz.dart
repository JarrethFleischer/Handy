import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/learn_sign_question.dart';
import 'package:handy/features/chapters/chapter 1/lesson_flow.dart';
import 'package:handy/features/widget/sound.dart';
import 'package:handy/theme/app_colors.dart';

class VideoMatchPair {
  const VideoMatchPair({required this.label, this.videoAsset, this.videoUrl});

  final String? videoAsset;
  final String? videoUrl;
  final String label;
}

class MatchVideoQuiz extends StatefulWidget {
  const MatchVideoQuiz({
    required this.pairs,
    required this.onContinue,
    super.key,
  });

  final List<VideoMatchPair> pairs;
  final LessonContinue onContinue;

  @override
  State<MatchVideoQuiz> createState() => _MatchVideoQuizState();
}

class _MatchVideoQuizState extends State<MatchVideoQuiz> {
  late final List<String?> _answers;
  int _currentVideoIndex = 0;
  bool _hasSubmitted = false;
  bool _missed = false;

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
      if (_allCorrect) {
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

    if (_allCorrect) {
      widget.onContinue(!_missed, awardsPoints: true);
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
          padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 10),
          child: Text(
            'Match the pairs',
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ClipRRect(
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
                      height: 210,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildVideoNavigation(),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: List.generate(
                          widget.pairs.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                              left: 20,
                            ),
                            child: _buildAnswerSlot(index),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: _wordChoices
                            .map(
                              (word) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 10,
                                  right: 20,
                                ),
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
                  color: AppColors.correct,
                  icon: Icons.check_circle,
                  title: 'Correct!',
                  buttonLabel: 'Continue',
                  onPressed: () => widget.onContinue(!_missed, awardsPoints: true),
                )
              : _hasSubmitted
              ? _AnswerSheet(
                  color: AppColors.incorrect,
                  icon: Icons.cancel,
                  title: 'Incorrect',
                  buttonLabel: 'Continue',
                  onPressed: () => widget.onContinue(false, awardsPoints: true),
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
          icon: const Icon(Icons.chevron_left),
        ),
        ...List.generate(
          widget.pairs.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showVideo(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 18,
                height: 18,
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _currentVideoIndex == index
                      ? AppColors.blueDark
                      : const Color(0xFFE2E8EA),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: _currentVideoIndex < widget.pairs.length - 1
              ? () => _showVideo(_currentVideoIndex + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildAnswerSlot(int index) {
    final answer = _answers[index];
    final isCorrect = _hasSubmitted && answer == widget.pairs[index].label;
    final isWrong = _hasSubmitted && answer != widget.pairs[index].label;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _removeAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: answer == null
              ? AppColors.gray
              : isCorrect
              ? AppColors.correct.withValues(alpha: 0.18)
              : isWrong
              ? AppColors.incorrect.withValues(alpha: 0.12)
              : const Color(0xFFE8F5F3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCorrect
                ? AppColors.correct
                : isWrong
                ? AppColors.incorrect
                : answer == null
                ? AppColors.gray
                : AppColors.correct,
            width: _hasSubmitted || answer != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                answer ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (answer != null && !_hasSubmitted)
              const Icon(Icons.close, color: AppColors.gray, size: 17),
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
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: _hasSubmitted || isUsed ? null : () => _chooseWord(word),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            height: 58,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grayLight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              word,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF14181B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
