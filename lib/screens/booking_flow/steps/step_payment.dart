import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/booking_provider.dart';

enum PaymentMethod { khqr, cash }

class StepPayment extends StatefulWidget {
  final VoidCallback onConfirm;
  const StepPayment({super.key, required this.onConfirm});

  @override
  State<StepPayment> createState() => StepPaymentState(); // ✅ public
}

class StepPaymentState
    extends
        State<StepPayment> // ✅ public, no underscore
    with TickerProviderStateMixin {
  PaymentMethod? _selected;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  late AnimationController _khqrAnim;
  late AnimationController _cashAnim;
  late AnimationController _detailAnim;

  late Animation<double> _detailFade;
  late Animation<Offset> _detailSlide;

  @override
  void initState() {
    super.initState();
    _khqrAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _cashAnim = AnimationController(
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _khqrAnim.dispose();
    _cashAnim.dispose();
    _detailAnim.dispose();
    super.dispose();
  }

  void _selectMethod(PaymentMethod method) {
    if (_selected == method) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = method);
    if (method == PaymentMethod.khqr) {
      _khqrAnim.forward();
      _cashAnim.reverse();
    } else {
      _cashAnim.forward();
      _khqrAnim.reverse();
    }
    _detailAnim.forward(from: 0);
  }

  // ✅ Public method called by booking_flow_screen via GlobalKey
  void handleConfirm() {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      final p = context.read<BookingProvider>();
      p.setUserInfo(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      widget.onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BookingProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Choose how you'd like to pay",
          style: TextStyle(color: AppTheme.kTextSub, fontSize: 13),
        ),
        const SizedBox(height: 24),
        _BookingSummaryCard(p: p),
        const SizedBox(height: 28),
        _UserInfoForm(
          formKey: _formKey,
          nameController: _nameController,
          phoneController: _phoneController,
        ),
        const SizedBox(height: 28),
        const Text(
          'SELECT PAYMENT',
          style: TextStyle(
            color: AppTheme.kTextSub,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        _PaymentCard(
          selected: _selected == PaymentMethod.khqr,
          animController: _khqrAnim,
          onTap: () => _selectMethod(PaymentMethod.khqr),
          icon: _KhqrIcon(),
          title: 'KHQR / Bank Transfer',
          subtitle: 'Scan QR code with any Cambodian banking app',
          badge: 'Instant',
          badgeColor: const Color(0xFF4CAF50),
          accentColor: const Color(0xFF0072CE),
        ),
        const SizedBox(height: 12),
        if (_selected != null)
          FadeTransition(
            opacity: _detailFade,
            child: SlideTransition(
              position: _detailSlide,
              child: Column(
                children: [
                  _selected == PaymentMethod.khqr
                      ? _KhqrDetail(totalPrice: p.totalPrice)
                      : _CashDetail(totalPrice: p.totalPrice),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── User Information Form ─────────────────────────────────────────────────────
class _UserInfoForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;

  const _UserInfoForm({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.kCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.kBorder),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONTACT INFORMATION',
              style: TextStyle(
                color: AppTheme.kTextSub,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: AppTheme.kTextSub),
                hintText: 'Enter your full name',
                hintStyle: const TextStyle(color: AppTheme.kTextSub),
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: AppTheme.kTextSub,
                  size: 20,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.kBorder),
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
                fillColor: const Color(0xFF0D0D1A),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: const TextStyle(color: AppTheme.kTextSub),
                hintText: 'Enter your phone number',
                hintStyle: const TextStyle(color: AppTheme.kTextSub),
                prefixIcon: const Icon(
                  Icons.phone_android_rounded,
                  color: AppTheme.kTextSub,
                  size: 20,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.kBorder),
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
                fillColor: const Color(0xFF0D0D1A),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                final phoneRegex = RegExp(r'^[0-9+\-\s]{8,15}$');
                if (!phoneRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid phone number';
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
  final BookingProvider p;
  const _BookingSummaryCard({required this.p});

  static String _fmtH(int h) {
    final period = h >= 12 ? 'PM' : 'AM';
    final hr = h % 12 == 0 ? 12 : h % 12;
    return '$hr:00 $period';
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final date = p.selectedDate;
    final dateStr = date != null
        ? '${_months[date.month - 1]} ${date.day}, ${date.year}'
        : '—';
    final timeStr = (p.startHour != null && p.endHour != null)
        ? '${_fmtH(p.startHour!)} – ${_fmtH(p.endHour!)}'
        : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.kCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.kBorder),
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.sports_rounded,
            label: 'Sport',
            value: p.selectedSport ?? '—',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.grid_view_rounded,
            label: 'Court',
            value: p.target?.name ?? '—',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: dateStr,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: timeStr,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFF2A2A3A), thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${p.totalPrice.toStringAsFixed(2)}',
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
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.kTextSub, size: 15),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppTheme.kTextSub, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
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
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? accentColor.withOpacity(0.08) : AppTheme.kCardAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? accentColor : AppTheme.kBorder,
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
                    ? accentColor.withOpacity(0.15)
                    : const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? accentColor.withOpacity(0.4)
                      : AppTheme.kBorder,
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
                          color: selected ? Colors.white : Colors.white70,
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
                          color: badgeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: badgeColor.withOpacity(0.4),
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
                    style: const TextStyle(
                      color: AppTheme.kTextSub,
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
                  color: selected ? accentColor : AppTheme.kBorder,
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
  final double totalPrice;
  const _KhqrDetail({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1828),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0072CE).withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0072CE).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: Color(0xFF0072CE),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KHQR Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Scan with your banking app',
                    style: TextStyle(color: AppTheme.kTextSub, fontSize: 11),
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
              child: CustomPaint(painter: _MockQrPainter()),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0072CE).withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF0072CE).withOpacity(0.35),
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
          const Text(
            'Supported Banks & Wallets',
            style: TextStyle(
              color: AppTheme.kTextSub,
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
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.kBorder),
                        ),
                        child: Text(
                          b,
                          style: const TextStyle(
                            color: Colors.white60,
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
            text: 'Open your banking app and tap "Scan QR"',
          ),
          const SizedBox(height: 8),
          _InstructionRow(step: '2', text: 'Scan the KHQR code above'),
          const SizedBox(height: 8),
          _InstructionRow(
            step: '3',
            text: 'Confirm the amount and complete the transfer',
          ),
          const SizedBox(height: 8),
          _InstructionRow(
            step: '4',
            text: 'Tap "Confirm & View QR Code" to finalize your booking',
          ),
        ],
      ),
    );
  }
}

// ── Cash Detail Panel ─────────────────────────────────────────────────────────
class _CashDetail extends StatelessWidget {
  final double totalPrice;
  const _CashDetail({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A120A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cash Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Pay at the venue counter',
                    style: TextStyle(color: AppTheme.kTextSub, fontSize: 11),
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
              color: const Color(0xFFF59E0B).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.25),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Amount Due at Venue',
                  style: TextStyle(
                    color: AppTheme.kTextSub,
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
                const Text(
                  'USD',
                  style: TextStyle(
                    color: AppTheme.kTextSub,
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
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.25)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.orange,
                  size: 15,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please arrive 10 minutes early to complete payment at the front desk before your session.',
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
            text: 'Tap "Confirm Booking" to reserve your court',
          ),
          const SizedBox(height: 8),
          _InstructionRow(
            step: '2',
            text: 'Arrive at the venue before your session',
          ),
          const SizedBox(height: 8),
          _InstructionRow(
            step: '3',
            text: 'Show your booking confirmation at the counter',
          ),
          const SizedBox(height: 8),
          _InstructionRow(
            step: '4',
            text: 'Pay the amount in cash and enjoy your game!',
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
  const _InstructionRow({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppTheme.kAccent.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.kAccent.withOpacity(0.4)),
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
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── KHQR Icon ─────────────────────────────────────────────────────────────────
class _KhqrIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.qr_code_rounded,
      color: Color(0xFF0072CE),
      size: 28,
    );
  }
}

// ── Mock QR Painter ───────────────────────────────────────────────────────────
class _MockQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A2E)
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
