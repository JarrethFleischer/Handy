import 'package:flutter/material.dart';
import 'package:handy/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const Color _brandYellow = Color(0xFFFFD56B);
  static const Color _brandOrange = Color(0xFFF59E0B);
  static const Color _brandBlue = Color(0xFF1DA1F2);
  static const Color _brandBlack = Color(0xFF0F0F0F);

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
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
      prefixIcon: Icon(icon, color: _brandOrange, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _brandOrange, width: 2),
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
          color: _brandBlack,
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
          backgroundColor: _brandBlack,
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
                  strokeWidth: 2.5,
                  color: _brandYellow,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _brandBlack,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please enter your email to receive an OTP code',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _brandBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the OTP code sent to ${_email.text.trim()}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
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
              style: TextButton.styleFrom(
                foregroundColor: _brandBlue,
              ),
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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _brandBlack,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a new password. Ensure it differs from previous ones.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar: Circular Back Button + Yellow Step Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: _loading ? null : _back,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: _brandBlack,
                        size: 26,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _brandYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Step ${_step + 1} of 3',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _brandBlack,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Only one step visible at a time.
              Visibility(visible: _step == 0, child: _emailStep()),
              Visibility(visible: _step == 1, child: _otpStep()),
              Visibility(visible: _step == 2, child: _passwordStep()),
            ],
          ),
        ),
      ),
    );
  }
}