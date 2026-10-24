import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:handy/features/camera/view/camera_view.dart';
import 'package:handy/theme/app_colors.dart';
=======
import 'package:handy/features/practice/quiz/quiz_loader_view.dart';
import 'package:handy/features/chapters/chapter_controller.dart';
import 'package:handy/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
>>>>>>> Stashed changes

class QuizView extends StatelessWidget {
  const QuizView({super.key});

<<<<<<< Updated upstream
  static const _quizItems = [
    'Hello',
    'Assalamualaikum',
    'Waalaikumusalam',
    'Yes',
    'No',
    'Apa khabar',
  ];
=======
  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  List<String> _quizItems = const [];
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
      final labels = <String, String>{};
      for (final chapter in chapters) {
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
      }
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('quiz_completed') ?? [];
      setState(() {
        _quizItems = labels.values.toList();
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
>>>>>>> Stashed changes

  Future<void> _practiceSign(BuildContext context, String sign) async {
    final passed = await QuizLoaderView.open(
      context,
<<<<<<< Updated upstream
      MaterialPageRoute(
        builder: (context) =>
            CameraView(purpose: CameraPurpose.liveTest, expectedSign: sign),
      ),
=======
      expectedSign: sign,
      xpReward: _completed.contains(sign) ? 0 : 100,
>>>>>>> Stashed changes
    );
    if (passed == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$sign is correct')));
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
<<<<<<< Updated upstream
                const SizedBox(height: 4),
                const Text(
                  'Select a word to begin practicing',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    itemCount: _quizItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      final label = _quizItems[index];
                      final isLocked = label != 'Hello';
                      return _QuizCard(
                        label: label,
                        isLocked: isLocked,
                        onTap: isLocked
                            ? null
                            : () => _practiceSign(context, label),
                      );
                    },
                  ),
                ),
              ],
=======
              ),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======

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
    return ListView.builder(
      itemCount: _quizItems.length,
      padding: const EdgeInsets.only(bottom: 90),
      itemBuilder: (context, index) {
        final label = _quizItems[index];
        final isDone = _completed.contains(label);
        final isLocked =
            index > 0 && !_completed.contains(_quizItems[index - 1]);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _QuizRowCard(
            indexNumber: index + 1,
            label: label,
            isLocked: isLocked,
            isDone: isDone,
            onTap: isLocked ? null : () => _practiceSign(context, label),
          ),
        );
      },
    );
  }
>>>>>>> Stashed changes
}

class _QuizRowCard extends StatefulWidget {
  const _QuizRowCard({
    required this.indexNumber,
    required this.label,
    required this.isLocked,
    required this.onTap,
  });

  final int indexNumber;
  final String label;
  final bool isLocked;
  final VoidCallback? onTap;

  @override
  State<_QuizRowCard> createState() => _QuizRowCardState();
}

class _QuizRowCardState extends State<_QuizRowCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
    return Opacity(
      opacity: isLocked ? 0.55 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.blueDark),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
=======
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
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                    isLocked ? Icons.lock : Icons.sign_language_outlined,
                    color: AppColors.blueDark,
                    size: 23,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
=======
                    widget.isLocked
                        ? Icons.lock_outline_rounded
                        : (widget.isDone
                            ? Icons.replay_rounded
                            : Icons.videocam_rounded),
                    color: const Color(0xFF14181B),
                    size: 18,
>>>>>>> Stashed changes
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