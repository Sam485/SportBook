import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
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
              'phone_or_username'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'phone_required'.tr(context);
                }
                if (value.length < 9) {
                  return 'valid_phone_required'.tr(context);
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'phone_hint'.tr(context),
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                prefixIcon: Icon(
                  Icons.phone,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                suffixIcon: null,
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

  Widget _confirmButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _validateAndLogin();
        },
        child: Text(
          'login'.tr(context),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
        style: AppTheme.elevatedButtonStyle(),
      ),
    );
  }

  void _validateAndLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(context, AppRoutes.verify, arguments: false);
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
