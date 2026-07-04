import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Auth/service/firebase_otp_service.dart';
import 'package:sportbook/feature/User/model/register_request_dto.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/screens/auth/policy_privacy_screen.dart';
import 'verify_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  final _firebaseOtpService = getIt<FirebaseOtpService>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('0')) {
      cleaned = '+855${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('855')) {
        cleaned = '+$cleaned';
      } else {
        cleaned = '+855$cleaned';
      }
    }
    return cleaned;
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please agree to the terms and conditions',
            style: const TextStyle(fontFamily: AppTheme.fontFamily),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final formattedPhone = _formatPhoneNumber(_phoneController.text.trim());

      await _firebaseOtpService.sendOtp(
        phoneNumber: formattedPhone,
        onCodeSent: (verificationId) {
          if (!mounted) return;
          setState(() => _isLoading = false);

          final registerRequest = RegisterRequestDto(
            name: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VerifyScreen(),
              settings: RouteSettings(
                name: AppRoutes.otpVerify,
                arguments: {
                  'userData': registerRequest,
                  'flow': 'signup',
                  'phoneNumber': formattedPhone,
                  'verificationId': verificationId,
                },
              ),
            ),
          );
        },
        onFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showError(e.message ?? 'Verification failed (${e.code})');
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : AppTheme.kLightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 24),
                  _buildFormCard(isDark),
                  const SizedBox(height: 20),
                  _buildFooter(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          width: 0.5,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name Field
            _buildLabel('Full Name', isDark),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fullNameController,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 15,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
              decoration: _buildInputDecoration(
                Icons.person_outline_rounded,
                'Enter your full name',
                isDark,
              ),
            ),
            const SizedBox(height: 16),

            // Phone Field
            _buildLabel('Phone Number', isDark),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 15,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (cleaned.length < 9) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
              decoration: _buildInputDecoration(
                Icons.phone_rounded,
                '+855 12 345 678',
                isDark,
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            _buildLabel('Password', isDark),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 15,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Min 6 characters',
                hintStyle: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppTheme.kAccent,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                errorStyle: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: Colors.red.shade300,
                  fontSize: 12,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password Field
            _buildLabel('Confirm Password', isDark),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 15,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return "Passwords don't match";
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Re-enter your password',
                hintStyle: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.check_circle_outline_rounded,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  ),
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppTheme.kAccent,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                errorStyle: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: Colors.red.shade300,
                  fontSize: 12,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Terms and Conditions with clickable links
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) =>
                        setState(() => _agreeToTerms = value ?? false),
                    activeColor: AppTheme.kAccent,
                    checkColor: const Color(0xFF0A1828),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: _navigateToPrivacyPolicy,
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                color: AppTheme.kAccent,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Create Account Button
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kAccent,
                  foregroundColor: const Color(0xFF0A1828),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: isDark
                      ? Colors.grey[800]
                      : Colors.grey[300],
                  textStyle: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Color(0xFF0A1828),
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Create Account',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        color: isDark ? Colors.white : AppTheme.kLightText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    IconData icon,
    String hint,
    bool isDark,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: AppTheme.fontFamily,
        color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
      ),
      errorStyle: TextStyle(
        fontFamily: AppTheme.fontFamily,
        color: Colors.red.shade300,
        fontSize: 12,
      ),
      filled: true,
      fillColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.kAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.login),
          child: Text(
            'Sign In',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: AppTheme.kAccent,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
