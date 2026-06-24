import 'package:sportbook/feature/Booking/model/dto/booking_payment_dto.dart';
import 'package:sportbook/feature/Booking/model/dto/slot_booking_model_dto.dart';
import 'package:sportbook/feature/Booking/model/dto/sportclub_booking_dto.dart';
import 'package:sportbook/feature/Booking/model/dto/user_booking_dto.dart';

class BookingModel {
  final int id;
  final UserBookingDto user;
  final SlotBookingModelDto slot;
  final SportclubBookingDto sportClub;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final int totalAmount;
  final String status;
  final String note;
  final String paymentStatus;
  final BookingPaymentDto? payment;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.user,
    required this.slot,
    required this.sportClub,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    required this.status,
    required this.note,
    required this.paymentStatus,
    this.payment,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,
      user: UserBookingDto.fromJson(json['user'] ?? {}),
      slot: SlotBookingModelDto.fromJson(json['slot'] ?? {}),
      sportClub: SportclubBookingDto.fromJson(json['sport_club'] ?? {}),
      bookingDate: json['booking_date'] != null
          ? DateTime.parse(json['booking_date'])
          : DateTime.now(),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      totalAmount: json['total_amount'] ?? 0,
      status: json['status'] ?? '',
      note: json['note'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      payment: json['payment'] != null
          ? BookingPaymentDto.fromJson(json['payment'])
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'slot': slot.toJson(),
      'sport_club': sportClub.toJson(),
      'booking_date': bookingDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'total_amount': totalAmount,
      'status': status,
      'note': note,
      'payment_status': paymentStatus,
      'payment': payment?.toJson(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
