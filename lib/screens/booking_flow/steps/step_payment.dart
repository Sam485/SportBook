import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme.dart';
import '../../../translations/app_translations.dart';

// ignore: constant_identifier_names
enum PaymentMethod { khqr, cash, aba, wing, pi_pay, true_money }

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

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  late AnimationController _khqrAnim;
  late AnimationController _cashAnim;
  late AnimationController _abaAnim;
  late AnimationController _wingAnim;
  late AnimationController _piPayAnim;
  late AnimationController _trueMoneyAnim;
  late AnimationController _detailAnim;

  late Animation<double> _detailFade;
  late Animation<Offset> _detailSlide;

  // Map of payment methods with their details
  final List<PaymentMethodConfig> _paymentMethods = [
    PaymentMethodConfig(
      method: PaymentMethod.khqr,
      label: 'KHQR',
      icon: Icons.qr_code_rounded,
      accentColor: const Color(0xFF0072CE),
      badge: 'instant',
      badgeColor: const Color(0xFF4CAF50),
    ),
    PaymentMethodConfig(
      method: PaymentMethod.aba,
      label: 'ABA',
      icon: Icons.account_balance_rounded,
      accentColor: const Color(0xFF0033A0),
      badge: 'popular',
      badgeColor: const Color(0xFF2196F3),
    ),
    PaymentMethodConfig(
      method: PaymentMethod.wing,
      label: 'Wing',
      icon: Icons.phone_android_rounded,
      accentColor: const Color(0xFFE31E24),
      badge: 'fast',
      badgeColor: const Color(0xFFFF5722),
    ),
    PaymentMethodConfig(
      method: PaymentMethod.pi_pay,
      label: 'Pi Pay',
      icon: Icons.payment_rounded,
      accentColor: const Color(0xFF00A651),
      badge: 'secure',
      badgeColor: const Color(0xFF4CAF50),
    ),
    PaymentMethodConfig(
      method: PaymentMethod.true_money,
      label: 'True Money',
      icon: Icons.wallet_rounded,
      accentColor: const Color(0xFFF57C00),
      badge: 'trusted',
      badgeColor: const Color(0xFFFF9800),
    ),
    PaymentMethodConfig(
      method: PaymentMethod.cash,
      label: 'Cash',
      icon: Icons.payments_rounded,
      accentColor: const Color(0xFFF59E0B),
      badge: 'onsite',
      badgeColor: const Color(0xFFFF9800),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Set initial selection if provided
    if (widget.selectedPaymentMethod != null) {
      _selected = _getPaymentMethodFromString(widget.selectedPaymentMethod!);
    }

    _khqrAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _cashAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _abaAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _wingAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _piPayAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _trueMoneyAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _detailAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _detailFade = CurvedAnimation(parent: _detailAnim, curve: Curves.easeOut);
    _detailSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _detailAnim, curve: Curves.easeOut));

    // If a method was pre-selected, animate it
    if (_selected != null) {
      _getAnimationController(_selected!).forward();
      _detailAnim.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _khqrAnim.dispose();
    _cashAnim.dispose();
    _abaAnim.dispose();
    _wingAnim.dispose();
    _piPayAnim.dispose();
    _trueMoneyAnim.dispose();
    _detailAnim.dispose();
    super.dispose();
  }

  PaymentMethod _getPaymentMethodFromString(String method) {
    switch (method.toLowerCase()) {
      case 'khqr':
        return PaymentMethod.khqr;
      case 'cash':
        return PaymentMethod.cash;
      case 'aba':
        return PaymentMethod.aba;
      case 'wing':
        return PaymentMethod.wing;
      case 'pi_pay':
        return PaymentMethod.pi_pay;
      case 'true_money':
        return PaymentMethod.true_money;
      default:
        return PaymentMethod.khqr;
    }
  }

  AnimationController _getAnimationController(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.khqr:
        return _khqrAnim;
      case PaymentMethod.cash:
        return _cashAnim;
      case PaymentMethod.aba:
        return _abaAnim;
      case PaymentMethod.wing:
        return _wingAnim;
      case PaymentMethod.pi_pay:
        return _piPayAnim;
      case PaymentMethod.true_money:
        return _trueMoneyAnim;
    }
  }

  void _selectMethod(PaymentMethod method) {
    if (_selected == method) return;
    HapticFeedback.selectionClick();

    // Reset all animations
    for (var anim in _getAllAnimationControllers()) {
      if (anim != _getAnimationController(method)) {
        anim.reverse();
      }
    }

    setState(() {
      _selected = method;
      // Pass the payment method in API format
      widget.onPaymentMethodSelected(_getPaymentMethodString(method));
    });

    _getAnimationController(method).forward();
    _detailAnim.forward(from: 0);
  }

  String _getPaymentMethodString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.khqr:
        return 'khqr';
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.aba:
        return 'aba';
      case PaymentMethod.wing:
        return 'wing';
      case PaymentMethod.pi_pay:
        return 'pi_pay';
      case PaymentMethod.true_money:
        return 'true_money';
    }
  }

  List<AnimationController> _getAllAnimationControllers() {
    return [
      _khqrAnim,
      _cashAnim,
      _abaAnim,
      _wingAnim,
      _piPayAnim,
      _trueMoneyAnim,
    ];
  }

  void handleConfirm() {
    // Check if mounted before using context
    if (!mounted) return;

    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('select_payment_method'.tr(context)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      widget.onConfirm();
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
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'choose_payment_desc'.tr(context),
          style: TextStyle(
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 13,
          ),
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
        _UserInfoForm(
          formKey: _formKey,
          nameController: _nameController,
          phoneController: _phoneController,
          isDark: isDark,
        ),
        const SizedBox(height: 28),
        Text(
          'select_payment_section'.tr(context),
          style: TextStyle(
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        ..._paymentMethods.map(
          (config) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PaymentCard(
              selected: _selected == config.method,
              animController: _getAnimationController(config.method),
              onTap: () => _selectMethod(config.method),
              icon: _PaymentIcon(icon: config.icon, color: config.accentColor),
              title: config.label,
              subtitle: _getSubtitle(config.method, context),
              badge: config.badge,
              badgeColor: config.badgeColor,
              accentColor: config.accentColor,
              isDark: isDark,
            ),
          ),
        ),
        if (_selected != null)
          FadeTransition(
            opacity: _detailFade,
            child: SlideTransition(
              position: _detailSlide,
              child: Column(children: [_buildPaymentDetail(context, isDark)]),
            ),
          ),
      ],
    );
  }

  String _getSubtitle(PaymentMethod method, BuildContext context) {
    switch (method) {
      case PaymentMethod.khqr:
        return 'khqr_subtitle'.tr(context);
      case PaymentMethod.cash:
        return 'cash_subtitle'.tr(context);
      case PaymentMethod.aba:
        return 'aba_subtitle'.tr(context);
      case PaymentMethod.wing:
        return 'wing_subtitle'.tr(context);
      case PaymentMethod.pi_pay:
        return 'pi_pay_subtitle'.tr(context);
      case PaymentMethod.true_money:
        return 'true_money_subtitle'.tr(context);
    }
  }

  Widget _buildPaymentDetail(BuildContext context, bool isDark) {
    switch (_selected) {
      case PaymentMethod.khqr:
        return _KhqrDetail(totalPrice: widget.totalPrice, isDark: isDark);
      case PaymentMethod.cash:
        return _CashDetail(totalPrice: widget.totalPrice, isDark: isDark);
      case PaymentMethod.aba:
        return _GenericPaymentDetail(
          title: 'ABA',
          icon: Icons.account_balance_rounded,
          color: const Color(0xFF0033A0),
          steps: [
            'aba_step1'.tr(context),
            'aba_step2'.tr(context),
            'aba_step3'.tr(context),
            'aba_step4'.tr(context),
          ],
          totalPrice: widget.totalPrice,
          isDark: isDark,
        );
      case PaymentMethod.wing:
        return _GenericPaymentDetail(
          title: 'Wing',
          icon: Icons.phone_android_rounded,
          color: const Color(0xFFE31E24),
          steps: [
            'wing_step1'.tr(context),
            'wing_step2'.tr(context),
            'wing_step3'.tr(context),
            'wing_step4'.tr(context),
          ],
          totalPrice: widget.totalPrice,
          isDark: isDark,
        );
      case PaymentMethod.pi_pay:
        return _GenericPaymentDetail(
          title: 'Pi Pay',
          icon: Icons.payment_rounded,
          color: const Color(0xFF00A651),
          steps: [
            'pi_pay_step1'.tr(context),
            'pi_pay_step2'.tr(context),
            'pi_pay_step3'.tr(context),
            'pi_pay_step4'.tr(context),
          ],
          totalPrice: widget.totalPrice,
          isDark: isDark,
        );
      case PaymentMethod.true_money:
        return _GenericPaymentDetail(
          title: 'True Money',
          icon: Icons.wallet_rounded,
          color: const Color(0xFFF57C00),
          steps: [
            'true_money_step1'.tr(context),
            'true_money_step2'.tr(context),
            'true_money_step3'.tr(context),
            'true_money_step4'.tr(context),
          ],
          totalPrice: widget.totalPrice,
          isDark: isDark,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Payment Method Config ─────────────────────────────────────────────────────
class PaymentMethodConfig {
  final PaymentMethod method;
  final String label;
  final IconData icon;
  final Color accentColor;
  final String badge;
  final Color badgeColor;

  const PaymentMethodConfig({
    required this.method,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.badge,
    required this.badgeColor,
  });
}

// ── Payment Icon ──────────────────────────────────────────────────────────────
class _PaymentIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _PaymentIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color, size: 28);
  }
}

