import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/chapter1_view.dart';
import 'package:handy/features/chapters/chapter_controller.dart';
import 'package:handy/features/leaderboard/leaderboard_controller.dart';
import 'package:handy/services/auth_service.dart';
import 'package:handy/theme/shimmer_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the 5-color repeating palette for Chapters & their child Lessons
class _ChapterColorPalette {
  const _ChapterColorPalette({
    required this.headerBg,
    required this.lessonStubBg,
    required this.progressBarColor,
  });

  final Color headerBg;
  final Color lessonStubBg;
  final Color progressBarColor;
}

class HomepageView extends StatefulWidget {
  const HomepageView({required this.isActive, super.key});

  final bool isActive;

  // Core Theme Colors
  static const Color _skyBgTop = Color(0xFFDDF1FF);
  static const Color _skyBgBottom = Color(0xFFF3FAFF);
  static const Color _primaryBlue = Color(0xFF22A2F2);
  static const Color _sunnyYellow = Color(0xFFFFD86B);
  static const Color _deepYellow = Color(0xFFFFB800);
  static const Color _vibrantGreen = Color(0xFF00E676);
  static const Color _inkBlack = Color(0xFF14181B);
  static const Color _slateText = Color(0xFF57636C);

  // 5 Hardcoded Chapter Colors in Sequence (Repeats automatically via index % 5)
  static const List<_ChapterColorPalette> _chapterPalettes = [
    // 1. Sunny Yellow
    _ChapterColorPalette(
      headerBg: Color(0xFFFFD86B),
      lessonStubBg: Color(0xFFFFECB3),
      progressBarColor: Color(0xFF22A2F2),
    ),
    // 2. Sky Cyan
    _ChapterColorPalette(
      headerBg: Color(0xFF7CE0FF),
      lessonStubBg: Color(0xFFD6F5FF),
      progressBarColor: Color(0xFF0095FF),
    ),
    // 3. Mint Green
    _ChapterColorPalette(
      headerBg: Color(0xFF80F5B5),
      lessonStubBg: Color(0xFFD8FCE9),
      progressBarColor: Color(0xFF00C853),
    ),
    // 4. Soft Coral Peach
    _ChapterColorPalette(
      headerBg: Color(0xFFFFA88A),
      lessonStubBg: Color(0xFFFFE4DB),
      progressBarColor: Color(0xFFFF6D3F),
    ),
    // 5. Periwinkle Lavender
    _ChapterColorPalette(
      headerBg: Color(0xFFC4B5FD),
      lessonStubBg: Color(0xFFEDE9FE),
      progressBarColor: Color(0xFF7C3AED),
    ),
  ];

  static const _body = TextStyle(
    fontFamily: 'Inter',
    color: _slateText,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const _caption = TextStyle(
    fontFamily: 'Inter',
    color: _slateText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const _title = TextStyle(
    fontFamily: 'Inter',
    color: _inkBlack,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );

  static const _badge = TextStyle(
    fontFamily: 'Inter',
    color: _inkBlack,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  @override
  State<HomepageView> createState() => _HomepageViewState();
}

class _HomepageViewState extends State<HomepageView> {
  final _chapterController = ChapterController();
  final _userController = LeaderboardController();
  final Set<int> _expandedChapterIds = {};

  List<Chapter> _chapters = [];
  Map<String, double> _lessonScores = {};
  int _userXP = 0;
  int _userStreakCount = 0;
  bool _isLoading = true;
  bool _didStartLoading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didStartLoading) {
      return;
    }
    _didStartLoading = true;
    _loadHomepage();
  }

  @override
  void didUpdateWidget(HomepageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _refreshLessonScores();
      _refreshUser();
    }
  }

