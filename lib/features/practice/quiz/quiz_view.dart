import 'package:flutter/material.dart';
import 'package:handy/features/practice/quiz/quiz_loader_view.dart';
import 'package:handy/features/chapters/chapter_controller.dart';
import 'package:handy/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizView extends StatefulWidget {
  const QuizView({super.key});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizChapter {
  const _QuizChapter({
    required this.title,
    required this.signs,
    this.comingSoon = false,
  });

  final String title;
  final List<String> signs;
  final bool comingSoon;
}

class _QuizViewState extends State<QuizView> {
  List<_QuizChapter> _chapters = const [];
  Set<String> _completed = {};
  bool _loading = true;
  String? _error;
  bool _showProTip = true;

  String get _userPrefix => '${AuthService.currentUserId}:';

  @override
  void initState() {
    super.initState();
    _loadSigns();
  }

  String _labelFromUrl(String url) {
    final name = Uri.parse(url).pathSegments.last;
    final stem = name.replaceAll(RegExp(r'\.mp4$', caseSensitive: false), '');
    return stem
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map(
          (word) => word.length == 1
              ? word.toUpperCase()
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Future<void> _loadSigns() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final chapters = await ChapterController().fetchChapters();
      final groups = <_QuizChapter>[];
      for (final chapter in chapters) {
        final labels = <String, String>{};
        for (final lesson in chapter.chapterStory.chapterContent) {
          for (final question in lesson.lessonQuestions) {
            final text = question.questionText.trim();
            for (final url in question.playableVideoUrls) {
              if (!url.toLowerCase().contains('.mp4')) continue;
              labels.putIfAbsent(
                url,
                () => text.isNotEmpty ? text : _labelFromUrl(url),
              );
            }
          }
        }
        if (labels.isEmpty) continue;
        final title = chapter.chapterStory.chapterTitle.trim();
        groups.add(
          _QuizChapter(
            title: title.isEmpty ? 'Chapter ${chapter.chapterLevel}' : title,
            signs: labels.values.toList(),
            comingSoon: chapter.chapterLevel == 2,
          ),
        );
      }
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('quiz_completed') ?? [];
      setState(() {
        _chapters = groups;
        _completed = saved
            .where((item) => item.startsWith(_userPrefix))
            .map((item) => item.substring(_userPrefix.length))
            .toSet();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load the quiz';
      });
    }
  }

  Future<void> _practiceSign(BuildContext context, String sign) async {
    final passed = await QuizLoaderView.open(
      context,
      expectedSign: sign,
      xpReward: _completed.contains(sign) ? 0 : 100,
    );
    if (passed != true || !context.mounted) return;
    try {
      await AuthService.recordStreak();
    } catch (error) {
      debugPrint('Streak activity could not be logged: $error');
    }
    final alreadyDone = _completed.contains(sign);
    if (!alreadyDone) {
      try {
        await AuthService.addXp(100);
      } on AuthException catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('quiz_completed') ?? [];
      await prefs.setStringList('quiz_completed', [
        ...saved,
        '$_userPrefix$sign',
      ]);
      if (!mounted) return;
      setState(() => _completed.add(sign));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3FAFF),
        body: Stack(
          children: [
            // Sky Gradient + Dot Grid Background
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFDDF1FF),
                      Color(0xFFF3FAFF),
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: _SubtleDotGridPainter(),
                ),
              ),
            ),

            SafeArea(
              top: true,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar with Back Button
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
                      'Quiz Arena',
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
                      'Select a word to practice with live AI camera',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF57636C),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(child: _buildList()),
                  ],
                ),
              ),
            ),

            // Sticky Pro-Tip Bottom Banner with 'X' Close Button
            if (_showProTip)
              Positioned(
                left: 20,
                right: 20,
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF14181B),
                      width: 1.8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF14181B),
                        offset: Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD86B),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF14181B),
                            width: 1.3,
                          ),
                        ),
                        child: const Icon(
                          Icons.lightbulb_rounded,
                          color: Color(0xFF14181B),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI CAMERA PRO TIP',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF14181B),
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'Keep your hand centered in good lighting for fast recognition!',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF57636C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _showProTip = false),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF14181B),
                              width: 1.3,
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Color(0xFF14181B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF22A2F2)),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadSigns,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14181B),
                foregroundColor: Colors.white,
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 90),
      children: [
        for (final chapter in _chapters) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 10),
            child: Text(
              chapter.comingSoon
                  ? '${chapter.title} · Coming soon'
                  : chapter.title,
              style: TextStyle(
                fontFamily: 'Inter',
                color: chapter.comingSoon
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF14181B),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (chapter.comingSoon)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _QuizRowCard(
                indexNumber: 0,
                label: 'Coming soon',
                isLocked: true,
                isDone: false,
                onTap: null,
              ),
            )
          else
            for (var index = 0; index < chapter.signs.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _QuizRowCard(
                  indexNumber: index + 1,
                  label: chapter.signs[index],
                  isLocked:
                      index > 0 &&
                      !_completed.contains(chapter.signs[index - 1]),
                  isDone: _completed.contains(chapter.signs[index]),
                  onTap:
                      index > 0 &&
                          !_completed.contains(chapter.signs[index - 1])
                      ? null
                      : () => _practiceSign(context, chapter.signs[index]),
                ),
              ),
        ],
      ],
    );
  }
}

class _QuizRowCard extends StatefulWidget {
  const _QuizRowCard({
    required this.indexNumber,
    required this.label,
    required this.isLocked,
    required this.isDone,
    required this.onTap,
  });

  final int indexNumber;
  final String label;
  final bool isLocked;
  final bool isDone;
  final VoidCallback? onTap;

  @override
  State<_QuizRowCard> createState() => _QuizRowCardState();
}

class _QuizRowCardState extends State<_QuizRowCard> {
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
          color: widget.isDone ? const Color(0xFF00E676) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isLocked
                ? const Color(0xFF94A3B8)
                : const Color(0xFF14181B),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isLocked
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF14181B),
              offset: Offset(0, widget.isLocked ? 2 : (_isPressed ? 2 : 4)),
              blurRadius: 0,
            ),
          ],
        ),
        child: Opacity(
          opacity: widget.isLocked ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Number / Status Icon Badge on the Left
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.isDone ? Colors.white : const Color(0xFFE0F7FF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF14181B),
                      width: 1.3,
                    ),
                  ),
                  child: widget.isLocked
                      ? const Icon(
                          Icons.lock_rounded,
                          color: Color(0xFF64748B),
                          size: 16,
                        )
                      : widget.isDone
                          ? const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF14181B),
                              size: 18,
                            )
                          : Text(
                              '${widget.indexNumber}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF22A2F2),
                              ),
                            ),
                ),
                const SizedBox(width: 14),

                // Word Label
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: const Color(0xFF14181B),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                // Action Indicator on the Right
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.isDone
                        ? Colors.white.withOpacity(0.3)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF14181B),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    widget.isLocked
                        ? Icons.lock_outline_rounded
                        : (widget.isDone
                            ? Icons.replay_rounded
                            : Icons.videocam_rounded),
                    color: const Color(0xFF14181B),
                    size: 18,
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