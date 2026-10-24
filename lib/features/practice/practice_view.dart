import 'package:flutter/material.dart';
import 'package:handy/features/practice/name_the_sign/name_the_sign_view.dart';
import 'package:handy/features/practice/quiz/quiz_view.dart';
<<<<<<< Updated upstream
import 'package:handy/theme/app_colors.dart';

class PracticeView extends StatelessWidget {
  const PracticeView({super.key});

=======

class PracticeView extends StatefulWidget {
  const PracticeView({this.isActive = false, super.key});

  final bool isActive;

  // Core Handy Theme Palette
  static const Color _skyBgTop = Color(0xFFDDF1FF);
  static const Color _skyBgBottom = Color(0xFFF3FAFF);
  static const Color _sunnyYellow = Color(0xFFFFD86B);
  static const Color _skyCyan = Color(0xFF7CE0FF);
  static const Color _mintGreen = Color(0xFF80F5B5);
  static const Color _inkBlack = Color(0xFF14181B);
  static const Color _slateText = Color(0xFF57636C);

  @override
  State<PracticeView> createState() => _PracticeViewState();
}

class _PracticeViewState extends State<PracticeView> {
>>>>>>> Stashed changes
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
<<<<<<< Updated upstream
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
=======
        backgroundColor: PracticeView._skyBgBottom,
        body: Stack(
          children: [
            // Clean Sky Gradient + Subtle Gamified Dot Grid Background
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      PracticeView._skyBgTop,
                      PracticeView._skyBgBottom,
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: _SubtleDotGridPainter(),
                ),
>>>>>>> Stashed changes
              ),
            ),

            // Main Content
            SafeArea(
              top: true,
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(
                  20,
                  16,
                  20,
                  120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Simple, bold "Practice" title (No BIM/Trophy/Streak bar)
                    const Text(
                      'Practice',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: PracticeView._inkBlack,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Mode 1: AI Camera Quiz
                    _GameModeCard(
                      modeBadge: 'MODE 01 • AI VISION',
                      title: 'Quiz',
                      description:
                          'Using AI camera to test your knowledge in real-time.',
                      ctaLabel: 'Start Camera Quiz',
                      headerColor: PracticeView._sunnyYellow,
                      artwork: const _CameraQuizArtwork(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizView(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),

                    // Mode 2: Name the Sign (Video + Type Meaning)
                    _GameModeCard(
                      modeBadge: 'MODE 02 • VIDEO & TYPE',
                      title: 'Name the sign',
                      description:
                          'Watch the sign video and type what the hand sign means.',
                      ctaLabel: 'Play Name the Sign',
                      headerColor: PracticeView._skyCyan,
                      artwork: const _VideoTypeArtwork(),
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
          ],
        ),
      ),
    );
  }
}

/// Clean, Tactile Game Mode Card with Circular Play Button
class _GameModeCard extends StatefulWidget {
  const _GameModeCard({
    required this.modeBadge,
    required this.title,
<<<<<<< Updated upstream
=======
    required this.description,
    required this.ctaLabel,
    required this.headerColor,
    required this.artwork,
>>>>>>> Stashed changes
    required this.onTap,
  });

  final String modeBadge;
  final String title;
<<<<<<< Updated upstream
  final VoidCallback onTap;

=======
  final String description;
  final String ctaLabel;
  final Color headerColor;
  final Widget artwork;
  final VoidCallback onTap;

  @override
  State<_GameModeCard> createState() => _GameModeCardState();
}

class _GameModeCardState extends State<_GameModeCard> {
  bool _isPressed = false;

>>>>>>> Stashed changes
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          _isPressed ? 3.0 : 0.0,
          0,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: PracticeView._inkBlack,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: PracticeView._inkBlack,
              offset: Offset(0, _isPressed ? 3 : 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored Header Strip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.headerColor,
                  border: const Border(
                    bottom: BorderSide(
                      color: PracticeView._inkBlack,
                      width: 1.8,
                    ),
<<<<<<< Updated upstream
                    const SizedBox(height: 4),
=======
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: PracticeView._inkBlack,
                          width: 1.4,
                        ),
                      ),
                      child: Text(
                        widget.modeBadge,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: PracticeView._inkBlack,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
>>>>>>> Stashed changes
                  ],
                ),
              ),

              // Main Card Body + Right Custom Artwork
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: PracticeView._inkBlack,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.description,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13.5,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                  color: PracticeView._slateText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        widget.artwork,
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Full-Width Jet Black CTA Action Bar with Circular Play Button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: PracticeView._inkBlack,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.ctaLabel,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                          // Circular Play Button
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: widget.headerColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: PracticeView._inkBlack,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Artwork for Mode 1: AI Camera Viewfinder
class _CameraQuizArtwork extends StatelessWidget {
  const _CameraQuizArtwork();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.10,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2C2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: PracticeView._inkBlack,
                  width: 1.5,
                ),
              ),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: PracticeView._sunnyYellow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PracticeView._inkBlack,
                width: 1.6,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.videocam_rounded,
                  color: PracticeView._inkBlack,
                  size: 32,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PracticeView._inkBlack,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Artwork for Mode 2: Video Player + Typing Input Box ("Aa_")
class _VideoTypeArtwork extends StatelessWidget {
  const _VideoTypeArtwork();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.12,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: PracticeView._mintGreen,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: PracticeView._inkBlack,
                  width: 1.5,
                ),
              ),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: PracticeView._skyCyan,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PracticeView._inkBlack,
                width: 1.6,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: PracticeView._inkBlack,
                          width: 1.3,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: PracticeView._inkBlack,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: PracticeView._inkBlack,
                      width: 1.2,
                    ),
                  ),
                  child: const Text(
                    'Aa_',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: PracticeView._inkBlack,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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