import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sportbook/feature/Booking/model/booking_model.dart';
import 'package:sportbook/feature/Booking/model/create_booking_model.dart';
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

  // Create a new booking
  Future<BookingModel> createBooking(CreateBookingModel booking) async {
    try {
      final data = booking.toJson();
      if (kDebugMode) {
        print('📤 Data: $data');
      }

      final response = await _dio.post('/bookings', data: data);

      return BookingModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Failed to create booking: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Cancel a booking
  Future<BookingModel> cancelBooking(int id) async {
    try {
      // Try POST first (most common)
      try {
        final response = await _dio.put('/bookings/$id/cancel');

        // Handle different response formats
        if (response.data != null) {
          // If response is a booking object
          if (response.data is Map && response.data.containsKey('id')) {
            return BookingModel.fromJson(response.data);
          }
          // If response is a success message with data
          else if (response.data is Map && response.data.containsKey('data')) {
            return BookingModel.fromJson(response.data['data']);
          }
        }

        // If we get here, the cancellation succeeded but we couldn't parse the response
        // Fetch the updated booking
        return await getBookingById(id);
      } on DioException catch (e) {
        // If POST fails with 405 (Method Not Allowed), try PUT or PATCH
        if (e.response?.statusCode == 405) {
          try {
            final response = await _dio.put('/bookings/$id/cancel');
            return BookingModel.fromJson(response.data);
          } on DioException catch (putError) {
            if (putError.response?.statusCode == 405) {
              final response = await _dio.patch('/bookings/$id/cancel');
              return BookingModel.fromJson(response.data);
            }
            rethrow;
          }
        }
        rethrow;
      }
    } on DioException catch (e) {
      // If we get a 404, the booking might already be cancelled or doesn't exist
      if (e.response?.statusCode == 404) {
        throw Exception('Booking not found or already cancelled');
      }

      throw Exception(
        'Failed to cancel booking: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected Error cancelling booking: $e');
      }
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Alternative: Cancel booking using PATCH (if your API uses this)
  Future<BookingModel> cancelBookingWithPatch(int id) async {
    try {
      final response = await _dio.patch(
        '/bookings/$id',
        data: {'status': 'cancelled'},
      );
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
