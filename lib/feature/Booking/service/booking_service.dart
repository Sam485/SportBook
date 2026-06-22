import 'package:sportbook/feature/Booking/model/booking_model.dart';
import 'package:sportbook/feature/Booking/model/get_all_booking_dto.dart';

abstract class BookingService {
  Future<GetAllBookingDto> getAllBookings({
    int page = 1,
    int limit = 10,
    String status = '',
  });

  Future<BookingModel> getBookingById(int id);

  Future<BookingModel> cancelBooking(int id);

  Future<GetAllBookingDto> getBookingsByStatus({
    required String status,
    int page = 1,
    int limit = 10,
  });

  Future<GetAllBookingDto> getUpcomingBookings({int page = 1, int limit = 10});

  Future<GetAllBookingDto> getPastBookings({int page = 1, int limit = 10});
}
