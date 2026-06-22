import 'package:dio/dio.dart';
import 'package:sportbook/feature/Booking/model/booking_model.dart';
import 'package:sportbook/feature/Booking/model/get_all_booking_dto.dart';

class BookingRepository {
  final Dio _dio;

  BookingRepository(this._dio);

  // Get all bookings with pagination and status filter
  Future<GetAllBookingDto> getAllBookings({
    int page = 1,
    int limit = 10,
    String status = '',
  }) async {
    try {
      final response = await _dio.get(
        '/bookings',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status.isNotEmpty) 'status': status,
        },
      );
      return GetAllBookingDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Failed to get bookings: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Failed to get bookings: $e');
    }
  }

  // Get single booking by ID
  Future<BookingModel> getBookingById(int id) async {
    try {
      final response = await _dio.get('/bookings/$id');
      return BookingModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Failed to get booking: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  // Cancel a booking
  Future<BookingModel> cancelBooking(int id) async {
    try {
      final response = await _dio.post('/bookings/$id/cancel');
      return BookingModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Failed to cancel booking: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Get bookings by status
  Future<GetAllBookingDto> getBookingsByStatus({
    required String status,
    int page = 1,
    int limit = 10,
  }) async {
    return getAllBookings(page: page, limit: limit, status: status);
  }

  // Get upcoming bookings
  Future<GetAllBookingDto> getUpcomingBookings({
    int page = 1,
    int limit = 10,
  }) async {
    return getAllBookings(page: page, limit: limit, status: 'upcoming');
  }

  // Get past bookings
  Future<GetAllBookingDto> getPastBookings({
    int page = 1,
    int limit = 10,
  }) async {
    return getAllBookings(page: page, limit: limit, status: 'completed');
  }
}
