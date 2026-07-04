import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sportbook/core/theme.dart'; // Import AppTheme

// ─────────────────────────────────────────────────────────────
// ABA PAYWAY CONFIG
// ─────────────────────────────────────────────────────────────

class AbaPaywayConfig {
  /// Get these from your sandbox registration email:
  /// https://sandbox.payway.com.kh/register-sandbox/
  static const merchantId =
      'ec475457'; // verify this matches your sandbox email
  static const apiKey =
      'cf929e030249169f5ff5da3630abba7649df6938'; // verify this too

  static const baseUrl = 'https://checkout-sandbox.payway.com.kh';

  static const generateQrEndpoint =
      '$baseUrl/api/payment-gateway/v1/payments/generate-qr';

  static const checkTxEndpoint =
      '$baseUrl/api/payment-gateway/v1/payments/check-transaction-2';

  static const qrLifetimeMin = 10;
  static const pollIntervalSec = 5;
}

// ─────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────

String _uniqueTranId() => DateTime.now().millisecondsSinceEpoch.toString();

String _reqTime() {
  final n = DateTime.now().toUtc();
  return '${n.year}'
      '${n.month.toString().padLeft(2, '0')}'
      '${n.day.toString().padLeft(2, '0')}'
      '${n.hour.toString().padLeft(2, '0')}'
      '${n.minute.toString().padLeft(2, '0')}'
      '${n.second.toString().padLeft(2, '0')}';
}

String _generateHash(String raw) {
  final hmac = Hmac(sha512, utf8.encode(AbaPaywayConfig.apiKey));
  return base64Encode(hmac.convert(utf8.encode(raw)).bytes);
}

String _buildCheckTransactionHash({
  required String reqTime,
  required String merchantId,
  required String tranId,
}) => _generateHash('$reqTime$merchantId$tranId');

// ─────────────────────────────────────────────────────────────
// DEBUG — call once at app start to verify credentials
// ─────────────────────────────────────────────────────────────

void debugAbaCredentials() {
  debugPrint('=== ABA CREDENTIAL DEBUG ===');
  debugPrint('MERCHANT ID   => ${AbaPaywayConfig.merchantId}');
  debugPrint('API KEY       => ${AbaPaywayConfig.apiKey}');
  debugPrint('API KEY BYTES => ${utf8.encode(AbaPaywayConfig.apiKey)}');
  debugPrint('============================');
}

// ─────────────────────────────────────────────────────────────
// PUBLIC ENTRY
// ─────────────────────────────────────────────────────────────

