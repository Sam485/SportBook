import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/feature/User/model/login_request_dto.dart';
import 'package:sportbook/feature/User/service/user_service.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/translations/app_translations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isChecked = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController =
      TextEditingController(); // Renamed for clarity
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _userRService = getIt<UserService>();
  final _tokenService = getIt<TokenService>();
  String? _identifierError;

  Future<void> _handleLogin(String input, String password) async {
    try {
      final loginRequest = LoginRequestDto.fromInput(input, password);
      final response = await _userRService.loginUser(loginRequest);
      await _tokenService.saveTokens(response.tokenModel);

      // Dismiss loading dialog before navigation
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
      }

      if (mounted) {
        Navigator.pop(context); // Go back (if needed)
        Navigator.pushNamed(context, AppRoutes.verify);
      }
    } catch (e) {
      // Dismiss loading dialog first
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('login_failed'.tr(context)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header(isDark)),
              const SliverToBoxAdapter(child: SizedBox(height: 15)),
              SliverToBoxAdapter(child: _Input(isDark)),
              const SliverToBoxAdapter(child: SizedBox(height: 15)),
              SliverToBoxAdapter(child: _confirmButton()),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_orSignUp(isDark)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: isDark ? Colors.black : AppTheme.kLightCardAlt,
          maxRadius: 80,
          minRadius: 40,
          child: Icon(
            Icons.person,
            size: 60,
            color: isDark ? Colors.white : AppTheme.kLightText,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'login'.tr(context),
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'welcome_back'.tr(context),
          style: TextStyle(
            color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _Input(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'email_phone_username'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _identifierController,
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
              ),
              validator: (value) => _validateIdentifier(value, context),
              onChanged: (value) {
                // Clear error when user starts typing
                if (_identifierError != null) {
                  setState(() {
                    _identifierError = null;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'email_phone_username_hint'.tr(context),
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                errorText: _identifierError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: AppTheme.kAccent,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                filled: true,
                fillColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'password'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'password_required'.tr(context);
                }
                if (value.length < 6) {
                  return 'password_min_length'.tr(context);
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'password_hint'.tr(context),
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                prefixIcon: Icon(
                  Icons.lock,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: AppTheme.kAccent,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                filled: true,
                fillColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                  },
                  activeColor: AppTheme.kAccent,
                  checkColor: Colors.black,
                ),
                const SizedBox(width: 5),
                Text(
                  'remember_me'.tr(context),
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.forget);
                  },
                  child: Text(
                    'forgot_password'.tr(context),
                    style: TextStyle(
                      color: AppTheme.kAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _validateIdentifier(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return 'identifier_required'.tr(context);
    }

    final trimmedValue = value.trim();

    // Check if it's an email
    final isEmail = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(trimmedValue);

    // Check if it's a valid phone number (Cambodian format)
    final isPhoneNumber = RegExp(
      r'^(\+855|855|0)[0-9]{8,9}$',
    ).hasMatch(trimmedValue);

    // Check if it's a username (alphanumeric and some special characters, min 3 chars)
    final isUsername = RegExp(r'^[a-zA-Z0-9._]{3,30}$').hasMatch(trimmedValue);

    if (isEmail) {
      return null; // Valid email
    } else if (isPhoneNumber) {
      return null; // Valid phone number
    } else if (isUsername) {
      return null; // Valid username
    } else {
      // Provide specific error message based on what the user entered
      if (trimmedValue.contains('@')) {
        return 'invalid_email_format'.tr(context);
      } else if (RegExp(r'^[0-9]+$').hasMatch(trimmedValue)) {
        if (trimmedValue.length < 9 || trimmedValue.length > 12) {
          return 'invalid_phone_length'.tr(context);
        }
        return 'invalid_phone_format'.tr(context);
      } else if (trimmedValue.length < 3) {
        return 'username_too_short'.tr(context);
      } else if (trimmedValue.length > 30) {
        return 'username_too_long'.tr(context);
      } else {
        return 'invalid_identifier'.tr(context);
      }
    }
  }

  Widget _confirmButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _validateAndLogin();
        },
        style: AppTheme.elevatedButtonStyle(),
        child: Text(
          'login'.tr(context),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  void _validateAndLogin() async {
    // Clear previous errors
    setState(() {
      _identifierError = null;
    });

    // Validate form
    if (_formKey.currentState!.validate()) {
      // Additional validation before login
      final identifier = _identifierController.text.trim();
      final password = _passwordController.text.trim();

      if (identifier.isEmpty) {
        setState(() {
          _identifierError = 'identifier_required'.tr(context);
        });
        return;
      }

      if (password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('password_required'.tr(context)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _handleLogin(identifier, password);
    }
  }

  Widget _orSignUp(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'dont_have_account'.tr(context),
            style: TextStyle(
              color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.signUp);
            },
            child: Text(
              'sign_up'.tr(context),
              style: TextStyle(
                color: AppTheme.kAccent,
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
