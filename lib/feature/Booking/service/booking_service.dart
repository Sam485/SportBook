import 'package:sportbook/feature/Booking/model/booking_model.dart';
import 'package:sportbook/feature/Booking/model/create_booking_model.dart';
import 'package:sportbook/feature/Booking/model/get_all_booking_dto.dart';

abstract class BookingService {
  // Get all bookings with pagination
  Future<GetAllBookingDto> getAllBookings({
    int page = 1,
    int limit = 10,
    String status = '',
  });

  // Get single booking by ID
  Future<BookingModel> getBookingById(int id);

  // Create a new booking
  Future<BookingModel> createBooking(CreateBookingModel booking);

  // Cancel a booking
  Future<BookingModel> cancelBooking(int id);

  // Alternative cancel method using PATCH
  Future<BookingModel> cancelBookingWithPatch(int id);

  // Get bookings by status
  Future<GetAllBookingDto> getBookingsByStatus({
    required String status,
    int page = 1,
    int limit = 10,
  });

  // Get upcoming bookings
  Future<GetAllBookingDto> getUpcomingBookings({int page = 1, int limit = 10});

  // Get past bookings
  Future<GetAllBookingDto> getPastBookings({int page = 1, int limit = 10});
}
