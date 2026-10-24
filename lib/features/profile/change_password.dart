import 'package:flutter/material.dart';
import 'package:handy/services/auth_service.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  static const _navy = Color(0xFF14304A);
  static const _page = Color(0xFFEAF5FF);
  static const _header = Color(0xFF9AD5FF);
  static const _button = Color(0xFF67B5FF);

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
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: _navy,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: controller,
              obscureText: hidden,
              validator: validator,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                suffixIcon: IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    hidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
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
      backgroundColor: _page,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: _header,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(
                    MediaQuery.of(context).size.width,
                    150,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: _navy,
                  ),
                  label: const Text(
                    'Back',
                    style: TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: _navy,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Change password',
                        style: TextStyle(
                          color: _navy,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Use a new password that is different from your current one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _navy, fontSize: 14),
                      ),
                      const SizedBox(height: 32),
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
                        onToggle: () => setState(() => _hideNext = !_hideNext),
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
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _button,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _saving ? null : _save,
                          child: Text(
                            _saving ? 'Saving...' : 'Save Changes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
