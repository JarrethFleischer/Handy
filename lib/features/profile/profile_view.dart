import 'package:flutter/material.dart';
import 'package:handy/features/feedback/feedback_screen.dart';
import 'package:handy/features/leaderboard/leaderboard_controller.dart';
import 'package:handy/features/profile/change_password.dart';
import 'package:handy/features/profile/profile_edit.dart';
import 'package:handy/features/login/login.dart';
import 'package:handy/features/widget/popup.dart';
import 'package:handy/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({this.isActive = false, super.key});

  final bool isActive;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _controller = LeaderboardController();
  CurrentUserProfile? _profile;
  bool _isLoading = true;
  bool _restoringStreak = false;

  @override
  void initState() {
    super.initState();
    AuthService.streakCount.addListener(_syncStreakCount);
    if (widget.isActive) _load();
  }

  @override
  void dispose() {
    AuthService.streakCount.removeListener(_syncStreakCount);
    super.dispose();
  }

  void _syncStreakCount() {
    final count = AuthService.streakCount.value;
    final profile = _profile;
    if (count == null || profile == null || !mounted) return;
    setState(() {
      _profile = CurrentUserProfile(
        userID: profile.userID,
        userName: profile.userName,
        userUsername: profile.userUsername,
        userXP: profile.userXP,
        userStreakCount: count,
        streakUpdated: DateTime.now().toIso8601String(),
      );
    });
  }

  @override
  void didUpdateWidget(ProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _load();
  }

  Future<void> _openEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileView()),
    );
    if (!mounted) return;
    await _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }
      final profile = await _controller.fetchCurrentUser(userId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  bool _missedStreakDay(String? updated) {
    if (updated == null || updated.isEmpty) return false;
    final parsed = DateTime.tryParse(updated);
    if (parsed == null) return false;
    final last = DateTime(parsed.year, parsed.month, parsed.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(last).inDays > 1;
  }

  Future<void> _restoreStreak() async {
    setState(() => _restoringStreak = true);
    try {
      await AuthService.restoreStreak();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Streak restored')),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _restoringStreak = false);
    }
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFFFEEED) : const Color(0xFFE0F7FF),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF14181B), width: 1.3),
        ),
        child: Icon(
          icon,
          color: isDestructive ? const Color(0xFFFF5252) : const Color(0xFF22A2F2),
          size: 19,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w800,
          color: isDestructive ? const Color(0xFFFF5252) : const Color(0xFF14181B),
          fontSize: 14.5,
        ),
      ),
      trailing: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF14181B), width: 1.2),
        ),
        child: const Icon(
          Icons.chevron_right_rounded,
          size: 16,
          color: Color(0xFF14181B),
        ),
      ),
      onTap: onTap,
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FAFF),
      body: Stack(
        children: [
          // Background Gradient + Dot Grid
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

          // Main Scrollable Content
          SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFF14181B),
              backgroundColor: const Color(0xFFFFD86B),
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                child: Column(
                  children: [
                    // --- TOP TITLE & ICON ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF14181B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.person_rounded,
                          color: Color(0xFF14181B),
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- AVATAR ---
                    _isLoading
                        ? _bone(width: 100, height: 100, circle: true)
                        : Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF14181B),
                                width: 2.2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF14181B),
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(4.5),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/profile_pic.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 14),

                    // --- NAME & EMAIL ---
                    _isLoading
                        ? Column(
                            children: [
                              const SizedBox(height: 4),
                              _bone(width: 140, height: 18),
                              const SizedBox(height: 6),
                              _bone(width: 180, height: 12),
                            ],
                          )
                        : Column(
                            children: [
                              Text(
                                _profile?.userName ?? 'User',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF14181B),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _profile?.userUsername ?? 'user@handy.app',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF57636C),
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 24),

                    // --- STREAK CARD ---
                    _isLoading
                        ? _bone(width: double.infinity, height: 140, radius: 20)
                        : _DailyStreakCard(
                            streakCount: _profile?.userStreakCount ?? 0,
                            canRestore: _missedStreakDay(_profile?.streakUpdated),
                            restoring: _restoringStreak,
                            onRestore: _restoreStreak,
                          ),
                    const SizedBox(height: 24),

                    // --- ACCOUNT SECTION ---
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Account',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF14181B),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            _buildListTile(
                              Icons.account_circle_rounded,
                              'Edit profile',
                              _openEditProfile,
                            ),
                            const Divider(height: 1, color: Color(0xFFE2E8F0), thickness: 1.2),
                            _buildListTile(
                              Icons.lock_reset_rounded,
                              'Change password',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ChangePasswordView(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- PROGRESS SECTION ---
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Progress',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF14181B),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            _buildListTile(
                              Icons.restart_alt_rounded,
                              'Reset progress',
                              () async {
                                final confirmed = await showResetProgressDialog(context);
                                if (!confirmed || !context.mounted) return;
                                try {
                                  await AuthService.resetXp();
                                } on AuthException catch (error) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.message)),
                                  );
                                  return;
                                }
                                final prefs = await SharedPreferences.getInstance();
                                final userId = '${AuthService.currentUserId}:';
                                final saved = prefs.getStringList('lesson_scores') ?? [];
                                await prefs.setStringList(
                                  'lesson_scores',
                                  saved.where((item) => !item.startsWith(userId)).toList(),
                                );
                                final completedQuiz = prefs.getStringList('quiz_completed') ?? [];
                                await prefs.setStringList(
                                  'quiz_completed',
                                  completedQuiz.where((item) => !item.startsWith(userId)).toList(),
                                );
                                if (!context.mounted) return;
                                await _load();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Progress reset to 0'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- SUPPORT SECTION ---
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Support',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF14181B),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            _buildListTile(
                              Icons.support_agent_rounded,
                              'Feedback',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FeedbackScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- LOGOUT BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFFF5252),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                              color: Color(0xFF14181B),
                              width: 1.8,
                            ),
                          ),
                          shadowColor: const Color(0xFF14181B),
                        ),
                        onPressed: () async {
                          await AuthService.logout();
                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // --- DELETE ACCOUNT BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5252),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                              color: Color(0xFF14181B),
                              width: 1.8,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          final shouldDelete = await showDeleteAccountDialog(context);
                          if (!shouldDelete || !context.mounted) return;
                          try {
                            await AuthService.deleteUser();
                            await AuthService.logout();
                            if (!context.mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          } on AuthException catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.message),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Delete Account',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Enhanced Daily Streak Card: Vertical layout with flame/deadStreak image, number, and calendar check/dead states
class _DailyStreakCard extends StatelessWidget {
  const _DailyStreakCard({
    required this.streakCount,
    required this.canRestore,
    required this.restoring,
    required this.onRestore,
  });

  final int streakCount;
  final bool canRestore;
  final bool restoring;
  final VoidCallback onRestore;
  static const _days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  @override
  Widget build(BuildContext context) {
    final todayIndex = DateTime.now().weekday % 7;
    final bool hasStreak = streakCount > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF14181B), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF14181B),
            offset: Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Vertical layout: Big image on top, number underneath
          Image.asset(
            hasStreak ? 'assets/images/streak.png' : 'assets/images/deadStreak.png',
            width: hasStreak ? 42 : 36,
            height: hasStreak ? 42 : 36,
          ),
          const SizedBox(height: 6),
          Text(
            '$streakCount',
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF14181B),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),

          // Calendar Days Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_days.length, (index) {
              final isToday = index == todayIndex;
              final daysBeforeToday = (todayIndex - index + 7) % 7;
              final bool isCompletedDay =
                  hasStreak && daysBeforeToday < streakCount;

              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCompletedDay ? const Color(0xFFFF4500) : Colors.transparent, // Orange-red for streak check days
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompletedDay ? const Color(0xFFFF4500) : const Color(0xFFCBD5E1),
                        width: isCompletedDay ? 1.2 : 2.5, // Thick dead grey line for uncompleted
                      ),
                    ),
                    child: isCompletedDay
                        ? const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _days[index],
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                      color: isToday ? const Color(0xFF14181B) : const Color(0xFF57636C),
                    ),
                  ),
                ],
              );
            }),
          ),
          if (canRestore) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: restoring ? null : onRestore,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFFFD86B),
                  foregroundColor: const Color(0xFF14181B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF14181B), width: 1.6),
                  ),
                ),
                child: Text(
                  restoring ? 'Restoring...' : 'Restore streak',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _bone({
  required double width,
  required double height,
  bool circle = false,
  double radius = 10,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFD6E6F2),
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : BorderRadius.circular(radius),
    ),
  );
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