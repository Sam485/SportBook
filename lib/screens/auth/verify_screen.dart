import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/routes/app_routes.dart';

// ignore: must_be_immutable
class VerifyScreen extends StatefulWidget {
  bool isSignUp;
  VerifyScreen({super.key, required this.isSignUp});

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

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    setState(() {}); // rebuild to update button state
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

  Future<void> _verify() async {
    if (!_isComplete) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate API call
    setState(() => _isLoading = false);
    if (mounted) {
      if (widget.isSignUp == true) {
        Navigator.pushReplacementNamed(context, AppRoutes.createProfile);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header()),
              const SliverToBoxAdapter(child: SizedBox(height: 36)),
              SliverToBoxAdapter(child: _otpFields()),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              SliverToBoxAdapter(child: _resendRow()),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(child: _verifyButton()),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_backToLogin()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.kAccent.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.verified_user_rounded,
            size: 40,
            color: AppTheme.kAccent,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Verify Your Phone',
          style: AppTheme.tsTitle.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Enter the 6-digit code sent to\nyour registered phone number',
          style: AppTheme.tsBody.copyWith(fontSize: 15, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _otpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (index) {
        return SizedBox(
          width: 48,
          height: 58,
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
              style: AppTheme.tsTitle.copyWith(fontSize: 22),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _controllers[index].text.isNotEmpty
                        ? AppTheme.kAccent
                        : AppTheme.kCardAlt,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.kAccent, width: 2),
                ),
                filled: true,
                fillColor: _controllers[index].text.isNotEmpty
                    ? AppTheme.kAccent.withOpacity(0.08)
                    : AppTheme.kCardAlt.withOpacity(0.4),
              ),
              onChanged: (val) {
                // Handle paste
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

  Widget _resendRow() {
    final canResend = _secondsLeft == 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code? ",
          style: AppTheme.tsBody.copyWith(fontSize: 14),
        ),
        canResend
            ? GestureDetector(
                onTap: _startTimer,
                child: Text(
                  'Resend',
                  style: AppTheme.tsAccent.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : Text(
                'Resend in ${_secondsLeft}s',
                style: AppTheme.tsAccent.copyWith(
                  fontSize: 14,
                  color: AppTheme.kTextSub,
                ),
              ),
      ],
    );
  }

  Widget _verifyButton() {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isComplete && !_isLoading ? _verify : null,
        style: AppTheme.elevatedButtonStyle(),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text('Verify OTP', style: AppTheme.tsButtonLabel),
      ),
    );
  }

  Widget _backToLogin() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Back to "),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Login',
              style: AppTheme.tsAccent.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
