import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/routes/app_routes.dart';

class ForgetScreen extends StatefulWidget {
  const ForgetScreen({super.key});

  @override
  State<ForgetScreen> createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen> {
  bool isChecked = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header()),
              const SliverToBoxAdapter(child: SizedBox(height: 15)),
              SliverToBoxAdapter(child: _Input()),
              const SliverToBoxAdapter(child: SizedBox(height: 15)),
              SliverToBoxAdapter(child: _confirmButton()),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_orSignUp()],
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
        CircleAvatar(
          backgroundColor: Colors.black,
          maxRadius: 80,
          minRadius: 40,
          child: const Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          "Forgot Password?",
          style: AppTheme.tsTitle.copyWith(fontSize: 32),
        ),
        const SizedBox(height: 10),
        Text(
          "Reset your password",
          style: AppTheme.tsBody.copyWith(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _Input() {
    return SizedBox(
      width: double.infinity,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Phone", style: AppTheme.tsLabel),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                if (value.length < 9) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
              decoration: AppTheme.textFieldDecoration(
                Icons.phone,
                'Phone Number',
                suffixIcon: null,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _confirmButton() {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _validateAndLogin();
        },
        child: Text('Reset Password', style: AppTheme.tsButtonLabel),
        style: AppTheme.elevatedButtonStyle,
      ),
    );
  }

  void _validateAndLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(context, AppRoutes.verify);
    }
  }

  Widget _orSignUp() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Remembered your password?"),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.login);
            },
            child: Text(
              'Log In',
              style: AppTheme.tsAccent.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
