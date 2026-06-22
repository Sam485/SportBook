class BookingPaymentDto {
  final int id;
  final double amount; // Changed to double
  final String method;
  final String status;
  final String transactionRef;
  final String? proofImageUrl;
  final DateTime? paidAt;
  final String? note;
  final DateTime createdAt;

  BookingPaymentDto({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    required this.transactionRef,
    this.proofImageUrl,
    this.paidAt,
    this.note,
    required this.createdAt,
  });

  factory BookingPaymentDto.fromJson(Map<String, dynamic> json) {
    return BookingPaymentDto(
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      method: json['method'] ?? '',
      status: json['status'] ?? '',
      transactionRef: json['transaction_ref'] ?? '',
      proofImageUrl: json['proof_image_url'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      note: json['note'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'method': method,
      'status': status,
      'transaction_ref': transactionRef,
      'proof_image_url': proofImageUrl,
      'paid_at': paidAt?.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
