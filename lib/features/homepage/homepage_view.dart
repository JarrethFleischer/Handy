import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/lesson_1_view.dart';
import 'package:handy/features/chapters/chapter 1/lesson_2_view.dart';
import 'package:handy/theme/app_colors.dart';
import 'package:handy/theme/shimmer_text.dart';

class HomepageView extends StatefulWidget {
  const HomepageView({super.key});

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
  bool _isChapterOneExpanded = false;
  bool _isLoading = true;
  bool _didStartLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didStartLoading) {
      return;
    }
    _didStartLoading = true;
    _loadHomepage();
  }

  Future<void> _loadHomepage() async {
    await Future.wait([
      precacheImage(const AssetImage('assets/images/background.png'), context),
      precacheImage(const AssetImage('assets/images/trophy.png'), context),
      precacheImage(const AssetImage('assets/images/streak.png'), context),
    ]);
    if (mounted) {
      setState(() {
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
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Image.asset(
                            'assets/images/trophy.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          ShimmerText(
                            '2',
                            style: HomepageView._body,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          20,
                          0,
                          0,
                          0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Image.asset(
                              'assets/images/streak.png',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            ShimmerText(
                              '0',
                              style: HomepageView._body,
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                    child: _ChapterCard(
                      label: 'CHAPTER 1',
                      title: 'Hello and Welcome',
                      progress: '1 of 4 lessons completed',
                      progressValue: 0.25,
                      icon: Icons.play_circle,
                      iconColor: const Color(0xFF386BF6),
                      isLoading: _isLoading,
                      isExpanded: _isChapterOneExpanded,
                      onTap: () {
                        setState(() {
                          _isChapterOneExpanded = !_isChapterOneExpanded;
                        });
                      },
                    ),
                  ),
                  _ExpandableSection(
                    expanded: _isChapterOneExpanded,
                    child: Column(
                      children: [
                        Container(
                          width: 10,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.grayLight,
                          ),
                        ),
                        _LessonCard(
                          title: 'Lesson 1',
                          subtitle: 'Discover new Vocabulary',
                          icon: Icons.check_circle,
                          iconColor: Color(0xFF386BF6),
                          isLoading: _isLoading,
                          progressValue: 1,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Lesson1View(),
                              ),
                            );
                          },
                        ),
                        const _LessonSpacer(),
                        _LessonCard(
                          title: 'Lesson 2',
                          subtitle: 'Discover new Vocabulary',
                          icon: Icons.play_circle,
                          iconColor: Color(0xFF386BF6),
                          isLoading: _isLoading,
                          progressValue: 0.25,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Lesson2View(),
                              ),
                            );
                          },
                        ),
                        const _LessonSpacer(),
                        _LessonCard(
                          title: 'Lesson 3',
                          subtitle: 'Practice a dialogue',
                          icon: Icons.lock,
                          iconColor: AppColors.blueLight,
                          isLoading: _isLoading,
                          progressValue: 0,
                        ),
                        const _LessonSpacer(),
                        _LessonCard(
                          title: 'Lesson 4',
                          subtitle: 'Practice with your camera',
                          icon: Icons.lock,
                          iconColor: AppColors.blueLight,
                          isLoading: _isLoading,
                          progressValue: 0,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                    child: Opacity(
                      opacity: 0.55,
                      child: _ChapterCard(
                        label: 'CHAPTER 2',
                        title: 'Basics of the Language',
                        progress: '0 of 4 lessons completed',
                        progressValue: 0.0,
                        icon: Icons.lock,
                        iconColor: Color(0xFF386BF6),
                        isLoading: _isLoading,
                      ),
                    ),
                  ),
                  _ExpandableSection(
                    expanded: false,
                    child: Column(
                      children: [
                        Container(
                          width: 10,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.grayLight,
                          ),
                        ),
                        _LessonCard(
                          title: 'Lesson 1',
                          subtitle: 'Discover new Vocabulary',
                          icon: Icons.check_circle,
                          iconColor: Color(0xFF386BF6),
                          progressValue: 1,
                          isLoading: _isLoading,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Lesson1View(),
                              ),
                            );
                          },
                        ),
                        const _LessonSpacer(),
                        _LessonCard(
                          title: 'Lesson 2',
                          subtitle: 'Discover new Vocabulary',
                          icon: Icons.play_circle,
                          iconColor: AppColors.blueLight,
                          progressValue: 0.25,
                          isLoading: _isLoading,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Lesson1View(),
                              ),
                            );
                          },
                        ),
                        const _LessonSpacer(),
                        _LessonCard(
                          title: 'Lesson 3',
                          subtitle: 'Practice a dialogue',
                          icon: Icons.play_circle,
                          iconColor: AppColors.blueLight,
                          progressValue: 0,
                          isLoading: _isLoading,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Lesson1View(),
                              ),
                            );
                          },
                        ),
                        const _LessonSpacer(),
                        _LessonCard(
                          title: 'Lesson 4',
                          subtitle: 'Practice with your camera',
                          icon: Icons.play_circle,
                          iconColor: AppColors.blueLight,
                          progressValue: 0,
                          isLoading: _isLoading,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Lesson1View(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
                color: const Color.fromARGB(255, 0, 136, 255).withOpacity(0.5),
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
                        color: const Color(0xFF9CCFFD),
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
                        Color(0xFF386BF6),
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
