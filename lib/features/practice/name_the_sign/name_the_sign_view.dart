import 'dart:math';

import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/learn_sign_question.dart';
import 'package:handy/theme/app_colors.dart';

class NameTheSignView extends StatefulWidget {
  const NameTheSignView({super.key});

  @override
  State<NameTheSignView> createState() => _NameTheSignViewState();
}

class _SignPrompt {
  const _SignPrompt(this.videoAsset, this.answers);

  final String videoAsset;
  final List<String> answers;
}

class _NameTheSignViewState extends State<NameTheSignView> {
  static const _signs = [
    _SignPrompt('assets/chapter_1/hello.mp4', ['Hello']),
    _SignPrompt('assets/chapter_1/assalamualaikum.mp4', ['Assalamualaikum']),
    _SignPrompt('assets/chapter_1/waalaikumussalam.mp4', [
      'Waalaikumussalam',
      'Waalaikumusalam',
    ]),
    _SignPrompt('assets/chapter_1/ya.mp4', ['Ya', 'Yes']),
    _SignPrompt('assets/chapter_1/tidak.mp4', ['Tidak', 'No']),
    _SignPrompt('assets/chapter_1/apa_khabar.mp4', [
      'Apa khabar',
      'Apa khabar?',
    ]),
    _SignPrompt('assets/chapter_1/khabar_baik.mp4', ['Khabar baik', 'Fine']),
    _SignPrompt('assets/chapter_1/terima_kasih.mp4', [
      'Terima kasih',
      'Thank you',
    ]),
    _SignPrompt('assets/chapter_1/sama_sama.mp4', ['Sama-sama', 'Sama sama']),
    _SignPrompt('assets/chapter_1/apa.mp4', ['Apa']),
  ];

  final _answerController = TextEditingController();
  final _random = Random();

  late _SignPrompt _current;
  int _correctCount = 0;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _current = _signs[_random.nextInt(_signs.length)];
    _answerController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[\s\-]+'), ' ');
  }

  void _checkAnswer() {
    final typed = _normalize(_answerController.text);
    if (typed.isEmpty) {
      return;
    }

    final matched = _current.answers.any(
      (answer) => _normalize(answer) == typed,
    );

    if (!matched) {
      setState(() => _isCorrect = false);
      return;
    }

    setState(() {
      _isCorrect = true;
      _correctCount++;
    });
  }

  void _nextSign() {
    _SignPrompt next;
    do {
      next = _signs[_random.nextInt(_signs.length)];
    } while (next.videoAsset == _current.videoAsset && _signs.length > 1);

    _answerController.clear();
    setState(() {
      _current = next;
      _isCorrect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasAnswer = _answerController.text.trim().isNotEmpty;
    final progress = (_correctCount / _signs.length).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    8,
                    0,
                    16 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.maybePop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: AppColors.textDark,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: progress == 0 ? 0.08 : progress,
                                  borderRadius: BorderRadius.circular(10),
                                  minHeight: 14,
                                  backgroundColor: AppColors.gray,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColors.blueDark,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Write down the shown sign!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        child: ColoredBox(
                          color: const Color(0xFFF6F1E6),
                          child: LessonVideo(
                            key: ValueKey(_current.videoAsset),
                            assetPath: _current.videoAsset,
                            height: 220,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _answerController,
                          enabled: _isCorrect != true,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _checkAnswer(),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textDark,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type here...',
                            hintStyle: const TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFFB0B0B0),
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: _isCorrect == true
                                ? AppColors.correct.withValues(alpha: 0.1)
                                : _isCorrect == false
                                ? AppColors.incorrect.withValues(alpha: 0.1)
                                : AppColors.grayLight,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _isCorrect == true
                                    ? AppColors.correct
                                    : const Color(0xFFE4E4E4),
                                width: _isCorrect == true ? 2.0 : 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _isCorrect == false
                                    ? AppColors.incorrect
                                    : const Color(0xFFE4E4E4),
                                width: _isCorrect == false ? 2.0 : 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _isCorrect == false
                                    ? AppColors.incorrect
                                    : AppColors.blueLight,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isCorrect == true)
                _AnswerSheet(
                  color: AppColors.correct,
                  icon: Icons.check_circle,
                  title: 'Correct!',
                  buttonLabel: 'Next question',
                  onPressed: _nextSign,
                )
              else if (_isCorrect == false)
                _AnswerSheet(
                  color: AppColors.incorrect,
                  icon: Icons.cancel,
                  title: 'Incorrect',
                  buttonLabel: 'Continue',
                  onPressed: _nextSign,
                )
              else
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    16 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: hasAnswer ? _checkAnswer : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.blueDark,
                        disabledBackgroundColor: const Color(0xFFD5DDE3),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Check'),
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
