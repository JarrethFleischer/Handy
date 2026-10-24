import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/chapter1_view.dart';
import 'package:handy/features/chapters/chapter_controller.dart';
import 'package:handy/features/leaderboard/leaderboard_controller.dart';
import 'package:handy/services/auth_service.dart';
import 'package:handy/theme/app_colors.dart';
import 'package:handy/theme/shimmer_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomepageView extends StatefulWidget {
  const HomepageView({required this.isActive, super.key});

  final bool isActive;

  static const _body = TextStyle(
    fontFamily: 'Inter',
    color: AppColors.textDark,
    fontSize: 14,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
  );

  static const _caption = TextStyle(
    fontFamily: 'Inter',
    color: AppColors.textDark,
    fontSize: 12,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
  );

  static const _title = TextStyle(
    fontFamily: 'Inter',
    color: AppColors.textDark,
    fontSize: 18,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
  );

  static const _badge = TextStyle(
    fontFamily: 'Inter',
    color: AppColors.textDark,
    fontSize: 12,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
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
        precacheImage(
          const AssetImage('assets/images/background.png'),
          context,
        ),
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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
          child: SafeArea(
            top: true,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // BIM Pill (Mock Dropdown - currently disabled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '🇲🇾',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'BIM',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: Colors.grey[600],
                              ), // Dropdown arrow
                            ],
                          ),
                        ),

                        // Trophies and Streaks (Using SVG placeholders)
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/trophy.png',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_userXP',
                              style: const TextStyle(
                                color: Color(0xFF14304A),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 16),

                            Image.asset(
                              'assets/images/streak.png',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_userStreakCount',
                              style: const TextStyle(
                                color: Color(0xFFFA6C5E),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        children: [
                          Text(_error!, style: HomepageView._body),
                          TextButton(
                            onPressed: _loadHomepage,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._chapters.asMap().entries.map(
                      (entry) => _buildChapter(entry.value, entry.key),
                    ),
                ],
              ),
            ),
          ),
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
          child: Opacity(
            opacity: unlocked ? 1 : 0.55,
            child: _ChapterCard(
              label: chapter.chapterStory.chapterTitle,
              title: chapter.chapterStory.chapterDesc,
              progress: '$completed of ${lessons.length} lessons completed',
              progressValue: progressValue,
              icon: unlocked ? Icons.play_circle : Icons.lock,
              iconColor: AppColors.blueLight,
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
        ),
        _ExpandableSection(
          expanded: unlocked && expanded,
          child: Column(
            children: [
              Container(
                width: 10,
                height: 20,
                decoration: const BoxDecoration(color: AppColors.grayLight),
              ),
              for (var i = 0; i < lessons.length; i++) ...[
                if (i > 0) const _LessonSpacer(),
                Builder(
                  builder: (context) {
                    final lesson = lessons[i];
                    final score = _score(chapter.chapterID, lesson.lessonNo);
                    final lessonOpen =
                        i == 0 ||
                        _score(chapter.chapterID, lessons[i - 1].lessonNo) > 0;
                    return _LessonCard(
                      title: lesson.lessonTitle,
                      subtitle: lesson.lessonDesc,
                      icon: lessonOpen ? Icons.play_circle : Icons.lock,
                      iconColor: AppColors.blueLight,
                      isLoading: _isLoading,
                      progressValue: score,
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
                                      setState(() => _userXP = profile.userXP);
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
      ],
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

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.label,
    required this.title,
    required this.progress,
    required this.progressValue,
    required this.icon,
    required this.iconColor,
    this.isExpanded,
    this.onTap,
    this.isLoading = false,
  });

  final String label;
  final String title;
  final String progress;
  final double progressValue;
  final IconData icon;
  final Color iconColor;
  final bool? isExpanded;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      expanded: isExpanded,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 150),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF9CCFFD), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.blueLight.withOpacity(1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 85,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.blueLight,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShimmerText(
                            label,
                            style: HomepageView._badge,
                            isLoading: isLoading,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: iconColor, size: 34),
                        if (isExpanded != null) ...[
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            turns: isExpanded! ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.textDark,
                              size: 28,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                  child: ShimmerText(
                    title,
                    style: HomepageView._title,
                    isLoading: isLoading,
                  ),
                ),
                ShimmerText(
                  progress,
                  style: HomepageView._caption,
                  isLoading: isLoading,
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 6, 0, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      borderRadius: BorderRadius.circular(10),
                      minHeight: 10,
                      backgroundColor: Color(0xFFC4C4C4),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.blueDark,
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

class _LessonSpacer extends StatelessWidget {
  const _LessonSpacer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(color: AppColors.white),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.progressValue = 0,
    this.onTap,
    this.isLoading = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final double progressValue;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.grayLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerText(
                        title,
                        style: HomepageView._title,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 4),
                      ShimmerText(
                        subtitle,
                        style: HomepageView._body,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                _LessonBadge(
                  locked: icon == Icons.lock,
                  progress: progressValue,
                ),
              ],
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
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 14,
              backgroundColor: AppColors.gray,
              color: isComplete ? AppColors.yellowDark : AppColors.blueDark,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: locked
                ? const Icon(Icons.lock, color: Color(0xFF8A8A8A), size: 18)
                : isComplete
                ? Image.asset(
                    'assets/images/trophy.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  )
                : Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
