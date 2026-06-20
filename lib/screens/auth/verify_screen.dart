// lib/screens/auth/verify_screen.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Auth/service/firebase_otp_service.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/feature/User/model/register_request_dto.dart';
import 'package:sportbook/feature/User/service/user_service.dart';
import 'package:sportbook/routes/app_routes.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  static const int _otpLength = 6;
  static const int _resendCooldown = 60;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  int _secondsLeft = _resendCooldown;
  Timer? _timer;
  bool _isLoading = false;
  String _flow = '';
  String _phoneNumber = '';
  RegisterRequestDto? _userData;

  final _userService = getIt<UserService>();
  final _tokenService = getIt<TokenService>();
  final _firebaseOtpService = getIt<FirebaseOtpService>();

  @override
  void initState() {
    super.initState();
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        setState(() {
          _flow = args['flow'] ?? '';
          _userData = args['userData'];
          _phoneNumber = args['phoneNumber'] ?? '';
        });
      } else if (args is RegisterRequestDto) {
        setState(() {
          _flow = 'signup';
          _userData = args;
        });
      }
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  bool get _isComplete => _otp.length == _otpLength;

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  void _onPaste(String pasted, int index) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    for (int i = 0; i < _otpLength && i < digits.length; i++) {
      _controllers[i].text = digits[i];
    }
    final next = (digits.length < _otpLength) ? digits.length : _otpLength - 1;
    _focusNodes[next].requestFocus();
    setState(() {});
  }

  void _clearFields() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  Future<void> _resendOtp() async {
    if (_secondsLeft > 0 || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      await _firebaseOtpService.sendOtp(
        phoneNumber: _phoneNumber,
        isResend: true,
        onCodeSent: (verificationId) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _startTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP resent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showError(e.message ?? 'Failed to resend OTP (${e.code})');
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  Future<void> _verifyOtp() async {
    if (!_isComplete) return;
    setState(() => _isLoading = true);

    try {
      // 1. Verify OTP with Firebase
      User? user = await _firebaseOtpService.verifyOtp(smsCode: _otp);

      if (user == null) {
        user = FirebaseAuth.instance.currentUser;
      }

      if (user == null) {
        throw Exception('No user found after verification');
      }

      // 2. Get Firebase ID token
      final firebaseToken = await user.getIdToken(true);
      if (firebaseToken == null) {
        throw Exception('Failed to get Firebase token');
      }

      // 3. Get FCM token
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        fcmToken = '';
      }

      print('🔵 Flow: $_flow');
      print('🔵 UserData: $_userData');

      if (mounted) {
        // Check the flow
        if (_flow == 'signup' && _userData != null) {
          // Sign up flow - register the user
          print('📝 Sign up flow - registering user...');
          final response = await _userService.registerUserWithFirebase(
            userData: _userData!,
            firebaseToken: firebaseToken,
            fcmToken: fcmToken ?? '',
          );
          await _tokenService.saveTokens(response.tokenModel);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        } else {
          // OTP Login flow - call /auth/phone-login
          print('📝 OTP Login flow - calling /auth/phone-login...');
          final response = await _userService.loginWithFirebase(
            firebaseToken: firebaseToken,
            fcmToken: fcmToken ?? '',
          );
          await _tokenService.saveTokens(response.tokenModel);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = e.message ?? 'Verification failed';
        if (e.code == 'invalid-verification-code') {
          errorMessage = 'Invalid OTP code. Please try again.';
        } else if (e.code == 'session-expired') {
          errorMessage = 'OTP session expired. Please request a new code.';
        }
        _showError(errorMessage);
        _clearFields();
      }
    } catch (e) {
      if (mounted) {
        _showError('Verification failed: ${e.toString()}');
        _clearFields();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    final displayPhoneNumber = _phoneNumber.isNotEmpty
        ? _phoneNumber
        : _userData?.phone ?? '+855968877203';

    String getButtonText() {
      if (_flow == 'signup') {
        return 'Verify & Create Account';
      } else if (_flow == 'otpLogin') {
        return 'Verify & Sign In';
      } else if (_flow == 'forgetPassword') {
        return 'Verify & Reset Password';
      }
      return 'Verify';
    }

    return Scaffold(
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
                  _buildHeader(isDark, displayPhoneNumber),
                  const SizedBox(height: 32),
                  _buildFormCard(isDark, getButtonText()),
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

  Widget _buildHeader(bool isDark, String phoneNumber) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.kAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            color: AppTheme.kAccent,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Enter OTP',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the 6-digit code sent to',
          style: TextStyle(
            color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
            fontSize: 14,
          ),
        ),
        Text(
          phoneNumber,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(bool isDark, String buttonText) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOtpFields(isDark),
          const SizedBox(height: 20),
          _buildResendRow(isDark),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isComplete && !_isLoading ? _verifyOtp : null,
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
                          buttonText,
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
    );
  }

  Widget _buildOtpFields(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (index) {
        final hasText = _controllers[index].text.isNotEmpty;
        return SizedBox(
          width: 44,
          height: 56,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyEvent(event, index),
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasText
                        ? AppTheme.kAccent
                        : (isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.kAccent,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: hasText
                    ? AppTheme.kAccent.withOpacity(0.08)
                    : (isDark
                          ? AppTheme.kCardAlt.withOpacity(0.4)
                          : AppTheme.kLightCardAlt.withOpacity(0.4)),
              ),
              onChanged: (val) {
                if (val.length > 1) {
                  _controllers[index].text = val[0];
                  _onPaste(val, index);
                  return;
                }
                _onChanged(val, index);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResendRow(bool isDark) {
    final canResend = _secondsLeft == 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Didn\'t receive the code?',
          style: TextStyle(
            color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        canResend
            ? GestureDetector(
                onTap: _resendOtp,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.kAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isLoading ? 'Resending...' : 'Resend',
                    style: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            : Text(
                '${_secondsLeft}s',
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ],
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
          onTap: () => Navigator.pop(context),
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
