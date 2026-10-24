import 'dart:math';

import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/learn_sign_question.dart';
import 'package:handy/features/chapters/chapter_controller.dart';
import 'package:handy/features/widget/sound.dart';
import 'package:handy/services/auth_service.dart';
import 'package:handy/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NameTheSignView extends StatefulWidget {
  const NameTheSignView({super.key});

  @override
  State<NameTheSignView> createState() => _NameTheSignViewState();
}

class _SignPrompt {
  const _SignPrompt({this.videoAsset, this.videoUrl, required this.answers});

  final String? videoAsset;
  final String? videoUrl;
  final List<String> answers;

  String get key => videoUrl ?? videoAsset ?? '';
}

class _NameTheSignViewState extends State<NameTheSignView> {
  final _answerController = TextEditingController();
  final _random = Random();

  String? _chapter;
  List<_SignPrompt>? _chapter1;
  List<_SignPrompt>? _chapter2;
  bool _chapter1Unlocked = false;
  bool _chapter2Unlocked = false;
  List<_SignPrompt> _signs = const [];
  int _index = 0;
  bool? _isCorrect;
  bool _loading = false;
  String? _error;

  _SignPrompt? get _current =>
      _signs.isEmpty || _index >= _signs.length ? null : _signs[_index];

  @override
  void initState() {
    super.initState();
    _answerController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _prefetchChapters();
  }

