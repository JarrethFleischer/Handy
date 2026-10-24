import 'package:flutter/material.dart';
import 'package:handy/features/practice/name_the_sign/name_the_sign_view.dart';
import 'package:handy/features/practice/quiz/quiz_view.dart';
import 'package:handy/features/leaderboard/leaderboard_controller.dart';
import 'package:handy/services/auth_service.dart';
import 'package:handy/theme/app_colors.dart';

class PracticeView extends StatefulWidget {
  const PracticeView({this.isActive = false, super.key});

  final bool isActive;

  @override
  State<PracticeView> createState() => _PracticeViewState();
}

class _PracticeViewState extends State<PracticeView> {
  final _userController = LeaderboardController();
  int _userXP = 0;
  int _userStreakCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _loadUser();
  }

  @override
  void didUpdateWidget(PracticeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _loadUser();
  }

  Future<void> _loadUser() async {
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
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              style: TextStyle(
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
                              style: TextStyle(
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
                  const SizedBox(height: 10),
                  const Text(
                    'Practice',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Refresh what you\'ve learned and build confidence',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.textDark,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PracticeCard(
                    icon: Icons.videocam_rounded,
                    title: 'Quiz',
                    description: 'Practice with AI camera',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuizView()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _PracticeCard(
                    icon: Icons.quiz,
                    title: 'Name the sign',
                    description: 'Test your knowledge',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NameTheSignView(),
                        ),
                      );
                    },
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

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.description,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String description;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.blueLight),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                child: Icon(icon, color: AppColors.blueLight, size: 36),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.grayDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.blueLight,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
