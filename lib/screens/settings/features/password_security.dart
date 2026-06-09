import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';

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

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_currentPasswordController.text.isEmpty) {
      _showError('Please enter current password');
      return;
    }
    if (_newPasswordController.text.isEmpty) {
      _showError('Please enter new password');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    // Handle password change
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed successfully!')),
    );
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
          'Password & Security',
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
                          'Security Tips',
                          style: TextStyle(
                            color: isDark ? Colors.white : AppTheme.kLightText,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Use a strong password with letters, numbers, and symbols',
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
              'CHANGE PASSWORD',
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
              label: 'Current Password',
              obscure: _obscureCurrent,
              onToggle: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // New Password
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'New Password',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Confirm Password
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
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
                onPressed: _changePassword,
                style: AppTheme.elevatedButtonStyle(),
                child: const Text('Change Password'),
              ),
            ),

            const SizedBox(height: 24),

            // Two-Factor Authentication
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecorationAdaptive(context),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.verified_user, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Two-Factor Authentication',
                          style: TextStyle(
                            color: isDark ? Colors.white : AppTheme.kLightText,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add an extra layer of security',
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
                  Switch(
                    value: false,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('2FA coming soon')),
                      );
                    },
                    activeColor: AppTheme.kAccent,
                  ),
                ],
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
