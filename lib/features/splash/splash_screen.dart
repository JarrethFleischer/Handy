import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:handy/features/login/login.dart'; // Import the SVG package

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4BA6FF),
      body: Stack(
        children: [
          // 1. THE FULL SCREEN BACKGROUND IMAGE (Bottom Layer)
          Positioned.fill(
            child: Image.asset(
              'assets/images/full_screen_bg.png',
              fit: BoxFit
                  .cover, // This forces the image to stretch and fill every corner
            ),
          ),

          // 2. YOUR UI (Top Layer)
          SafeArea(
            bottom: false,
            // EVERYTHING MUST BE INSIDE THIS COLUMN
            child: Column(
              children: [
                // --- 1. TOP HEADER ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // REPLACE the string with your team's actual logo asset path
                      SvgPicture.asset(
                        'assets/images/logo.svg',
                        height: 32, // Adjust size as needed
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- 2. MIDDLE CARD (Responsive Vector Background) ---
                Expanded(
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        // 1. Define the master width for the card (80% of screen)
                        double cardWidth =
                            MediaQuery.of(context).size.width * 0.8;

                        // We wrap the Stack in a SizedBox so the Stack boundaries
                        // perfectly match the SVG background.
                        return SizedBox(
                          width: cardWidth,
                          child: SvgPicture.asset(
                            'assets/images/splash_small_bg.svg',
                            width: cardWidth,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // --- 3. BOTTOM SHEET (White Box with Curved Corners) ---
                Container(
                  width: double.infinity,
                  // This decoration creates the white background and rounds the top corners
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(32, 48, 32, 56),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Learn Fast',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'with ',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          // THE YELLOW HIGHLIGHT WITH SOLID SHADOW
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal:
                                  12, // slightly widened so it looks like a box
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBB03B), // Yellow color
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ), // Solid black border
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black, // Solid shadow color
                                  offset: Offset(
                                    4,
                                    4,
                                  ), // Pushes shadow down and right
                                  blurRadius:
                                      0, // No blur makes it a solid block
                                ),
                              ],
                            ),
                            child: const Text(
                              'Handy',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Master sign language while\nhaving fun with our interactive\nfeatures!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'GET STARTED   »',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ], // <--- The Column safely closes down here now!
            ),
          ),
        ],
      ),
    );
  }
}
