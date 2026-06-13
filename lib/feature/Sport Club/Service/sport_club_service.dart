import 'package:dio/dio.dart';
import 'package:sportbook/feature/Sport%20Club/model/dto/get_all_sport_club_dto.dart';

class SportClubService {
  final Dio dio;
  SportClubService(this.dio);
  Future<GetAllSportClubDto> getAllSportClub() async {
    try {
      final response = await dio.get('/sport-clubs?page=1&limit=10&search=');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetAllSportClubDto.fromJson(response.data);
      } else {
        throw Exception('Retrived data Failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Server responded with error
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
