import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/User/model/change_pass_reqeuest_dto.dart';
import 'package:sportbook/feature/User/service/user_service.dart';
import 'package:sportbook/translations/app_translations.dart';

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  State<PasswordSecurityScreen> createState() => _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState extends State<PasswordSecurityScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  late final UserService _userService;

  @override
  void initState() {
    super.initState();
    _userService = getIt<UserService>();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    // Validate inputs
    if (_currentPasswordController.text.isEmpty) {
      _showError('enter_current_password'.tr(context));
      return;
    }
    if (_newPasswordController.text.isEmpty) {
      _showError('enter_new_password'.tr(context));
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showError('password_min_length'.tr(context));
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('passwords_do_not_match'.tr(context));
      return;
    }

    // Show loading
    setState(() => _isLoading = true);

    try {
      final request = ChangePasswordRequestDto(
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      await _userService.changePassword(request);

      if (mounted) {
        setState(() => _isLoading = false);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('password_changed_success'.tr(context)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        // Navigate back after delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        String errorMessage = e.toString();
        // Clean up error message
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.replaceAll('Exception: ', '');
        }
        if (errorMessage.contains('Server error:')) {
          errorMessage = errorMessage.replaceAll('Server error: ', '');
        }
        _showError(errorMessage);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
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
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : AppTheme.kLightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'password_security'.tr(context),
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecorationAdaptive(context),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.kAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield, color: AppTheme.kAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'security_tips'.tr(context),
                          style: TextStyle(
                            color: isDark ? Colors.white : AppTheme.kLightText,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'strong_password_tip'.tr(context),
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.kTextSub
                                : AppTheme.kLightTextSub,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Change Password Section
            Text(
              'change_password_section'.tr(context).toUpperCase(),
              style: TextStyle(
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Current Password
            _buildPasswordField(
              controller: _currentPasswordController,
              label: 'current_password'.tr(context),
              obscure: _obscureCurrent,
              onToggle: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // New Password
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'new_password'.tr(context),
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Confirm Password
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'confirm_new_password'.tr(context),
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Change Password Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: AppTheme.elevatedButtonStyle(),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('change_password'.tr(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(
        color: isDark ? Colors.white : AppTheme.kLightText,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
          ),
          onPressed: onToggle,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.kAccent, width: 2),
        ),
        filled: true,
        fillColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
      ),
    );
  }
}
