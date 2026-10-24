import 'package:flutter/material.dart';
import 'package:handy/features/navbar/navbar.dart';
import 'package:handy/features/splash/splash_screen.dart';
import 'package:handy/features/widget/sound.dart';
import 'package:handy/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final signedIn = await AuthService.restoreSession();
  runApp(MainApp(signedIn: signedIn));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.signedIn});

  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return ClickSoundLayer(child: child ?? const SizedBox.shrink());
      },
      home: signedIn ? const AppNavigationShell() : const SplashScreen(),
    );
  }
}
