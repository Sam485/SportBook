// screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/User/model/user_model.dart';
import 'package:sportbook/feature/User/service/user_service.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/screens/settings/features/editing_profile.dart';
import 'package:sportbook/translations/app_translations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = getIt<UserService>();
  UserModel? _user;
  bool _isLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _userService.addListener(_onUserServiceChanged);
    _loadUserProfile();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _userService.removeListener(_onUserServiceChanged);
    super.dispose();
  }

  void _onUserServiceChanged() {
    if (_isDisposed || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        setState(() {
          _user = _userService.currentUser;
        });
      }
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      if (mounted && !_isDisposed) {
        setState(() => _isLoading = true);
      }
      await _userService.getProfile();
      if (mounted && !_isDisposed) {
        setState(() {
          _user = _userService.currentUser;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        appBar: AppBar(
          backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
          elevation: 0,
          title: Text(
            'edit_profile'.tr(context),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: isDark ? Colors.white : AppTheme.kLightText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : AppTheme.kLightText,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.kAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        elevation: 0,
        title: Text(
          'edit_profile'.tr(context),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : AppTheme.kLightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── PROFILE INFO SECTION HEADER ──
            Text(
              'profile_info'.tr(context).toUpperCase(),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // ── NAME CARD ──
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: AppTheme.cardDecorationAdaptive(
                  context,
                  radius: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.kAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: AppTheme.kAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'full_name'.tr(context),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: isDark
                                  ? AppTheme.kTextSub
                                  : AppTheme.kLightTextSub,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _user?.fullName ?? 'SILAEND',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.kLightText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── EMAIL CARD ──
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: AppTheme.cardDecorationAdaptive(
                  context,
                  radius: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.kAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.email_outlined,
                        color: AppTheme.kAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'email_address'.tr(context),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: isDark
                                  ? AppTheme.kTextSub
                                  : AppTheme.kLightTextSub,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _user?.email ?? 'phone_855968877203@phone.local',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.kLightText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── PHONE CARD ──
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: AppTheme.cardDecorationAdaptive(
                  context,
                  radius: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.kAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.phone_outlined,
                        color: AppTheme.kAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'phone'.tr(context),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: isDark
                                  ? AppTheme.kTextSub
                                  : AppTheme.kLightTextSub,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _user?.phone ?? '+855968877203',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.kLightText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── SECURITY SECTION HEADER ──
            Text(
              'security'.tr(context).toUpperCase(),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // ── CHANGE PASSWORD CARD ──
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.changePassword);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: AppTheme.cardDecorationAdaptive(
                  context,
                  radius: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.kAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: AppTheme.kAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'change_password'.tr(context),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.kLightText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
