import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Auth/service/firebase_otp_service.dart';
import 'package:sportbook/routes/app_routes.dart';

class SignInWithOtpScreen extends StatefulWidget {
  const SignInWithOtpScreen({super.key});

  @override
  State<SignInWithOtpScreen> createState() => _SignInWithOtpScreenState();
}

class _SignInWithOtpScreenState extends State<SignInWithOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  final _firebaseOtpService = getIt<FirebaseOtpService>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length < 9) {
      return 'Please enter a valid phone number';
    }
    return null;
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

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final rawPhone = _phoneController.text.trim();
    final fullPhoneNumber = _formatPhoneNumber(rawPhone);

    setState(() => _isLoading = true);

    try {
      await _firebaseOtpService.sendOtp(
        phoneNumber: fullPhoneNumber,
        onCodeSent: (verificationId) {
          if (!mounted) return;
          setState(() => _isLoading = false);

          // ✅ THE FIX: Use Navigator.push with MaterialPageRoute
          Navigator.pushNamed(
            context,
            AppRoutes.otpVerify,
            arguments: {
              'flow': 'otpLogin',
              'phoneNumber': fullPhoneNumber,
              'verificationId': verificationId,
            },
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
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      appBar: AppBar(),
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
                  const SizedBox(height: 8),
                  _buildSubHeader(isDark),
                  const SizedBox(height: 32),
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
          'Phone Sign In',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSubHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Enter your phone number to receive OTP',
            style: TextStyle(
              color: isDark ? Colors.white54 : AppTheme.kLightTextSub,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
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
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
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
            Text(
              'Phone Number',
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 15,
              ),
              validator: _validatePhone,
              decoration: InputDecoration(
                hintText: '012 345 678',
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.phone_rounded,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A 6-digit verification code will be sent to this number',
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSendOtp,
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
                            'Send Code',
                            style: TextStyle(
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

  Widget _buildFooter(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Back to',
          style: TextStyle(
            color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          child: Text(
            'Sign In',
            style: TextStyle(
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
