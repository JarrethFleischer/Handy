import 'package:flutter/material.dart';
import 'package:handy/features/profile/profile_edit.dart';
import 'package:handy/features/login/login.dart';
import 'package:handy/theme/app_colors.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  // Helper widget to build the settings rows cleanly
  Widget _buildListTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.blueLight), // Light blue icons
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF14304A), // Dark navy text
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.blueLight,
      ),
      onTap: () {}, // Empty action for now
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
              child: Column(
                children: [
                  // --- TOP BAR (Language & Streaks) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
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
                  const SizedBox(height: 16),

                  // --- EDIT PROFILE BUTTON ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF67B5FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileView(),
                        ),
                      );
                    }, // Empty action
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- SETTINGS CARD ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    // THE FIX: We use a Material widget instead of a BoxDecoration!
                    child: Material(
                      color: Colors.white,
                      clipBehavior: Clip
                          .antiAlias, // Keeps the tap ripples inside the rounded corners
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ), // Black stroke
                      ),
                      child: Column(
                        children: [
                          _buildListTile(Icons.favorite, 'Favourites'),
                          _buildListTile(Icons.download, 'Downloads'),

                          const Divider(height: 1, color: Color(0xFF9AD5FF)),

                          _buildListTile(
                            Icons.spatial_audio_off_outlined,
                            'Language',
                          ),
                          _buildListTile(Icons.location_on, 'Location'),
                          _buildListTile(Icons.desktop_windows, 'Display'),

                          const Divider(height: 1, color: Color(0xFF9AD5FF)),

                          _buildListTile(Icons.history, 'Clear History'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- LOGOUT BUTTON ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
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
