import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:khqr_sdk/khqr_sdk.dart';
import 'package:sportbook/core/theme.dart'; // Import AppTheme

// ── Config ────────────────────────────────────────────────────────
class KhqrConfig {
  static const bakongAccountId = 'lik_tong@bkrt';
  static const merchantName = 'sen dy';
  static const merchantCity = 'Phnom Penh';
  static const acquiringBank = 'ACLEDA Bank';
  static const merchantId = '123456789';
  static const bakongToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7ImlkIjoiOGU5OGRhNTA0NmUyNDc0MiJ9LCJpYXQiOjE3Nzg5OTIyNjIsImV4cCI6MTc4Njc2ODI2Mn0.icrn-H2qO9KQI6ij8TmDNISShkRAjqO4L4W2hNVOTOo';
  static const checkTxUrl =
      'https://api-bakong.nbc.gov.kh/v1/check_transaction_by_md5';
  static const pollIntervalSec = 5;
  static const qrExpiryMinutes = 10;
}

// ── Public function — call from anywhere ──────────────────────────
Future<void> showKhqrPaymentSheet({
  required BuildContext context,
  required double amount,
  required VoidCallback onSuccess,
}) async {
  // Build QR first, then show sheet
  final data = await _buildQrData(amount);

  if (!context.mounted) return;

  if (data == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Failed to generate QR. Try again.',
          style: TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        backgroundColor: Colors.red.shade600,
      ),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: false,
    barrierColor: Colors.black.withOpacity(
      0.2,
    ), // Adjust opacity (lower = brighter)
    builder: (_) => KhqrPaymentSheet(
      amount: amount,
      qrString: data['qr']!,
      md5: data['md5']!,
      onSuccess: onSuccess,
    ),
  );
}

// ── QR builder ────────────────────────────────────────────────────
Future<Map<String, String>?> _buildQrData(double amount) async {
  try {
    final expiry =
        DateTime.now().millisecondsSinceEpoch +
        (KhqrConfig.qrExpiryMinutes * 60 * 1000);

    final merchantInfo = MerchantInfo(
      bakongAccountId: KhqrConfig.bakongAccountId,
      acquiringBank: KhqrConfig.acquiringBank,
      merchantId: KhqrConfig.merchantId,
      merchantName: KhqrConfig.merchantName,
      merchantCity: KhqrConfig.merchantCity,
      currency: KhqrCurrency.usd,
      amount: amount,
      expirationTimestamp: expiry,
    );

    final khqr = KhqrSdk();

    final KhqrData? result = await khqr.generateMerchant(merchantInfo);

    if (result == null) {
      return null;
    }

    return {'qr': result.qr, 'md5': result.md5};
  } catch (e) {
    debugPrint('KHQR generation error: $e');
    return null;
  }
}

// ── KHQR Sheet Widget ─────────────────────────────────────────────
class KhqrPaymentSheet extends StatefulWidget {
  final double amount;
  final String qrString;
  final String md5;
  final VoidCallback onSuccess;

  const KhqrPaymentSheet({
    super.key,
    required this.amount,
    required this.qrString,
    required this.md5,
    required this.onSuccess,
  });

  @override
  State<KhqrPaymentSheet> createState() => _KhqrPaymentSheetState();
}

class _KhqrPaymentSheetState extends State<KhqrPaymentSheet> {
  String _status = 'waiting'; // waiting | paid | expired | error
  String? _errorMsg;
  Timer? _pollTimer;
  Timer? _expiryTimer;
  int _secondsLeft = KhqrConfig.qrExpiryMinutes * 60;

  @override
  void initState() {
    super.initState();
    _startPolling();
    _startExpiryCountdown();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _expiryTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _checkPayment();
    _pollTimer = Timer.periodic(
      Duration(seconds: KhqrConfig.pollIntervalSec),
      (_) => _checkPayment(),
    );
  }

