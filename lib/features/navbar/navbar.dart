import 'package:flutter/material.dart';
import 'package:handy/features/homepage/homepage_view.dart';
import 'package:handy/features/practice/practice_view.dart';

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
      body: IndexedStack(
        index: _currentIndex,
        children: const [HomepageView(), PracticeView(), _ProfilePlaceholder()],
      ),
      bottomNavigationBar: AppBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF1F4F8),
      body: SafeArea(
        child: Center(
          child: Text(
            'Profile',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF14181B),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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

  Widget _selectedIcon(IconData icon) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      // decoration: const BoxDecoration(
      //   color: Color(0x14249689),
      //   borderRadius: BorderRadius.all(Radius.circular(14)),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Color(0x66249689),
      //       blurRadius: 30,
      //       spreadRadius: 1,
      //       offset: Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Icon(icon, color: const Color(0xFF386BF6), size: 26),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / 3;
        final indicatorWidth = tabWidth * 0.40;

        return Stack(
          children: [
            BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              iconSize: 26,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF386BF6),
              unselectedItemColor: const Color(0xFF57636C),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: _selectedIcon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.fitness_center_outlined),
                  activeIcon: _selectedIcon(Icons.fitness_center),
                  label: 'Practice',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: _selectedIcon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              top: 0,
              left:
                  (tabWidth * currentIndex) + ((tabWidth - indicatorWidth) / 2),
              width: indicatorWidth,
              height: 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF386BF6),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xAA386BF6),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
