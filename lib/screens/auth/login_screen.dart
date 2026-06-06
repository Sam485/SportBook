import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/routes/app_routes.dart';

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
        Text("Log In", style: AppTheme.tsTitle.copyWith(fontSize: 32)),
        const SizedBox(height: 10),
        Text(
          "Welcome back! Please Sign in to continue",
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
            Text("Phone or Username", style: AppTheme.tsLabel),
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
                'Phone or Username',
                suffixIcon: null,
              ),
            ),
            const SizedBox(height: 10),
            Text("Password", style: AppTheme.tsLabel),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              decoration: AppTheme.textFieldDecoration(
                Icons.lock,
                'Password',
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
                  ),
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
                ),
                const SizedBox(width: 5),
                const Text('Remember Me'),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.forget);
                  },
                  child: Text(
                    'Forget Password?',
                    style: AppTheme.tsAccent.copyWith(fontSize: 14),
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
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _validateAndLogin();
        },
        child: Text('Login', style: AppTheme.tsButtonLabel),
        style: AppTheme.elevatedButtonStyle(),
      ),
    );
  }

  void _validateAndLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(context, AppRoutes.verify, arguments: false);
    }
  }

  Widget _orSignUp() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Don't have an account?"),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.signUp);
            },
            child: Text(
              'Sign Up',
              style: AppTheme.tsAccent.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