  Future<void> _refreshUser() async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;
    try {
      final profile = await _userController.fetchCurrentUser(userId);
      if (!mounted) return;
      setState(() {
        _userXP = profile.userXP;
        _userStreakCount = profile.userStreakCount;
      });
    } catch (_) {}
  }

  Future<void> _refreshLessonScores() async {
    final scores = await _readLessonScores();
    if (!mounted) return;
    setState(() => _lessonScores = scores);
  }

  Future<void> _loadHomepage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final chapters = await _chapterController.fetchChapters();
      CurrentUserProfile? profile;
      final userId = AuthService.currentUserId;
      if (userId != null) {
        try {
          profile = await _userController.fetchCurrentUser(userId);
        } catch (_) {}
      }
      if (!mounted) return;
      await Future.wait([
        precacheImage(const AssetImage('assets/images/coin.png'), context),
        precacheImage(const AssetImage('assets/images/streak.png'), context),
      ]);
      if (!mounted) return;
      final completed = await _readLessonScores();
      if (!mounted) return;
      setState(() {
        _chapters = chapters;
        _lessonScores = completed;
        _userXP = profile?.userXP ?? 0;
        _userStreakCount = profile?.userStreakCount ?? 0;
        if (chapters.isNotEmpty && _expandedChapterIds.isEmpty) {
          _expandedChapterIds.add(chapters.first.chapterID);
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load chapters';
        _isLoading = false;
      });
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
        backgroundColor: HomepageView._skyBgBottom,
        body: Stack(
          children: [
            // Clean Sky Gradient + Subtle Gamified Dot Grid Background
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      HomepageView._skyBgTop,
                      HomepageView._skyBgBottom,
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: _SubtleDotGridPainter(),
                ),
              ),
            ),

            // Main Foreground Content
            SafeArea(
              top: true,
              bottom: false,
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isLoading
                        ? const LinearProgressIndicator(
                            minHeight: 3,
                            backgroundColor: Color(0xFFD6ECFF),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              HomepageView._primaryBlue,
                            ),
                          )
                        : const SizedBox(height: 3),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: HomepageView._inkBlack,
                      backgroundColor: HomepageView._sunnyYellow,
                      onRefresh: _loadHomepage,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          20,
                          12,
                          20,
                          120,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopBar(),
                            const SizedBox(height: 6),
                            if (_error != null)
                              _buildErrorState()
                            else if (_isLoading && _chapters.isEmpty)
                              const _HomepageSkeletonList()
                            else
                              ..._chapters.asMap().entries.map(
                                (entry) =>
                                    _buildChapter(entry.value, entry.key),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // BIM Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: HomepageView._inkBlack, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: HomepageView._inkBlack,
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('🇲🇾', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text(
                'BIM',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: HomepageView._inkBlack,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: HomepageView._inkBlack,
              ),
            ],
          ),
        ),

        // Trophies & Streaks
        Row(
          children: [
            _StatPill(
              iconPath: 'assets/images/trophy.png',
              value: '$_userXP',
              textColor: HomepageView._inkBlack,
              bgColor: HomepageView._sunnyYellow,
              isLoading: _isLoading,
            ),
            const SizedBox(width: 10),
            _StatPill(
              iconPath: 'assets/images/streak.png',
              value: '$_userStreakCount',
              textColor: const Color(0xFFD9381E),
              bgColor: Colors.white,
              isLoading: _isLoading,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: HomepageView._inkBlack, width: 1.8),
          boxShadow: const [
            BoxShadow(
              color: HomepageView._inkBlack,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: HomepageView._primaryBlue,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: HomepageView._title.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _loadHomepage,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomepageView._inkBlack,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _lessonKey(int chapterId, int lessonNo) {
    final userId = AuthService.currentUserId ?? 0;
    return '$userId:$chapterId:$lessonNo';
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

  Future<void> _saveLessonScore(
    int chapterId,
    int lessonNo,
    double score,
  ) async {
    final key = _lessonKey(chapterId, lessonNo);
    final previous = _lessonScores[key] ?? 0;
    final best = score > previous ? score : previous;
    final scores = {..._lessonScores, key: best};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'lesson_scores',
      scores.entries.map((entry) => '${entry.key}=${entry.value}').toList(),
    );
    if (!mounted) return;
    setState(() => _lessonScores = scores);
  }

  double _score(int chapterId, int lessonNo) {
    return _lessonScores[_lessonKey(chapterId, lessonNo)] ?? 0;
  }

  bool _chapterOpen(int index) {
    final chapter = _chapters[index];
    if (!chapter.isUnlocked) return false;
    if (index == 0) return true;
    final previous = _chapters[index - 1];
    final lessons = previous.chapterStory.chapterContent;
    if (lessons.isEmpty) return true;
    return lessons.every(
      (lesson) => _score(previous.chapterID, lesson.lessonNo) > 0,
    );
  }

  Widget _buildChapter(Chapter chapter, int index) {
    final lessons = chapter.chapterStory.chapterContent;
    final completed = lessons
        .where(
          (lesson) =>
              (_lessonScores[_lessonKey(chapter.chapterID, lesson.lessonNo)] ??
                  0) >
              0,
        )
        .length;
    final progressValue = lessons.isEmpty ? 0.0 : completed / lessons.length;
    final expanded = _expandedChapterIds.contains(chapter.chapterID);
    final unlocked = _chapterOpen(index);

    // Pick 1 of the 5 colors in sequence and repeat when index >= 5
    final palette = HomepageView
        ._chapterPalettes[index % HomepageView._chapterPalettes.length];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
          child: _ChapterCard(
            label: chapter.chapterStory.chapterTitle,
            title: chapter.chapterStory.chapterDesc,
            progress: '$completed of ${lessons.length} lessons completed',
            progressValue: progressValue,
            palette: palette,
            unlocked: unlocked,
            isLoading: _isLoading,
            isExpanded: unlocked ? expanded : null,
            onTap: unlocked
                ? () {
                    setState(() {
                      if (expanded) {
                        _expandedChapterIds.remove(chapter.chapterID);
                      } else {
                        _expandedChapterIds.add(chapter.chapterID);
                      }
                    });
                  }
                : null,
          ),
        ),
        _ExpandableSection(
          expanded: unlocked && expanded,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                const _PathConnector(height: 16),
                for (var i = 0; i < lessons.length; i++) ...[
                  if (i > 0) const _PathConnector(height: 12),
                  Builder(
                    builder: (context) {
                      final lesson = lessons[i];
                      final score = _score(chapter.chapterID, lesson.lessonNo);
                      final lessonOpen =
                          i == 0 ||
                          _score(chapter.chapterID, lessons[i - 1].lessonNo) >
                              0;
                      return _LessonCard(
                        stepNumber: i + 1,
                        title: lesson.lessonTitle,
                        subtitle: lesson.lessonDesc,
                        locked: !lessonOpen,
                        isLoading: _isLoading,
                        progressValue: score,
                        unlockedStubColor: palette.lessonStubBg,
                        completedStubColor: palette.headerBg,
                        onTap: lessonOpen
                            ? () async {
                                final earned = await Navigator.push<double>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Chapter1View(
                                      lesson: lesson,
                                      awardsXp: score < 1,
                                    ),
                                  ),
                                );
                                if (earned != null) {
                                  await _saveLessonScore(
                                    chapter.chapterID,
                                    lesson.lessonNo,
                                    earned,
                                  );
                                  final userId = AuthService.currentUserId;
                                  if (userId != null) {
                                    try {
                                      final profile = await _userController
                                          .fetchCurrentUser(userId);
                                      if (mounted) {
                                        setState(
                                          () => _userXP = profile.userXP,
                                        );
                                      }
                                    } catch (_) {}
                                  }
                                }
                              }
                            : null,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Draws a very subtle, clean geometric dot pattern over the sky gradient
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

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.iconPath,
    required this.value,
    required this.textColor,
    required this.bgColor,
    this.isLoading = false,
  });

  final String iconPath;
  final String value;
  final Color textColor;
  final Color bgColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: HomepageView._inkBlack, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: HomepageView._inkBlack,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 18, height: 18),
          const SizedBox(width: 6),
          ShimmerText(
            value,
            isLoading: isLoading,
            style: TextStyle(
              fontFamily: 'Inter',
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  const _ExpandableSection({required this.expanded, required this.child});

  final bool expanded;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: expanded ? 1 : 0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      child: child,
      builder: (context, value, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: value,
            child: Opacity(
              opacity: value,
              child: IgnorePointer(ignoring: !expanded, child: child),
            ),
          ),
        );
      },
    );
  }
}

/// CHAPTER CARD: Multi-color header strip + clean regular border on the inner Chapter badge
class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.label,
    required this.title,
    required this.progress,
    required this.progressValue,
    required this.palette,
    required this.unlocked,
    this.isExpanded,
    this.onTap,
    this.isLoading = false,
  });

  final String label;
  final String title;
  final String progress;
  final double progressValue;
  final _ChapterColorPalette palette;
  final bool unlocked;
  final bool? isExpanded;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isComplete = progressValue >= 1.0;

    return Semantics(
      button: onTap != null,
      expanded: isExpanded,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: unlocked ? Colors.white : const Color(0xFFF3F7FA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: unlocked
                  ? HomepageView._inkBlack
                  : const Color(0xFFB8C7D4),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: unlocked
                    ? HomepageView._inkBlack
                    : const Color(0xFFD0DCE5),
                blurRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colored Header Banner (Cycles through 5 colors)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? palette.headerBg
                        : const Color(0xFFE2E8F0),
                    border: Border(
                      bottom: BorderSide(
                        color: unlocked
                            ? HomepageView._inkBlack
                            : const Color(0xFFCBD5E1),
                        width: 1.8,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Chapter Pill Tag -> Regular clean border, NO chunky bottom shadow!
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: unlocked
                                ? HomepageView._inkBlack
                                : const Color(0xFF94A3B8),
                            width: 1.4,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 14,
                              color: unlocked
                                  ? HomepageView._inkBlack
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 5),
                            ShimmerText(
                              label.toUpperCase(),
                              style: HomepageView._badge.copyWith(
                                letterSpacing: 0.4,
                                color: unlocked
                                    ? HomepageView._inkBlack
                                    : const Color(0xFF64748B),
                              ),
                              isLoading: isLoading,
                            ),
                          ],
                        ),
                      ),

                      // Play/Status Circle + Expand Arrow (Clean regular border inside header)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: !unlocked
                                  ? const Color(0xFFCBD5E1)
                                  : isComplete
                                  ? HomepageView._vibrantGreen
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: unlocked
                                    ? HomepageView._inkBlack
                                    : const Color(0xFF94A3B8),
                                width: 1.4,
                              ),
                            ),
                            child: Icon(
                              unlocked
                                  ? (isComplete
                                        ? Icons.check_rounded
                                        : Icons.play_arrow_rounded)
                                  : Icons.lock_rounded,
                              color: unlocked
                                  ? HomepageView._inkBlack
                                  : const Color(0xFF64748B),
                              size: 18,
                            ),
                          ),
                          if (isExpanded != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.75),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: HomepageView._inkBlack,
                                  width: 1.4,
                                ),
                              ),
                              child: AnimatedRotation(
                                turns: isExpanded! ? 0.5 : 0,
                                duration: const Duration(milliseconds: 250),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: HomepageView._inkBlack,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Chapter Body Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerText(
                        title,
                        style: HomepageView._title.copyWith(
                          color: unlocked
                              ? HomepageView._inkBlack
                              : const Color(0xFF64748B),
                        ),
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerText(
                            progress,
                            style: HomepageView._caption,
                            isLoading: isLoading,
                          ),
                          Text(
                            '${(progressValue * 100).round()}%',
                            style: HomepageView._caption.copyWith(
                              color: HomepageView._inkBlack,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: unlocked
                                ? HomepageView._inkBlack
                                : const Color(0xFFCBD5E1),
                            width: 1.4,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: progressValue),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            builder: (context, animatedValue, _) {
                              return LinearProgressIndicator(
                                value: animatedValue,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isComplete
                                      ? HomepageView._vibrantGreen
                                      : palette.progressBarColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
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
}

class _PathConnector extends StatelessWidget {
  const _PathConnector({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: height,
      decoration: const BoxDecoration(
        color: HomepageView._inkBlack,
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.locked,
    required this.unlockedStubColor,
    required this.completedStubColor,
    this.progressValue = 0,
    this.onTap,
    this.isLoading = false,
  });

  final int stepNumber;
  final String title;
  final String subtitle;
  final bool locked;
  final Color unlockedStubColor;
  final Color completedStubColor;
  final double progressValue;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isComplete = progressValue >= 1.0;
    final accentColor = locked
        ? const Color(0xFFCBD5E1)
        : isComplete
        ? completedStubColor
        : unlockedStubColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: locked ? 0.72 : 1,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: locked ? const Color(0xFFF8FAFC) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: locked
                    ? const Color(0xFF94A3B8)
                    : HomepageView._inkBlack,
                width: 1.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: locked
                      ? const Color(0xFFCBD5E1)
                      : HomepageView._inkBlack,
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.5),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Colored Stub with Step Number (01, 02...)
                    Container(
                      width: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accentColor,
                        border: Border(
                          right: BorderSide(
                            color: locked
                                ? const Color(0xFF94A3B8)
                                : HomepageView._inkBlack,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        stepNumber.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: locked
                              ? const Color(0xFF64748B)
                              : HomepageView._inkBlack,
                        ),
                      ),
                    ),

                    // Main Lesson Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShimmerText(
                                    title,
                                    style: HomepageView._title.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    isLoading: isLoading,
                                  ),
                                  const SizedBox(height: 2),
                                  ShimmerText(
                                    subtitle,
                                    style: HomepageView._body.copyWith(
                                      fontSize: 12,
                                    ),
                                    isLoading: isLoading,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _LessonBadge(
                              locked: locked,
                              progress: progressValue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonBadge extends StatelessWidget {
  const _LessonBadge({required this.locked, required this.progress});

  final bool locked;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final isComplete = progress >= 1;

    return SizedBox(
      width: 44,
      height: 44,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        builder: (context, animatedProgress, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  value: locked ? 0 : animatedProgress,
                  strokeWidth: 4.5,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: isComplete
                      ? HomepageView._deepYellow
                      : HomepageView._primaryBlue,
                ),
              ),
              Container(
                width: 33,
                height: 33,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isComplete ? HomepageView._sunnyYellow : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: locked
                        ? const Color(0xFFCBD5E1)
                        : HomepageView._inkBlack,
                    width: 1.4,
                  ),
                ),
                child: locked
                    ? const Icon(
                        Icons.lock_rounded,
                        color: Color(0xFF94A3B8),
                        size: 16,
                      )
                    : isComplete
                    ? Image.asset(
                        'assets/images/trophy.png',
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                      )
                    : Text(
                        '${(animatedProgress * 100).round()}%',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: HomepageView._inkBlack,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomepageSkeletonList extends StatefulWidget {
  const _HomepageSkeletonList();

  @override
  State<_HomepageSkeletonList> createState() => _HomepageSkeletonListState();
}

class _HomepageSkeletonListState extends State<_HomepageSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _skeletonBox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.85).animate(_controller),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFD6E6F2),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(2, (index) {
        return Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: HomepageView._inkBlack, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: HomepageView._inkBlack,
                  offset: Offset(0, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _skeletonBox(width: 95, height: 28, radius: 8),
                    _skeletonBox(width: 34, height: 34, radius: 17),
                  ],
                ),
                const SizedBox(height: 18),
                _skeletonBox(width: 190, height: 22),
                const SizedBox(height: 14),
                _skeletonBox(width: 140, height: 14),
                const SizedBox(height: 10),
                _skeletonBox(width: double.infinity, height: 13, radius: 20),
              ],
            ),
          ),
        );
      }),
    );
  }
}