  Future<void> _prefetchChapters() async {
    try {
      final chapters = await ChapterController().fetchChapters();
      if (!mounted) return;
      final scores = await _readLessonScores();
      if (!mounted) return;
      setState(() {
        _chapter1 = _signsForLevel(chapters, 1);
        _chapter2 = _signsForLevel(chapters, 2);
        _chapter1Unlocked = _lessonsStarted(chapters, 1, scores);
        _chapter2Unlocked = _lessonsStarted(chapters, 2, scores);
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[\s\-]+'), ' ');
  }

  String _labelFromUrl(String url) {
    final name = Uri.parse(url).pathSegments.last;
    final stem = name.replaceAll(RegExp(r'\.mp4$', caseSensitive: false), '');
    final words = stem
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map(
          (word) => word.length == 1
              ? word.toUpperCase()
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .toList();
    return words.join(' ');
  }

  Future<Map<String, double>> _readLessonScores() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('lesson_scores') ?? [];
    final scores = <String, double>{};
    for (final item in saved) {
      final split = item.split('=');
      if (split.length == 2) {
        scores[split[0]] = double.tryParse(split[1]) ?? 0;
      }
    }
    return scores;
  }

  bool _lessonsStarted(
    List<Chapter> chapters,
    int level,
    Map<String, double> scores,
  ) {
    final matches = chapters.where((item) => item.chapterLevel == level);
    if (matches.isEmpty) return false;
    final userId = AuthService.currentUserId ?? 0;
    for (final chapter in matches) {
      final lessons = chapter.chapterStory.chapterContent;
      if (lessons.isEmpty) return false;
      for (final lesson in lessons) {
        final score =
            scores['$userId:${chapter.chapterID}:${lesson.lessonNo}'] ?? 0;
        if (score <= 0) return false;
      }
    }
    return true;
  }

  List<_SignPrompt> _signsForLevel(List<Chapter> chapters, int level) {
    final byUrl = <String, Set<String>>{};

    for (final chapter in chapters.where((item) => item.chapterLevel == level)) {
      for (final lesson in chapter.chapterStory.chapterContent) {
        for (final question in lesson.lessonQuestions) {
          for (final url in question.playableVideoUrls) {
            if (!url.toLowerCase().contains('.mp4')) continue;
            final answers = byUrl.putIfAbsent(url, () => <String>{});
            final fromName = _labelFromUrl(url);
            if (fromName.isNotEmpty) answers.add(fromName);
            final text = question.questionText.trim();
            if (text.isNotEmpty && question.questionVideos.length == 1) {
              answers.add(text);
            }
          }
        }
      }
    }

    return byUrl.entries
        .map(
          (entry) => _SignPrompt(
            videoUrl: entry.key,
            answers: entry.value.toList(),
          ),
        )
        .toList();
  }

  Future<void> _startChapter(String chapter) async {
    final level = chapter == 'Chapter 2' ? 2 : 1;
    final unlocked = level == 1 ? _chapter1Unlocked : _chapter2Unlocked;
    if (!unlocked) return;
    final cached = level == 1 ? _chapter1 : _chapter2;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final signs = cached == null
          ? _signsForLevel(await ChapterController().fetchChapters(), level)
          : List<_SignPrompt>.of(cached);
      signs.shuffle(_random);
      if (!mounted) return;
      if (signs.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'No videos found for $chapter';
        });
        return;
      }
      setState(() {
        _loading = false;
        _chapter = chapter;
        if (level == 1) {
          _chapter1 = signs;
        } else {
          _chapter2 = signs;
        }
        _signs = signs;
        _index = 0;
        _isCorrect = null;
      });
      _answerController.clear();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load $chapter';
      });
    }
  }

  void _checkAnswer() {
    final typed = _normalize(_answerController.text);
    if (typed.isEmpty) {
      return;
    }

    final matched = _current!.answers.any(
      (answer) => _normalize(answer) == typed,
    );

    if (!matched) {
      playIncorrectSound();
      setState(() => _isCorrect = false);
      return;
    }

    playCorrectSound();
    setState(() => _isCorrect = true);
  }

  void _leaveQuiz() {
    setState(() {
      _chapter = null;
      _signs = const [];
      _index = 0;
      _isCorrect = null;
    });
    _answerController.clear();
  }

  void _nextSign() {
    _answerController.clear();
    if (_index + 1 >= _signs.length) {
      _leaveQuiz();
      return;
    }
    setState(() {
      _index++;
      _isCorrect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_chapter == null || _current == null) {
      return _buildChapterPicker();
    }

    final current = _current!;
    final hasAnswer = _answerController.text.trim().isNotEmpty;
    final progress = ((_index + 1) / _signs.length).clamp(0.0, 1.0);
    final isLast = _index + 1 >= _signs.length;

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
                              onPressed: _leaveQuiz,
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
                            key: ValueKey(current.key),
                            assetPath: current.videoAsset,
                            videoUrl: current.videoUrl,
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
                  buttonLabel: isLast ? 'Done' : 'Next question',
                  onPressed: _nextSign,
                )
              else if (_isCorrect == false)
                _AnswerSheet(
                  color: AppColors.incorrect,
                  icon: Icons.cancel,
                  title: 'Incorrect',
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

  Widget _buildChapterPicker() {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: Color(0xFF14304A),
                ),
                label: const Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF14304A),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Name the sign',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF14304A),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a chapter to practice',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF14304A),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(color: Color(0xFF67B5FF)),
                ),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.incorrect,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _ChapterChoice(
                title: 'Chapter 1',
                locked: _chapter1 != null && !_chapter1Unlocked,
                subtitle: _chapter1 == null
                    ? 'Loading signs...'
                    : _chapter1Unlocked
                    ? '${_chapter1!.length} signs'
                    : 'Complete both lessons to unlock',
                onTap: _loading || !_chapter1Unlocked
                    ? null
                    : () => _startChapter('Chapter 1'),
              ),
              const SizedBox(height: 16),
              _ChapterChoice(
                title: 'Chapter 2',
                locked: _chapter2 != null && !_chapter2Unlocked,
                subtitle: _chapter2 == null
                    ? 'Loading signs...'
                    : _chapter2Unlocked
                    ? '${_chapter2!.length} signs'
                    : 'Complete both lessons to unlock',
                onTap: _loading || !_chapter2Unlocked
                    ? null
                    : () => _startChapter('Chapter 2'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterChoice extends StatelessWidget {
  const _ChapterChoice({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.locked = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(
                locked ? Icons.lock_outline : Icons.menu_book_outlined,
                color: const Color(0xFF67B5FF),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF14304A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF14304A)),
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
