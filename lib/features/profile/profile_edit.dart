import 'package:flutter/material.dart';

class EditProfileView extends StatefulWidget {
  //const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _username = TextEditingController(text: 'Danish Syazwi');
  final _phone = TextEditingController(text: '(+60) 19 848 7025');
  final _email = TextEditingController(text: 'danish25122004@gmail.com');
  final _bio = TextEditingController(text: 'Kongkek For LIFE!!');

  @override
  void dispose() {
    _username.dispose();
    _phone.dispose();
    _email.dispose();
    _bio.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF14304A),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FF), // Light blue background
      body: Stack(
        children: [
          // 1. THE CURVED HEADER BACKGROUND
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF9AD5FF),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(MediaQuery.of(context).size.width, 120),
                ),
              ),
            ),
          ),

          // 2. THE TOP-LEFT BACK BUTTON
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFF14304A)),
                  label: const Text(
                    'Back',
                    style: TextStyle(
                      color: Color(0xFF14304A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent, // No background
                    foregroundColor: const Color(0xFF14304A),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ),
          ),

          // 3. THE MAIN SCROLLABLE FORM
          SafeArea(
            child: Padding(
              // Pushes the content down so it doesn't overlap the back button
              padding: const EdgeInsets.only(top: 60.0), 
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    
                    // --- EDITABLE AVATAR ---
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          padding: const EdgeInsets.all(4.0),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/profile_pic.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Tiny floating camera icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD465), // Yellow from your theme
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.black87, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- FORM FIELDS ---
                    _buildTextField('Username', Icons.person_outline, _username),
                    _buildTextField('Phone Number', Icons.phone_outlined, _phone),
                    _buildTextField('Email Address', Icons.email_outlined, _email),
                    _buildTextField('About Me', Icons.edit_note, _bio, maxLines: 3),

                    const SizedBox(height: 24),

                    // --- SAVE BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF67B5FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.black, width: 1.5), 
                          ),
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus(); 
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
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