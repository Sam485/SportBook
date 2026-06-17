// feature/Sport Club/Repository/sport_club_repository.dart
import 'package:dio/dio.dart';
import 'package:sportbook/feature/SportClub/model/dto/get_all_sport_club_dto.dart';

class SportClubRepository {
  final Dio dio;

  SportClubRepository(this.dio);

  Future<GetAllSportClubDto> getAllSportClub({
    int page = 1,
    int limit = 10,
    String search = '',
    String? categoryId,
    double? lat,
    double? lng,
    double? radius,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        if (search.isNotEmpty) 'search': search,
        if (categoryId != null) 'category_id': categoryId,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (radius != null) 'radius': radius,
      };

      final response = await dio.get(
        '/sport-clubs',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetAllSportClubDto.fromJson(response.data);
      } else {
        throw Exception('Retrieved data Failed: ${response.statusCode}');
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
