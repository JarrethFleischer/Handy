import 'package:flutter/material.dart';
import 'package:handy/features/profile/profile_edit.dart';
import 'package:handy/features/login/login.dart';
import 'package:handy/features/widget/popup.dart';
import 'package:handy/theme/app_colors.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  // Helper widget to build the settings rows cleanly
  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Icon(
        icon,
        color: AppColors.blueLight,
        size: 28,
      ), // Light blue icons
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          color: Color(0xFF14304A),
          fontSize: 14, // Dark navy text
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.blueLight,
      ),
      onTap: onTap, // Empty action for now
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6FF), // Very light blue background
      body: Stack(
        children: [
          // 1. THE CURVED HEADER BACKGROUND
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.blueLight, // Sky blue header
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(
                    MediaQuery.of(context).size.width,
                    150,
                  ),
                ),
              ),
            ),
          ),

          // 2. THE MAIN SCROLLABLE CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // --- TOP BAR (Language & Streaks) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0.0,
                      vertical: 16.0,
                    ),
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
                              'assets/images/coin.png',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '0',
                              style: TextStyle(
                                color: Color(0xFF14304A),
                                fontWeight: FontWeight.bold,
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
                            const Text(
                              '3',
                              style: TextStyle(
                                color: Color(0xFFFA6C5E),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- "USER" TITLE ---
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'User',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14304A),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.person_outline,
                        color: Color(0xFF14304A),
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- AVATAR ---
                  Container(
                    width: 110,
                    height: 110,
                    // The White background with Black Stroke
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ), // Black stroke
                    ),
                    padding: const EdgeInsets.all(
                      4.0,
                    ), // The white gap before the image
                    child: ClipOval(
                      // ClipOval forces any square image to become a perfect circle!
                      child: Image.asset(
                        'assets/images/profile_pic.png', // CHANGE THIS TO YOUR PNG PATH
                        fit: BoxFit
                            .cover, // Ensures the image fills the circle perfectly
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- NAME & EMAIL ---
                  const Text(
                    'Danish Syazwi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF14304A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'danish25122004@gmail.com',
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 30),
                  // --- SETTINGS CARD ---
                  _DailyStreakCard(),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Row(
                      children: const [
                        Text(
                          'Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF14304A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // THE FIX: We use a Material widget instead of a BoxDecoration!
                    child: Material(
                      color: Colors.white,
                      clipBehavior: Clip
                          .antiAlias, // Keeps the tap ripples inside the rounded corners
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: AppColors.blueLight,
                          width: 1,
                        ), // Black stroke
                      ),
                      child: Column(
                        children: [
                          _buildListTile(
                            Icons.account_circle,
                            'Edit profile',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileView(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: Color(0xFF9AD5FF)),
                          _buildListTile(Icons.password, 'Change password', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileView(),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Row(
                      children: const [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF14304A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // THE FIX: We use a Material widget instead of a BoxDecoration!
                    child: Material(
                      color: Colors.white,
                      clipBehavior: Clip
                          .antiAlias, // Keeps the tap ripples inside the rounded corners
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: AppColors.blueLight,
                          width: 1,
                        ), // Black stroke
                      ),
                      child: Column(
                        children: [
                          _buildListTile(Icons.repeat, 'Reset progress', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileView(),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Row(
                      children: const [
                        Text(
                          'Support',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF14304A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // THE FIX: We use a Material widget instead of a BoxDecoration!
                    child: Material(
                      color: Colors.white,
                      clipBehavior: Clip
                          .antiAlias, // Keeps the tap ripples inside the rounded corners
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: AppColors.blueLight,
                          width: 1,
                        ), // Black stroke
                      ),
                      child: Column(
                        children: [
                          _buildListTile(Icons.support_agent, 'Feedback', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileView(),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- LOGOUT BUTTON ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.transparent, // Coral Red
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.red, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 85,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }, // Empty action
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppColors.incorrect, // Coral Red
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () async {
                      final shouldDelete = await showDeleteAccountDialog(
                        context,
                      );
                      if (!shouldDelete || !context.mounted) {
                        return;
                      }
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40), // Spacing for the bottom navbar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyStreakCard extends StatelessWidget {
  const _DailyStreakCard();

  static const _days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  @override
  Widget build(BuildContext context) {
    final todayIndex = DateTime.now().weekday % 7;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.blueLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Start daily streak!',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF14304A),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_days.length, (index) {
              return _StreakDay(
                label: _days[index],
                isToday: index == todayIndex,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StreakDay extends StatelessWidget {
  const _StreakDay({required this.label, required this.isToday});

  final String label;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: isToday
              ? Image.asset('assets/images/streak.png')
              : Center(
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.blueLight),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isToday ? AppColors.blueDark : AppColors.blueLight,
          ),
        ),
      ],
    );
  }
}

// class _DashedCirclePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = AppColors.blueDark
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.6;
//     const dashCount = 14;
//     final radius = size.shortestSide / 2 - 1;
//     final center = Offset(size.width / 2, size.height / 2);
//     const sweep = 3.14159 * 2 / dashCount;
//     for (var index = 0; index < dashCount; index += 2) {
//       canvas.drawArc(
//         Rect.fromCircle(center: center, radius: radius),
//         index * sweep,
//         sweep * 0.7,
//         false,
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
