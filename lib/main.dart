import 'package:flutter/material.dart';
import 'package:handy/features/splash/splash_screen.dart';
import 'package:handy/features/widget/sound.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return ClickSoundLayer(child: child ?? const SizedBox.shrink());
      },
      home: SplashScreen(),
    );
  }
}
