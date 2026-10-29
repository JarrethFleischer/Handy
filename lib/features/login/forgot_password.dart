import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:handy/services/auth_service.dart';
import 'package:handy/theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const Color _icon = Color(0xFFF8AE2B);
  static const _title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    height: 1.2,
    color: Colors.black,
  );
  static const _body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  int _step = 0;
  bool _loading = false;
  bool _obscure = true;

  final _emailKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<FormState>();
  final _passKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } on AuthException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // STEP 1: send OTP
  Future<void> _sendOtp() async {
    if (!_emailKey.currentState!.validate()) return;
    await _run(() async {
      await AuthService.sendOtp(email: _email.text.trim());
      _snack('OTP sent to ${_email.text.trim()}', error: false);
      setState(() => _step = 1);
    });
  }

  // STEP 2: no verify endpoint, so just store OTP and go to next step.
  void _confirmOtp() {
    if (!_otpKey.currentState!.validate()) return;
    setState(() => _step = 2);
  }

  // STEP 3: reset password
  Future<void> _resetPassword() async {
    if (!_passKey.currentState!.validate()) return;
    await _run(() async {
      await AuthService.resetPassword(
        email: _email.text.trim(),
        otp: _otp.text.trim(),
        newPassword: _newPass.text,
      );
      _snack('Password reset! Please log in.', error: false);
      if (mounted) Navigator.pop(context);
    });
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _step--);
    }
  }

  // Shared input decoration matching the clean wireframe + strong Login accents
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      prefixIcon: Icon(icon, color: _icon, size: 25),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _button(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.black54,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _emailStep() {
    return Form(
      key: _emailKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Forgot password',
            textAlign: TextAlign.center,
            style: _title,
          ),
          const SizedBox(height: 6),
          const Text(
            'Please enter your email to receive an OTP code',
            textAlign: TextAlign.center,
            style: _body,
          ),
          const SizedBox(height: 28),
          _fieldLabel('Your Email'),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              hint: 'name@example.com',
              icon: Icons.email_outlined,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 28),
          _button('Send OTP', _sendOtp),
        ],
      ),
    );
  }

  Widget _otpStep() {
    return Form(
      key: _otpKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Check your email',
            textAlign: TextAlign.center,
            style: _title,
          ),
          const SizedBox(height: 12),
          Text(
            'Enter the OTP code sent to ${_email.text.trim()}',
            textAlign: TextAlign.center,
            style: _body,
          ),
          const SizedBox(height: 28),
          _fieldLabel('OTP Code'),
          TextFormField(
            controller: _otp,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(
              hint: 'Enter 6-digit code',
              icon: Icons.pin_outlined,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'OTP is required' : null,
          ),
          const SizedBox(height: 28),
          _button('Continue', _confirmOtp),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _loading ? null : _sendOtp,
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text(
                'Resend OTP',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordStep() {
    return Form(
      key: _passKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Set a new password',
            textAlign: TextAlign.center,
            style: _title,
          ),
          const SizedBox(height: 12),
          const Text(
            'Create a new password. Ensure it differs from previous ones.',
            textAlign: TextAlign.center,
            style: _body,
          ),
          const SizedBox(height: 28),
          _fieldLabel('New Password'),
          TextFormField(
            controller: _newPass,
            obscureText: _obscure,
            decoration: _inputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black38,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) => (v == null || v.length < 6)
                ? 'Password must be at least 6 characters'
                : null,
          ),
          const SizedBox(height: 18),
          _fieldLabel('Confirm Password'),
          TextFormField(
            controller: _confirmPass,
            obscureText: _obscure,
            decoration: _inputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline,
            ),
            validator: (v) =>
                v != _newPass.text ? 'Passwords do not match' : null,
          ),
          const SizedBox(height: 28),
          _button('Reset Password', _resetPassword),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/auth_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SvgPicture.asset('assets/images/logo.svg', height: 40),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.yellowLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: _loading ? null : _back,
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  label: const Text(
                                    'Back',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Step ${_step + 1} of 3',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Visibility(
                              visible: _step == 0,
                              child: _emailStep(),
                            ),
                            Visibility(visible: _step == 1, child: _otpStep()),
                            Visibility(
                              visible: _step == 2,
                              child: _passwordStep(),
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
