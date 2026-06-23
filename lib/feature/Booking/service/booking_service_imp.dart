import 'package:sportbook/feature/Booking/model/booking_model.dart';
import 'package:sportbook/feature/Booking/model/create_booking_model.dart';
import 'package:sportbook/feature/Booking/model/get_all_booking_dto.dart';
import 'package:sportbook/feature/Booking/repository/booking_repository.dart';
import 'package:sportbook/feature/Booking/service/booking_service.dart';

class BookingServiceImp implements BookingService {
  final BookingRepository _repository;

  BookingServiceImp(this._repository);

  @override
  Future<GetAllBookingDto> getAllBookings({
    int page = 1,
    int limit = 10,
    String status = '',
  }) async {
    return await _repository.getAllBookings(
      page: page,
      limit: limit,
      status: status,
    );
  }

  @override
  Future<BookingModel> getBookingById(int id) async {
    return await _repository.getBookingById(id);
  }

  @override
  Future<BookingModel> createBooking(CreateBookingModel booking) async {
    return await _repository.createBooking(booking);
  }

  @override
  Future<BookingModel> cancelBooking(int id) async {
    return await _repository.cancelBooking(id);
  }

  @override
  Future<GetAllBookingDto> getBookingsByStatus({
    required String status,
    int page = 1,
    int limit = 10,
  }) async {
    return await _repository.getBookingsByStatus(
      status: status,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<GetAllBookingDto> getUpcomingBookings({
    int page = 1,
    int limit = 10,
  }) async {
    return await _repository.getUpcomingBookings(page: page, limit: limit);
  }

  @override
  Future<GetAllBookingDto> getPastBookings({
    int page = 1,
    int limit = 10,
  }) async {
    return await _repository.getPastBookings(page: page, limit: limit);
  }
}
