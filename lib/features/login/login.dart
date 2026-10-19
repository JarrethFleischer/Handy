import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:handy/features/homepage/homepage_view.dart';
import 'package:handy/features/navbar/navbar.dart';
import 'package:handy/features/sign%20up/signup.dart';
import 'package:handy/services/auth_service.dart';
import 'package:handy/features/login/forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.login(
        username: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AppNavigationShell()),
        (route) => false,
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // void _submit() {
  //   if (!_formKey.currentState!.validate()) return;

  //   // NEW ROUTING: Direct pushReplacement instead of named routes
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => const HomepageView()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. The wrapper that prevents the white space at the bottom!
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 2. THE BACKGROUND IMAGE
            Positioned.fill(
              child: Image.asset(
                'assets/images/auth_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment
                    .center, // Ensures the background image crop is perfectly centered
              ),
            ),

            SafeArea(
              child: Center(
                // <--- THIS IS THE WIDGET THAT CENTERS EVERYTHING
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Centers the column's children
                    children: [
                      SvgPicture.asset('assets/images/logo.svg', height: 40),
                      const SizedBox(height: 4),

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDB7B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Sign in to your\nAccount',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                children: [
                                  TextFormField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      hintText: 'Email address',
                                      hintStyle: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.mail_outline,
                                        color: Color(0xFFF8AE2B),
                                        size: 25,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!emailRegex.hasMatch(value.trim())) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  Divider(height: 1, color: Colors.grey[200]),
                                  TextFormField(
                                    controller: _password,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      hintStyle: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 14,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        color: Color(0xFFF8AE2B),
                                        size: 25,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                ),
                                child: const Text(
                                  'Forgot Your Password ?',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _loading ? null : _submit,
                                child: _loading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Log In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
