import 'package:dio/dio.dart';
import 'package:sportbook/feature/Slot/Model/dto/get_all_slot_dto.dart';
import 'package:sportbook/feature/Slot/Model/slot_model.dart';

class SlotRepository {
  final Dio dio;

  SlotRepository(this.dio);

  Future<GetAllSlotsDto> getSlots({
    required int sportClubId,
    int page = 1,
    int limit = 10,
    bool available = true,
  }) async {
    try {
      final response = await dio.get(
        '/sport-clubs/$sportClubId/slots',
        queryParameters: {'page': page, 'limit': limit, 'available': available},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetAllSlotsDto.fromJson(response.data);
      } else {
        throw Exception('Failed to get slots: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Server error: ${e.response?.data['message'] ?? e.message}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Server is not responding.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<SlotModel> getSlotById(int slotId) async {
    try {
      final response = await dio.get('/slots/$slotId');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SlotModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get slot: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Server error: ${e.response?.data['message'] ?? e.message}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Server is not responding.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<GetAllSlotsDto> getSlotsBySportClubId(
    int sportClubId,
    int categoryId,
  ) async {
    try {
      final response = await dio.get(
        '/sport-clubs/$sportClubId/slots?page=1&limit=10&available=true&search=&category_id=$categoryId',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetAllSlotsDto.fromJson(response.data);
      } else {
        throw Exception('Failed to get slots: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Server error: ${e.response?.data['message'] ?? e.message}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Server is not responding.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
