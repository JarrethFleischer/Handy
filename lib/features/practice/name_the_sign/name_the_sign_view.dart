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

  /// Pop-up confirmation dialog when user taps back during an active quiz
  Future<void> _onBackPressed() async {
    if (_chapter != null) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF14181B), width: 2),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Leave Quiz?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w900,
              color: Color(0xFF14181B),
            ),
          ),
          content: const Text(
            'Are you sure you want to leave? Your current progress in this session will be lost.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              color: Color(0xFF57636C),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF57636C),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Yes, Leave',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );

      if (shouldLeave == true) {
        _leaveQuiz();
      }
    } else {
      Navigator.maybePop(context);
    }
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
<<<<<<< Updated upstream
    final progress = (_correctCount / _signs.length).clamp(0.0, 1.0);
=======
    final progress = ((_index + 1) / _signs.length).clamp(0.0, 1.0);
    final isLast = _index + 1 >= _signs.length;
    final correctAnswerText = current.answers.isNotEmpty ? current.answers.first : 'Unknown';
>>>>>>> Stashed changes

    return WillPopScope(
      onWillPop: () async {
        await _onBackPressed();
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.white, // Pure white background as requested
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      16 + MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: Column(
                      children: [
                        // Top Bar: Back Button + Progress Bar + Question Number Counter
                        Row(
                          children: [
<<<<<<< Updated upstream
                            IconButton(
                              onPressed: () => Navigator.maybePop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: AppColors.textDark,
                                size: 26,
=======
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
                                onPressed: _onBackPressed,
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Color(0xFF14181B),
                                  size: 22,
                                ),
>>>>>>> Stashed changes
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Question X of Y counter
                                  Text(
                                    'Question ${_index + 1} of ${_signs.length}',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF57636C),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Yellow Progress Bar
                                  Container(
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF14181B),
                                        width: 1.3,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: LinearProgressIndicator(
                                        value: progress == 0 ? 0.08 : progress,
                                        backgroundColor: Colors.transparent,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          Color(0xFFFFD86B), // Bright Sunny Yellow
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
<<<<<<< Updated upstream
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
=======
                        const SizedBox(height: 24),
                        const Text(
                          'Watch & type what the sign means!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF14181B),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
>>>>>>> Stashed changes
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Video Card
                        Container(
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
                                offset: Offset(0, 5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: LessonVideo(
                              key: ValueKey(current.key),
                              assetPath: current.videoAsset,
                              videoUrl: current.videoUrl,
                              height: 210,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Text Input Field
                        TextField(
                          controller: _answerController,
                          enabled: _isCorrect != true,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _checkAnswer(),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF14181B),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type your answer here...',
                            hintStyle: const TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF94A3B8),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: _isCorrect == true
                                ? const Color(0xFF00E676).withValues(alpha: 0.12)
                                : _isCorrect == false
                                ? const Color(0xFFFF5252).withValues(alpha: 0.12)
                                : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF14181B),
                                width: 1.8,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: _isCorrect == true
                                    ? const Color(0xFF00E676)
                                    : _isCorrect == false
                                    ? const Color(0xFFFF5252)
                                    : const Color(0xFF14181B),
                                width: 1.8,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF22A2F2),
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
<<<<<<< Updated upstream
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
=======
                      ],
>>>>>>> Stashed changes
                    ),
                  ),
                ),
                if (_isCorrect == true)
                  _AnswerSheet(
                    color: const Color(0xFF00E676),
                    icon: Icons.check_circle_rounded,
                    title: 'Correct!',
                    subtitle: '',
                    buttonLabel: isLast ? 'Done' : 'Next Question',
                    onPressed: _nextSign,
                  )
                else if (_isCorrect == false)
                  _AnswerSheet(
                    color: const Color(0xFFFF5252),
                    icon: Icons.cancel_rounded,
                    title: 'Incorrect',
                    subtitle: 'Correct answer: $correctAnswerText', // Duolingo style correct word reveal
                    buttonLabel: isLast ? 'Done' : 'Continue',
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
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: hasAnswer ? _checkAnswer : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF14181B),
                          disabledBackgroundColor: const Color(0xFFCBD5E1),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: const Color(0xFF64748B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: const Text('Check Answer'),
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
<<<<<<< Updated upstream
=======

  Widget _buildChapterPicker() {
    return Scaffold(
      backgroundColor: Colors.white, // White background for picker as well
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                          onPressed: () => Navigator.maybePop(context),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF14181B),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Name the sign',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF14181B),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose a chapter to practice video naming',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF57636C),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: CircularProgressIndicator(color: Color(0xFF22A2F2)),
                    ),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFFFF5252),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _ChapterChoice(
                    title: 'Chapter 1',
                    headerColor: const Color(0xFFFFD86B),
                    locked: _chapter1 != null && !_chapter1Unlocked,
                    subtitle: _chapter1 == null
                        ? 'Loading signs...'
                        : _chapter1Unlocked
                        ? '${_chapter1!.length} signs available'
                        : 'Complete both lessons to unlock',
                    onTap: _loading || !_chapter1Unlocked
                        ? null
                        : () => _startChapter('Chapter 1'),
                  ),
                  const SizedBox(height: 16),
                  _ChapterChoice(
                    title: 'Chapter 2',
                    headerColor: const Color(0xFF7CE0FF),
                    locked: _chapter2 != null && !_chapter2Unlocked,
                    subtitle: _chapter2 == null
                        ? 'Loading signs...'
                        : _chapter2Unlocked
                        ? '${_chapter2!.length} signs available'
                        : 'Complete both lessons to unlock',
                    onTap: _loading || !_chapter2Unlocked
                        ? null
                        : () => _startChapter('Chapter 2'),
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

class _ChapterChoice extends StatefulWidget {
  const _ChapterChoice({
    required this.title,
    required this.subtitle,
    required this.headerColor,
    required this.onTap,
    this.locked = false,
  });

  final String title;
  final String subtitle;
  final Color headerColor;
  final VoidCallback? onTap;
  final bool locked;

  @override
  State<_ChapterChoice> createState() => _ChapterChoiceState();
}

class _ChapterChoiceState extends State<_ChapterChoice> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: widget.onTap == null ? null : () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _isPressed ? 2.0 : 0.0, 0),
        decoration: BoxDecoration(
          color: widget.locked ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.locked ? const Color(0xFF94A3B8) : const Color(0xFF14181B),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.locked ? const Color(0xFFCBD5E1) : const Color(0xFF14181B),
              offset: Offset(0, widget.locked ? 2 : (_isPressed ? 2 : 5)),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Opacity(
            opacity: widget.locked ? 0.65 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.locked ? const Color(0xFFE2E8F0) : widget.headerColor,
                    border: const Border(
                      bottom: BorderSide(
                        color: Color(0xFF14181B),
                        width: 1.6,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF14181B),
                            width: 1.3,
                          ),
                        ),
                        child: Text(
                          widget.title.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF14181B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.locked ? const Color(0xFFE2E8F0) : const Color(0xFFE0F7FF),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF14181B),
                            width: 1.3,
                          ),
                        ),
                        child: Icon(
                          widget.locked ? Icons.lock_rounded : Icons.menu_book_rounded,
                          color: widget.locked ? const Color(0xFF64748B) : const Color(0xFF22A2F2),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Color(0xFF14181B),
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Color(0xFF57636C),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF14181B), size: 26),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
>>>>>>> Stashed changes
}

class _AnswerSheet extends StatelessWidget {
  const _AnswerSheet({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
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
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF14181B),
                fontSize: 14,
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
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
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