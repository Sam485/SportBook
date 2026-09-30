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

enum VerifyFlow { otpLogin, signup, forgetPassword }

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

  // Flow state variables
  VerifyFlow _flow = VerifyFlow.otpLogin;
  String _phoneNumber = '';
  String? _verificationId;
  RegisterRequestDto? _userData;

  final _userService = getIt<UserService>();
  final _tokenService = getIt<TokenService>();
  final _firebaseOtpService = getIt<FirebaseOtpService>();

  @override
  void initState() {
    super.initState();
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      final args = route?.settings.arguments;

      if (args is Map<String, dynamic>) {
        final flowString = args['flow'] as String? ?? '';
        final phone = args['phoneNumber'] as String? ?? '';
        final verificationId = args['verificationId'] as String?;
        final userData = args['userData'];

        setState(() {
          _flow = _parseFlow(flowString);
          _phoneNumber = phone;
          _verificationId = verificationId;
          _userData = userData is RegisterRequestDto ? userData : null;
        });
      } else if (args is RegisterRequestDto) {
        setState(() {
          _flow = VerifyFlow.signup;
          _userData = args;
          _phoneNumber = args.phone;
        });
      } else {}

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _focusNodes[0].requestFocus();
        }
      });
    });
  }

  VerifyFlow _parseFlow(String flow) {
    switch (flow.toLowerCase()) {
      case 'signup':
        return VerifyFlow.signup;
      case 'forgetpassword':
      case 'forget_password':
      case 'resetpassword':
      case 'reset_password':
        return VerifyFlow.forgetPassword;
      case 'otplogin':
      case 'otp_login':
      default:
        return VerifyFlow.otpLogin;
    }
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

    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseOtpService.sendOtp(
        phoneNumber: _phoneNumber,
        isResend: true,
        onCodeSent: (verificationId) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _verificationId = verificationId;
          });
          _startTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'OTP resent successfully',
                style: const TextStyle(fontFamily: AppTheme.fontFamily),
              ),
              backgroundColor: Colors.green,
            ),
          );
        },
        onFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          _showError(e.message ?? 'Failed to resend OTP (${e.code})');
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showError(e.toString());
    }
  }

  Future<void> _verifyOtp() async {
    if (!_isComplete) return;

    setState(() => _isLoading = true);

    try {
      User user = await _firebaseOtpService.verifyOtp(
        smsCode: _otp,
        verificationIdOverride: _verificationId,
      );

      final firebaseToken = await user.getIdToken(true);
      if (firebaseToken == null) {
        throw Exception('Failed to get Firebase token');
      }

      if (!mounted) return;

      switch (_flow) {
        case VerifyFlow.signup:
          await _handleSignupFlow(firebaseToken);
          break;
        case VerifyFlow.forgetPassword:
          await _handleForgetPasswordFlow(firebaseToken);
          break;
        case VerifyFlow.otpLogin:
          await _handleOtpLoginFlow(firebaseToken);
          break;
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = e.message ?? 'Verification failed';

        if (e.code == 'invalid-verification-code') {
          errorMessage = 'Invalid OTP code. Please try again.';
          _clearFields();
        } else if (e.code == 'session-expired') {
          errorMessage = 'OTP session expired. Please request a new code.';
          _clearFields();
        } else if (e.code == 'too-many-requests') {
          errorMessage = 'Too many attempts. Please try again later.';
        } else if (e.code == 'missing-verification-id') {
          errorMessage = 'Session expired. Please request a new OTP.';
          _clearFields();
        }

        _showError(errorMessage);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _showError('Verification failed: ${e.toString()}');
        _clearFields();
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignupFlow(String firebaseToken) async {
    if (_userData == null) {
      throw Exception('User data is missing for signup');
    }

    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      fcmToken = '';
    }

    final response = await _userService.registerUserWithFirebase(
      userData: _userData!,
      firebaseToken: firebaseToken,
      fcmToken: fcmToken ?? '',
    );

    await _tokenService.saveTokens(response.tokenModel);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created successfully!',
            style: const TextStyle(fontFamily: AppTheme.fontFamily),
          ),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _isLoading = false);
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  Future<void> _handleForgetPasswordFlow(String firebaseToken) async {
    if (mounted) {
      _clearFields();
      setState(() => _isLoading = false);

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.resetPassword,
        arguments: {
          'phoneNumber': _phoneNumber,
          'firebaseToken': firebaseToken,
        },
        (route) => false,
      );
    }
  }

  Future<void> _handleOtpLoginFlow(String firebaseToken) async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      fcmToken = '';
    }

    final response = await _userService.loginWithFirebase(
      firebaseToken: firebaseToken,
      fcmToken: fcmToken ?? '',
    );

    await _tokenService.saveTokens(response.tokenModel);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
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

  String _getButtonText() {
    switch (_flow) {
      case VerifyFlow.signup:
        return 'Verify & Create Account';
      case VerifyFlow.forgetPassword:
        return 'Verify & Reset Password';
      case VerifyFlow.otpLogin:
        return 'Verify & Sign In';
    }
  }

  String _getHeaderSubtitle() {
    switch (_flow) {
      case VerifyFlow.signup:
        return 'Enter the 6-digit code sent to verify your account';
      case VerifyFlow.forgetPassword:
        return 'Enter the 6-digit code sent to reset your password';
      case VerifyFlow.otpLogin:
        return 'Enter the 6-digit code sent to sign in';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.kAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _flow == VerifyFlow.forgetPassword
                ? Icons.lock_reset_rounded
                : _flow == VerifyFlow.signup
                ? Icons.person_add_rounded
                : Icons.verified_user_rounded,
            color: AppTheme.kAccent,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _flow == VerifyFlow.forgetPassword
              ? 'Reset Password'
              : _flow == VerifyFlow.signup
              ? 'Create Account'
              : 'Enter OTP',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getHeaderSubtitle(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
            fontSize: 14,
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
                          _getButtonText(),
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
                fontFamily: AppTheme.fontFamily,
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
                    ? AppTheme.kAccent.withValues(alpha: 0.08)
                    : (isDark
                          ? AppTheme.kCardAlt.withValues(alpha: 0.4)
                          : AppTheme.kLightCardAlt.withValues(alpha: 0.4)),
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
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        canResend
            ? GestureDetector(
                onTap: _isLoading ? null : _resendOtp,
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
                    _isLoading ? 'Sending...' : 'Resend',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
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
                  fontFamily: AppTheme.fontFamily,
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
            fontFamily: AppTheme.fontFamily,
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
