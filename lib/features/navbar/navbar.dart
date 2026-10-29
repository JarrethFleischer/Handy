import 'package:flutter/material.dart';
import 'package:handy/features/homepage/homepage_view.dart';
import 'package:handy/features/practice/practice_view.dart';
import 'package:handy/features/leaderboard/leaderboard_view.dart';
import 'package:handy/features/profile/profile_view.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFEAF6FF),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomepageView(isActive: _currentIndex == 0),
          PracticeView(isActive: _currentIndex == 1),
          LeaderboardView(isActive: _currentIndex == 2),
          ProfileView(isActive: _currentIndex == 3),
        ],
      ),
      bottomNavigationBar: AppBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex == index) return;
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class AppBottomNavbar extends StatelessWidget {
  const AppBottomNavbar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const Color _inkBlack = Color(0xFF14181B);
  static const Color _activeBlue = Color(0xFF1B9AF5);
  static const Color _sunnyYellow = Color(0xFFFFD86B);
  static const Color _softYellowPill = Color(0xFFFFF2C2);
  static const Color _inactiveSlate = Color(0xFF8CA2B4);

  Widget _buildIcon(int index, bool isSelected) {
    final color = isSelected ? _inkBlack : _inactiveSlate;
    switch (index) {
      case 0:
        return Icon(
          isSelected ? Icons.home_rounded : Icons.home_outlined,
          color: color,
          size: 24,
        );
      case 1:
        return _TargetArrowIcon(
          color: color,
          size: 23,
          isFilled: isSelected,
        );
      case 2:
        return Icon(
          isSelected ? Icons.leaderboard_rounded : Icons.leaderboard_outlined,
          color: color,
          size: 23,
        );
      case 3:
      default:
        return Icon(
          isSelected ? Icons.person_rounded : Icons.person_outline_rounded,
          color: color,
          size: 24,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Practice', 'Leaderboard', 'Profile'];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Container(
          height: 78,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: _inkBlack,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _activeBlue.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              const BoxShadow(
                color: Color(0x2614181B),
                blurRadius: 0,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Row(
              children: List.generate(labels.length, (index) {
                final isSelected = currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(index),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Lifted higher (bottom: 10) so label has plenty of breathing room above the yellow dot
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          padding: EdgeInsets.only(
                            bottom: isSelected ? 10.0 : 0.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOutCubic,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSelected ? 14 : 0,
                                  vertical: isSelected ? 3.5 : 0,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _softYellowPill
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? _sunnyYellow
                                        : Colors.transparent,
                                    width: 1.2,
                                  ),
                                ),
                                child: _buildIcon(index, isSelected),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                child: isSelected
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text(
                                          labels[index],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: _inkBlack,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),

                        // Tucked lower (bottom: -9) for clean separation from the text
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          bottom: isSelected ? -9 : -20,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: isSelected ? 1.0 : 0.0,
                            child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: _sunnyYellow,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _inkBlack,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TargetArrowIcon extends StatelessWidget {
  const _TargetArrowIcon({
    required this.color,
    required this.size,
    required this.isFilled,
  });

  final Color color;
  final double size;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TargetArrowPainter(
          color: color,
          isFilled: isFilled,
        ),
      ),
    );
  }
}

class _TargetArrowPainter extends CustomPainter {
  _TargetArrowPainter({required this.color, required this.isFilled});

  final Color color;
  final bool isFilled;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.46, size.height * 0.54);
    final outerRadius = size.width * 0.40;
    final innerRadius = size.width * 0.21;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = isFilled ? 2.2 : 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      0.15,
      5.35,
      false,
      strokePaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      0.25,
      5.15,
      false,
      strokePaint,
    );

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, isFilled ? 2.8 : 2.2, dotPaint);

    final arrowTip = center;
    final arrowTail = Offset(size.width * 0.88, size.height * 0.12);
    canvas.drawLine(arrowTip, arrowTail, strokePaint);

    final headPath = Path()
      ..moveTo(center.dx + 5.5, center.dy - 1.0)
      ..lineTo(center.dx, center.dy)
      ..lineTo(center.dx + 1.0, center.dy - 5.5);
    canvas.drawPath(headPath, strokePaint);

    final featherPath = Path()
      ..moveTo(size.width * 0.72, size.height * 0.12)
      ..lineTo(size.width * 0.72, size.height * 0.28)
      ..lineTo(size.width * 0.88, size.height * 0.28);
    canvas.drawPath(featherPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _TargetArrowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isFilled != isFilled;
  }
}