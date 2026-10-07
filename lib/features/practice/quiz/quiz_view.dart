import 'package:flutter/material.dart';
import 'package:handy/features/camera/view/camera_view.dart';
import 'package:handy/theme/app_colors.dart';

class QuizView extends StatelessWidget {
  const QuizView({super.key});

  static const _quizItems = [
    'Hello',
    'Assalamualaikum',
    'Waalaikumusalam',
    'Yes',
    'No',
    'Apa khabar',
  ];

  Future<void> _practiceSign(BuildContext context, String sign) async {
    final passed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CameraView(purpose: CameraPurpose.liveTest, expectedSign: sign),
      ),
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
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.label,
    required this.isLocked,
    required this.onTap,
  });

  final String label;
  final bool isLocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