// ── Generic Payment Detail ───────────────────────────────────────────────────
class _GenericPaymentDetail extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> steps;
  final int totalPrice;
  final bool isDark;

  const _GenericPaymentDetail({
    required this.title,
    required this.icon,
    required this.color,
    required this.steps,
    required this.totalPrice,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A1828) : AppTheme.kLightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.kLightText,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${'pay_with'.tr(context)} $title',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Text(
                  'amount_due'.tr(context),
                  style: TextStyle(
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _InstructionRow(
                step: '${index + 1}',
                text: step,
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── User Information Form ─────────────────────────────────────────────────────
class _UserInfoForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final bool isDark;

  const _UserInfoForm({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
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
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'contact_info_section'.tr(context),
              style: TextStyle(
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
              ),
              decoration: InputDecoration(
                labelText: 'full_name_label'.tr(context),
                labelStyle: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                hintText: 'full_name_hint'.tr(context),
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  size: 20,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
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
                color: isDark ? Colors.white : AppTheme.kLightText,
              ),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'phone_label'.tr(context),
                labelStyle: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                hintText: 'phone_hint'.tr(context),
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                prefixIcon: Icon(
                  Icons.phone_android_rounded,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  size: 20,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
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
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
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
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Payment Option Card ───────────────────────────────────────────────────────
class _PaymentCard extends StatelessWidget {
  final bool selected;
  final AnimationController animController;
  final VoidCallback onTap;
  final Widget icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Color accentColor;
  final bool isDark;

  const _PaymentCard({
    required this.selected,
    required this.animController,
    required this.onTap,
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
      onTap: onTap,
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

// ── KHQR Detail Panel ─────────────────────────────────────────────────────────
class _KhqrDetail extends StatelessWidget {
  final int totalPrice;
  final bool isDark;

  const _KhqrDetail({required this.totalPrice, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A1828) : AppTheme.kLightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0072CE).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0072CE).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: Color(0xFF0072CE),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'khqr_title'.tr(context),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.kLightText,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'khqr_subtitle'.tr(context),
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CustomPaint(painter: _MockQrPainter(isDark: isDark)),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0072CE).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF0072CE).withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              '\$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF0072CE),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'supported_banks'.tr(context),
            style: TextStyle(
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children:
                [
                      'ABA',
                      'ACLEDA',
                      'Wing',
                      'Pi Pay',
                      'True Money',
                      'Phillip Bank',
                      'Canadia',
                    ]
                    .map(
                      (b) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A1A2E)
                              : AppTheme.kLightCardAlt,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.kBorder
                                : AppTheme.kLightBorder,
                          ),
                        ),
                        child: Text(
                          b,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white60
                                : AppTheme.kLightTextSub,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 16),
          _InstructionRow(
            step: '1',
            text: 'khqr_step1'.tr(context),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _InstructionRow(
            step: '2',
            text: 'khqr_step2'.tr(context),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _InstructionRow(
            step: '3',
            text: 'khqr_step3'.tr(context),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _InstructionRow(
            step: '4',
            text: 'khqr_step4'.tr(context),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ── Cash Detail Panel ─────────────────────────────────────────────────────────
class _CashDetail extends StatelessWidget {
  final int totalPrice;
  final bool isDark;

  const _CashDetail({required this.totalPrice, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A120A) : AppTheme.kLightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'cash_title'.tr(context),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.kLightText,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'cash_subtitle'.tr(context),
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'amount_due'.tr(context),
                  style: TextStyle(
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'usd'.tr(context),
                  style: TextStyle(
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.orange,
                  size: 15,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'cash_note'.tr(context),
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 11.5,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InstructionRow(
            step: '1',
            text: 'cash_step1'.tr(context),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _InstructionRow(
            step: '2',
            text: 'cash_step2'.tr(context),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _InstructionRow(
            step: '3',
            text: 'cash_step3'.tr(context),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _InstructionRow(
            step: '4',
            text: 'cash_step4'.tr(context),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ── Instruction Row ───────────────────────────────────────────────────────────
class _InstructionRow extends StatelessWidget {
  final String step;
  final String text;
  final bool isDark;

  const _InstructionRow({
    required this.step,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppTheme.kAccent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.kAccent.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: AppTheme.kAccent,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mock QR Painter ───────────────────────────────────────────────────────────
class _MockQrPainter extends CustomPainter {
  final bool isDark;

  _MockQrPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE0E0E0)
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 21;

    void drawCell(int col, int row) {
      canvas.drawRect(
        Rect.fromLTWH(
          col * cellSize,
          row * cellSize,
          cellSize - 0.5,
          cellSize - 0.5,
        ),
        paint,
      );
    }

    void drawSquare(int col, int row, int size) {
      for (int i = col; i < col + size; i++) {
        drawCell(i, row);
        drawCell(i, row + size - 1);
      }
      for (int j = row; j < row + size; j++) {
        drawCell(col, j);
        drawCell(col + size - 1, j);
      }
      for (int i = col + 2; i < col + size - 2; i++) {
        for (int j = row + 2; j < row + size - 2; j++) {
          drawCell(i, j);
        }
      }
    }

    drawSquare(0, 0, 7);
    drawSquare(14, 0, 7);
    drawSquare(0, 14, 7);

    for (int i = 8; i < 13; i += 2) {
      drawCell(i, 6);
      drawCell(6, i);
    }

    final pattern = [
      [8, 8],
      [9, 8],
      [10, 9],
      [8, 10],
      [11, 10],
      [9, 11],
      [12, 8],
      [13, 9],
      [14, 11],
      [10, 12],
      [8, 13],
      [11, 13],
      [13, 13],
      [9, 15],
      [12, 15],
      [15, 8],
      [16, 9],
      [17, 8],
      [15, 10],
      [18, 10],
      [16, 12],
      [17, 13],
      [18, 8],
      [19, 9],
      [20, 10],
      [8, 16],
      [9, 17],
      [10, 18],
      [11, 16],
      [12, 17],
      [8, 19],
      [10, 20],
      [11, 19],
      [13, 18],
      [14, 19],
    ];

    for (final cell in pattern) {
      drawCell(cell[0], cell[1]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