  void _startExpiryCountdown() {
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        _expiryTimer?.cancel();
        _pollTimer?.cancel();
        if (_status == 'waiting') setState(() => _status = 'expired');
      }
    });
  }

  Future<void> _checkPayment() async {
    if (_status != 'waiting') return;
    try {
      final res = await http
          .post(
            Uri.parse(KhqrConfig.checkTxUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${KhqrConfig.bakongToken}',
            },
            body: jsonEncode({'md5': widget.md5}),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;
      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (body['responseCode'] == 0 && body['data'] != null) {
        _pollTimer?.cancel();
        _expiryTimer?.cancel();
        setState(() => _status = 'paid');
      } else if (body['responseCode'] != 0 && body['responseCode'] != 1) {
        setState(() {
          _status = 'error';
          _errorMsg = body['responseMessage']?.toString();
        });
      }
    } on TimeoutException {
      // Keep polling
    } catch (e) {
      debugPrint('Poll error: $e');
    }
  }

  String get _timerText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(22, 12, 22, bottom + 24),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.border(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/logo/bakong-logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.qr_code_2_outlined,
                    color: Color(0xFF1565C0),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan to Pay',
                    style: AppTheme.tsTitleAdaptive(
                      context,
                    ).copyWith(fontSize: 18),
                  ),
                  Text('Bakong · KHQR', style: AppTheme.tsSubAdaptive(context)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.kAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$ ${widget.amount.toStringAsFixed(2)}',
                  style: AppTheme.tsSubAdaptive(context).copyWith(
                    color: AppTheme.kAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_status == 'waiting') _buildWaiting(context),
          if (_status == 'paid') _buildSuccess(context),
          if (_status == 'expired') _buildExpired(context),
          if (_status == 'error') _buildError(context),
        ],
      ),
    );
  }

  Widget _buildWaiting(BuildContext context) {
    final isExpiringSoon = _secondsLeft < 60;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardAlt(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.border(context), width: 1),
          ),
          child: KhqrCardWidget(
            width: 270,
            amount: widget.amount,
            qr: widget.qrString,
            receiverName: KhqrConfig.merchantName,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpiringSoon
                  ? Icons.warning_amber_rounded
                  : Icons.access_time_outlined,
              size: 14,
              color: isExpiringSoon
                  ? const Color(0xFFFF9800)
                  : AppTheme.textSub(context),
            ),
            const SizedBox(width: 5),
            Text(
              'QR expires in $_timerText',
              style: AppTheme.tsSubAdaptive(context).copyWith(
                color: isExpiringSoon
                    ? const Color(0xFFFF9800)
                    : AppTheme.textSub(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const CircularProgressIndicator(
          color: AppTheme.kAccent,
          strokeWidth: 2,
        ),
        const SizedBox(height: 8),
        Text('Waiting for payment...', style: AppTheme.tsSubAdaptive(context)),
        const SizedBox(height: 8),
        Text(
          'Scan with Bakong app',
          style: AppTheme.tsSubAdaptive(
            context,
          ).copyWith(fontSize: 12, color: AppTheme.textSub(context)),
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF4CAF50),
            size: 44,
          ),
        ),
        const SizedBox(height: 16),
        Text('Payment Successful!', style: AppTheme.tsTitleAdaptive(context)),
        const SizedBox(height: 6),
        Text(
          '\$ ${widget.amount.toStringAsFixed(2)} paid successfully',
          style: AppTheme.tsBodyAdaptive(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onSuccess();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kAccent,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            child: Text(
              'Done',
              style: AppTheme.tsLabelAdaptive(context).copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpired(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.timer_off_outlined,
            color: Color(0xFFFF9800),
            size: 44,
          ),
        ),
        const SizedBox(height: 16),
        Text('QR Code Expired', style: AppTheme.tsTitleAdaptive(context)),
        const SizedBox(height: 6),
        Text(
          'Please generate a new QR code to continue.',
          style: AppTheme.tsBodyAdaptive(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kAccent,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            child: Text(
              'Generate New QR',
              style: AppTheme.tsLabelAdaptive(context).copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFE53935),
            size: 44,
          ),
        ),
        const SizedBox(height: 16),
        Text('Something Went Wrong', style: AppTheme.tsTitleAdaptive(context)),
        const SizedBox(height: 6),
        Text(
          _errorMsg ?? 'Unable to verify payment. Contact support.',
          style: AppTheme.tsBodyAdaptive(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kAccent,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            child: Text(
              'Close',
              style: AppTheme.tsLabelAdaptive(context).copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
