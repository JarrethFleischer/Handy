import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_picker/country_picker.dart';
import 'package:handy/features/login/login.dart';
import 'package:handy/features/navbar/navbar.dart';
import 'package:handy/models/auth_exception.dart';
import 'package:handy/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _selectedCountryCode = '+1';
  String _selectedFlagEmoji = '🇺🇸';

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _dob = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _dob.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFD465),
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dob.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AppNavigationShell()),
      (route) => false,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = await AuthService.create();
      await authService.signUp(
        name: _name.text.trim(),
        email: _email.text.trim(),
        dateOfBirth: _dob.text,
        phone: '$_selectedCountryCode${_phone.text.trim()}',
        password: _password.text,
      );

      if (!mounted) return;
      _navigateToHome();
    } on AuthException catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.message);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Sign up failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 450,
          ),
          child: SizedBox.expand(
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/logo.svg',
                                  height: 40,
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFDB7B),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'Create Account',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Already have an account? ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: _isLoading
                                                ? null
                                                : () =>
                                                    Navigator.pop(context),
                                            child: const Text(
                                              'Login',
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              controller: _name,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              decoration: const InputDecoration(
                                                hintText: 'Username',
                                                hintStyle: TextStyle(
                                                  color: Colors.black38,
                                                  fontSize: 14,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.person_outline,
                                                  color: Color(0xFFF8AE2B),
                                                  size: 25,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  vertical: 16,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Enter your name';
                                                }
                                                return null;
                                              },
                                            ),
                                            Divider(
                                                height: 1,
                                                color: Colors.grey[200]),
                                            TextFormField(
                                              controller: _email,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              decoration: const InputDecoration(
                                                hintText: 'email@example.com',
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
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  vertical: 16,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    !value.contains('@')) {
                                                  return 'Enter a valid email';
                                                }
                                                return null;
                                              },
                                            ),
                                            Divider(
                                                height: 1,
                                                color: Colors.grey[200]),
                                            TextFormField(
                                              controller: _dob,
                                              readOnly: true,
                                              onTap: _selectDate,
                                              decoration: const InputDecoration(
                                                hintText: 'DD/MM/YYYY',
                                                hintStyle: TextStyle(
                                                  color: Colors.black38,
                                                  fontSize: 14,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.calendar_today_outlined,
                                                  color: Color(0xFFF8AE2B),
                                                  size: 25,
                                                ),
                                                suffixIcon: Icon(
                                                  Icons.calendar_month,
                                                  color: Colors.grey,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  vertical: 16,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Select your date of birth';
                                                }
                                                return null;
                                              },
                                            ),
                                            Divider(
                                                height: 1,
                                                color: Colors.grey[200]),
                                            TextFormField(
                                              controller: _phone,
                                              keyboardType:
                                                  TextInputType.phone,
                                              decoration: InputDecoration(
                                                hintText: '123456789',
                                                hintStyle: TextStyle(
                                                  color: Colors.black38,
                                                  fontSize: 14,
                                                ),
                                                prefixIcon: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 12,
                                                    right: 8,
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      showCountryPicker(
                                                        context: context,
                                                        showPhoneCode: true,
                                                        onSelect:
                                                            (Country country) {
                                                          setState(() {
                                                            _selectedCountryCode =
                                                                country.phoneCode;
                                                            _selectedFlagEmoji =
                                                                country.flagEmoji;
                                                          });
                                                        },
                                                      );
                                                    },
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          _selectedFlagEmoji,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          '+$_selectedCountryCode',
                                                          style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          color: Colors.grey[600],
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Container(
                                                          width: 1,
                                                          height: 24,
                                                          color: Colors.grey[300],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 16,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Enter your phone number';
                                                }
                                                return null;
                                              },
                                            ),
                                            Divider(
                                                height: 1,
                                                color: Colors.grey[200]),
                                            TextFormField(
                                              controller: _password,
                                              obscureText: _obscurePassword,
                                              decoration: InputDecoration(
                                                hintText: '********',
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
                                                if (value == null ||
                                                    value.length < 6) {
                                                  return 'Password must be at least 6 characters';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        height: 56,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed:
                                              _isLoading ? null : _submit,
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.add,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Sign Up',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