Future<void> showAbaPaywaySheet({
  required BuildContext context,
  required double amount,
  required VoidCallback onSuccess,
}) async {
  final result = await _generateQr(amount);

  if (!context.mounted) return;

  if (result == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Failed to generate ABA QR payment.',
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
    useSafeArea: true,
    builder: (_) => AbaPaywaySheet(
      amount: amount,
      tranId: result['tran_id']!,
      qrString: result['qr_string'],
      qrImage: result['qr_image'],
      onSuccess: onSuccess,
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// GENERATE QR
// ─────────────────────────────────────────────────────────────

Future<Map<String, String?>?> _generateQr(double amount) async {
  try {
    final reqTime = _reqTime();
    final tranId = _uniqueTranId();

    const firstName = 'BCoffee';
    const lastName = 'App';
    const phone = '000000000';
    const email = 'info@bcoffee.com';
    const purchaseType = 'purchase';
    const paymentOption = 'abapay_khqr';
    const currency = 'USD';
    const qrImageTemplate = 'template4_color';
    const lifetime = 10;

    final amountStr = amount.toStringAsFixed(2);

    // Items — base64 encoded JSON
    final rawItems = jsonEncode([
      {"name": "Wallet Top Up", "quantity": 1, "price": amount},
    ]);
    final items = base64Encode(utf8.encode(rawItems));

    // Optional fields that are null → use empty string in hash
    const callbackUrl = '';
    const returnDeeplink = '';
    const customFields = '';
    const returnParams = '';
    const payout = '';

    // CORRECT hash order per ABA docs:
    final rawHash =
        reqTime +
        AbaPaywayConfig.merchantId +
        tranId +
        amountStr +
        items +
        firstName +
        lastName +
        email +
        phone +
        purchaseType +
        paymentOption +
        callbackUrl +
        returnDeeplink +
        currency +
        customFields +
        returnParams +
        payout +
        lifetime.toString() +
        qrImageTemplate;

    debugPrint('RAW HASH => $rawHash');

    final hash = _generateHash(rawHash);

    debugPrint('HASH => $hash');

    final body = jsonEncode({
      "req_time": reqTime,
      "merchant_id": AbaPaywayConfig.merchantId,
      "tran_id": tranId,
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "amount": amountStr,
      "purchase_type": purchaseType,
      "payment_option": paymentOption,
      "items": items,
      "currency": currency,
      "callback_url": null,
      "return_deeplink": null,
      "custom_fields": null,
      "return_params": null,
      "payout": null,
      "lifetime": lifetime,
      "qr_image_template": qrImageTemplate,
      "hash": hash,
    });

    debugPrint('ABA REQUEST => $body');

    final response = await http.post(
      Uri.parse(AbaPaywayConfig.generateQrEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    debugPrint('ABA RESPONSE => ${response.body}');

    final json = jsonDecode(response.body);
    final status = json['status'];

    if (status['code'].toString() != '0') {
      debugPrint('ABA ERROR => $status');
      return null;
    }

    return {
      'tran_id': tranId,
      'qr_string': json['qrString'],
      'qr_image': json['qrImage'],
    };
  } catch (e) {
    debugPrint('ABA EXCEPTION => $e');
    return null;
  }
}

// ─────────────────────────────────────────────────────────────
// PAYMENT SHEET WIDGET
// ─────────────────────────────────────────────────────────────

class AbaPaywaySheet extends StatefulWidget {
  final double amount;
  final String tranId;
  final String? qrString;
  final String? qrImage;
  final VoidCallback onSuccess;

  const AbaPaywaySheet({
    super.key,
    required this.amount,
    required this.tranId,
    required this.qrString,
    required this.qrImage,
    required this.onSuccess,
  });

  @override
  State<AbaPaywaySheet> createState() => _AbaPaywaySheetState();
}

class _AbaPaywaySheetState extends State<AbaPaywaySheet> {
  String _status = 'waiting';
  Timer? _pollTimer;
  Timer? _expiryTimer;
  int _secondsLeft = AbaPaywayConfig.qrLifetimeMin * 60;

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
    _checkTransaction();
    _pollTimer = Timer.periodic(
      Duration(seconds: AbaPaywayConfig.pollIntervalSec),
      (_) => _checkTransaction(),
    );
  }

  void _startExpiryCountdown() {
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        _expiryTimer?.cancel();
        _pollTimer?.cancel();
        setState(() => _status = 'expired');
      }
    });
  }

  Future<void> _checkTransaction() async {
    if (_status != 'waiting') return;
    try {
      final reqTime = _reqTime();
      final params = jsonEncode({
        'req_time': reqTime,
        'merchant_id': AbaPaywayConfig.merchantId,
        'tran_id': widget.tranId,
        'hash': _buildCheckTransactionHash(
          reqTime: reqTime,
          merchantId: AbaPaywayConfig.merchantId,
          tranId: widget.tranId,
        ),
      });

      final response = await http.post(
        Uri.parse(AbaPaywayConfig.checkTxEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: params,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final paymentStatus = body['data']?['payment_status'];

      if (paymentStatus == 'APPROVED') {
        _pollTimer?.cancel();
        _expiryTimer?.cancel();
        if (!mounted) return;
        setState(() => _status = 'paid');
      }
    } catch (e) {
      debugPrint('CHECK TX ERROR => $e');
    }
  }

  // Decode base64 QR image (fallback)
  Uint8List? get _qrBytes {
    if (widget.qrImage == null) return null;
    final raw = widget.qrImage!.replaceFirst('data:image/png;base64,', '');
    return base64Decode(raw);
  }

  Widget _buildQrWidget() {
    // Fallback: base64 image from ABA API
    if (_qrBytes != null) {
      return Image.memory(
        _qrBytes!,
        width: 400,
        height: 400,
        fit: BoxFit.contain,
      );
    }

    return const SizedBox(width: 400, height: 400);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.7,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return Container(
          padding: EdgeInsets.fromLTRB(22, 12, 22, bottom + 24),
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.border(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Text(
                  'ABA PayWay',
                  style: AppTheme.tsTitleAdaptive(
                    context,
                  ).copyWith(fontSize: 20),
                ),

                const SizedBox(height: 24),

                if (_status == 'waiting') _buildWaiting(context),
                if (_status == 'paid') _buildSuccess(context),
                if (_status == 'expired') _buildExpired(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaiting(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpiringSoon = _secondsLeft < 60;

    return Column(
      children: [
        // QR Code container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ],
          ),
          child: _buildQrWidget(),
        ),

        const SizedBox(height: 24),

        Text(
          '\$${widget.amount.toStringAsFixed(2)}',
          style: AppTheme.tsTitleAdaptive(context).copyWith(fontSize: 24),
        ),

        const SizedBox(height: 10),

        Text(
          'Scan with ABA or KHQR supported banking app',
          textAlign: TextAlign.center,
          style: AppTheme.tsBodyAdaptive(context),
        ),

        const SizedBox(height: 24),

        const CircularProgressIndicator(
          color: AppTheme.kAccent,
          strokeWidth: 2,
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
              'Expires in ${_secondsLeft}s',
              style: AppTheme.tsSubAdaptive(context).copyWith(
                color: isExpiringSoon
                    ? const Color(0xFFFF9800)
                    : AppTheme.textSub(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
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

        const SizedBox(height: 20),

        Text('Payment Successful', style: AppTheme.tsTitleAdaptive(context)),

        const SizedBox(height: 8),

        Text(
          '\$${widget.amount.toStringAsFixed(2)} added to your wallet',
          style: AppTheme.tsBodyAdaptive(context),
        ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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

        const SizedBox(height: 20),

        Text('QR Expired', style: AppTheme.tsTitleAdaptive(context)),

        const SizedBox(height: 8),

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
            onPressed: () => Navigator.pop(context),
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
}
