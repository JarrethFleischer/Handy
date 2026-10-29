import 'package:flutter/material.dart';
import 'package:handy/services/auth_service.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  bool _hideCurrent = true;
  bool _hideNext = true;
  bool _hideConfirm = true;
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await AuthService.changePassword(
        currentPassword: _current.text,
        newPassword: _next.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool hidden,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              color: Color(0xFF14181B),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF14181B), width: 1.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF14181B),
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              obscureText: hidden,
              validator: validator,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Color(0xFF14181B),
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF22A2F2),
                ),
                suffixIcon: IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    hidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF14181B),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
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
      backgroundColor: const Color(0xFFF3FAFF),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFDDF1FF), Color(0xFFF3FAFF)],
                ),
              ),
              child: CustomPaint(painter: _DotGridPainter()),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(
                          side: BorderSide(color: Color(0xFF14181B), width: 1.4),
                        ),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.pop(context),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF14181B),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Change password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF14181B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF14181B),
                                width: 2.2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF14181B),
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              size: 42,
                              color: Color(0xFF22A2F2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Use a new password that is different from your current one.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF57636C),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _passwordField(
                            label: 'Current password',
                            controller: _current,
                            hidden: _hideCurrent,
                            onToggle: () =>
                                setState(() => _hideCurrent = !_hideCurrent),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your current password';
                              }
                              return null;
                            },
                          ),
                          _passwordField(
                            label: 'New password',
                            controller: _next,
                            hidden: _hideNext,
                            onToggle: () =>
                                setState(() => _hideNext = !_hideNext),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Use at least 6 characters';
                              }
                              if (value == _current.text) {
                                return 'Choose a different password';
                              }
                              return null;
                            },
                          ),
                          _passwordField(
                            label: 'Confirm new password',
                            controller: _confirm,
                            hidden: _hideConfirm,
                            onToggle: () =>
                                setState(() => _hideConfirm = !_hideConfirm),
                            validator: (value) {
                              if (value != _next.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD86B),
                                foregroundColor: const Color(0xFF14181B),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(
                                    color: Color(0xFF14181B),
                                    width: 1.8,
                                  ),
                                ),
                              ),
                              onPressed: _saving ? null : _save,
                              child: Text(
                                _saving ? 'Saving...' : 'Save Changes',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
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
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22A2F2).withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    const spacing = 26.0;
    for (double x = 14; x < size.width; x += spacing) {
      for (double y = 14; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
