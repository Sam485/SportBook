import 'package:sportbook/feature/Booking/model/booking_model.dart';

class GetAllBookingDto {
  final List<BookingModel> data;
  final int total;
  final int page;
  final int limit;

  GetAllBookingDto({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory GetAllBookingDto.fromJson(Map<String, dynamic> json) {
    List<BookingModel> bookings = [];
    if (json['data'] != null && json['data'] is List) {
      bookings = (json['data'] as List)
          .map((e) => BookingModel.fromJson(e))
          .toList();
    }

    return GetAllBookingDto(
      data: bookings,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
    };
  }
}
