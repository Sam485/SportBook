class CreateBookingModel {
  final int slotId;
  final int sportClubId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final String note;
  final String paymentMethod;
  final String transactionRef;

  CreateBookingModel({
    required this.slotId,
    required this.sportClubId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.paymentMethod,
    required this.transactionRef,
  });

  factory CreateBookingModel.fromJson(Map<String, dynamic> json) {
    return CreateBookingModel(
      slotId: json['slot_id'] ?? 0,
      sportClubId: json['sport_club_id'] ?? 0,
      bookingDate: json['booking_date'] != null
          ? DateTime.parse(json['booking_date'])
          : DateTime.now(),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      note: json['note'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      transactionRef: json['transaction_ref'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slot_id': slotId,
      'sport_club_id': sportClubId,
      'booking_date': _formatDate(bookingDate),
      'start_time': _convertTo24HourFormat(startTime),
      'end_time': _convertTo24HourFormat(endTime),
      'note': note,
      'payment_method': _getPaymentMethodValue(paymentMethod),
      'transaction_ref': transactionRef,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Convert any time format to 24-hour HH:MM
  String _convertTo24HourFormat(String timeStr) {
    if (timeStr.isEmpty) return '00:00';

    // If already in 24-hour format (HH:MM), return as is
    final regExp24 = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (regExp24.hasMatch(timeStr)) {
      return timeStr;
    }

    // Try to parse 12-hour format (e.g., "12:00 PM" or "12:00 AM")
    final regExp12 = RegExp(
      r'^([0-9]{1,2}):([0-9]{2})\s?(AM|PM)$',
      caseSensitive: false,
    );
    final match = regExp12.firstMatch(timeStr.trim());

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      final minute = match.group(2)!;
      final period = match.group(3)!.toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return '${hour.toString().padLeft(2, '0')}:$minute';
    }

    // If we can't parse it, try to extract hour and minute
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      try {
        int hour = int.parse(parts[0].replaceAll(RegExp(r'[^0-9]'), ''));
        final minute = parts[1].substring(0, 2);
        return '${hour.toString().padLeft(2, '0')}:$minute';
      } catch (_) {
        return timeStr;
      }
    }

    return timeStr;
  }

  // Get the correct payment method value for the API
  String _getPaymentMethodValue(String method) {
    // Map frontend payment method names to API expected values
    switch (method.toLowerCase()) {
      case 'khqr':
        return 'qr_code';
      case 'cash':
        return 'cash';
      case 'aba':
        return 'aba';
      case 'wing':
        return 'wing';
      case 'pi_pay':
        return 'pi_pay';
      case 'true_money':
        return 'true_money';
      default:
        return 'qr_code'; // Default to QR code
    }
  }

  // Helper method to generate transaction ID
  static String generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond % 10000;
    return 'TXN${timestamp.toString().substring(timestamp.toString().length - 8)}$random';
  }
}
