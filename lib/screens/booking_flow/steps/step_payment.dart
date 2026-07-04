import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/User/service/user_service.dart';
import 'package:sportbook/translations/app_translations.dart';
import 'package:sportbook/widgets/aba_payway_sheet.dart';
import 'package:sportbook/widgets/khqr_payment_sheet.dart';

enum PaymentMethod { khqr, aba, bakong }

class StepPayment extends StatefulWidget {
  final VoidCallback onConfirm;
  final Function(String) onPaymentMethodSelected;
  final String? selectedPaymentMethod;
  final int totalPrice;
  final String? selectedSport;
  final String? courtName;
  final String? date;
  final String? timeRange;

  const StepPayment({
    super.key,
    required this.onConfirm,
    required this.onPaymentMethodSelected,
    this.selectedPaymentMethod,
    required this.totalPrice,
    this.selectedSport,
    this.courtName,
    this.date,
    this.timeRange,
  });

  @override
  State<StepPayment> createState() => StepPaymentState();
}

class StepPaymentState extends State<StepPayment>
    with TickerProviderStateMixin {
  PaymentMethod? _selected;
  PaymentMethod? _selectedSubMethod;
  bool _isPaymentCompleted = false;
  bool _isLoadingUserData = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  late AnimationController _khqrAnim;
  late AnimationController _detailAnim;

  final _authService = getIt<UserService>();

  @override
  void initState() {
    super.initState();

    if (widget.selectedPaymentMethod != null) {
      _selected = _getPaymentMethodFromString(widget.selectedPaymentMethod!);
    }

    _khqrAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _detailAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    if (_selected != null) {
      _khqrAnim.forward();
      _detailAnim.forward(from: 0);
    }

    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _khqrAnim.dispose();
    _detailAnim.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingUserData = true;
    });

    try {
      final user = _authService.currentUser;

      if (user != null && mounted) {
        if (user.fullName.isNotEmpty) {
          _nameController.text = user.fullName;
        } else if (user.fullName.isNotEmpty) {
          _nameController.text = user.fullName;
        }

        if (user.phone.isNotEmpty) {
          _phoneController.text = user.phone;
        } else if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
          _phoneController.text = user.phoneNumber!;
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    }
  }

  PaymentMethod _getPaymentMethodFromString(String method) {
    switch (method.toLowerCase()) {
      case 'khqr':
        return PaymentMethod.khqr;
      case 'aba':
        return PaymentMethod.aba;
      case 'bakong':
        return PaymentMethod.bakong;
      default:
        return PaymentMethod.khqr;
    }
  }

  String _getPaymentMethodString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.khqr:
        return 'khqr';
      case PaymentMethod.aba:
        return 'aba';
      case PaymentMethod.bakong:
        return 'bakong';
    }
  }

  void _selectMethod() {
    HapticFeedback.selectionClick();
    _showPaymentBottomSheet();
  }

  void _showPaymentBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentSelectionBottomSheet(
        totalPrice: widget.totalPrice,
        isDark: Theme.of(context).brightness == Brightness.dark,
        onSelected: (method) {
          setState(() {
            _selectedSubMethod = method;
            _isPaymentCompleted = false;
            widget.onPaymentMethodSelected(_getPaymentMethodString(method));
          });
          _khqrAnim.forward();
          _detailAnim.forward(from: 0);
          Navigator.pop(context);

          _showPaymentSheet(method);
        },
      ),
    );
  }

  void _showPaymentSheet(PaymentMethod method) {
    final amount = widget.totalPrice.toDouble();

    switch (method) {
      case PaymentMethod.aba:
        showAbaPaywaySheet(
          context: context,
          amount: amount,
          onSuccess: () {
            setState(() {
              _isPaymentCompleted = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Payment successful!',
                  style: const TextStyle(fontFamily: AppTheme.fontFamily),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
        break;

      case PaymentMethod.bakong:
      case PaymentMethod.khqr:
        showKhqrPaymentSheet(
          context: context,
          amount: amount,
          onSuccess: () {
            setState(() {
              _isPaymentCompleted = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Payment successful!',
                  style: const TextStyle(fontFamily: AppTheme.fontFamily),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
        break;
    }
  }

  void handleConfirm() {
    if (!mounted) return;

    if (_selectedSubMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'select_payment_method'.tr(context),
            style: const TextStyle(fontFamily: AppTheme.fontFamily),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!_isPaymentCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'please_complete_payment_first'.tr(context),
            style: const TextStyle(fontFamily: AppTheme.fontFamily),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      widget.onConfirm();
    }
  }

  void _retryPayment() {
    if (_selectedSubMethod != null) {
      _showPaymentSheet(_selectedSubMethod!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          'payment_method'.tr(context),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'choose_payment_desc'.tr(context),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 28),
        _UserInfoForm(
          formKey: _formKey,
          nameController: _nameController,
          phoneController: _phoneController,
          isDark: isDark,
          isLoading: _isLoadingUserData,
        ),
        const SizedBox(height: 24),
        _BookingSummaryCard(
          totalPrice: widget.totalPrice,
          selectedSport: widget.selectedSport,
          courtName: widget.courtName,
          date: widget.date,
          timeRange: widget.timeRange,
          isDark: isDark,
        ),
        const SizedBox(height: 28),
        Text(
          'select_payment_section'.tr(context),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        _PaymentCard(
          selected: _selectedSubMethod != null,
          isPaymentCompleted: _isPaymentCompleted,
          animController: _khqrAnim,
          onTap: _selectMethod,
          onRetry: _retryPayment,
          icon: _isPaymentCompleted
              ? const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF4CAF50),
                  size: 28,
                )
              : const Icon(
                  Icons.qr_code_rounded,
                  color: Color(0xFF0072CE),
                  size: 28,
                ),
          title: _isPaymentCompleted ? 'Payment Completed' : 'QR / KHQR',
          subtitle: _isPaymentCompleted
              ? 'Payment successful via ${_selectedSubMethod == PaymentMethod.aba ? "ABA Payway" : "Bakong/KHQR"}'
              : 'Bakong • ABA Payway • Any QR Bank',
          badge: _isPaymentCompleted ? 'paid' : 'instant',
          badgeColor: _isPaymentCompleted
              ? const Color(0xFF4CAF50)
              : const Color(0xFF4CAF50),
          accentColor: _isPaymentCompleted
              ? const Color(0xFF4CAF50)
              : const Color(0xFF0072CE),
          isDark: isDark,
        ),
        const SizedBox(height: 16),

        if (_selectedSubMethod != null && !_isPaymentCompleted)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'tap_payment_card_to_pay'.tr(context),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Colors.orange,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _retryPayment,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Colors.orange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (_isPaymentCompleted)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'payment_completed_successfully'.tr(context),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Payment Selection Bottom Sheet ──────────────────────────────────────────
class _PaymentSelectionBottomSheet extends StatelessWidget {
  final int totalPrice;
  final bool isDark;
  final Function(PaymentMethod) onSelected;

  const _PaymentSelectionBottomSheet({
    required this.totalPrice,
    required this.isDark,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0D1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'choose_payment_provider'.tr(context),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: isDark ? Colors.white : AppTheme.kLightText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'select_one_below'.tr(context),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          _PaymentOptionTile(
            icon: Icons.account_balance_rounded,
            title: 'ABA Payway',
            subtitle: 'Pay with ABA Mobile',
            color: const Color(0xFF0033A0),
            isDark: isDark,
            onTap: () => onSelected(PaymentMethod.aba),
          ),
          const SizedBox(height: 12),
          _PaymentOptionTile(
            icon: Icons.qr_code_2_rounded,
            title: 'Bakong / KHQR',
            subtitle: 'Scan with Bakong app',
            color: const Color(0xFF0072CE),
            isDark: isDark,
            onTap: () => onSelected(PaymentMethod.bakong),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
              ),
              child: Text(
                'cancel'.tr(context),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? Colors.white70 : AppTheme.kLightText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment Option Tile ──────────────────────────────────────────────────────
class _PaymentOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : AppTheme.kLightCardAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: isDark ? Colors.white : AppTheme.kLightText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Payment Card (Single Option) ─────────────────────────────────────────────
class _PaymentCard extends StatelessWidget {
  final bool selected;
  final bool isPaymentCompleted;
  final AnimationController animController;
  final VoidCallback onTap;
  final VoidCallback onRetry;
  final Widget icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Color accentColor;
  final bool isDark;

  const _PaymentCard({
    required this.selected,
    required this.isPaymentCompleted,
    required this.animController,
    required this.onTap,
    required this.onRetry,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPaymentCompleted ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.08)
              : (isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? accentColor
                : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected
                    ? accentColor.withValues(alpha: 0.15)
                    : (isDark
                          ? const Color(0xFF1E1E2E)
                          : AppTheme.kLightCardAlt),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? accentColor.withValues(alpha: 0.4)
                      : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                ),
              ),
              child: Center(child: icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: selected
                              ? accentColor
                              : (isDark ? Colors.white70 : AppTheme.kLightText),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: badgeColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: badgeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isPaymentCompleted)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 13),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? accentColor : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? accentColor
                        : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 13)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

// ── User Info Form ────────────────────────────────────────────────────────────
class _UserInfoForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final bool isDark;
  final bool isLoading;

  const _UserInfoForm({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.isDark,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
        ),
      ),
      child: isLoading
          ? Column(
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.kAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'loading_user_data'.tr(context),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: isDark
                            ? AppTheme.kTextSub
                            : AppTheme.kLightTextSub,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'contact_info_section'.tr(context),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: isDark ? Colors.white : AppTheme.kLightText,
                    ),
                    decoration: InputDecoration(
                      labelText: 'full_name_label'.tr(context),
                      labelStyle: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: isDark
                            ? AppTheme.kTextSub
                            : AppTheme.kLightTextSub,
                      ),
                      hintText: 'full_name_hint'.tr(context),
                      hintStyle: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: isDark
                            ? AppTheme.kTextSub
                            : AppTheme.kLightTextSub,
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: isDark
                            ? AppTheme.kTextSub
                            : AppTheme.kLightTextSub,
                        size: 20,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppTheme.kBorder
                              : AppTheme.kLightBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.kAccent,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                          width: 2,
                        ),
                      ),
                      errorStyle: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0D0D1A)
                          : AppTheme.kLightCard,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'full_name_required'.tr(context);
                      }
                      if (value.trim().length < 2) {
                        return 'name_min_length'.tr(context);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: isDark ? Colors.white : AppTheme.kLightText,
                    ),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'phone_label'.tr(context),
                      labelStyle: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: isDark
                            ? AppTheme.kTextSub
                            : AppTheme.kLightTextSub,
                      ),
                      hintText: 'phone_hint'.tr(context),
                      hintStyle: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: isDark
                            ? AppTheme.kTextSub
                            : AppTheme.kLightTextSub,
                      ),
                      prefixIcon: Icon(
                        Icons.phone_android_rounded,
                        color: isDark
                            ? AppTheme.kTextSub
                            : AppTheme.kLightTextSub,
                        size: 20,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppTheme.kBorder
                              : AppTheme.kLightBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.kAccent,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                          width: 2,
                        ),
                      ),
                      errorStyle: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0D0D1A)
                          : AppTheme.kLightCard,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'phone_required'.tr(context);
                      }
                      final phoneRegex = RegExp(r'^[0-9+\-\s]{8,15}$');
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return 'phone_invalid'.tr(context);
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Booking Summary Card ──────────────────────────────────────────────────────
class _BookingSummaryCard extends StatelessWidget {
  final int totalPrice;
  final String? selectedSport;
  final String? courtName;
  final String? date;
  final String? timeRange;
  final bool isDark;

  const _BookingSummaryCard({
    required this.totalPrice,
    this.selectedSport,
    this.courtName,
    this.date,
    this.timeRange,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
        ),
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.sports_rounded,
            label: 'sport'.tr(context),
            value: selectedSport ?? '—',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.grid_view_rounded,
            label: 'court'.tr(context),
            value: courtName ?? '—',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.calendar_today_rounded,
            label: 'date'.tr(context),
            value: date ?? '—',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.access_time_rounded,
            label: 'time'.tr(context),
            value: timeRange ?? '—',
            isDark: isDark,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: isDark ? const Color(0xFF2A2A3A) : Colors.grey[300]!,
              thickness: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total_amount'.tr(context),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: AppTheme.kAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
          size: 15,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
