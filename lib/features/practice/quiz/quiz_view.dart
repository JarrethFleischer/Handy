import 'package:flutter/material.dart';
import 'package:handy/features/camera/view/camera_view.dart';
import 'package:handy/features/chapters/chapter_controller.dart';
import 'package:handy/services/auth_service.dart';
import 'package:handy/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizView extends StatefulWidget {
  const QuizView({super.key});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  List<String> _quizItems = const [];
  Set<String> _completed = {};
  bool _loading = true;
  String? _error;

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

  Future<void> _practiceSign(BuildContext context, String sign) async {
    final passed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CameraView(
              purpose: CameraPurpose.liveTest,
              expectedSign: sign,
              xpReward: _completed.contains(sign) ? 0 : 100,
            ),
      ),
    );
    if (passed != true || !context.mounted) return;
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
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textDark,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Quiz',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                Expanded(child: _buildGrid()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blueDark),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            TextButton(onPressed: _loadSigns, child: const Text('Try again')),
          ],
        ),
      );
    }
    return GridView.builder(
      itemCount: _quizItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final label = _quizItems[index];
        final isDone = _completed.contains(label);
        final isLocked =
            index > 0 && !_completed.contains(_quizItems[index - 1]);
        return _QuizCard(
          label: label,
          isLocked: isLocked,
          isDone: isDone,
          onTap: isLocked ? null : () => _practiceSign(context, label),
        );
      },
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.label,
    required this.isLocked,
    required this.isDone,
    required this.onTap,
  });

  final String label;
  final bool isLocked;
  final bool isDone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.55 : 1,
      child: Material(
        color: isDone ? AppColors.blueDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDone ? AppColors.blueDark : Colors.white,
              border: Border.all(color: AppColors.blueDark),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0x3349A69B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLocked ? Icons.lock : Icons.sign_language_outlined,
                    color: isDone ? Colors.white : AppColors.blueDark,
                    size: 23,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: isDone ? Colors.white : AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
